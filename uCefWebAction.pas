unit uCefWebAction;

interface

uses
  Sysutils, Classes, System.SyncObjs,
  //
  uCEFInterfaces, uCEFTypes, uCEFChromium, uCEFChromiumEvents,
  //
  uReLog3, uLoggerInterface,
  //
  uCefWebActionBase;

type
  TCefWebAction = class;
  TCefWebActionEvent = function(const AWebAction: TCefWebAction): Boolean of object;
  TCefWebActionProc = reference to function(const AWebAction: TCefWebAction): Boolean;

  TCefWebAction = class(TCefWebActionBase)
  private
    FIsSetEvents: Boolean;
    FLock: TCriticalSection;
    FLoadEvent: TEvent;
    FIsNavigation: Boolean;
    FOnAction: TCefWebActionEvent;
    FOnActionProc: TCefWebActionProc;
    FSaveOnLoadStart: TOnLoadStart;
    FSaveOnLoadEnd: TOnLoadEnd;
    FSaveOnLoadError: TOnLoadError;
    procedure Clear;
    procedure OnLoadStart(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; transitionType: TCefTransitionType);
    procedure OnLoadEnd(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; httpStatusCode: Integer);
    procedure OnLoadError(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; errorCode: TCefErrorCode; const errorText, failedUrl: ustring);
  protected
    function DoStartEvent: Boolean; override;
  public
    constructor Create(const AName: string; const ALogger: ILoggerInterface;
        const AWeb: TChromium; const ATimeout: Integer; const AAbortEvent: TEvent;
        const AAction: TCefWebActionEvent;
        const AActionProc: TCefWebActionProc); overload;
    constructor Create(const AName: string; const ALogger: ILoggerInterface;
        const AWeb: TChromium; const ATimeout: Integer; const AAbortEvent: TEvent;
        const AAction: TCefWebActionEvent); overload;
    constructor Create(const AName: string; const ALogger: ILoggerInterface;
        const AWeb: TChromium; const ATimeout: Integer; const AAbortEvent: TEvent;
        const AActionProc: TCefWebActionProc); overload;
    constructor Create(const ALogger: ILoggerInterface;
        const AWeb: TChromium; const ATimeout: Integer; const AAbortEvent: TEvent;
        const AAction: TCefWebActionEvent;
        const AActionProc: TCefWebActionProc); overload;
    constructor Create(const ALogger: ILoggerInterface;
        const AWeb: TChromium; const ATimeout: Integer; const AAbortEvent: TEvent;
        const AAction: TCefWebActionEvent); overload;
    constructor Create(const ALogger: ILoggerInterface;
        const AWeb: TChromium; const ATimeout: Integer; const AAbortEvent: TEvent;
        const AActionProc: TCefWebActionProc); overload;
    destructor Destroy; override;

    function Start: Boolean; override;
    function Wait: TWaitResult; override;

    property IsNavigate: Boolean read FIsNavigation write FIsNavigation;
  end;

implementation

uses
  //
  uGlobalFunctions,
  //
  uCefUtilConst;


{ TCefWebAction }

constructor TCefWebAction.Create(const AName: string; const ALogger: ILoggerInterface;
  const AWeb: TChromium; const ATimeout: Integer; const AAbortEvent: TEvent;
  const AAction: TCefWebActionEvent; const AActionProc: TCefWebActionProc);
begin
  FOnAction := AAction;
  FOnActionProc := AActionProc;
  FLoadEvent := TEvent.Create;
  FLoadEvent.ResetEvent();
  FLock := TCriticalSection.Create;

  inherited Create(AName, ALogger, AWeb, ATimeout, AAbortEvent);
end;

constructor TCefWebAction.Create(const AName: string; const ALogger: ILoggerInterface;
  const AWeb: TChromium; const ATimeout: Integer; const AAbortEvent: TEvent;
  const AAction: TCefWebActionEvent);
begin
  Create(AName, ALogger, AWeb, ATimeout, AAbortEvent, AAction, nil)
end;

constructor TCefWebAction.Create(const AName: string; const ALogger: ILoggerInterface;
  const AWeb: TChromium; const ATimeout: Integer; const AAbortEvent: TEvent;
  const AActionProc: TCefWebActionProc);
begin
  Create(AName, ALogger, AWeb, ATimeout, nil, AActionProc)
end;

constructor TCefWebAction.Create(const ALogger: ILoggerInterface; const AWeb: TChromium;
  const ATimeout: Integer; const AAbortEvent: TEvent; const AAction: TCefWebActionEvent;
  const AActionProc: TCefWebActionProc);
begin
  Create('', ALogger, AWeb, ATimeout, AAbortEvent, AAction, AActionProc)
end;

constructor TCefWebAction.Create(const ALogger: ILoggerInterface;
  const AWeb: TChromium; const ATimeout: Integer; const AAbortEvent: TEvent;
  const AAction: TCefWebActionEvent);
begin
  Create(ALogger, AWeb, ATimeout, AAbortEvent, AAction, nil)
end;

constructor TCefWebAction.Create(const ALogger: ILoggerInterface;
  const AWeb: TChromium; const ATimeout: Integer; const AAbortEvent: TEvent;
  const AActionProc: TCefWebActionProc);
begin
  Create(ALogger, AWeb, ATimeout, AAbortEvent, nil, AActionProc)
end;

destructor TCefWebAction.Destroy;
begin
  Clear();
  FLock.Enter;
  FLoadEvent.Free;
  FLock.Free;
  inherited;
end;

procedure TCefWebAction.Clear;
var
  cr: TChromium;
  b: Boolean;
begin
  LogDebug('~clear');
  cr := Chromium;
  b := FIsSetEvents;
  FIsSetEvents := False;
  if Assigned(cr) and b then
  begin
    FLock.Enter;
    try
      cr.OnLoadStart := FSaveOnLoadStart;
      cr.OnLoadEnd := FSaveOnLoadEnd;
      cr.OnLoadError := FSaveOnLoadError;
    finally
      FLock.Leave
    end;
  end;
  TThread.Sleep(1);
  FLock.Enter;
  try
    FSaveOnLoadStart := nil;
    FSaveOnLoadEnd := nil;
    FSaveOnLoadError := nil;
  finally
    FLock.Leave
  end;
end;

procedure TCefWebAction.OnLoadEnd(Sender: TObject; const browser: ICefBrowser;
  const frame: ICefFrame; httpStatusCode: Integer);
var
  save: TOnLoadEnd;
begin
  save := FSaveOnLoadEnd;
  FLock.Enter;
  try
    if Assigned(save) then
      save(Sender, browser, frame, httpStatusCode);
    if FIsSetEvents and frame.IsMain then
    begin
      LogInfo('loadEnd %s', [frame.Url]);
      FLoadEvent.SetEvent()
    end;
  finally
    FLock.Leave
  end;
end;

procedure TCefWebAction.OnLoadError(Sender: TObject; const browser: ICefBrowser;
  const frame: ICefFrame; errorCode: TCefErrorCode; const errorText,
  failedUrl: ustring);
var
  save: TOnLoadError;
begin
  save := FSaveOnLoadError;
  FLock.Enter;
  try
    if Assigned(save) then
      save(Sender, browser, frame, errorCode, errorText, failedUrl);
    if FIsSetEvents and frame.IsMain then
    begin
      FFail := True;
      FErrorStr := Format('loadError %d "%s" %s', [errorCode, errorText, failedUrl]);
      LogError(FErrorStr);
      FLoadEvent.SetEvent
    end;
  finally
    FLock.Leave
  end;
end;

procedure TCefWebAction.OnLoadStart(Sender: TObject; const browser: ICefBrowser;
  const frame: ICefFrame; transitionType: TCefTransitionType);
var
  save: TOnLoadStart;
begin
  save := FSaveOnLoadStart;
  FLock.Enter;
  try
    if Assigned(save) then
      save(Sender, browser, frame, transitionType);
    if FIsSetEvents and frame.IsMain then
    begin
      LogInfo('loadStart #%d %s', [transitionType, frame.Url]);
      FIsNavigation := True;
    end;
  finally
    FLock.Leave
  end;
end;

function TCefWebAction.DoStartEvent: Boolean;
begin
  if Assigned(FOnAction) then
    Result := FOnAction(Self)
  else
  if Assigned(FOnActionProc) then
    Result := FOnActionProc(Self)
  else
    Result := False
end;

function SameMethod(const AMethod1, AMethod2: TOnLoadStart): Boolean; overload;
begin
  Result := Assigned(AMethod1) and
            Assigned(AMethod2) and
            (TMethod(AMethod1) = TMethod(AMethod2))
end;
function SameMethod(const AMethod1, AMethod2: TOnLoadEnd): Boolean; overload;
begin
  Result := Assigned(AMethod1) and
            Assigned(AMethod2) and
            (TMethod(AMethod1) = TMethod(AMethod2))
end;
function SameMethod(const AMethod1, AMethod2: TOnLoadError): Boolean; overload;
begin
  Result := Assigned(AMethod1) and
            Assigned(AMethod2) and
            (TMethod(AMethod1) = TMethod(AMethod2))
end;

function TCefWebAction.Start: Boolean;
var B: TChromium;
begin
  LogDebug('~start');
  FSaveOnLoadStart := nil;
  FSaveOnLoadEnd := nil;
  FSaveOnLoadError := nil;
  B := Chromium;
  if Assigned(B) then
  begin
    {
      if FBrowser.IsLoading then
      begin
        FBrowser.StopLoad();
        LogInfo('stop loading...');
        Sleep(NAV_WAIT_TIMEOUT);
      end;
     }
    if not SameMethod(B.OnLoadStart, OnLoadStart) then
    begin
      FSaveOnLoadStart := B.OnLoadStart;
      B.OnLoadStart := OnLoadStart;
    end;
    if not SameMethod(B.OnLoadEnd, OnLoadEnd) then
    begin
      FSaveOnLoadEnd := B.OnLoadEnd;
      B.OnLoadEnd := OnLoadEnd;
    end;
    if not SameMethod(B.OnLoadError, OnLoadError) then
    begin
      FSaveOnLoadError := B.OnLoadError;
      B.OnLoadError := OnLoadError;
    end;
    FIsSetEvents := True;
  end;
  Result := inherited Start();
end;

function TCefWebAction.Wait: TWaitResult;
begin
  LogDebug('wait NAV_WAIT_TIMEOUT');
  Result := Sleep(NAV_WAIT_TIMEOUT, FLoadEvent);
  if Result = wrTimeout then
  begin
    if FIsNavigation then
    begin
      LogDebug('wait TIMEOUT');
      Result := Sleep(IfEmpty(FTimeout, TIMEOUT_DEF), FLoadEvent);
      if (Result = wrTimeout) and not FFail then
        Result := wrSignaled
    end
    else
    begin
      Result := Sleep(SCREEN_WAIT_TIMEOUT, FLoadEvent);
      if Result = wrTimeout then
        Result := wrSignaled
    end;
  end;
  Clear();
end;


end.
