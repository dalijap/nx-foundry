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

unit NX.Foundry.Config;

{$I 'NX.inc'}

interface

uses
  {$IFDEF NAMESPACES}
  System.SysUtils,
  System.Classes,
  System.Variants,
  Xml.XMLDoc,
  Xml.XMLIntf,
  {$ELSE}
  SysUtils,
  Classes,
  Variants,
  XMLDoc,
  XMLIntf,
  {$ENDIF}
  NX.Foundry.TestFramework;

type
  TNxTestConfig = class
  protected
    fFileName: string;
    fDisabledTests: TNxStringArray;
  public
    constructor Create(const aFileName: string);
    procedure LoadFromFile;
    procedure SaveToFile;
    property DisabledTests: TNxStringArray read fDisabledTests write fDisabledTests;
  end;

implementation

// ***** TNxTestConfig *****

constructor TNxTestConfig.Create(const aFileName: string);
begin
  inherited Create;
  fFileName := aFileName;
end;

procedure TNxTestConfig.LoadFromFile;
var
  lDoc: IXMLDocument;
  lConfig: IXMLNode;
  lValue: string;
  sl: TStringList;
  i: integer;
begin
  SetLength(fDisabledTests, 0);
  if FileExists(fFileName) then
    try
      lDoc := TXMLDocument.Create(nil);
      lDoc.LoadFromFile(fFileName);
      if Assigned(lDoc.Node) then
        lConfig := lDoc.Node.ChildNodes.FindNode('config');
      if Assigned(lConfig) and (lConfig.NodeName = 'config') then
        begin
          lValue := VarToStr(lConfig.ChildValues['disabled_tests']);
          sl := TStringList.Create;
          try
            sl.Text := lValue;
            SetLength(fDisabledTests, sl.Count);
            for i := 0 to High(fDisabledTests) do
              fDisabledTests[i] := sl[i];
          finally
            sl.Free;
          end;
        end;
    except
    end;
end;

procedure TNxTestConfig.SaveToFile;
var
  lDoc: IXMLDocument;
  lConfig, lTests: IXMLNode;
  lValue: string;
  i: integer;
begin
  try
    lDoc := TXMLDocument.Create(nil);
    lDoc.Active := True;
    lDoc.Options := [doNodeAutoIndent];
    lConfig := lDoc.AddChild('config');
    lTests := lConfig.AddChild('disabled_tests');
    for i := 0 to High(fDisabledTests) do
      if i = 0 then
        lValue := fDisabledTests[i]
      else
        lValue := lValue + #13#10 + fDisabledTests[i];
    lTests.NodeValue := lValue;
    lDoc.SaveToFile(fFileName);
  except
  end;
end;

end.
