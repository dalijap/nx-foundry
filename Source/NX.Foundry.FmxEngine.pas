{*******************************************************************************

  MIT License

  Copyright (c) 2012-2026 Dalija Prasnikar

  https://dalija.prasnikar.info

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in all
  copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
  SOFTWARE.

********************************************************************************}

unit NX.Foundry.FmxEngine;

{$I 'NX.inc'}

interface

uses
  System.StartUpCopy,
  System.Types,
  System.UITypes,
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Threading,
  System.IOUtils,
  System.Actions,
  FMX.Types,
  FMX.Objects,
  FMX.Graphics,
  FMX.Controls,
  FMX.DialogService,
  FMX.Forms,
  FMX.StdCtrls,
  FMX.TreeView,
  FMX.Layouts,
  FMX.Controls.Presentation,
  FMX.ActnList,
  FMX.MultiView,
  FMX.ListBox,
  NX.Foundry.TestFramework,
  NX.Foundry.Config,
  NX.Foundry.Filters;

type
  TNxGuiTestEngine = class(TNxTestEngine)
  public
    procedure Start; override;
  end;

  TTestStatus = class(TControl)
  private
    fStatus: TNxTestOutcome;
    procedure SetStatus(const Value: TNxTestOutcome);
  protected
    procedure Paint; override;
  public
    property Status: TNxTestOutcome read fStatus write SetStatus;
  end;

  TTestTreeItem = class(TTreeViewItem)
  private
    fContainer: TLayout;
    fStatus: TTestStatus;
    fTestName: TLabel;
    function GetStatus: TNxTestOutcome;
    procedure SetStatus(const Value: TNxTestOutcome);
    function GetTestName: string;
    procedure SetTestName(const Value: string);
  protected
    function FindTextObject: TFmxObject; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Status: TNxTestOutcome read GetStatus write SetStatus;
    property TestName: string read GetTestName write SetTestName;
  end;

  TMainForm = class(TForm);

  TNxTestApp = class(TInterfacedObject, INxTestReporter)
  protected
    fConfig: TNxTestConfig;
    fForm: TMainForm;
    fActionList: TActionList;
    fToolBar: TLayout;
    fSelectionToolBar: TLayout;
    fTreeView: TTreeView;
    fStatusBar: TStatusBar;
    fRunBtn: TButton;
    fRunSelectedBtn: TButton;
    fCancelRunBtn: TButton;
    fFilterLabel: TLabel;
    fStatusLabel: TLabel;
    fScoreLabel: TLabel;
    fTotalLabel: TLabel;
    fOutcomeLabels: array[TNxTestOutcome] of TLabel;
    fScoreProgress: TProgressBar;
    fProgress: TProgressBar;
    fSideView: TMultiView;
    fSideViewContent: TVertScrollBox;
    fCategoriesLayout: TLayout;
    fCategoriesFilterMode: TComboBox;
    fTestNodes: TDictionary<string, TTestTreeItem>;
    fDisabledTests: TNxStringArray;
    fSelectedTests: TNxStringArray;
    fCategories: TNxStringArray;
    [volatile] fFormInitialized: Boolean;
    [volatile] fRunning: Boolean;
    procedure OnIdle(Sender: TObject; var Done: Boolean);
    procedure CreateUserInterface;
    procedure OnFormCloseQuery(Sender: TObject; var CanClose: Boolean);

    procedure BuildTreeRecursive(AParentNode: TControl; aSuite: INxTestSuite);
    procedure BuildCategories;
    procedure UpdateCategoriesLabel(Sender: TObject);

    procedure ExecuteCollapseAll(Sender: TObject);
    procedure ExecuteExpandAll(Sender: TObject);
    procedure ExecuteSelectNode(Sender: TObject);
    procedure ExecuteDeselectNode(Sender: TObject);
    procedure ExecuteSelectAll(Sender: TObject);
    procedure ExecuteDeselectAll(Sender: TObject);
    procedure ExecuteSelectOutcome(Sender: TObject);

    procedure RunAll(Sender: TObject);
    procedure RunSelected(Sender: TObject);
    procedure CancelRun(Sender: TObject);
    function TestChecked(const aTest: INxTest): Boolean;
    procedure UpdateTestSelection;
    function CategoryFilter: INxTestStringsFilter;
    procedure SetRunning(const Value: Boolean);
    property Running: Boolean read fRunning write SetRunning;
  public
    constructor Create;
    destructor Destroy; override;

    procedure OnRunStart(const aTest: INxTest; aTotalCount: Integer);
    procedure OnRunEnds(const aTest: INxTest; const aSummary: INxTestSummary);

    // start and end of a test suite
    procedure OnSuiteStart(const aTest: INxTest);
    procedure OnSuiteEnds(const aTest: INxTest; const aSummary: INxTestSummary);

    // start and end of an individual test
    procedure OnTestStart(const aTest: INxTest);
    procedure OnTestEnds(const aTest: INxTest; const aResult: INxTestResult);

    procedure OnStatus(const aTest: INxTest; const aStatusMsg: string);
  end;

const
  StatusColors: array[TNxTestOutcome] of TAlphaColor = (
    TAlphaColorRec.Whitesmoke,
    TAlphaColorRec.Green,
    TAlphaColorRec.Gold,
    TAlphaColorRec.Gray,
    TAlphaColorRec.Royalblue,
    TAlphaColorRec.Crimson,
    TAlphaColorRec.Crimson,
    TAlphaColorRec.Darkviolet,
    TAlphaColorRec.Black);

implementation

{$R *.fmx}

// ***** TNxGuiTestEngine *****

procedure TNxGuiTestEngine.Start;
begin
  Application.Run;
end;

// ***** TTestStatus *****

procedure TTestStatus.SetStatus(const Value: TNxTestOutcome);
begin
  if fStatus <> Value then
    begin
      fStatus := Value;
      Repaint;
    end;
end;

procedure TTestStatus.Paint;
var
  Path: TPathData;
  R: TRectF;
  DrawColor: TAlphaColor;
begin
  inherited;
  Path := TPathData.Create;
  try
    R := BoundsRect;
    DrawColor := StatusColors[fStatus];
    case fStatus of
      TestSkip, TestIncomplete :
        begin
          R.Inflate(0, -3);
          Path.AddEllipse(R);
          Canvas.Stroke.Kind := TBrushKind.Solid;
          Canvas.Stroke.Color := TAlphaColorRec.Gray;
          Canvas.Fill.Color := DrawColor;
          Canvas.FillPath(Path, 1);
          Canvas.DrawPath(Path, 1);
        end;

      TestPass :
        begin
          R.Inflate(0, -3);
          Path.AddEllipse(R);
          Canvas.Fill.Color := DrawColor;
          Canvas.FillPath(Path, 1.0);
          Canvas.Stroke.Color := TAlphaColorRec.Whitesmoke;
          Canvas.Stroke.Dash := TStrokeDash.Solid;
          canvas.Stroke.Kind := TBrushKind.Solid;
          Canvas.Stroke.Thickness := 1.5;
          Canvas.Stroke.Join := TStrokeJoin.Round;
          Canvas.Stroke.Cap := TStrokeCap.Round;
          Path.Clear;
          Path.MoveTo(TPointF.Create(R.Left + 5, R.Top + 10));
          Path.LineTo(TPointF.Create(R.Left + 9, R.Top + 13));
          Path.LineTo(TPointF.Create(R.Left + 13, R.Top + 6));
          Canvas.DrawPath(Path, 1);
        end;

      TestEmpty :
        begin
          R.Inflate(1, -4);
          R.Offset(0, -1);
          Path.MoveTo(PointF(R.Left + R.Width / 2, R.Top));
          Path.LineTo(PointF(R.Left, R.Bottom));
          Path.LineTo(PointF(R.Right, R.Bottom));
          Path.ClosePath;
          Canvas.Fill.Color := DrawColor;
          Canvas.FillPath(Path, 1);
          R.Offset(0, 1);
          Canvas.Fill.Color := TAlphaColorRec.Black;
          Canvas.FillText(R, '!', False, 1, [], TTextAlign.Center, TTextAlign.Center);
        end;

      TestIgnore, TestLeak, TestFail, TestTimeout :
        begin
          R.Inflate(0, -3);
          Path.AddEllipse(R);
          Canvas.Fill.Color := DrawColor;
          Canvas.FillPath(Path, 1);
          Canvas.Fill.Color := TAlphaColorRec.Whitesmoke;
          Canvas.FillText(R, '!', False, 1, [], TTextAlign.Center, TTextAlign.Center);
        end;

      TestError :
        begin
          R.Inflate(0, -3);
          Path.AddEllipse(R);
          Canvas.Fill.Color := DrawColor;
          Canvas.FillPath(Path, 1);
          R.Offset(0, -2);
          Canvas.Fill.Color := TAlphaColorRec.Whitesmoke;
          Canvas.FillText(R, 'x', False, 1, [], TTextAlign.Center, TTextAlign.Center);
        end;
    end;
  finally
    Path.Free;
  end;
end;

// ***** TTestTreeItem *****

constructor TTestTreeItem.Create(AOwner: TComponent);
begin
  inherited;
  fContainer := TLayout.Create(Self);
  fContainer.Parent := Self;
  fContainer.Align := TAlignLayout.Client;
  fContainer.Margins.Left := 46;
  fContainer.Margins.Right := 0;
  fContainer.HitTest := False;
  Height := 24;
  Text := '';

  fStatus := TTestStatus.Create(Self);
  fStatus.Parent := fContainer;
  fStatus.Align := TAlignLayout.MostLeft;
  fStatus.Margins.Top := 0;
  fStatus.Margins.Right := 8;
  fStatus.Margins.Left := 0;
  fStatus.Margins.Bottom := 0;
  fStatus.Width := 18;

  fTestName := TLabel.Create(Self);
  fTestName.Parent := fContainer;
  fTestName.Align := TAlignLayout.Client;
  fTestName.VertTextAlign := TTextAlign.Center;
  fTestName.Text := '';
  fTestName.Font.Size := 14;
  fTestName.AutoSize := True;
end;

function TTestTreeItem.FindTextObject: TFmxObject;
begin
  Result := inherited;
end;

function TTestTreeItem.GetStatus: TNxTestOutcome;
begin
  Result := fStatus.Status;
end;

procedure TTestTreeItem.SetStatus(const Value: TNxTestOutcome);
begin
  fStatus.Status := Value;
end;

function TTestTreeItem.GetTestName: string;
begin
  Result := fTestName.Text;
end;

procedure TTestTreeItem.SetTestName(const Value: string);
begin
  fTestName.Text := Value;
end;

// ***** TNxTestApp *****

constructor TNxTestApp.Create;
var
  lConfigFileName: string;
begin
  inherited;
  {$IFDEF MSWINDOWS}
  lConfigFileName := ChangeFileExt(ParamStr(0), '.config.xml');
  {$ELSE}
  lConfigFileName := System.IOUtils.TPath.Combine(System.IOUtils.TPath.GetDocumentsPath, Application.Title + '.config.xml');
  {$ENDIF}
  fConfig := TNxTestConfig.Create(lConfigFileName);
  fTestNodes := TDictionary<string, TTestTreeItem>.Create;
  Application.Initialize;
  Application.CreateForm(TMainForm, fForm);
  Application.OnIdle := OnIdle;
end;

destructor TNxTestApp.Destroy;
begin
  fConfig.Free;
  fTestNodes.Free;
  inherited;
end;

procedure TNxTestApp.OnIdle(Sender: TObject; var Done: Boolean);
begin
  if Assigned(fForm) and not fFormInitialized then
    CreateUserInterface;
end;

procedure TNxTestApp.CreateUserInterface;
var
  lAction: TAction;
  lLayout: TLayout;
  lFlow: TFlowLayout;
  lBtn: TButton;
  lSpeedBtn: TSpeedButton;
  lChk: TCheckBox;
  lOutcome: TNxTestOutcome;
  lStatus: TTestStatus;
  lLabel: TLabel;
  lPos: Single;
begin
  fFormInitialized := True;

  fConfig.LoadFromFile;
  fDisabledTests := fConfig.DisabledTests;

  fForm.OnCloseQuery := OnFormCloseQuery;

  fActionList := TActionList.Create(fForm);

  fToolBar := TLayout.Create(fForm);
  fToolBar.Align := TAlignLayout.MostTop;
  fToolBar.Height := 48;
  fToolBar.Parent := fForm;
  fToolBar.Padding.Left := 8;
  fToolBar.Padding.Right := 8;
  fToolBar.Padding.Top := 6;
  fToolBar.Padding.Bottom := 6;

  fSelectionToolBar := TLayout.Create(fForm);
  fSelectionToolBar.Height := 42;

  fSideView := TMultiView.Create(fForm);
  fSideView.Width := 220;
  fSideView.Parent := fForm;

  if fForm.Width < 1000 then
    begin
      fSelectionToolBar.Align := TAlignLayout.Top;
      fSelectionToolBar.Parent := fForm;
      fSelectionToolBar.Padding.Bottom := 6;
      fSideView.Mode := TMultiViewMode.Drawer;
    end
  else
    begin
      fSelectionToolBar.Align := TAlignLayout.Client;
      fSelectionToolBar.Margins.Left := 6;
      fSelectionToolBar.Parent := fToolBar;
      fSideView.Mode := TMultiViewMode.Panel;
    end;

  lSpeedBtn := TSpeedButton.Create(fForm);
  lSpeedBtn.Parent := fToolBar;
  lSpeedBtn.StyleLookup := 'detailstoolbuttonbordered';
  lSpeedBtn.Align := TAlignLayout.MostLeft;
  lSpeedBtn.Width := 32;
  fSideView.MasterButton := lSpeedBtn;

  fSideViewContent := TVertScrollBox.Create(fForm);
  fSideViewContent.Parent := fSideView;
  fSideViewContent.Align := TAlignLayout.Client;

  lAction := TAction.Create(fActionList);
  lAction.Text := 'Collapse All';
  lAction.OnExecute := ExecuteCollapseAll;

  lBtn := TButton.Create(fForm);
  lBtn.Height := 32;
  lBtn.Position.Y := 800;
  lBtn.Action := lAction;
  lBtn.Margins.Left := 8;
  lBtn.Margins.Right := 8;
  lBtn.Margins.Top := 4;
  lBtn.Margins.Bottom := 4;
  lBtn.Parent := fSideViewContent;
  lBtn.Align := TAlignLayout.Top;

  lAction := TAction.Create(fActionList);
  lAction.Text := 'Expand All';
  lAction.OnExecute := ExecuteExpandAll;

  lBtn := TButton.Create(fForm);
  lBtn.Height := 32;
  lBtn.Position.Y := 800;
  lBtn.Action := lAction;
  lBtn.Margins.Left := 8;
  lBtn.Margins.Right := 8;
  lBtn.Margins.Top := 4;
  lBtn.Margins.Bottom := 4;
  lBtn.Parent := fSideViewContent;
  lBtn.Align := TAlignLayout.Top;

  lAction := TAction.Create(fActionList);
  lAction.Text := 'Select Node';
  lAction.OnExecute := ExecuteSelectNode;

  lBtn := TButton.Create(fForm);
  lBtn.Height := 32;
  lBtn.Position.Y := 800;
  lBtn.Action := lAction;
  lBtn.Margins.Left := 8;
  lBtn.Margins.Right := 8;
  lBtn.Margins.Top := 4;
  lBtn.Margins.Bottom := 4;
  lBtn.Parent := fSideViewContent;
  lBtn.Align := TAlignLayout.Top;

  lAction := TAction.Create(fActionList);
  lAction.Text := 'Deselect Node';
  lAction.OnExecute := ExecuteDeselectNode;

  lBtn := TButton.Create(fForm);
  lBtn.Height := 32;
  lBtn.Position.Y := 800;
  lBtn.Action := lAction;
  lBtn.Margins.Left := 8;
  lBtn.Margins.Right := 8;
  lBtn.Margins.Top := 4;
  lBtn.Margins.Bottom := 4;
  lBtn.Parent := fSideViewContent;
  lBtn.Align := TAlignLayout.Top;

  fRunBtn := TButton.Create(fForm);
  fRunBtn.Margins.Left := 8;
  fRunBtn.Align := TAlignLayout.Left;
  fRunBtn.Text := 'Run All';
  fRunBtn.Parent := fToolBar;
  fRunBtn.Width := 120;
  fRunBtn.OnClick := RunAll;

  fRunSelectedBtn := TButton.Create(fForm);
  fRunSelectedBtn.Margins.Left := 8;
  fRunSelectedBtn.Position.X := 1000;
  fRunSelectedBtn.Align := TAlignLayout.Left;
  fRunSelectedBtn.Text := 'Run Selected';
  fRunSelectedBtn.Parent := fToolBar;
  fRunSelectedBtn.Width := 120;
  fRunSelectedBtn.OnClick := RunSelected;

  fCancelRunBtn := TButton.Create(fForm);
  fCancelRunBtn.Margins.Left := 8;
  fCancelRunBtn.Position.X := 1000;
  fCancelRunBtn.Align := TAlignLayout.Left;
  fCancelRunBtn.Text := 'Cancel';
  fCancelRunBtn.Parent := fToolBar;
  fCancelRunBtn.Width := 100;
  fCancelRunBtn.OnClick := CancelRun;
  fCancelRunBtn.Enabled := False;

  lAction := TAction.Create(fActionList);
  lAction.Hint := 'Select All';
  lAction.OnExecute := ExecuteSelectAll;

  lSpeedBtn := TSpeedButton.Create(fForm);
  lSpeedBtn.Action := lAction;
  lSpeedBtn.Width := 36;
  lSpeedBtn.Position.X := 1000;
  lSpeedBtn.Align := TAlignLayout.Left;
  lSpeedBtn.Parent := fSelectionToolBar;

  lChk := TCheckBox.Create(lSpeedBtn);
  lChk.IsChecked := True;
  lChk.HitTest := False;
  lChk.Parent := lSpeedBtn;
  lChk.Position.X := 8;
  lChk.Position.Y := 8;

  lAction := TAction.Create(fActionList);
  lAction.Hint := 'Deselect All';
  lAction.OnExecute := ExecuteDeselectAll;

  lSpeedBtn := TSpeedButton.Create(fForm);
  lSpeedBtn.Action := lAction;
  lSpeedBtn.Width := 36;
  lSpeedBtn.Margins.Left := 6;
  lSpeedBtn.Position.X := 1000;
  lSpeedBtn.Align := TAlignLayout.Left;
  lSpeedBtn.Parent := fSelectionToolBar;

  lChk := TCheckBox.Create(lSpeedBtn);
  lChk.IsChecked := false;
  lChk.HitTest := False;
  lChk.Parent := lSpeedBtn;
  lChk.Position.X := 8;
  lChk.Position.Y := 8;

  for lOutcome := Low(TNxTestOutcome) to Pred(High(TNxTestOutcome)) do
    begin
      lAction := TAction.Create(fActionList);
      lAction.Hint := 'Select ' + NxTestOutcomeDescription[lOutcome];
      lAction.OnExecute := ExecuteSelectOutcome;
      lAction.Tag := Ord(lOutcome);

      lSpeedBtn := TSpeedButton.Create(fForm);
      lSpeedBtn.Margins.Left := 6;
      lSpeedBtn.Height := 36;
      lSpeedBtn.Width := 36;
      lSpeedBtn.Action := lAction;
      lSpeedBtn.Position.X := 800;
      lSpeedBtn.Parent := fSelectionToolBar;
      lSpeedBtn.Align := TAlignLayout.Left;

      lStatus := TTestStatus.Create(lSpeedBtn);
      lStatus.HitTest := False;
      lStatus.Width := 18;
      lStatus.Height := 24;
      lStatus.Status := lOutcome;
      lStatus.Parent := lSpeedBtn;
      lStatus.Position.X := 4;
      lStatus.Position.Y := 3;
    end;

  fFilterLabel := TLabel.Create(fForm);
  fFilterLabel.Text := '';
  fFilterLabel.Height := 24;
  fFilterLabel.Margins.Left := 6;
  fFilterLabel.Margins.Right := 6;
  fFilterLabel.Align := TAlignLayout.Top;
  fFilterLabel.Parent := fForm;

  fTreeView := TTreeView.Create(fForm);
  fTreeView.Align := TAlignLayout.Client;
  fTreeView.Parent := fForm;
  fTreeView.ShowCheckboxes := True;
  fTreeView.ShowScrollBars := True;

  lFlow := TFlowLayout.Create(fForm);
  lFlow.Height := 48;
  lFlow.Margins.Top := 6;
  lFlow.Margins.Left := 6;
  lFlow.Margins.Right := 6;
  lFlow.Align := TAlignLayout.Bottom;
  lFlow.Parent := fForm;

  lLayout := TLayout.Create(fForm);
  lLayout.Width := 52;
  lLayout.Height := 48;
  lLayout.Parent := lFlow;

  lLabel := TLabel.Create(fForm);
  lLabel.AutoSize := False;
  lLabel.Height := 24;
  lLabel.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style, TStyledSetting.FontColor];
  lLabel.TextSettings.Font.Size := 12;
  lLabel.Text := 'Tests';
  lLabel.Trimming := TTextTrimming.None;
  lLabel.VertTextAlign := TTextAlign.Center;
  lLabel.Align := TAlignLayout.Top;
  lLabel.Parent := lLayout;

  fTotalLabel := TLabel.Create(fForm);
  fTotalLabel.Text := '0';
  fTotalLabel.TextAlign := TTextAlign.Center;
  fTotalLabel.VertTextAlign := TTextAlign.Center;
  fTotalLabel.Align := TAlignLayout.Top;
  fTotalLabel.Parent := lLayout;

  lPos := lLayout.Width;

  for lOutcome := Low(TNxTestOutcome) to Pred(High(TNxTestOutcome)) do
    begin
      lPos := lPos + 68;
      if lPos > fForm.Width then
        begin
          var lBreak := TFlowLayoutBreak.Create(fForm);
          lBreak.Parent := lFlow;
          lFlow.Height := lFlow.Height + 48;
          lPos := 68;
        end;
      lLayout := TLayout.Create(fForm);
      lLayout.Width := 68;
      lLayout.Height := 48;
      lLayout.Parent := lFlow;

      lLabel := TLabel.Create(fForm);
      lLabel.AutoSize := False;
      lLabel.Height := 24;
      lLabel.StyledSettings := [TStyledSetting.Family, TStyledSetting.Style, TStyledSetting.FontColor];
      lLabel.TextSettings.Font.Size := 12;
      lLabel.Text := NxTestOutcomeDescription[lOutcome];
      lLabel.VertTextAlign := TTextAlign.Center;
      lLabel.Trimming := TTextTrimming.None;
      lLabel.Margins.Left := 22;
      lLabel.Align := TAlignLayout.Top;
      lLabel.Parent := lLayout;

      lStatus := TTestStatus.Create(fForm);
      lStatus.Width := 18;
      lStatus.Height := 24;
      lStatus.Status := lOutcome;
      lStatus.Parent := lLayout;

      lLabel := TLabel.Create(fForm);
      lLabel.Text := '0';
      lLabel.TextAlign := TTextAlign.Center;
      lLabel.VertTextAlign := TTextAlign.Center;
      lLabel.Align := TAlignLayout.Top;
      lLabel.Parent := lLayout;
      fOutcomeLabels[lOutcome] := lLabel;
    end;

  lLayout := TLayout.Create(fForm);
  lLayout.Height := 20;
  lLayout.Align := TAlignLayout.Bottom;
  lLayout.Parent := fForm;

  fScoreLabel := TLabel.Create(fForm);
  fScoreLabel.AutoSize := False;
  fScoreLabel.Align := TAlignLayout.Left;
  fScoreLabel.Margins.Left := 6;
  fScoreLabel.Margins.Right := 6;
  fScoreLabel.Width := 100;
  fScoreLabel.Parent := lLayout;

  fScoreProgress := TProgressBar.Create(fForm);
  fScoreProgress.Align := TAlignLayout.Client;
  fScoreProgress.Parent := lLayout;

  fProgress := TProgressBar.Create(fForm);
  fProgress.Align := TAlignLayout.Bottom;
  fProgress.Parent := fForm;
  fProgress.Height := 8;
  fProgress.Margins.Bottom := 8;

  fStatusBar := TStatusBar.Create(fForm);
  fStatusBar.Align := TAlignLayout.MostBottom;
  fStatusBar.Height := 25;
  fStatusBar.Parent := fForm;
  fStatusBar.Padding.Left := 6;
  fStatusBar.Padding.Right := 6;

  fStatusLabel := TLabel.Create(fForm);
  fStatusLabel.Text := 'Ready';
  fStatusLabel.Align := TAlignLayout.Client;
  fStatusLabel.Parent := fStatusBar;

  NxTestRegistry.Discover;
  TThread.ForceQueue(nil,
    procedure
    begin
      BuildTreeRecursive(fTreeView, NxTestRegistry.Suite);
      fTreeView.ExpandAll;
      BuildCategories;
    end);
end;

procedure TNxTestApp.BuildTreeRecursive(aParentNode: TControl; aSuite: INxTestSuite);
var
  lSuiteNode, lNode: TTestTreeItem;
  lSuite: INxTestSuite;
  lTest: INxTest;
  i: Integer;
begin
  lSuiteNode := TTestTreeItem.Create(fTreeView);
  lSuiteNode.TestName := aSuite.TestName;
  lSuiteNode.IsChecked := TestChecked(aSuite);
  lSuiteNode.Parent := aParentNode;
  lSuiteNode.TagString := aSuite.FullTestName;
  fTestNodes.TryAdd(aSuite.FullTestName, lSuiteNode);

  for i := 0 to aSuite.ItemCount - 1 do
  begin
    lTest := aSuite.Test(i);
    if Supports(lTest, INxTestSuite, lSuite) then
      begin
        BuildTreeRecursive(lSuiteNode, lSuite);
      end
    else
      begin
        lNode := TTestTreeItem.Create(fTreeView);
        lNode.TestName := lTest.TestName;
        lNode.IsChecked := TestChecked(lTest);
        lNode.Parent := lSuiteNode;
        lNode.TagString := lTest.FullTestName;
        fTestNodes.TryAdd(lTest.FullTestName, lNode);
        AddUniqueStrings(fCategories, lTest.Categories);
      end;
  end;
end;

procedure TNxTestApp.BuildCategories;
var
  lLabel: TLabel;
  lChk: TCheckBox;
  i: Integer;
begin
  lLabel := TLabel.Create(fForm);
  lLabel.Margins.Left := 8;
  lLabel.Margins.Top := 8;
  lLabel.Text := 'Categories Filter';
  lLabel.Align := TAlignLayout.Top;
  lLabel.Position.Y := 800;
  lLabel.Parent := fSideViewContent;

  fCategoriesFilterMode := TComboBox.Create(fForm);
  fCategoriesFilterMode.Margins.Left := 8;
  fCategoriesFilterMode.Margins.right := 8;
  fCategoriesFilterMode.Margins.Top := 8;
  fCategoriesFilterMode.Align := TAlignLayout.Top;
  fCategoriesFilterMode.Position.Y := 800;
  fCategoriesFilterMode.Parent := fSideViewContent;
  fCategoriesFilterMode.Items.Add('No category filtering');
  fCategoriesFilterMode.Items.Add('Test in any category');
  fCategoriesFilterMode.Items.Add('Test in all categories');
  fCategoriesFilterMode.Items.Add('Test in no categories');
  fCategoriesFilterMode.ItemIndex := 0;
  fCategoriesFilterMode.OnChange := UpdateCategoriesLabel;

  if Length(fCategories) = 0 then
    begin
      lLabel := TLabel.Create(fForm);
      lLabel.Margins.Left := 8;
      lLabel.Margins.Top := 8;
      lLabel.Text := '<no categories>';
      lLabel.Align := TAlignLayout.Top;
      lLabel.Position.Y := 800;
      lLabel.Parent := fSideViewContent;
    end
  else
    begin
      fCategoriesLayout := TLayout.Create(fForm);
      fCategoriesLayout.Position.Y := 800;
      fCategoriesLayout.Margins.Left := 8;
      fCategoriesLayout.Margins.Right := 8;
      fCategoriesLayout.Margins.Top := 8;
      fCategoriesLayout.Parent := fSideViewContent;
      fCategoriesLayout.Align := TAlignLayout.Top;

      for i := 0 to High(fCategories) do
        begin
          lChk := TCheckBox.Create(fForm);
          lChk.Position.Y := 800;
          lChk.Text := fCategories[i];
          lChk.TagString := fCategories[i];
          lChk.Margins.Bottom := 8;
          lChk.Parent := fCategoriesLayout;
          lChk.Align := TAlignLayout.Top;
          lChk.OnChange := UpdateCategoriesLabel;
        end;
      fCategoriesLayout.Height := lChk.Position.Y + lChk.Height + 8;
    end;
end;

procedure TNxTestApp.OnFormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not Running;
  if CanClose then
    UpdateTestSelection
  else
    TDialogService.MessageDialog('Test suite is running? Do you want to force close?',
      TMsgDlgType.mtWarning, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0,
      procedure(const AResult: TModalResult)
      begin
        if AResult = mrYes then
          Application.Terminate;
      end);
end;

function TNxTestApp.TestChecked(const aTest: INxTest): Boolean;
begin
  Result := not ContainsString(fDisabledTests, aTest.FullTestName);
end;

procedure TNxTestApp.UpdateCategoriesLabel(Sender: TObject);
var
  lText: string;
  i: Integer;
begin
  if fCategoriesFilterMode.ItemIndex = 0 then
    lText := 'No categories filtering'
  else
    begin
      case fCategoriesFilterMode.ItemIndex of
        1 : lText := lText + 'Any categories: ';
        2 : lText := lText + 'All categories: ';
        3 : lText := lText + 'No categories: ';
      end;
      for i := 0 to fCategoriesLayout.Children.Count - 1 do
        if TCheckBox(fCategoriesLayout.Children[i]).IsChecked then
          lText := lText + fCategoriesLayout.Children[i].TagString + ', ';
    end;
  fFilterLabel.Text := lText;
end;

procedure TNxTestApp.UpdateTestSelection;

procedure SelectRecursive(aNode: TTreeViewItem);
var
  i: Integer;
begin
  AddUniqueString(fSelectedTests, aNode.TagString);
  for i := 0 to aNode.Count - 1 do
    if aNode.Items[i].IsChecked then
      SelectRecursive(aNode.Items[i]);
end;

var
  i: Integer;
  lNode: TTreeViewItem;
begin
  SetLength(fSelectedTests, 0);
  SetLength(fDisabledTests, 0);
  for i := 0 to fTreeView.GlobalCount - 1 do
    begin
      lNode := fTreeView.ItemByGlobalIndex(i);
      TTestTreeItem(lNode).Status := TestSkip;
      if not lNode.IsChecked then
        AddUniqueString(fDisabledTests, lNode.TagString);
    end;
  if Length(fDisabledTests) > 0 then
    begin
      for i := 0 to fTreeView.Count - 1 do
        if fTreeView.Items[i].IsChecked then
          SelectRecursive(fTreeView.Items[i]);
    end;

  fConfig.DisabledTests := fDisabledTests;
  fConfig.SaveToFile;
end;

function TNxTestApp.CategoryFilter: INxTestStringsFilter;
var
  i: Integer;
begin
  case fCategoriesFilterMode.ItemIndex of
    1 : // any category
      begin
        Result := TNxTestAnyCategoryFilter.Create;
        for i := 0 to fCategoriesLayout.Children.Count - 1 do
          if TCheckBox(fCategoriesLayout.Children[i]).IsChecked then
            Result.AddString(fCategoriesLayout.Children[i].TagString);
      end;
    2 : // all categories
      begin
        Result := TNxTestAllCategoriesFilter.Create;
        for i := 0 to fCategoriesLayout.Children.Count - 1 do
          if TCheckBox(fCategoriesLayout.Children[i]).IsChecked then
            Result.AddString(fCategoriesLayout.Children[i].TagString);
      end;
    3 : // no category
      begin
        Result := TNxTestNoCategoriesFilter.Create;
        for i := 0 to fCategoriesLayout.Children.Count - 1 do
          if TCheckBox(fCategoriesLayout.Children[i]).IsChecked then
            Result.AddString(fCategoriesLayout.Children[i].TagString);
      end;
    else // category filtering disabled
      Result := nil;
  end;
end;

procedure TNxTestApp.ExecuteCollapseAll(Sender: TObject);
begin
  fTreeView.CollapseAll;
  fSideView.HideMaster;
end;

procedure TNxTestApp.ExecuteExpandAll(Sender: TObject);
begin
  fTreeView.ExpandAll;
  fSideView.HideMaster;
end;

procedure TNxTestApp.ExecuteSelectNode(Sender: TObject);
var
  i: Integer;
  lCurrent: TTreeViewItem;
  lNode: TTreeViewItem;
begin
  lCurrent := fTreeView.Selected;
  if Assigned(lCurrent) then
    begin
      lCurrent.IsChecked := True;
      for i := 0 to lCurrent.Count - 1 do
        begin
          lNode := lCurrent.ItemByIndex(i);
          lNode.IsChecked := True;
        end;
    end;
  fSideView.HideMaster;
end;

procedure TNxTestApp.ExecuteDeselectNode(Sender: TObject);
var
  i: Integer;
  lCurrent: TTreeViewItem;
  lNode: TTreeViewItem;
begin
  lCurrent := fTreeView.Selected;
  if Assigned(lCurrent) then
    begin
      lCurrent.IsChecked := False;
      for i := 0 to lCurrent.Count - 1 do
        begin
          lNode := lCurrent.ItemByIndex(i);
          lNode.IsChecked := False;
        end;
    end;
  fSideView.HideMaster;
end;

procedure TNxTestApp.ExecuteSelectAll(Sender: TObject);
var
  i: Integer;
  lNode: TTreeViewItem;
begin
  for i := 0 to fTreeView.GlobalCount - 1 do
    begin
      lNode := fTreeView.ItemByGlobalIndex(i);
      lNode.IsChecked := True;
    end;
  fSideView.HideMaster;
end;

procedure TNxTestApp.ExecuteDeselectAll(Sender: TObject);
var
  i: Integer;
  lNode: TTreeViewItem;
begin
  for i := 1 to fTreeView.GlobalCount - 1 do
    begin
      lNode := fTreeView.ItemByGlobalIndex(i);
      lNode.IsChecked := False;
    end;
  fSideView.HideMaster;
end;

procedure TNxTestApp.ExecuteSelectOutcome(Sender: TObject);
var
  i: Integer;
  lNode: TTreeViewItem;
  Outcome: TNxTestOutcome;
begin
  Outcome := TNxTestOutcome(TComponent(Sender).Tag);
  for i := 0 to fTreeView.GlobalCount - 1 do
    begin
      lNode := fTreeView.ItemByGlobalIndex(i);
      if lNode.Count > 0 then
        lNode.IsChecked := True
      else
        lNode.IsChecked := TTestTreeItem(lNode).Status = Outcome;
    end;
  fSideView.HideMaster;
end;

procedure TNxTestApp.RunAll(Sender: TObject);
var
  i: Integer;
  lNode: TTreeViewItem;
begin
  Running := True;
  for i := 0 to fTreeView.GlobalCount - 1 do
    begin
      lNode := fTreeView.ItemByGlobalIndex(i);
      TTestTreeItem(lNode).Status := TestSkip;
    end;
  TTask.Run(
    procedure
    begin
      // always use category filter, it will be nil if category filtering is not enabled
      Engine.Runner.RunTests(CategoryFilter);
    end);
end;

procedure TNxTestApp.RunSelected(Sender: TObject);
var
  lFilters: INxTestMultiFilter;
  lNameFilter: INxTestStringsFilter;
begin
  Running := True;
  UpdateTestSelection;
  lFilters := TNxTestAllFilters.Create;
  lNameFilter := TNxTestNameFilter.Create;
  lNameFilter.AddStrings(fSelectedTests);
  lFilters.AddFilter(lNameFilter);
  // always use category filter, it will be nil if category filtering is not enabled
  lFilters.AddFilter(CategoryFilter);
  TTask.Run(
    procedure
    begin
      Engine.Runner.RunTests(lFilters);
    end);
end;

procedure TNxTestApp.SetRunning(const Value: Boolean);
begin
  fRunning := Value;
  fSideView.Enabled := not Value;
  fSelectionToolBar.Enabled := not Value;
  fRunBtn.Enabled := not Value;
  fRunSelectedBtn.Enabled := not Value;
  fCancelRunBtn.Enabled := Value;
end;

procedure TNxTestApp.CancelRun(Sender: TObject);
begin
  Running := False;
  Engine.Runner.Cancel;
end;

procedure TNxTestApp.OnRunStart(const aTest: INxTest; aTotalCount: Integer);
var
  lOutcome: TNxTestOutcome;
begin
  fStatusLabel.Text := 'Running...';
  fProgress.Value := 0;
  fProgress.Max := aTotalCount;
  fScoreProgress.Value := 0;
  fScoreLabel.Text := 'Score: 0%';
  fScoreProgress.Max := aTotalCount;
  fTotalLabel.Text := '0';
  for lOutcome := Low(TNxTestOutcome) to Pred(High(TNxTestOutcome)) do
    fOutcomeLabels[lOutcome].Text := '0';
end;

procedure TNxTestApp.OnRunEnds(const aTest: INxTest; const aSummary: INxTestSummary);
begin
  fStatusLabel.Text := Format('Completed: %s Duration: %s', [NxTestOutcomeText[aSummary.Outcome], FormatDuration(aSummary.Duration)]);
  Running := False;
end;

procedure TNxTestApp.OnSuiteStart(const aTest: INxTest);
begin

end;

procedure TNxTestApp.OnSuiteEnds(const aTest: INxTest; const aSummary: INxTestSummary);
var
  lNode: TTestTreeItem;
begin
  if fTestNodes.TryGetValue(aTest.FullTestName, lNode) then
    lNode.Status := aSummary.Outcome;
end;

procedure TNxTestApp.OnTestStart(const aTest: INxTest);
begin

end;

procedure TNxTestApp.OnTestEnds(const aTest: INxTest; const aResult: INxTestResult);
var
  lNode: TTestTreeItem;
begin
  if fTestNodes.TryGetValue(aTest.FullTestName, lNode) then
    lNode.Status := aResult.Outcome;
  fProgress.Value := fProgress.Value + 1;
  if aResult.Outcome = TestPass then
    fScoreProgress.Value := fScoreProgress.Value + 1
  else
  if aResult.Outcome = TestSkip then
    fScoreProgress.Max := fScoreProgress.Max - 1;
  fScoreLabel.Text := Format('Score: %d%%', [Round(fScoreProgress.Value / fScoreProgress.Max * 100)]);
  fTotalLabel.Text := Trunc(fProgress.Value).ToString;
  if Assigned(fOutcomeLabels[aResult.Outcome]) then
    fOutcomeLabels[aResult.Outcome].Text := (StrToInt(fOutcomeLabels[aResult.Outcome].Text) + 1).ToString;
end;

procedure TNxTestApp.OnStatus(const aTest: INxTest; const aStatusMsg: string);
begin

end;

end.
