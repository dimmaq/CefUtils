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

  TCefSendEventTaskItem = class abstract
  protected
    FOwner: TCefSendEventThread;
    FBrowser: ICefBrowser;
    FArgs: ICefListValue;
    procedure Execute; virtual; abstract;
  public
    constructor Create(const ABrowser: ICefBrowser; const AArgs: ICefListValue);
  end;


  TCefSendEventThread = class(TWorkThreadBase)
  private
    FLock: TCriticalSection;
    FEvent: TEvent;
    FQueue: TList<TCefSendEventTaskItem>;
    procedure StartNextTask;
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
    //
    procedure AddTask(const ATask: TCefSendEventTaskItem);
  end;


procedure CefSendEventThreadInit(OnTErminated: TNotifyEvent);
procedure CefSendEventThreadFinal;
procedure CefSendEventThreadTaskAdd(const ATask: TCefSendEventTaskItem);


implementation

var
  gQueueThread: TCefSendEventThread;

procedure CefSendEventThreadInit(OnTErminated: TNotifyEvent);
begin
  Assert(gQueueThread = nil, 'CefSendEventThread already init');

  if not Assigned(gQueueThread) then
  begin
    gQueueThread := TCefSendEventThread.Create;
    gQueueThread.OnTerminate := OnTErminated;
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

procedure CefSendEventThreadTaskAdd(const ATask: TCefSendEventTaskItem);
begin
  Assert(gQueueThread <> nil, 'CefSendEventThread not init');

  if Assigned(gQueueThread) then
    gQueueThread.AddTask(ATask);
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
  FQueue := TList<TCefSendEventTaskItem>.Create;
end;

destructor TCefSendEventThread.Destroy;
begin
  FLock.Enter;
  while FQueue.Count > 0 do
  begin
    FQueue.Last.Free;
    FQueue.Delete(FQueue.Count - 1);
  end;
  FreeAndNil(FQueue);
  FreeAndNil(FEvent);
  FreeAndNil(FLock);
  inherited;
end;

procedure TCefSendEventThread.Execute;
begin
    while not Aborted do
    begin
      Sleep(60000, FEvent);
      if Aborted then
        Exit
      else
      if FQueue.Count > 0 then
        StartNextTask()
    end;
end;

procedure TCefSendEventThread.AddTask(const ATask: TCefSendEventTaskItem);
begin
  FLock.Enter;
  try
    FQueue.Add(ATask);
    FEvent.SetEvent();
  finally
    FLock.Leave
  end;
end;

procedure TCefSendEventThread.StartNextTask;
const
  LEN = 10;
var
  arr: TArray<TCefSendEventTaskItem>;
  task: TCefSendEventTaskItem;
  j: Integer;
begin
  FLock.Enter;
  try
    arr := FQueue.ToArray();
    while FQueue.Count > 0 do
    begin
      FQueue.Delete(FQueue.Count - 1);
    end;
    FEvent.ResetEvent();
  finally
    FLock.Leave
  end;
  try
    for j := 0 to Length(arr) - 1 do
    begin
      task := arr[j];
      if not Aborted then
        if Assigned(task) then
          task.Execute();
    end;
  finally
    for j := 0 to Length(arr) - 1 do
    begin
      task := arr[j];
      task.Free;
    end;
  end;
end;

{ TCefSendEventTaskItem }

constructor TCefSendEventTaskItem.Create(const ABrowser: ICefBrowser;
  const AArgs: ICefListValue);
begin
  inherited Create;
  FBrowser := ABrowser;
  FArgs := AArgs.Copy();
  FOwner := gQueueThread;
end;

initialization

finalization
  CefSendEventThreadFinal();

end.
