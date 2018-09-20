unit uCefUIBrowserProcessMessageReceiver;

interface

uses
  System.SysUtils, System.Generics.Collections,
  //
  uCEFApplication, uCefTypes, uCefInterfaces, uCefChromium;

type
  TCefUIBrowserProcessMessageReceiver = class
  private
  protected
    FName: string;
    //---
    procedure Receive(Sender: TObject; const ABrowser: ICefBrowser;
      ASourceProcess: TCefProcessId; const AMessage: ICefProcessMessage;
      out AResult: Boolean); virtual;
  public
    constructor Create(const AName: string);
    destructor Destroy; override;
  end;

procedure CefUIBrowserProcessMessageReceiverInit(const A: TChromium);
procedure CefUIBrowserProcessMessageReceiverAdd(const A: TCefUIBrowserProcessMessageReceiver);

implementation

type
  TCefUIBrowserProcessMessageReceiverOwner = class
  private
    FHandlers: TObjectList<TCefUIBrowserProcessMessageReceiver>;
    //---
    procedure Receive(Sender: TObject; const ABrowser: ICefBrowser;
      ASourceProcess: TCefProcessId; const AMessage: ICefProcessMessage; out AResult: Boolean);
  public
    constructor Create;
    destructor Destroy; override;
    //---
    procedure InitCefBrowser(const A: TChromium);
    procedure AddRceiver(const A: TCefUIBrowserProcessMessageReceiver);
  end;

var
  gReceiver: TCefUIBrowserProcessMessageReceiverOwner;

procedure CefUIBrowserProcessMessageReceiverInit(const A: TChromium);
begin
  gReceiver.InitCefBrowser(A)
end;

procedure CefUIBrowserProcessMessageReceiverAdd(const A: TCefUIBrowserProcessMessageReceiver);
begin
  gReceiver.AddRceiver(A)
end;

{ TCefUIBrowserProcessMessageReceiverOwner }

procedure TCefUIBrowserProcessMessageReceiverOwner.AddRceiver(
  const A: TCefUIBrowserProcessMessageReceiver);
begin
  FHandlers.Add(A)
end;

constructor TCefUIBrowserProcessMessageReceiverOwner.Create;
begin
  FHandlers := TObjectList<TCefUIBrowserProcessMessageReceiver>.Create(True);
end;

destructor TCefUIBrowserProcessMessageReceiverOwner.Destroy;
begin
  if Assigned(GlobalCEFApp) then
    GlobalCEFApp.OnProcessMessageReceived := nil;
  FHandlers.Free;
  inherited;
end;

procedure TCefUIBrowserProcessMessageReceiverOwner.InitCefBrowser(
  const A: TChromium);
begin
  A.OnProcessMessageReceived := Self.Receive
end;

procedure TCefUIBrowserProcessMessageReceiverOwner.Receive(Sender: TObject;
    const ABrowser: ICefBrowser; ASourceProcess: TCefProcessId;
    const AMessage: ICefProcessMessage; out AResult: Boolean);
var H: TCefUIBrowserProcessMessageReceiver;
begin
  for H in FHandlers do
  begin
    if H.FName = AMessage.Name then
    begin
      H.Receive(Sender, ABrowser, ASourceProcess, AMessage, AResult);
      if AResult then
        Exit()
    end;
  end;
  AResult := False
end;


{ TCefUIBrowserProcessMessageReceiver }

constructor TCefUIBrowserProcessMessageReceiver.Create(const AName: string);
begin
  FName := AName
end;

destructor TCefUIBrowserProcessMessageReceiver.Destroy;
begin

  inherited;
end;

procedure TCefUIBrowserProcessMessageReceiver.Receive(Sender: TObject;
    const ABrowser: ICefBrowser; ASourceProcess: TCefProcessId;
    const AMessage: ICefProcessMessage; out AResult: Boolean);
begin
  AResult := False;
end;

initialization
  gReceiver := TCefUIBrowserProcessMessageReceiverOwner.Create;

finalization
  FreeAndNil(gReceiver)

end.
