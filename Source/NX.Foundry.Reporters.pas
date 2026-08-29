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
    function OpenArray(const aKey: string): INxReportBuilder;
    function Close: INxReportBuilder;
    function Write(const aValue: string): INxReportBuilder; overload;
    function Write(const aKey, aValue: string): INxReportBuilder; overload;
    function Write(const aKey: string; aValue: Boolean): INxReportBuilder; overload;
    function Write(const aKey: string; aValue: Int64): INxReportBuilder; overload;
    function Write(const aKey: string; aValue: Double): INxReportBuilder; overload;
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
    fFirstInScope: array of Boolean;
    fScopeStack: array of TNxBuilderScope;
    fInvariantFormat: TFormatSettings;
    procedure AddIndent;
    procedure RemoveIndent;
    procedure WriteIndent;
    procedure PushFirst;
    procedure PopFirst;
    procedure UpdateFirst;
    function PeekFirst: Boolean;
    procedure PushScope(aScope: TNxBuilderScopeType; const aKey: string);
    function PopScope: TNxBuilderScope;
  public
    constructor Create; virtual;
    function Open(const aKey: string): INxReportBuilder; virtual;
    function OpenArray(const aKey: string): INxReportBuilder; virtual;
    function Close: INxReportBuilder; virtual;
    function Write(const aValue: string): INxReportBuilder; overload; virtual;
    function Write(const aKey, aValue: string): INxReportBuilder; overload; virtual;
    function Write(const aKey: string; aValue: Boolean): INxReportBuilder; overload; virtual;
    function Write(const aKey: string; aValue: Int64): INxReportBuilder; overload; virtual;
    function Write(const aKey: string; aValue: Double): INxReportBuilder; overload; virtual;
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
    function Write(const aKey: string; aValue: Boolean): INxReportBuilder; overload; override;
    function Write(const aKey: string; aValue: Int64): INxReportBuilder; overload; override;
    function Write(const aKey: string; aValue: Double): INxReportBuilder; overload; override;
  end;

  TNxJsonReportBuilder = class(TNxBaseReportBuilder)
  protected
    function EscapeJsonValue(const aValue: string): string;
  public
    function Open(const aKey: string): INxReportBuilder; override;
    function OpenArray(const aKey: string): INxReportBuilder; override;
    function Close: INxReportBuilder; override;
    function Write(const aValue: string): INxReportBuilder; overload; override;
    function Write(const aKey, aValue: string): INxReportBuilder; overload; override;
    function Write(const aKey: string; aValue: Boolean): INxReportBuilder; overload; override;
    function Write(const aKey: string; aValue: Int64): INxReportBuilder; overload; override;
    function Write(const aKey: string; aValue: Double): INxReportBuilder; overload; override;
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
  protected
    fFileName: string;
  public
    constructor Create(const aFileName: string);
  end;

  TNxAIReporter = class(TNxFileReporter)
  protected
    procedure ReportFailures(const aBuilder: INxReportBuilder; const aSummary: INxTestSummary);
  public
    procedure OnRunEnds(const aTest: INxTest; const aSummary: INxTestSummary); override;
  end;

implementation

// ***** TNxBaseReportBuilder *****

constructor TNxBaseReportBuilder.Create;
begin
  inherited;
  fIndentChars := 2;
  fInvariantFormat.CurrencyString := #$00A4;
  fInvariantFormat.CurrencyFormat := 0;
  fInvariantFormat.CurrencyDecimals := 2;
  fInvariantFormat.DateSeparator := '/';
  fInvariantFormat.TimeSeparator := ':';
  fInvariantFormat.ListSeparator := ',';
  fInvariantFormat.ShortDateFormat := 'MM/dd/yyyy';
  fInvariantFormat.LongDateFormat := 'dddd, dd MMMMM yyyy HH:nn:ss';
  fInvariantFormat.TimeAMString := 'AM';
  fInvariantFormat.TimePMString := 'PM';
  fInvariantFormat.ShortTimeFormat := 'HH:nn';
  fInvariantFormat.LongTimeFormat := 'HH:nn:ss';

  fInvariantFormat.ThousandSeparator := ',';
  fInvariantFormat.DecimalSeparator := '.';
  fInvariantFormat.TwoDigitYearCenturyWindow := 50;
  fInvariantFormat.NegCurrFormat := 0;
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

procedure TNxBaseReportBuilder.PushFirst;
begin
  SetLength(fFirstInScope, Length(fFirstInScope) + 1);
  fFirstInScope[High(fFirstInScope)] := True;
end;

procedure TNxBaseReportBuilder.PopFirst;
begin
  if Length(fFirstInScope) > 0 then
    SetLength(fFirstInScope, Length(fFirstInScope) - 1);
end;

function TNxBaseReportBuilder.PeekFirst: Boolean;
begin
  if Length(fFirstInScope) > 0 then
    Result := fFirstInScope[High(fFirstInScope)]
  else
    Result := True;
end;

procedure TNxBaseReportBuilder.UpdateFirst;
begin
  if Length(fFirstInScope) > 0 then
    fFirstInScope[High(fFirstInScope)] := False;
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

function TNxBaseReportBuilder.Open(const aKey: string): INxReportBuilder;
begin
  Result := Self;
end;

function TNxBaseReportBuilder.OpenArray(const aKey: string): INxReportBuilder;
begin
  Result := Self;
end;

function TNxBaseReportBuilder.Close: INxReportBuilder;
begin
  Result := Self;
end;

function TNxBaseReportBuilder.Write(const aValue: string): INxReportBuilder;
begin
  Result := Self;
end;

function TNxBaseReportBuilder.Write(const aKey, aValue: string): INxReportBuilder;
begin
  Result := Self;
end;

function TNxBaseReportBuilder.Write(const aKey: string; aValue: Boolean): INxReportBuilder;
begin
  Result := Self;
end;

function TNxBaseReportBuilder.Write(const aKey: string; aValue: Int64): INxReportBuilder;
begin
  Result := Self;
end;

function TNxBaseReportBuilder.Write(const aKey: string; aValue: Double): INxReportBuilder;
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

function TNxTextReportBuilder.Write(const aValue: string): INxReportBuilder;
begin
  WriteIndent;
  fValue := fValue + aValue;
  Writeln;
  Result := Self;
end;

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

function TNxTextReportBuilder.Write(const aKey: string; aValue: Boolean): INxReportBuilder;
begin
  WriteIndent;
  if aKey = '' then
    fValue := fValue + BoolToStr(aValue, True)
  else
    fValue := fValue + aKey + ': ' + BoolToStr(aValue, True);
  Writeln;
  Result := Self;
end;

function TNxTextReportBuilder.Write(const aKey: string; aValue: Int64): INxReportBuilder;
begin
  WriteIndent;
  if aKey = '' then
    fValue := fValue + IntToStr(aValue)
  else
    fValue := fValue + aKey + ': ' + IntToStr(aValue);
  Writeln;
  Result := Self;
end;

function TNxTextReportBuilder.Write(const aKey: string; aValue: Double): INxReportBuilder;
begin
  WriteIndent;
  if aKey = '' then
    fValue := fValue + FloatToStr(aValue, fInvariantFormat)
  else
    fValue := fValue + aKey + ': ' + FloatToStr(aValue, fInvariantFormat);
  Writeln;
  Result := Self;
end;


// ***** TNxJsonReportBuilder *****

// See https://www.rfc-editor.org/info/rfc8259/
//
//  string = quotation-mark *char quotation-mark
//
//  char = unescaped /
//      escape (
//          %x22 /          ; "    quotation mark  U+0022
//          %x5C /          ; \    reverse solidus U+005C
//          %x2F /          ; /    solidus         U+002F
//          %x62 /          ; b    backspace       U+0008
//          %x66 /          ; f    form feed       U+000C
//          %x6E /          ; n    line feed       U+000A
//          %x72 /          ; r    carriage return U+000D
//          %x74 /          ; t    tab             U+0009
//          %x75 4HEXDIG )  ; uXXXX                U+XXXX

function TNxJsonReportBuilder.EscapeJsonValue(const aValue: string): string;
var
  i: Integer;
begin
  Result := '';
  for i := 1 to Length(aValue) do
    case aValue[i] of
      '"' : Result := Result + '\"';
      '\' : Result := Result + '\\';
      '/' : Result := Result + '\/';
      #8  : Result := Result + '\b';
      #9  : Result := Result + '\t';
      #10 : Result := Result + '\n';
      #12 : Result := Result + '\f';
      #13 : Result := Result + '\r';
    else
      if Ord(aValue[i]) < 32 then
        Result := Result + '\u00' + IntToHex(Ord(aValue[i]), 2)
      else
        Result := Result + aValue[i];
    end;
end;

function TNxJsonReportBuilder.Open(const aKey: string): INxReportBuilder;
begin
  if fValue <> '' then
    begin
      if not PeekFirst then
        fValue := fValue + ',';
      UpdateFirst;
      Writeln;
    end;
  PushFirst;
  PushScope(stObject, aKey);
  WriteIndent;
  if aKey = '' then
    fValue := fValue + '{'
  else
    fValue := fValue + '"' + aKey + '": {';
  AddIndent;
  Result := Self;
end;

function TNxJsonReportBuilder.OpenArray(const aKey: string): INxReportBuilder;
begin
  if fValue <> '' then
    begin
      if not PeekFirst then
        fValue := fValue + ',';
      UpdateFirst;
      Writeln;
    end;
  PushFirst;
  PushScope(stArray, aKey);
  WriteIndent;
  if aKey = '' then
    fValue := fValue + '['
  else
    fValue := fValue + '"' + aKey + '": [';
  AddIndent;
  Result := Self;
end;

function TNxJsonReportBuilder.Close: INxReportBuilder;
var
  lScope: TNxBuilderScope;
begin
  lScope := PopScope;
  PopFirst;
  Writeln;
  RemoveIndent;
  WriteIndent;
  if lScope.Scope = stObject then
    fValue := fValue + '}'
  else
    fValue := fValue + ']';
  Result := Self;
end;

function TNxJsonReportBuilder.Write(const aValue: string): INxReportBuilder;
begin
  if not PeekFirst then
    fValue := fValue + ',';
  UpdateFirst;
  fValue := fValue + aValue;
  Result := Self;
end;

function TNxJsonReportBuilder.Write(const aKey, aValue: string): INxReportBuilder;
begin
  if not PeekFirst then
    fValue := fValue + ',';
  UpdateFirst;
  Writeln;
  WriteIndent;
  fValue := fValue + '"' + aKey + '": "' + EscapeJsonValue(aValue) + '"';
  Result := Self;
end;

function TNxJsonReportBuilder.Write(const aKey: string; aValue: Boolean): INxReportBuilder;
begin
  if not PeekFirst then
    fValue := fValue + ',';
  UpdateFirst;
  if not PeekFirst then
    fValue := fValue + ',';
  Writeln;
  WriteIndent;
  fValue := fValue + '"' + aKey + '": ' + LowerCase(BoolToStr(aValue, True));
  Result := Self;
end;

function TNxJsonReportBuilder.Write(const aKey: string; aValue: Int64): INxReportBuilder;
begin
  if not PeekFirst then
    fValue := fValue + ',';
  UpdateFirst;
  Writeln;
  WriteIndent;
  fValue := fValue + '"' + aKey + '": ' + IntToStr(aValue);
  Result := Self;
end;

function TNxJsonReportBuilder.Write(const aKey: string; aValue: Double): INxReportBuilder;
begin
  if not PeekFirst then
    fValue := fValue + ',';
  UpdateFirst;
  Writeln;
  WriteIndent;
  fValue := fValue + '"' + aKey + '": ' + FloatToStr(aValue, fInvariantFormat);
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
    TestIgnore : OutcomeMsg := 'Some tests were ignored!';
    TestLeak : OutcomeMsg := 'Some tests had memory leaks!';
    TestFail : OutcomeMsg := 'Some tests failed!';
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
    .Write(Format('Leaked:     %d', [aSummary.Leaked]))
    .Write(Format('Failed:     %d', [aSummary.Failed]))
    .Write(Format('Errored:    %d', [aSummary.Errored]))
    .Write(Format('Timed Out:  %d', [aSummary.TimedOut]))
    .Outdent
    .Write('----------------------------------------------------')

    .Indent
    .Write(Format('Total Time: %s', [FormatDuration(aSummary.Duration)]))
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

// ***** TNxAIReporter *****

procedure TNxAIReporter.ReportFailures(const aBuilder: INxReportBuilder; const aSummary: INxTestSummary);
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
            .Open('')
            .Write('name', lResult.Info.FullTestName)
            .Write('status', NxTestOutcomeText[lResult.Outcome])
            .Write('duration', lResult.Duration)
            .Write('message', lResult.ExceptionMsg)
            .Write('stack_trace', lResult.StackTrace)
            .Close
        end;
    end;
end;

procedure TNxAIReporter.OnRunEnds(const aTest: INxTest; const aSummary: INxTestSummary);
var
  Builder: INxReportBuilder;
begin
  Builder := TNxJsonReportBuilder.Create;
  Builder
    .Open('')
    .Open('results')
    .Open('summary')
    .Write('tests', aSummary.Total)
    .Write('passed', aSummary.Passed)
    .Write('skipped', aSummary.Skipped)
    .Write('empty', aSummary.Empty)
    .Write('ignored', aSummary.Ignored)
    .Write('leaked', aSummary.Leaked)
    .Write('failed', aSummary.Failed)
    .Write('errored', aSummary.Errored)
    .Write('timedout', aSummary.TimedOut)
    .Write('duration', aSummary.Duration)
    .Close;

  if aSummary.Outcome > TestPass then
    begin
      Builder.OpenArray('tests');
      ReportFailures(Builder, aSummary);
      Builder.Close;
    end;

  Builder
    .Close
    .Close;

  Builder.SaveToFile(fFileName);
end;

end.

