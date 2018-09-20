unit uCefWaitEventList;

interface

uses
  System.SysUtils, System.Classes, System.SyncObjs, System.Generics.Collections,
  Winapi.Windows,
  //
  uCEFInterfaces;

type
  TCefWaitEventItem = class
  private
    class var
      FUID: Integer;
  public
    ID: Integer;
    Event: TEvent;
    Res: ICefListValue;
    Tick: Cardinal;
    constructor Create;
    destructor Destroy; override;
    function TickDif: Cardinal;
  end;

procedure CefWaitEventInit;
function CefWaitEventAdd: TCefWaitEventItem;
procedure CefWaitEventDelete(const A: TCefWaitEventItem);
function CefWaitEventGet(const AId: Integer): TCefWaitEventItem;

implementation

uses
  //
  AcedCommon;

type
  TCefWaitEventList = class
  private
    FLock: TCriticalSection;
    FList: TObjectList<TCefWaitEventItem>;
  public
    constructor Create;
    destructor Destroy; override;

    function Add: TCefWaitEventItem;
    procedure Delete(const A: TCefWaitEventItem);
    function Get(const AId: Integer): TCefWaitEventItem;
  end;

var
  gCefWaitEventList: TCefWaitEventList;

procedure CefWaitEventInit;
begin
  TCefWaitEventItem.FUID := 0;
  gCefWaitEventList := TCefWaitEventList.Create;
end;

function CefWaitEventAdd: TCefWaitEventItem;
begin
  Result := gCefWaitEventList.Add()
end;

procedure CefWaitEventDelete(const A: TCefWaitEventItem);
begin
  gCefWaitEventList.Delete(A)
end;

function CefWaitEventGet(const AId: Integer): TCefWaitEventItem;
begin
  Result := gCefWaitEventList.Get(AId)
end;

{ TCefWaitEventList }

constructor TCefWaitEventList.Create;
begin
  FLock := TCriticalSection.Create;
  FList := TObjectList<TCefWaitEventItem>.Create;
end;

destructor TCefWaitEventList.Destroy;
begin
  FList.Free;
  FLock.Free;
  inherited;
end;

function TCefWaitEventList.Get(const AId: Integer): TCefWaitEventItem;
begin
  FLock.Enter;
  try
    for Result in FList do
      if Result.ID = AId then
        Exit
  finally
    FLock.Leave
  end;
  Exit(nil)
end;

function TCefWaitEventList.Add: TCefWaitEventItem;
begin
  FLock.Enter;
  try
    Result := TCefWaitEventItem.Create;
    FList.Add(Result);
  finally
    FLock.Leave
  end;
end;

procedure TCefWaitEventList.Delete(const A: TCefWaitEventItem);
begin
  FLock.Enter;
  try
    FList.Remove(A);
  finally
    FLock.Leave
  end;
end;

{ TCefWaitEventItem }

constructor TCefWaitEventItem.Create;
begin
  ID := TCefWaitEventItem.FUID;
  Inc(TCefWaitEventItem.FUID);
  Event := TEvent.Create;
  Event.ResetEvent();
  Tick := GetTickCount()
end;

destructor TCefWaitEventItem.Destroy;
begin
  Event.Free;
  inherited;
end;

function TCefWaitEventItem.TickDif: Cardinal;
begin
  Result := G_TickCountSince(Tick)
end;

initialization
  // InitWaitEvent

finalization
  FreeAndNil(gCefWaitEventList)

end.
