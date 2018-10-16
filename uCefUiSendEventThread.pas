unit uCefUiSendEventThread;

interface

uses
  System.SysUtils, System.Classes, System.Types, System.Generics.Collections,
  System.SyncObjs,
  //
  uCEFInterfaces,
  //
  uWorkThreadBase;

type
  TCefSendEventThread = class;

  TCefSendEventTaskProc = reference to procedure(const AOwner: TCefSendEventThread);

  TCefSendEventThread = class(TWorkThreadBase)
  private
    FLock: TCriticalSection;
    FEvent: TEvent;
    FQueue: TQueue<TCefSendEventTaskProc>;
    procedure StartTask(const AProc: TCefSendEventTaskProc);
    procedure StartNextTask;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
    //
    procedure AddTask(const AProc: TCefSendEventTaskProc);
  end;


procedure CefSendEventThreadInit;
procedure CefSendEventThreadFinal;
procedure CefSendEventThreadTaskAdd(const AProc: TCefSendEventTaskProc);

implementation

var
  gQueueThread: TCefSendEventThread;

procedure CefSendEventThreadInit;
begin
  Assert(gQueueThread = nil, 'CefSendEventThread already init');

  if not Assigned(gQueueThread) then
  begin
    gQueueThread := TCefSendEventThread.Create;
    gQueueThread.Start();
  end;
end;

procedure CefSendEventThreadFinal;
begin
  if Assigned(gQueueThread) then
  begin
    gQueueThread.Terminate();
    gQueueThread.WaitFor;
    FreeAndNil(gQueueThread);
  end;
end;

procedure CefSendEventThreadTaskAdd(const AProc: TCefSendEventTaskProc);
begin
  Assert(gQueueThread <> nil, 'CefSendEventThread not init');

  if Assigned(gQueueThread) then
    gQueueThread.AddTask(AProc);
end;

{ TCefSendEventThread }

constructor TCefSendEventThread.Create;
begin
  inherited Create;
  FreeOnTerminate := False;
  NameThreadForDebugging('TCefSendEventThread');
  //
  FLock := TCriticalSection.Create;
  FEvent := TEvent.Create(nil, True, False, '');
  FQueue := TQueue<TCefSendEventTaskProc>.Create;
end;

destructor TCefSendEventThread.Destroy;
begin
  FLock.Enter;
  FreeAndNil(FQueue);
  FreeAndNil(FEvent);
  FreeAndNil(FLock);
  inherited;
end;

procedure TCefSendEventThread.Execute;
var signaled: THandleObject;
begin
  while not Aborted do
  begin
    signaled := Sleep(1000, FEvent);
    if Aborted then
      Exit;
    //
    if signaled = FEvent then
      StartNextTask();
  end;
end;

procedure TCefSendEventThread.AddTask(const AProc: TCefSendEventTaskProc);
begin
  FLock.Enter;
  try
    FQueue.Enqueue(AProc);
    FEvent.SetEvent();
  finally
    FLock.Leave
  end;
end;

procedure TCefSendEventThread.StartNextTask;
var proc: TCefSendEventTaskProc;
begin
  if FQueue.Count = 0 then
    Exit;
  proc := nil;
  FLock.Enter;
  try
    if FQueue.Count > 0 then
      proc := FQueue.Dequeue();

{    while (FQueue.Count > 0) and not Aborted do
    begin
      proc := FQueue.Dequeue();
    end;
    }
    FEvent.ResetEvent();
  finally
    FLock.Leave
  end;
  if not Aborted then
    StartTask(proc);
end;

procedure TCefSendEventThread.StartTask(const AProc: TCefSendEventTaskProc);
begin
  if Assigned(AProc) then
    AProc(Self)
end;

initialization

finalization
  CefSendEventThreadFinal();

end.
