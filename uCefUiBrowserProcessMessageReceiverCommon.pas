unit uCefUIBrowserProcessMessageReceiverCommon;

interface

uses
  System.SysUtils, System.Generics.Collections, System.Classes,
  //
  uCEFApplication, uCefTypes, uCefInterfaces, uCefChromium,
  //
  uCefUIBrowserProcessMessageReceiver
  ;

type
  TCefUIBrowserProcessMessageReceiverCommon = class(TCefUIBrowserProcessMessageReceiver)
  protected
    procedure Receive(Sender: TObject; const ABrowser: ICefBrowser;
      ASourceProcess: TCefProcessId; const AMessage: ICefProcessMessage;
      out AResult: Boolean); override;
  public
    constructor Create;
  end;

implementation

uses
  uCEFProcessMessage, uCEFMiscFunctions,
  //
  uCefUtilConst, uCefWaitEventList, uCefUtilFunc, uCefUIFunc;

{ TCefUIBrowserProcessMessageReceiverCommon }

constructor TCefUIBrowserProcessMessageReceiverCommon.Create;
begin
  inherited Create(MYAPP_CEF_MESSAGE_NAME)
end;

procedure TCefUIBrowserProcessMessageReceiverCommon.Receive(Sender: TObject;
  const ABrowser: ICefBrowser; ASourceProcess: TCefProcessId;
  const AMessage: ICefProcessMessage; out AResult: Boolean);
var
  arg: ICefListValue;
  event: TCefWaitEventItem;
  eventId: Integer;
  z: string;
begin
  AResult := False;
  arg := AMessage.ArgumentList.Copy();
  if arg.GetType(IDX_TYPE) = VTYPE_INT then
  begin
    AResult := True;
    case arg.GetInt(IDX_TYPE) of
      VAL_CLICK_XY:      CefUIFocusClickAndCallbackAsync(False, ABrowser, arg);
      VAL_FOCUSCLICK_XY: CefUIFocusClickAndCallbackAsync(True, ABrowser, arg);
      VAL_KEY_PRESS:     CefUIKeyPressAsync(ABrowser, arg);
    else
      AResult := False;
    end;
  end
  else
  begin
    z := 'msgRecv:' + AMessage.Name + ' ';
    eventId := arg.GetInt(IDX_EVENT);
    z := z + 'bid:' + ABrowser.Identifier.ToString + ' eid:' + IntToStr(eventId) + ' ';
    event := CefWaitEventGet(eventId);
    if Assigned(event) then
    begin
      z := z + 'tick:' + IntToStr(event.TickDif()) + ' res:' + CefListValueToJsonStr(arg);
      event.Res := arg;
      event.Event.SetEvent();
      AResult := True;
    end;
    CefLog('frame', 138, 1, z);
  end;
end;

initialization
  CefUIBrowserProcessMessageReceiverAdd(TCefUIBrowserProcessMessageReceiverCommon.Create())

end.
