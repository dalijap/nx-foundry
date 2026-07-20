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

unit NX.Foundry.Reporters;

{$I 'NX.inc'}

interface

uses
  {$IFDEF NAMESPACES}
  System.SysUtils,
  System.Classes,
  System.Contnrs,
  System.Diagnostics,
  {$ELSE}
  Windows,
  SysUtils,
  Classes,
  Contnrs,
  {$ENDIF}
  NX.Foundry.TestFramework;

type
  INxReportBuilder = interface
    ['{5FB22440-F022-45BC-8716-EDBD3D451877}']
    function Open(const aKey: string): INxReportBuilder;
    function OpenArray: INxReportBuilder;
    function Close: INxReportBuilder;
    function Write(const aValue: string): INxReportBuilder; overload;
    function Write(const aKey, aValue: string): INxReportBuilder; overload;
    function Writeln: INxReportBuilder;
    function Indent: INxReportBuilder;
    function Outdent: INxReportBuilder;
    function SaveToString: string;
    procedure SaveToFile(const aFileName: string);
  end;

  TNxBuilderScopeType = (stObject, stArray);
  TNxBuilderScope = record
    Key: string;
    Scope: TNxBuilderScopeType;
  end;

  TNxBaseReportBuilder = class(TInterfacedObject, INxReportBuilder)
  protected
    fValue: string;
    fIndentLevel: Integer;
    fIndentChars: Integer;
    fScopeStack: array of TNxBuilderScope;
    procedure AddIndent;
    procedure RemoveIndent;
    procedure WriteIndent;
    procedure PushScope(aScope: TNxBuilderScopeType; const aKey: string);
    function PopScope: TNxBuilderScope;
  public
    constructor Create; virtual;
    function Open(const aKey: string): INxReportBuilder; virtual;
    function OpenArray: INxReportBuilder; virtual;
    function Close: INxReportBuilder; virtual;
    function Write(const aValue: string): INxReportBuilder; overload; virtual;
    function Write(const aKey, aValue: string): INxReportBuilder; overload; virtual;
    function Writeln: INxReportBuilder;
    function Indent: INxReportBuilder;
    function Outdent: INxReportBuilder;
    function SaveToString: string;
    procedure SaveToFile(const aFileName: string);
  end;

  TNxTextReportBuilder = class(TNxBaseReportBuilder)
  public
    function Write(const aValue: string): INxReportBuilder; override;
    function Write(const aKey, aValue: string): INxReportBuilder; override;
  end;

  TNxJsonReportBuilder = class(TNxBaseReportBuilder)
  public
  end;

  TNxXmlReportBuilder = class(TNxBaseReportBuilder)
  public
  end;


  TNxBaseReporter = class(TInterfacedObject, INxTestReporter)
  public
    procedure OnRunStart(const aTest: INxTest; aTotalCount: Integer); virtual;
    procedure OnRunEnds(const aTest: INxTest; const aSummary: INxTestSummary); virtual;

    procedure OnSuiteStart(const aTest: INxTest); virtual;
    procedure OnSuiteEnds(const aTest: INxTest; const aSummary: INxTestSummary); virtual;

    procedure OnTestStart(const aTest: INxTest); virtual;
    procedure OnTestEnds(const aTest: INxTest; const aResult: INxTestResult); virtual;

    procedure OnStatus(const aTest: INxTest; const aStatusMsg: string); virtual;
  end;

  TNxConsoleReporter = class(TNxBaseReporter)
  private
    fIndex: Integer;
    procedure ReportFailures(const aBuilder: INxReportBuilder; const aSummary: INxTestSummary);
  public
    procedure OnRunStart(const aTest: INxTest; aTotalCount: Integer); override;
    procedure OnRunEnds(const aTest: INxTest; const aSummary: INxTestSummary); override;
    procedure OnTestEnds(const aTest: INxTest; const aResult: INxTestResult); override;
    procedure OnStatus(const aTest: INxTest; const aStatusMsg: string); override;
  end;

  TNxFileReporter = class(TNxBaseReporter)
  private
    fFileName: string;
  public
    constructor Create(const aFileName: string);
  end;

implementation

function SaveStringToFile(const aFileName, aValue: string): Boolean;
var
  f: TFileStream;
  Size: Integer;
  u: UTF8String;
begin
  try
    f := TFileStream.Create(aFileName, fmCreate or fmShareExclusive);
    try
      u := UTF8Encode(aValue);
      Size := Length(u);
      if Size > 0 then
        f.WriteBuffer(u[1], Size);
      Result := True;
    finally
      f.Free;
    end;
  except
    Result := False;
  end;
end;

// ***** TNxBaseReportBuilder *****

constructor TNxBaseReportBuilder.Create;
begin
  inherited;
  fIndentChars := 2;
end;

procedure TNxBaseReportBuilder.AddIndent;
begin
  Inc(fIndentLevel);
end;

procedure TNxBaseReportBuilder.RemoveIndent;
begin
  if fIndentLevel > 0 then
    Dec(fIndentLevel);
end;

procedure TNxBaseReportBuilder.WriteIndent;
begin
  if fIndentLevel > 0 then
    fValue := fValue + StringOfChar(' ', fIndentLevel * fIndentChars);
end;

procedure TNxBaseReportBuilder.PushScope(aScope: TNxBuilderScopeType; const aKey: string);
var
  lScope: TNxBuilderScope;
begin
  lScope.Scope := aScope;
  lScope.Key := '';
  SetLength(fScopeStack, Length(fScopeStack) + 1);
  fScopeStack[High(fScopeStack)] := lScope;
end;

function TNxBaseReportBuilder.PopScope: TNxBuilderScope;
begin
  if Length(fScopeStack) > 0 then
    begin
      Result := fScopeStack[High(fScopeStack)];
      SetLength(fScopeStack, High(fScopeStack));
    end
  else
    begin
      Result.Scope := stObject;
      Result.Key := '';
    end;
end;

function TNxBaseReportBuilder.Close: INxReportBuilder;
begin
  Result := Self;
end;

function TNxBaseReportBuilder.Open(const aKey: string): INxReportBuilder;
begin
  Result := Self;
end;

function TNxBaseReportBuilder.OpenArray: INxReportBuilder;
begin
  Result := Self;
end;

function TNxBaseReportBuilder.Write(const aKey, aValue: string): INxReportBuilder;
begin
  Result := Self;
end;

function TNxBaseReportBuilder.Write(const aValue: string): INxReportBuilder;
begin
  Result := Self;
end;

function TNxBaseReportBuilder.Writeln: INxReportBuilder;
begin
  fValue := fValue + sLineBreak;
  Result := Self;
end;

function TNxBaseReportBuilder.Indent: INxReportBuilder;
begin
  AddIndent;
  Result := Self;
end;

function TNxBaseReportBuilder.Outdent: INxReportBuilder;
begin
  RemoveIndent;
  Result := Self;
end;

function TNxBaseReportBuilder.SaveToString: string;
begin
  Result := fValue;
end;

procedure TNxBaseReportBuilder.SaveToFile(const aFileName: string);
begin
  SaveStringToFile(aFileName, fValue);
end;

// ***** TNxTextReportBuilder *****

function TNxTextReportBuilder.Write(const aKey, aValue: string): INxReportBuilder;
begin
  WriteIndent;
  if aKey = '' then
    fValue := fValue + aValue
  else
    fValue := fValue + aKey + ': ' + aValue;
  Writeln;
  Result := Self;
end;

function TNxTextReportBuilder.Write(const aValue: string): INxReportBuilder;
begin
  WriteIndent;
  fValue := fValue + aValue;
  Writeln;
  Result := Self;
end;

// ***** TNxBaseReporter *****

procedure TNxBaseReporter.OnRunStart(const aTest: INxTest; aTotalCount: Integer);
begin
end;

procedure TNxBaseReporter.OnRunEnds(const aTest: INxTest; const aSummary: INxTestSummary);
begin
end;

procedure TNxBaseReporter.OnSuiteStart(const aTest: INxTest);
begin
end;

procedure TNxBaseReporter.OnSuiteEnds(const aTest: INxTest; const aSummary: INxTestSummary);
begin
end;

procedure TNxBaseReporter.OnTestStart(const aTest: INxTest);
begin
end;

procedure TNxBaseReporter.OnTestEnds(const aTest: INxTest; const aResult: INxTestResult);
begin
end;

procedure TNxBaseReporter.OnStatus(const aTest: INxTest; const aStatusMsg: string);
begin
end;

// ***** TNxConsoleReporter *****

procedure TNxConsoleReporter.ReportFailures(const aBuilder: INxReportBuilder; const aSummary: INxTestSummary);
var
  lResult: INxTestResult;
  lSummary: INxTestSummary;
  i: Integer;
begin
  for i := 0 to aSummary.ItemCount - 1 do
    begin
      lResult := aSummary.Result(i);
      if Supports(lResult, INxTestSummary, lSummary) then
        ReportFailures(aBuilder, lSummary)
      else
      if lResult.Outcome > TestPass then
        begin
          aBuilder
            .Write(NxTestOutcomeText[lResult.Outcome], lResult.Info.FullTestName)
            .Indent
            .Write('', lResult.ExceptionMsg);
          if lResult.StackTrace <> '' then
            aBuilder.Write('', lResult.StackTrace);
          aBuilder
            .Outdent
            .Writeln;
        end;
    end;
end;

procedure TNxConsoleReporter.OnRunStart(const aTest: INxTest; aTotalCount: Integer);
begin
  fIndex := 0;
  Writeln(Format('NX Foundry - Running %d tests: %s', [aTotalCount, aTest.TestName]));
  Writeln;
end;

procedure TNxConsoleReporter.OnRunEnds(const aTest: INxTest; const aSummary: INxTestSummary);
var
  OutcomeMsg: string;
  Builder: INxReportBuilder;
begin
  case aSummary.Outcome of
    TestPass : OutcomeMsg := 'Succesfully completed!';
    TestSkip : OutcomeMsg := 'No tests were executed!';
    TestEmpty : OutcomeMsg := 'Some tests were executed wihtout any verifications!';
    TestFail :  OutcomeMsg := 'Some tests failed!';
    TestError : OutcomeMsg := 'Unexpected error occured!';
    TestTimeout : OutcomeMsg := 'Timeout occured!';
    TestIncomplete : OutcomeMsg := 'Test run was incomplete!';
  end;

  Builder := TNxTextReportBuilder.Create;
  Builder
    .Write('====================================================')
    .Write('                  TEST RUN SUMMARY                  ')
    .Write('====================================================')

    .Indent
    .Write(Format('Outcome:    %s', [NxTestOutcomeText[aSummary.Outcome]]))
    .Write(OutcomeMsg)
    .Outdent
    .Write('----------------------------------------------------')

    .Indent
    .Write(Format('Total:      %d', [aSummary.Total]))
    .Write(Format('Executed:   %d', [aSummary.Executed]))
    .Outdent
    .Write('----------------------------------------------------')

    .Indent
    .Write(Format('Passed:     %d', [aSummary.Passed]))
    .Write(Format('Skipped:    %d', [aSummary.Skipped]))
    .Write(Format('Empty:      %d', [aSummary.Empty]))
    .Write(Format('Ignored:    %d', [aSummary.Ignored]))
    .Write(Format('Failed:     %d', [aSummary.Failed]))
    .Write(Format('Errored:    %d', [aSummary.Errored]))
    .Write(Format('Timed Out:  %d', [aSummary.TimedOut]))
    .Outdent
    .Write('----------------------------------------------------')

    .Indent
    .Write(Format('Total Time: %d ms', [aSummary.Duration]))
    .Outdent
    .Write('====================================================')
    .Writeln;

  if aSummary.Outcome > TestPass then
    ReportFailures(Builder, aSummary);

   Writeln;
   Writeln;
   Writeln(Builder.SaveToString);
end;

procedure TNxConsoleReporter.OnTestEnds(const aTest: INxTest; const aResult: INxTestResult);
begin
  Write(NxTestOutcomeLetter[aResult.Outcome]);
  Inc(fIndex);
  if (fIndex mod 10) = 0 then
    Writeln;
end;

procedure TNxConsoleReporter.OnStatus(const aTest: INxTest; const aStatusMsg: string);
begin
  Writeln;
  Writeln('Status: ', aTest.FullTestName, ' ', aStatusMsg);
end;

// ***** TNxFileReporter *****

constructor TNxFileReporter.Create(const aFileName: string);
begin
  inherited Create;
  fFileName := aFileName;
end;

end.

