unit uCefScriptDict;

interface

uses
  //
  System.SysUtils, System.Classes, System.Generics.Collections,
  System.Generics.Defaults, System.SyncObjs,
  //
  uCEFInterfaces, uCEFChromium,
  //
  uReLog3, uLoggerInterface,
  //
  uCefScriptBase, uCefUtilType;

type
  TCefScriptClass = class of TCefScriptBase;
  TCefScriptPair = TPair<string,TCefScriptClass>;
  TCefScriptList = TList<TCefScriptPair>;

  TCefScriptDict = class
  private
    FItems: TCefScriptList;
    function Find(const AKey: string; var AClass: TCefScriptClass): Boolean;
    function ParseLine(const ALine: string; var AName, AParam: string;
      var AIgnore: Boolean): TCefScriptClass;
  public
    constructor Create;
    destructor Destroy; override;
    function MakeScript(const ALine: string; const AController: TCefControllerBase;
        const ALogger: ILoggerInterface; const AWebBrowser: TChromium;
        const AAbortEvent: TEvent): TCefScriptBase; overload;
    function MakeScript(const ALine: string; const AParent: TCefScriptBase): TCefScriptBase; overload;
    procedure Add(const AName: string; const AClass: TCefScriptClass); overload;
    procedure Add(const AClass: TCefScriptClass); overload;
    function Keys: TArray<string>;
  end;

implementation

uses
  //
  uStringUtils, uGlobalConstants;

{ TCefScriptDict }

procedure TCefScriptDict.Add(const AName: string;
  const AClass: TCefScriptClass);
begin
  FItems.Add(TCefScriptPair.Create(AName, AClass))
end;

procedure TCefScriptDict.Add(const AClass: TCefScriptClass);
begin
  Add(AClass.GetName(), AClass)
end;

constructor TCefScriptDict.Create;
begin
  inherited;
  FItems := TCefScriptList.Create();
end;

destructor TCefScriptDict.Destroy;
begin
  FreeAndNil(FItems);
  inherited;
end;

function TCefScriptDict.Find(const AKey: string;
  var AClass: TCefScriptClass): Boolean;
var
  item: TCefScriptPair;
begin
  for item in FItems do
  begin
    if AnsiCompareText(item.Key, AKey) = 0 then
    begin
      AClass := item.Value;
      Exit(True);
    end;
  end;
  Exit(False)
end;

function TCefScriptDict.Keys: TArray<string>;
var
  list: TList<string>;
  item: TCefScriptPair;
begin
  list := TList<string>.Create;
  try
    for item in FItems do
      list.Add(item.Key);
    Result := list.ToArray
  finally
    list.Free
  end
end;

function TCefScriptDict.ParseLine(const ALine: string; var AName,
  AParam: string; var AIgnore: Boolean): TCefScriptClass;
var
  cat, param: string;
  clss: TCefScriptClass;
  ignor: Boolean;
begin
  param := ALine;
  cat := StrCut(param, gCharsSpace);
  ignor := False;
  if (cat <> '') and (cat[1] = '!') then
  begin
    ignor := True;
    Delete(cat, 1, 1)
  end;
  //---
  AName := Trim(cat);
  AParam := Trim(param);
  AIgnore := ignor;
  if Find(cat, clss) then
    Exit(clss);

  Exit(nil);
end;

function TCefScriptDict.MakeScript(const ALine: string;
  const AParent: TCefScriptBase): TCefScriptBase;
var
  cat, param: string;
  clss: TCefScriptClass;
  ignor: Boolean;
begin
  clss := ParseLine(ALine, cat, param, ignor);
  if Assigned(clss) then
    Exit(clss.Create(AParent, param, ignor));

  Result := nil;
end;

function TCefScriptDict.MakeScript(const ALine: string;
  const AController: TCefControllerBase;
  const ALogger: ILoggerInterface;
  const AWebBrowser: TChromium;
  const AAbortEvent: TEvent): TCefScriptBase;
var
  cat, param: string;
  clss: TCefScriptClass;
  ignor: Boolean;
begin
  clss := ParseLine(ALine, cat, param, ignor);
  if Assigned(clss) then
    Exit(clss.Create(param, ignor, ALogger, AWebBrowser, AController, AAbortEvent));

  Result := nil;
end;

end.
