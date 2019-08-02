unit uCefUtilFunc;

interface

uses
  System.SysUtils, System.Classes, System.Types,
  //
  uCEFInterfaces, uCEFTypes;

type
  ECefError = class(Exception);
  ECefRenderError = class(ECefError);

  TElementParams = record
    Tag: string;
    Id: string;
    Name: string;
    Class_: string;
    AttrName: string;
    AttrValue: string;
    Text: string;
    constructor Create(const ATag, AId, AName, AClass, AAttrName, AAttrValue, AText: string);
    class function CreateId(const AId: string; const ATag: string = ''): TElementParams; static;
    class function CreateTagText(const ATag, ATextRegExp: string): TElementParams; static;
    class function CreateTagName(const ATag, AName: string): TElementParams; static;
    class function CreateTagClass(const ATag, AClass: string): TElementParams; static;
    class function CreateTagAttr(const ATag, AAttrName, AAttrValue: string): TElementParams; static;
    class function CreateCefListValue(const A: ICefListValue): TElementParams; static;

    procedure SaveToCefListValue(const A: ICefListValue);
    function IsEmpty: Boolean;
  end;

function CefSendProcessMessageCurrentContextToBrowser(const AMsg: ICefProcessMessage): Boolean;

function ElemFilt(const ATag, AId, AName, AClass, AAttrName, AAttrValue, AText: string): TElementParams;
function ElemById(const AId: string; const ATag: string = ''): TElementParams;
function ElemByAttr(const ATag, AAttrName, AAttrValue: string): TElementParams;
function ElemByCefList(const A: ICefListValue): TElementParams;

function CefAppMessageNew: ICefProcessMessage;
function CefAppMessageArgs(var AArgs: ICefListValue): ICefProcessMessage;
function CefAppMessageType(const AType: Integer; var AArgs: ICefListValue): ICefProcessMessage;
function CefAppMessageTypeVal(const AType: Integer; const AValue: Integer): ICefProcessMessage;  overload;
function CefAppMessageTypeVal(const AType: Integer; const AValue: string): ICefProcessMessage;   overload;
function CefAppMessageTypeElem(const AType: Integer; const AElem: TElementParams;
  var AArgs: ICefListValue): ICefProcessMessage; overload;
function CefAppMessageTypeElem(const AType: Integer;
  const AElem: TElementParams): ICefProcessMessage; overload;
function CefAppMessageTypeElem(const AType: Integer; const AElem: TElementParams;
  const AValue2: string; var AArgs: ICefListValue): ICefProcessMessage; overload;
function CefAppMessageResultNew(const AResult: string): ICefProcessMessage; overload;
function CefAppMessageResultNew(const AResult: Boolean): ICefProcessMessage; overload;
function CefAppMessageResultNew(const AResult: ICefListValue): ICefProcessMessage; overload;
function CefAppMessageTypeExecCallback(const ACallbackId: Integer; var AArgs: ICefListValue): ICefProcessMessage; overload;
function CefAppMessageTypeExecCallback(const ACallbackId: Integer): ICefProcessMessage;  overload;

procedure CefExecJsCallback(const ABrowser: ICefBrowser; const AId: Integer);

function CefStringMapToDictValue(const A: ICefStringMap): ICefDictionaryValue;

//function CefListValueToJson(const A: ICefListValue; const APad: string): string;
function CefListValueToJsonStr(const A: ICefListValue): string;

procedure ContextSetPreferenceIfCan(const AContext: ICefRequestContext; const AName: string; const AValue: ICefValue); overload;
procedure ContextSetPreferenceIfCan(const AContext: ICefRequestContext; const AName, AValue: string); overload;
procedure ContextSetPreferenceIfCan(const AContext: ICefRequestContext; const AName: string; const AValue: Boolean); overload;
procedure ContextWebRtcDisable(const AContext: ICefRequestContext);

implementation

uses
  //
  uCEFStringMap, uCEFDictionaryValue, uCefTask, uCEFValue, uCefv8Context,
  uCEFMiscFunctions, uCEFConstants,
  //
  uGlobalFunctions,
  //
  uCEFProcessMessage, uCefUtilConst;


function CefAppMessageNew: ICefProcessMessage;
begin
  Result := TCefProcessMessageRef.New(MYAPP_CEF_MESSAGE_NAME);
end;

function CefAppMessageArgs(var AArgs: ICefListValue): ICefProcessMessage;
begin
  Result := CefAppMessageNew();
  AArgs := Result.ArgumentList;
end;

function CefAppMessageType(const AType: Integer; var AArgs: ICefListValue): ICefProcessMessage;
begin
  Result := CefAppMessageArgs(AArgs);
  AArgs.SetInt(IDX_TYPE, AType);
end;

function CefAppMessageTypeVal(const AType: Integer; const AValue: Integer): ICefProcessMessage;
var args: ICefListValue;
begin
  Result := CefAppMessageType(AType, args);
  args.SetInt(IDX_VALUE, AValue);
end;

function CefAppMessageTypeVal(const AType: Integer; const AValue: string): ICefProcessMessage;
var args: ICefListValue;
begin
  Result := CefAppMessageType(AType, args);
  args.SetString(IDX_VALUE, AValue);
end;

function CefAppMessageTypeElem(const AType: Integer; const AElem: TElementParams;
  var AArgs: ICefListValue): ICefProcessMessage;
begin
  Result := CefAppMessageType(AType, AArgs);
  AElem.SaveToCefListValue(AArgs);
end;

function CefAppMessageTypeElem(const AType: Integer;
  const AElem: TElementParams): ICefProcessMessage;
var tmp: ICefListValue;
begin
  Result := CefAppMessageType(AType, tmp);
  AElem.SaveToCefListValue(tmp);
end;

function CefAppMessageTypeElem(const AType: Integer; const AElem: TElementParams;
  const AValue2: string; var AArgs: ICefListValue): ICefProcessMessage;
begin
  Result := CefAppMessageTypeElem(AType, AElem, AArgs);
  AArgs.SetString(IDX_VALUE2, AValue2);
end;

function CefAppMessageResultNew(const AResult: string): ICefProcessMessage;
var arg: ICefListValue;
begin
  Result := CefAppMessageArgs(arg);
  arg.SetString(IDX_RESULT, AResult)
end;

function CefAppMessageResultNew(const AResult: Boolean): ICefProcessMessage;
var arg: ICefListValue;
begin
  Result := CefAppMessageArgs(arg);
  arg.SetBool(IDX_RESULT, AResult)
end;

function CefAppMessageResultNew(const AResult: ICefListValue): ICefProcessMessage;
var arg: ICefListValue;
begin
  Result := CefAppMessageArgs(arg);
  arg.SetList(IDX_RESULT, AResult)
end;

function CefAppMessageTypeExecCallback(const ACallbackId: Integer; var AArgs: ICefListValue): ICefProcessMessage;
begin
  Result := CefAppMessageType(VAL_EXEC_CALLBACK, AArgs);
  AArgs.SetInt(IDX_CALLBACK_ID, ACallbackId)
end;

function CefAppMessageTypeExecCallback(const ACallbackId: Integer): ICefProcessMessage;
var tmp: ICefListValue;
begin
  Result := CefAppMessageTypeExecCallback(ACallbackId, tmp);
end;

function CefStringMapToDictValue(const A: ICefStringMap): ICefDictionaryValue;
var
  j: Integer;
  s: string;
begin
  Result := TCefDictionaryValueRef.New;
  for j := 0 to A.Size - 1 do
  begin
    s := A.Key[j];
    Result.SetString(s, A.Value[j]);
  end;
end;

function CefBinaryToStr(const A: ICefBinaryValue): string;
var buf, text: TBytes;
begin
  SetLength(buf, A.GetSize);
  A.GetData(@buf[0], Length(buf), 0);
  SetLength(text, Length(buf) * 2);
  BinToHex(buf, 0, text, 0, Length(buf));
  Result := TEncoding.ANSI.GetString(text);
end;

(*
function CefDictValueToJson(const A: ICefDictionaryValue; const APad: string): string;
var
  j, l: Integer;
  keys: TStringList;
  z: string;
  v: ICefValue;

  procedure put(const s: string);
  begin
    Result := Result + APad + '"' + z + '": ' + s + IfElse(j=l,'', ',') + #13#10
  end;

begin
  Result := '';
  keys := TStringList.Create;
  l := A.GetSize - 1;
  j := 0;
  try
    A.GetKeys(keys);
    for z in keys do
    begin
      v := A.GetValue(z);
      case v.GetType of
        VTYPE_INVALID: put('"!!!INVALID"');
        VTYPE_NULL: put('null');
        VTYPE_BOOL: put(IfElse(v.GetBool, 'true', 'false'));
        VTYPE_INT: put(IntToStr(v.GetInt));
        VTYPE_DOUBLE: put(v.GetDouble.ToString);
        VTYPE_STRING: put('"' + v.GetString + '"');
        VTYPE_BINARY: put('"' + CefBinaryToStr(v.GetBinary) + '"');
        VTYPE_DICTIONARY: put('{'#13#10 + CefDictValueToJson(v.GetDictionary, APad + #9) + APad + '}');
        VTYPE_LIST: put('['#13#10 + CefListValueToJson(v.GetList, APad + #9) + APad + ']');
      end;
      Inc(j);
    end;
  finally
    keys.Free
  end;
end;

function CefListValueToJson(const A: ICefListValue; const APad: string): string;
var
  j, l: Integer;
  v: ICefValue;

  procedure put(const s: string);
  begin
    Result := Result + APad + s + IfElse(j=l,'', ',') + #13#10
  end;

begin
  Result := '';
  l := A.GetSize;
  if l = 0 then
    Exit;
  Dec(l);

  for j := 0 to l do
  begin
    v := A.GetValue(j);
    case v.GetType of
      VTYPE_INVALID: put('"!!!INVALID"');
      VTYPE_NULL: put('null');
      VTYPE_BOOL: put(IfElse(v.GetBool, 'true', 'false'));
      VTYPE_INT: put(IntToStr(v.GetInt));
      VTYPE_DOUBLE: put(v.GetDouble.ToString);
      VTYPE_STRING: put('"' + v.GetString + '"');
      VTYPE_BINARY: put('"' + CefBinaryToStr(v.GetBinary) + '"');
      VTYPE_DICTIONARY: put('{'#13#10 + CefDictValueToJson(v.GetDictionary, APad + #9) + APad + '}');
      VTYPE_LIST: put('['#13#10 + CefListValueToJson(v.GetList, APad + #9) + APad + ']');
    end;
  end;
end;

function CefListValueToJsonStr(const A: ICefListValue): string;
begin
  if A = nil then
    Exit('nil');

  Result := '['#13#10 + CefListValueToJson(A, '') + ']'#13#10
end;
*)


function CefListValueToJsonStr(const A: ICefListValue): string;
var val: ICefValue;
begin
  val := TCefValueRef.New;
  val.SetList(A);
  Result := CefWriteJson(val, JSON_WRITER_PRETTY_PRINT) // JSON_WRITER_PRETTY_PRINT
end;
{ TElementParams }

constructor TElementParams.Create(const ATag, AId, AName, AClass, AAttrName,
  AAttrValue, AText: string);
begin
  Tag := ATag;
  Id := AId;
  Name := AName;
  Class_ := AClass;
  AttrName := AAttrName;
  AttrValue := AAttrValue;
  Text := AText
end;

class function TElementParams.CreateCefListValue(
  const A: ICefListValue): TElementParams;
begin
  Result := TElementParams.Create(A.GetString(IDX_TAG), A.GetString(IDX_ID),
    A.GetString(IDX_NAME), A.GetString(IDX_CLASS),
    A.GetString(IDX_ATTR), A.GetString(IDX_VALUE), A.GetString(IDX_TEXT))
end;

class function TElementParams.CreateId(const AId, ATag: string): TElementParams;
begin
  Result := TElementParams.Create(ATag, AId, '', '', '', '', '')
end;

class function TElementParams.CreateTagAttr(const ATag, AAttrName,
  AAttrValue: string): TElementParams;
begin
  Result := TElementParams.Create(ATag, '', '', '', AAttrName, AAttrValue, '')
end;

class function TElementParams.CreateTagClass(const ATag, AClass: string): TElementParams;
begin
  Result := TElementParams.Create(ATag, '', '', AClass, '', '', '')
end;

class function TElementParams.CreateTagName(const ATag, AName: string): TElementParams;
begin
  Result := TElementParams.Create(ATag, '', AName, '', '', '', '')
end;

class function TElementParams.CreateTagText(const ATag,
  ATextRegExp: string): TElementParams;
begin
  Result := TElementParams.Create(ATag, '', '', '', '', '', ATextRegExp)
end;

function TElementParams.IsEmpty: Boolean;
begin
  Result :=
    Tag.IsEmpty and
    Id.IsEmpty and
    Name.IsEmpty and
    Class_.IsEmpty and
    AttrName.IsEmpty and
    AttrValue.IsEmpty
end;

procedure TElementParams.SaveToCefListValue(const A: ICefListValue);
begin
  if Tag <> '' then
    A.SetString(IDX_TAG, Tag);
  if Id <> '' then
    A.SetString(IDX_ID, Id);
  if Name <> '' then
    A.SetString(IDX_NAME, Name);
  if Class_ <> '' then
    A.SetString(IDX_CLASS, Class_);
  if AttrName <> '' then
    A.SetString(IDX_ATTR, AttrName);
  if AttrValue <> '' then
    A.SetString(IDX_VALUE, AttrValue);
  if Text <> '' then
    A.SetString(IDX_TEXT, Text);
end;

function ElemById(const AId, ATag: string): TElementParams;
begin
  Result := TElementParams.CreateId(AId, ATag)
end;

function ElemFilt(const ATag, AId, AName, AClass, AAttrName, AAttrValue, AText: string): TElementParams;
begin
  Result := TElementParams.Create(ATag, AId, AName, AClass, AAttrName, AAttrValue, AText)
end;

function ElemByAttr(const ATag, AAttrName, AAttrValue: string): TElementParams;
begin
  Result := TElementParams.Create(ATag, '', '', '', AAttrName, AAttrValue, '')
end;

function ElemByCefList(const A: ICefListValue): TElementParams;
begin
  Result := TElementParams.CreateCefListValue(A)
end;

procedure ContextWebRtcDisable(const AContext: ICefRequestContext);
begin
  //ContextSetPreferenceIfCan(AContext, 'disable-webrtc', True);
  //ContextSetPreferenceIfCan(AContext, 'enable-webrtc', False);

  // Disables leaking of IPs via WebRTC on standard CEF builds.
  // This options obsoleted from Chromium M50, but still exists in source. (Actually they are no more exist on fresh builds (55+?.)
  ContextSetPreferenceIfCan(AContext, 'webrtc.multiple_routes_enabled', false);
  ContextSetPreferenceIfCan(AContext, 'webrtc.nonproxied_udp_enabled', false);
  // Values:
  // See webrtc_ip_handling_policy.h for description.
  // default
  // default_public_and_private_interfaces
  // default_public_interface_only
  // disable_non_proxied_udp
  ContextSetPreferenceIfCan(AContext, 'webrtc.ip_handling_policy', 'disable_non_proxied_udp');
  // media.device_id_salt is chrome-only preference, so there is no way to randomize device ids.
end;

function CefSendProcessMessageBrowser(const ABrowser: ICefBrowser;
  const ATarget: TCefProcessId; const AMsg: ICefProcessMessage): Boolean;
begin
  ABrowser.MainFrame.SendProcessMessage(ATarget, AMsg);
  Result := True;
end;

function CefSendProcessMessageBrowserToRender(const ABrowser: ICefBrowser;
  const AMsg: ICefProcessMessage): Boolean;
begin
  Result := CefSendProcessMessageBrowser(ABrowser, PID_RENDERER, AMsg);
end;

function CefSendProcessMessageCurrentContext(const ATarget: TCefProcessId; const AMsg: ICefProcessMessage): Boolean;
begin
  Result := CefSendProcessMessageBrowser(TCefv8ContextRef.Current.Browser, ATarget, AMsg);
end;

function CefSendProcessMessageCurrentContextToRender(const AMsg: ICefProcessMessage): Boolean;
begin
  Result := CefSendProcessMessageCurrentContext(PID_RENDERER, AMsg);
end;

function CefSendProcessMessageCurrentContextToBrowser(const AMsg: ICefProcessMessage): Boolean;
begin
  Result := CefSendProcessMessageCurrentContext(PID_BROWSER, AMsg);
end;

procedure CefExecJsCallback(const ABrowser: ICefBrowser; const AId: Integer);
var
  msg: ICefProcessMessage;
begin
  if aid < 1 then
    Exit;
  msg := CefAppMessageTypeExecCallback(AId);
  CefSendProcessMessageBrowserToRender(ABrowser, msg)
end;

procedure ContextSetPreferenceIfCan(const AContext: ICefRequestContext; const AName, AValue: string);
var cefval: ICefValue;
begin
  cefval := TCefValueRef.New;
  cefval.SetString(AValue);
  ContextSetPreferenceIfCan(AContext, AName, cefval)
end;

procedure ContextSetPreferenceIfCan(const AContext: ICefRequestContext; const AName: string; const AValue: ICefValue);
begin
  TCefFastTask.New(TID_UI, procedure
    var
      //res: Boolean;
      err: ustring;
    begin
      {res := }AContext.SetPreference(AName, AValue, err);
     // if not res then
      //  gApp.Log.Error('fail context.SetPreference %s "%s"', [AName, err]);
    end
  );
end;

procedure ContextSetPreferenceIfCan(const AContext: ICefRequestContext; const AName: string; const AValue: Boolean);
var cefval: ICefValue;
begin
  cefval := TCefValueRef.New;
  cefval.SetBool(Ord(AValue));
  ContextSetPreferenceIfCan(AContext, AName, cefval)
end;

end.
