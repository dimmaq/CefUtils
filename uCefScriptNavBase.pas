unit uCefScriptNavBase;

interface

uses
  System.Classes, System.SysUtils, System.SyncObjs,
  //
  uReLog3, uLoggerInterface,
  //
  uCefScriptBase, uCefWebActionBase, uCefWebAction;

const
  NAV_TIMEOUT_DEF = 60;

type
  TCefScriptNavBase =  class abstract(TCefScriptBase)
  private
  protected
    FSetIsNav: Boolean;
    FDoStop: Boolean;
    FAction: TCefWebAction;
    procedure Nav(const AUrl: string);
    function DoStartEvent: Boolean; override;
    function DoNavEvent(const AWebAction: TCefWebAction): Boolean; virtual; abstract;
  public
    constructor Create(const AActionName: string; const ASetAsNav: Boolean;
      const AParent: TCefScriptBase);
    destructor Destroy; override;
    procedure AfterConstruction; override;
    function Wait:TWaitResult; override;
    procedure Abort; override;
  end;


implementation

uses
  //
  uStringUtils
  ;

{ TCefScriptNavBase }

constructor TCefScriptNavBase.Create(const AActionName: string; const ASetAsNav: Boolean;
  const AParent: TCefScriptBase);
begin
  inherited Create(AActionName, AParent);
  FSetIsNav := ASetAsNav
end;

destructor TCefScriptNavBase.Destroy;
begin
  FAction.Free;
  inherited;
end;

procedure TCefScriptNavBase.AfterConstruction;
begin
  inherited;
  FAction := TCefWebAction.Create('wa', FLogger, Chromium, NAV_TIMEOUT_DEF, FAbortEvent, DoNavEvent);
end;

procedure TCefScriptNavBase.Abort;
begin
  inherited;
  FAction.Abort();
end;

function TCefScriptNavBase.DoStartEvent: Boolean;
begin
  if FSetIsNav then
  begin
    FAction.IsNavigate := True;
    FDoStop := True;
  end;
  if FDoStop then
  begin
    DoNavStop();
  end;

  Result := FAction.Start()
end;

procedure TCefScriptNavBase.Nav(const AUrl: string);
begin
  LogInfo('navigate ' + AUrl);
  //FAction.IsNavigate := True;
  Chromium.LoadURL(AUrl);
end;

function TCefScriptNavBase.Wait: TWaitResult;
begin
  Result := FAction.Wait();
  FFail := FAction.IsFail;
  if FAction.ErrorStr <> '' then
    LogError2(FAction.ErrorStr);
end;

end.
