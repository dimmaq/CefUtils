unit uCefScriptBase;

interface

uses
  Classes, SysUtils, System.SyncObjs, System.IOUtils,
  //
  uCEFInterfaces, uCEFChromium, uCEFTypes,
  //
  uReLog3, uLoggerInterface,
  //
  uCefWebActionBase, uCefWebAction, uCefUtilType;

const
  PAUSE_DEF = '1111-3333';
  PAUSE_STEP_DEF = 3000;

  CHARS_SPACE = [#32, #9];

type
  TCefScriptBase = class abstract(TCefWebActionBase)
  private
    procedure SetAppLogger(const Value: ILoggerInterface);
  protected
    FAppLogger: ILoggerInterface;
    FController: TCefControllerBase;
    FParent: TCefScriptBase;
    function GetChromium: TChromium; override;
    procedure ParseParams(var A: string); virtual;
  public
    constructor Create(const AActionName, AParams: string; const AIgnoreFail: Boolean;
      const ALogger: ILoggerInterface; const ABrowser: TChromium;
      const AController: TCefControllerBase; const AAbortEvent: TEvent); overload;
    constructor Create(const AActionName: string; const AParent: TCefScriptBase; const AParams: string;
      const AIgnoreFail: Boolean); overload;
    constructor Create(const AActionName: string; const AParent: TCefScriptBase;
      const AIgnoreFail: Boolean); overload;
    constructor Create(const AActionName: string; const AParent: TCefScriptBase; const AParams: string); overload;
    constructor Create(const AActionName: string; const AParent: TCefScriptBase); overload;
    destructor Destroy; override;

    procedure AppLog(const ALevel: TLogLevel; const A: string); virtual;
    procedure AppLog2(const ALevel: TLogLevel; const A: string); overload;
    procedure AppLog2(const ALevel: TLogLevel; const A: string; const AArgs: array of const); overload;
    procedure AbortMsg2(const AErrorMessage: string); overload;
    procedure AbortMsg2(const AErrorMessageFormat: string; const AArgs: array of const); overload;
    procedure FailMsg2(const AErrorMessage: string); overload;
    procedure FailMsg2(const AErrorMessageFormat: string; const AArgs: array of const); overload;
    procedure LogInfo2(const A: string); overload;
    procedure LogInfo2(const A: string; const AArgs: array of const); overload;
    procedure LogError2(const A: string); overload;
    procedure LogError2(const A: string; const AArgs: array of const); overload;
    procedure LogSucc2(const A: string); overload;
    procedure LogSucc2(const A: string; const AArgs: array of const); overload;

    function GetBrowserPageSource(var AHtml: string): Boolean;
//    procedure SaveHtmlDump;
    class function GetScriptName: string; virtual;

    property Controller: TCefControllerBase read FController;
    property Parent: TCefScriptBase read FParent;
    property AppLogger: ILoggerInterface read FAppLogger write SetAppLogger;
  end;

implementation

uses
  //
  //
  uGlobalFunctions, uStringUtils,
  //
  uCefUtilConst
  ;

type
  TWaitTextResult = class
    html: string;
    event: TEvent;
    abort: Boolean;
    constructor Create;
    destructor Destroy; override;
    procedure OnResult(Sender: TObject; const aText : ustring);
  end;

{ TCefScriptBase }

constructor TCefScriptBase.Create(const AActionName, AParams: string;
  const AIgnoreFail: Boolean; const ALogger: ILoggerInterface;
  const ABrowser: TChromium; const AController: TCefControllerBase;
  const AAbortEvent: TEvent);
var params, nam: string;
begin
  nam := AActionName;
  if nam = '' then
    nam := GetScriptName();

  inherited Create(nam, ALogger, ABrowser, 0, AAbortEvent);
  FAutoSetFail := True;
  FIgnoreFail := AIgnoreFail;

  FController := AController;

  params := AParams;
  ParseParams(params);
end;

constructor TCefScriptBase.Create(const AActionName: string; const AParent: TCefScriptBase; const AParams: string;
  const AIgnoreFail: Boolean);
begin
  Create(AActionName, AParams, AIgnoreFail, AParent.Logger, AParent.Chromium, AParent.FController, AParent.FAbortEvent);
  FParent := AParent
end;

constructor TCefScriptBase.Create(const AActionName: string; const AParent: TCefScriptBase; const AIgnoreFail: Boolean);
begin
  Create(AActionName, AParent, '', AIgnoreFail)
end;

constructor TCefScriptBase.Create(const AActionName: string; const AParent: TCefScriptBase; const AParams: string);
begin
  Create(AActionName, AParams, AParent.IgnoreFail, AParent.Logger, AParent.Chromium, AParent.FController, AParent.FAbortEvent);
  FParent := AParent
end;

constructor TCefScriptBase.Create(const AActionName: string; const AParent: TCefScriptBase);
begin
  Create(AActionName, AParent, '', AParent.IgnoreFail)
end;

destructor TCefScriptBase.Destroy;
begin
  inherited;
end;

function TCefScriptBase.GetChromium: TChromium;
begin
  Result := inherited GetChromium();
  if Result = nil then
    if Assigned(Parent) then
      Result := Parent.Chromium;
end;

function TCefScriptBase.GetBrowserPageSource(var AHtml: string): Boolean;
var
  event: TWaitTextResult;
  res: TWaitResult;
  B: TChromium;
begin
  AHtml := '';
  B := Chromium;

  event := TWaitTextResult.Create;
  try
    B.OnTextResultAvailable := event.OnResult;
    B.RetrieveHTML;
    res := Sleep(CEF_EVENT_WAIT_TIMEOUT, event.event, False);
    event.abort := True;
    B.OnTextResultAvailable := nil;
    if FAborted then
      Exit(False);
    if res = wrTimeout then
    begin
      FailMsg2('timeout retrieve HTML');
      Exit(False);
    end;
    if res = wrSignaled then
    begin
      if event.html = '' then
      begin
        FailMsg2('fail retrieve HTML, empty result');
        Exit(False);
      end;
      AHtml := event.html;
      Exit(True);
    end;
  finally
    event.Free
  end;
  Exit(False)
end;


class function TCefScriptBase.GetScriptName: string;
begin
  Result := '*'
end;

procedure TCefScriptBase.AppLog(const ALevel: TLogLevel; const A: string);
begin
  if Assigned(FAppLogger) then
    FAppLogger.Log(ALevel, A)
  else
    if Assigned(FParent) then
      FParent.AppLog(ALevel, A)
end;

procedure TCefScriptBase.AppLog2(const ALevel: TLogLevel; const A: string;
  const AArgs: array of const);
begin
  AppLog2(ALevel, format(A, AArgs))
end;

procedure TCefScriptBase.AppLog2(const ALevel: TLogLevel; const A: string);
begin
  AppLog(ALevel, A)
end;

procedure TCefScriptBase.FailMsg2(const AErrorMessage: string);
begin
  AppLog2(TLogLevel.logError, AErrorMessage);
  FailMsg(AErrorMessage)
end;

procedure TCefScriptBase.FailMsg2(const AErrorMessageFormat: string;
  const AArgs: array of const);
begin
  FailMsg2(Format(AErrorMessageFormat, AArgs))
end;

procedure TCefScriptBase.AbortMsg2(const AErrorMessage: string);
begin
  AppLog2(TLogLevel.logError, AErrorMessage);
  AbortMsg(AErrorMessage)
end;

procedure TCefScriptBase.AbortMsg2(const AErrorMessageFormat: string;
  const AArgs: array of const);
begin
  AbortMsg2(Format(AErrorMessageFormat, AArgs))
end;

procedure TCefScriptBase.LogError2(const A: string);
begin
  AppLog2(TLogLevel.logError, A);
  LogError(A);
end;

procedure TCefScriptBase.LogError2(const A: string; const AArgs: array of const);
begin
  AppLog2(TLogLevel.logError, A, AArgs);
  LogError(A, AArgs);
end;

procedure TCefScriptBase.LogInfo2(const A: string;
  const AArgs: array of const);
begin
  AppLog2(TLogLevel.logInfo, A, AArgs);
  LogInfo(A, AArgs);
end;

procedure TCefScriptBase.LogInfo2(const A: string);
begin
  AppLog2(TLogLevel.logInfo, A);
  LogInfo(A);
end;

procedure TCefScriptBase.LogSucc2(const A: string);
begin
  AppLog2(TLogLevel.logSuccess, A);
  LogSuccess(A);
end;

procedure TCefScriptBase.LogSucc2(const A: string;
  const AArgs: array of const);
begin
  AppLog2(TLogLevel.logSuccess, A, AArgs);
  LogSuccess(A, AArgs);
end;

procedure TCefScriptBase.ParseParams(var A: string);
begin
  if A <> '' then
    LogDebug('params: ' + A);
end;

procedure TCefScriptBase.SetAppLogger(const Value: ILoggerInterface);
begin
  FAppLogger := Value;
end;

{
procedure TCefScriptBase.SaveHtmlDump;
var fil, html: string;
begin
  if GetBrowserPageSource(html) then
  begin
    fil := FUser.SaveDir + 'dump_' + GetTimeStampStr() + '.html';
    TFile.WriteAllText(fil, html, TEncoding.UTF8);
    LogInfo('dump saved ' + fil);
  end;
end;
}


{ TWaitTextResult }

constructor TWaitTextResult.Create;
begin
  event := TEvent.Create;
  event.ResetEvent;
end;

destructor TWaitTextResult.Destroy;
begin
  abort := True;
  event.Free;
  inherited;
end;

procedure TWaitTextResult.OnResult(Sender: TObject; const aText: ustring);
begin
  if not Abort then
  begin
    html := aText;
    event.SetEvent;
  end;
end;

end.
