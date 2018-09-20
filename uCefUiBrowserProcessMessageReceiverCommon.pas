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
  uCefUtilConst, uCefWaitEventList, uCefUtilFunc;

{ TCefUIBrowserProcessMessageReceiverCommon }

constructor TCefUIBrowserProcessMessageReceiverCommon.Create;
begin
  inherited Create(APP_CEF_RENDER_MESSAGE_NAME)
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
  z := 'msgRecv:' + amessage.Name + ' ';
  arg := amessage.ArgumentList;
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

initialization
  CefUIBrowserProcessMessageReceiverAdd(TCefUIBrowserProcessMessageReceiverCommon.Create())

end.
