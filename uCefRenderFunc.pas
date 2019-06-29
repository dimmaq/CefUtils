unit uCefRenderFunc;

interface

uses
  System.SysUtils, System.Types, System.Generics.Collections, System.Math,
  //
  uCEFInterfaces, uCEFTypes, uCEFStringMap, uCEFListValue, uCEFDictionaryValue,
  uCEFv8Context,
  //
  uCefUtilFunc;

function CefRenderElementExist(const browser: ICefBrowser;
  const AElement: TElementParams): ICefListValue;
function CefRenderGetElementsAttr(const ABrowser: ICefBrowser;
  const AElement: TElementParams): ICefListValue;
function CefRenderGetElementById(const browser: ICefBrowser; const AId: string): ICefDomNode;
function CefRenderElementSetValueById(const browser: ICefBrowser;
  const AId, AValue: string): Boolean;
function CefRenderElementSetValueByName(const browser: ICefBrowser;
  const AName, AValue: string): Boolean;
function CefRenderElementSetValue(const browser: ICefBrowser;
  const AElem: TElementParams; const AValue: string): Boolean;
function CefRenderElementSetAttrByName(const browser: ICefBrowser;
  const AName, AAttr, AValue: string): Boolean;
function CefRenderGetWindowRect(const ABrowser: ICefBrowser): TRect;
function CefRenderGetElementRect(const ABrowser: ICefBrowser;
  AElement: TElementParams): TRect;
function CefRenderGetBodyRect(const ABrowser: ICefBrowser): TRect;
function CefRenderGetElementText(const ABrowser: ICefBrowser;
  AElement: TElementParams): string;
function CefRenderSelectSetValue(const browser: ICefBrowser;
  const ASelect: TElementParams; const AValue: string): Boolean;

function CefRenderGetElementOuterHtml(const ABrowser: ICefBrowser;
  const AElement: TElementParams): string;
function CefRenderGetElementAsMarkup(const ABrowser: ICefBrowser;
  const AElement: TElementParams): string;
function CefRenderGetElementInnerText(const ABrowser: ICefBrowser;
  const AElement: TElementParams): string;

procedure CefRenderFocusClickInBrowser(const x, y: Integer; const ACallback: ICefv8Value);
procedure CefRenderClickInBrowser(const x, y: Integer; const ACallback: ICefv8Value);
procedure CefRenderKeyPressInBrowser(const AKey: Integer; const ACallback: ICefv8Value);

implementation

uses

  //
  uCefDomVisitFunc, uCefUtilConst, uCefUtilCallbackList;

function CefRenderGetElementById(const browser: ICefBrowser; const AId: string): ICefDomNode;
var res: ICefDomNode;
begin
  browser.MainFrame.VisitDomProc(
    procedure(const document: ICefDomDocument)
    begin
      res := document.GetElementById(AId);
    end);
  Result := res;
end;

function CefRenderElementExist(const browser: ICefBrowser;
  const AElement: TElementParams): ICefListValue;
var
  res: ICefListValue;
  el: TElementParams;
begin
  res := nil;
  el := AElement;
  browser.MainFrame.VisitDomProc(
    procedure(const ADocument: ICefDomDocument)
    var
      node: ICefDomNode;
      attr: ICefStringMap;
    begin
      node := CefVisitGetElement(ADocument, el, nil);
      if Assigned(node) then
      begin
        attr := TCefStringMapOwn.Create();
        node.GetElementAttributes(attr);
        res := TCefListValueRef.New;
        res.SetString(IDX_TAG, node.ElementTagName);
        res.SetDictionary(IDX_ATTR, CefStringMapToDictValue(attr));
      end;
    end);
  Result := res;
end;

function CefRenderGetElementsAttr(const ABrowser: ICefBrowser;
  const AElement: TElementParams): ICefListValue;
var
  res: ICefListValue;
  el: TElementParams;
begin
  res := nil;
  el := AElement;
  ABrowser.MainFrame.VisitDomProc(
    procedure(const ADocument: ICefDomDocument)
    var
      nodes: TArray<ICefDomNode>;
      node: ICefDomNode;
      item: ICefDictionaryValue;
      attr: ICefStringMap;
      j: Integer;
    begin
      nodes := CefVisitGetElements(ADocument, el, nil, MaxInt);
      if Length(nodes) > 0 then
      begin
        res := TCefListValueRef.New();
        j := 0;
        for node in nodes do
        begin
          attr := TCefStringMapOwn.Create();
          node.GetElementAttributes(attr);
          item := CefStringMapToDictValue(attr);
          item.SetString(KEY_TAG, node.ElementTagName);
          res.SetDictionary(j, item);
          Inc(j)
        end;
      end;
    end);
  Result := res;
end;

function CefRenderGetElementOuterHtml(const ABrowser: ICefBrowser;
  const AElement: TElementParams): string;
begin
  Result := CefRenderGetElementAsMarkup(ABrowser, AElement)
end;

function CefRenderGetElementAsMarkup(const ABrowser: ICefBrowser;
  const AElement: TElementParams): string;
var
  res: string;
  el: TElementParams;
begin
  res := '';
  el := AElement;
  ABrowser.MainFrame.VisitDomProc(
    procedure(const ADocument: ICefDomDocument)
    var
      node: ICefDomNode;
    begin
      node := CefVisitGetElement(ADocument, el, nil);
      if Assigned(node) then
      begin
        res := node.AsMarkup;
      end;
    end);
  Result := res;
end;

function CefRenderGetElementInnerText(const ABrowser: ICefBrowser;
  const AElement: TElementParams): string;
var
  res: string;
  el: TElementParams;
begin
  res := '';
  el := AElement;
  ABrowser.MainFrame.VisitDomProc(
    procedure(const ADocument: ICefDomDocument)
    var
      node: ICefDomNode;
    begin
      node := CefVisitGetElement(ADocument, el, nil);
      if Assigned(node) then
      begin
        res := node.ElementInnerText;
      end;
    end);
  Result := res;
end;

function CefRenderElementSetValueById(const browser: ICefBrowser; const AId, AValue: string): Boolean;
var res: Boolean;
begin
  res := False;
  browser.MainFrame.VisitDomProc(
    procedure(const document: ICefDomDocument)
    var nod: ICefDomNode;
    begin
      nod := document.GetElementById(AId);
      if Assigned(nod) then
      begin
        res := nod.SetElementAttribute('value', AValue);
      end;
    end
  );
  Result := res
end;

function CefRenderElementSetValueByName(const browser: ICefBrowser; const AName, AValue: string): Boolean;
var res: Boolean;
begin
  res := False;
  browser.MainFrame.VisitDomProc(
    procedure(const document: ICefDomDocument)
    var nod: ICefDomNode;
    begin
      nod := CefVisitGetElementByName(document, AName);
      if Assigned(nod) then
      begin
        res := nod.SetElementAttribute('value', AValue)
      end;
    end
  );
  Result := res
end;

function CefRenderElementSetValue(const browser: ICefBrowser;
  const AElem: TElementParams; const AValue: string): Boolean;
var
  res: Boolean;
  el: TElementParams;
begin
  el := AElem;
  res := False;
  browser.MainFrame.VisitDomProc(
    procedure(const document: ICefDomDocument)
    var nod: ICefDomNode;
    begin
      nod := CefVisitGetElement(document, el);
      if Assigned(nod) then
      begin
        res := nod.SetElementAttribute('value', AValue)
      end;
    end
  );
  Result := res
end;

function CefRenderElementSetAttrByName(const browser: ICefBrowser; const AName, AAttr, AValue: string): Boolean;
var res: Boolean;
begin
  res := False;
  browser.MainFrame.VisitDomProc(
    procedure(const document: ICefDomDocument)
    var nod: ICefDomNode;
    begin
      nod := CefVisitGetElementByName(document, AName);
      if Assigned(nod) then
      begin
        res := nod.SetElementAttribute(AAttr, AValue)
      end;
    end
  );
  Result := res
end;

function CefRenderGetWindowRect(const ABrowser: ICefBrowser): TRect;
var
//  el: ICefDomNode;
//  msg: ICefProcessMessage;
//  arg: ICefListValue;
  context: ICefv8Context;
  x,y,wh,ww: Integer;

  function getVal(const AName: string; var AVal: Integer): Boolean;
  var
    excp: ICefV8Exception;
    val: ICefV8Value;
  begin
    context.Eval(AName, '', 0, val, excp);
    if not val.IsValid then Exit(True);
    AVal := val.GetIntValue;
    Exit(False)
  end;

begin
  Result := TRect.Empty;
  context := ABrowser.MainFrame.GetV8Context;
  if (context <> nil) then
  begin
    // прокручено вниз
    if getVal('window.pageYOffset', y) then
      Exit;
    // прокручено вправо
    if getVal('window.pageXOffset', x) then
      Exit;
    // ширина окна
    if getVal('window.innerWidth', ww) then
      Exit;
    // высота окна
    if getVal('window.innerHeight', wh) then
      Exit;

    Result.Left := x;
    Result.Top := y;
    Result.Right := x + ww;
    Result.Bottom := y + wh;
  end;
end;

function CefRenderGetBodyRect(const ABrowser: ICefBrowser): TRect;
var
  context: ICefv8Context;
  bh,bw,hh: Integer;

  function getVal(const AName: string; var AVal: Integer): Boolean;
  var
    excp: ICefV8Exception;
    val: ICefV8Value;
  begin
    context.Eval(AName, '', 0, val, excp);
    if not val.IsValid then Exit(True);
    AVal := val.GetIntValue;
    Exit(False)
  end;

begin
  Result := TRect.Empty;
  context := ABrowser.MainFrame.GetV8Context;
  if (context <> nil) then
  begin
    // высота страницы
    if getVal('document.body.scrollHeight', bh) then
      Exit;
    // ширина страницы
    if getVal('document.body.scrollWidth', bw) then
      Exit;
    // высота страницы
    hh := 0;
    //if getVal('document.documentElement.scrollHeight', hh) then
    //  Exit;

    Result.Left := 0;
    Result.Top := 0;
    Result.Right := bw;
    Result.Bottom := Max(bh, hh)
  end;
end;

function CefRenderGetElementRect(const ABrowser: ICefBrowser;
  AElement: TElementParams): TRect;
var
  res: TRect;

begin
  res := TRect.Empty;
  ABrowser.MainFrame.VisitDomProc(
    procedure(const ADocument: ICefDomDocument)
    var
      node: ICefDomNode;
      nodeRect: TCefRect;
    begin
      node := CefVisitGetElement(ADocument, AElement, nil);
      if Assigned(node) then
      begin
        nodeRect := node.ElementBounds;

        res.Left := nodeRect.X;
        res.Top := nodeRect.Y;
        res.Width := nodeRect.width;
        res.Height := nodeRect.height;
      end;
    end
  );

  Result := res
end;

function CefRenderGetElementText(const ABrowser: ICefBrowser;
  AElement: TElementParams): string;
begin
  Result := CefRenderGetElementInnerText(ABrowser, AElement)
end;


function CefRenderSelectSetValue(const browser: ICefBrowser;
  const ASelect: TElementParams; const AValue: string): Boolean;
var
  res: Boolean;
  el: TElementParams;
begin
  el := ASelect;
  res := False;
  browser.MainFrame.VisitDomProc(
    procedure(const document: ICefDomDocument)
    var nod: ICefDomNode;
    begin
      nod := CefVisitGetElement(document, el);
      if not Assigned(nod) then
        Exit;
      nod := nod.FirstChild;
      while Assigned(nod) do
      begin
        if CompareText(nod.ElementTagName, 'option') = 0 then
        begin
          if nod.GetElementAttribute('value') = AValue then
          begin
            res := nod.SetElementAttribute('selected', 'selected');
            Exit
          end;
        end;
        nod := nod.NextSibling;
      end
    end
  );
  Result := res
end;

procedure FocusClickInBrowser(const AFocus: Boolean; const x, y: Integer; const ACallback: ICefv8Value);
var
  msg: ICefProcessMessage;
  arg: ICefListValue;
  cbId, k: Integer;
begin
  cbId := gCallbackList.Add(ACallback);
  if AFocus then k := VAL_FOCUSCLICK_XY else k := VAL_CLICK_XY;
  msg := CefAppMessageType(k, arg);
  arg.SetInt(IDX_CLICK_CALLBACKID, cbId);
  arg.SetInt(IDX_CLICK_X, x);
  arg.SetInt(IDX_CLICK_Y, y);
  CefSendProcessMessageCurrentContextToBrowser(msg);
end;

procedure CefRenderClickInBrowser(const x, y: Integer; const ACallback: ICefv8Value);
begin
  FocusClickInBrowser(False, x, y, ACallback)
end;

procedure CefRenderFocusClickInBrowser(const x, y: Integer; const ACallback: ICefv8Value);
begin
  FocusClickInBrowser(True, x, y, ACallback)
end;


procedure CefRenderKeyPressInBrowser(const AKey: Integer; const ACallback: ICefv8Value);
var
  msg: ICefProcessMessage;
  arg: ICefListValue;
  cbId: Integer;
begin
  cbId := gCallbackList.Add(ACallback);

  msg := CefAppMessageType(VAL_KEY_PRESS, arg);
  arg.SetInt(IDX_KEY_CALLBACKID, cbId);
  arg.SetInt(IDX_KEY_CODE, AKey);
  CefSendProcessMessageCurrentContextToBrowser(msg);
end;

end.
