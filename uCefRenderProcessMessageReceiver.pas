unit uCefRenderProcessMessageReceiver;

interface

uses
  System.SysUtils, System.Generics.Collections,
  //
  uCEFApplication, uCefTypes, uCefInterfaces;

type
  TCefRenderProcessMessageReceiver = class
  private
  protected
    FName: string;
    //---
    procedure Receive(const ABrowser: ICefBrowser; ASourceProcess: TCefProcessId;
      const AMessage: ICefProcessMessage; var AHandled: boolean); virtual;
  public
    constructor Create(const AName: string);
    destructor Destroy; override;
  end;

procedure CefAppRenderProcessMessageInit;
procedure CefAppRenderProcessMessageReceiverAdd(const A: TCefRenderProcessMessageReceiver);

implementation

type
  TCefRenderProcessMessageReceiverOwner = class
  private
    FHandlers: TObjectList<TCefRenderProcessMessageReceiver>;
    //---
    procedure Receive(const ABrowser: ICefBrowser; ASourceProcess: TCefProcessId;
        const AMessage: ICefProcessMessage; var AHandled : boolean);
  public
    constructor Create;
    destructor Destroy; override;
    //---
    procedure InitCefGlobalApp;
    procedure AddRceiver(const A: TCefRenderProcessMessageReceiver);
  end;

var
  gReceiver: TCefRenderProcessMessageReceiverOwner;

procedure CefAppRenderProcessMessageInit;
begin
  gReceiver.InitCefGlobalApp()
end;

procedure CefAppRenderProcessMessageReceiverAdd(const A: TCefRenderProcessMessageReceiver);
begin
  gReceiver.AddRceiver(A)
end;

{ TCefRenderProcessMessageReceiverOwner }

procedure TCefRenderProcessMessageReceiverOwner.AddRceiver(
  const A: TCefRenderProcessMessageReceiver);
begin
  FHandlers.Add(A)
end;

constructor TCefRenderProcessMessageReceiverOwner.Create;
begin
  FHandlers := TObjectList<TCefRenderProcessMessageReceiver>.Create(True);
  InitCefGlobalApp();
end;

destructor TCefRenderProcessMessageReceiverOwner.Destroy;
begin
  if Assigned(GlobalCEFApp) then
    GlobalCEFApp.OnProcessMessageReceived := nil;
  FHandlers.Free;
  inherited;
end;

procedure TCefRenderProcessMessageReceiverOwner.InitCefGlobalApp;
begin
  if Assigned(GlobalCEFApp) then
    GlobalCEFApp.OnProcessMessageReceived := Self.Receive;
end;

procedure TCefRenderProcessMessageReceiverOwner.Receive(const ABrowser: ICefBrowser;
  ASourceProcess: TCefProcessId; const AMessage: ICefProcessMessage;
  var AHandled: boolean);
var H: TCefRenderProcessMessageReceiver;
begin
  for H in FHandlers do
  begin
    if H.FName = AMessage.Name then
    begin
      H.Receive(ABrowser, ASourceProcess, AMessage, AHandled);
      if AHandled then
        Exit()
    end;
  end;
  AHandled := False
end;

{ TCefRenderProcessMessageReceiver }

constructor TCefRenderProcessMessageReceiver.Create(const AName: string);
begin
  FName := AName
end;

destructor TCefRenderProcessMessageReceiver.Destroy;
begin

  inherited;
end;

procedure TCefRenderProcessMessageReceiver.Receive(const ABrowser: ICefBrowser;
  ASourceProcess: TCefProcessId; const AMessage: ICefProcessMessage;
  var AHandled: boolean);
begin
  AHandled := False;
end;

initialization
  gReceiver := TCefRenderProcessMessageReceiverOwner.Create;

finalization
  FreeAndNil(gReceiver)

end.
