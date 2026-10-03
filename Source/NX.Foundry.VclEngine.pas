
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
  System.Actions,
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
  Vcl.ActnList,
  Vcl.Buttons,
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
  ActnList,
  Buttons,
  XmlDoc,
  XmlIntf,
  XPMan,
  {$ENDIF}
  NX.Foundry.TestFramework,
  NX.Foundry.Config,
  NX.Foundry.Filters;

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
    fActionList: TActionList;
    fImages: TImageList;
    fToolBar: TPanel;
    fSelectionToolBar: TPanel;
    fTreeView: TNxTreeView;
    fStatusBar: TStatusBar;
    fRunBtn: TButton;
    fRunSelectedBtn: TButton;
    fCancelRunBtn: TButton;
    fFilterLabel: TLabel;
    fScoreLabel: TLabel;
    fTotalLabel: TLabel;
    fOutcomeLabels: array[TNxTestOutcome] of TLabel;
    fScoreProgress: TProgressBar;
    fProgress: TProgressBar;
    fSideViewContent: TScrollBox;
    fCategoriesLayout: TPanel;
    fCategoriesFilterMode: TComboBox;
    fTestNodes: TNxTestTreeNodes;
    fDisabledTests: TNxStringArray;
    fSelectedTests: TNxStringArray;
    fCategories: TNxStringArray;
    fFormInitialized: Boolean;
    fRunning: Boolean;
    fDpi: Integer;
    procedure OnFormCloseQuery(Sender: TObject; var CanClose: Boolean);
    function ScaledPix(aValue: Integer): Integer;
    procedure CreateUserInterface;
    procedure CheckBitmap(aChecked: Boolean; var Bmp, Mask: TBitmap);
    procedure StatusBitmap(aStatus: TNxTestOutcome; var Bmp, Mask: TBitmap);
    procedure OnCreateNodeClass(Sender: TCustomTreeView; var NodeClass: TTreeNodeClass);
    procedure BuildTreeRecursive(AParentNode: TNxTreeNode; aSuite: INxTestSuite);
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

procedure TNxTestApp.CheckBitmap(aChecked: Boolean; var Bmp, Mask: TBitmap);
var
  R: TRect;
begin
  Bmp.Width := ScaledPix(20);
  Bmp.Height := ScaledPix(16);
  Mask.Width := Bmp.Width;
  Mask.Height := Bmp.Height;
  R := Rect(0, 0, Bmp.Width, Bmp.Height);
  Bmp.Canvas.Brush.Style := bsSolid;
  Bmp.Canvas.Brush.Color := clWhite;
  Bmp.Canvas.FillRect(R);
  Mask.Canvas.Brush.Style := bsSolid;
  Bmp.Canvas.Brush.Color := clWhite;
  Mask.Canvas.FillRect(R);
  Mask.Canvas.Brush.Color := clBlack;
  R := Rect(ScaledPix(4), 0, Bmp.Width, Bmp.Height);
  Bmp.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, ScaledPix(2), ScaledPix(2));
  Mask.Canvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom, ScaledPix(2), ScaledPix(2));
  if aChecked then
    begin
      Bmp.Canvas.Pen.Color := clBlack;
      Bmp.Canvas.Pen.Width := 2;
      Bmp.Canvas.Pen.Style := psSolid;
      Bmp.Canvas.MoveTo(R.Left + ScaledPix(3), R.Top + ScaledPix(8));
      Bmp.Canvas.LineTo(R.Left + ScaledPix(7), R.Top + ScaledPix(11));
      Bmp.Canvas.LineTo(R.Left + ScaledPix(11), R.Top + ScaledPix(4));
    end;
end;

procedure TNxTestApp.StatusBitmap(aStatus: TNxTestOutcome; var Bmp, Mask: TBitmap);
var
  R: TRect;
  DrawColor: TColor;
  s: string;
begin
  Bmp.Width := ScaledPix(20);
  Bmp.Height := ScaledPix(16);
  Mask.Width := Bmp.Width;
  Mask.Height := Bmp.Height;
  R := Rect(0, 0, Bmp.Width, Bmp.Height);
  Bmp.Canvas.Brush.Style := bsSolid;
  Bmp.Canvas.Brush.Color := clWhite;
  Bmp.Canvas.FillRect(R);
  Mask.Canvas.Brush.Style := bsSolid;
  Mask.Canvas.Brush.Color := clWhite;
  Mask.Canvas.FillRect(R);
  Mask.Canvas.Brush.Color := clBlack;
  DrawColor := StatusColors[aStatus];
  Bmp.Canvas.Font.Name := 'Arial';
  Bmp.Canvas.Font.Style := [fsBold];
  Bmp.Canvas.Font.Size := 8;
  R := Rect(ScaledPix(4), 0, Bmp.Width, Bmp.Height);
  Bmp.Canvas.Pen.Style := psClear;
  Bmp.Canvas.Brush.Color := DrawColor;

  case aStatus of
    TestSkip, TestIncomplete :
    begin
      Bmp.Canvas.Pen.Style := psSolid;
      Bmp.Canvas.Pen.Color := clGray;
      Bmp.Canvas.Ellipse(R.Left, R.Top, R.Right, R.Bottom);
      Mask.Canvas.Ellipse(R.Left, R.Top, R.Right, R.Bottom);
    end;

    TestPass :
    begin
      Bmp.Canvas.Ellipse(R.Left, R.Top, R.Right, R.Bottom);
      Mask.Canvas.Ellipse(R.Left, R.Top, R.Right, R.Bottom);
      Bmp.Canvas.Pen.Color := TextInverse;
      Bmp.Canvas.Pen.Width := 2;
      Bmp.Canvas.Pen.Style := psSolid;
      Bmp.Canvas.MoveTo(R.Left + ScaledPix(3), R.Top + ScaledPix(8));
      Bmp.Canvas.LineTo(R.Left + ScaledPix(7), R.Top + ScaledPix(11));
      Bmp.Canvas.LineTo(R.Left + ScaledPix(11), R.Top + ScaledPix(4));
    end;

    TestEmpty :
    begin
      Bmp.Canvas.Polygon([
        Point(R.Left + ((R.Right - R.Left) div 2), R.Top),
        Point(R.Left, R.Bottom),
        Point(R.Right, R.Bottom)
      ]);
      Mask.Canvas.Polygon([
        Point(R.Left + ((R.Right - R.Left) div 2), R.Top),
        Point(R.Left, R.Bottom),
        Point(R.Right, R.Bottom)
      ]);
      Bmp.Canvas.Brush.Style := bsClear;
      Bmp.Canvas.Font.Color := TextBlack;
      s := '!';
      Bmp.Canvas.TextOut(R.Left + ScaledPix(7), ScaledPix(2), s);
    end;

    TestIgnore, TestLeak, TestFail, TestTimeout:
    begin
      Bmp.Canvas.Ellipse(R.Left, R.Top, R.Right, R.Bottom);
      Mask.Canvas.Ellipse(R.Left, R.Top, R.Right, R.Bottom);
      Bmp.Canvas.Brush.Style := bsClear;
      Bmp.Canvas.Font.Color := TextInverse;
      s := '!';
      Bmp.Canvas.TextOut(R.Left + ScaledPix(7), ScaledPix(1), s);
    end;

    TestError:
    begin
      Bmp.Canvas.Ellipse(R.Left, R.Top, R.Right, R.Bottom);
      Mask.Canvas.Ellipse(R.Left, R.Top, R.Right, R.Bottom);
      Bmp.Canvas.Brush.Style := bsClear;
      Bmp.Canvas.Font.Color := TextInverse;
      s := 'x';
      Bmp.Canvas.TextOut(R.Left + ScaledPix(5), 0, s);
    end;
  end;
end;

procedure TNxTestApp.CreateUserInterface;
var
  i: TNxTestOutcome;
  Bmp: TBitmap;
  Mask: TBitmap;
  lFlow: TPanel;
  lLayout: TPanel;
  lBtn: TButton;
  lSpeedBtn: TSpeedButton;
  lAction: TAction;
  lChk: TCheckBox;
  lOutcome: TNxTestOutcome;
  lLabel: TLabel;
  lPos: Integer;
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
  Mask := nil;
  Bmp := TBitmap.Create;
  try
    Mask := TBitmap.Create;
    for i := Low(TNxTestOutcome) to High(TNxTestOutcome) do
      begin
        StatusBitmap(i, Bmp, Mask);
        fImages.Add(Bmp, Mask);
      end;
    CheckBitmap(True, Bmp, Mask);
    fImages.Add(Bmp, Mask);
    CheckBitmap(False, Bmp, Mask);
    fImages.Add(Bmp, Mask);
  finally
    Bmp.Free;
    Mask.Free;
  end;
  fActionList := TActionList.Create(fForm);
  fActionList.Images := fImages;

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

  fSelectionToolBar := TPanel.Create(fForm);
  fSelectionToolBar.Caption := '';
  fSelectionToolBar.Align := alClient;
  fSelectionToolBar.Parent := fToolBar;
  fSelectionToolBar.BevelOuter := bvNone;

  fSideViewContent := TScrollBox.Create(fForm);
  fSideViewContent.Align := alLeft;
  fSideViewContent.Parent := fForm;

  lAction := TAction.Create(fActionList);
  lAction.Caption := 'Collapse All';
  lAction.OnExecute := ExecuteCollapseAll;

  lBtn := TButton.Create(fForm);
  lBtn.Height := 32;
  lBtn.Action := lAction;
  {$IFDEF VCL_PADDING}
  lBtn.AlignWithMargins := True;
  lBtn.Margins.Left := ScaledPix(8);
  lBtn.Margins.Right := ScaledPix(8);
  lBtn.Margins.Top := ScaledPix(4);
  lBtn.Margins.Bottom := ScaledPix(4);
  {$ENDIF}
  lBtn.Parent := fSideViewContent;
  lBtn.Align := alTop;

  lAction := TAction.Create(fActionList);
  lAction.Caption := 'Expand All';
  lAction.OnExecute := ExecuteExpandAll;

  lBtn := TButton.Create(fForm);
  lBtn.Height := ScaledPix(32);
  lBtn.Action := lAction;
  {$IFDEF VCL_PADDING}
  lBtn.AlignWithMargins := True;
  lBtn.Margins.Left := ScaledPix(8);
  lBtn.Margins.Right := ScaledPix(8);
  lBtn.Margins.Top := ScaledPix(4);
  lBtn.Margins.Bottom := ScaledPix(4);
  {$ENDIF}
  lBtn.Parent := fSideViewContent;
  lBtn.Align := alTop;

  lAction := TAction.Create(fActionList);
  lAction.Caption := 'Select Node';
  lAction.OnExecute := ExecuteSelectNode;

  lBtn := TButton.Create(fForm);
  lBtn.Height := ScaledPix(32);
  lBtn.Action := lAction;
  {$IFDEF VCL_PADDING}
  lBtn.AlignWithMargins := True;
  lBtn.Margins.Left := ScaledPix(8);
  lBtn.Margins.Right := ScaledPix(8);
  lBtn.Margins.Top := ScaledPix(4);
  lBtn.Margins.Bottom := ScaledPix(4);
  {$ENDIF}
  lBtn.Parent := fSideViewContent;
  lBtn.Align := alTop;

  lAction := TAction.Create(fActionList);
  lAction.Caption := 'Deselect Node';
  lAction.OnExecute := ExecuteDeselectNode;

  lBtn := TButton.Create(fForm);
  lBtn.Height := ScaledPix(32);
  lBtn.Action := lAction;
  {$IFDEF VCL_PADDING}
  lBtn.AlignWithMargins := True;
  lBtn.Margins.Left := ScaledPix(8);
  lBtn.Margins.Right := ScaledPix(8);
  lBtn.Margins.Top := ScaledPix(4);
  lBtn.Margins.Bottom := ScaledPix(4);
  {$ENDIF}
  lBtn.Parent := fSideViewContent;
  lBtn.Align := alTop;

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

  lAction := TAction.Create(fActionList);
  lAction.Hint := 'Select All';
  lAction.ImageIndex := Ord(High(TNxTestOutcome)) + 1;
  lAction.ActionList := fActionList;
  lAction.OnExecute := ExecuteSelectAll;

  lSpeedBtn := TSpeedButton.Create(fForm);
  lSpeedBtn.Action := lAction;
  lSpeedBtn.Width := ScaledPix(36);
  {$IFDEF VCL_PADDING}
  lSpeedBtn.AlignWithMargins := True;
  lSpeedBtn.Margins.Top := 0;
  lSpeedBtn.Margins.Bottom := 0;
  lSpeedBtn.Margins.Left := ScaledPix(6);
  lSpeedBtn.Margins.Right := 0;
  {$ENDIF}
  lSpeedBtn.Align := alLeft;
  lSpeedBtn.Parent := fSelectionToolBar;

  lAction := TAction.Create(fActionList);
  lAction.Hint := 'Deselect All';
  lAction.ImageIndex := Ord(High(TNxTestOutcome)) + 2;
  lAction.ActionList := fActionList;
  lAction.OnExecute := ExecuteDeselectAll;

  lSpeedBtn := TSpeedButton.Create(fForm);
  lSpeedBtn.Action := lAction;
  lSpeedBtn.Width := ScaledPix(36);
  {$IFDEF VCL_PADDING}
  lSpeedBtn.AlignWithMargins := True;
  lSpeedBtn.Margins.Top := 0;
  lSpeedBtn.Margins.Bottom := 0;
  lSpeedBtn.Margins.Left := ScaledPix(6);
  lSpeedBtn.Margins.Right := 0;
  {$ENDIF}
  lSpeedBtn.Align := alLeft;
  lSpeedBtn.Parent := fSelectionToolBar;

  for lOutcome := Low(TNxTestOutcome) to Pred(High(TNxTestOutcome)) do
    begin
      lAction := TAction.Create(fActionList);
      lAction.Hint := 'Select ' + NxTestOutcomeDescription[lOutcome];
      lAction.OnExecute := ExecuteSelectOutcome;
      lAction.Tag := Ord(lOutcome);
      lAction.ImageIndex := Ord(lOutcome);
      lAction.ActionList := fActionList;

      lSpeedBtn := TSpeedButton.Create(fForm);
      {$IFDEF VCL_PADDING}
      lSpeedBtn.AlignWithMargins := True;
      lSpeedBtn.Margins.Top := 0;
      lSpeedBtn.Margins.Bottom := 0;
      lSpeedBtn.Margins.Left := ScaledPix(6);
      lSpeedBtn.Margins.Right := 0;
      {$ENDIF}
      lSpeedBtn.Height := ScaledPix(36);
      lSpeedBtn.Width := ScaledPix(36);
      lSpeedBtn.Action := lAction;
      lSpeedBtn.Parent := fSelectionToolBar;
      lSpeedBtn.Align := alLeft;
    end;

  fFilterLabel := TLabel.Create(fForm);
  fFilterLabel.Caption := '';
  fFilterLabel.Height := ScaledPix(24);
  {$IFDEF VCL_PADDING}
  fFilterLabel.AlignWithMargins := True;
  fFilterLabel.Margins.Left := ScaledPix(6);
  fFilterLabel.Margins.Right := ScaledPix(6);
  {$ENDIF}
  fFilterLabel.Top := 600;
  fFilterLabel.Align := alTop;
  fFilterLabel.Parent := fForm;

  fTreeView := TNxTreeView.Create(fForm);
  fTreeView.Align := alClient;
  fTreeView.Parent := fForm;
  fTreeView.CheckBoxes := True;
  fTreeView.Images := fImages;
  fTreeView.OnCreateNodeClass := OnCreateNodeClass;
  fTreeView.DoubleBuffered := True;
  fTreeView.HideSelection := False;

  fStatusBar := TStatusBar.Create(fForm);
  fStatusBar.Align := alBottom;
  fStatusBar.Height := ScaledPix(25);
  fStatusBar.Parent := fForm;
  fStatusBar.SimplePanel := True;

  lFlow := TPanel.Create(fForm);
  lFlow.Height := ScaledPix(48);
  {$IFDEF VCL_PADDING}
  lFlow.Margins.Top := ScaledPix(6);
  lFlow.Margins.Left := ScaledPix(6);
  lFlow.Margins.Right := ScaledPix(6);
  lFlow.Margins.Bottom := 0;
  {$ENDIF}
  lFlow.Align := alBottom;
  lFlow.BevelOuter := bvNone;
  lFlow.Parent := fForm;

  lLayout := TPanel.Create(fForm);
  lLayout.Width := ScaledPix(52);
  lLayout.Height := ScaledPix(48);
  lLayout.BevelOuter := bvNone;
  lLayout.Left := ScaledPix(6);
  lLayout.Parent := lFlow;

  lLabel := TLabel.Create(fForm);
  lLabel.AutoSize := False;
  lLabel.Height := ScaledPix(24);
  lLabel.Caption := 'Tests';
  lLabel.Layout := tlCenter;
  lLabel.Align := alTop;
  lLabel.Parent := lLayout;

  fTotalLabel := TLabel.Create(fForm);
  fTotalLabel.Caption := '0';
  fTotalLabel.Alignment := taCenter;
  fTotalLabel.Layout := tlCenter;
  fTotalLabel.Align := alTop;
  fTotalLabel.Parent := lLayout;

  lPos := ScaledPix(6) + lLayout.Width;

  for lOutcome := Low(TNxTestOutcome) to Pred(High(TNxTestOutcome)) do
    begin
      lLayout := TPanel.Create(fForm);
      lLayout.Width := ScaledPix(68);
      lLayout.Height := ScaledPix(48);
      lLayout.BevelOuter := bvNone;
      lLayout.Left := lPos;
      lLayout.Parent := lFlow;
      lPos := lPos + ScaledPix(68);

      lLabel := TLabel.Create(fForm);
      lLabel.AutoSize := False;
      lLabel.Height := ScaledPix(24);
      lLabel.Caption := NxTestOutcomeDescription[lOutcome];
      lLabel.Layout := tlCenter;
      lLabel.Align := alTop;
      lLabel.Parent := lLayout;

      lLabel := TLabel.Create(fForm);
      lLabel.AutoSize := True;
      lLabel.Caption := '0';
      lLabel.Alignment := taCenter;
      lLabel.Layout := tlCenter;
      lLabel.Align := alTop;
      lLabel.Parent := lLayout;
      fOutcomeLabels[lOutcome] := lLabel;
    end;

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

  fProgress := TProgressBar.Create(fForm);
  fProgress.Align := alBottom;
  fProgress.Parent := fForm;
  fProgress.Height := ScaledPix(8);
  {$IFDEF VCL_PADDING}
  fProgress.Margins.Bottom := ScaledPix(8);
  fProgress.AlignWithMargins := True;
  {$ENDIF}

  NxTestRegistry.Discover;

  BuildTreeRecursive(nil, NxTestRegistry.Suite);
  fTreeView.FullExpand;
  BuildCategories;
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
        AddUniqueStrings(fCategories, lTest.Categories);
      end;
  end;
end;

procedure TNxTestApp.BuildCategories;
var
  lLabel: TLabel;
  lChk: TCheckBox;
  i: Integer;
  h: Integer;
begin
  lLabel := TLabel.Create(fForm);
  {$IFDEF VCL_PADDING}
  lLabel.AlignWithMargins := True;
  lLabel.Margins.Left := ScaledPix(8);
  lLabel.Margins.Top := ScaledPix(8);
  {$ENDIF}
  lLabel.Caption := 'Categories Filter';
  lLabel.Align := alTop;
  lLabel.Parent := fSideViewContent;

  fCategoriesFilterMode := TComboBox.Create(fForm);
  {$IFDEF VCL_PADDING}
  fCategoriesFilterMode.AlignWithMargins := True;
  fCategoriesFilterMode.Margins.Left := ScaledPix(8);
  fCategoriesFilterMode.Margins.Right := ScaledPix(8);
  fCategoriesFilterMode.Margins.Top := ScaledPix(8);
  {$ENDIF}
  fCategoriesFilterMode.Align := alTop;
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
      {$IFDEF VCL_PADDING}
      lLabel.AlignWithMargins := True;
      lLabel.Margins.Left := ScaledPix(8);
      lLabel.Margins.Top := ScaledPix(8);
      {$ENDIF}
      lLabel.Caption := '<no categories>';
      lLabel.Align := alTop;
      lLabel.Parent := fSideViewContent;
    end
  else
    begin
      h := ScaledPix(8);
      fCategoriesLayout := TPanel.Create(fForm);
      {$IFDEF VCL_PADDING}
      fCategoriesLayout.AlignWithMargins := True;
      fCategoriesLayout.Margins.Left := ScaledPix(8);
      fCategoriesLayout.Margins.Right := ScaledPix(8);
      fCategoriesLayout.Margins.Top := ScaledPix(8);
      {$ENDIF}
      fCategoriesLayout.Top := 600;
      fCategoriesLayout.BevelOuter := bvNone;
      fCategoriesLayout.Align := alTop;
      fCategoriesLayout.Parent := fSideViewContent;

      for i := 0 to High(fCategories) do
        begin
          lChk := TCheckBox.Create(fForm);
          lChk.Caption := fCategories[i];
          {$IFDEF VCL_PADDING}
          lChk.AlignWithMargins := True;
          lChk.Margins.Top := 0;
          lChk.Margins.Bottom := ScaledPix(8);
          {$ENDIF}
          lChk.Parent := fCategoriesLayout;
          lChk.Align := alTop;
          lChk.OnClick := UpdateCategoriesLabel;
          h := h + lChk.Height + ScaledPix(8);
        end;
      fCategoriesLayout.Height := h;
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
      for i := 0 to fCategoriesLayout.ControlCount - 1 do
        if TCheckBox(fCategoriesLayout.Controls[i]).Checked then
          lText := lText + TCheckBox(fCategoriesLayout.Controls[i]).Caption + ', ';
    end;
  fFilterLabel.Caption := lText;
end;

procedure TNxTestApp.UpdateTestSelection;

procedure SelectRecursive(aNode: TNxTreeNode);
var
  lNode: TNxTreeNode;
begin
  AddUniqueString(fSelectedTests, aNode.TagString);
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
        AddUniqueString(fDisabledTests, lNode.TagString);
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

function TNxTestApp.CategoryFilter: INxTestStringsFilter;
var
  i: Integer;
begin
  case fCategoriesFilterMode.ItemIndex of
    1 : // any category
      begin
        Result := TNxTestAnyCategoryFilter.Create;
        for i := 0 to fCategoriesLayout.ControlCount - 1 do
          if TCheckBox(fCategoriesLayout.Controls[i]).Checked then
            Result.AddString(TCheckBox(fCategoriesLayout.Controls[i]).Caption);
      end;
    2 : // all categories
      begin
        Result := TNxTestAllCategoriesFilter.Create;
        for i := 0 to fCategoriesLayout.ControlCount - 1 do
          if TCheckBox(fCategoriesLayout.Controls[i]).Checked then
            Result.AddString(TCheckBox(fCategoriesLayout.Controls[i]).Caption);
      end;
    3 : // no category
      begin
        Result := TNxTestNoCategoriesFilter.Create;
        for i := 0 to fCategoriesLayout.ControlCount - 1 do
          if TCheckBox(fCategoriesLayout.Controls[i]).Checked then
            Result.AddString(TCheckBox(fCategoriesLayout.Controls[i]).Caption);
      end;
    else // category filtering disabled
      Result := nil;
  end;
end;

procedure TNxTestApp.ExecuteCollapseAll(Sender: TObject);
begin
  fTreeView.FullCollapse;
end;

procedure TNxTestApp.ExecuteExpandAll(Sender: TObject);
begin
  fTreeView.FullExpand;
end;

procedure TNxTestApp.ExecuteSelectNode(Sender: TObject);
var
  lCurrent: TTreeNode;
  lNode: TTreeNode;
begin
  lCurrent := fTreeView.Selected;
  if Assigned(lCurrent) then
    begin
      TTreeViewNodeSetChecked(lCurrent, True);
      lNode := lCurrent.GetFirstChild;
      while Assigned(lNode) do
        begin
          TTreeViewNodeSetChecked(lNode, True);
          lNode := lNode.GetNextSibling;
        end;
    end;
end;

procedure TNxTestApp.ExecuteDeselectNode(Sender: TObject);
var
  lCurrent: TTreeNode;
  lNode: TTreeNode;
begin
  lCurrent := fTreeView.Selected;
  if Assigned(lCurrent) then
    begin
      TTreeViewNodeSetChecked(lCurrent, False);
      lNode := lCurrent.GetFirstChild;
      while Assigned(lNode) do
        begin
          TTreeViewNodeSetChecked(lNode, False);
          lNode := lNode.GetNextSibling;
        end;
    end;
end;

procedure TNxTestApp.ExecuteSelectAll(Sender: TObject);
var
  i: Integer;
  lNode: TTreeNode;
begin
  for i := 0 to fTreeView.Items.Count - 1 do
    begin
      lNode := fTreeView.Items[i];
      TTreeViewNodeSetChecked(lNode, True);
    end;
end;

procedure TNxTestApp.ExecuteDeselectAll(Sender: TObject);
var
  i: Integer;
  lNode: TTreeNode;
begin
  for i := 0 to fTreeView.Items.Count - 1 do
    begin
      lNode := fTreeView.Items[i];
      TTreeViewNodeSetChecked(lNode, False);
    end;
end;

procedure TNxTestApp.ExecuteSelectOutcome(Sender: TObject);
var
  i: Integer;
  lNode: TTreeNode;
  Outcome: TNxTestOutcome;
begin
  Outcome := TNxTestOutcome(TComponent(Sender).Tag);
  for i := 0 to fTreeView.Items.Count - 1 do
    begin
      lNode := fTreeView.Items[i];
      if lNode.Count > 0 then
        TTreeViewNodeSetChecked(lNode, True)
      else
        TTreeViewNodeSetChecked(lNode, lNode.ImageIndex = Ord(Outcome));
    end;
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
  // always use category filter, it will be nil if category filtering is not enabled
  Engine.Runner.RunTests(CategoryFilter);
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
  Engine.Runner.RunTests(lFilters);
end;

procedure TNxTestApp.SetRunning(const Value: Boolean);
begin
  fRunning := Value;
  fSideViewContent.Enabled := not Value;
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
  fStatusBar.SimpleText := 'Running...';
  fProgress.Position := 0;
  fProgress.Max := aTotalCount;
  fScoreProgress.Position := 0;
  fScoreLabel.Caption := 'Score: 0%';
  fScoreProgress.Max := aTotalCount;
  fTotalLabel.Caption := '0';
  for lOutcome := Low(TNxTestOutcome) to Pred(High(TNxTestOutcome)) do
    fOutcomeLabels[lOutcome].Caption := '0';
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
  fTotalLabel.Caption := IntToStr(fProgress.Position);
  if Assigned(fOutcomeLabels[aResult.Outcome]) then
    fOutcomeLabels[aResult.Outcome].Caption := IntToStr(StrToInt(fOutcomeLabels[aResult.Outcome].Caption) + 1);
  fTreeView.Invalidate;
  Application.ProcessMessages;
end;

procedure TNxTestApp.OnStatus(const aTest: INxTest; const aStatusMsg: string);
begin

end;

end.
