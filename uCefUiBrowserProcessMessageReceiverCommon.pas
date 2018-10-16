unit uCefUIBrowserProcessMessageReceiverCommon;

interface

uses
  System.SysUtils, System.Generics.Collections,
  //
  uCEFApplication, uCefTypes, uCefInterfaces, uCefChromium,
  //
  uCefUIBrowserProcessMessageReceiver
  ;

type
  TCefUIBrowserProcessMessageReceiverCommon = class(TCefUIBrowserProcessMessageReceiver)
  private
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
  arg := amessage.ArgumentList;
  if arg.GetType(IDX_TYPE) = VTYPE_INT then
  begin
    AResult := True;
    arg := AMessage.ArgumentList;
    case arg.GetInt(IDX_TYPE) of
      VAL_CLICK_XY: CefUIClickAndCallbackAsync(ABrowser, arg);
      VAL_KEY_PRESS: CefUIKeyPress(ABrowser, arg);
    end;
  end
  else
  begin
    z := 'msgRecv:' + amessage.Name + ' ';
    eventId := arg.GetInt(IDX_EVENT);
    z := z + 'eid:' + IntToStr(eventId) + ' ';
    event := CefWaitEventGet(eventId);
    if Assigned(event) then
    begin
      z := z + 'tick:' + IntToStr(event.TickDif()) + ' res:' + CefListValueToJsonStr(arg);
      event.Res := arg.Copy();
      event.Event.SetEvent();
      AResult := True;
    end;
    CefLog('frame', 138, 1, z);
  end;
end;

initialization
  CefUIBrowserProcessMessageReceiverAdd(TCefUIBrowserProcessMessageReceiverCommon.Create())

end.
