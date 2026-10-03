unit TemplateSuites;

interface

{$IF CompilerVersion >= 23.0}
  {$DEFINE NAMESPACES}
{$IFEND}

uses
  {$IFDEF NAMESPACES}
  System.SysUtils,
  {$ELSE}
  SysUtils,
  {$ENDIF}
  NX.Foundry,
  NX.Foundry.TestFramework;

type
  EUnexpected = class(Exception);

  TestFoo = class(TNxTestCase)
  published
    procedure TestSuccess;
    procedure TestNone;
    procedure TestFail;
    procedure TestError;
    procedure TestIgnored;
  end;

  TestBar = class(TNxTestCase)
  private
    sut: TObject;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestSut;
    procedure TestPool;
  end;

  TestIgnored = class(TNxTestCase)
  published
    procedure TestIgnoredFirst;
    procedure TestIgnoredSecond;
  end;

implementation

{ TestFoo }

procedure TestFoo.TestSuccess;
var
  ReturnValue: Integer;
begin
  ReturnValue := 5;
  Expect(ReturnValue).EqualTo(5);
end;

procedure TestFoo.TestNone;
var
  ReturnValue: Integer;
begin
  ReturnValue := 5;
end;

procedure TestFoo.TestFail;
var
  ReturnValue: string;
begin
  ReturnValue := 'foo';
  Expect(ReturnValue).EqualTo('abc');
end;

procedure TestFoo.TestIgnored;
begin
  raise EUnexpected.Create('Ignored test');
end;

procedure TestFoo.TestError;
begin
  raise EUnexpected.Create('Something happened');
end;

{ TestBar }

procedure TestBar.SetUp;
begin
  inherited;
  sut := TObject.Create;
end;

procedure TestBar.TearDown;
begin
  sut.Free;
  inherited;
end;

procedure TestBar.TestSut;
begin
  Expect(sut).IsNot.Null;
end;

procedure TestBar.TestPool;
var
  Bar: TObject;
begin
  Bar := TObject.Create;
  AutoPool.Add(Bar);
  Expect(Bar).IsNot.Null;
end;

{ TestIgnored }

procedure TestIgnored.TestIgnoredFirst;
begin
  raise EUnexpected.Create('Ignored test');
end;

procedure TestIgnored.TestIgnoredSecond;
begin
  raise EUnexpected.Create('Ignored test');
end;

initialization

  NxTestRegistry.RegisterTests(TestFoo);
  NxTestRegistry.IgnoreTest(TestFoo, @TestFoo.TestIgnored);
  NxTestRegistry.CategorizeTest(TestFoo, @TestFoo.TestIgnored, 'Ignored');
  NxTestRegistry.CategorizeTest(TestFoo, @TestFoo.TestSuccess, 'Smoke');
  NxTestRegistry.CategorizeTest(TestFoo, @TestFoo.TestFail, 'Long');
  NxTestRegistry.CategorizeTest(TestFoo, @TestFoo.TestNone, 'Empty');
  NxTestRegistry.RegisterTests(TestBar);
  NxTestRegistry.RegisterTests(TestIgnored);
  NxTestRegistry.IgnoreTests(TestIgnored);

end.

