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

  NxRtti = class
  protected
    class var fContext: TRttiContext;
    class constructor ClassCreate;
    class destructor ClassDestroy;
    class function GetContext: TRttiContext; static;
  public
    class property Context: TRttiContext read GetContext;
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

// ***** NxRtti *****

class constructor NxRtti.ClassCreate;
begin
  {$IFDEF DELPHI_XE7_UP}
  // Fix for RSP-38281
  TRttiContext.KeepContext;
  {$ENDIF}
  fContext := TRttiContext.Create;
  fContext.FindType('');
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

end.
