unit uCefJsExt;

interface

(*
procedure CefOnWebKitInitializedEvent;
begin
  TMyExt.DoRegister(TMyExt.Create('myext'));
end;
*)

uses
  System.SysUtils, System.Classes, System.Generics.Collections, System.Math,
  //
  uCEFTypes, uCEFInterfaces, uCEFv8Value, uCEFProcessMessage, uCEFv8Handler,
  uCEFMiscFunctions, uCEFv8Context;

type
  TJsFunc = procedure(const obj: ICefv8Value; const arguments: TCefv8ValueArray; var retval: ICefv8Value; var exception: ustring) of object;
  TJsParam = TPair<TJsFunc, TJsFunc>;

  THandlersDict = TDictionary<string, TJsFunc>;
  TParamsDict = TDictionary<string, TJsParam>;

  TCefJsExt = class;
  TCefJsExtClass = class of TCefJsExt;

  TCefJsExt = class(TCefv8HandlerOwn)
  private
    FName: string;
    FTestParam: string;
  private
    procedure Click(const obj: ICefv8Value; const arguments: TCefv8ValueArray; var retval: ICefv8Value; var exception: ustring);
    procedure FocusClick(const obj: ICefv8Value; const arguments: TCefv8ValueArray; var retval: ICefv8Value; var exception: ustring);
    procedure KeyPress(const obj: ICefv8Value; const arguments: TCefv8ValueArray; var retval: ICefv8Value; var exception: ustring);
    procedure Notify(const obj: ICefv8Value; const arguments: TCefv8ValueArray; var retval: ICefv8Value; var exception: ustring);
    procedure GetParamHandler(const obj: ICefv8Value; const arguments: TCefv8ValueArray; var retval: ICefv8Value; var exception: ustring);
    procedure TestParamGetter(const obj: ICefv8Value; const arguments: TCefv8ValueArray; var retval: ICefv8Value; var exception: ustring);
    procedure TestParamSetter(const obj: ICefv8Value; const arguments: TCefv8ValueArray; var retval: ICefv8Value; var exception: ustring);
  protected
    CefV8FalseValue: ICefv8Value;
    CefV8TrueValue: ICefv8Value;
    CefV8BoolValues: array[Boolean] of ICefv8Value;
  protected
    FHandlers: THandlersDict;
    FParams: TParamsDict;
    function GetParam(const AName: string; out AValue: ICefv8Value): Boolean; virtual;
  protected
    function Execute(const name: ustring; const obj: ICefv8Value; const arguments: TCefv8ValueArray;
      var retval: ICefv8Value; var exception: ustring): Boolean; override;
  public
    constructor Create(const AName: string); reintroduce;
    destructor Destroy; override;
    procedure AfterConstruction; override;
    //
    function GetJsCode: string;
    class procedure DoRegister(const A: TCefJsExtClass; const AName: string); overload;
    class procedure DoRegister(const A: TCefJsExt); overload;
    property Name: string read FName write FName;
  end;

function TryGetArgument(const AArguments: TCefv8ValueArray; const AIndex: Integer;
  var AValue: ICefv8Value): Boolean; overload;
function TryGetArgument(const AArguments: TCefv8ValueArray; const AIndex: Integer;
  var AValue: Integer): Boolean; overload;
function TryGetArgument(const AArguments: TCefv8ValueArray; const AIndex: Integer;
  var AValue: string): Boolean; overload;
function TryGetArgument(const AArguments: TCefv8ValueArray; const AIndex: Integer;
  var AValue: Boolean): Boolean; overload;

implementation

uses
  uCefUtilConst, uCefUtilFunc, uCefRenderFunc;

function TryGetArgument(const AArguments: TCefv8ValueArray; const AIndex: Integer;
  var AValue: ICefv8Value): Boolean;
begin
  AValue := nil;
  if Length(AArguments) < (AIndex + 1) then
    Exit(False);
  AValue := AArguments[AIndex];
  Result := True;
end;

function TryGetArgument(const AArguments: TCefv8ValueArray; const AIndex: Integer;
  var AValue: Integer): Boolean;
var v: ICefv8Value;
begin

  if TryGetArgument(AArguments, AIndex, v) and Assigned(v) then
  begin
    if v.IsInt then
    begin
      AValue := v.GetIntValue;
      Exit(True)
    end
    else
    if v.isUInt then
    begin
      AValue := v.GetUIntValue;
      Exit(True)
    end
  end;
  Result := False;
end;

function TryGetArgument(const AArguments: TCefv8ValueArray; const AIndex: Integer;
  var AValue: string): Boolean;
var v: ICefv8Value;
begin
  if TryGetArgument(AArguments, AIndex, v) and Assigned(v) then
  begin
    if v.IsString then
    begin
      AValue := v.GetStringValue;
      Exit(True)
    end
  end;
  Result := False;
end;

function TryGetArgument(const AArguments: TCefv8ValueArray; const AIndex: Integer;
  var AValue: Boolean): Boolean;
var v: ICefv8Value;
begin
  if TryGetArgument(AArguments, AIndex, v) and Assigned(v) then
  begin
    if v.IsBool then
    begin
      AValue := v.GetBoolValue();
      Exit(True)
    end
  end;
  Result := False;
end;


class procedure TCefJsExt.DoRegister(const A: TCefJsExt);
var
  code: string;
  v8handler: ICefv8Handler;
begin
  // This is the JS extension example with a function in the "JavaScript Integration" wiki page at
  // https://bitbucket.org/chromiumembedded/cef/wiki/JavaScriptIntegration.md

  Assert(A.Name <> '', 'TCefJsExt.Name is empty');

  code := A.GetJsCode();
  v8handler := A;

  CefRegisterExtension('v8/' + A.FName, code, v8handler);
end;

class procedure TCefJsExt.DoRegister(const A: TCefJsExtClass; const AName: string);
begin
  DoRegister(A.Create(AName))
end;

constructor TCefJsExt.Create(const AName: string);
begin
  inherited Create;
  Name := AName;
  FHandlers := THandlersDict.Create;
  FParams := TParamsDict.Create;

  CefV8FalseValue := TCefv8ValueRef.NewBool(False);
  CefV8TrueValue := TCefv8ValueRef.NewBool(True);
  CefV8BoolValues[True] := CefV8TrueValue;
  CefV8BoolValues[False] := CefV8FalseValue;
end;

destructor TCefJsExt.Destroy;
begin
  FParams.Free;
  FHandlers.Free;
  inherited;
end;

procedure TCefJsExt.AfterConstruction;
begin
  inherited;

  FHandlers.Add('click', Click);
  FHandlers.Add('focusClick', FocusClick);
  FHandlers.Add('keyPress', KeyPress);
  FHandlers.Add('notify', Notify);
  FHandlers.Add('getParam', GetParamHandler);

  FTestParam := '42';
  FParams.Add('testParam', TJSParam.Create(TestParamGetter, TestParamSetter));
end;

procedure TCefJsExt.Notify(const obj: ICefv8Value;
  const arguments: TCefv8ValueArray; var retval: ICefv8Value;
  var exception: ustring);
var
  s: string;
begin
  if TryGetArgument(arguments, 0, s) then
  begin
    CefSendProcessMessageCurrentContextToBrowser(CefAppMessageTypeVal(VAL_NOTIFY_STR, s))
  end
end;


procedure TCefJsExt.TestParamGetter(const obj: ICefv8Value;
  const arguments: TCefv8ValueArray; var retval: ICefv8Value;
  var exception: ustring);
begin
  retval := TCefv8ValueRef.NewString(FTestParam)
end;

procedure TCefJsExt.TestParamSetter(const obj: ICefv8Value;
  const arguments: TCefv8ValueArray; var retval: ICefv8Value;
  var exception: ustring);
var z: string;
begin
  if TryGetArgument(arguments, 0, z) then
    FTestParam := z
  else
    exception := 'no_string'
end;

procedure TCefJsExt.Click(const obj: ICefv8Value;
  const arguments: TCefv8ValueArray; var retval: ICefv8Value;
  var exception: ustring);
var
  x,y: Integer;
  cb: ICefv8Value;
begin
  if TryGetArgument(arguments, 0, x) then
    if TryGetArgument(arguments, 1, y) then
    begin
      TryGetArgument(arguments, 2, cb);
      CefRenderClickInBrowser(x, y, cb)
    end;
end;

procedure TCefJsExt.FocusClick(const obj: ICefv8Value;
  const arguments: TCefv8ValueArray; var retval: ICefv8Value;
  var exception: ustring);
var
  x,y: Integer;
  cb: ICefv8Value;
begin
  if TryGetArgument(arguments, 0, x) then
    if TryGetArgument(arguments, 1, y) then
    begin
      TryGetArgument(arguments, 2, cb);
      CefRenderFocusClickInBrowser(x, y, cb)
    end;
end;

procedure TCefJsExt.KeyPress(const obj: ICefv8Value;
  const arguments: TCefv8ValueArray; var retval: ICefv8Value;
  var exception: ustring);
var
  key: Integer;
  s: string;
  k, cb: ICefv8Value;
begin
  key := 0;
  k := nil;
  if TryGetArgument(arguments, 0, k) and (k <> nil) then
  begin
    if k.IsInt then
      key := k.GetIntValue
    else
    if k.IsUInt then
      key := k.GetUIntValue
    else
    if k.IsString then
    begin
      s := k.GetStringValue;
      if s <> '' then
        key := Ord(s[1]);
    end;
  end;
  if key <> 0 then
  begin
    TryGetArgument(arguments, 1, cb);
    CefRenderKeyPressInBrowser(key, cb)
  end;
end;

function TCefJsExt.Execute(const name      : ustring;
                              const obj       : ICefv8Value;
                              const arguments : TCefv8ValueArray;
                              var   retval    : ICefv8Value;
                              var   exception : ustring): Boolean;
var func: TJsFunc;
begin
  if FHandlers.TryGetValue(name, func) then
  begin
    func(obj, arguments, retval, exception);
    Exit(True)
  end;
  Exit(False)
end;

function TCefJsExt.GetJsCode: string;
var z,g,s: string;
  p: TPair<string,TJsParam>;
  gf, sf: TJsFunc;
begin
  Result := 'var ' + FName + ';' +
            'if (!' + FName + ')' +
            '  ' + FName + ' = {};' +
            '(function() {';
  for z in FHandlers.Keys do
    Result := Result +
                       '  ' + FName + '.' + z + ' = function(...theArgs) {' +
                       '    native function ' + z + '();' +
                       '    return ' + z + '(...theArgs);' +
                       '  };';

  for p in FParams do
  begin
    z := p.Key;
    gf := p.Value.Key;
    if Assigned(gf) then
    begin
      g := '_get_' + z;
      Result := Result +
                         '  ' + FName + '.__defineGetter__(''' + z + ''', function() {' +
                         '    native function ' + g + '();' +
                         '    return ' + g + '();' +
                         '  });';
      FHandlers.Add(g, gf);
    end;

    sf := p.Value.Value;
    if Assigned(sf) then
    begin
      s := '_set_' + z;
      Result := Result +
                         '  ' + FName + '.__defineSetter__(''' + z + ''', function(b) {' +
                         '    native function ' + s + '();' +
                         '    if(b) ' + s + '(b);' +
                         '  });';
      FHandlers.Add(s, sf);
    end;
  end;

  Result := Result + '})();';
end;


function TCefJsExt.GetParam(const AName: string;
  out AValue: ICefv8Value): Boolean;
begin
  AValue := nil;
  if AName = 'test' then
  begin
    AValue := TCefv8ValueRef.NewString('test');
  end;
  Result := Assigned(AValue)
end;

procedure TCefJsExt.GetParamHandler(const obj: ICefv8Value;
  const arguments: TCefv8ValueArray; var retval: ICefv8Value;
  var exception: ustring);
var
  nam: string;
begin
  retval := nil;
  if TryGetArgument(arguments, 0, nam) then
  begin
    GetParam(nam, retval);
  end
end;

end.
