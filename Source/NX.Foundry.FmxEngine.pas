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
  NX.Foundry.TestFramework,
  NX.Foundry.Config;

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
    fToolBar: TLayout;
    fTreeView: TTreeView;
    fStatusBar: TStatusBar;
    fRunBtn: TButton;
    fRunSelectedBtn: TButton;
    fCancelRunBtn: TButton;
    fStatusLabel: TLabel;
    fScoreLabel: TLabel;
    fScoreProgress: TProgressBar;
    fProgress: TProgressBar;
    fTestNodes: TDictionary<string, TTestTreeItem>;
    fDisabledTests: TNxStringArray;
    fSelectedTests: TNxStringArray;
    [volatile] fFormInitialized: Boolean;
    [volatile] fRunning: Boolean;
    procedure OnIdle(Sender: TObject; var Done: Boolean);
    procedure CreateUserInterface;
    procedure OnFormCloseQuery(Sender: TObject; var CanClose: Boolean);

    procedure BuildTreeRecursive(AParentNode: TControl; aSuite: INxTestSuite);
    procedure RunAll(Sender: TObject);
    procedure RunSelected(Sender: TObject);
    procedure CancelRun(Sender: TObject);
    function TestChecked(const aTest: INxTest): Boolean;
    function TestSelected(const aTest: INxTest): Boolean;
    procedure UpdateTestSelection;
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
          Canvas.Fill.Color := DrawColor;
          Canvas.FillPath(Path, 1);
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
          Path.MoveTo(TPointF.Create(5, 12));
          Path.LineTo(TPointF.Create(9, 15));
          Path.LineTo(TPointF.Create(13, 8));
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
  lLayout: TLayout;
begin
  fFormInitialized := True;

  fConfig.LoadFromFile;
  fDisabledTests := fConfig.DisabledTests;

  fForm.OnCloseQuery := OnFormCloseQuery;

  fToolBar := TLayout.Create(fForm);
  fToolBar.Align := TAlignLayout.Top;
  fToolBar.Height := 48;
  fToolBar.Parent := fForm;
  fToolBar.Padding.Left := 8;
  fToolBar.Padding.Right := 8;
  fToolBar.Padding.Top := 6;
  fToolBar.Padding.Bottom := 6;

  fRunBtn := TButton.Create(fForm);
  fRunBtn.Align := TAlignLayout.Left;
  fRunBtn.Text := 'Run All';
  fRunBtn.Parent := fToolBar;
  fRunBtn.Width := 120;
  fRunBtn.OnClick := RunAll;

  fRunSelectedBtn := TButton.Create(fForm);
  fRunSelectedBtn.Margins.Left := 8;
  fRunSelectedBtn.Position.X := 600;
  fRunSelectedBtn.Align := TAlignLayout.Left;
  fRunSelectedBtn.Text := 'Run Selected';
  fRunSelectedBtn.Parent := fToolBar;
  fRunSelectedBtn.Width := 120;
  fRunSelectedBtn.OnClick := RunSelected;

  fCancelRunBtn := TButton.Create(fForm);
  fCancelRunBtn.Margins.Left := 8;
  fCancelRunBtn.Position.X := 600;
  fCancelRunBtn.Align := TAlignLayout.Left;
  fCancelRunBtn.Text := 'Cancel';
  fCancelRunBtn.Parent := fToolBar;
  fCancelRunBtn.Width := 120;
  fCancelRunBtn.OnClick := CancelRun;
  fCancelRunBtn.Enabled := False;

  fTreeView := TTreeView.Create(fForm);
  fTreeView.Align := TAlignLayout.Client;
  fTreeView.Parent := fForm;
  fTreeView.ShowCheckboxes := True;
  fTreeView.ShowScrollBars := True;

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
      end;
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

function TNxTestApp.TestSelected(const aTest: INxTest): Boolean;
begin
  // if selected tests array is empty, treat all tests as selected
  Result := Length(fSelectedTests) = 0;
  if not Result then
    Result := ContainsString(fSelectedTests, aTest.FullTestName);
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
      Engine.Runner.RunTests(nil);
    end);
end;

procedure TNxTestApp.RunSelected(Sender: TObject);
begin
  Running := True;
  UpdateTestSelection;
  TTask.Run(
    procedure
    begin
      Engine.Runner.RunTests(TestSelected);
    end);
end;

procedure TNxTestApp.SetRunning(const Value: Boolean);
begin
  fRunning := Value;
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
begin
  fStatusLabel.Text := 'Running...';
  fProgress.Value := 0;
  fProgress.Max := aTotalCount;
  fScoreProgress.Value := 0;
  fScoreLabel.Text := 'Score: 0%';
  fScoreProgress.Max := aTotalCount;
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
end;

procedure TNxTestApp.OnStatus(const aTest: INxTest; const aStatusMsg: string);
begin

end;

end.
