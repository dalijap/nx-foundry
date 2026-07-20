program TemplateTests;

{$DEFINE CONSOLE_RUNNER}

// {$DEFINE CLI}

{$IFDEF CONSOLE_RUNNER}
  {$APPTYPE CONSOLE}
{$ENDIF}

uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  NX.Foundry.TestInsight,
  {$ENDIF }
  NX.Foundry.Reporters,
  NX.Foundry.TestFramework,
  TemplateSuites;

{$R *.res}

var
  Engine: INxTestEngine;
begin
  ReportMemoryLeaksOnShutdown := True;
  {$IFDEF TESTINSIGHT}
  RunRegisteredTests;
  {$ELSE}
  Engine := TNxTestEngine.Create;
  // add as many reporters as needed
  Engine.AddReporter(TNxConsoleReporter.Create);
  // run tests
  Engine.Runner.RunTests;
  // set exit code if not all tests passed
  if Engine.RunOutcome <> TestPass then
    ExitCode := NxExitFail;
  {$IFNDEF CLI}
  Readln;
  {$ENDIF}
  {$ENDIF}
end.
