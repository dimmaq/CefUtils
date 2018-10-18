unit uCefUtilCallbackList;

interface

uses
  SysUtils, Classes, System.Generics.Collections, ioutils, System.SyncObjs,
  //
  uCEFTypes, uCEFInterfaces, uCEFv8Value, uCEFProcessMessage, uCEFv8Handler,
  uCEFMiscFunctions,
   uCEFv8Context;

type
  TCefCallbackItem = record
    Id: Integer;
    Func: ICefv8Value;
    Ctx: ICefv8Context;
    constructor Create(const AFunc: ICefv8Value);
  end;

  TCefCallbackContainer = class
  private
    FLock: TCriticalSection;
    FList: TList<TCefCallbackItem>;
  public
    constructor Create;
    destructor Destroy; override;
    //
    function Add(const AFunc: ICefv8Value): Integer;
    procedure ContextRelease(const ACtx: ICefv8Context);
    function Execute(const AId: Integer): Boolean;
  end;

var
  gCallbackList: TCefCallbackContainer;

implementation

{ TCefCallbackContainer }

function TCefCallbackContainer.Add(const AFunc: ICefv8Value): Integer;
var item: TCefCallbackItem;
begin
  Result := 0;
  if (not Assigned(AFunc)) or (not AFunc.IsFunction) then
    Exit;
  //
  FLock.Enter;
  try
//    CefDebugLog('cb/Add');
    item := TCefCallbackItem.Create(afunc);
    FList.Add(item);
    Result := item.Id;
  finally
    FLock.Leave
  end;
end;

procedure TCefCallbackContainer.ContextRelease(const ACtx: ICefv8Context);
var
  item: TCefCallbackItem;
  j: Integer;
begin
  FLock.Enter;
  try
   // CefDebugLog('cb/ContextRelease');
    for j := FList.Count - 1 downto 0 do
    begin
      item := FList[j];
      if item.Ctx.IsSame(ACtx) then
        FList.Delete(j)
    end;
  finally
    FLock.Leave
  end;
end;

constructor TCefCallbackContainer.Create;
begin
  FLock := TCriticalSection.Create;
  FList := TList<TCefCallbackItem>.Create;
end;

destructor TCefCallbackContainer.Destroy;
begin
  FLock.Free;
  FList.Free;
  inherited;
end;

function TCefCallbackContainer.Execute(const AId: Integer): Boolean;
var
  item: TCefCallbackItem;
  j: Integer;
begin
  FLock.Enter;
  try
   // CefDebugLog('cb/exec');
    for j := 0 to FList.Count - 1 do
    begin
      item := FList[j];
      if item.Id = AId then
      begin
        item.Func.ExecuteFunctionWithContext(item.Ctx, nil, nil);
        FList.Delete(j);
        Exit(True)
      end;
    end;
  finally
    FLock.Leave
  end;
  Result := False
end;

var
  ID_COUNTER: Integer = 0;

{ TCefCallbackItem }

constructor TCefCallbackItem.Create(const AFunc: ICefv8Value);
begin
  Id := TInterlocked.Increment(ID_COUNTER);
  Func := AFunc;
  Ctx := TCefv8ContextRef.Current();
end;

initialization
  gCallbackList := TCefCallbackContainer.Create;

finalization
  gCallbackList.Free;

end.
