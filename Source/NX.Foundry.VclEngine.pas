(*******************************************************************************

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

********************************************************************************)

unit NX.Foundry.VclEngine;

{$I 'NX.inc'}

interface

uses
  {$IFDEF NAMESPACES}
  System.Types,
  System.UITypes,
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  Winapi.Windows,
  Winapi.CommCtrl,
  Vcl.ImgList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  {$ELSE}
  Types,
  SysUtils,
  Classes,
  Windows,
  CommCtrl,
  ImgList,
  Graphics,
  Controls,
  Forms,
  Dialogs,
  StdCtrls,
  ExtCtrls,
  ComCtrls,
  XmlDoc,
  XmlIntf,
  XPMan,
  {$ENDIF}
  NX.Foundry.TestFramework,
  NX.Foundry.Config;

type
  TNxGuiTestEngine = class(TNxTestEngine)
  public
    procedure Start; override;
  end;

  TNxTreeView = class(TTreeView)
  {$IFNDEF DELPHI_ALEXANDRIA_UP}
  protected
    fCheckBoxes: Boolean;
    procedure CreateWnd; override;
  public
    // dummy property for compatibility reasons - this patch forces checkboxes
    property CheckBoxes: Boolean read fCheckBoxes write fCheckBoxes;
  {$ENDIF}
  end;

  TNxTreeNode = class(TTreeNode)
  public
    TagString: string;
  end;

  TNxTreeNodeClass = class of TNxTreeNode;

  TNxTestTreeNodes = class
  private
    {$IFDEF GENERICS}
    fItems: TDictionary<string, TNxTreeNode>;
    {$ELSE}
    fItems: TStringList;
    {$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddOrSetValue(const aKey: string; aValue: TNxTreeNode);
    function TryGetValue(const aKey: string; var aValue: TNxTreeNode): Boolean;
  end;

  TMainForm = class(TForm);

  TNxTestApp = class(TInterfacedObject, INxTestReporter)
  protected
    fConfig: TNxTestConfig;
    fForm: TMainForm;
    fImages: TImageList;
    fToolBar: TPanel;
    fTreeView: TNxTreeView;
    fStatusBar: TStatusBar;
    fRunBtn: TButton;
    fRunSelectedBtn: TButton;
    fCancelRunBtn: TButton;
    fScoreLabel: TLabel;
    fScoreProgress: TProgressBar;
    fProgress: TProgressBar;
    fTestNodes: TNxTestTreeNodes;
    fDisabledTests: TNxStringArray;
    fSelectedTests: TNxStringArray;
    fFormInitialized: Boolean;
    fRunning: Boolean;
    fDpi: Integer;
    procedure OnFormCloseQuery(Sender: TObject; var CanClose: Boolean);
    function ScaledPix(aValue: Integer): Integer;
    procedure CreateUserInterface;
    function StatusBitmap(aStatus: TNxTestOutcome): TBitmap;
    procedure OnCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
    procedure BuildTreeRecursive(AParentNode: TNxTreeNode; aSuite: INxTestSuite);
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
  StatusColors: array[TNxTestOutcome] of TColor = (
    $F5F5F5, // TAlphaColorRec.Whitesmoke
    $008000, // TAlphaColorRec.Green
    $00D7FF, // TAlphaColorRec.Gold
    $808080, // TAlphaColorRec.Gray
    $E16941, // TAlphaColorRec.RoyalBlue
    $3C14DC, // TAlphaColorRec.Crimson
    $3C14DC, // TAlphaColorRec.Crimson
    $D30094, // TAlphaColorRec.Darkviolet
    $000000); //TAlphaColorRec.Black

  TextBlack = $000000;
  TextInverse = $F5F5F5;

implementation

{$R *.dfm}

// ***** TNxGuiTestEngine *****

procedure TNxGuiTestEngine.Start;
begin
  Application.Run;
end;

// ***** TNxTreeView *****

{$IFDEF DELPHI_ALEXANDRIA_UP}
function TreeViewNodeIsChecked(aNode: TTreeNode): Boolean;
begin
  Result := aNode.Checked;
end;

procedure TTreeViewNodeSetChecked(aNode: TTreeNode; aChecked: Boolean);
begin
  aNode.Checked := aChecked;
end;

{$ELSE}
const
  TVS_UNCHECKED = 1;
  TVS_CHECKED = 2;

function TreeViewNodeIsChecked(aNode: TTreeNode): Boolean;
var
  Item: TTVItem;
begin
  Result := True;
  FillChar(Item, SizeOf(Item), 0);
  Item.mask := TVIF_HANDLE or TVIF_STATE;
  Item.hItem := aNode.ItemId;
  Item.stateMask := TVIS_STATEIMAGEMASK;
  if TreeView_GetItem(aNode.Handle, Item) then
    Result := ((Item.state and TVIS_STATEIMAGEMASK) shr 12) = TVS_CHECKED;
end;

procedure TTreeViewNodeSetChecked(aNode: TTreeNode; aChecked: Boolean);
var
  Item: TTVItem;
begin
  FillChar(Item, SizeOf(Item), 0);
  Item.mask := TVIF_HANDLE or TVIF_STATE;
  Item.hItem := aNode.ItemId;
  Item.stateMask := TVIS_STATEIMAGEMASK;
  if aChecked then
    Item.state := IndexToStateImageMask(TVS_CHECKED)
  else
    Item.state := IndexToStateImageMask(TVS_UNCHECKED);
  TreeView_SetItem(aNode.Handle, Item);
end;

procedure TNxTreeView.CreateWnd;
begin
  inherited;
  SetWindowLong(Handle, GWL_STYLE, GetWindowLong(Handle, GWL_STYLE) or TVS_CHECKBOXES);
end;
{$ENDIF}

// ***** TNxTestTreeNodes *****

constructor TNxTestTreeNodes.Create;
begin
{$IFDEF GENERICS}
  fItems := TDictionary<string, TNxTreeNode>.Create;
{$ELSE}
  fItems := TStringList.Create;
{$ENDIF}
end;

destructor TNxTestTreeNodes.Destroy;
begin
  fItems.Free;
  inherited;
end;

{$IFDEF GENERICS}
procedure TNxTestTreeNodes.AddOrSetValue(const aKey: string; aValue: TNxTreeNode);
begin
  fItems.AddOrSetValue(aKey, aValue);
end;

function TNxTestTreeNodes.TryGetValue(const aKey: string; var aValue: TNxTreeNode): Boolean;
begin
  Result := fItems.TryGetValue(aKey, aValue);
end;
{$ELSE}
procedure TNxTestTreeNodes.AddOrSetValue(const aKey: string; aValue: TNxTreeNode);
var
  Idx: Integer;
begin
  Idx := fItems.IndexOf(aKey);
  if Idx >= 0 then
    fItems.Objects[Idx] := aValue
  else
    fItems.AddObject(aKey, aValue);
end;

function TNxTestTreeNodes.TryGetValue(const aKey: string; var aValue: TNxTreeNode): Boolean;
var
  Idx: Integer;
begin
  Idx := fItems.IndexOf(aKey);
  if Idx >= 0 then
  begin
    aValue := fItems.Objects[Idx] as TNxTreeNode;
    Result := True;
  end
  else
  begin
    aValue := nil;
    Result := False;
  end;
end;

{$ENDIF}

// ***** TNxTestApp *****

constructor TNxTestApp.Create;
var
  lConfigFileName: string;
begin
  inherited;
  fTestNodes := TNxTestTreeNodes.Create;
  lConfigFileName := ChangeFileExt(ParamStr(0), '.config.xml');
  fConfig := TNxTestConfig.Create(lConfigFileName);
  Application.Initialize;
  Application.CreateForm(TMainForm, fForm);
  fDpi := 96;
  CreateUserInterface;
end;

destructor TNxTestApp.Destroy;
begin
  fTestNodes.Free;
  fConfig.Free;
  inherited;
end;

function TNxTestApp.ScaledPix(aValue: Integer): Integer;
begin
  Result := MulDiv(aValue, fDpi, 96);
end;

function TNxTestApp.StatusBitmap(aStatus: TNxTestOutcome): TBitmap;
var
  r: TRect;
  DrawColor: TColor;
  s: string;
begin
  Result := TBitmap.Create;
  Result.Width := ScaledPix(20);
  Result.Height := ScaledPix(16);
  Result.Canvas.Brush.Style := bsSolid;
  Result.Canvas.Brush.Color := clWhite;
  Result.Canvas.FillRect(R);
  DrawColor := StatusColors[aStatus];
  Result.Canvas.Font.Name := 'Arial';
  Result.Canvas.Font.Style := [fsBold];
  Result.Canvas.Font.Size := 8;
  R := Rect(ScaledPix(4), 0, Result.Width, Result.Height);
  Result.Canvas.Pen.Style := psClear;
  Result.Canvas.Brush.Color := DrawColor;

  case aStatus of
    TestSkip, TestIncomplete :
    begin
      Result.Canvas.Ellipse(R.Left, R.Top, R.Right, R.Bottom);
    end;

    TestPass :
    begin
      Result.Canvas.Ellipse(R.Left, R.Top, R.Right, R.Bottom);
      Result.Canvas.Pen.Color := TextInverse;
      Result.Canvas.Pen.Width := 2;
      Result.Canvas.Pen.Style := psSolid;
      Result.Canvas.MoveTo(R.Left + ScaledPix(3), R.Top + ScaledPix(8));
      Result.Canvas.LineTo(R.Left + ScaledPix(7), R.Top + ScaledPix(11));
      Result.Canvas.LineTo(R.Left + ScaledPix(11), R.Top + ScaledPix(4));
    end;

    TestEmpty :
    begin
      Result.Canvas.Polygon([
        Point(R.Left + ((R.Right - R.Left) div 2), R.Top),
        Point(R.Left, R.Bottom),
        Point(R.Right, R.Bottom)
      ]);
      Result.Canvas.Brush.Style := bsClear;
      Result.Canvas.Font.Color := TextBlack;
      s := '!';
      Result.Canvas.TextOut(R.Left + ScaledPix(7), ScaledPix(2), s);
    end;

    TestIgnore, TestLeak, TestFail, TestTimeout:
    begin
      Result.Canvas.Ellipse(R.Left, R.Top, R.Right, R.Bottom);
      Result.Canvas.Brush.Style := bsClear;
      Result.Canvas.Font.Color := TextInverse;
      s := '!';
      Result.Canvas.TextOut(R.Left + ScaledPix(7), ScaledPix(1), s);
    end;

    TestError:
    begin
      Result.Canvas.Ellipse(R.Left, R.Top, R.Right, R.Bottom);
      Result.Canvas.Brush.Style := bsClear;
      Result.Canvas.Font.Color := TextInverse;
      s := 'x';
      Result.Canvas.TextOut(R.Left + ScaledPix(5), 0, s);
    end;
  end;
end;

procedure TNxTestApp.CreateUserInterface;
var
  i: TNxTestOutcome;
  Bmp: TBitmap;
  lLayout: TPanel;
begin
  if not Assigned(fForm) then
    Exit;
  fFormInitialized := True;

  fDpi := GetDeviceCaps(GetDC(fForm.Handle), LOGPIXELSX);
  fForm.OnCloseQuery := OnFormCloseQuery;

  fConfig.LoadFromFile;
  fDisabledTests := fConfig.DisabledTests;

  fImages := TImageList.Create(fForm);
  fImages.ShareImages := True;
  fImages.Width := ScaledPix(20);
  fImages.Height := ScaledPix(16);
  for i := Low(TNxTestOutcome) to High(TNxTestOutcome) do
    begin
      Bmp := StatusBitmap(i);
      fImages.Add(Bmp, nil);
      Bmp.Free;
    end;

  fToolBar := TPanel.Create(fForm);
  fToolBar.Caption := '';
  fToolBar.Align := alTop;
  fToolBar.Height := ScaledPix(44);
  fToolBar.Parent := fForm;
  {$IFDEF VCL_PADDING}
  fToolBar.Padding.Left := ScaledPix(8);
  fToolBar.Padding.Right := ScaledPix(8);
  fToolBar.Padding.Top := ScaledPix(6);
  fToolBar.Padding.Bottom := ScaledPix(6);
  {$ENDIF}

  fRunBtn := TButton.Create(fForm);
  fRunBtn.Align := alLeft;
  fRunBtn.Caption := 'Run All';
  fRunBtn.Parent := fToolBar;
  fRunBtn.Width := ScaledPix(120);
  fRunBtn.OnClick := RunAll;

  fRunSelectedBtn := TButton.Create(fForm);
  fRunSelectedBtn.Align := alLeft;
  fRunSelectedBtn.Caption := 'Run Selected';
  fRunSelectedBtn.Parent := fToolBar;
  fRunSelectedBtn.Width := ScaledPix(120);
  fRunSelectedBtn.OnClick := RunSelected;

  fCancelRunBtn := TButton.Create(fForm);
  fCancelRunBtn.Align := alLeft;
  fCancelRunBtn.Caption := 'Cancel';
  fCancelRunBtn.Parent := fToolBar;
  fCancelRunBtn.Width := ScaledPix(120);
  fCancelRunBtn.OnClick := CancelRun;
  fCancelRunBtn.Enabled := False;

  fTreeView := TNxTreeView.Create(fForm);
  fTreeView.Align := alClient;
  fTreeView.Parent := fForm;
  fTreeView.CheckBoxes := True;
  fTreeView.Images := fImages;
  fTreeView.OnCreateNodeClass := OnCreateNodeClass;

  fStatusBar := TStatusBar.Create(fForm);
  fStatusBar.Align := alBottom;
  fStatusBar.Height := ScaledPix(25);
  fStatusBar.Parent := fForm;
  fStatusBar.SimplePanel := True;

  fProgress := TProgressBar.Create(fForm);
  fProgress.Align := alBottom;
  fProgress.Parent := fForm;
  fProgress.Height := ScaledPix(8);
  {$IFDEF VCL_PADDING}
  fProgress.Margins.Bottom := ScaledPix(8);
  fProgress.AlignWithMargins := True;
  {$ENDIF}

  lLayout := TPanel.Create(fForm);
  lLayout.Caption := '';
  lLayout.BevelInner := bvNone;
  lLayout.BevelOuter := bvNone;
  lLayout.Height := ScaledPix(20);
  lLayout.Align := alBottom;
  lLayout.Parent := fForm;

  fScoreLabel := TLabel.Create(fForm);
  fScoreLabel.Layout := tlCenter;
  fScoreLabel.AutoSize := False;
  fScoreLabel.Align := alLeft;
  fScoreLabel.Width := ScaledPix(100);
  fScoreLabel.Parent := lLayout;

  fScoreProgress := TProgressBar.Create(fForm);
  fScoreProgress.Align := alClient;
  fScoreProgress.Parent := lLayout;

  NxTestRegistry.Discover;

  BuildTreeRecursive(nil, NxTestRegistry.Suite);
  fTreeView.FullExpand;
end;

procedure TNxTestApp.OnCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
begin
  NodeClass := TNxTreeNode;
end;

procedure TNxTestApp.BuildTreeRecursive(aParentNode: TNxTreeNode; aSuite: INxTestSuite);
var
  lSuiteNode, lNode: TNxTreeNode;
  lSuite: INxTestSuite;
  lTest: INxTest;
  i: Integer;
begin
  lSuiteNode := fTreeView.Items.AddChild(aParentNode, aSuite.TestName) as TNxTreeNode;
  lSuiteNode.ImageIndex := Ord(TestSkip);
  lSuiteNode.SelectedIndex := Ord(TestSkip);
  lSuiteNode.TagString := aSuite.FullTestName;
  TTreeViewNodeSetChecked(lSuiteNode, TestChecked(aSuite));
  fTestNodes.AddOrSetValue(aSuite.FullTestName, lSuiteNode);

  for i := 0 to aSuite.ItemCount - 1 do
  begin
    lTest := aSuite.Test(i);
    if Supports(lTest, INxTestSuite, lSuite) then
      begin
        BuildTreeRecursive(lSuiteNode, lSuite);
      end
    else
      begin
        lNode := fTreeView.Items.AddChild(lSuiteNode, lTest.TestName) as TNxTreeNode;
        lNode.ImageIndex := Ord(TestSkip);
        lNode.SelectedIndex := Ord(TestSkip);
        lNode.TagString := lTest.FullTestName;
        TTreeViewNodeSetChecked(lNode, TestChecked(lTest));
        fTestNodes.AddOrSetValue(lTest.FullTestName, lNode);
      end;
  end;
end;

procedure TNxTestApp.OnFormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := not Running;
  if CanClose then
    UpdateTestSelection
  else
  if MessageDlg('Test suite is running? Do you want to force close?', mtWarning, [mbYes, mbNo], 0) = mrYes then
    Application.Terminate;
end;

function TNxTestApp.TestChecked(const aTest: INxTest): Boolean;
begin
  Result := not ContainsString(aTest.FullTestName, fDisabledTests);
end;

function TNxTestApp.TestSelected(const aTest: INxTest): Boolean;
begin
  // if selected tests array is empty, treat all tests as selected
  Result := Length(fSelectedTests) = 0;
  if not Result then
    Result := ContainsString(aTest.FullTestName, fSelectedTests);
end;

procedure TNxTestApp.UpdateTestSelection;

procedure SelectRecursive(aNode: TNxTreeNode);
var
  lNode: TNxTreeNode;
begin
  AddUniqueString(aNode.TagString, fSelectedTests);
  lNode := aNode.GetFirstChild as TNxTreeNode;
  while Assigned(lNode) do
    begin
      if TreeViewNodeIsChecked(lNode) then
        SelectRecursive(lNode);
      lNode := lNode.GetNextSibling as TNxTreeNode;
    end;
end;

var
  i: Integer;
  lNode: TNxTreeNode;
begin
  SetLength(fSelectedTests, 0);
  SetLength(fDisabledTests, 0);
  for i := 0 to fTreeView.Items.Count - 1 do
    begin
      lNode := fTreeView.Items[i] as TNxTreeNode;
      lNode.ImageIndex := Ord(TestSkip);
      lNode.SelectedIndex := Ord(TestSkip);
      if not TreeViewNodeIsChecked(lNode) then
        AddUniqueString(lNode.TagString, fDisabledTests);
    end;
  if Length(fDisabledTests) > 0 then
    begin
      lNode := fTreeView.Items.GetFirstNode as TNxTreeNode;
      while Assigned(lNode) do
        begin
          if TreeViewNodeIsChecked(lNode) then
            SelectRecursive(lNode);
          lNode := lNode.GetNextSibling as TNxTreeNode;
        end;
    end;

  fConfig.DisabledTests := fDisabledTests;
  fConfig.SaveToFile;
end;

procedure TNxTestApp.RunAll(Sender: TObject);
var
  i: Integer;
  lNode: TTreeNode;
begin
  Running := True;
  for i := 0 to fTreeView.Items.Count - 1 do
    begin
      lNode := fTreeView.Items[i];
      lNode.ImageIndex := Ord(TestSkip);
      lNode.SelectedIndex := Ord(TestSkip);
    end;
  Engine.Runner.RunTests(nil);
end;

procedure TNxTestApp.RunSelected(Sender: TObject);
begin
  Running := True;
  UpdateTestSelection;
  Engine.Runner.RunTests(TestSelected);
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
  fStatusBar.SimpleText := 'Running...';
  fProgress.Position := 0;
  fProgress.Max := aTotalCount;
  fScoreProgress.Position := 0;
  fScoreLabel.Caption := 'Score: 0%';
  fScoreProgress.Max := aTotalCount;
end;

procedure TNxTestApp.OnRunEnds(const aTest: INxTest; const aSummary: INxTestSummary);
begin
  fStatusBar.SimpleText := Format('Completed: %s Duration: %s', [NxTestOutcomeText[aSummary.Outcome], FormatDuration(aSummary.Duration)]);
  Running := False;
end;

procedure TNxTestApp.OnSuiteStart(const aTest: INxTest);
begin

end;

procedure TNxTestApp.OnSuiteEnds(const aTest: INxTest; const aSummary: INxTestSummary);
var
  lNode: TNxTreeNode;
begin
  if fTestNodes.TryGetValue(aTest.FullTestName, lNode) then
    begin
      lNode.ImageIndex := Ord(aSummary.Outcome);
      lNode.SelectedIndex := Ord(aSummary.Outcome);
    end;
  fTreeView.Invalidate;
  Application.ProcessMessages;
end;

procedure TNxTestApp.OnTestStart(const aTest: INxTest);
begin

end;

procedure TNxTestApp.OnTestEnds(const aTest: INxTest; const aResult: INxTestResult);
var
  lNode: TNxTreeNode;
begin
  if fTestNodes.TryGetValue(aTest.FullTestName, lNode) then
    begin
      lNode.ImageIndex := Ord(aResult.Outcome);
      lNode.SelectedIndex := Ord(aResult.Outcome);
    end;
  fProgress.Position := fProgress.Position + 1;
  if aResult.Outcome = TestPass then
    fScoreProgress.Position := fScoreProgress.Position + 1
  else
  if aResult.Outcome = TestSkip then
    fScoreProgress.Max := fScoreProgress.Max - 1;
  fScoreLabel.Caption := Format('Score: %d%%', [Round(fScoreProgress.Position / fScoreProgress.Max * 100)]);
  fTreeView.Invalidate;
  Application.ProcessMessages;
end;

procedure TNxTestApp.OnStatus(const aTest: INxTest; const aStatusMsg: string);
begin

end;

end.
