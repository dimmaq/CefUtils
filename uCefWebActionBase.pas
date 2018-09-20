unit uCefWebActionBase;

interface

uses
  Sysutils, Classes, System.SyncObjs,
  //
  uCEFInterfaces, uCEFTypes, uCEFChromium,
  uReLog3, uLoggerInterface;

type
  TCefWebActionBase = class abstract
  private
    FChromium: TChromium;
    //---
    function GetIsSucccess: Boolean;
    function GetLocationURL: string;
  protected
    FLog: TReLog3;
    FLogger: ILoggerInterface;
    FAbortEvent: TEvent;
    FEventObjOwn: Boolean;
    FName: string;
    FTimeout: Integer;
    FAborted: Boolean;
    FFail: Boolean;
    FAutoSetFail: Boolean;
    FIgnoreFail: Boolean;
    FErrorStr: string;
    //---
    function DoNavStop: Boolean;
    function DoStartEvent: Boolean; virtual; abstract;
    procedure SetChromium(const Value: TChromium);
    function GetChromium: TChromium; virtual;
  public
    constructor Create(const AName: string; const ALogger: ILoggerInterface;
        const AWeb: TChromium; const ATimeout: Integer; const AAbortEvent: TEvent);
    destructor Destroy; override;

    function Start: Boolean; virtual;
    function Sleep(const A: Integer; const AWaitObj: TEvent = nil;
      const AAbortOnFail: Boolean = True): TWaitResult; overload;
    function Sleep(const A: string; const AWaitObj: TEvent = nil;
      const AAbortOnFail: Boolean = True): TWaitResult; overload;
    function Wait: TWaitResult; virtual;
    procedure Abort; virtual;
    procedure AbortMsg(const AErrorMessage: string); overload;
    procedure AbortMsg(const AErrorMessageFormat: string; const AArgs: array of const); overload;
    procedure FailMsg(const AErrorMessage: string); overload;
    procedure FailMsg(const AErrorMessageFormat: string; const AArgs: array of const); overload;

    {$HINTS OFF}
    procedure LogLog(const ALevel: TLogLevel; const AFormat: string; const AArgs: array of const); overload;
    procedure LogLog(const ALevel: TLogLevel; const A: string); overload;
    procedure LogDebug(const A: string); overload;
    procedure LogDebug(const AFormat: string; const AArgs: array of const); overload;
    procedure LogInfo(const A: string); overload;
    procedure LogInfo(const AFormat: string; const AArgs: array of const); overload;
    procedure LogError(const A: string); overload;
    procedure LogError(const AFormat: string; const AArgs: array of const); overload;
    procedure LogSuccess(const A: string); overload;
    procedure LogSuccess(const AFormat: string; const AArgs: array of const); overload;
    {$HINTS ON}

    property IsAborted: Boolean read FAborted;
    property IsFail: Boolean read FFail;
    property IsSuccess: Boolean read GetIsSucccess;
    property LocationURL: string read GetLocationURL;

    property Chromium: TChromium read GetChromium write SetChromium;
    property Logger: ILoggerInterface read FLogger;
    property AbortEvent: TEvent read FAbortEvent;
    property ErrorStr: string read FErrorStr;
    property IgnoreFail: Boolean read FIgnoreFail;
  end;

function SleepEvents(E1, E2: TEvent; const A: Integer): TWaitResult; overload;
function SleepEvents(E1, E2: TEvent; const A: Integer; var AFired: THandleObject): TWaitResult; overload;

implementation

uses
  AcedBinary,
  //
  uGlobalFunctions, uStringUtils,
  //
  uCefUtilConst;

const
  TIMEOUT_DEF = 1000;

procedure SwapEvents(var E1, E2: TEvent);
begin
  G_Swap32(E1, E2);
end;

function SleepEvents(E1, E2: TEvent; const A: Integer; var AFired: THandleObject): TWaitResult;
var arr: THandleObjectArray;
begin
  if E1 = nil then
  begin
    SwapEvents(E1, E2);
    if E1 = nil then
      Exit(wrSignaled);
  end;
  if Assigned(E2) then
  begin
    SetLength(arr, 2);
    arr[0] := E1;
    arr[1] := E2;
    Result := TEvent.WaitForMultiple(arr, A, False, AFired)
  end
  else
  begin
    AFired := E1;
    Result := E1.WaitFor(A)
  end
end;

function SleepEvents(E1, E2: TEvent; const A: Integer): TWaitResult;
var tmp: THandleObject;
begin
  Result := SleepEvents(E1, E2, A, tmp)
end;

{ TCefWebActionBase }

constructor TCefWebActionBase.Create(const AName: string; const ALogger: ILoggerInterface;
  const AWeb: TChromium; const ATimeout: Integer; const AAbortEvent: TEvent);
begin
  inherited Create;

  FChromium := AWeb;
  FName := AName;

  if Assigned(ALogger) then
  begin
    FLog := TReLog3.Create(ALogger, '~' + AName);
    FLogger := FLog;
  end;

  FTimeout := ATimeout * 1000;

  FAbortEvent := AAbortEvent;
  if not Assigned(FAbortEvent) then
  begin
    FAbortEvent := TEvent.Create;
    FAbortEvent.ResetEvent();
    FEventObjOwn := True;
  end;
end;

destructor TCefWebActionBase.Destroy;
begin
  FChromium := nil;
  if FEventObjOwn then
    FAbortEvent.Free;
  if FFail then
    LogDebug('fail')
  else
  if IsAborted then
    LogDebug('abort')
//  else
//  if IsSuccess then
//    LogDebug('success')
  else
    LogDebug('done');

  inherited;
end;

procedure TCefWebActionBase.Abort;
begin
  LogDebug('setabort');
  FAborted := True;
  FAbortEvent.SetEvent()
end;

function TCefWebActionBase.DoNavStop: Boolean;
var B: TChromium;
begin
  B := Chromium;
  if B = nil then
    Exit(False);

  if B.IsLoading then
  begin
    B.StopLoad();
    LogInfo('stop loading...');
    Result := Sleep(NAV_WAIT_TIMEOUT) = wrTimeout;
    Exit
  end;
  Result := True
end;

procedure TCefWebActionBase.LogLog(const ALevel: TLogLevel; const A: string);
begin
  if Assigned(FLog) then
    FLog.Log(ALevel, A)
end;

procedure TCefWebActionBase.LogLog(const ALevel: TLogLevel; const AFormat: string;
  const AArgs: array of const);
begin
  if Assigned(FLog) then
    FLog.Log(ALevel, AFormat, AArgs)
end;

procedure TCefWebActionBase.LogSuccess(const A: string);
begin
  LogLog(TLogLevel.logSuccess, A)
end;

procedure TCefWebActionBase.LogSuccess(const AFormat: string;
  const AArgs: array of const);
begin
  LogLog(TLogLevel.logSuccess, AFormat, AArgs)
end;

procedure TCefWebActionBase.LogDebug(const AFormat: string;
  const AArgs: array of const);
begin
  LogLog(TLogLevel.logDebug, AFormat, AArgs)
end;

procedure TCefWebActionBase.LogDebug(const A: string);
begin
  LogLog(TLogLevel.logDebug, A)
end;

procedure TCefWebActionBase.LogError(const AFormat: string;
  const AArgs: array of const);
begin
  LogLog(TLogLevel.logError, AFormat, AArgs)
end;

procedure TCefWebActionBase.LogError(const A: string);
begin
  LogLog(TLogLevel.logError, A)
end;

procedure TCefWebActionBase.LogInfo(const AFormat: string;
  const AArgs: array of const);
begin
  LogLog(TLogLevel.logInfo, AFormat, AArgs)
end;

procedure TCefWebActionBase.LogInfo(const A: string);
begin
  LogLog(TLogLevel.logInfo, A)
end;

procedure TCefWebActionBase.AbortMsg(const AErrorMessage: string);
begin
  LogError(AErrorMessage);
  Abort()
end;

procedure TCefWebActionBase.AbortMsg(const AErrorMessageFormat: string;
  const AArgs: array of const);
begin
  AbortMsg(Format(AErrorMessageFormat, AArgs))
end;

procedure TCefWebActionBase.FailMsg(const AErrorMessage: string);
begin
  LogError(AErrorMessage);
  FFail := True;
  //Abort()
end;

procedure TCefWebActionBase.FailMsg(const AErrorMessageFormat: string;
  const AArgs: array of const);
begin
  FailMsg(Format(AErrorMessageFormat, AArgs))
end;

function TCefWebActionBase.GetChromium: TChromium;
begin
  Result := FChromium
end;

function TCefWebActionBase.GetIsSucccess: Boolean;
begin
  Result := (not FFail) and (not FAborted)
end;

function TCefWebActionBase.GetLocationURL: string;
begin
  Result := Chromium.Browser.MainFrame.Url
end;

function TCefWebActionBase.Start: Boolean;
begin
  Result := DoStartEvent();
  if FAutoSetFail and not Result then
    FFail := True
end;

function TCefWebActionBase.Sleep(const A: Integer;
  const AWaitObj: TEvent; const AAbortOnFail: Boolean): TWaitResult;
var fired: THandleObject;
begin
  if IsFail and AAbortOnFail then
    Exit(wrError);
  if IsAborted then
    Exit(wrAbandoned);

  LogDebug('.sleep ' + A.ToString);
  Result := SleepEvents(FAbortEvent, AWaitObj, A, fired);
  if Result = wrSignaled then
    if FAbortEvent = fired then
    begin
      FAborted := True;
      Result := wrAbandoned
    end;
end;

procedure TCefWebActionBase.SetChromium(const Value: TChromium);
begin
  FChromium := Value;
end;

function TCefWebActionBase.Sleep(const A: string;
  const AWaitObj: TEvent; const AAbortOnFail: Boolean): TWaitResult;
begin
  Result := Sleep(RandomRangeStr(A), AWaitObj, AAbortOnFail)
end;

function TCefWebActionBase.Wait: TWaitResult;
begin
  Result := Sleep(IfElse(FTimeout < 1, TIMEOUT_DEF, FTimeout), nil)
end;


end.
