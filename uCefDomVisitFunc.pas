unit uCefDomVisitFunc;

interface

uses
  Classes, System.SysUtils, System.Types, System.IoUtils,
  System.Generics.Collections,
  //
  uCEFInterfaces, uCEFTypes,
  //
  uCefUtilFunc;

type
  TCefDomNodeFilterProc = function(const ANode: ICefDomNode): Boolean;

function CefVisitGetElementsRoot(const ARoot: ICefDomNode;
  const AElement: TElementParams; const AFilter: TCefDomNodeFilterProc;
  const ALimit: Integer): TArray<ICefDomNode>;
function CefVisitGetElements(const ADocument: ICefDomDocument;
    const AElement: TElementParams; const AFilter: TCefDomNodeFilterProc;
    const ALimit: Integer): TArray<ICefDomNode>;
function CefVisitGetElementRoot(const ARoot: ICefDomNode;
  const AElement: TElementParams;
  const AFilter: TCefDomNodeFilterProc): ICefDomNode;
function CefVisitGetElement(const ADocument: ICefDomDocument;
    const AElement: TElementParams;
    const AFilter: TCefDomNodeFilterProc = nil): ICefDomNode;
function CefVisitGetElementByName(const ADocument: ICefDomDocument;
    const AName: string): ICefDomNode;

implementation

uses
  //
  uRegExprFunc, uStringUtils;

function CefVisitGetElementsRoot(const ARoot: ICefDomNode;
  const AElement: TElementParams; const AFilter: TCefDomNodeFilterProc;
  const ALimit: Integer): TArray<ICefDomNode>;
var
  l_elem: ICefDomNode;
  l_arr: TList<ICefDomNode>;
  l_class, l_name, l_tag: string;

  function TestTag(const AElem: ICefDomNode): Boolean;
  begin
    Result := l_tag.IsEmpty or (l_tag = LowerCase(Trim(AElem.ElementTagName)))
  end;
  function TestName(const AElem: ICefDomNode): Boolean;
  begin
    Result := l_name.IsEmpty or (l_name = LowerCase(Trim(AElem.GetElementAttribute('name'))))
  end;
  function TestClass(const AElem: ICefDomNode): Boolean;
  var elclass, z: string;
  begin
    if l_class.IsEmpty then
      Exit(True);
    elclass := LowerCase(Trim(AElem.GetElementAttribute('class')));
    while elclass <> '' do
    begin
      z := Trim(StrCut(elclass, [#0..#32]));
      if z = l_class then
        Exit(True);
      elclass := Trim(elclass);
    end;
    Exit(False);
  end;
  function TestAttr(const AElem: ICefDomNode): Boolean;
  var attrval: string;
  begin
    if AElement.AttrName.IsEmpty or AElement.AttrValue.IsEmpty then
      Exit(True);
    attrval := LowerCase(Trim((AElem.GetElementAttribute(AElement.AttrName))));
    Result := YesRegExpr(attrval, AElement.AttrValue)
  end;
  function TestText(const AElem: ICefDomNode): Boolean;
  var val: string;
  begin
    if AElement.Text.IsEmpty then
      Exit(True);
    if not AElem.HasChildren then
      Exit(False);
    if AElem.FirstChild = nil then
      Exit(False);
    if not AElem.FirstChild.IsSame(AElem.LastChild) then // there is one child
      Exit(False);
    if not AElem.FirstChild.IsText then
      Exit(False);
    val := AElem.FirstChild.AsMarkup;
    Result := YesRegExpr(val, AElement.Text);
  end;

  function TestFilter(const AElem: ICefDomNode): Boolean;
  begin
    if Assigned(AElem) then
      if AElem.IsElement then
        if TestTag(AElem)  then
          if TestName(AElem) then
            if TestClass(AElem) then
              if not Assigned(AFilter) or AFilter(AElem) then
                if TestAttr(aElem) then
                  if TestText(aElem) then
                    Exit(True);
    Exit(False);
  end;
  function ProcessNode(const ANode: ICefDomNode; const AList: TList<ICefDomNode>; const ALevel: Integer): Boolean;
  var Node: ICefDomNode;
  begin
    if Assigned(ANode) then
    begin
      Node := ANode.FirstChild;
      while Assigned(Node) do
      begin
        if TestFilter(Node) then
        begin
          AList.Add(Node);
          if AList.Count >= ALimit then
            Exit(True);
        end;
        if ProcessNode(Node, AList, ALevel + 1) then
          Exit(True);
        Node := Node.NextSibling;
      end;
    end;
    Exit(False)
  end;


begin
  Result := nil;
  if ARoot = nil then
    Exit;

  l_class := LowerCase(Trim(AElement.Class_));
  l_name := LowerCase(Trim(AElement.Name));
  l_tag := LowerCase(Trim(AElement.Tag));

  if AElement.Id <> '' then
  begin
    l_elem := ARoot.Document.getElementById(AElement.Id);
    if TestFilter(l_elem) then
    begin
      SetLength(Result, 1);
      Result[0] := l_elem;
    end;
    Exit;
  end;

  l_arr := TList<ICefDomNode>.Create;
  try
    ProcessNode(ARoot, l_arr, 0);
    Result := l_arr.ToArray;
  finally
    l_arr.Free
  end;
end;

function CefVisitGetElements(const ADocument: ICefDomDocument;
  const AElement: TElementParams; const AFilter: TCefDomNodeFilterProc;
  const ALimit: Integer): TArray<ICefDomNode>;
begin
  Result := nil;
  if ADocument = nil then
    Exit;
  Result := CefVisitGetElementsRoot(ADocument.Document, AElement, AFilter, ALimit)
end;

function CefVisitGetElement(const ADocument: ICefDomDocument;
  const AElement: TElementParams;
  const AFilter: TCefDomNodeFilterProc): ICefDomNode;
var arr: TArray<ICefDomNode>;
begin
  arr := CefVisitGetElements(ADocument, AElement, AFilter, 1);
  if Length(arr) > 0 then
    Exit(arr[0]);
  Exit(nil)
end;

function CefVisitGetElementRoot(const ARoot: ICefDomNode;
  const AElement: TElementParams;
  const AFilter: TCefDomNodeFilterProc): ICefDomNode;
var arr: TArray<ICefDomNode>;
begin
  arr := CefVisitGetElementsRoot(ARoot, AElement, AFilter, 1);
  if Length(arr) > 0 then
    Exit(arr[0]);
  Exit(nil)
end;


function CefVisitGetElementByName(const ADocument: ICefDomDocument; const AName: string): ICefDomNode;
begin
  Result := CefVisitGetElement(ADocument, TElementParams.CreateTagName('', AName), nil)
end;

end.
