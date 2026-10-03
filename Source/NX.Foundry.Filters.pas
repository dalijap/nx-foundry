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

unit NX.Foundry.Filters;

{$I 'NX.inc'}

interface

uses
  {$IFDEF NAMESPACES}
  System.Classes,
  {$ELSE}
  Classes,
  {$ENDIF}
  NX.Foundry.TestFramework;

type
  INxTestMultiFilter = interface(INxTestFilter)
    procedure AddFilter(const aFilter: INxTestFilter);
  end;

  INxTestStringsFilter = interface(INxTestFilter)
    procedure AddString(const aValue: string);
    procedure AddStrings(const aValues: array of string);
  end;

  TNxTestMultiFilter = class(TInterfacedObject)
  protected
    fFilters: TNxTestFilterList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddFilter(const aFilter: INxTestFilter);
  end;

  TNxTestAnyFilter = class(TNxTestMultiFilter, INxTestFilter, INxTestMultiFilter)
  public
    function Matches(const aTest: INxTest): Boolean;
  end;

  TNxTestAllFilters = class(TNxTestMultiFilter, INxTestFilter, INxTestMultiFilter)
  public
    function Matches(const aTest: INxTest): Boolean;
  end;

  TNxTestStringsFilter = class(TInterfacedObject)
  protected
    fItems: TStringList;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    procedure AddString(const aValue: string);
    procedure AddStrings(const aValues: array of string);
  end;

  TNxTestNameFilter = class(TNxTestStringsFilter, INxTestFilter, INxTestStringsFilter)
  public
    function Matches(const aTest: INxTest): Boolean;
  end;

  TNxTestAnyCategoryFilter = class(TNxTestStringsFilter, INxTestFilter, INxTestStringsFilter)
  public
    function Matches(const aTest: INxTest): Boolean;
  end;

  TNxTestAllCategoriesFilter = class(TNxTestStringsFilter, INxTestFilter, INxTestStringsFilter)
  public
    function Matches(const aTest: INxTest): Boolean;
  end;

  TNxTestNoCategoriesFilter = class(TNxTestStringsFilter, INxTestFilter, INxTestStringsFilter)
  public
    function Matches(const aTest: INxTest): Boolean;
  end;

implementation

// ***** TNxTestMultiFilter *****

constructor TNxTestMultiFilter.Create;
begin
  fFilters := TNxTestFilterList.Create;
end;

destructor TNxTestMultiFilter.Destroy;
begin
  fFilters.Free;
  inherited;
end;

procedure TNxTestMultiFilter.AddFilter(const aFilter: INxTestFilter);
begin
  if Assigned(aFilter) then
    fFilters.Add(aFilter);
end;

// ***** TNxTestAnyFilter *****

function TNxTestAnyFilter.Matches(const aTest: INxTest): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to fFilters.Count - 1 do
    begin
      Result := fFilters[i].Matches(aTest);
      if Result then
        Exit;
    end;
end;

// ***** TNxTestAllFilters *****

function TNxTestAllFilters.Matches(const aTest: INxTest): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to fFilters.Count - 1 do
    begin
      Result := fFilters[i].Matches(aTest);
      if not Result then
        Exit;
    end;
end;

// ***** TNxTestStringsFilter *****

constructor TNxTestStringsFilter.Create;
begin
  fItems := TStringList.Create;
  fItems.Sorted := True;
  fItems.Duplicates := dupIgnore;
end;

destructor TNxTestStringsFilter.Destroy;
begin
  fItems.Free;
  inherited;
end;

procedure TNxTestStringsFilter.AddString(const aValue: string);
begin
  fItems.Add(aValue);
end;

procedure TNxTestStringsFilter.AddStrings(const aValues: array of string);
var
  i: Integer;
begin
  for i := 0 to High(aValues) do
    fItems.Add(aValues[i]);
end;

// ***** TNxTestNameFilter *****

function TNxTestNameFilter.Matches(const aTest: INxTest): Boolean;
var
  Idx: Integer;
begin
  if fItems.Count = 0 then
    Result := True
  else
    Result := fItems.Find(aTest.FullTestName, Idx);
end;

// ***** TNxTestAnyCategoryFilter *****

function TNxTestAnyCategoryFilter.Matches(const aTest: INxTest): Boolean;
var
  i, Idx: Integer;
  lCategories: TNxStringArray;
begin
  Result := False;
  lCategories := aTest.Categories;
  for i := 0 to High(lCategories) do
    begin
      Result := fItems.Find(lCategories[i], Idx);
      if Result then
        Exit;
    end;
end;

// ***** TNxTestAllCategoriesFilter *****

function TNxTestAllCategoriesFilter.Matches(const aTest: INxTest): Boolean;
var
  i: Integer;
  lCategories: TNxStringArray;
begin
  Result := False;
  lCategories := aTest.Categories;
  for i := 0 to fItems.Count - 1 do
    begin
      Result := ContainsString(lCategories, fItems[i]);
      if not Result then
        Exit;
    end;
end;

// ***** TNxTestNoCategoriesFilter *****

function TNxTestNoCategoriesFilter.Matches(const aTest: INxTest): Boolean;
var
  i: Integer;
  lCategories: TNxStringArray;
begin
  Result := True;
  lCategories := aTest.Categories;
  for i := 0 to fItems.Count - 1 do
    begin
      Result := not ContainsString(lCategories, fItems[i]);
      if not Result then
        Exit;
    end;
end;

end.
