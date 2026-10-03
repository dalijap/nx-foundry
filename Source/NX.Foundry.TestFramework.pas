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

unit NX.Foundry.TestFramework;

{$I 'NX.inc'}

interface

uses
  {$IFDEF NAMESPACES}
  {$IFDEF GENERICS}
  System.Generics.Collections,
  {$ENDIF}
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
    ///	  Test had memory leaks
    ///	</summary>
    TestLeak,

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

  TNxTestDescriptor = class
  private
    fTestName: string;
    fCategories: TNxStringArray;
  public
    constructor Create(const aTestName: string);
    procedure AddCategory(const aCategory: string);
    procedure AddCategories(const aCategories: array of string);
    property TestName: string read fTestName;
    property Categories: TNxStringArray read fCategories;
  end;

  TNxTestDescriptorList = class
  private
    {$IFDEF GENERICS}
    fItems: TDictionary<string, TNxTestDescriptor>;
    {$ELSE}
    fItems: TStringList;
    {$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;
    function AddTest(const aTestName: string): TNxTestDescriptor;
    function FindTest(const aTestName: string): TNxTestDescriptor;
  end;

  INxTestInfo = interface;
  INxTest = interface;
  INxTestResult = interface;

  INxTestFilter = interface
    ['{FE3D8871-D238-4D22-9CD5-915EB628595F}']
    function Matches(const aTest: INxTest): Boolean;
  end;

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
    function GetLeaked: Integer;
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
    property Leaked: Integer read GetLeaked;
    property Failed: Integer read GetFailed;
    property Errored: Integer read GetErrored;
    property TimedOut: Integer read GetTimedOut;
    property Total: Integer read GetTotal;
    // Total - Skipped
    property Executed: Integer read GetExecuted;
  end;

  INxTestInfo = interface
    ['{872557E6-9BEF-4A3E-B66E-6109475613CC}']
    function GetCategories: TNxStringArray;
    function GetTestPath: string;
    function GetTestUnitName: string;
    function GetTestClassName: string;
    function GetTestMethodName: string;
    function GetTestName: string;
    function GetFullTestName: string;
    function GetTestClass: TClass;
    property Categories: TNxStringArray read GetCategories;
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
    procedure ApplyDescriptor(aDescriptor: TNxTestDescriptor);
    procedure Run;
  end;

  INxTestSuite = interface(INxTest)
    ['{B2A70242-6BEB-4C76-B18F-BF5589780DA2}']
    procedure AddTest(const aTest: INxTest);
    procedure AddSuite(const aSuite: INxTestSuite);
    procedure Discover(aDescriptor: TNxTestDescriptorList);
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
    procedure RunTests(const aFilter: INxTestFilter = nil);
    procedure Cancel;
    property DiscoveryMode: Boolean read GetDiscoveryMode write SetDiscoveryMode;
  end;

  INxTestEngine = interface
    ['{DCA9B585-FB45-4CEC-940B-6AAF71B72790}']
    function Runner: INxTestRunner;

    procedure AddReporter(const aReporter: INxTestReporter);

    procedure Start;

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

  TNxTestFilterList = class(TNxList)
  private
    function GetItem(Index: Integer): INxTestFilter;
  public
    procedure Add(const aItem: INxTestFilter);
    property Items[Index: Integer]: INxTestFilter read GetItem; default;
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
    fLeaked: Integer;
    fFailed: Integer;
    fErrored: Integer;
    fTimedOut: Integer;
    fTotal: Integer;
    function GetOutcome: TNxTestOutcome; override;
    function GetPassed: Integer;
    function GetSkipped: Integer;
    function GetEmpty: Integer;
    function GetIgnored: Integer;
    function GetLeaked: Integer;
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
    property Leaked: Integer read GetLeaked;
    property Failed: Integer read GetFailed;
    property Errored: Integer read GetErrored;
    property TimedOut: Integer read GetTimedOut;
    property Total: Integer read GetTotal;
    property Executed: Integer read GetExecuted;
  end;


  TNxBaseTest = class(TInterfacedObject, INxTest)
  protected
    AutoPool: INxAutoReleasePool;
    fCategories: TNxStringArray;
    fTestMethodName: string;
    fTestName: string;

    function GetCategories: TNxStringArray;
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
    procedure ApplyDescriptor(aDescriptor: TNxTestDescriptor);
    procedure Run;
    property Categories: TNxStringArray read GetCategories;
    property TestPath: string read GetTestPath;
    property TestUnitName: string read GetTestUnitName;
    property TestClassName: string read GetTestClassName;
    property TestMethodName: string read GetTestMethodName;
    property TestName: string read GetTestName;
    property FullTestName: string read GetFullTestName;
    property TestClass: TClass read GetTestClass;
  public
    class function ClassFullTestName(aClass: TClass; aMethod: Pointer): string; overload; {$IFDEF STATIC} static; {$ENDIF}
    class function ClassFullTestName(aClass: TClass; const aMethodName: string): string; overload; {$IFDEF STATIC} static; {$ENDIF}
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
    procedure Discover(aDescriptor: TNxTestDescriptorList); virtual;
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
    procedure Discover(aDescriptor: TNxTestDescriptorList); override;
  end;


  TNxTestRunner = class(TInterfacedObject, INxTestRunner)
  protected
    fEngine: Pointer;
    fFilter: INxTestFilter;
    fDiscoveryMode: Boolean;
    {$IFDEF ATTRIBUTES}[volatile]{$ENDIF}
    fCanceled: Boolean;
    function GetDiscoveryMode: Boolean;
    procedure SetDiscoveryMode(aValue: Boolean);
    property DiscoveryMode: Boolean read GetDiscoveryMode write SetDiscoveryMode;
    function StackTrace(E: Exception): string;
    procedure InvokeTest(const aTest: INxTest; const aSummary: INxTestSummary); virtual;
    procedure InternalSkipTest(const aTest: INxTest; aOutcome: TNxTestOutcome; const aSummary: INxTestSummary); virtual;
    procedure InternalRunTest(const aTest: INxTest; const aSummary: INxTestSummary); virtual;
    procedure InternalRunTests(const aSuite: INxTestSuite; const aSummary: INxTestSummary); overload; virtual;
  public
    constructor Create(const aEngine: INxTestEngine); virtual;

    function ShouldRunTest(const aTest: INxTest): Boolean; virtual;
    procedure RunTests(const aFilter: INxTestFilter = nil);
    procedure Cancel;

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
    procedure DoRunEnds(const aTest: INxTest; const aSummary: INxTestSummary); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Runner: INxTestRunner;
    procedure AddReporter(const aReporter: INxTestReporter);

    procedure Start; virtual;

    procedure NotifyRunStart(const aTest: INxTest; aTotalCount: Integer);
    procedure NotifyRunEnds(const aTest: INxTest; const aSummary: INxTestSummary);

    procedure NotifySuiteStart(const aTest: INxTest);
    procedure NotifySuiteEnds(const aTest: INxTest; const aSummary: INxTestSummary);

    procedure NotifyTestStart(const aTest: INxTest);
    procedure NotifyTestEnds(const aTest: INxTest; const aResult: INxTestResult);

    procedure NotifyStatus(const aTest: INxTest; const aStatusMsg: string; const aResult: INxTestResult);
  end;

  TNxConsoleTestEngine = class(TNxTestEngine)
  protected
    fPause: Boolean;
    procedure DoRunEnds(const aTest: INxTest; const aSummary: INxTestSummary); override;
  public
    constructor Create(aPause: Boolean); reintroduce;
  end;

  TNxTestRegistry = class
  protected
    fSuite: INxTestSuite;
    fConfigList: TNxTestDescriptorList;
    fIgnoredTests: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure RegisterTests(const aTestClass: TNxTestCaseClass); overload;
    procedure RegisterTests(const aTest: INxTest); overload;
    procedure RegisterTests(const aSuite: INxTestSuite); overload;
    procedure CategorizeTest(const aTestClass: TNxTestCaseClass; const aMethodName, aCategory: string); overload;
    procedure CategorizeTest(const aTestClass: TNxTestCaseClass; const aMethodName: string; const aCategories: array of string); overload;
    procedure CategorizeTest(const aTestClass: TNxTestCaseClass; aMethod: Pointer; const aCategory: string); overload;
    procedure CategorizeTest(const aTestClass: TNxTestCaseClass; aMethod: Pointer; const aCategories: array of string); overload;
    procedure CategorizeTests(const aTestClass: TNxTestCaseClass; const aCategory: string); overload;
    procedure CategorizeTests(const aTestClass: TNxTestCaseClass; const aCategories: array of string); overload;
    procedure IgnoreTest(const aTestClass: TNxTestCaseClass; aMethod: Pointer);
    procedure IgnoreTests(const aTestClass: TNxTestCaseClass);
    function IsTestIgnored(const aTestName: string): Boolean;
    procedure Discover;
    property Suite: INxTestSuite read fSuite;
    property ConfigList: TNxTestDescriptorList read fConfigList;
  end;

  NxTestRegistry = class
  public
    class procedure RegisterTests(const aTestClass: TNxTestCaseClass); overload; {$IFDEF STATIC} static; {$ENDIF}
    class procedure RegisterTests(const aTest: INxTest); overload; {$IFDEF STATIC} static; {$ENDIF}
    class procedure RegisterTests(const aSuite: INxTestSuite); overload; {$IFDEF STATIC} static; {$ENDIF}
    class procedure CategorizeTest(const aTestClass: TNxTestCaseClass; aMethod: Pointer; const aCategory: string); overload; {$IFDEF STATIC} static; {$ENDIF}
    class procedure CategorizeTest(const aTestClass: TNxTestCaseClass; aMethod: Pointer; const aCategories: array of string); overload; {$IFDEF STATIC} static; {$ENDIF}
    class procedure CategorizeTests(const aTestClass: TNxTestCaseClass; const aCategory: string); overload; {$IFDEF STATIC} static; {$ENDIF}
    class procedure CategorizeTests(const aTestClass: TNxTestCaseClass; const aCategories: array of string); overload; {$IFDEF STATIC} static; {$ENDIF}
    // Ignores single published test method from a test class
    class procedure IgnoreTest(const aTestClass: TNxTestCaseClass; aMethod: Pointer); {$IFDEF STATIC} static; {$ENDIF}
    // Ignores all published test methods from a test class
    class procedure IgnoreTests(const aTestClass: TNxTestCaseClass); {$IFDEF STATIC} static; {$ENDIF}
    class function IsTestIgnored(const aTestName: string): Boolean; {$IFDEF STATIC} static; {$ENDIF}
    class procedure Discover; {$IFDEF STATIC} static; {$ENDIF}
    class function Suite: INxTestSuite; {$IFDEF STATIC} static; {$ENDIF}
    class function ConfigList: TNxTestDescriptorList; {$IFDEF STATIC} static; {$ENDIF}
  end;

// standalone helper functions
function FormatDuration(aDuration: UInt32): string;
procedure AddString(var aStrings: TNxStringArray; const aValue: string);
procedure AddStrings(var aStrings: TNxStringArray; const aValues: array of string);
procedure AddUniqueString(var aStrings: TNxStringArray; const aValue: string);
procedure AddUniqueStrings(var aStrings: TNxStringArray; const aValues: array of string);
procedure RemoveString(var aStrings: TNxStringArray; const aValue: string);
function ContainsString(aStrings: TNxStringArray; const aValue: string): Boolean;
function SaveStringToFile(const aFileName, aValue: string): Boolean;


const
  NxExitFail = 1;
  NxTestOutcomeLetter: array[TNxTestOutcome] of string = ('-', '.', '?', 'I', 'L', 'F', 'E', 'T', 'A');
  NxTestOutcomeText: array[TNxTestOutcome] of string = ('SKIP', 'PASS', 'EMPTY', 'IGNORE', 'LEAK', 'FAIL', 'ERROR', 'TIMEOUT', 'ABORT');
  NxTestOutcomeDescription: array[TNxTestOutcome] of string = ('Skipped', 'Passed', 'Empty', 'Ignored', 'Leaked', 'Failed', 'Errored', 'Timeout', 'Aborted');

// global engine reference, should be initialized only once at application startup
var
  Engine: INxTestEngine;

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
{$REGION '***** Configuration *****'}
{$ENDIF}

// ***** TNxTestDescriptor *****

constructor TNxTestDescriptor.Create(const aTestName: string);
begin
  fTestName := aTestName;
end;

procedure TNxTestDescriptor.AddCategory(const aCategory: string);
begin
  // skip verifying whether category is unique for speed
  // categories are used only as a flag and duplicates don't have impact on functionality
  AddString(fCategories, aCategory);
end;

procedure TNxTestDescriptor.AddCategories(const aCategories: array of string);
begin
  // skip verifying whether category is unique for speed
  // categories are used only as a flag and duplicates don't have impact on functionality
  AddStrings(fCategories, aCategories);
end;

// ***** TNxTestDescriptorList *****

constructor TNxTestDescriptorList.Create;
begin
  {$IFDEF GENERICS}
  fItems := TObjectDictionary<string, TNxTestDescriptor>.Create([doOwnsValues]);
  {$ELSE}
  fItems := TStringList.Create;
  fItems.Sorted := True;
  {$ENDIF}
end;

destructor TNxTestDescriptorList.Destroy;
{$IFDEF GENERICS}
begin
{$ELSE}
var
  i: Integer;
begin
  for i := fItems.Count - 1 downto 0 do
    fItems.Objects[i].Free;
{$ENDIF}
  fItems.Free;
  inherited;
end;

function TNxTestDescriptorList.AddTest(const aTestName: string): TNxTestDescriptor;
begin
  Result := TNxTestDescriptor.Create(aTestName);
  {$IFDEF GENERICS}
  fItems.Add(aTestName, Result);
  {$ELSE}
  fItems.AddObject(aTestName, Result);
  {$ENDIF}
end;

function TNxTestDescriptorList.FindTest(const aTestName: string): TNxTestDescriptor;
{$IFDEF GENERICS}
begin
  if not fItems.TryGetValue(aTestName, Result) then
    Result := nil;
end;
{$ELSE}
var
  Idx: Integer;
begin
  if fItems.Find(aTestName, Idx) then
    Result := TNxTestDescriptor(fItems.Objects[Idx])
  else
    Result := nil;
end;
{$ENDIF}

{$IFDEF REGION}
{$ENDREGION '***** Configuration *****'}
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

function TNxTestSummary.GetLeaked: Integer;
begin
  Result := fLeaked;
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
  if fLeaked > 0 then
    Result := TestLeak
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
      Inc(fLeaked, lSummary.Leaked);
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
        TestLeak : Inc(fLeaked);
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

// ***** TNxTestFilterList *****

procedure TNxTestFilterList.Add(const aItem: INxTestFilter);
begin
  fItems.Add(aItem);
end;

function TNxTestFilterList.GetItem(Index: Integer): INxTestFilter;
begin
  Result := fItems[Index] as INxTestFilter;
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

function PublishedMethodName(aClass: TClass; aMethod: Pointer): string;
var
  Current: TClass;
  MethodTablePtr: Pointer;
  MethodCount: Word;
  Entry: PMethRec;
  Name: ^ShortString;
begin
  Result := '';
  Entry := nil;
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
          if Entry^.methAddr = aMethod then
            begin
              Result := string(Name^);
              Exit;
            end;
          Dec(MethodCount);
          Entry := Pointer(NativeUInt(PByte(Entry)) + Entry.recSize);
        end;

      Current := Current.ClassParent;
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

function TNxBaseTest.GetCategories: TNxStringArray;
begin
  Result := fCategories;
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

procedure TNxBaseTest.ApplyDescriptor(aDescriptor: TNxTestDescriptor);
begin
  AddStrings(fCategories, aDescriptor.Categories);
end;

procedure TNxBaseTest.Run;
var
  lExpected: ExceptClass;
begin
  try
    NxExpect.ClearExpect;
    NxExpect.ClearThrown;
    SetUp;
    try
      Execute;
      NxExpect.VerifyThrown;
    except
      on E: Exception do
        begin
          lExpected := NxExpect.ExpectedException;
          if (E is NxExpect.FailExceptionClass) or not Assigned(lExpected) then
            raise;
          if E is lExpected then
            NxExpect.DoExpect
          else
            NxExpect.FailThrow(NxExpect.FormatException(lExpected), NxExpect.FormatException(E));
        end;
    end;
    if not NxExpect.ExpectCalled then
      NxExpect.FailEmpty;
  finally
    NxExpect.ClearThrown;
    AutoPool.Clear;
    // if SetUp fails, TearDown should still run to do a partial cleanup
    TearDown;
  end;
end;

class function TNxBaseTest.ClassFullTestName(aClass: TClass; aMethod: Pointer): string;
begin
  {$IFDEF RTTIEX}
  Result := aClass.UnitName + '.' + aClass.ClassName;
  {$ELSE}
  Result := aClass.ClassName;
  {$ENDIF}
  Result := Result + '.' + PublishedMethodName(aClass, aMethod);
end;

class function TNxBaseTest.ClassFullTestName(aClass: TClass; const aMethodName: string): string;
begin
  {$IFDEF RTTIEX}
  Result := aClass.UnitName + '.' + aClass.ClassName;
  {$ELSE}
  Result := aClass.ClassName;
  {$ENDIF}
  Result := Result + '.' + aMethodName;
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

procedure TNxTestSuite.Discover(aDescriptor: TNxTestDescriptorList);
var
  lSuite: INxTestSuite;
  lTest: INxTest;
  i: Integer;
begin
  for i := 0 to fTests.Count - 1 do
    begin
      lTest := fTests[i];
      if Supports(lTest, INxTestSuite, lSuite) then
        lSuite.Discover(aDescriptor);
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

procedure TNxTestCaseSuite.Discover(aDescriptor: TNxTestDescriptorList);
var
  lMethods: TNxStringArray;
  lCodePtr: Pointer;
  lTest: INxTest;
  i: Integer;
  lDescriptor: TNxTestDescriptor;
begin
  if fDiscovered then
    Exit;
  lMethods := PublishedMethodNames(fClass);
  for i := 0 to High(lMethods) do
    begin
      lCodePtr := fClass.MethodAddress(lMethods[i]);
      lTest := fClass.Create(lMethods[i], lCodePtr);
      AddTest(lTest);
      lDescriptor := aDescriptor.FindTest(lTest.FullTestName);
      if Assigned(lDescriptor) then
        lTest.ApplyDescriptor(lDescriptor);
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
    Result := fFilter.Matches(aTest)
  else
    Result := True;
end;

procedure TNxTestRunner.InvokeTest(const aTest: INxTest; const aSummary: INxTestSummary);
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

procedure TNxTestRunner.InternalSkipTest(const aTest: INxTest; aOutcome: TNxTestOutcome; const aSummary: INxTestSummary);
var
  lResult: INxTestResult;
begin
  NotifyTestStart(aTest);
  lResult := TNxTestResult.Create(aTest, aOutcome, 0, '', '');
  aSummary.AddResult(lResult);
  NotifyTestEnds(aTest, lResult);
end;

{$IFDEF ANONYMOUS_METHODS}
procedure TNxTestRunner.InternalRunTest(const aTest: INxTest; const aSummary: INxTestSummary);
begin
  if TThread.CurrentThread.ThreadID = MainThreadID then
    InvokeTest(aTest, aSummary)
  else
    begin
      // give main thread some time to run between tests
      Sleep(10);
      // execute test in the main thread
      TThread.Synchronize(nil,
        procedure
        begin
          InvokeTest(aTest, aSummary);
        end)
    end;
end;
{$ELSE}
procedure TNxTestRunner.InternalRunTest(const aTest: INxTest; const aSummary: INxTestSummary);
begin
  InvokeTest(aTest, aSummary);
end;
{$ENDIF}

procedure TNxTestRunner.InternalRunTests(const aSuite: INxTestSuite; const aSummary: INxTestSummary);
var
  i: Integer;
  lTest: INxTest;
  lSuite: INXTestSuite;
  lSummary: INxTestSummary;
  lResult: INxTestResult;
begin
  NotifySuiteStart(aSuite);

  for i := 0 to aSuite.ItemCount - 1 do
    begin
      if fCanceled then
        begin
          lResult := TNxTestResult.Create(aSuite, TestIncomplete, 0, '', '');
          aSummary.AddResult(lResult);
          Exit;
        end;
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
            InternalSkipTest(lTest, TestSkip, aSummary)
          else
          if ShouldRunTest(lTest) then
            begin
              // test for ignored only after test passes other filters
              // otherwise test results will be polluted with ignored tests
              if NxTestRegistry.IsTestIgnored(lTest.FullTestName) then
                InternalSkipTest(lTest, TestIgnore, aSummary)
              else
                InternalRunTest(lTest, aSummary)
            end
          else
            InternalSkipTest(lTest, TestSkip, aSummary)
        end;
    end;
  NotifySuiteEnds(aSuite, aSummary);
end;

procedure TNxTestRunner.RunTests(const aFilter: INxTestFilter = nil);
var
  lSummary: INxTestSummary;
  lSuite: INxTestSuite;
begin
  fFilter := aFilter;
  lSuite := fNxTestRegistry.Suite;
  lSuite.Discover(fNxTestRegistry.ConfigList);
  lSummary := TNxTestSummary.Create(lSuite, lSuite.TotalCount);
  NotifyRunStart(lSuite, lSuite.TotalCount);
  try
    InternalRunTests(lSuite, lSummary);
  finally
    NotifyRunEnds(lSuite, lSummary);
  end;
end;

procedure TNxTestRunner.Cancel;
begin
  fCanceled := True;
end;

{$IFDEF ANONYMOUS_METHODS}
procedure TNxTestRunner.NotifyRunStart(const aTest: INxTest; aTotalCount: Integer);
begin
  if TThread.CurrentThread.ThreadID = MainThreadID then
    INxTestEngine(fEngine).NotifyRunStart(aTest, aTotalCount)
  else
    TThread.Synchronize(nil,
      procedure
      begin
        INxTestEngine(fEngine).NotifyRunStart(aTest, aTotalCount)
      end);
end;

procedure TNxTestRunner.NotifyRunEnds(const aTest: INxTest; const aSummary: INxTestSummary);
begin
  fCanceled := False;
  if TThread.CurrentThread.ThreadID = MainThreadID then
    INxTestEngine(fEngine).NotifyRunEnds(aTest, aSummary)
  else
    TThread.Synchronize(nil,
      procedure
      begin
        INxTestEngine(fEngine).NotifyRunEnds(aTest, aSummary)
      end);
end;

procedure TNxTestRunner.NotifySuiteStart(const aTest: INxTest);
begin
  if TThread.CurrentThread.ThreadID = MainThreadID then
    INxTestEngine(fEngine).NotifySuiteStart(aTest)
  else
    TThread.Synchronize(nil,
      procedure
      begin
        INxTestEngine(fEngine).NotifySuiteStart(aTest);
      end);
end;

procedure TNxTestRunner.NotifySuiteEnds(const aTest: INxTest; const aSummary: INxTestSummary);
begin
  if TThread.CurrentThread.ThreadID = MainThreadID then
    INxTestEngine(fEngine).NotifySuiteEnds(aTest, aSummary)
  else
    TThread.Synchronize(nil,
      procedure
      begin
        INxTestEngine(fEngine).NotifySuiteEnds(aTest, aSummary);
      end);
end;

procedure TNxTestRunner.NotifyTestStart(const aTest: INxTest);
begin
  if TThread.CurrentThread.ThreadID = MainThreadID then
    INxTestEngine(fEngine).NotifyTestStart(aTest)
  else
    TThread.Synchronize(nil,
      procedure
      begin
        INxTestEngine(fEngine).NotifyTestStart(aTest);
      end);
end;

procedure TNxTestRunner.NotifyTestEnds(const aTest: INxTest; const aResult: INxTestResult);
begin
  if TThread.CurrentThread.ThreadID = MainThreadID then
    INxTestEngine(fEngine).NotifyTestEnds(aTest, aResult)
  else
    TThread.Synchronize(nil,
      procedure
      begin
        INxTestEngine(fEngine).NotifyTestEnds(aTest, aResult);
      end);
end;

procedure TNxTestRunner.NotifyStatus(const aTest: INxTest; const aStatusMsg: string; const aResult: INxTestResult);
begin
  if TThread.CurrentThread.ThreadID = MainThreadID then
    INxTestEngine(fEngine).NotifyStatus(aTest, aStatusMsg, aResult)
  else
    TThread.Synchronize(nil,
      procedure
      begin
        INxTestEngine(fEngine).NotifyStatus(aTest, aStatusMsg, aResult);
      end);
end;

{$ELSE}
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
{$ENDIF}

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

procedure TNxTestEngine.AddReporter(const aReporter: INxTestReporter);
begin
  fReporters.Add(aReporter);
end;

procedure TNxTestEngine.Start;
begin
  fRunner.RunTests;
end;

procedure TNxTestEngine.DoRunEnds(const aTest: INxTest; const aSummary: INxTestSummary);
begin
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
  DoRunEnds(aTest, aSummary);
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


// ***** TNxConsoleTestEngine *****

constructor TNxConsoleTestEngine.Create(aPause: Boolean);
begin
  inherited Create;
  fPause := aPause;
end;

procedure TNxConsoleTestEngine.DoRunEnds(const aTest: INxTest; const aSummary: INxTestSummary);
begin
  inherited;
  // set exit code if not all tests passed
  if aSummary.Outcome <> TestPass then
    ExitCode := NxExitFail;
  if fPause then
    begin
      Writeln('Test run completed. Press ENTER to exit.');
      Readln;
    end;
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
  fConfigList := TNxTestDescriptorList.Create;
  fIgnoredTests := TStringList.Create;
  fIgnoredTests.Sorted := True;
  fIgnoredTests.Duplicates := dupIgnore;
end;

destructor TNxTestRegistry.Destroy;
begin
  fConfigList.Free;
  fIgnoredTests.Free;
  inherited;
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
  fSuite.Discover(fConfigList);
end;

procedure TNxTestRegistry.CategorizeTest(const aTestClass: TNxTestCaseClass; const aMethodName, aCategory: string);
var
  lConfig: TNxTestDescriptor;
  lTestName: string;
begin
  lTestName := aTestClass.ClassFullTestName(aTestClass, aMethodName);
  lConfig := fConfigList.FindTest(lTestName);
  if lConfig = nil then
    lConfig := fConfigList.AddTest(lTestName);
  lConfig.AddCategory(aCategory);
end;

procedure TNxTestRegistry.CategorizeTest(const aTestClass: TNxTestCaseClass; const aMethodName: string; const aCategories: array of string);
var
  lConfig: TNxTestDescriptor;
  lTestName: string;
begin
  lTestName := aTestClass.ClassFullTestName(aTestClass, aMethodName);
  lConfig := fConfigList.FindTest(lTestName);
  if lConfig = nil then
    lConfig := fConfigList.AddTest(lTestName);
  lConfig.AddCategories(aCategories);
end;

procedure TNxTestRegistry.CategorizeTest(const aTestClass: TNxTestCaseClass; aMethod: Pointer; const aCategory: string);
var
  lConfig: TNxTestDescriptor;
  lTestName: string;
begin
  lTestName := aTestClass.ClassFullTestName(aTestClass, aMethod);
  lConfig := fConfigList.FindTest(lTestName);
  if lConfig = nil then
    lConfig := fConfigList.AddTest(lTestName);
  lConfig.AddCategory(aCategory);
end;

procedure TNxTestRegistry.CategorizeTest(const aTestClass: TNxTestCaseClass; aMethod: Pointer; const aCategories: array of string);
var
  lConfig: TNxTestDescriptor;
  lTestName: string;
begin
  lTestName := aTestClass.ClassFullTestName(aTestClass, aMethod);
  lConfig := fConfigList.FindTest(lTestName);
  if lConfig = nil then
    lConfig := fConfigList.AddTest(lTestName);
  lConfig.AddCategories(aCategories);
end;

procedure TNxTestRegistry.CategorizeTests(const aTestClass: TNxTestCaseClass; const aCategory: string);
var
  lMethods: TNxStringArray;
  i: Integer;
begin
  lMethods := PublishedMethodNames(aTestClass);
  for i := 0 to High(lMethods) do
    CategorizeTest(aTestClass, lMethods[i], aCategory);
end;

procedure TNxTestRegistry.CategorizeTests(const aTestClass: TNxTestCaseClass; const aCategories: array of string);
var
  lMethods: TNxStringArray;
  i: Integer;
begin
  lMethods := PublishedMethodNames(aTestClass);
  for i := 0 to High(lMethods) do
    CategorizeTest(aTestClass, lMethods[i], aCategories);
end;

procedure TNxTestRegistry.IgnoreTest(const aTestClass: TNxTestCaseClass; aMethod: Pointer);
begin
  fIgnoredTests.Add(aTestClass.ClassFullTestName(aTestClass, aMethod));
end;

procedure TNxTestRegistry.IgnoreTests(const aTestClass: TNxTestCaseClass);
var
  lMethods: TNxStringArray;
  i: Integer;
begin
  lMethods := PublishedMethodNames(aTestClass);
  for i := 0 to High(lMethods) do
    fIgnoredTests.Add(aTestClass.ClassFullTestName(aTestClass, lMethods[i]));
end;

function TNxTestRegistry.IsTestIgnored(const aTestName: string): Boolean;
var
  Idx: Integer;
begin
  Result := fIgnoredTests.Find(aTestName, Idx);
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

class procedure NxTestRegistry.CategorizeTest(const aTestClass: TNxTestCaseClass; aMethod: Pointer; const aCategory: string);
begin
  fNxTestRegistry.CategorizeTest(aTestClass, aMethod, aCategory);
end;

class procedure NxTestRegistry.CategorizeTest(const aTestClass: TNxTestCaseClass; aMethod: Pointer; const aCategories: array of string);
begin
  fNxTestRegistry.CategorizeTest(aTestClass, aMethod, aCategories);
end;

class procedure NxTestRegistry.CategorizeTests(const aTestClass: TNxTestCaseClass; const aCategory: string);
begin
  fNxTestRegistry.CategorizeTests(aTestClass, aCategory);
end;

class procedure NxTestRegistry.CategorizeTests(const aTestClass: TNxTestCaseClass; const aCategories: array of string);
begin
  fNxTestRegistry.CategorizeTests(aTestClass, aCategories);
end;

class procedure NxTestRegistry.IgnoreTest(const aTestClass: TNxTestCaseClass; aMethod: Pointer);
begin
  fNxTestRegistry.IgnoreTest(aTestClass, aMethod);
end;

class procedure NxTestRegistry.IgnoreTests(const aTestClass: TNxTestCaseClass);
begin
  fNxTestRegistry.IgnoreTests(aTestClass);
end;

class function NxTestRegistry.IsTestIgnored(const aTestName: string): Boolean;
begin
  Result := fNxTestRegistry.IsTestIgnored(aTestName);
end;

class procedure NxTestRegistry.Discover;
begin
  fNxTestRegistry.Discover;
end;

class function NxTestRegistry.Suite: INxTestSuite;
begin
  Result := fNxTestRegistry.Suite;
end;

class function NxTestRegistry.ConfigList: TNxTestDescriptorList;
begin
  Result := fNxTestRegistry.ConfigList;
end;

{$IFDEF REGION}
{$ENDREGION '***** Registry *****'}
{$ENDIF}

function FormatDuration(aDuration: UInt32): string;
var
  h, m, s, ms: UInt32;
begin
  h := aDuration div 3600000;
  aDuration := aDuration mod 3600000;
  m := aDuration div 60000;
  aDuration := aDuration mod 60000;
  s := aDuration div 1000;
  ms := aDuration mod 1000;
  Result := Format('%d:%2d:%2d:%3d', [h, m, s, ms]);
  Result := StringReplace(Result, ' ', '0', [rfReplaceAll]);
end;

procedure AddString(var aStrings: TNxStringArray; const aValue: string);
begin
  SetLength(aStrings, Length(aStrings) + 1);
  aStrings[High(aStrings)] := aValue;
end;

procedure AddStrings(var aStrings: TNxStringArray; const aValues: array of string);
var
  i, n: Integer;
begin
  n := Length(aStrings);
  SetLength(aStrings, n + Length(aValues));
  for i := 0 to High(aValues) do
    aStrings[n + i] := aValues[i];
end;

procedure AddUniqueString(var aStrings: TNxStringArray; const aValue: string);
begin
  if not ContainsString(aStrings, aValue) then
    begin
      SetLength(aStrings, Length(aStrings) + 1);
      aStrings[High(aStrings)] := aValue;
    end;
end;

procedure AddUniqueStrings(var aStrings: TNxStringArray; const aValues: array of string);
var
  i: Integer;
begin
  for i := 0 to High(aValues) do
    AddUniqueString(aStrings, aValues[i]);
end;

procedure RemoveString(var aStrings: TNxStringArray; const aValue: string);
var
  i: Integer;
begin
  for i := 0 to High(aStrings) do
    if aValue = aStrings[i] then
      begin
        if i < High(aStrings) then
          aStrings[i] := aStrings[High(aStrings)];
        SetLength(aStrings, Length(aStrings) - 1);
        Break;
      end;
end;

function ContainsString(aStrings: TNxStringArray; const aValue: string): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to High(aStrings) do
    if aValue = aStrings[i] then
      begin
        Result := True;
        Break;
      end;
end;

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

function LoadStringFromFile(const aFileName: string; var aValue: string): Boolean;
var
  f: TFileStream;
  Size: Integer;
  u: UTF8String;
begin
  aValue := '';
  try
    f := TFileStream.Create(aFileName, fmOpenRead);
    try
      Size := f.Size;
      SetLength(u, Size);
      if Size > 0 then
        f.ReadBuffer(u[1], Size);
      aValue := UTF8Decode(u);
      Result := True;
    finally
      f.Free;
    end;
  except
    Result := False;
  end;
end;

initialization

  fNxTestRegistry := TNxTestRegistry.Create;

finalization

  fNxTestRegistry.Free;

end.
