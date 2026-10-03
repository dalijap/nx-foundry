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

unit NX.Foundry;

{$I 'NX.inc'}

interface

// {$DEFINE DUNIT}

uses
  {$IFDEF DUNIT}
  TestFramework,
  {$ENDIF}
  {$IFDEF NAMESPACES}
  System.SysUtils,
  System.Classes,
  System.Contnrs,
  System.DateUtils,
  System.Math;
  {$ELSE}
  Windows,
  SysUtils,
  Classes,
  Contnrs,
  DateUtils,
  Math;
  {$ENDIF}

const
  sHex = '0x';
  sAny = 'any';
  sNil = 'nil';
  sNone = 'none';
  sSeparator = ', ';
  sTestEmpty = '%s%sTest executed wihtout any verifications';
  sTestTimeout = '%s%sTimeout occured';
  sExpectedThrow = '%s%sExpected exception: %s actual: %s';
  sExpectedThrowMessage = '%s%sExpected exception message: %s actual: %s';
  sExpectedNotNil = '%s%sExpected is not: nil actual: nil';
  sExpectedNil = '%s%sExpected: nil actual: %s';
  sExpectedNotEqualTo = '%s%sExpected is not: %s actual: %s';
  sExpectedEqualTo = '%s%sExpected: %s actual: %s';
  sExpectedMemoryNotEqualTo = '%s%sExpected memory content is not equal: %s actual: %s';
  sExpectedMemoryEqualTo = '%s%sExpected memory content is equal: %s actual: %s';
  sExpectedNotSame = '%s%sExpected is not same: %s actual: %s';
  sExpectedSame = '%s%sExpected same: %s actual: %s';
  sExpectedNotDescendantOf = '%s%sExpected not descendant of: %s actual: %s';
  sExpectedDescendantOf = '%s%sExpected descendant of: %s actual: %s';
  sExpectedNotInstanceOf = '%s%sExpected not instance of: %s actual: %s';
  sExpectedInstanceOf = '%s%sExpected instance of: %s actual: %s';

type
  {$IFNDEF DELPHI_2009_UP}
  UInt32 = type Cardinal;
  NativeInt = Integer;
  {$ENDIF}

  INxAutoReleasePool = interface
    procedure Clear;
    procedure Add(aInstance: TObject);
  end;

  NxAutoRelease = class
  public
    class function New(aInstance: TObject): IInterface; {$IFDEF STATIC} static; {$ENDIF}
    class function NewPool: INxAutoReleasePool; {$IFDEF STATIC} static; {$ENDIF}
  end;

  TNxProcedure = TProcedure;
  TNxProcedureMth = procedure of object;

  {$IFDEF ANONYMOUS_METHODS}
  TNxProcedureRef = TProc;
  {$ELSE}
  TNxProcedureRef = IInterface;
  {$ENDIF}

  {$IFDEF ENHANCED_RECORDS}
  TNxAnyProcedure = record
  {$ELSE}
  TNxAnyProcedure = object
  {$ENDIF}
  private
    fMth: TNxProcedureMth;
    fRef: TNxProcedureRef;
    procedure AssignMth(aValue: TNxProcedureMth);
    procedure AssignRef(const aValue: TNxProcedureRef);
  public
    class function NotEqual(const Left, Right: TNxAnyProcedure): Boolean; {$IFDEF STATIC} static; {$ENDIF}
    class function Equal(const Left, Right: TNxAnyProcedure): Boolean; {$IFDEF STATIC} static; {$ENDIF}
    class function Compare(const Left, Right: TNxAnyProcedure): Integer; {$IFDEF STATIC} static; {$ENDIF}

    constructor Create(aValue: TNxProcedure); overload;
    constructor Create(aValue: TNxProcedureMth); overload;
    constructor Create(const aValue: TNxProcedureRef); overload;
    procedure Assign(aValue: TNxProcedure); overload;
    procedure Assign(aValue: TNxProcedureMth); overload;
    procedure Assign(const aValue: TNxProcedureRef); overload;
    function IsAssigned: Boolean;
    procedure Clear;
    procedure Invoke;
    property Mth: TNxProcedureMth read fMth write AssignMth;
    property Ref: TNxProcedureRef read fRef write AssignRef;
  end;

  TNxAnonymousThread = class(TThread)
  private
    fProc: TNxAnyProcedure;
    {$IFNDEF DELPHI_2010_UP}
    fFinished: Boolean;
    {$ENDIF}
  protected
    procedure Execute; override;
  public
    constructor Create(const aProcedure: TNxAnyProcedure); overload;
    constructor Create(aValue: TNxProcedure); overload;
    constructor Create(aValue: TNxProcedureMth); overload;
    constructor Create(const aValue: TNxProcedureRef); overload;
    {$IFNDEF DELPHI_2010_UP}
    procedure Start;
    property Finished: Boolean read fFinished;
    class function GetTickCount: Cardinal;
    {$ENDIF}
  end;

  /// <summary>
  /// Exception class raised when test had no assertions.
  /// </summary
  ETestEmpty = class(EAbort);

  /// <summary>
  /// Default exception class raised when an assertion fails.
  /// </summary
  {$IFDEF DUNIT}
  ETestFailure = TestFramework.ETestFailure;
  {$ELSE}
  ETestFailure = class(EAbort);
  {$ENDIF}

  /// <summary>
  /// Exception class raised when test timedout.
  /// </summary
  ETestTimeout = class(EAbort);

  /// <summary>
  /// <para>
  /// Helper class used by testing framework itself for handling test verifications and failing the test.
  /// </para>
  /// </summary>
  NxExpect = class
  public
    // mandatory initialization FailException class
    class procedure Init(aEmptyException, aFailException, aTimeoutException: ExceptClass); {$IFDEF STATIC} static; {$ENDIF}
    class function EmptyExceptionClass: ExceptClass; {$IFDEF STATIC} static; {$ENDIF}
    class function FailExceptionClass: ExceptClass; {$IFDEF STATIC} static; {$ENDIF}
    class function TimeoutExceptionClass: ExceptClass; {$IFDEF STATIC} static; {$ENDIF}

    // verification for empty tests
    class procedure ClearExpect; {$IFDEF STATIC} static; {$ENDIF}
    class procedure DoExpect; {$IFDEF STATIC} static; {$ENDIF}
    class function ExpectCalled: Boolean; {$IFDEF STATIC} static; {$ENDIF}

    // expected exceptions
    class procedure ClearThrown; {$IFDEF STATIC} static; {$ENDIF}
    class procedure VerifyThrown(const Msg: string = ''); overload; {$IFDEF STATIC} static; {$ENDIF}
    class procedure ExpectThrows(const Expected: ExceptClass); {$IFDEF STATIC} static; {$ENDIF}
    class function ExpectedException: ExceptClass; {$IFDEF STATIC} static; {$ENDIF}

    // formatting
    class function FormatClass(Value: TClass): string; {$IFDEF STATIC} static; {$ENDIF}
    class function FormatException(Value: TClass): string; overload; {$IFDEF STATIC} static; {$ENDIF}
    class function FormatException(Value: TObject): string; overload; {$IFDEF STATIC} static; {$ENDIF}
    class function FormatObject(Value: TObject): string; {$IFDEF STATIC} static; {$ENDIF}
    class function FormatPointer(Value: Pointer): string; {$IFDEF STATIC} static; {$ENDIF}

    // raising fail test exceptions
    class procedure Fail(const Msg: string); {$IFDEF STATIC} static; {$ENDIF}
    class procedure FailEmpty(const Msg: string = ''); {$IFDEF STATIC} static; {$ENDIF}
    class procedure FailTimeout(const Msg: string = ''); {$IFDEF STATIC} static; {$ENDIF}
    class procedure FailThrow(const Actual, Expected: string; const Msg: string = ''); {$IFDEF STATIC} static; {$ENDIF}
    class procedure FailThrowMessage(const Actual, Expected: string; const Msg: string = ''); {$IFDEF STATIC} static; {$ENDIF}
    class procedure FailNull(IsNot: Boolean; Actual: Pointer; const Msg: string = ''); {$IFDEF STATIC} static; {$ENDIF}
    class procedure FailEqualTo(IsNot: Boolean; const Actual, Expected: string; const Msg: string = ''); {$IFDEF STATIC} static; {$ENDIF}
    class procedure FailEqualToMemory(IsNot: Boolean; Actual, Expected: Pointer; const Msg: string = ''); {$IFDEF STATIC} static; {$ENDIF}
    class procedure FailSame(IsNot: Boolean; Actual, Expected: Pointer; const Msg: string = ''); {$IFDEF STATIC} static; {$ENDIF}
    class procedure FailDescendantOf(IsNot: Boolean; Actual: TObject; aClass: TClass; const Msg: string = ''); {$IFDEF STATIC} static; {$ENDIF}
    class procedure FailInstanceOf(IsNot: Boolean; Actual: TObject; aClass: TClass; const Msg: string = ''); {$IFDEF STATIC} static; {$ENDIF}
  end;

  IExpectBase = interface
    ['{26E8FB29-93D9-441B-A93A-45D1DB8F94DB}']
    function GetObj: TObject;
    property Obj: TObject read GetObj;
  end;

  IExpectProcedure = interface
    function DoesNot: IExpectProcedure;
    function Throw(const ExpectedException: TClass; const Msg: string = ''): IExpectProcedure;
    function ThrowAny(const Msg: string = ''): IExpectProcedure;
  end;

  TExpectBase = class(TInterfacedObject, IExpectBase)
  protected
    fNot: Boolean;
    function GetObj: TObject;
  public
    property Obj: TObject read GetObj;
  end;

  TExpectProc = class(TExpectBase, IExpectProcedure)
  private
    fValue: TNxAnyProcedure;
  public
    constructor Create(Value: TNxProcedure); overload;
    constructor Create(Value: TNxProcedureMth); overload;
    constructor Create(const Value: TNxProcedureRef); overload;
    function DoesNot: IExpectProcedure;
    function Throw(const ExpectedException: TClass; const Msg: string = ''): IExpectProcedure;
    function ThrowAny(const Msg: string = ''): IExpectProcedure;
  end;

  IExpectBoolean = interface
    function IsNot: IExpectBoolean;
    function EqualTo(const Expected: Boolean; const Msg: string = ''): IExpectBoolean;
    function IsFalse(const Msg: string = ''): IExpectBoolean;
    function IsTrue(const Msg: string = ''): IExpectBoolean;
  end;

  TExpectBoolean = class(TExpectBase, IExpectBoolean)
  private
    fValue: Boolean;
  public
    constructor Create(const Value: Boolean);
    function IsNot: IExpectBoolean;
    function EqualTo(const Expected: Boolean; const Msg: string = ''): IExpectBoolean;
    function IsFalse(const Msg: string = ''): IExpectBoolean;
    function IsTrue(const Msg: string = ''): IExpectBoolean;
  end;

  IExpectInt32 = interface
    function IsNot: IExpectInt32;
    function EqualTo(const Expected: Integer; const Msg: string = ''): IExpectInt32;
  end;

  TExpectInt32 = class(TExpectBase, IExpectInt32)
  private
    fValue: Integer;
  public
    constructor Create(const Value: Integer);
    function IsNot: IExpectInt32;
    function EqualTo(const Expected: Integer; const Msg: string = ''): IExpectInt32;
  end;

  IExpectUInt32 = interface
    function IsNot: IExpectUInt32;
    function EqualTo(const Expected: UInt32; const Msg: string = ''): IExpectUInt32;
  end;

  TExpectUInt32 = class(TExpectBase, IExpectUInt32)
  private
    fValue: UInt32;
  public
    constructor Create(const Value: UInt32);
    function IsNot: IExpectUInt32;
    function EqualTo(const Expected: UInt32; const Msg: string = ''): IExpectUInt32;
  end;

  IExpectInt64 = interface
    function IsNot: IExpectInt64;
    function EqualTo(const Expected: Int64; const Msg: string = ''): IExpectInt64;
  end;

  TExpectInt64 = class(TExpectBase, IExpectInt64)
  private
    fValue: Int64;
  public
    constructor Create(const Value: Int64);
    function IsNot: IExpectInt64;
    function EqualTo(const Expected: Int64; const Msg: string = ''): IExpectInt64;
  end;

  IExpectUInt64 = interface
    function IsNot: IExpectUInt64;
    function EqualTo(const Expected: UInt64; const Msg: string = ''): IExpectUInt64;
  end;

  TExpectUInt64 = class(TExpectBase, IExpectUInt64)
  private
    fValue: UInt64;
  public
    constructor Create(const Value: UInt64);
    function IsNot: IExpectUInt64;
    function EqualTo(const Expected: UInt64; const Msg: string = ''): IExpectUInt64;
  end;

  IExpectCurrency = interface
    function IsNot: IExpectCurrency;
    function EqualTo(const Expected: Currency; const Msg: string = ''): IExpectCurrency;
  end;

  TExpectCurrency = class(TExpectBase, IExpectCurrency)
  private
    fValue: Currency;
  public
    constructor Create(const Value: Currency);
    function IsNot: IExpectCurrency;
    function EqualTo(const Expected: Currency; const Msg: string = ''): IExpectCurrency;
  end;

  IExpectSingle = interface
    function IsNot: IExpectSingle;
    function EqualTo(const Expected: Single; const Msg: string = ''): IExpectSingle; overload;
    function EqualTo(const Expected: Single; Epsilon: Double; const Msg: string = ''): IExpectSingle; overload;
  end;

  TExpectSingle = class(TExpectBase, IExpectSingle)
  private
    fValue: Single;
  public
    constructor Create(const Value: Single);
    function IsNot: IExpectSingle;
    function EqualTo(const Expected: Single; const Msg: string = ''): IExpectSingle; overload;
    function EqualTo(const Expected: Single; Epsilon: Double; const Msg: string = ''): IExpectSingle; overload;
  end;

  IExpectDouble = interface
    function IsNot: IExpectDouble;
    function EqualTo(const Expected: Double; const Msg: string = ''): IExpectDouble; overload;
    function EqualTo(const Expected, Epsilon: Double; const Msg: string = ''): IExpectDouble; overload;
  end;

  TExpectDouble = class(TExpectBase, IExpectDouble)
  private
    fValue: Double;
  public
    constructor Create(const Value: Double);
    function IsNot: IExpectDouble;
    function EqualTo(const Expected: Double; const Msg: string = ''): IExpectDouble; overload;
    function EqualTo(const Expected, Epsilon: Double; const Msg: string = ''): IExpectDouble; overload;
  end;

  IExpectDateTime = interface
    function IsNot: IExpectDateTime;
    function EqualTo(const Expected: TDateTime; const Msg: string = ''): IExpectDateTime;
  end;

  TExpectDateTime = class(TExpectBase, IExpectDateTime)
  private
    fValue: TDateTime;
  public
    constructor Create(const Value: TDateTime);
    function IsNot: IExpectDateTime;
    function EqualTo(const Expected: TDateTime; const Msg: string = ''): IExpectDateTime;
  end;

  IExpectChar = interface
    function IsNot: IExpectChar;
    function EqualTo(const Expected: Char; const Msg: string = ''): IExpectChar;
  end;

  TExpectChar = class(TExpectBase, IExpectChar)
  private
    fValue: Char;
  public
    constructor Create(const Value: Char);
    function IsNot: IExpectChar;
    function EqualTo(const Expected: Char; const Msg: string = ''): IExpectChar;
  end;

  IExpectString = interface
    function IsNot: IExpectString;
    function EqualTo(const Expected: string; const Msg: string = ''): IExpectString;
    function Empty(const Msg: string = ''): IExpectString;
  end;

  TExpectString = class(TExpectBase, IExpectString)
  private
    fValue: string;
  public
    constructor Create(const Value: string);
    function IsNot: IExpectString;
    function EqualTo(const Expected: string; const Msg: string = ''): IExpectString;
    function Empty(const Msg: string = ''): IExpectString;
  end;

  IExpectUtf8String = interface
    function IsNot: IExpectUtf8String;
    function EqualTo(const Expected: UTF8String; const Msg: string = ''): IExpectUtf8String;
    function Empty(const Msg: string = ''): IExpectUtf8String;
  end;

  TExpectUtf8String = class(TExpectBase, IExpectUtf8String)
  private
    fValue: UTF8String;
  public
    constructor Create(const Value: UTF8String);
    function IsNot: IExpectUtf8String;
    function EqualTo(const Expected: UTF8String; const Msg: string = ''): IExpectUtf8String;
    function Empty(const Msg: string = ''): IExpectUtf8String;
  end;

  IExpectAnsiString = interface
    function IsNot: IExpectAnsiString;
    function EqualTo(const Expected: AnsiString; const Msg: string = ''): IExpectAnsiString;
    function Empty(const Msg: string = ''): IExpectAnsiString;
  end;

  TExpectAnsiString = class(TExpectBase, IExpectAnsiString)
  private
    fValue: AnsiString;
  public
    constructor Create(const Value: AnsiString);
    function IsNot: IExpectAnsiString;
    function EqualTo(const Expected: AnsiString; const Msg: string = ''): IExpectAnsiString;
    function Empty(const Msg: string = ''): IExpectAnsiString;
  end;

  IExpectWideString = interface
    function IsNot: IExpectWideString;
    function EqualTo(const Expected: WideString; const Msg: string = ''): IExpectWideString;
    function Empty(const Msg: string = ''): IExpectWideString;
  end;

  TExpectWideString = class(TExpectBase, IExpectWideString)
  private
    fValue: WideString;
  public
    constructor Create(const Value: WideString);
    function IsNot: IExpectWideString;
    function EqualTo(const Expected: WideString; const Msg: string = ''): IExpectWideString;
    function Empty(const Msg: string = ''): IExpectWideString;
  end;

  IExpectObject = interface
    function IsNot: IExpectObject;
    function Null(const Msg: string = ''): IExpectObject;
    function Same(const Expected: TObject; const Msg: string = ''): IExpectObject;
    function InstanceOf(const aClass: TClass; const Msg: string = ''): IExpectObject;
    function DescendantOf(const aClass: TClass; const Msg: string = ''): IExpectObject;
  end;

  TExpectObject = class(TExpectBase, IExpectObject)
  private
    fValue: TObject;
  public
    constructor Create(const Value: TObject);
    function IsNot: IExpectObject;
    function Null(const Msg: string = ''): IExpectObject;
    function Same(const Expected: TObject; const Msg: string = ''): IExpectObject;
    function InstanceOf(const aClass: TClass; const Msg: string = ''): IExpectObject;
    function DescendantOf(const aClass: TClass; const Msg: string = ''): IExpectObject;
  end;

  IExpectInterface = interface
    function IsNot: IExpectInterface;
    function Null(const Msg: string = ''): IExpectInterface;
    function Same(const Expected: IInterface; const Msg: string = ''): IExpectInterface;
  end;

  TExpectInterface = class(TExpectBase, IExpectInterface)
  private
    fValue: IInterface;
  public
    constructor Create(const Value: IInterface);
    function IsNot: IExpectInterface;
    function Null(const Msg: string = ''): IExpectInterface;
    function Same(const Expected: IInterface; const Msg: string = ''): IExpectInterface;
  end;

  IExpectMemory = interface
    function IsNot: IExpectMemory;
    function EqualTo(const Expected: Pointer; Size: NativeInt; const Msg: string = ''): IExpectMemory;
  end;

  TExpectMemory = class(TExpectBase, IExpectMemory)
  private
    fValue: Pointer;
  public
    constructor Create(const Value: Pointer);
    function IsNot: IExpectMemory;
    function EqualTo(const Expected: Pointer; Size: NativeInt; const Msg: string = ''): IExpectMemory;
  end;

{$IFDEF GENERICS}
  IExpectValueType<T: record> = interface
    function IsNot: IExpectValueType<T>;
    function EqualTo(const Expected: T; const Msg: string = ''): IExpectValueType<T>;
  end;

  TExpectValueType<T: record> = class(TExpectBase, IExpectValueType<T>)
  private
    fValue: T;
  public
    constructor Create(const Value: T);
    function IsNot: IExpectValueType<T>;
    function EqualTo(const Expected: T; const Msg: string = ''): IExpectValueType<T>;
  end;

  // generics support
  ExpectT = class
  public
    class function Actual<T: record>(const aActual: T): IExpectValueType<T>; {$IFDEF STATIC} static; {$ENDIF}
  end;
{$ENDIF}

// standalone Expect functions
// not organized within a class to allow custom extensions which follow the same syntax

procedure ExpectThrows(const Expected: ExceptClass);
function ExpectProcedure(const Proc: TNxProcedure): IExpectProcedure; overload;
function ExpectProcedure(const Proc: TNxProcedureMth): IExpectProcedure; overload;
{$IFDEF ANONYMOUS_METHODS}
function ExpectProcedure(const Proc: TNxProcedureRef): IExpectProcedure; overload;
{$ENDIF}
function Expect(const Actual: Boolean): IExpectBoolean; overload;
function Expect(const Actual: Integer): IExpectInt32; overload;
function Expect(const Actual: UInt32): IExpectUInt32; overload;
function Expect(const Actual: Int64): IExpectInt64; overload;
function Expect(const Actual: UInt64): IExpectUInt64; overload;
function Expect(const Actual: Single): IExpectSingle; overload;
function Expect(const Actual: Double): IExpectDouble; overload;
{$IFDEF DELPHI_XE_UP}
function Expect(const Actual: TDateTime): IExpectDateTime; overload;
function Expect(const Actual: Currency): IExpectCurrency; overload;
{$ENDIF}
function ExpectDateTime(const Actual: TDateTime): IExpectDateTime; overload;
function ExpectCurrency(const Actual: Currency): IExpectCurrency; overload;
function Expect(const Actual: Char): IExpectChar; overload;
function Expect(const Actual: string): IExpectString; overload;
{$IFDEF UNICODE}
function Expect(const Actual: UTF8String): IExpectUtf8String; overload;
function Expect(const Actual: AnsiString): IExpectAnsiString; overload;
function Expect(const Actual: WideString): IExpectWideString; overload;
{$ENDIF}
function ExpectUtf8String(const Actual: UTF8String): IExpectUtf8String; overload;
function ExpectAnsiString(const Actual: AnsiString): IExpectAnsiString; overload;
function ExpectWideString(const Actual: WideString): IExpectWideString; overload;
function Expect(const Actual: TObject): IExpectObject; overload;
function Expect(const Actual: IInterface): IExpectInterface; overload;

// Runs code in background thread and waits for completion.
// If aFail is set raise timeout exception with additional aMsg

function RunAsync(const aProcedure: TNxAnyProcedure; aTimeout: UInt32 = 30000; aFail: Boolean = True; const aMsg: string = ''): Boolean; overload;
function RunAsync(const aProcedures: array of TNxAnyProcedure; aTimeout: UInt32 = 30000; aFail: Boolean = True; const aMsg: string = ''): Boolean; overload;
{$IFDEF ANONYMOUS_METHODS}
function RunAsync(const aProcedure: TNxProcedureRef; aTimeout: UInt32 = 30000; aFail: Boolean = True; const aMsg: string = ''): Boolean; overload;
function RunAsync(const aProcedures: array of TNxProcedureRef; aTimeout: UInt32 = 30000; aFail: Boolean = True; const aMsg: string = ''): Boolean; overload;
{$ENDIF}

{$IFNDEF DELPHI_2009_UP}
function UIntToStr(Value: UInt32): string; overload;
function UIntToStr(Value: UInt64): string; overload;
{$ENDIF}

implementation

{$IFNDEF DELPHI_2009_UP}
function UIntToStr(Value: UInt32): string;
begin
  Result := IntToStr(Integer(Value));
end;

function UIntToStr(Value: UInt64): string;
begin
  Result := IntToStr(Int64(Value));
end;
{$ENDIF}

{$IFDEF REGION}
{$REGION '***** NxAutoRelease *****'}
{$ENDIF}

type
  // Auto release wrapper for automatic destruction of wrapped instance
  // Suitable for unit testing, because wrapped object is used through
  // its original reference
  //
  // var s := TStringList.Create;
  // var a := NxAutoRelease.New(s);
  TNxAutoRelease = class(TInterfacedObject)
  private
    fInstance: TObject;
  public
    constructor Create(aInstance: TObject);
    destructor Destroy; override;
  end;

  TNxAutoReleasePool = class(TInterfacedObject, INxAutoReleasePool)
  private
    fInstances: TObjectList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Add(aInstance: TObject);
  end;

constructor TNxAutoRelease.Create(aInstance: TObject);
begin
  fInstance := aInstance;
end;

destructor TNxAutoRelease.Destroy;
begin
  fInstance.Free;
  inherited;
end;

constructor TNxAutoReleasePool.Create;
begin
  fInstances := TObjectList.Create(True);
end;

destructor TNxAutoReleasePool.Destroy;
begin
  fInstances.Free;
  inherited;
end;

procedure TNxAutoReleasePool.Clear;
begin
  fInstances.Clear;
end;

procedure TNxAutoReleasePool.Add(aInstance: TObject);
begin
  fInstances.Add(aInstance);
end;

class function NxAutoRelease.New(aInstance: TObject): IInterface;
begin
  Result := TNxAutoRelease.Create(aInstance);
end;

class function NxAutoRelease.NewPool: INxAutoReleasePool;
begin
  Result := TNxAutoReleasePool.Create;
end;

{$IFDEF REGION}
{$ENDREGION '***** NxAutoRelease *****'}
{$ENDIF}

{$IFDEF REGION}
{$REGION '***** TNxAnyProcedure *****'}
{$ENDIF}

constructor TNxAnyProcedure.Create(aValue: TNxProcedure);
begin
  TMethod(fMth).Code := @aValue;
  TMethod(fMth).Data := nil;
end;

constructor TNxAnyProcedure.Create(aValue: TNxProcedureMth);
begin
  fMth := aValue;
end;

constructor TNxAnyProcedure.Create(const aValue: TNxProcedureRef);
begin
  fMth := nil;
  fRef := aValue;
end;

procedure TNxAnyProcedure.Assign(aValue: TNxProcedure);
begin
  TMethod(fMth).Code := @aValue;
  TMethod(fMth).Data := nil;
  fRef := nil;
end;

procedure TNxAnyProcedure.Assign(aValue: TNxProcedureMth);
begin
  fMth := aValue;
  fRef := nil;
end;

procedure TNxAnyProcedure.AssignMth(aValue: TNxProcedureMth);
begin
  fMth := aValue;
  fRef := nil;
end;

procedure TNxAnyProcedure.Assign(const aValue: TNxProcedureRef);
begin
  fMth := nil;
  fRef := aValue;
end;

procedure TNxAnyProcedure.AssignRef(const aValue: TNxProcedureRef);
begin
  fMth := nil;
  fRef := aValue;
end;

function TNxAnyProcedure.IsAssigned: Boolean;
begin
  Result := Assigned(fRef) or Assigned(fMth);
end;

procedure TNxAnyProcedure.Clear;
begin
  fMth := nil;
  fRef := nil;
end;

procedure TNxAnyProcedure.Invoke;
begin
  {$IFDEF ANONYMOUS_METHODS}
  if Assigned(fRef) then
    fRef
  else
  {$ENDIF}
  if TMethod(fMth).Data = nil then
    TNxProcedure(TMethod(fMth).Code)
  else
    fMth;
end;

class function TNxAnyProcedure.NotEqual(const Left, Right: TNxAnyProcedure): Boolean;
begin
  Result := (TMethod(Left.fMth).Code <> TMethod(Right.fMth).Code) or (TMethod(Left.fMth).Data <> TMethod(Right.fMth).Data)
    or (Left.fRef <> Right.fRef);
end;

class function TNxAnyProcedure.Equal(const Left, Right: TNxAnyProcedure): Boolean;
begin
  Result := (TMethod(Left.fMth).Code = TMethod(Right.fMth).Code) and (TMethod(Left.fMth).Data = TMethod(Right.fMth).Data)
    and (Left.fRef = Right.fRef);
end;

class function TNxAnyProcedure.Compare(const Left, Right: TNxAnyProcedure): Integer;
begin
  Result := NativeInt(Left.fRef) - NativeInt(Right.fRef);
  if Result = 0 then
    begin
      if TMethod(Left.fMth).Code = TMethod(Right.fMth).Code then
        Result := NativeInt(TMethod(Left.fMth).Data) - NativeInt(TMethod(Right.fMth).Data)
      else
        Result := NativeInt(TMethod(Left.fMth).Code) - NativeInt(TMethod(Right.fMth).Code);
    end;
end;

{$IFDEF REGION}
{$ENDREGION '***** TNxAnyProcedure *****'}
{$ENDIF}

{$IFDEF REGION}
{$REGION '***** TNxAnonymousThread *****'}
{$ENDIF}

constructor TNxAnonymousThread.Create(const aProcedure: TNxAnyProcedure);
begin
  inherited Create(True);
  FreeOnTerminate := True;
  fProc := aProcedure;
end;

constructor TNxAnonymousThread.Create(aValue: TNxProcedure);
var
  AnyProc: TNxAnyProcedure;
begin
  AnyProc.Create(aValue);
  Create(AnyProc);
end;

constructor TNxAnonymousThread.Create(aValue: TNxProcedureMth);
var
  AnyProc: TNxAnyProcedure;
begin
  AnyProc.Create(aValue);
  Create(AnyProc);
end;

constructor TNxAnonymousThread.Create(const aValue: TNxProcedureRef);
var
  AnyProc: TNxAnyProcedure;
begin
  AnyProc.Create(aValue);
  Create(AnyProc);
end;

procedure TNxAnonymousThread.Execute;
begin
  try
    fProc.Invoke;
  finally
  {$IFNDEF DELPHI_2010_UP}
    fFinished := True;
  {$ENDIF}
  end;
end;

{$IFNDEF DELPHI_2010_UP}
procedure TNxAnonymousThread.Start;
begin
  Resume;
end;

class function TNxAnonymousThread.GetTickCount: Cardinal;
begin
  Result := Windows.GetTickCount;
end;
{$ENDIF}

{$IFDEF REGION}
{$ENDREGION '***** TNxAnonymousThread *****'}
{$ENDIF}

{$IFDEF REGION}
{$REGION '***** Expect *****'}
{$ENDIF}

// Globals

var
  fNxEmptyException: ExceptClass;
  fNxFailException: ExceptClass;
  fNxTimeoutException: ExceptClass;

threadvar
  fNxExpectCalled: Boolean;

threadvar
  fNxExpectedException: ExceptClass;


// ***** NxExpect *****

class procedure NxExpect.Init(aEmptyException, aFailException, aTimeoutException: ExceptClass);
begin
  fNxEmptyException := aEmptyException;
  fNxFailException := aFailException;
  fNxTimeoutException := aTimeoutException;
end;

class function NxExpect.EmptyExceptionClass: ExceptClass;
begin
  Result := fNxEmptyException;
end;

class function NxExpect.FailExceptionClass: ExceptClass;
begin
  Result := fNxFailException;
end;

class function NxExpect.TimeoutExceptionClass: ExceptClass;
begin
  Result := fNxTimeoutException;
end;

class procedure NxExpect.ClearExpect;
begin
  fNxExpectCalled := False;
end;

class procedure NxExpect.DoExpect;
begin
  fNxExpectCalled := True;
end;

class function NxExpect.ExpectCalled: Boolean;
begin
  Result := fNxExpectCalled;
end;

class procedure NxExpect.ClearThrown;
begin
  fNxExpectedException := nil;
end;

class procedure NxExpect.VerifyThrown(const Msg: string);
begin
  try
    // if the expected exception is assigned at this point it means that
    // previous code failed to raise expected exception
    if Assigned(fNxExpectedException) then
      FailThrow(FormatException(nil), FormatException(fNxExpectedException), Msg);
  finally
    fNxExpectedException := nil;
  end;
end;

class procedure NxExpect.ExpectThrows(const Expected: ExceptClass);
begin
  // check whether we were already expecting exception
  VerifyThrown;
  fNxExpectedException := Expected;
end;

class function NxExpect.ExpectedException: ExceptClass;
begin
  Result := fNxExpectedException;
end;

class function NxExpect.FormatClass(Value: TClass): string;
begin
  if Assigned(Value) then
    Result := Value.ClassName
  else
    Result := sNil;
end;

class function NxExpect.FormatException(Value: TClass): string;
begin
  if Assigned(Value) then
  begin
    if Value = TObject then
      Result := sAny
    else
      Result := Value.ClassName
  end
  else
    Result := sNone;
end;

class function NxExpect.FormatException(Value: TObject): string;
begin
  if Assigned(Value) then
    Result := Value.ClassName
  else
    Result := sNone;
end;

class function NxExpect.FormatObject(Value: TObject): string;
begin
  if Assigned(Value) then
    Result := Value.ClassName
  else
    Result := sNil;
end;

class function NxExpect.FormatPointer(Value: Pointer): string;
begin
  if Assigned(Value) then
    Result := sHex + IntToHex(NativeInt(Value), SizeOf(Pointer) * 2)
  else
    Result := sNil;
end;

class procedure NxExpect.Fail(const Msg: string);
begin
  raise fNxFailException.Create(Msg);
end;

class procedure NxExpect.FailEmpty(const Msg: string);
var
  Separator: string;
begin
  if Msg = '' then
    Separator := ''
  else
    Separator := sSeparator;
  raise fNxEmptyException.Create(Format(sTestEmpty, [Msg, Separator]));
end;

class procedure NxExpect.FailTimeout(const Msg: string);
var
  Separator: string;
begin
  if Msg = '' then
    Separator := ''
  else
    Separator := sSeparator;
  raise fNxTimeoutException.Create(Format(sTestTimeout, [Msg, Separator]));
end;

class procedure NxExpect.FailThrow(const Actual, Expected, Msg: string);
var
  Separator: string;
begin
  if Msg = '' then
    Separator := ''
  else
    Separator := sSeparator;
  Fail(Format(sExpectedThrow, [Msg, Separator, Expected, Actual]))
end;

class procedure NxExpect.FailThrowMessage(const Actual, Expected, Msg: string);
var
  Separator: string;
begin
  if Msg = '' then
    Separator := ''
  else
    Separator := sSeparator;
  Fail(Format(sExpectedThrowMessage, [Msg, Separator, Expected, Actual]))
end;

class procedure NxExpect.FailNull(IsNot: Boolean; Actual: Pointer; const Msg: string);
var
  Separator: string;
begin
  if Msg = '' then
    Separator := ''
  else
    Separator := sSeparator;
  if IsNot then
    Fail(Format(sExpectedNotNil, [Msg, Separator]))
  else
    Fail(Format(sExpectedNil, [Msg, Separator, FormatPointer(Actual)]));
end;

class procedure NxExpect.FailEqualTo(IsNot: Boolean; const Actual, Expected, Msg: string);
var
  Separator: string;
begin
  if Msg = '' then
    Separator := ''
  else
    Separator := sSeparator;
  if IsNot then
    Fail(Format(sExpectedNotEqualTo, [Msg, Separator, Expected, Actual]))
  else
    Fail(Format(sExpectedEqualTo, [Msg, Separator, Expected, Actual]));
end;

class procedure NxExpect.FailEqualToMemory(IsNot: Boolean; Actual, Expected: Pointer; const Msg: string);
var
  Separator: string;
begin
  if Msg = '' then
    Separator := ''
  else
    Separator := sSeparator;
  if IsNot then
    Fail(Format(sExpectedMemoryNotEqualTo, [Msg, Separator, FormatPointer(Expected), FormatPointer(Actual)]))
  else
    Fail(Format(sExpectedMemoryEqualTo, [Msg, Separator,FormatPointer(Expected), FormatPointer(Actual)]));
end;

class procedure NxExpect.FailSame(IsNot: Boolean; Actual, Expected: Pointer; const Msg: string);
var
  Separator: string;
begin
  if Msg = '' then
    Separator := ''
  else
    Separator := sSeparator;
  if IsNot then
    Fail(Format(sExpectedNotSame, [Msg, Separator, FormatPointer(Expected), FormatPointer(Actual)]))
  else
    Fail(Format(sExpectedSame, [Msg, Separator, FormatPointer(Expected), FormatPointer(Actual)]));
end;

class procedure NxExpect.FailDescendantOf(IsNot: Boolean; Actual: TObject; aClass: TClass; const Msg: string);
var
  Separator: string;
begin
  if Msg = '' then
    Separator := ''
  else
    Separator := sSeparator;
  if IsNot then
    Fail(Format(sExpectedNotDescendantOf, [Msg, Separator, FormatClass(aClass), FormatObject(Actual)]))
  else
    Fail(Format(sExpectedDescendantOf, [Msg, Separator, FormatClass(aClass), FormatObject(Actual)]));
end;

class procedure NxExpect.FailInstanceOf(IsNot: Boolean; Actual: TObject; aClass: TClass; const Msg: string);
var
  Separator: string;
begin
  if Msg = '' then
    Separator := ''
  else
    Separator := sSeparator;
  if IsNot then
    Fail(Format(sExpectedNotInstanceOf, [Msg, Separator, FormatClass(aClass), FormatObject(Actual)]))
  else
    Fail(Format(sExpectedInstanceOf, [Msg, Separator, FormatClass(aClass), FormatObject(Actual)]));
end;


// ***** TExpectBase *****

function TExpectBase.GetObj: TObject;
begin
  Result := Self;
end;

// ***** TExpectProc *****

constructor TExpectProc.Create(Value: TNxProcedure);
begin
  fNot := False;
  fValue.Create(Value);
end;

constructor TExpectProc.Create(Value: TNxProcedureMth);
begin
  fNot := False;
  fValue.Create(Value);
end;

constructor TExpectProc.Create(const Value: TNxProcedureRef);
begin
  fNot := False;
  fValue.Create(Value);
end;

function TExpectProc.DoesNot: IExpectProcedure;
begin
  fNot := True;
  Result := Self;
end;

function TExpectProc.Throw(const ExpectedException: TClass; const Msg: string): IExpectProcedure;
var
  Passed: Boolean;
  Actual: TClass;
begin
  NxExpect.DoExpect;

  Passed := False;
  Actual := nil;
  try
    fValue.Invoke;
  except
    on E: TObject do
    begin
      Actual := E.ClassType;
      if Assigned(ExpectedException) then
        Passed := E.InheritsFrom(ExpectedException);
    end;
  end;
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailThrow(NxExpect.FormatException(ExpectedException), NxExpect.FormatException(Actual), Msg);
  Result := Self;
end;

function TExpectProc.ThrowAny(const Msg: string): IExpectProcedure;
begin
  Result := Throw(TObject, Msg);
end;

// ***** TExpectBoolean *****

constructor TExpectBoolean.Create(const Value: Boolean);
begin
  fNot := False;
  fValue := Value;
end;

function TExpectBoolean.IsNot: IExpectBoolean;
begin
  fNot := True;
  Result := Self;
end;

function TExpectBoolean.EqualTo(const Expected: Boolean; const Msg: string): IExpectBoolean;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := fValue = Expected;
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailEqualTo(fNot, BoolToStr(fValue, True), BoolToStr(Expected, True), Msg);
end;

function TExpectBoolean.IsFalse(const Msg: string): IExpectBoolean;
begin
  Result := EqualTo(False, Msg);
end;

function TExpectBoolean.IsTrue(const Msg: string): IExpectBoolean;
begin
  Result := EqualTo(True, Msg);
end;

// ***** TExpectInt32 *****

constructor TExpectInt32.Create(const Value: Integer);
begin
  fNot := False;
  fValue := Value;
end;

function TExpectInt32.IsNot: IExpectInt32;
begin
  fNot := True;
  Result := Self;
end;

function TExpectInt32.EqualTo(const Expected: Integer; const Msg: string = ''): IExpectInt32;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := fValue = Expected;
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailEqualTo(fNot, IntToStr(fValue), IntToStr(Expected), Msg);
end;

// ***** TExpectUInt32 *****

constructor TExpectUInt32.Create(const Value: UInt32);
begin
  fNot := False;
  fValue := Value;
end;

function TExpectUInt32.IsNot: IExpectUInt32;
begin
  fNot := True;
  Result := Self;
end;

function TExpectUInt32.EqualTo(const Expected: UInt32; const Msg: string = ''): IExpectUInt32;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := fValue = Expected;
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailEqualTo(fNot, UIntToStr(fValue), UIntToStr(Expected), Msg);
end;

// ***** TExpectInt64 *****

constructor TExpectInt64.Create(const Value: Int64);
begin
  fNot := False;
  fValue := Value;
end;

function TExpectInt64.IsNot: IExpectInt64;
begin
  fNot := True;
  Result := Self;
end;

function TExpectInt64.EqualTo(const Expected: Int64; const Msg: string = ''): IExpectInt64;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := fValue = Expected;
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailEqualTo(fNot, IntToStr(fValue), IntToStr(Expected), Msg);
end;

// ***** TExpectUInt64 *****

constructor TExpectUInt64.Create(const Value: UInt64);
begin
  fNot := False;
  fValue := Value;
end;

function TExpectUInt64.IsNot: IExpectUInt64;
begin
  fNot := True;
  Result := Self;
end;

function TExpectUInt64.EqualTo(const Expected: UInt64; const Msg: string = ''): IExpectUInt64;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := fValue = Expected;
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailEqualTo(fNot, UIntToStr(fValue), UIntToStr(Expected), Msg);
end;

// ***** TExpectCurrency *****

constructor TExpectCurrency.Create(const Value: Currency);
begin
  fNot := False;
  fValue := Value;
end;

function TExpectCurrency.IsNot: IExpectCurrency;
begin
  fNot := True;
  Result := Self;
end;

function TExpectCurrency.EqualTo(const Expected: Currency; const Msg: string = ''): IExpectCurrency;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := fValue = Expected;
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailEqualTo(fNot, CurrToStr(fValue), CurrToStr(Expected), Msg);
end;

// ***** TExpectSingle *****

constructor TExpectSingle.Create(const Value: Single);
begin
  fNot := False;
  fValue := Value;
end;

function TExpectSingle.IsNot: IExpectSingle;
begin
  fNot := True;
  Result := Self;
end;

function TExpectSingle.EqualTo(const Expected: Single; const Msg: string): IExpectSingle;
begin
  Result := EqualTo(Expected, 0, Msg);
end;

function TExpectSingle.EqualTo(const Expected: Single; Epsilon: Double; const Msg: string): IExpectSingle;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := SameValue(fValue, Expected, Epsilon);
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailEqualTo(fNot, FloatToStr(fValue), FloatToStr(Expected), Msg);
  Result := Self;
end;

// ***** TExpectDouble *****

constructor TExpectDouble.Create(const Value: Double);
begin
  fNot := False;
  fValue := Value;
end;

function TExpectDouble.IsNot: IExpectDouble;
begin
  fNot := True;
  Result := Self;
end;

function TExpectDouble.EqualTo(const Expected: Double; const Msg: string): IExpectDouble;
begin
  Result := EqualTo(Expected, 0, Msg);
end;

function TExpectDouble.EqualTo(const Expected, Epsilon: Double; const Msg: string): IExpectDouble;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := SameValue(fValue, Expected, Epsilon);
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailEqualTo(fNot, FloatToStr(fValue), FloatToStr(Expected), Msg);
  Result := Self;
end;

// ***** TExpectDateTime *****

constructor TExpectDateTime.Create(const Value: TDateTime);
begin
  fNot := False;
  fValue := Value;
end;

function TExpectDateTime.IsNot: IExpectDateTime;
begin
  fNot := True;
  Result := Self;
end;

function TExpectDateTime.EqualTo(const Expected: TDateTime; const Msg: string): IExpectDateTime;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := SameDateTime(fValue, Expected);
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailEqualTo(fNot, FormatDateTime('c', fValue), FormatDateTime('c', Expected), Msg);
  Result := Self;
end;

// ***** TExpectChar *****

constructor TExpectChar.Create(const Value: Char);
begin
  fNot := False;
  fValue := Value;
end;

function TExpectChar.IsNot: IExpectChar;
begin
  fNot := True;
  Result := Self;
end;

function TExpectChar.EqualTo(const Expected: Char; const Msg: string): IExpectChar;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := fValue = Expected;
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailEqualTo(fNot, fValue, Expected, Msg);
  Result := Self;
end;

// ***** TExpectString *****

constructor TExpectString.Create(const Value: string);
begin
  fNot := False;
  fValue := Value;
end;

function TExpectString.IsNot: IExpectString;
begin
  fNot := True;
  Result := Self;
end;

function TExpectString.EqualTo(const Expected: string; const Msg: string): IExpectString;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := fValue = Expected;
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailEqualTo(fNot, fValue, Expected, Msg);
  Result := Self;
end;

function TExpectString.Empty(const Msg: string): IExpectString;
begin
  Result := EqualTo('', Msg);
end;

// ***** TExpectUtf8String *****

constructor TExpectUtf8String.Create(const Value: UTF8String);
begin
  fNot := False;
  fValue := Value;
end;

function TExpectUtf8String.IsNot: IExpectUtf8String;
begin
  fNot := True;
  Result := Self;
end;

function TExpectUtf8String.EqualTo(const Expected: UTF8String; const Msg: string): IExpectUtf8String;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := fValue = Expected;
  if fNot then
    Passed := not Passed;
  if not Passed then
  {$IFDEF UNICODE}
    NxExpect.FailEqualTo(fNot, string(fValue), string(Expected), Msg);
  {$ELSE}
    NxExpect.FailEqualTo(fNot, UTF8Decode(fValue), UTF8Decode(Expected), Msg);
  {$ENDIF}
  Result := Self;
end;

function TExpectUtf8String.Empty(const Msg: string): IExpectUtf8String;
begin
  Result := EqualTo('', Msg);
end;

// ***** TExpectAnsiString *****

constructor TExpectAnsiString.Create(const Value: AnsiString);
begin
  fNot := False;
  fValue := Value;
end;

function TExpectAnsiString.IsNot: IExpectAnsiString;
begin
  fNot := True;
  Result := Self;
end;

function TExpectAnsiString.EqualTo(const Expected: AnsiString; const Msg: string): IExpectAnsiString;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := fValue = Expected;
  if fNot then
    Passed := not Passed;
  if not Passed then
  {$IFDEF UNICODE}
    NxExpect.FailEqualTo(fNot, string(fValue), string(Expected), Msg);
  {$ELSE}
    NxExpect.FailEqualTo(fNot, fValue, Expected, Msg);
  {$ENDIF}
  Result := Self;
end;

function TExpectAnsiString.Empty(const Msg: string): IExpectAnsiString;
begin
  Result := EqualTo('', Msg);
end;

// ***** TExpectWideString *****

constructor TExpectWideString.Create(const Value: WideString);
begin
  fNot := False;
  fValue := Value;
end;

function TExpectWideString.IsNot: IExpectWideString;
begin
  fNot := True;
  Result := Self;
end;

function TExpectWideString.EqualTo(const Expected: WideString; const Msg: string): IExpectWideString;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := fValue = Expected;
  if fNot then
    Passed := not Passed;
  if not Passed then
  NxExpect.FailEqualTo(fNot, fValue, Expected, Msg);
  Result := Self;
end;

function TExpectWideString.Empty(const Msg: string): IExpectWideString;
begin
  Result := EqualTo('', Msg);
end;

// ***** TExpectObject *****

constructor TExpectObject.Create(const Value: TObject);
begin
  fNot := False;
  fValue := Value;
end;

function TExpectObject.IsNot: IExpectObject;
begin
  fNot := True;
  Result := Self;
end;

function TExpectObject.Null(const Msg: string): IExpectObject;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := fValue = nil;
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailNull(fNot, @fValue, Msg);
  Result := Self;
end;

function TExpectObject.Same(const Expected: TObject; const Msg: string): IExpectObject;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := fValue = Expected;
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailSame(fNot, @fValue, @Expected, Msg);
  Result := Self;
end;

function TExpectObject.DescendantOf(const aClass: TClass; const Msg: string): IExpectObject;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := fValue.InheritsFrom(aClass);
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailDescendantOf(fNot, fValue, aClass, Msg);
  Result := Self;
end;

function TExpectObject.InstanceOf(const aClass: TClass; const Msg: string): IExpectObject;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := fValue.InheritsFrom(aClass);
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailInstanceOf(fNot, fValue, aClass, Msg);
  Result := Self;
end;

// ***** TExpectInterface *****

constructor TExpectInterface.Create(const Value: IInterface);
begin
  fNot := False;
  fValue := Value;
end;

function TExpectInterface.IsNot: IExpectInterface;
begin
  fNot := True;
  Result := Self;
end;

function TExpectInterface.Null(const Msg: string): IExpectInterface;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := fValue = nil;
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailNull(fNot, @fValue, Msg);
  Result := Self;
end;

function TExpectInterface.Same(const Expected: IInterface; const Msg: string): IExpectInterface;
var
  Passed: Boolean;
  ValueIntf: IInterface;
  ExpectedIntf: IInterface;
begin
  NxExpect.DoExpect;

  ValueIntf := fValue as IInterface;
  ExpectedIntf := Expected as IInterface;
  Passed := fValue = Expected;
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailSame(fNot, Pointer(ValueIntf), Pointer(ExpectedIntf), Msg);
  Result := Self;
end;

// ***** TExpectMemory *****

constructor TExpectMemory.Create(const Value: Pointer);
begin
  fNot := False;
  fValue := Value;
end;

function TExpectMemory.IsNot: IExpectMemory;
begin
  fNot := True;
  Result := Self;
end;

function TExpectMemory.EqualTo(const Expected: Pointer; Size: NativeInt; const Msg: string): IExpectMemory;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := CompareMem(fValue, Expected, Size);
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailEqualToMemory(fNot, fValue, Expected, Msg);
  Result := Self;
end;

{$IFDEF GENERICS}

constructor TExpectValueType<T>.Create(const Value: T);
begin
  fNot := False;
  fValue := Value;
end;

function TExpectValueType<T>.IsNot: IExpectValueType<T>;
begin
  fNot := True;
  Result := Self;
end;

function TExpectValueType<T>.EqualTo(const Expected: T; const Msg: string = ''): IExpectValueType<T>;
var
  Passed: Boolean;
begin
  NxExpect.DoExpect;

  Passed := CompareMem(@fValue, @Expected, SizeOf(T));
  if fNot then
    Passed := not Passed;
  if not Passed then
    NxExpect.FailEqualToMemory(fNot, @fValue, @Expected, Msg);
end;

// ***** ExpectT *****

class function ExpectT.Actual<T>(const aActual: T): IExpectValueType<T>;
begin
  Result := TExpectValueType<T>.Create(aActual);
end;

{$ENDIF}

// standalone functions

procedure ExpectThrows(const Expected: ExceptClass);
begin
  NxExpect.ExpectThrows(Expected);
end;

function ExpectProcedure(const Proc: TNxProcedure): IExpectProcedure;
begin
  Result := TExpectProc.Create(Proc);
end;

function ExpectProcedure(const Proc: TNxProcedureMth): IExpectProcedure;
begin
  Result := TExpectProc.Create(Proc);
end;

{$IFDEF ANONYMOUS_METHODS}
function ExpectProcedure(const Proc: TNxProcedureRef): IExpectProcedure;
begin
  Result := TExpectProc.Create(Proc);
end;
{$ENDIF}

function Expect(const Actual: Boolean): IExpectBoolean;
begin
  Result := TExpectBoolean.Create(Actual);
end;

function Expect(const Actual: Integer): IExpectInt32;
begin
  Result := TExpectInt32.Create(Actual);
end;

function Expect(const Actual: UInt32): IExpectUInt32;
begin
  Result := TExpectUInt32.Create(Actual);
end;

function Expect(const Actual: Int64): IExpectInt64;
begin
  Result := TExpectInt64.Create(Actual);
end;

function Expect(const Actual: UInt64): IExpectUInt64;
begin
  Result := TExpectUInt64.Create(Actual);
end;

function Expect(const Actual: Single): IExpectSingle;
begin
  Result := TExpectSingle.Create(Actual);
end;

function Expect(const Actual: Double): IExpectDouble;
begin
  Result := TExpectDouble.Create(Actual);
end;

{$IFDEF DELPHI_XE_UP}
function Expect(const Actual: TDateTime): IExpectDateTime;
begin
  Result := TExpectDateTime.Create(Actual);
end;

function Expect(const Actual: Currency): IExpectCurrency;
begin
  Result := TExpectCurrency.Create(Actual);
end;
{$ENDIF}

function ExpectDateTime(const Actual: TDateTime): IExpectDateTime;
begin
  Result := TExpectDateTime.Create(Actual);
end;

function ExpectCurrency(const Actual: Currency): IExpectCurrency;
begin
  Result := TExpectCurrency.Create(Actual);
end;

function Expect(const Actual: Char): IExpectChar;
begin
  Result := TExpectChar.Create(Actual);
end;

function Expect(const Actual: string): IExpectString;
begin
  Result := TExpectString.Create(Actual);
end;

{$IFDEF UNICODE}
function Expect(const Actual: UTF8String): IExpectUtf8String;
begin
  Result := TExpectUTF8String.Create(Actual);
end;

function Expect(const Actual: AnsiString): IExpectAnsiString;
begin
  Result := TExpectAnsiString.Create(Actual);
end;

function Expect(const Actual: WideString): IExpectWideString;
begin
  Result := TExpectWideString.Create(Actual);
end;
{$ENDIF}

function ExpectUtf8String(const Actual: UTF8String): IExpectUtf8String;
begin
  Result := TExpectUTF8String.Create(Actual);
end;

function ExpectAnsiString(const Actual: AnsiString): IExpectAnsiString;
begin
  Result := TExpectAnsiString.Create(Actual);
end;

function ExpectWideString(const Actual: WideString): IExpectWideString;
begin
  Result := TExpectWideString.Create(Actual);
end;

function Expect(const Actual: TObject): IExpectObject;
begin
  Result := TExpectObject.Create(Actual);
end;

function Expect(const Actual: IInterface): IExpectInterface;
begin
  Result := TExpectInterface.Create(Actual);
end;

{$IFDEF REGION}
{$ENDREGION '***** Expect *****'}
{$ENDIF}

{$IFDEF REGION}
{$REGION '***** RunAsync *****'}
{$ENDIF}

function RunAsync(const aProcedure: TNxAnyProcedure; aTimeout: UInt32; aFail: Boolean; const aMsg: string): Boolean;
var
  Start, Ticks: UInt32;
  Thread: TNxAnonymousThread;
begin
  Result := True;
  Thread := TNxAnonymousThread.Create(aProcedure);
  Thread.FreeOnTerminate := False;
  Thread.Start;
  Start := TNxAnonymousThread.GetTickCount;
  while not Thread.Finished do
    begin
      Ticks := TNxAnonymousThread.GetTickCount - Start;
      if Ticks > aTimeout then
      begin
        Result := False;
        Thread.Terminate;
        Break;
      end;
      {$IFDEF NAMESPACES}
      if TThread.CurrentThread.ThreadID = MainThreadID then
      {$ELSE}
      if GetCurrentThreadID <> MainThreadID then
      {$ENDIF}
        CheckSynchronize(100)
      else
        Sleep(100);
    end;
  // don't block if thread is unresponsive, memory leak is acceptable here
  if Thread.Finished then
    Thread.Free;
  if aFail and not Result then
    NxExpect.FailTimeout(aMsg);
end;

function RunAsync(const aProcedures: array of TNxAnyProcedure; aTimeout: UInt32; aFail: Boolean; const aMsg: string): Boolean;
var
  Start, Ticks: UInt32;
  Threads: array of TNxAnonymousThread;
  i: Integer;
  AllDone: Boolean;
begin
  Result := True;
  AllDone := False;
  SetLength(Threads, Length(aProcedures));
  for i := 0 to High(Threads) do
    begin
      Threads[i] := TNxAnonymousThread.Create(aProcedures[i]);
      Threads[i].FreeOnTerminate := False;
      Threads[i].Start;
    end;
  Start := TNxAnonymousThread.GetTickCount;
  while not AllDone do
    begin
      Ticks := TNxAnonymousThread.GetTickCount - Start;
      if Ticks > aTimeout then
      begin
        Result := False;
        for i := 0 to High(Threads) do
          Threads[i].Terminate;
        Break;
      end;
      {$IFDEF NAMESPACES}
      if TThread.CurrentThread.ThreadID = MainThreadID then
      {$ELSE}
      if GetCurrentThreadID <> MainThreadID then
      {$ENDIF}
        CheckSynchronize(100)
      else
        Sleep(100);
      AllDone := True;
      for i := 0 to High(Threads) do
        begin
          if not Threads[i].Finished then
            begin
              AllDone := False;
              Break;
            end;
        end;
    end;
  // don't block if thread is unresponsive, memory leak is acceptable here
  for i := 0 to High(Threads) do
    if Threads[i].Finished then
      Threads[i].Free;
  if aFail and not Result then
    NxExpect.FailTimeout(aMsg);
end;

{$IFDEF ANONYMOUS_METHODS}

function RunAsync(const aProcedure: TNxProcedureRef; aTimeout: UInt32; aFail: Boolean; const aMsg: string): Boolean;
var
  Proc: TNxAnyProcedure;
begin
  Proc := TNxAnyProcedure.Create(aProcedure);
  Result := RunAsync(Proc, aTimeout, aFail, aMsg);
end;

function RunAsync(const aProcedures: array of TNxProcedureRef; aTimeout: UInt32; aFail: Boolean; const aMsg: string): Boolean;
var
  Procs: array of TNxAnyProcedure;
  i: Integer;
begin
  SetLength(Procs, Length(aProcedures));
  for i := 0 to High(Procs) do
    Procs[i] := TNxAnyProcedure.Create(aProcedures[i]);
  Result := RunAsync(Procs, aTimeout, aFail, aMsg);
end;

{$ENDIF}

{$IFDEF REGION}
{$ENDREGION '***** RunAsync *****'}
{$ENDIF}

initialization

  NxExpect.Init(ETestEmpty, ETestFailure, ETestTimeout);

end.



