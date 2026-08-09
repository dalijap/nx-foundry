program TemplateTests;

{$DEFINE CONSOLE_TESTRUNNER}

{$IFNDEF TESTINSIGHT}
{$IFNDEF CONSOLE_TESTRUNNER}
  {$DEFINE FMX_TESTRUNNER}
{$ENDIF}
{$ENDIF}

// {$DEFINE CI}

{$IFDEF CONSOLE_TESTRUNNER}
  {$APPTYPE CONSOLE}
{$ENDIF}

uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  NX.Foundry.TestInsight,
  {$ELSE}
  {$IFNDEF CONSOLE_TESTRUNNER}
  {$IFDEF FMX_TESTRUNNER}
  NX.Foundry.FmxEngine,
  {$ELSE}
  NX.Foundry.VclEngine,
  {$ENDIF}
  {$ENDIF}
  {$ENDIF}
  NX.Foundry.Reporters,
  NX.Foundry.TestFramework,
  TemplateSuites in '..\TemplateSuites.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  {$IFDEF TESTINSIGHT}
    Engine := TNxTestInsightEngine.Create;
  {$ELSE}
  {$IFDEF CONSOLE_TESTRUNNER}
    {$IFDEF CI}
    Engine := TNxConsoleTestEngine.Create(False);
    {$ELSE}
    Engine := TNxConsoleTestEngine.Create(True);
    {$ENDIF}
    // add as many reporters as needed
    Engine.AddReporter(TNxConsoleReporter.Create);
  {$ELSE}
    Engine := TNxGuiTestEngine.Create;
    Engine.AddReporter(TNxTestApp.Create);
  {$ENDIF}
  {$ENDIF}
  Engine.Start;
end.

