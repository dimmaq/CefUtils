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
    procedure OnLoadError(Sender: TObject; const browser: ICefBrowser; const frame: ICefFrame; errorCode: Integer; const errorText, failedUrl: ustring);
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
  FLoadEvent.Free;
  inherited;
end;

procedure TCefWebAction.Clear;
var B: TChromium;
begin
  B := Chromium;
  if Assigned(B) and FIsSetEvents then
  begin
    B.OnLoadStart := FSaveOnLoadStart;
    B.OnLoadEnd := FSaveOnLoadEnd;
    B.OnLoadError := FSaveOnLoadError;
  end;
  FIsSetEvents := False;
  FSaveOnLoadStart := nil;
  FSaveOnLoadEnd := nil;
  FSaveOnLoadError := nil;
end;

procedure TCefWebAction.OnLoadEnd(Sender: TObject; const browser: ICefBrowser;
  const frame: ICefFrame; httpStatusCode: Integer);
begin
  if Assigned(FSaveOnLoadEnd) then
    FSaveOnLoadEnd(Sender, browser, frame, httpStatusCode);
  if (not FDestroying) and frame.IsMain then
  begin
    LogInfo('loadEnd %s', [frame.Url]);
    FLoadEvent.SetEvent()
  end;
end;

procedure TCefWebAction.OnLoadError(Sender: TObject; const browser: ICefBrowser;
  const frame: ICefFrame; errorCode: Integer; const errorText,
  failedUrl: ustring);
begin
  if Assigned(FSaveOnLoadError) then
    FSaveOnLoadError(Sender, browser, frame, errorCode, errorText, failedUrl);
  if (not FDestroying) and frame.IsMain then
  begin
    FErrorStr := Format('loadError %d "%s" %s', [errorCode, errorText, failedUrl]);
    LogError(FErrorStr);
    FFail := True;
    FLoadEvent.SetEvent
  end;
end;

procedure TCefWebAction.OnLoadStart(Sender: TObject; const browser: ICefBrowser;
  const frame: ICefFrame; transitionType: TCefTransitionType);
begin
  if Assigned(FSaveOnLoadStart) then
    FSaveOnLoadStart(Sender, browser, frame, transitionType);
  if (not FDestroying) and frame.IsMain then
  begin
    LogInfo('loadStart #%d %s', [transitionType, frame.Url]);
    FIsNavigation := True;
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
  Result := Sleep(NAV_WAIT_TIMEOUT, FLoadEvent);
  if Result = wrTimeout then
  begin
    if FIsNavigation then
    begin
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
