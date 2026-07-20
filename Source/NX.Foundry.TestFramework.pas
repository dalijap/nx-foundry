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

unit NX.Foundry.TestFramework;

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
  NX.Foundry;

type
  {$IFDEF GENERICS}
  TNxStringArray = TArray<string>;
  {$ELSE}
  TNxStringArray = array of string;
  {$ENDIF}

  TNxTestOutcome = (
    ///	<summary>
    ///	  Initial outcome - test was skipped
    ///	</summary>
    TestSkip,

    ///	<summary>
    ///	  Test passed 
    ///	</summary>
    TestPass,

    ///	<summary>
    ///	  Test had no verifications
    ///	</summary>
    TestEmpty,

    ///	<summary>
    ///	  Ignore test - for ignoring failing tests which cannot be fixed in adequate timeframe
    ///	</summary>
    TestIgnore,

    ///	<summary>
    ///	  Test verification failed
    ///	</summary>
    TestFail,

    ///	<summary>
    ///	  Test raised unexpected exception
    ///	</summary>
    TestError,

    ///	<summary>
    ///	  Test timedout while running
    ///	</summary>
    TestTimeout,

    ///	<summary>
    ///	  Test was incomplete - aborted
    ///	</summary>
    TestIncomplete
    );

  INxTestInfo = interface;
  INxTest = interface;
  INxTestResult = interface;

  TNxTestFilter = function(const aTest: INxTest): Boolean of object;

  INxTestResult = interface
    ['{FD39D82E-AAE9-4B30-BFCF-36546E9CFE5F}']
    function GetInfo: INxTestInfo;
    function GetOutcome: TNxTestOutcome;
    function GetDuration: UInt32;
    function GetExceptionMsg: string;
    function GetStackTrace: string;
    property Info: INxTestInfo read GetInfo;
    property Outcome: TNxTestOutcome read GetOutcome;
    // duration in miliseconds
    property Duration: UInt32 read GetDuration;
    property ExceptionMsg: string read GetExceptionMsg;
    property StackTrace: string read GetStackTrace;
  end;

  INxTestSummary = interface(INxTestResult)
    ['{1163A1E1-54D5-40C1-B705-D954D84093F9}']
    function GetPassed: Integer;
    function GetSkipped: Integer;
    function GetEmpty: Integer;
    function GetIgnored: Integer;
    function GetFailed: Integer;
    function GetErrored: Integer;
    function GetTimedOut: Integer;
    function GetTotal: Integer;
    function GetExecuted: Integer;

    procedure AddResult(const aResult: INxTestResult);
    function Result(aIndex: Integer): INxTestResult;
    function ItemCount: Integer;

    property Passed: Integer read GetPassed;
    property Skipped: Integer read GetSkipped;
    property Empty: Integer read GetEmpty;
    property Ignored: Integer read GetIgnored;
    property Failed: Integer read GetFailed;
    property Errored: Integer read GetErrored;
    property TimedOut: Integer read GetTimedOut;
    property Total: Integer read GetTotal;
    // Total - Skipped
    property Executed: Integer read GetExecuted;
  end;

  INxTestInfo = interface
    ['{872557E6-9BEF-4A3E-B66E-6109475613CC}']
    function GetTestPath: string;
    function GetTestUnitName: string;
    function GetTestClassName: string;
    function GetTestMethodName: string;
    function GetTestName: string;
    function GetFullTestName: string;
    function GetTestClass: TClass;
    property TestPath: string read GetTestPath;
    property TestUnitName: string read GetTestUnitName;
    property TestClassName: string read GetTestClassName;
    property TestMethodName: string read GetTestMethodName;
    property TestName: string read GetTestName;
    property FullTestName: string read GetFullTestName;
    property TestClass: TClass read GetTestClass;
  end;

  INxTest = interface(INxTestInfo)
    ['{BE84487C-2D2A-4531-A66A-9A7EE1FF0E67}']
    procedure Run;
  end;

  INxTestSuite = interface(INxTest)
    ['{B2A70242-6BEB-4C76-B18F-BF5589780DA2}']
    procedure AddTest(const aTest: INxTest);
    procedure AddSuite(const aSuite: INxTestSuite);
    procedure Discover;
    function Test(aIndex: Integer): INxTest;
    function ItemCount: Integer;
    function TotalCount: Integer;
  end;

  INxTestReporter = interface
    ['{ECAF30DA-A9D4-4C82-9E2B-F27887394B9F}']
    // start and end of whole test run
    procedure OnRunStart(const aTest: INxTest; aTotalCount: Integer);
    procedure OnRunEnds(const aTest: INxTest; const aSummary: INxTestSummary);

    // start and end of a test suite
    procedure OnSuiteStart(const aTest: INxTest);
    procedure OnSuiteEnds(const aTest: INxTest; const aSummary: INxTestSummary);

    // start and end of an individual test
    procedure OnTestStart(const aTest: INxTest);
    procedure OnTestEnds(const aTest: INxTest; const aResult: INxTestResult);

    // not implemented yet
    procedure OnStatus(const aTest: INxTest; const aStatusMsg: string);
  end;

  INxTestRunner = interface
    ['{87C56F9F-9031-45AF-A300-9CEF48475B98}']
    function GetDiscoveryMode: Boolean;
    procedure SetDiscoveryMode(aValue: Boolean);
    procedure RunTests(aFilter: TNxTestFilter = nil);
    property DiscoveryMode: Boolean read GetDiscoveryMode write SetDiscoveryMode;
  end;

  INxTestEngine = interface
    ['{DCA9B585-FB45-4CEC-940B-6AAF71B72790}']
    function Runner: INxTestRunner;
    function RunOutcome: TNxTestOutcome;

    procedure AddReporter(const aReporter: INxTestReporter);

    procedure NotifyRunStart(const aTest: INxTest; aTotalCount: Integer);
    procedure NotifyRunEnds(const aTest: INxTest; const aSummary: INxTestSummary);

    procedure NotifySuiteStart(const aTest: INxTest);
    procedure NotifySuiteEnds(const aTest: INxTest; const aSummary: INxTestSummary);

    procedure NotifyTestStart(const aTest: INxTest);
    procedure NotifyTestEnds(const aTest: INxTest; const aResult: INxTestResult);

    procedure NotifyStatus(const aTest: INxTest; const aStatusMsg: string; const aResult: INxTestResult);
  end;


  TNxList = class
  private
    fItems: IInterfaceList;
    function GetCount: Integer;
  public
    constructor Create;
    procedure Clear;
    property Count: Integer read GetCount;
  end;

  TNxTestResultList = class(TNxList)
  private
    function GetItem(Index: Integer): INxTestResult;
  public
    procedure Add(const aItem: INxTestResult);
    property Items[Index: Integer]: INxTestResult read GetItem; default;
  end;

  TNxTestList = class(TNxList)
  private
    function GetItem(Index: Integer): INxTest;
  public
    procedure Add(const aItem: INxTest);
    property Items[Index: Integer]: INxTest read GetItem; default;
  end;

  TNxTestReporterList = class(TNxList)
  private
    function GetItem(Index: Integer): INxTestReporter;
  public
    procedure Add(const aItem: INxTestReporter);
    property Items[Index: Integer]: INxTestReporter read GetItem; default;
  end;


  TNxTestResult = class(TInterfacedObject, INxTestResult)
  protected
    fInfo: INxTestInfo;
    fExceptionMsg: string;
    fStackTrace: string;
    fDuration: UInt32;
    fOutcome: TNxTestOutcome;
    function GetInfo: INxTestInfo;
    function GetOutcome: TNxTestOutcome; virtual;
    function GetDuration: UInt32;
    function GetExceptionMsg: string;
    function GetStackTrace: string;
  public
    constructor Create(const aInfo: INxTestInfo; aOutcome: TNxTestOutcome; aDuration: UInt32; const aExceptionMsg, aStackTrace: string);
    property Info: INxTestInfo read GetInfo;
    property Outcome: TNxTestOutcome read GetOutcome;
    property Duration: UInt32 read GetDuration;
    property ExceptionMsg: string read GetExceptionMsg;
    property StackTrace: string read GetStackTrace;
  end;

  TNxTestSummary = class(TNxTestResult, INxTestSummary)
  protected
    fTestResults: TNxTestResultList;
    fAllTests: Integer;
    fPassed: Integer;
    fSkipped: Integer;
    fEmpty: Integer;
    fIgnored: Integer;
    fFailed: Integer;
    fErrored: Integer;
    fTimedOut: Integer;
    fTotal: Integer;
    function GetOutcome: TNxTestOutcome; override;
    function GetPassed: Integer;
    function GetSkipped: Integer;
    function GetEmpty: Integer;
    function GetIgnored: Integer;
    function GetFailed: Integer;
    function GetErrored: Integer;
    function GetTimedOut: Integer;
    function GetTotal: Integer;
    function GetExecuted: Integer;
  public
    constructor Create(const aInfo: INxTestInfo; aAllTests: Integer);
    destructor Destroy; override;
    procedure AddResult(const aResult: INxTestResult);
    function Result(aIndex: Integer): INxTestResult;
    function ItemCount: Integer;
    property Passed: Integer read GetPassed;
    property Skipped: Integer read GetSkipped;
    property Empty: Integer read GetEmpty;
    property Ignored: Integer read GetIgnored;
    property Failed: Integer read GetFailed;
    property Errored: Integer read GetErrored;
    property TimedOut: Integer read GetTimedOut;
    property Total: Integer read GetTotal;
    property Executed: Integer read GetExecuted;
  end;


  TNxBaseTest = class(TInterfacedObject, INxTest)
  protected
    AutoPool: INxAutoReleasePool;
    fTestMethodName: string;
    fTestName: string;

    function GetTestPath: string; virtual;
    function GetTestUnitName: string;
    function GetTestClassName: string;
    function GetTestMethodName: string;
    function GetTestName: string;
    function GetFullTestName: string; virtual;
    function GetTestClass: TClass;

    procedure SetUp; virtual;
    procedure TearDown; virtual;
    procedure Execute; virtual;
  public
    procedure AfterConstruction; override;
    procedure BeforeDestruction; override;
    procedure Run;
    property TestPath: string read GetTestPath;
    property TestUnitName: string read GetTestUnitName;
    property TestClassName: string read GetTestClassName;
    property TestMethodName: string read GetTestMethodName;
    property TestName: string read GetTestName;
    property FullTestName: string read GetFullTestName;
    property TestClass: TClass read GetTestClass;
  end;

  {$M+}
  TNxTestCase = class(TNxBaseTest)
  protected
    fCodePtr: Pointer;
    procedure Execute; override;
  public
    constructor Create(const aMethodName: string; aCodePtr: Pointer); overload;
    class function Suite: INxTestSuite; virtual;
  end;

  // alias for DUnit TTestCase class
  TTestCase = TNxTestCase;

  TNxTestCaseClass = class of TNxTestCase;

  TNxTestSuite = class(TNxBaseTest, INxTestSuite, INxTest)
  protected
    fTests: TNxTestList;
  public
    constructor Create(const aName: string);
    destructor Destroy; override;
    procedure AddTest(const aTest: INxTest);
    procedure AddSuite(const aSuite: INxTestSuite);
    procedure Discover; virtual;
    function Test(aIndex: Integer): INxTest;
    function ItemCount: Integer;
    function TotalCount: Integer;
  end;

  TNxTestCaseSuite = class(TNxTestSuite)
  protected
    fClass: TNxTestCaseClass;
    fDiscovered: Boolean;
    function GetTestPath: string; override;
  public
    constructor Create(const aClass: TNxTestCaseClass);
    procedure Discover; override;
  end;


  TNxTestRunner = class(TInterfacedObject, INxTestRunner)
  protected
    fEngine: Pointer;
    fFilter: TNxTestFilter;
    fDiscoveryMode: Boolean;
    function GetDiscoveryMode: Boolean;
    procedure SetDiscoveryMode(aValue: Boolean);
    property DiscoveryMode: Boolean read GetDiscoveryMode write SetDiscoveryMode;
    function StackTrace(E: Exception): string;
    procedure InternalSkipTest(const aTest: INxTest; const aSummary: INxTestSummary); virtual;
    procedure InternalRunTest(const aTest: INxTest; const aSummary: INxTestSummary); virtual;
    procedure InternalRunTests(const aSuite: INxTestSuite; const aSummary: INxTestSummary); overload; virtual;
  public
    constructor Create(const aEngine: INxTestEngine); virtual;

    function ShouldRunTest(const aTest: INxTest): Boolean; virtual;
    procedure RunTests(aFilter: TNxTestFilter = nil);

    procedure NotifyRunStart(const aTest: INxTest; aTotalCount: Integer);
    procedure NotifyRunEnds(const aTest: INxTest; const aSummary: INxTestSummary);

    procedure NotifySuiteStart(const aTest: INxTest);
    procedure NotifySuiteEnds(const aTest: INxTest; const aSummary: INxTestSummary);

    procedure NotifyTestStart(const aTest: INxTest);
    procedure NotifyTestEnds(const aTest: INxTest; const aResult: INxTestResult);

    procedure NotifyStatus(const aTest: INxTest; const aStatusMsg: string; const aResult: INxTestResult);
  end;

  TNxTestEngine = class(TInterfacedObject, INxTestEngine)
  protected
    fRunner: INxTestRunner;
    fReporters: TNxTestReporterList;
    fRunOutcome: TNxTestOutcome;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Runner: INxTestRunner;
    function RunOutcome: TNxTestOutcome;
    procedure AddReporter(const aReporter: INxTestReporter);

    procedure NotifyRunStart(const aTest: INxTest; aTotalCount: Integer);
    procedure NotifyRunEnds(const aTest: INxTest; const aSummary: INxTestSummary);

    procedure NotifySuiteStart(const aTest: INxTest);
    procedure NotifySuiteEnds(const aTest: INxTest; const aSummary: INxTestSummary);

    procedure NotifyTestStart(const aTest: INxTest);
    procedure NotifyTestEnds(const aTest: INxTest; const aResult: INxTestResult);

    procedure NotifyStatus(const aTest: INxTest; const aStatusMsg: string; const aResult: INxTestResult);
  end;

  TNxTestRegistry = class
  protected
    fSuite: INxTestSuite;
  public
    constructor Create;
    procedure RegisterTests(const aTestClass: TNxTestCaseClass); overload;
    procedure RegisterTests(const aTest: INxTest); overload;
    procedure RegisterTests(const aSuite: INxTestSuite); overload;
    procedure Discover;
    property Suite: INxTestSuite read fSuite;
  end;

  NxTestRegistry = class
  public
    class procedure RegisterTests(const aTestClass: TNxTestCaseClass); overload; {$IFDEF STATIC} static; {$ENDIF}
    class procedure RegisterTests(const aTest: INxTest); overload; {$IFDEF STATIC} static; {$ENDIF}
    class procedure RegisterTests(const aSuite: INxTestSuite); overload; {$IFDEF STATIC} static; {$ENDIF}
    class procedure Discover; {$IFDEF STATIC} static; {$ENDIF}
  end;

const
  NxExitFail = 1;
  NxTestOutcomeLetter: array[TNxTestOutcome] of string = ('-', '.', '?', 'I', 'F', 'E', 'T', 'A');
  NxTestOutcomeText: array[TNxTestOutcome] of string = ('SKIP', 'PASS', 'EMPTY', 'IGNORE', 'FAIL', 'ERROR', 'TIMEOUT', 'ABORT');

implementation

{$IFDEF REGION}
{$REGION '***** Compatibility *****'}
{$ENDIF}

{$IFNDEF NAMESPACES}
type
  TStopWatch = object
  private
    fStartTimeStamp: UInt32;
    fElapsed: UInt32;
  public
    procedure Reset;
    procedure Start;
    procedure Stop;
    function ElapsedMilliseconds: UInt32;
  end;

// ***** TStopWatch *****

procedure TStopWatch.Reset;
begin
  fElapsed := 0;
end;

procedure TStopWatch.Start;
begin
  fStartTimeStamp := GetTickCount;
end;

procedure TStopWatch.Stop;
begin
  fElapsed := GetTickCount - fStartTimeStamp;
end;

function TStopWatch.ElapsedMilliseconds: UInt32;
begin
  Result := fElapsed;
end;

{$ENDIF}

{$IFDEF REGION}
{$ENDREGION '***** Compatibility *****'}
{$ENDIF}

{$IFDEF REGION}
{$REGION '***** Results *****'}
{$ENDIF}

// ***** TNxTestResult *****

constructor TNxTestResult.Create(const aInfo: INxTestInfo; aOutcome: TNxTestOutcome; aDuration: UInt32; const aExceptionMsg, aStackTrace: string);
begin
  inherited Create;
  fInfo := aInfo;
  fOutcome := aOutcome;
  fDuration := aDuration;
  fExceptionMsg := aExceptionMsg;
  fStackTrace := aStackTrace;
end;

function TNxTestResult.GetInfo: INxTestInfo;
begin
  Result := fInfo
end;

function TNxTestResult.GetDuration: UInt32;
begin
  Result := fDuration;
end;

function TNxTestResult.GetOutcome: TNxTestOutcome;
begin
  Result := fOutcome;
end;

function TNxTestResult.GetExceptionMsg: string;
begin
  Result := fExceptionMsg;
end;

function TNxTestResult.GetStackTrace: string;
begin
  Result := fStackTrace;
end;

// ***** TNxTestSummary *****

constructor TNxTestSummary.Create(const aInfo: INxTestInfo; aAllTests: Integer);
begin
  inherited Create(aInfo, TestSkip, 0, '', '');
  fTestResults := TNxTestResultList.Create;
  fAllTests := aAllTests;
end;

destructor TNxTestSummary.Destroy;
begin
  fTestResults.Free;
  inherited;
end;

function TNxTestSummary.GetPassed: Integer;
begin
  Result := fPassed;
end;

function TNxTestSummary.GetSkipped: Integer;
begin
  Result := fSkipped;
end;

function TNxTestSummary.GetEmpty: Integer;
begin
  Result := fEmpty;
end;

function TNxTestSummary.GetIgnored: Integer;
begin
  Result := fIgnored;
end;

function TNxTestSummary.GetFailed: Integer;
begin
  Result := fFailed;
end;

function TNxTestSummary.GetErrored: Integer;
begin
  Result := fErrored;
end;

function TNxTestSummary.GetTimedOut: Integer;
begin
  Result := fTimedOut;
end;

function TNxTestSummary.GetTotal: Integer;
begin
  Result := fTotal;
end;

function TNxTestSummary.GetExecuted: Integer;
begin
  Result := fTotal - fSkipped;
end;

function TNxTestSummary.GetOutcome: TNxTestOutcome;
begin
  if fTotal <> fAllTests then
    Result := TestIncomplete
  else
  if (fTotal = 0) or (fSkipped = fTotal) then
    Result := TestSkip
  else
  if fTimedOut > 0 then
    Result := TestTimeout
  else
  if fErrored > 0 then
    Result := TestError
  else
  if fFailed > 0 then
    Result := TestFail
  else
  if fIgnored > 0 then
    Result := TestIgnore
  else
  if fEmpty > 0 then
    Result := TestEmpty
  else
    Result := TestPass;
end;

procedure TNxTestSummary.AddResult(const aResult: INxTestResult);
var
  lSummary: INxTestSummary;
begin
  if Supports(aResult, INxTestSummary, lSummary) then
    begin
      Inc(fTotal, lSummary.Total);
      Inc(fDuration, lSummary.Duration);
      Inc(fPassed, lSummary.Passed);
      Inc(fSkipped, lSummary.Skipped);
      Inc(fEmpty, lSummary.Empty);
      Inc(fIgnored, lSummary.Ignored);
      Inc(fFailed, lSummary.Failed);
      Inc(fErrored, lSummary.Errored);
      Inc(fTimedOut, lSummary.TimedOut);
    end
  else
    begin
      Inc(fTotal);
      if aResult = nil then
      begin
        Inc(fSkipped);
        Exit;
      end;

      Inc(fDuration, aResult.Duration);

      case aResult.Outcome of
        TestSkip : Inc(fSkipped);
        TestPass : Inc(fPassed);
        TestEmpty : Inc(fEmpty);
        TestIgnore : Inc(fIgnored);
        TestFail : Inc(fFailed);
        TestError : Inc(fErrored);
        TestTimeout : Inc(fTimedOut);
      end;
    end;
  fTestResults.Add(aResult);
end;

function TNxTestSummary.Result(aIndex: Integer): INxTestResult;
begin
  Result := fTestResults[aIndex];
end;

function TNxTestSummary.ItemCount: Integer;
begin
  Result := fTestResults.Count;
end;

{$IFDEF REGION}
{$ENDREGION '***** Results *****'}
{$ENDIF}

{$IFDEF REGION}
{$REGION '***** Lists *****'}
{$ENDIF}

// ***** TNxList *****

constructor TNxList.Create;
begin
  inherited;
  fItems := TInterfaceList.Create;
end;

procedure TNxList.Clear;
begin
  fItems.Clear;
end;

function TNxList.GetCount: Integer;
begin
  Result := fItems.Count;
end;

// ***** TNxTestResultList *****

procedure TNxTestResultList.Add(const aItem: INxTestResult);
begin
  fItems.Add(aItem);
end;

function TNxTestResultList.GetItem(Index: Integer): INxTestResult;
begin
  Result := fItems[Index] as INxTestResult;
end;

// ***** TNxTestList *****

procedure TNxTestList.Add(const aItem: INxTest);
begin
  fItems.Add(aItem);
end;

function TNxTestList.GetItem(Index: Integer): INxTest;
begin
  Result := fItems[Index] as INxTest;
end;

// ***** TNxTestRepoterList *****

procedure TNxTestReporterList.Add(const aItem: INxTestReporter);
begin
  fItems.Add(aItem);
end;

function TNxTestReporterList.GetItem(Index: Integer): INxTestReporter;
begin
  Result := fItems[Index] as INxTestReporter;
end;

{$IFDEF REGION}
{$ENDREGION '***** Lists *****'}
{$ENDIF}

// Globals
var
  fNxTestRegistry: TNxTestRegistry;

{$IFDEF REGION}
{$REGION '***** Tests/Suites *****'}
{$ENDIF}

type
  // from System
  PMethRec = ^MethRec;
  MethRec = packed record
    recSize: Word;
    methAddr: Pointer;
    nameLen: Byte;
    { nameChars[nameLen]: _AnsiChr }
  end;

function PublishedMethodNames(aClass: TClass): TNxStringArray;
var
  Current: TClass;
  List: TStringList;
  MethodTablePtr: Pointer;
  MethodCount: Word;
  Entry: PMethRec;
  Name: ^ShortString;
  i: Integer;
begin
  Result := nil;
  Entry := nil;
  List := TStringList.Create;
  try
    // ignore duplicate method names - there can be methods with same name in class hierarchy
    List.Duplicates := dupIgnore;
    Current := aClass;
    while Assigned(Current) do
      begin
        // get the pointer to method table
        MethodTablePtr := PPointer(NativeInt(PByte(Current)) + vmtMethodTable)^;
        if Assigned(MethodTablePtr) then
          begin
            MethodCount := PWord(MethodTablePtr)^;
            // get pointer to the first method
            // Entry is accessed only if method count is > 0
            Inc(PWord(MethodTablePtr));
            Entry := MethodTablePtr;
          end
        else
          MethodCount := 0;

        while MethodCount > 0 do
          begin
            Name := @Entry^.nameLen;
            List.Add(string(Name^));
            Dec(MethodCount);
            Entry := Pointer(NativeUInt(PByte(Entry)) + Entry.recSize);
          end;

        Current := Current.ClassParent;
      end;
    SetLength(Result, List.Count);
    for i := 0 to List.Count - 1 do
      Result[i] := List[i];
  finally
    List.Free;
  end;
end;


// ***** TNxBaseTest *****

procedure TNxBaseTest.AfterConstruction;
begin
  inherited;
  AutoPool := NxAutoRelease.NewPool;
end;

procedure TNxBaseTest.BeforeDestruction;
begin
  AutoPool := nil;
  inherited;
end;

procedure TNxBaseTest.SetUp;
begin
end;

procedure TNxBaseTest.TearDown;
begin
end;

procedure TNxBaseTest.Execute;
begin
end;

function TNxBaseTest.GetTestPath: string;
begin
  if GetTestUnitName <> '' then
    Result := GetTestUnitName + '.' + TestClassName
  else
    Result := TestClassName;
end;

function TNxBaseTest.GetTestUnitName: string;
begin
  {$IFDEF RTTIEX}
  Result := UnitName;
  {$ELSE}
  Result := '';
  {$ENDIF}
end;

function TNxBaseTest.GetTestClassName: string;
begin
  Result := ClassName;
end;

function TNxBaseTest.GetTestMethodName: string;
begin
  Result := fTestMethodName;
end;

function TNxBaseTest.GetTestName: string;
begin
  Result := fTestName;
end;

function TNxBaseTest.GetFullTestName: string;
begin
  Result := TestPath + '.' + TestName;
end;

function TNxBaseTest.GetTestClass: TClass;
begin
  Result := ClassType;
end;

procedure TNxBaseTest.Run;
begin
  try
    NxExpect.ClearExpect;
    SetUp;
    Execute;
    if not NxExpect.ExpectCalled then
      NxExpect.FailEmpty;
  finally
    AutoPool.Clear;
    // if SetUp fails, TearDown should still run to do a partial cleanup
    TearDown;
  end;
end;

// ***** TNxTestCase *****

constructor TNxTestCase.Create(const aMethodName: string; aCodePtr: Pointer);
begin
  inherited Create;
  fTestMethodName := aMethodName;
  fTestName := aMethodName;
  fCodePtr := aCodePtr;
end;

procedure TNxTestCase.Execute;
var
  lMth: TNxProcedureMth;
begin
  TMethod(lMth).Code := fCodePtr;
  TMethod(lMth).Data := Self;
  lMth();
end;

class function TNxTestCase.Suite: INxTestSuite;
begin
  Result := TNxTestCaseSuite.Create(Self);
end;

// ***** TNxTestSuite *****

constructor TNxTestSuite.Create(const aName: string);
begin
  inherited Create;
  fTests := TNxTestList.Create;
  fTestName := aName;
end;

destructor TNxTestSuite.Destroy;
begin
  fTests.Free;
  inherited;
end;

procedure TNxTestSuite.AddTest(const aTest: INxTest);
begin
  fTests.Add(aTest);
end;

procedure TNxTestSuite.AddSuite(const aSuite: INxTestSuite);
begin
  fTests.Add(aSuite);
end;

procedure TNxTestSuite.Discover;
var
  lSuite: INxTestSuite;
  lTest: INxTest;
  i: Integer;
begin
  for i := 0 to fTests.Count - 1 do
    begin
      lTest := fTests[i];
      if Supports(lTest, INxTestSuite, lSuite) then
        lSuite.Discover;
    end;
end;

function TNxTestSuite.Test(aIndex: Integer): INxTest;
begin
  Result := fTests[aIndex];
end;

function TNxTestSuite.ItemCount: Integer;
begin
  Result := fTests.Count;
end;

function TNxTestSuite.TotalCount: Integer;
var
  lSuite: INxTestSuite;
  lTest: INxTest;
  i: Integer;
begin
  Result := 0;
  for i := 0 to fTests.Count - 1 do
    begin
      lTest := fTests[i];
      if Supports(lTest, INxTestSuite, lSuite) then
        Result := Result + lSuite.TotalCount
      else
        Inc(Result);
    end;
end;

// ***** TNxTestCaseSuite *****

constructor TNxTestCaseSuite.Create(const aClass: TNxTestCaseClass);
begin
  inherited Create(aClass.ClassName);
  fClass := aClass;
end;

procedure TNxTestCaseSuite.Discover;
var
  lMethods: TNxStringArray;
  lCodePtr: Pointer;
  lTest: INxTest;
  i: Integer;
begin
  if fDiscovered then
    Exit;
  lMethods := PublishedMethodNames(fClass);
  for i := 0 to High(lMethods) do
    begin
      lCodePtr := fClass.MethodAddress(lMethods[i]);
      lTest := fClass.Create(lMethods[i], lCodePtr);
      AddTest(lTest);
    end;
  fDiscovered := True;
end;

function TNxTestCaseSuite.GetTestPath: string;
begin
  Result := fClass.ClassName;
end;

{$IFDEF REGION}
{$ENDREGION '***** Tests/Suites *****'}
{$ENDIF}

{$IFDEF REGION}
{$REGION '***** Runner *****'}
{$ENDIF}

// ***** TNxTestRunner *****

constructor TNxTestRunner.Create(const aEngine: INxTestEngine);
begin
  inherited Create;
  fEngine := Pointer(aEngine);
end;

function TNxTestRunner.GetDiscoveryMode: Boolean;
begin
  Result := fDiscoveryMode;
end;

procedure TNxTestRunner.SetDiscoveryMode(aValue: Boolean);
begin
  fDiscoveryMode := aValue;
end;

function TNxTestRunner.StackTrace(E: Exception): string;
begin
  {$IFDEF STACKTRACE}
  Result := E.StackTrace;
  {$ELSE}
  Result := '';
  {$ENDIF}
end;

function TNxTestRunner.ShouldRunTest(const aTest: INxTest): Boolean;
begin
  if Assigned(fFilter) then
    Result := fFilter(aTest)
  else
    Result := True;
end;

procedure TNxTestRunner.InternalSkipTest(const aTest: INxTest; const aSummary: INxTestSummary);
var
  lResult: INxTestResult;
begin
  NotifyTestStart(aTest);
  lResult := TNxTestResult.Create(aTest, TestSkip, 0, '', '');
  aSummary.AddResult(lResult);
  NotifyTestEnds(aTest, lResult);
end;

procedure TNxTestRunner.InternalRunTest(const aTest: INxTest; const aSummary: INxTestSummary);
var
  sw: TStopwatch;
  lResult: INxTestResult;
  lExceptionMsg: string;
  lStackTrace: string;
  lOutcome: TNxTestOutcome;
begin
  NotifyTestStart(aTest);
  sw.Reset;
  sw.Start;
  try
    aTest.Run;
    lOutcome := TestPass;
  except
    on E: ETestFailure do
      begin
        lOutcome := TestFail;
        lExceptionMsg := E.Message;
        lStackTrace := StackTrace(E);
      end;
    on E: ETestEmpty do
      begin
        lOutcome := TestEmpty;
        lExceptionMsg := E.Message;
        lStackTrace := StackTrace(E);
      end;
    on E: ETestTimeout do
      begin
        lOutcome := TestTimeout;
        lExceptionMsg := E.Message;
        lStackTrace := StackTrace(E);
      end;
    on E: Exception do
      begin
        lOutcome := TestError;
        lExceptionMsg := E.ClassName +': ' + E.Message;
        lStackTrace := StackTrace(E);
      end;
  end;
  sw.Stop;
  lResult := TNxTestResult.Create(aTest, lOutcome, sw.ElapsedMilliseconds, lExceptionMsg, lStackTrace);
  aSummary.AddResult(lResult);
  NotifyTestEnds(aTest, lResult);
end;

procedure TNxTestRunner.InternalRunTests(const aSuite: INxTestSuite; const aSummary: INxTestSummary);
var
  i: Integer;
  lTest: INxTest;
  lSuite: INXTestSuite;
  lSummary: INxTestSummary;
begin
  NotifySuiteStart(aSuite);

  for i := 0 to aSuite.ItemCount - 1 do
    begin
      lTest := aSuite.Test(i);
      if Supports(lTest, INxTestSuite, lSuite) then
        begin
          lSummary := TNxTestSummary.Create(lSuite, lSuite.TotalCount);
          InternalRunTests(lSuite, lSummary);
          aSummary.AddResult(lSummary);
        end
      else
        begin
          if fDiscoveryMode then
            // discovery mode is the same as skipping
            InternalSkipTest(lTest, aSummary)
          else
          if ShouldRunTest(lTest) then
            InternalRunTest(lTest, aSummary)
          else
            InternalSkipTest(lTest, aSummary)
        end;
    end;
  NotifySuiteEnds(aSuite, aSummary);
end;

procedure TNxTestRunner.RunTests(aFilter: TNxTestFilter = nil);
var
  lSummary: INxTestSummary;
  lSuite: INxTestSuite;
begin
  fFilter := aFilter;
  lSuite := fNxTestRegistry.Suite;
  lSuite.Discover;
  lSummary := TNxTestSummary.Create(lSuite, lSuite.TotalCount);
  NotifyRunStart(lSuite, lSuite.TotalCount);
  try
    InternalRunTests(lSuite, lSummary);
  finally
    NotifyRunEnds(lSuite, lSummary);
  end;
end;

procedure TNxTestRunner.NotifyRunStart(const aTest: INxTest; aTotalCount: Integer);
begin
  INxTestEngine(fEngine).NotifyRunStart(aTest, aTotalCount);
end;

procedure TNxTestRunner.NotifyRunEnds(const aTest: INxTest; const aSummary: INxTestSummary);
begin
  INxTestEngine(fEngine).NotifyRunEnds(aTest, aSummary);
end;

procedure TNxTestRunner.NotifySuiteStart(const aTest: INxTest);
begin
  INxTestEngine(fEngine).NotifySuiteStart(aTest);
end;

procedure TNxTestRunner.NotifySuiteEnds(const aTest: INxTest; const aSummary: INxTestSummary);
begin
  INxTestEngine(fEngine).NotifySuiteEnds(aTest, aSummary);
end;

procedure TNxTestRunner.NotifyTestStart(const aTest: INxTest);
begin
  INxTestEngine(fEngine).NotifyTestStart(aTest);
end;

procedure TNxTestRunner.NotifyTestEnds(const aTest: INxTest; const aResult: INxTestResult);
begin
  INxTestEngine(fEngine).NotifyTestEnds(aTest, aResult);
end;

procedure TNxTestRunner.NotifyStatus(const aTest: INxTest; const aStatusMsg: string; const aResult: INxTestResult);
begin
  INxTestEngine(fEngine).NotifyStatus(aTest, aStatusMsg, aResult);
end;

{$IFDEF REGION}
{$ENDREGION '***** Runner *****'}
{$ENDIF}

{$IFDEF REGION}
{$REGION '***** Engine *****'}
{$ENDIF}

// ***** TNxTestEngine *****

constructor TNxTestEngine.Create;
begin
  inherited;
  fReporters := TNxTestReporterList.Create;
  fRunner := TNxTestRunner.Create(Self);
end;

destructor TNxTestEngine.Destroy;
begin
  fReporters.Free;
  inherited;
end;

function TNxTestEngine.Runner: INxTestRunner;
begin
  Result := fRunner;
end;

function TNxTestEngine.RunOutcome: TNxTestOutcome;
begin
  Result := fRunOutcome;
end;

procedure TNxTestEngine.AddReporter(const aReporter: INxTestReporter);
begin
  fReporters.Add(aReporter);
end;

procedure TNxTestEngine.NotifyRunStart(const aTest: INxTest; aTotalCount: Integer);
var
  i: Integer;
begin
  for i := 0 to fReporters.Count - 1 do
    fReporters[i].OnRunStart(aTest, aTotalCount);
end;

procedure TNxTestEngine.NotifyRunEnds(const aTest: INxTest; const aSummary: INxTestSummary);
var
  i: Integer;
begin
  for i := 0 to fReporters.Count - 1 do
    fReporters[i].OnRunEnds(aTest, aSummary);
  fRunOutcome := aSummary.Outcome;
end;

procedure TNxTestEngine.NotifySuiteStart(const aTest: INxTest);
var
  i: Integer;
begin
  for i := 0 to fReporters.Count - 1 do
    fReporters[i].OnSuiteStart(aTest);
end;

procedure TNxTestEngine.NotifySuiteEnds(const aTest: INxTest; const aSummary: INxTestSummary);
var
  i: Integer;
begin
  for i := 0 to fReporters.Count - 1 do
    fReporters[i].OnSuiteEnds(aTest, aSummary);
end;

procedure TNxTestEngine.NotifyTestStart(const aTest: INxTest);
var
  i: Integer;
begin
  for i := 0 to fReporters.Count - 1 do
    fReporters[i].OnTestStart(aTest);
end;

procedure TNxTestEngine.NotifyTestEnds(const aTest: INxTest; const aResult: INxTestResult);
var
  i: Integer;
begin
  for i := 0 to fReporters.Count - 1 do
    fReporters[i].OnTestEnds(aTest, aResult);
end;

procedure TNxTestEngine.NotifyStatus(const aTest: INxTest; const aStatusMsg: string; const aResult: INxTestResult);
var
  i: Integer;
begin
  for i := 0 to fReporters.Count - 1 do
    fReporters[i].OnStatus(aTest, aStatusMsg);
end;

{$IFDEF REGION}
{$ENDREGION '***** Engine *****'}
{$ENDIF}

{$IFDEF REGION}
{$REGION '***** Registry *****'}
{$ENDIF}

// ***** TNxTestRegistry *****

constructor TNxTestRegistry.Create;
begin
  inherited;
  fSuite := TNxTestSuite.Create(ExtractFileName(ParamStr(0)));
end;

procedure TNxTestRegistry.RegisterTests(const aTestClass: TNxTestCaseClass);
begin
  RegisterTests(aTestClass.Suite);
end;

procedure TNxTestRegistry.RegisterTests(const aTest: INxTest);
begin
  fSuite.AddTest(aTest);
end;

procedure TNxTestRegistry.RegisterTests(const aSuite: INxTestSuite);
begin
  fSuite.AddSuite(aSuite);
end;

procedure TNxTestRegistry.Discover;
begin
  fSuite.Discover;
end;

// ***** NxTestRegistry *****

class procedure NxTestRegistry.RegisterTests(const aTestClass: TNxTestCaseClass);
begin
  fNxTestRegistry.RegisterTests(aTestClass);
end;

class procedure NxTestRegistry.RegisterTests(const aTest: INxTest);
begin
  fNxTestRegistry.RegisterTests(aTest);
end;

class procedure NxTestRegistry.RegisterTests(const aSuite: INxTestSuite);
begin
  fNxTestRegistry.RegisterTests(aSuite);
end;

class procedure NxTestRegistry.Discover;
begin
  fNxTestRegistry.Discover;
end;

{$IFDEF REGION}
{$ENDREGION '***** Registry *****'}
{$ENDIF}

initialization

  fNxTestRegistry := TNxTestRegistry.Create;

finalization

  fNxTestRegistry.Free;

end.
