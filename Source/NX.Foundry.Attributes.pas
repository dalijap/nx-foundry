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

unit NX.Foundry.Attributes;

{$I 'NX.inc'}

interface

uses
  {$IFDEF NAMESPACES}
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.Rtti,
  System.TypInfo;
  {$ELSE}
  SysUtils,
  Classes,
  Generics.Collections,
  Rtti,
  TypInfo;
  {$ENDIF}

type
  CategoryAttribute = class(TCustomAttribute)
  private
    fCategory: string;
  public
    constructor Create(const aCategory: string);
    property Category: string read fCategory;
  end;

  IgnoreAttribute = class(TCustomAttribute)
  private
    fReason: string;
  public
    constructor Create(const aReason: string = '');
    property Reason: string read fReason;
  end;

  TestAttribute = class(TCustomAttribute);

  TNxNamedTest = (Named);
  TNxParsedTest = (Parsed);

  TBaseTestCaseAttribute = class(TCustomAttribute)
  protected
    fName: string;
    fValues: TArray<TValue>;
  public
    constructor Create(const aName: string; aValues: TArray<TValue>);
    property Name: string read fName;
    property Values: TArray<TValue> read fValues;
  end;

  TestCaseAttribute = class(TBaseTestCaseAttribute)
  public
    constructor Create(aNamed: TNxNamedTest; aParsed: TNxParsedTest; const aName, aValues: string; aDelimiter: Char = ','); overload;
    constructor Create(aParsed: TNxParsedTest; const aValues: string; aDelimiter: Char = ','); overload;

    // string
    constructor Create(aNamed: TNxNamedTest; const aName, Arg1: string); overload;
    constructor Create(aNamed: TNxNamedTest; const aName, Arg1, Arg2: string); overload;
    constructor Create(aNamed: TNxNamedTest; const aName, Arg1, Arg2, Arg3: string); overload;
    constructor Create(aNamed: TNxNamedTest; const aName, Arg1, Arg2, Arg3, Arg4: string); overload;
    constructor Create(aNamed: TNxNamedTest; const aName, Arg1, Arg2, Arg3, Arg4, Arg5: string); overload;
    constructor Create(aNamed: TNxNamedTest; const aName, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: string); overload;
    constructor Create(aNamed: TNxNamedTest; const aName, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7: string); overload;
    constructor Create(aNamed: TNxNamedTest; const aName, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8: string); overload;

    constructor Create(const Arg1: string); overload;
    constructor Create(const Arg1, Arg2: string); overload;
    constructor Create(const Arg1, Arg2, Arg3: string); overload;
    constructor Create(const Arg1, Arg2, Arg3, Arg4: string); overload;
    constructor Create(const Arg1, Arg2, Arg3, Arg4, Arg5: string); overload;
    constructor Create(const Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: string); overload;
    constructor Create(const Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7: string); overload;
    constructor Create(const Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8: string); overload;

    // Int64
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1: Int64); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2: Int64); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3: Int64); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4: Int64); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4, Arg5: Int64); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: Int64); overload;

    constructor Create(Arg1: Int64); overload;
    constructor Create(Arg1, Arg2: Int64); overload;
    constructor Create(Arg1, Arg2, Arg3: Int64); overload;
    constructor Create(Arg1, Arg2, Arg3, Arg4: Int64); overload;
    constructor Create(Arg1, Arg2, Arg3, Arg4, Arg5: Int64); overload;
    constructor Create(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: Int64); overload;

    // UInt64
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1: UInt64); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2: UInt64); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3: UInt64); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4: UInt64); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4, Arg5: UInt64); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: UInt64); overload;

    constructor Create(Arg1: UInt64); overload;
    constructor Create(Arg1, Arg2: UInt64); overload;
    constructor Create(Arg1, Arg2, Arg3: UInt64); overload;
    constructor Create(Arg1, Arg2, Arg3, Arg4: UInt64); overload;
    constructor Create(Arg1, Arg2, Arg3, Arg4, Arg5: UInt64); overload;
    constructor Create(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: UInt64); overload;

    // Double
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1: Double); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2: Double); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3: Double); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4: Double); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4, Arg5: Double); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: Double); overload;

    constructor Create(Arg1: Double); overload;
    constructor Create(Arg1, Arg2: Double); overload;
    constructor Create(Arg1, Arg2, Arg3: Double); overload;
    constructor Create(Arg1, Arg2, Arg3, Arg4: Double); overload;
    constructor Create(Arg1, Arg2, Arg3, Arg4, Arg5: Double); overload;
    constructor Create(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: Double); overload;

    // Boolean
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1: Boolean); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2: Boolean); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3: Boolean); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4: Boolean); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4, Arg5: Boolean); overload;
    constructor Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: Boolean); overload;

    constructor Create(Arg1: Boolean); overload;
    constructor Create(Arg1, Arg2: Boolean); overload;
    constructor Create(Arg1, Arg2, Arg3: Boolean); overload;
    constructor Create(Arg1, Arg2, Arg3, Arg4: Boolean); overload;
    constructor Create(Arg1, Arg2, Arg3, Arg4, Arg5: Boolean); overload;
    constructor Create(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: Boolean); overload;
  end;

  TestCaseProviderAttribute = class(TCustomAttribute)
  private
    fProviderClass: TClass;
    fProviderName: string;
  public
    constructor Create(aProviderClass: TClass; const aProviderName: string); overload;
    constructor Create(const aProviderName: string); overload;
    property ProviderClass: TClass read fProviderClass;
    property ProviderName: string read fProviderName;
  end;

  INxValueConverter = interface
    function Convert(const aValue: string; aType: TRttiType): TValue;
  end;

  TNxValueConverter = class(TInterfacedObject, INxValueConverter)
  protected
    ConverterSettings: TFormatSettings;
  public
    constructor Create;
    function Convert(const aValue: string; aType: TRttiType): TValue;
  end;

  NxRtti = class
  protected
    class var fContext: TRttiContext;
    class var fConverter: INxValueConverter;
    class constructor ClassCreate;
    class destructor ClassDestroy;
    class function GetContext: TRttiContext; static;
  public
    class function Convert(const aValue: TValue; aType: TRttiType): TValue; static;
    class function HasAttribute(aRttiObject: TRttiObject; aAttrClass: TClass): Boolean; overload; static;
    class function HasAttribute(aAttributes: TArray<TCustomAttribute>; aAttrClass: TClass): Boolean; overload; static;
    class function AttributeCount(aAttributes: TArray<TCustomAttribute>; aAttrClass: TClass): Integer; static;
    class function TestCaseName(const aValues: TArray<TValue>): string; static;
    class property Context: TRttiContext read GetContext;
    class property Converter: INxValueConverter read fConverter write fConverter;
  end;

implementation

// ***** CategoryAttribute *****

constructor CategoryAttribute.Create(const aCategory: string);
begin
  inherited Create;
  fCategory := aCategory;
end;

// ***** IgnoreAttribute *****

constructor IgnoreAttribute.Create(const aReason: string);
begin
  inherited Create;
  fReason := aReason;
end;

// ***** TBaseTestCaseAttribute *****

constructor TBaseTestCaseAttribute.Create(const aName: string; aValues: TArray<TValue>);
begin
  inherited Create;
  fName := aName;
  fValues := aValues;
end;

// ***** TestCaseAttribute *****

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; aParsed: TNxParsedTest; const aName, aValues: string; aDelimiter: Char);
var
  lValues: TArray<TValue>;
  lStrings: TStringList;
  i: Integer;
begin
  lStrings := TStringList.Create;
  try
    lStrings.Delimiter := aDelimiter;
    lStrings.DelimitedText := aValues;
    SetLength(lValues, lStrings.Count);
    for i := 0 to lStrings.Count - 1 do
      lValues[i] := Trim(lStrings[i]);
  finally
    lStrings.Free;
  end;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aParsed: TNxParsedTest; const aValues: string; aDelimiter: Char);
begin
  Create(Named, aParsed, '', aValues, aDelimiter);
end;

{$REGION '***** string *****'}

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName, Arg1: string);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 1);
  lValues[0] := Arg1;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName, Arg1, Arg2: string);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 2);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName, Arg1, Arg2, Arg3: string);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 3);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName, Arg1, Arg2, Arg3, Arg4: string);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 4);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  lValues[3] := Arg4;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName, Arg1, Arg2, Arg3, Arg4, Arg5: string);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 5);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  lValues[3] := Arg4;
  lValues[4] := Arg5;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: string);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 6);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  lValues[3] := Arg4;
  lValues[4] := Arg5;
  lValues[5] := Arg6;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7: string);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 7);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  lValues[3] := Arg4;
  lValues[4] := Arg5;
  lValues[5] := Arg6;
  lValues[6] := Arg7;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName, Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8: string);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 8);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  lValues[3] := Arg4;
  lValues[4] := Arg5;
  lValues[5] := Arg6;
  lValues[6] := Arg7;
  lValues[7] := Arg8;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(const Arg1: string);
begin
  Create(Named, '', Arg1);
end;

constructor TestCaseAttribute.Create(const Arg1, Arg2: string);
begin
  Create(Named, '', Arg1, Arg2);
end;

constructor TestCaseAttribute.Create(const Arg1, Arg2, Arg3: string);
begin
  Create(Named, '', Arg1, Arg2, Arg3);
end;

constructor TestCaseAttribute.Create(const Arg1, Arg2, Arg3, Arg4: string);
begin
  Create(Named, '', Arg1, Arg2, Arg3, Arg4);
end;

constructor TestCaseAttribute.Create(const Arg1, Arg2, Arg3, Arg4, Arg5: string);
begin
  Create(Named, '', Arg1, Arg2, Arg3, Arg4, Arg5);
end;

constructor TestCaseAttribute.Create(const Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: string);
begin
  Create(Named, '', Arg1, Arg2, Arg3, Arg4, Arg6);
end;

constructor TestCaseAttribute.Create(const Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7: string);
begin
  Create(Named, '', Arg1, Arg2, Arg3, Arg4, Arg6, Arg7);
end;

constructor TestCaseAttribute.Create(const Arg1, Arg2, Arg3, Arg4, Arg5, Arg6, Arg7, Arg8: string);
begin
  Create(Named, '', Arg1, Arg2, Arg3, Arg4, Arg6, Arg7, Arg8);
end;

{$ENDREGION '***** string *****'}

{$REGION '***** Int64 *****'}

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1: Int64);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 1);
  lValues[0] := Arg1;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2: Int64);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 2);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3: Int64);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 3);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4: Int64);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 4);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  lValues[3] := Arg4;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4, Arg5: Int64);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 5);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  lValues[3] := Arg4;
  lValues[4] := Arg5;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: Int64);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 6);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  lValues[3] := Arg4;
  lValues[4] := Arg5;
  lValues[5] := Arg6;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(Arg1: Int64);
begin
  Create(Named, '', Arg1);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2: Int64);
begin
  Create(Named, '', Arg1, Arg2);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2, Arg3: Int64);
begin
  Create(Named, '', Arg1, Arg2, Arg3);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2, Arg3, Arg4: Int64);
begin
  Create(Named, '', Arg1, Arg2, Arg3, Arg4);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2, Arg3, Arg4, Arg5: Int64);
begin
  Create(Named, '', Arg1, Arg2, Arg3, Arg4, Arg5);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: Int64);
begin
  Create(Named, '', Arg1, Arg2, Arg3, Arg4, Arg6);
end;

{$ENDREGION '***** Int64 *****'}

{$REGION '***** UInt64 *****'}

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1: UInt64);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 1);
  lValues[0] := Arg1;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2: UInt64);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 2);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3: UInt64);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 3);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4: UInt64);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 4);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  lValues[3] := Arg4;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4, Arg5: UInt64);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 5);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  lValues[3] := Arg4;
  lValues[4] := Arg5;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: UInt64);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 6);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  lValues[3] := Arg4;
  lValues[4] := Arg5;
  lValues[5] := Arg6;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(Arg1: UInt64);
begin
  Create(Named, '', Arg1);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2: UInt64);
begin
  Create(Named, '', Arg1, Arg2);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2, Arg3: UInt64);
begin
  Create(Named, '', Arg1, Arg2, Arg3);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2, Arg3, Arg4: UInt64);
begin
  Create(Named, '', Arg1, Arg2, Arg3, Arg4);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2, Arg3, Arg4, Arg5: UInt64);
begin
  Create(Named, '', Arg1, Arg2, Arg3, Arg4, Arg5);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: UInt64);
begin
  Create(Named, '', Arg1, Arg2, Arg3, Arg4, Arg6);
end;

{$ENDREGION '***** UInt64 *****'}

{$REGION '***** Double *****'}

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1: Double);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 1);
  lValues[0] := Arg1;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2: Double);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 2);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3: Double);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 3);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4: Double);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 4);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  lValues[3] := Arg4;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4, Arg5: Double);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 5);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  lValues[3] := Arg4;
  lValues[4] := Arg5;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: Double);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 6);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  lValues[3] := Arg4;
  lValues[4] := Arg5;
  lValues[5] := Arg6;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(Arg1: Double);
begin
  Create(Named, '', Arg1);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2: Double);
begin
  Create(Named, '', Arg1, Arg2);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2, Arg3: Double);
begin
  Create(Named, '', Arg1, Arg2, Arg3);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2, Arg3, Arg4: Double);
begin
  Create(Named, '', Arg1, Arg2, Arg3, Arg4);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2, Arg3, Arg4, Arg5: Double);
begin
  Create(Named, '', Arg1, Arg2, Arg3, Arg4, Arg5);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: Double);
begin
  Create(Named, '', Arg1, Arg2, Arg3, Arg4, Arg6);
end;

{$ENDREGION '***** Double *****'}

{$REGION '***** Boolean *****'}

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1: Boolean);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 1);
  lValues[0] := Arg1;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2: Boolean);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 2);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3: Boolean);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 3);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4: Boolean);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 4);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  lValues[3] := Arg4;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4, Arg5: Boolean);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 5);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  lValues[3] := Arg4;
  lValues[4] := Arg5;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(aNamed: TNxNamedTest; const aName: string; Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: Boolean);
var
  lValues: TArray<TValue>;
begin
  SetLength(lValues, 6);
  lValues[0] := Arg1;
  lValues[1] := Arg2;
  lValues[2] := Arg3;
  lValues[3] := Arg4;
  lValues[4] := Arg5;
  lValues[5] := Arg6;
  inherited Create(aName, lValues);
end;

constructor TestCaseAttribute.Create(Arg1: Boolean);
begin
  Create(Named, '', Arg1);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2: Boolean);
begin
  Create(Named, '', Arg1, Arg2);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2, Arg3: Boolean);
begin
  Create(Named, '', Arg1, Arg2, Arg3);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2, Arg3, Arg4: Boolean);
begin
  Create(Named, '', Arg1, Arg2, Arg3, Arg4);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2, Arg3, Arg4, Arg5: Boolean);
begin
  Create(Named, '', Arg1, Arg2, Arg3, Arg4, Arg5);
end;

constructor TestCaseAttribute.Create(Arg1, Arg2, Arg3, Arg4, Arg5, Arg6: Boolean);
begin
  Create(Named, '', Arg1, Arg2, Arg3, Arg4, Arg6);
end;

{$ENDREGION '***** Boolean *****'}

// ***** TestCaseProviderAttribute *****

constructor TestCaseProviderAttribute.Create(aProviderClass: TClass; const aProviderName: string);
begin
  inherited Create;
  fProviderClass := aProviderClass;
  fProviderName := aProviderName;
end;

constructor TestCaseProviderAttribute.Create(const aProviderName: string);
begin
  inherited Create;
  fProviderName := aProviderName;
end;

// ***** TNxValueConverter *****

constructor TNxValueConverter.Create;
begin
  ConverterSettings := TFormatSettings.Create;
  ConverterSettings.DecimalSeparator := '.';
end;

function TNxValueConverter.Convert(const aValue: string; aType: TRttiType): TValue;
begin
  case aType.TypeKind of
    tkInteger, tkInt64 : Result := TValue.FromOrdinal(aType.Handle, StrToInt64(aValue));
    tkFloat : Result := TValue.From<Double>(StrToFloat(aValue, ConverterSettings));
    else
      Result := aValue;
  end;
end;


// ***** NxRtti *****

class constructor NxRtti.ClassCreate;
begin
  {$IFDEF DELPHI_XE7_UP}
  // Fix for RSP-38281
  TRttiContext.KeepContext;
  {$ENDIF}
  fContext := TRttiContext.Create;
  fContext.FindType('');
  fConverter := TNxValueConverter.Create;
end;

class destructor NxRtti.ClassDestroy;
begin
  fContext.Free;
  {$IFDEF DELPHI_XE7_UP}
  TRttiContext.DropContext;
  {$ENDIF}
end;

class function NxRtti.GetContext: TRttiContext;
begin
  Result := fContext;
end;

class function NxRtti.Convert(const aValue: TValue; aType: TRttiType): TValue;
begin
  if aValue.TypeInfo = aType.Handle then
    Result := aValue
  else
  if (aValue.Kind = tkUString) then
    Result := fConverter.Convert(aValue.AsString, aType)
  else
    Result := aValue;
end;

class function NxRtti.HasAttribute(aRttiObject: TRttiObject; aAttrClass: TClass): Boolean;
var
  lAttr: TCustomAttribute;
begin
  Result := False;
  for lAttr in aRttiObject.GetAttributes do
    if lAttr is aAttrClass then
      begin
        Result := True;
        Break;
      end;
end;

class function NxRtti.HasAttribute(aAttributes: TArray<TCustomAttribute>; aAttrClass: TClass): Boolean;
var
  lAttr: TCustomAttribute;
begin
  Result := False;
  for lAttr in aAttributes do
    if lAttr is aAttrClass then
      begin
        Result := True;
        Break;
      end;
end;

class function NxRtti.AttributeCount(aAttributes: TArray<TCustomAttribute>; aAttrClass: TClass): Integer;
var
  lAttr: TCustomAttribute;
begin
  Result := 0;
  for lAttr in aAttributes do
    if lAttr is aAttrClass then
      Inc(Result);
end;

class function NxRtti.TestCaseName(const aValues: TArray<TValue>): string;
var
  lValue: TValue;
begin
  Result := '';
  for lValue in aValues do
    begin
      if Result = '' then
        Result := lValue.ToString
      else
        Result := Result + ', ' + lValue.ToString;
    end;
end;

end.


