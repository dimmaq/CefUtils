unit uCefUIFunc;

interface

uses
  System.SysUtils, System.SyncObjs, System.Types,
  //
  uCEFInterfaces, uCEFTypes, uCEFMiscFunctions, uCEFConstants, uCEFChromium,
  //
  uCefScriptBase, uCefWebActionBase, uCefUtilFunc;

const
  DIR_UP = 1;
  DIR_DOWN = -1;
  SCROLL_STEP_DEF = 100;

  WaitResultStr: array[TWaitResult] of string = ('wrSignaled', 'wrTimeout', 'wrAbandoned', 'wrError', 'wrIOCompletion');

function CefUISendRenderMessage(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const A: ICefProcessMessage): ICefListValue;

function CefUIElementIdExists(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
    const AId: string): Boolean; overload;
function CefUIElementIdExists(const AAction: TCefScriptBase;
    const AId: string): Boolean; overload;
function CefUIElementExists(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string): ICefListValue; overload;
function CefUIElementExists(const AAction: TCefScriptBase;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string): ICefListValue; overload;
function CefUIElementExists(const AAction: TCefScriptBase;
  const AElement: TElementParams): ICefListValue; overload;
function CefUIGetElementsAttr(const AAction: TCefScriptBase;
  const AElement: TElementParams): ICefListValue;
function CefUIElementSetValuaById(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
    const AId, AValue: string): Boolean; overload;
function CefUIElementSetValuaById(const AAction: TCefScriptBase;
    const AId, AValue: string): Boolean; overload;
function CefUIElementSetValuaByName(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
    const AName, AValue: string): Boolean;
function CefUIElementSetAttrByName(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
    const AName, AAttr, AValue: string): Boolean;
function CefUIGetWindowRect(const ABrowser: ICefBrowser; const AAbortEvent: TEvent): TRect; overload;
function CefUIGetWindowRect(const AAction: TCefScriptBase): TRect; overload;
function CefUIGetBodyRect(const ABrowser: ICefBrowser; const AAbortEvent: TEvent): TRect;

function CefUIGetElementRect(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const AElem: TElementParams): TRect; overload;
function CefUIGetElementRect(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string): TRect; overload;
function CefUIGetElementRect(const AAction: TCefScriptBase;
  const AElem: TElementParams): TRect; overload;

function CefUIScrollToElement(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const ATimeout, AStep: Integer;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string;
  const ATry: Integer): Boolean; overload;
function CefUIScrollToElement(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const ASpeed: Integer;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string): Boolean; overload;
function CefUIScrollToElement(const AAction: TCefScriptBase;
  const ASpeed: Integer;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string): Boolean; overload;
function CefUIScrollToElement(const AAction: TCefScriptBase;
  const ASpeed: Integer; const AElement: TElementParams): Boolean; overload;
function CefUIScrollToElement(const AAction: TCefScriptBase;
  const AElement: TElementParams): Boolean; overload;


function CefUIMouseSetToPoint(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const AMousePos: PPoint; const AToPoint: TPoint; const ATimeout: Integer): Boolean; overload;
function CefUIMouseSetToPoint(const AAction: TCefScriptBase;
  const AToPoint: TPoint; const ATimeout: Integer): Boolean; overload;
function CefUIMouseMoveToElement(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  var APoint: TPoint; const ATimeout, AStep: Integer;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string): Boolean; overload;
function CefUIMouseMoveToElement(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  var APoint: TPoint; const ASpeed: Integer;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string): Boolean; overload;
function CefUIMouseMoveToElement(const AAction: TCefScriptBase; const ASpeed: Integer;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string): Boolean; overload;
function CefUIMouseMoveToElement(const AAction: TCefScriptBase; const ASpeed: Integer;
  const AElement: TElementParams): Boolean; overload;
function CefUIMouseMoveToElement(const AAction: TCefScriptBase;
  const AElement: TElementParams): Boolean; overload;
procedure CefUIMouseClick(const ABrowser: ICefBrowser; const APoint: TPoint); overload;
procedure CefUIMouseClick(const AAction: TCefScriptBase); overload;
procedure CefUIClickAndCallback(const ABrowser: ICefBrowser; const AArg: ICefListValue);
procedure CefSendKeyEvent(const ABrowser: ICefBrowser; AKeyCode: Integer); overload;
procedure CefSendKeyEvent(const ABrowser: TChromium; AKeyCode: Integer); overload;
procedure CefUIKeyPress(const ABrowser: ICefBrowser; const AArg: ICefListValue);
function CefUIDoScroll(const ACursor: TPoint; const AStep, ACount: Integer;
  const ABrowser: ICefBrowser; const AAbortEvent: TEvent; const ATimeout: Integer): Boolean;
function CefUIScroll(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const ACursor: TPoint; const ATimeout, AStep, ADir, ATry: Integer): Boolean; overload;
function CefUIScroll(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const ACursor: TPoint; const ASpeed, ADir: Integer): Boolean; overload;
function CefUIScroll(const AAction: TCefScriptBase; const ASpeed, ADir: Integer): Boolean; overload;
function CefUIGetElementText(const ABrowser: ICefBrowser;
  const AAbortEvent: TEvent; const AElement: TElementParams): string; overload;
function CefUIGetElementText(const AAction: TCefScriptBase;
  const AElement: TElementParams): string; overload;
function CefUISetElementValue(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const AElement: TElementParams; const AValue: string): Boolean; overload;
function CefUISetElementValue(const AAction: TCefScriptBase;
  const AElement: TElementParams; const AValue: string): Boolean; overload;
function CefUISetSelectValue(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const AElement: TElementParams; const AValue: string): Boolean; overload;
function CefUISetSelectValue(const AAction: TCefScriptBase;
  const AElement: TElementParams; const AValue: string): Boolean; overload;

function CefUITypeText(const AAction: TCefScriptBase; const AText: string;
  const AElement: TElementParams): Boolean;

function CefUIGetElementAttrValue(const AAction: TCefScriptBase;
  const AElement: TElementParams; const AAttrName: string): string;

implementation

uses
  Winapi.Windows, System.Math, Vcl.Forms,
  //
  uGlobalFunctions,
  //
  uCefUtilConst, uCefWaitEventList;


function CefUISendRenderMessage(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const A: ICefProcessMessage): ICefListValue;
var
  event: TCefWaitEventItem;
  args: ICefListValue;
  res: TWaitResult;
  fired: THandleObject;
  firedS: string;
begin
  event := CefWaitEventAdd();
  try
    args := A.ArgumentList;
    args.SetInt(IDX_EVENT, event.ID);
    CefLog('uifunc', 111, 1, Format('msgSend to render thrd:%d eid:%d tick:%d args:%s', [GetCurrentThreadId, event.ID, event.Tick, CefListValueToJsonStr(args)]));
    ABrowser.SendProcessMessage(PID_RENDERER, A);
    fired := nil;
    res := SleepEvents(event.Event, AAbortEvent, CEF_EVENT_WAIT_TIMEOUT, fired);
    firedS := '?';
    if fired = AAbortEvent then
      firedS := 'abortEvent'
    else
    if fired = event.Event then
      firedS := 'waitEvent';
    CefLog('uifunc', 121, 1, Format('event %s %s thrd:%d eid:%d time:%d args:%s', [WaitResultStr[res], firedS, GetCurrentThreadId, event.ID, event.TickDif, CefListValueToJsonStr(event.Res)]));
    if res = wrSignaled then
    begin
      if fired = event.Event then
      begin
        Exit(event.Res)
      end
      else
      if (AAbortEvent <> nil) and (fired = AAbortEvent) then
      begin
        Exit(nil)
      end
      else
      begin
        raise ECefError.Create('CefUISendRenderMessage() unknow event signaled ' + fired.ClassName)
      end;
    end
    else
    begin
      raise ECefRenderError.CreateFmt('render wait error %s %s time:%d', [WaitResultStr[res], firedS, event.TickDif])
    end;
  finally
    CefWaitEventDelete(event)
  end;
end;



function CefUIElementIdExists(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
    const AId: string): Boolean;
var
  msg: ICefProcessMessage;
  arg, res: ICefListValue;
begin
  msg := CefAppMessageType(VAL_TEST_ID_EXISTS, arg);
  arg.SetString(IDX_ID, AId);

  res := CefUISendRenderMessage(ABrowser, AAbortEvent, msg);
  if Assigned(res) then
    Result := res.GetBool(IDX_RESULT)
  else
    Result := False
end;

function CefUIElementIdExists(const AAction: TCefScriptBase; const AId: string): Boolean;
begin
  Result := CefUIElementIdExists(AAction.Chromium.Browser, AAction.AbortEvent, AId)
end;

function CefUIElementExists(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string): ICefListValue;
var
  msg: ICefProcessMessage;
  arg, res: ICefListValue;
begin
  msg := CefAppMessageType(VAL_TEST_ELEMENT_EXISTS, arg);
  arg.SetString(IDX_TAG, ATag);
  arg.SetString(IDX_ID, AId);
  arg.SetString(IDX_NAME, AName);
  arg.SetString(IDX_CLASS, AClass);
  arg.SetString(IDX_ATTR, AAttrName);
  arg.SetString(IDX_VALUE, AAttrValueRegExpr);

  res := CefUISendRenderMessage(ABrowser, AAbortEvent, msg);
  if Assigned(res) then
  begin
    if res.GetType(IDX_RESULT) = VTYPE_LIST then
      Exit(res.GetList(IDX_RESULT).Copy())
  end;
  Result := nil
end;

function CefUIElementExists(const AAction: TCefScriptBase;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string): ICefListValue;
begin
  Result := CefUIElementExists(AAction.Chromium.Browser, AAction.AbortEvent,
    ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr)
end;

function CefUIElementExists(const AAction: TCefScriptBase;
  const AElement: TElementParams): ICefListValue;
begin
  Result := CefUIElementExists(AAction, AElement.Tag, AElement.Id,
      AElement.Name, AElement.Class_, AElement.AttrName, AElement.AttrValue)
end;

function CefUIElementSetValuaById(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
    const AId, AValue: string): Boolean;
var
  msg: ICefProcessMessage;
  arg, res: ICefListValue;
begin
  msg := CefAppMessageType(VAL_SET_VALUE_BY_ID, arg);
  arg.SetString(IDX_ID, AID);
  arg.SetString(IDX_VALUE, AValue);

  res := CefUISendRenderMessage(ABrowser, AAbortEvent, msg);
  if Assigned(res) then
    Result := res.GetBool(IDX_RESULT)
  else
    Result := False
end;

function CefUIElementSetValuaById(const AAction: TCefScriptBase;
    const AId, AValue: string): Boolean;
begin
  Result := CefUIElementSetValuaById(AAction.Chromium.Browser, AAction.AbortEvent, AId, AValue)
end;

function CefUIElementSetValuaByName(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
    const AName, AValue: string): Boolean;
var
  msg: ICefProcessMessage;
  arg, res: ICefListValue;
begin
  msg := CefAppMessageType(VAL_SET_VALUE_BY_NAME, arg);
  arg.SetString(IDX_NAME, AName);
  arg.SetString(IDX_VALUE, AValue);

  res := CefUISendRenderMessage(ABrowser, AAbortEvent, msg);
  if Assigned(res) then
    Result := res.GetBool(IDX_RESULT)
  else
    Result := False
end;

function CefUIElementSetAttrByName(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
    const AName, AAttr, AValue: string): Boolean;
var
  msg: ICefProcessMessage;
  arg, res: ICefListValue;
begin
  msg := CefAppMessageType(VAL_SET_ATTR_BY_NAME, arg);
  arg.SetString(IDX_NAME, AName);
  arg.SetString(IDX_ATTR, AAttr);
  arg.SetString(IDX_VALUE, AValue);

  res := CefUISendRenderMessage(ABrowser, AAbortEvent, msg);
  if Assigned(res) then
    Result := res.GetBool(IDX_RESULT)
  else
    Result := False
end;

function CefUISetElementValue(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const AElement: TElementParams; const AValue: string): Boolean;
var
  msg: ICefProcessMessage;
  arg, res: ICefListValue;
begin
  msg := CefAppMessageType(VAL_SET_ELEMENT_VALUE, arg);
  AElement.SaveToCefListValue(arg);
  arg.SetString(IDX_VALUE2, AValue);

  res := CefUISendRenderMessage(ABrowser, AAbortEvent, msg);
  if Assigned(res) then
    Result := res.GetBool(IDX_RESULT)
  else
    Result := False
end;

function CefUISetElementValue(const AAction: TCefScriptBase;
  const AElement: TElementParams; const AValue: string): Boolean;
begin
  Result := CefUISetElementValue(AAction.Chromium.Browser, AAction.AbortEvent,
    AElement, AValue)
end;

function ArgsToRect(const A: ICefListValue): TRect;
begin
  Result.Left   := A.GetInt(IDX_LEFT);
  Result.Right  := A.GetInt(IDX_RIGHT);
  Result.Top    := A.GetInt(IDX_TOP);
  Result.Bottom := A.GetInt(IDX_BOTTOM);
end;

function CefUIGetWindowRect(const ABrowser: ICefBrowser; const AAbortEvent: TEvent): TRect;
var
  msg: ICefProcessMessage;
  arg, res: ICefListValue;
begin
  msg := CefAppMessageType(VAL_GET_WINDOW_RECT, arg);

  res := CefUISendRenderMessage(ABrowser, AAbortEvent, msg);
  if Assigned(res) then
  begin
    Result := ArgsToRect(res);
  end
  else
    Result := TRect.Empty
end;

function CefUIGetWindowRect(const AAction: TCefScriptBase): TRect;
begin
  Result := CefUIGetWindowRect(AAction.Chromium.Browser, AAction.AbortEvent)
end;

function CefUIGetBodyRect(const ABrowser: ICefBrowser; const AAbortEvent: TEvent): TRect;
var
  msg: ICefProcessMessage;
  arg, res: ICefListValue;
begin
  msg := CefAppMessageType(VAL_GET_BIDY_RECT, arg);

  res := CefUISendRenderMessage(ABrowser, AAbortEvent, msg);
  if Assigned(res) then
  begin
    Result := ArgsToRect(res);
  end
  else
    Result := TRect.Empty
end;

function CefUIGetElementRect(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const AElem: TElementParams): TRect;
var
  msg: ICefProcessMessage;
  arg, res: ICefListValue;
begin
  msg := CefAppMessageTypeElem(VAL_GET_ELEMENT_RECT, AElem, arg);

  res := CefUISendRenderMessage(ABrowser, AAbortEvent, msg);
  if Assigned(res) then
  begin
    Result := ArgsToRect(res);
  end
  else
    Result := TRect.Empty
end;

function CefUIGetElementRect(const AAction: TCefScriptBase;
  const AElem: TElementParams): TRect;
begin
  Result := CefUIGetElementRect(AAction.Chromium.Browser, AAction.AbortEvent, AElem)
end;

function CefUIGetElementRect(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string): TRect;
begin
  Result := CefUIGetElementRect(ABrowser, AAbortEvent, ElemFilt(ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr))
end;

function CefUIDoScroll(const ACursor: TPoint; const AStep, ACount: Integer;
  const ABrowser: ICefBrowser; const AAbortEvent: TEvent; const ATimeout: Integer): Boolean;
var
  mouseEvent: TCefMouseEvent;
  j: Integer;
begin
  if ACount < 1 then
    Exit(True);

  mouseEvent.x := ACursor.X;
  mouseEvent.y := ACursor.Y;
  mouseEvent.modifiers := EVENTFLAG_NONE;
  for j := 1 to Acount do
  begin
    ABrowser.Host.SendMouseWheelEvent(@mouseEvent, 0, AStep);
    if MainThreadID = GetCurrentThreadId then
    begin
      Application.ProcessMessages;
      Sleep(ATimeout)
    end
    else
    begin
      if Assigned(AAbortEvent) then
        if SleepEvents(AAbortEvent, nil, ATimeout) <> wrTimeout then
          Exit(False)
    end;
  end;
  Result := not Assigned(AAbortEvent) or (SleepEvents(AAbortEvent, nil, SCROLL_WAIT) = wrTimeout)
end;

function CefUIScrollToElement(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const ATimeout, AStep: Integer;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string;
  const ATry: Integer): Boolean;
const
  PADDING = 50;
var
  elem, window: TRect;
  dif, step, count: Integer;
begin
  if ATry >= 9 then
    Exit(True);

  window := CefUIGetWindowRect(ABrowser, AAbortEvent);
  if window.IsEmpty then
    Exit(False);

  elem := CefUIGetElementRect(ABrowser, AAbortEvent, ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr);
  if elem.IsEmpty then
    Exit(False);

  //ABrowser.Host.SendMouseMoveEvent(nil, True);

  step := Abs(AStep);
  // to up
  if (elem.Top - PADDING) < 0 then
  begin
    dif :=  Abs(elem.Top - PADDING);
    count := Round(dif / step);
  end
  else
  //down
  if (elem.Bottom + PADDING) > window.Height then
  begin
    dif :=  (elem.Bottom + PADDING) - window.Height;
    count := Round(dif / step);
    step := -1 * step
  end
  else
  begin
    Exit(True)
  end;
  Result := CefUIDoScroll(TPoint.Zero, step, count, ABrowser, AAbortEvent, ATimeout);
  if Result then
    Result := CefUIScrollToElement(ABrowser, AAbortEvent, ATimeout, AStep,
      ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr, ATry + 1)
end;

function CefUIScrollToElement(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const ASpeed: Integer;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string): Boolean;
var time: Integer;
begin
  time := Round(Power(ASpeed / 50000, -1));
  Result := CefUIScrollToElement(ABrowser, AAbortEvent, time, SCROLL_STEP_DEF,
      ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr, 0)
end;

function CefUIScrollToElement(const AAction: TCefScriptBase;
  const ASpeed: Integer;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string): Boolean;
begin
  Result := CefUIScrollToElement(AAction.Chromium.Browser, AAction.AbortEvent,
      ASpeed, ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr)
end;

function CefUIScrollToElement(const AAction: TCefScriptBase;
  const ASpeed: Integer; const AElement: TElementParams): Boolean;
begin
  Result := (not AElement.IsEmpty) and CefUIScrollToElement(AAction, ASpeed, AElement.Tag, AElement.Id,
      AElement.Name, AElement.Class_, AElement.AttrName, AElement.AttrValue)
end;

function CefUIScrollToElement(const AAction: TCefScriptBase;
  const AElement: TElementParams): Boolean;
begin
  Result := CefUIScrollToElement(AAction, AAction.Controller.Speed, AElement.Tag, AElement.Id,
      AElement.Name, AElement.Class_, AElement.AttrName, AElement.AttrValue)
end;

function CefUIMouseSetToPoint(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const AMousePos: PPoint; const AToPoint: TPoint; const ATimeout: Integer): Boolean;
var
  mouseEvent: TCefMouseEvent;
begin
  if Assigned(AMousePos) then
  begin
    AMousePos^.X := AToPoint.x;
    AMousePos^.Y := AToPoint.y;
  end;

  mouseEvent.x := AToPoint.X;
  mouseEvent.y := AToPoint.Y;
  mouseEvent.modifiers := EVENTFLAG_NONE;

  ABrowser.Host.SendMouseMoveEvent(@mouseEvent, False);
  ABrowser.MainFrame.ExecuteJavaScript('mymouse00 = document.getElementById(''mymouse00''); mymouse00.style.left = "'+IntToStr(mouseEvent.x+2)+'px"; mymouse00.style.top = "'+IntToStr(mouseEvent.y+2)+'px";', '', 0);

  if MainThreadID = GetCurrentThreadId then
  begin
    Application.ProcessMessages;
    Sleep(ATimeout)
  end
  else
  begin
    if SleepEvents(AAbortEvent, nil, ATimeout) <> wrTimeout then
      Exit(False)
  end;

  Exit(True)
end;

function CefUIMouseSetToPoint(const AAction: TCefScriptBase;
  const AToPoint: TPoint; const ATimeout: Integer): Boolean;
begin
  Result := CefUIMouseSetToPoint(AAction.Chromium.Browser, AAction.AbortEvent,
    @AAction.Controller.Cursor, AToPoint, ATimeout)
end;

function CefUIMouseMoveToElement(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  var APoint: TPoint; const ATimeout, AStep: Integer;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string): Boolean;
var
  elem: TRect;
  ElemCenter: TPoint;
  lx,ly: Integer;
//  xs,ys, xf,yf: Integer;
  stepCount: Integer;
  xb, yb: Boolean;
  xk, yk, len, xp, yp: Extended;
begin
  elem := CefUIGetElementRect(ABrowser, AAbortEvent, ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr);
  if elem.IsEmpty then
    Exit(False);
  ElemCenter := elem.CenterPoint;

  // направление True - назад
  xb := ElemCenter.X < APoint.X;
  yb := ElemCenter.y < APoint.y;
  // Первая точка прямой
  //xs := Min(ElemCenter.X, APoint.X);
  //ys := Min(ElemCenter.Y, APoint.Y);
  // Последняя точка прятой
  //xf := Max(ElemCenter.X, APoint.X);
  //yf := Max(ElemCenter.Y, APoint.Y);
  // длинная  прямой по осям
  lx := abs(ElemCenter.X-APoint.X);
  ly := abs(ElemCenter.Y-APoint.Y);
  // длинна прямой
  len := Sqrt(IntPower(lx, 2) + IntPower(ly, 2));
  // кол-во шагов
  stepCount := Round(len / AStep);
  if stepCount < 1 then
    stepCount := 1;
  // длина шага по прямой
  //step := len / stepCount;
  // длина шага по осям
  xk := lx / stepCount;
  yk := ly / stepCount;
  // если в обратную торону
  if xb then
    xk := -1 * xk;
  if yb then
    yk := -1 * yk;

  // текущее положение
  xp := APoint.X;
  yp := APoint.Y;
  while True do
  begin
    xp := xp + xk;
    yp := yp + yk;

    CefUIMouseSetToPoint(ABrowser, AAbortEvent, @APoint, TPoint.Create(Round(xp), Round(yp)), ATimeout);

    if Abs(ElemCenter.X - APoint.X) <= 2 then
      if Abs(ElemCenter.Y - APoint.Y) <= 2 then
        Exit(True);

  end;
  Exit(False);
end;

function CefUIMouseSetToElement(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  var APoint: TPoint; const ATimeout, AStep: Integer;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string): Boolean;
var
  elem: TRect;
  ElemCenter: TPoint;
begin
  elem := CefUIGetElementRect(ABrowser, AAbortEvent, ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr);
  if elem.IsEmpty then
    Exit(False);
  ElemCenter := TPoint.Create(elem.Left + 2, elem.Top + 2);

  CefUIMouseSetToPoint(ABrowser, AAbortEvent, @APoint, ElemCenter, ATimeout);

  if Abs(ElemCenter.X - APoint.X) <= 2 then
    if Abs(ElemCenter.Y - APoint.Y) <= 2 then
      Exit(True);

  Exit(False);
end;

function CefUIMouseMoveToElement(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  var APoint: TPoint; const ASpeed: Integer;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string): Boolean;
var pause: Integer;
begin
  pause := Round(Power(ASpeed / 20000, -1));
  Result :=
  //CefUIMouseMoveToElement
  CefUIMouseSetToElement(ABrowser, AAbortEvent, APoint, pause, 2,
    ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr)
end;

function CefUIMouseMoveToElement(const AAction: TCefScriptBase; const ASpeed: Integer;
  const ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr: string): Boolean;
begin
  Result := CefUIMouseMoveToElement(AAction.Chromium.Browser, AAction.AbortEvent,
    AAction.Controller.Cursor, ASpeed, ATag, AId, AName, AClass, AAttrName, AAttrValueRegExpr)
end;

function CefUIMouseMoveToElement(const AAction: TCefScriptBase; const ASpeed: Integer;
  const AElement: TElementParams): Boolean;
begin
  Result := CefUIMouseMoveToElement(AAction, ASpeed, AElement.Tag, AElement.Id,
      AElement.Name, AElement.Class_, AElement.AttrName, AElement.AttrValue)
end;

function CefUIMouseMoveToElement(const AAction: TCefScriptBase;
  const AElement: TElementParams): Boolean;
begin
  Result := CefUIMouseMoveToElement(AAction, AAction.Controller.Speed, AElement.Tag, AElement.Id,
      AElement.Name, AElement.Class_, AElement.AttrName, AElement.AttrValue)
end;

procedure CefUIMouseClick(const ABrowser: ICefBrowser; const APoint: TPoint);
var mouseEvent: TCefMouseEvent;
begin
  mouseEvent.x := APoint.X;
  mouseEvent.y := APoint.Y;
  mouseEvent.modifiers := EVENTFLAG_NONE;
  Sleep(50);
  ABrowser.Host.SendMouseClickEvent(@mouseEvent, MBT_LEFT, False, 1);
  Sleep(100);
  ABrowser.Host.SendMouseClickEvent(@mouseEvent, MBT_LEFT, True, 1);
  Sleep(50);
end;

procedure CefUIMouseClick(const AAction: TCefScriptBase);
begin
  CefUIMouseClick(AAction.Chromium.Browser, AAction.Controller.Cursor)
end;

procedure CefUIClickAndCallback(const ABrowser: ICefBrowser; const AArg: ICefListValue);
var x,y,id: Integer;
begin
  x := AArg.GetInt(IDX_X);
  y := AArg.GetInt(IDX_Y);
  CefUIMouseClick(ABrowser, TPoint.Create(x, y));
  //
  id := aarg.GetInt(IDX_CALLBACKID);
  CefExecJsCallback(ABrowser, id);
end;

procedure CefSendKeyEvent(const ABrowser: ICefBrowser; AKeyCode: Integer);
var
  event: TCefKeyEvent;
  VkCode: Byte;
  scanCode: UINT;
begin
  FillMemory(@event, SizeOf(event), 0);
  event.is_system_key := 0;
  event.modifiers := 0;

  VkCode := LOBYTE(VkKeyScan(Char(AkeyCode)));
  scanCode := MapVirtualKey(VkCode, MAPVK_VK_TO_VSC);

  event.native_key_code := (scanCode shl 16) or  // key scan code
                             1;                  // key repeat count
  event.windows_key_code := VkCode;
  event.kind := KEYEVENT_RAWKEYDOWN;
  ABrowser.Host.SendKeyEvent(@event);

  event.windows_key_code := AKeyCode;
  event.kind := KEYEVENT_CHAR;
  ABrowser.Host.SendKeyEvent(@event);

  event.windows_key_code := VkCode;
  // bits 30 and 31 should be always 1 for WM_KEYUP
  event.native_key_code := event.native_key_code or Integer($C0000000);
  event.kind := KEYEVENT_KEYUP;
  ABrowser.Host.SendKeyEvent(@event);
end;

procedure CefSendKeyEvent(const ABrowser: TChromium; AKeyCode: Integer);
begin
  CefSendKeyEvent(ABrowser.Browser, AKeyCode)
end;

procedure CefUIKeyPress(const ABrowser: ICefBrowser; const AArg: ICefListValue);
var key: Integer;
begin
  key := AArg.GetInt(IDX_VALUE);
  CefSendKeyEvent(ABrowser, key)
end;


function CefUIScroll(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const ACursor: TPoint; const ATimeout, AStep, ADir, ATry: Integer): Boolean;
var
  window, body: TRect;
  dir, step, count: Integer;
begin
  if ATry >= 5 then
    Exit(True);

  body := CefUIGetBodyRect(ABrowser, AAbortEvent);
  if body.IsEmpty then
    Exit(False);
  window := CefUIGetWindowRect(ABrowser, AAbortEvent);
  if window.IsEmpty then
    Exit(False);

  step := Abs(AStep);
  dir := ADir;
  if dir = 0 then
  begin
    dir := IfElse(window.Top = 0, DIR_DOWN, DIR_UP)
  end;

  // DIR_UP
  if dir > 0 then
  begin
    count := window.Top div step;
  end
  else
  begin
    // DOWN
    count := (body.Height - window.Bottom) div step;
    step := -1 * step;
  end;
  Result := CefUIDoScroll(ACursor, step, count, ABrowser, AAbortEvent, ATimeout);
  if Result then
    Result := CefUIScroll(ABrowser, AAbortEvent, ACursor, ATimeout, AStep, dir, ATry+1)
end;

function CefUIScroll(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const ACursor: TPoint; const ASpeed, ADir: Integer): Boolean;
begin
  Result := CefUIScroll(ABrowser, AAbortEvent, ACursor,
    Round(Power(ASpeed / 50000, -1)), SCROLL_STEP_DEF, ADir, 0)
end;

function CefUIScroll(const AAction: TCefScriptBase; const ASpeed, ADir: Integer): Boolean;
begin
  Result := CefUIScroll(AAction.Chromium.Browser, AAction.AbortEvent,
    AAction.Controller.Cursor, ASpeed, ADir)
end;

function CefUIGetElementText(const ABrowser: ICefBrowser;
  const AAbortEvent: TEvent; const AElement: TElementParams): string;
var
  msg: ICefProcessMessage;
  arg, res: ICefListValue;
begin
  msg := CefAppMessageType(VAL_GET_ELEMENT_TEXT, arg);
  AElement.SaveToCefListValue(arg);
  res := CefUISendRenderMessage(ABrowser, AAbortEvent, msg);
  if Assigned(res) then
  begin
    Result := res.GetString(IDX_RESULT);
    Exit;
  end;
  Result := ''
end;

function CefUIGetElementText(const AAction: TCefScriptBase;
  const AElement: TElementParams): string;
begin
  Result := CefUIGetElementText(AAction.Chromium.Browser, AAction.AbortEvent, AElement)
end;


function CefUISetSelectValue(const ABrowser: ICefBrowser; const AAbortEvent: TEvent;
  const AElement: TElementParams; const AValue: string): Boolean;
var
  msg: ICefProcessMessage;
  arg, res: ICefListValue;
begin
  msg := CefAppMessageTypeElem(VAL_SET_SELECT_VALUE, AElement, AValue, arg);

  res := CefUISendRenderMessage(ABrowser, AAbortEvent, msg);
  if Assigned(res) then
    Result := res.GetBool(IDX_RESULT)
  else
    Result := False
end;

function CefUISetSelectValue(const AAction: TCefScriptBase;
  const AElement: TElementParams; const AValue: string): Boolean;
begin
  Result := CefUISetSelectValue(AAction.Chromium.Browser, AAction.AbortEvent, AElement, AValue)
end;

function CefUIGetElementsAttr(const AAction: TCefScriptBase;
  const AElement: TElementParams): ICefListValue;
var
  msg: ICefProcessMessage;
  res: ICefListValue;
begin
  msg := CefAppMessageTypeElem(VAL_GET_ELEMENTS_ATTR, AElement);
  res := CefUISendRenderMessage(AAction.Chromium.Browser, AAction.AbortEvent, msg);
  if Assigned(res) then
    if res.GetType(IDX_RESULT) = VTYPE_LIST then
      Exit(res.GetList(IDX_RESULT).Copy());
  Result := nil
end;

function CefUITypeText(const AAction: TCefScriptBase; const AText: string;
  const AElement: TElementParams): Boolean;
var
  br: TChromium;
  ch: Char;
begin
  br := AAction.Chromium;
  br.SendFocusEvent(True);
  if CefUIScrollToElement(AAction, AElement) then
  begin
    if CefUIMouseMoveToElement(AAction, AElement) then
    begin
      CefUIMouseClick(AAction);
      for ch in AText do
      begin
        CefSendKeyEvent(br, Ord(ch));
        if SleepEvents(AAction.AbortEvent, nil, 500) <> wrTimeout then
          Exit(False)
      end;
      Exit(True)
    end;
  end;
  Exit(False)
end;


function CefUIGetElementAttrValue(const AAction: TCefScriptBase;
  const AElement: TElementParams; const AAttrName: string): string;
var
  res: ICefListValue;
  dic: ICefDictionaryValue;
begin
  res := CefUIElementExists(AAction, AElement);
  if Assigned(res) then
  begin
    dic := res.GetDictionary(IDX_ATTR);
    if Assigned(dic) then
    begin
      Result := dic.GetString(AAttrName);
      Exit;
    end;
  end;
  Exit('')
end;


end.
