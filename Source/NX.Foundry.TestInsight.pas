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

unit NX.Foundry.TestInsight;

interface

{$O+}
{$W-}

uses
  // TestInsight must be initialized first
  TestInsight.Client,
  Nx.Foundry.TestFramework;

type
  TNxTestInsightEngine = class(TNxTestEngine)
  private
    fClient: ITestInsightClient;
    fSelectedTests: TNxStringArray;
  public
    constructor Create(const BaseUrl: string = DefaultUrl); reintroduce;
    procedure Start; override;
    function TestSelected(const aTest: INxTest): Boolean;
  end;

  TNxTestInsightReporter = class(TInterfacedObject, INxTestReporter)
  private
    fClient: ITestInsightClient;
  public
    constructor Create(const aClient: ITestInsightClient);

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

implementation

{ TNxTestInsightEngine }

constructor TNxTestInsightEngine.Create(const BaseUrl: string);
begin
  inherited Create;
  NxTestRegistry.Discover;
  fClient := TTestInsightRestClient.Create(BaseUrl);
  AddReporter(TNxTestInsightReporter.Create(fClient));
  fRunner.DiscoveryMode := not fClient.Options.ExecuteTests;
  fSelectedTests := fClient.GetTests;
end;

procedure TNxTestInsightEngine.Start;
begin
  Runner.RunTests(TestSelected);
end;

function TNxTestInsightEngine.TestSelected(const aTest: INxTest): Boolean;
begin
  // if selected tests array is empty, treat all tests as selected
  Result := Length(fSelectedTests) = 0;
  if not Result then
    Result := ContainsString(aTest.TestPath + '.' + aTest.TestName, fSelectedTests);
end;

{ TNxTestInsightReporter }

constructor TNxTestInsightReporter.Create(const aClient: ITestInsightClient);
begin
  inherited Create;
  fClient := aClient;
end;

procedure TNxTestInsightReporter.OnRunStart(const aTest: INxTest; aTotalCount: Integer);
begin
  fClient.StartedTesting(aTotalCount);
end;

procedure TNxTestInsightReporter.OnRunEnds(const aTest: INxTest; const aSummary: INxTestSummary);
begin
  fClient.FinishedTesting;
end;

procedure TNxTestInsightReporter.OnSuiteStart(const aTest: INxTest);
begin
end;

procedure TNxTestInsightReporter.OnSuiteEnds(const aTest: INxTest; const aSummary: INxTestSummary);
begin

end;

procedure TNxTestInsightReporter.OnTestStart(const aTest: INxTest);
begin

end;

procedure TNxTestInsightReporter.OnTestEnds(const aTest: INxTest; const aResult: INxTestResult);
var
  lTestResult: TTestInsightResult;
  lResultType: TResultType;
  TestClass: TClass;
begin
  case aResult.Outcome of
    TestSkip : lResultType := TResultType.Skipped;
    TestPass : lResultType := TResultType.Passed;
    TestEmpty : lResultType := TResultType.Warning;
    TestIgnore : lResultType := TResultType.Failed;
    TestFail : lResultType := TResultType.Failed;
    TestError : lResultType := TResultType.Error;
    TestTimeout : lResultType := TResultType.Failed;
    else lResultType := TResultType.Skipped;
  end;

  lTestResult := TTestInsightResult.Create(lResultType, aTest.TestName, aTest.TestClassName);
  lTestResult.ExceptionMessage := aResult.ExceptionMsg;
  lTestResult.Duration := aResult.Duration;
  lTestResult.ClassName := aTest.TestClassName;
  lTestResult.UnitName := aTest.TestUnitName;
  lTestResult.MethodName := aTest.TestMethodName;
  lTestResult.Path := aTest.TestPath;
  fClient.PostResult(lTestResult);
end;

procedure TNxTestInsightReporter.OnStatus(const aTest: INxTest; const aStatusMsg: string);
begin

end;

end.

