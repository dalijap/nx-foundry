program TemplateTests;

{$DEFINE CONSOLE_TESTRUNNER}

{$IFNDEF CONSOLE_TESTRUNNER}
  {$DEFINE GUI_TESTRUNNER}
{$ENDIF }

// {$DEFINE CI}

{$IFDEF CONSOLE_TESTRUNNER}
  {$APPTYPE CONSOLE}
{$ENDIF}

uses
  SysUtils,
  {$IFDEF GUI_TESTRUNNER}
  NX.Foundry.VclEngine,
  {$ENDIF}
  NX.Foundry.Reporters,
  NX.Foundry.TestFramework,
  TemplateSuites;

{$R *.res}

begin
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
  Engine.Start;
end.

