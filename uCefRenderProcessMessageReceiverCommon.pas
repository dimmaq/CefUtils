unit uCefRenderProcessMessageReceiverCommon;

interface

uses
  System.Types,
  //
  uCEFApplication, uCEFRenderProcessHandler, uCefTypes, uCefInterfaces,
  //
  uCefRenderProcessMessageReceiver;

type
  TCefRenderProcessMessageReceiverCommon = class(TCefRenderProcessMessageReceiver)
  private
  protected
    procedure Receive(const ABrowser: ICefBrowser; ASourceProcess: TCefProcessId;
      const AMessage: ICefProcessMessage; var AHandled: boolean); override;
  public
    constructor Create;
  end;

implementation

uses
  System.SysUtils, Winapi.Windows,
  //
  AcedCommon,
  //
  uCEFProcessMessage, uCEFMiscFunctions,
  //
  uCefUtilConst, uCefRenderFunc, uCefUtilFunc, uCefUtilCallbackList;

function TestIdExists(const ABrowser: ICefBrowser; const AId: string): ICefProcessMessage;
var el: ICefDomNode;
begin
  el := CefRenderGetElementById(ABrowser, AId);
  Result := CefAppMessageResultNew(Assigned(el));
end;

function SetValueById(const ABrowser: ICefBrowser; const AId, AValue: string): ICefProcessMessage;
var bol: Boolean;
begin
  bol := CefRenderElementSetValueById(ABrowser, AId, AValue);
  Result := CefAppMessageResultNew(bol);
end;

function SetValueByName(const ABrowser: ICefBrowser; const AName, AValue: string): ICefProcessMessage;
var bol: Boolean;
begin
  bol := CefRenderElementSetValueByName(ABrowser, AName, AValue);
  Result := CefAppMessageResultNew(bol);
end;

function SetAttrByName(const ABrowser: ICefBrowser; const AName, AAttr, AValue: string): ICefProcessMessage;
var bol: Boolean;
begin
  bol := CefRenderElementSetAttrByName(ABrowser, AName, AAttr, AValue);
  Result := CefAppMessageResultNew(bol)
end;

procedure RectToArgs(const ARect: TRect; const AArgs: ICefListValue);
begin
  AArgs.SetInt(IDX_LEFT,   ARect.Left);
  AArgs.SetInt(IDX_TOP,    ARect.Top);
  AArgs.SetInt(IDX_RIGHT,  ARect.Right);
  AArgs.SetInt(IDX_BOTTOM, ARect.Bottom);
end;

function GetWindowRect(const ABrowser: ICefBrowser): ICefProcessMessage;
var
  r: TRect;
  msg: ICefProcessMessage;
  arg: ICefListValue;
begin
  r := CefRenderGetWindowRect(ABrowser);
  msg := CefAppMessageArgs(arg);
  RectToArgs(r, arg);
  Result := msg;
end;

function GetBodyRect(const ABrowser: ICefBrowser): ICefProcessMessage;
var
  r: TRect;
  msg: ICefProcessMessage;
  arg: ICefListValue;
begin
  r := CefRenderGetBodyRect(ABrowser);
  msg := CefAppMessageArgs(arg);
  RectToArgs(r, arg);
  Result := msg;
end;

function GetElementRect(const ABrowser: ICefBrowser;
    const AArgs: ICefListValue): ICefProcessMessage;
var
  r: TRect;
  msg: ICefProcessMessage;
  arg: ICefListValue;
  el: TElementParams;
begin
  el := TElementParams.CreateCefListValue(AArgs);
  r := CefRenderGetElementRect(ABrowser, el);

  msg := CefAppMessageArgs(arg);
  RectToArgs(r, arg);
  Result := msg;
end;

function TestElementExists(const ABrowser: ICefBrowser;
    const AArgs: ICefListValue): ICefProcessMessage;
var
  res: ICefListValue;
begin
  res := CefRenderElementExist(ABrowser, TElementParams.CreateCefListValue(AArgs));

  Result := CefAppMessageResultNew(res)
end;

function SetElementValue(const ABrowser: ICefBrowser;
    const AArgs: ICefListValue): ICefProcessMessage;
var
  bol: Boolean;
begin
  bol := CefRenderElementSetValue(ABrowser, ElemByCefList(AArgs), AArgs.GetString(IDX_VALUE2));
  Result := CefAppMessageResultNew(bol);
end;

function SetSelectValue(const ABrowser: ICefBrowser;
  const AArgs: ICefListValue): ICefProcessMessage;
var
  bol: Boolean;
begin
  bol := CefRenderSelectSetValue(ABrowser, ElemByCefList(AArgs), AArgs.GetString(IDX_VALUE2));
  Result := CefAppMessageResultNew(bol);
end;

function GetElementsAttr(const ABrowser: ICefBrowser;
  const AArgs: ICefListValue): ICefProcessMessage;
begin
  Result := CefAppMessageResultNew(CefRenderGetElementsAttr(ABrowser, ElemByCefList(AArgs)))
end;

function GetElementOuterHtml(const ABrowser: ICefBrowser;
  const AArgs: ICefListValue): ICefProcessMessage;
begin
  Result := CefAppMessageResultNew(CefRenderGetElementOuterHtml(ABrowser, ElemByCefList(AArgs)))
end;

function GetElementInnerText(const ABrowser: ICefBrowser;
  const AArgs: ICefListValue): ICefProcessMessage;
begin
  Result := CefAppMessageResultNew(CefRenderGetElementInnerText(ABrowser, ElemByCefList(AArgs)))
end;

function GetElementAsMarkup(const ABrowser: ICefBrowser;
  const AArgs: ICefListValue): ICefProcessMessage;
begin
  Result := CefAppMessageResultNew(CefRenderGetElementAsMarkup(ABrowser, ElemByCefList(AArgs)))
end;

procedure RenderExecCallback(const ABrowser: ICefBrowser;
  const AArgs: ICefListValue);
var id: Integer;
begin
  id := AArgs.GetInt(IDX_CALLBACK_ID);
  gCallbackList.Execute(id)
end;


{ TCefRenderProcessMessageReceiverCommon }

constructor TCefRenderProcessMessageReceiverCommon.Create;
begin
  inherited Create(MYAPP_CEF_MESSAGE_NAME);
end;

procedure TCefRenderProcessMessageReceiverCommon.Receive(
  const ABrowser: ICefBrowser; ASourceProcess: TCefProcessId;
  const AMessage: ICefProcessMessage; var AHandled: boolean);
var
  eventId: Integer;
  msg: ICefProcessMessage;
  arg: ICefListValue;
  tick: Cardinal;
begin
  AHandled := True;
  //---
  tick := GetTickCount();
  arg := AMessage.ArgumentList;
  eventId := arg.GetInt(IDX_EVENT);
  CefLog('uAppCefRenderMessage', 145, 1, Format('render msgRecv eid:%d %s', [eventId, CefListValueToJsonStr(arg)]));
  msg := nil;
  case arg.GetInt(IDX_TYPE) of
    VAL_TEST_ID_EXISTS:      msg := TestIdExists(ABrowser, arg.GetString(IDX_ID));
    VAL_SET_VALUE_BY_ID:     msg := SetValueById(ABrowser, arg.GetString(IDX_ID), arg.GetString(IDX_VALUE));
    VAL_SET_VALUE_BY_NAME:   msg := SetValueByName(ABrowser, arg.GetString(IDX_NAME), arg.GetString(IDX_VALUE));
    VAL_SET_ATTR_BY_NAME:    msg := SetAttrByName(ABrowser, arg.GetString(IDX_NAME), arg.GetString(IDX_ATTR), arg.GetString(IDX_VALUE));
    VAL_GET_WINDOW_RECT:     msg := GetWindowRect(ABrowser);
    VAL_GET_ELEMENT_RECT:    msg := GetElementRect(ABrowser, arg);
    VAL_TEST_ELEMENT_EXISTS: msg := TestElementExists(ABrowser, arg);
    VAL_GET_BIDY_RECT:       msg := GetBodyRect(ABrowser);
    VAL_GET_ELEMENT_TEXT:    msg := GetElementInnerText(ABrowser, arg);
    VAL_SET_ELEMENT_VALUE:   msg := SetElementValue(ABrowser, arg);
    VAL_SET_SELECT_VALUE:    msg := SetSelectValue(ABrowser, arg);
    VAL_GET_ELEMENTS_ATTR:   msg := GetElementsAttr(ABrowser, arg);
    VAL_OUTERHTML          : msg := GetElementOuterHtml(ABrowser, arg);
    VAL_INNERTEXT          : msg := GetElementInnerText(ABrowser, arg);
    VAL_ASMARKUP           : msg := GetElementAsMarkup(ABrowser, arg);
    VAL_EXEC_CALLBACK:       RenderExecCallback(ABrowser, arg);
    {...}
    else
      msg := CefAppMessageNew();
  end;

  arg := nil;
  if Assigned(msg) then
  begin
    arg := msg.ArgumentList;
    arg.SetInt(IDX_EVENT, eventId);
    tick := G_TickCountSince(tick);
    CefLog('uAppCefRenderMessage', 167, 1, Format('render send time:%d eid:%d %s', [tick, eventId, CefListValueToJsonStr(arg)]));
    ABrowser.SendProcessMessage(ASourceProcess, msg);
  end;
end;

initialization
  CefAppRenderProcessMessageReceiverAdd(TCefRenderProcessMessageReceiverCommon.Create())

end.
