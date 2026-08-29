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
  Vcl.ImgList,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Vcl.ComCtrls,
  {$ELSE}
  Types,
  SysUtils,
  Classes,
  ImgList,
  Graphics,
  Controls,
  Forms,
  StdCtrls,
  ExtCtrls,
  ComCtrls,
  XmlDoc,
  XmlIntf,
  {$ENDIF}
  NX.Foundry.TestFramework;

type
  TNxGuiTestEngine = class(TNxTestEngine)
  private
    fSelectedTests: TNxStringArray;
  public
    procedure Start; override;
    function TestSelected(const aTest: INxTest): Boolean;
  end;

  TMainForm = class(TForm);

  TNxTestApp = class(TInterfacedObject, INxTestReporter)
  protected
    fForm: TMainForm;
    fImages: TImageList;
    fToolBar: TPanel;
    fTreeView: TTreeView;
    fStatusBar: TStatusBar;
    fRunBtn: TButton;
    {$IFDEF GENERICS}
    fTestNodes: TDictionary<string, TTreeNode>;
    {$ENDIF}
    fFormInitialized: Boolean;
    procedure CreateUserInterface;
    function StatusBitmap(aStatus: TNxTestOutcome): TBitmap;
    procedure BuildTreeRecursive(AParentNode: TTreeNode; aSuite: INxTestSuite);
    procedure RunAll(Sender: TObject);
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

function TNxGuiTestEngine.TestSelected(const aTest: INxTest): Boolean;
begin
  Result := True;
end;

procedure TNxGuiTestEngine.Start;
begin
  Application.Run;
end;

// ***** TNxTestApp *****

constructor TNxTestApp.Create;
begin
  inherited;
{$IFDEF GENERICS}
  fTestNodes := TDictionary<string, TTreeNode>.Create;
{$ENDIF}
  Application.Initialize;
  Application.CreateForm(TMainForm, fForm);
  CreateUserInterface;
end;

destructor TNxTestApp.Destroy;
begin
{$IFDEF GENERICS}
  fTestNodes.Free;
{$ENDIF}
  inherited;
end;

function TNxTestApp.StatusBitmap(aStatus: TNxTestOutcome): TBitmap;
var
  r: TRect;
  DrawColor: TColor;
  s: string;
begin
  Result := TBitmap.Create;
  Result.Width := 16;
  Result.Height := 16;
  Result.Canvas.Brush.Style := bsSolid;
  Result.Canvas.Brush.Color := clWhite;
  Result.Canvas.FillRect(R);
  DrawColor := StatusColors[aStatus];
  Result.Canvas.Font.Name := 'Arial';
  Result.Canvas.Font.Style := [fsBold];
  Result.Canvas.Font.Size := 8;
  R := Rect(0, 0, 16, 16);
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
      Result.Canvas.MoveTo(R.Left + 3, R.Top + 8);
      Result.Canvas.LineTo(R.Left + 7, R.Top + 11);
      Result.Canvas.LineTo(R.Left + 11, R.Top + 4);
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
      Result.Canvas.TextOut(7, 2, s);
    end;

    TestIgnore, TestLeak, TestFail, TestTimeout:
    begin
      Result.Canvas.Ellipse(R.Left, R.Top, R.Right, R.Bottom);
      Result.Canvas.Brush.Style := bsClear;
      Result.Canvas.Font.Color := TextInverse;
      s := '!';
      Result.Canvas.TextOut(7, 1, s);
    end;

    TestError:
    begin
      Result.Canvas.Ellipse(R.Left, R.Top, R.Right, R.Bottom);
      Result.Canvas.Brush.Style := bsClear;
      Result.Canvas.Font.Color := TextInverse;
      s := 'x';
      Result.Canvas.TextOut(5, 0, s);
    end;
  end;
end;

procedure TNxTestApp.CreateUserInterface;
var
  i: TNxTestOutcome;
  Bmp: TBitmap;
begin
  if not Assigned(fForm) then
    Exit;
  fFormInitialized := True;

  fImages := TImageList.Create(fForm);
  fImages.ShareImages := True;
  fImages.Width := 16;
  fImages.Height := 16;
  for i := Low(TNxTestOutcome) to High(TNxTestOutcome) do
    begin
      Bmp := StatusBitmap(i);
      fImages.Add(Bmp, nil);
      Bmp.Free;
    end;

  fToolBar := TPanel.Create(fForm);
  fToolBar.Caption := '';
  fToolBar.Align := alTop;
  fToolBar.Height := 44;
  fToolBar.Parent := fForm;
  {$IFDEF VCL_PADDING}
  fToolBar.Padding.Left := 8;
  fToolBar.Padding.Right := 8;
  fToolBar.Padding.Top := 6;
  fToolBar.Padding.Bottom := 6;
  {$ENDIF}

  fRunBtn := TButton.Create(fForm);
  fRunBtn.Align := alLeft;
  fRunBtn.Caption := 'Run All';
  fRunBtn.Parent := fToolBar;
  fRunBtn.Width := 120;
  fRunBtn.OnClick := RunAll;

  fTreeView := TTreeView.Create(fForm);
  fTreeView.Align := alClient;
  fTreeView.Parent := fForm;
//  fTreeView.CheckBoxes := True;
  fTreeView.Images := fImages;

  fStatusBar := TStatusBar.Create(fForm);
  fStatusBar.Align := alBottom;
  fStatusBar.Height := 25;
  fStatusBar.Parent := fForm;
  fStatusBar.SimplePanel := True;

  NxTestRegistry.Discover;

  BuildTreeRecursive(nil, NxTestRegistry.Suite);
  fTreeView.FullExpand;
end;

procedure TNxTestApp.BuildTreeRecursive(aParentNode: TTreeNode; aSuite: INxTestSuite);
var
  lSuiteNode, lNode: TTreeNode;
  lSuite: INxTestSuite;
  lTest: INxTest;
  i: Integer;
begin
  lSuiteNode := fTreeView.Items.AddChild(aParentNode, aSuite.TestName);
  lSuiteNode.ImageIndex := Ord(TestSkip);
  lSuiteNode.SelectedIndex := Ord(TestSkip);
  {$IFDEF GENERICS}
  fTestNodes.AddOrSetValue(aSuite.FullTestName, lSuiteNode);
  {$ENDIF}

  for i := 0 to aSuite.ItemCount - 1 do
  begin
    lTest := aSuite.Test(i);
    if Supports(lTest, INxTestSuite, lSuite) then
      begin
        BuildTreeRecursive(lSuiteNode, lSuite);
      end
    else
      begin
        lNode := fTreeView.Items.AddChild(lSuiteNode, lTest.TestName);
        lNode.ImageIndex := Ord(TestSkip);
        lNode.SelectedIndex := Ord(TestSkip);
        {$IFDEF GENERICS}
        fTestNodes.AddOrSetValue(lTest.FullTestName, lNode);
        {$ENDIF}
      end;
  end;
end;

procedure TNxTestApp.RunAll(Sender: TObject);
begin
  Engine.Runner.RunTests;
end;

procedure TNxTestApp.OnRunStart(const aTest: INxTest; aTotalCount: Integer);
begin
  fStatusBar.SimpleText := 'Running...';
end;

procedure TNxTestApp.OnRunEnds(const aTest: INxTest; const aSummary: INxTestSummary);
begin
  fStatusBar.SimpleText := Format('Completed: %s Duration: %s', [NxTestOutcomeText[aSummary.Outcome], FormatDuration(aSummary.Duration)]);
end;

procedure TNxTestApp.OnSuiteStart(const aTest: INxTest);
begin

end;

procedure TNxTestApp.OnSuiteEnds(const aTest: INxTest; const aSummary: INxTestSummary);
var
  lNode: TTreeNode;
begin
  {$IFDEF GENERICS}
  if fTestNodes.TryGetValue(aTest.FullTestName, lNode) then
    begin
      lNode.ImageIndex := Ord(aSummary.Outcome);
      lNode.SelectedIndex := Ord(aSummary.Outcome);
    end;
  {$ENDIF}
  fTreeView.Invalidate;
  Application.ProcessMessages;
end;

procedure TNxTestApp.OnTestStart(const aTest: INxTest);
begin

end;

procedure TNxTestApp.OnTestEnds(const aTest: INxTest; const aResult: INxTestResult);
var
  lNode: TTreeNode;
begin
  {$IFDEF GENERICS}
  if fTestNodes.TryGetValue(aTest.FullTestName, lNode) then
    begin
      lNode.ImageIndex := Ord(aResult.Outcome);
      lNode.SelectedIndex := Ord(aResult.Outcome);
    end;
  {$ENDIF}
  fTreeView.Invalidate;
  Application.ProcessMessages;
end;

procedure TNxTestApp.OnStatus(const aTest: INxTest; const aStatusMsg: string);
begin

end;

end.
