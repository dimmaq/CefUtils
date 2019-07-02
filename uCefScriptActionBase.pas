unit uCefScriptActionBase;

interface

uses
  //
  System.SysUtils, System.Classes, System.SyncObjs,
  //
  uCEFTypes, uCEFInterfaces, uCEFProcessMessage, uCEFDownloadImageCallBack,
  //
  uCefWebAction, uCefScriptBase, uCefWebActionBase, uCefScriptNav, uCefUtilFunc,
  uCefUtilType, uCefScriptDict;


type
  TCefProcMethod0 = procedure of object;
  TCefScriptStep1 = function(const ASender: TCefScriptBase): Boolean of object;
  TCefScriptStep1Array = array of TCefScriptStep1;

  TCefScriptActionBase = class abstract (TCefScriptBase)
  private
    procedure RunActionStopFree;
    function RunActionStartWait: TWaitResult; overload;
    function RunActionStartWait(var AResult: Boolean;
      const ASetFail: Boolean): TWaitResult; overload;
  protected
    FAction: TCefWebActionBase;
    FScriptDict: TCefScriptDict;
    //---
    function DoNavGoBack: Boolean;
    function RunScript(const AScript: string; const ASetFail: Boolean = True): Boolean;
    function RunScriptNav(const AUrl: string; const ANavFunc: TCefScriptNavFunc;
      const ANavProc0: TCefScriptNavProc0;
      const ASetFail, AIsNavigation: Boolean): Boolean; overload;
    function RunScriptNav(const AUrl: string; const ASetFail: Boolean = True;
      const AIsNavigation: Boolean = True): Boolean; overload;
    function RunScriptNav(const ANavFunc: TCefScriptNavFunc; const ASetFail: Boolean = True;
      const AIsNavigation: Boolean = False): Boolean; overload;
    function RunScriptNav(const ANavProc0: TCefScriptNavProc0; const ASetFail: Boolean = True;
      const AIsNavigation: Boolean = False): Boolean; overload;
    //---
    function RunScriptClickById(const AId: string;
        const ASetFail: Boolean = True; const ASetIsNav: Boolean = False): Boolean;
    function RunScriptScrollAndClickElement(const ASpeed: TCefUISpeed;
      const AElem: TElementParams; const ASetFail: Boolean;
      const ASetIsNav: Boolean): Boolean; overload;
    function RunScriptScrollAndClickElement(const AElem: TElementParams;
      const ASetFail: Boolean = True; const ASetIsNav: Boolean = False): Boolean; overload;
    function RunScriptScrollAndClickElementNav(const AElem: TElementParams;
      const ASetFail: Boolean = True): Boolean;
    //---
    function DoStepPause(const ATimeout: string; const ASteps: array of TCefScriptStep1): Boolean; overload;
    function DoPause(const ATimeout: string; const ASteps: TCefScriptStep1 = nil): Boolean;

  public
    destructor Destroy; override;
    //---

    //---
    function Wait: TWaitResult; override;
    procedure Abort; override;
    //---
    procedure SetScriptDict(const A: TCefScriptDict);
    property ScriptDict: TCefScriptDict read FScriptDict write SetScriptDict;
  end;

implementation

uses
  uStringUtils,
  //
  uCefScriptClickElement, uCefWaitEventList, uCefUIFunc;

{ TCefScriptActionBase }

destructor TCefScriptActionBase.Destroy;
begin
  if Assigned(FAction) then
    FAction.Free;
  inherited;
end;

function TCefScriptActionBase.DoStepPause(const ATimeout: string;
  const ASteps: array of TCefScriptStep1): Boolean;
var step: TCefScriptStep1;
begin
  for step in ASteps do
  begin
    if Sleep(RandomRangeStr(ATimeout, PAUSE_STEP_DEF)) <> wrTimeout then
      Exit(False);
    if Assigned(step) then
      if not step(Self) then
        Exit(False);
  end;
  Exit(Sleep(ATimeout) = wrTimeout)
end;

function TCefScriptActionBase.DoPause(const ATimeout: string;
  const ASteps: TCefScriptStep1): Boolean;
begin
  if Assigned(ASteps) then
    Result := DoStepPause(ATimeout, [ASteps])
  else
    Result := Sleep(ATimeout) = wrTimeout
end;

function TCefScriptActionBase.DoNavGoBack: Boolean;
begin
  LogInfo('go <- back');
  if Chromium.CanGoBack then
  begin
    Result := RunScriptNav(
        procedure
        begin
          Chromium.GoBack();
        end,
      True, True);
  end
  else
  begin
    LogError('not canGoBack');
    Result := False
  end
end;

function TCefScriptActionBase.RunActionStartWait: TWaitResult;
begin
  if FAction.Start() then
    Result := FAction.Wait()
  else
    Result := wrError
end;

function TCefScriptActionBase.RunActionStartWait(var AResult: Boolean;
  const ASetFail: Boolean): TWaitResult;
var wr: TWaitResult;
begin
  AResult := False;
  wr := RunActionStartWait();
  if wr = wrSignaled then
  begin
    FAction.LogDebug('action wrSignaled');
    if FAction.IsSuccess then
      AResult := True;
  end
  else
  if wr = wrTimeout then
  begin
    if FAction.IsSuccess then
    begin
      AResult := True;
      FAction.LogDebug('action wrTimeout');
    end
    else
    begin
      FAction.LogError('action wrTimeout')
    end
  end
  else
  if wr = wrAbandoned then
  begin
    FAction.LogError('action wrAbandoned');
  end
  else
  if wr = wrError then
  begin
    FAction.LogError('action wrError');
  end;

  if ASetFail and FAction.IsFail and not FAction.IgnoreFail  then
    FFail := True;

  Result := wr;
end;


procedure TCefScriptActionBase.RunActionStopFree;
begin
  if Assigned(FAction) then
  begin
    FAction.Abort();
    FAction.Wait();
    FAction.Free;
    FAction := nil;
  end;
end;

function TCefScriptActionBase.RunScript(const AScript: string; const ASetFail: Boolean): Boolean;
begin
  RunActionStopFree();
  try
    if not Assigned(FScriptDict) then
    begin
      LogError('no script dict');
      if ASetFail then
        FFail := True;
      Exit(False)
    end;

    FAction := FScriptDict.MakeScript(AScript, FController, FLogger, Chromium, FAbortEvent);
    if not Assigned(FAction) then
    begin
      LogError('not found script "%s"', [AScript]);
      if ASetFail then
        FFail := True;
      Exit(False)
    end;
    RunActionStartWait(Result, ASetFail);
  finally
    FreeAndNil(FAction);
  end;
end;

function TCefScriptActionBase.RunScriptClickById(const AId: string;
  const ASetFail, ASetIsNav: Boolean): Boolean;
begin
  RunActionStopFree();
  try
    FAction := TScriptClickElement.Create(FController.Pause, AId, ASetIsNav, Self);
    RunActionStartWait(Result, ASetFail);
  finally
    FreeAndNil(FAction);
  end;
end;

function TCefScriptActionBase.RunScriptScrollAndClickElement(const ASpeed: TCefUISpeed;
  const AElem: TElementParams; const ASetFail, ASetIsNav: Boolean): Boolean;
var bol: Boolean;
begin
  LogDebug('scroll to element');
  bol := CefUIScrollToElement(Self, ASpeed, AElem);
  if bol then
  begin
    DoPause(PAUSE_DEF);
    LogDebug('mouse move to element');
    bol := CefUIMouseMoveToElement(Self, ASpeed, AElem);
    if bol then
    begin
      DoPause(PAUSE_DEF);
      bol := RunScriptNav(
        procedure
        begin
          LogDebug('click element');
          CefUIMouseClick(Self);
        end,
        ASetFail, ASetIsNav);
      //---
      if not bol then
        LogError('fail click to element');
      Exit(bol)
    end
    else
    begin
      LogError('fail mouse move to element');
    end;
  end
  else
  begin
    LogError('fail scroll to element');
  end;
  Result := False;
end;

function TCefScriptActionBase.RunScriptScrollAndClickElement(
  const AElem: TElementParams; const ASetFail, ASetIsNav: Boolean): Boolean;
begin
  Result := RunScriptScrollAndClickElement(FController.Speed, AElem, ASetFail, ASetIsNav)
end;

function TCefScriptActionBase.RunScriptScrollAndClickElementNav(
  const AElem: TElementParams; const ASetFail: Boolean): Boolean;
begin
  Result := RunScriptScrollAndClickElement(FController.Speed, AElem, ASetFail, True)
end;

procedure TCefScriptActionBase.SetScriptDict(const A: TCefScriptDict);
begin
  FScriptDict := A
end;

function TCefScriptActionBase.RunScriptNav(const AUrl: string;
  const ANavFunc: TCefScriptNavFunc; const ANavProc0: TCefScriptNavProc0;
  const ASetFail, AIsNavigation: Boolean): Boolean;
begin
  RunActionStopFree();
  try
    FAction := TCefScriptNav.Create(AUrl, ANavFunc, ANavProc0, AIsNavigation, Self);
    RunActionStartWait(Result, ASetFail);
  finally
    FreeAndNil(FAction);
  end;
end;

function TCefScriptActionBase.RunScriptNav(const AUrl: string;
  const ASetFail, AIsNavigation: Boolean): Boolean;
begin
  Result := RunScriptNav(AUrl, nil, nil, ASetFail, AIsNavigation)
end;

function TCefScriptActionBase.RunScriptNav(const ANavFunc: TCefScriptNavFunc;
  const ASetFail, AIsNavigation: Boolean): Boolean;
begin
  Result := RunScriptNav('', ANavFunc, nil, ASetFail, AIsNavigation)
end;

function TCefScriptActionBase.RunScriptNav(const ANavProc0: TCefScriptNavProc0;
  const ASetFail, AIsNavigation: Boolean): Boolean;
begin
  Result := RunScriptNav('', nil, ANavProc0, ASetFail, AIsNavigation)
end;

procedure TCefScriptActionBase.Abort;
begin
  if Assigned(FAction) then
    FAction.Abort();
  inherited;
end;

function TCefScriptActionBase.Wait: TWaitResult;
begin
  if Assigned(FAction) then
    Result := FAction.Wait()
  else
    Result := inherited Wait()
end;


end.
