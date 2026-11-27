unit TemplateAttrSuites;

interface

{$IF CompilerVersion >= 23.0}
  {$DEFINE NAMESPACES}
{$IFEND}

uses
  {$IFDEF NAMESPACES}
  System.SysUtils,
  System.Rtti,
  {$ELSE}
  SysUtils,
  {$ENDIF}
  NX.Foundry,
  NX.Foundry.TestFramework;

type
  EUnexpected = class(Exception);

  Provider = class
  public
    class function AddData(aIndex: Integer): TArray<TValue>; static;
  end;

  TestAttr = class(TNxTestCase)
  public
    class function AddData(aIndex: Integer): TArray<TValue>; static;
    [Test]
    procedure TestNoParams;
    [TestCase(Named, 'Sum 5', 5, 2, 3)]
    [TestCase(5, 2, 3)]
    [TestCase(Named, Parsed, 'Sum 5 Parsed', '5, 2, 3')]
    procedure TestSum(Expected, a, b: Integer);
    [TestCaseProvider(Provider, 'AddData')]
    procedure TestProviderAdd(Expected, a, b: Integer);
    [TestCaseProvider('AddData')]
    procedure TestInternalAdd(Expected, a, b: Integer);
  published
    procedure TestSuccess;
    [Category('Empty')]
    procedure TestNone;
    [Ignore]
    procedure TestIgnored;
  end;

  [Ignore]
  TestAttrIgnored = class(TNxTestCase)
  published
    procedure TestIgnoredFirst;
    procedure TestIgnoredSecond;
  end;

implementation

{ Provider }

class function Provider.AddData(aIndex: Integer): TArray<TValue>;
begin
  Result := nil;
  case aIndex of
    -1 : // returns test case names and length is used to specify number of test cases
      begin
        SetLength(Result, 1);
      end;
    0 :
      begin
        SetLength(Result, 3);
        Result[0] := 10;
        Result[1] := 5;
        Result[2] := 5;
      end;
  end;
end;

{ TestAttr }

procedure TestAttr.TestNoParams;
begin
  ExpectPass;
end;

class function TestAttr.AddData(aIndex: Integer): TArray<TValue>;
begin
  Result := nil;
  case aIndex of
    -1 : // returns test case names and length is used to specify number of test cases
      begin
        SetLength(Result, 3);
        Result[0] := 'First';
        Result[1] := 'Second';
      end;
    0 :
      begin
        SetLength(Result, 3);
        Result[0] := 5;
        Result[1] := 2;
        Result[2] := 3;
      end;
    1 :
      begin
        SetLength(Result, 3);
        Result[0] := 6;
        Result[1] := 3;
        Result[2] := 3;
      end;
  end;
end;

procedure TestAttr.TestSum(Expected, a, b: Integer);
var
  ReturnValue: Integer;
begin
  ReturnValue := a + b;
  Expect(ReturnValue).EqualTo(Expected);
end;

procedure TestAttr.TestProviderAdd(Expected, a, b: Integer);
var
  ReturnValue: Integer;
begin
  ReturnValue := a + b;
  Expect(ReturnValue).EqualTo(Expected);
end;

procedure TestAttr.TestInternalAdd(Expected, a, b: Integer);
var
  ReturnValue: Integer;
begin
  ReturnValue := a + b;
  Expect(ReturnValue).EqualTo(Expected);
end;

procedure TestAttr.TestSuccess;
var
  ReturnValue: Integer;
begin
  ReturnValue := 5;
  Expect(ReturnValue).EqualTo(5);
end;

procedure TestAttr.TestNone;
var
  ReturnValue: Integer;
begin
  ReturnValue := 5;
end;

procedure TestAttr.TestIgnored;
begin
  raise EUnexpected.Create('Ignored test');
end;

{ TestAttrIgnored }

procedure TestAttrIgnored.TestIgnoredFirst;
begin
  raise EUnexpected.Create('Ignored test');
end;

procedure TestAttrIgnored.TestIgnoredSecond;
begin
  raise EUnexpected.Create('Ignored test');
end;

initialization

  NxTestRegistry.RegisterTests(TestAttr);
  NxTestRegistry.RegisterTests(TestAttrIgnored);

end.

