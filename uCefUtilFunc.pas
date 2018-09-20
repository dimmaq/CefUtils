unit uCefUtilFunc;

interface

uses
  System.SysUtils, System.Classes, System.Types,
  //
  uCEFInterfaces,
  //
  uAppConst;

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
    constructor Create(const ATag, AId, AName, AClass, AAttrName, AAttrValue: string);
    class function CreateId(const AId: string; const ATag: string = ''): TElementParams; static;
    class function CreateTagName(const ATag, AName: string): TElementParams; static;
    class function CreateTagClass(const ATag, AClass: string): TElementParams; static;
    class function CreateTagAttr(const ATag, AAttrName, AAttrValue: string): TElementParams; static;
    class function CreateCefListValue(const A: ICefListValue): TElementParams; static;

    procedure SaveToCefListValue(const A: ICefListValue);
    function IsEmpty: Boolean;
  end;

function ElemFilt(const ATag, AId, AName, AClass, AAttrName, AAttrValue: string): TElementParams;
function ElemById(const AId: string; const ATag: string = ''): TElementParams;
function ElemByAttr(const ATag, AAttrName, AAttrValue: string): TElementParams;
function ElemByCefList(const A: ICefListValue): TElementParams;

function CefAppMessageNew: ICefProcessMessage;
function CefAppMessageArgs(var AArgs: ICefListValue): ICefProcessMessage;
function CefAppMessageType(const AType: Integer; var AArgs: ICefListValue): ICefProcessMessage;
function CefAppMessageTypeVal(const AType: Integer; const AValue: Integer): ICefProcessMessage;
function CefAppMessageTypeElem(const AType: Integer; const AElem: TElementParams;
  var AArgs: ICefListValue): ICefProcessMessage; overload;
function CefAppMessageTypeElem(const AType: Integer;
  const AElem: TElementParams): ICefProcessMessage; overload;
function CefAppMessageTypeElem(const AType: Integer; const AElem: TElementParams;
  const AValue2: string; var AArgs: ICefListValue): ICefProcessMessage; overload;
function CefAppMessageResultNew(const AResult: Boolean): ICefProcessMessage; overload;
function CefAppMessageResultNew(const AResult: ICefListValue): ICefProcessMessage; overload;

function CefStringMapToDictValue(const A: ICefStringMap): ICefDictionaryValue;

function CefListValueToJson(const A: ICefListValue; const APad: string): string;
function CefListValueToJsonStr(const A: ICefListValue): string;

procedure ContextSetPreferenceIfCan(const AContext: ICefRequestContext;
  const AName: string; const AValue: ICefValue); overload;
procedure ContextSetPreferenceIfCan(const AContext: ICefRequestContext;
  const AName, AValue: string); overload;
procedure ContextSetPreferenceIfCan(const AContext: ICefRequestContext;
  const AName: string; const AValue: Boolean); overload;
procedure ContextWebRtcDisable(const AContext: ICefRequestContext);

implementation

uses
  //
  uCEFStringMap, uCEFDictionaryValue, uCEFTypes, uCefTask, uCEFValue,
  //
  uGlobalFunctions,
  //
  uCEFProcessMessage, uCefUtilConst;

function CefAppMessageNew: ICefProcessMessage;
begin
  Result := TCefProcessMessageRef.New(APP_CEF_RENDER_MESSAGE_NAME);
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



{ TElementParams }

constructor TElementParams.Create(const ATag, AId, AName, AClass, AAttrName,
  AAttrValue: string);
begin
  Tag := ATag;
  Id := AId;
  Name := AName;
  Class_ := AClass;
  AttrName := AAttrName;
  AttrValue := AAttrValue
end;

class function TElementParams.CreateCefListValue(
  const A: ICefListValue): TElementParams;
begin
  Result := TElementParams.Create(A.GetString(IDX_TAG), A.GetString(IDX_ID),
    A.GetString(IDX_NAME), A.GetString(IDX_CLASS),
    A.GetString(IDX_ATTR), A.GetString(IDX_VALUE))
end;

class function TElementParams.CreateId(const AId, ATag: string): TElementParams;
begin
  Result := TElementParams.Create(ATag, AId, '', '', '', '')
end;

class function TElementParams.CreateTagAttr(const ATag, AAttrName,
  AAttrValue: string): TElementParams;
begin
  Result := TElementParams.Create(ATag, '', '', '', AAttrName, AAttrValue)
end;

class function TElementParams.CreateTagClass(const ATag, AClass: string): TElementParams;
begin
  Result := TElementParams.Create(ATag, '', '', AClass, '', '')
end;

class function TElementParams.CreateTagName(const ATag, AName: string): TElementParams;
begin
  Result := TElementParams.Create(ATag, '', AName, '', '', '')
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
  A.SetString(IDX_TAG, Tag);
  A.SetString(IDX_ID, Id);
  A.SetString(IDX_NAME, Name);
  A.SetString(IDX_CLASS, Class_);
  A.SetString(IDX_ATTR, AttrName);
  A.SetString(IDX_VALUE, AttrValue);
end;

function ElemById(const AId, ATag: string): TElementParams;
begin
  Result := TElementParams.CreateId(AId, ATag)
end;

function ElemFilt(const ATag, AId, AName, AClass, AAttrName, AAttrValue: string): TElementParams;
begin
  Result := TElementParams.Create(ATag, AId, AName, AClass, AAttrName, AAttrValue)
end;

function ElemByAttr(const ATag, AAttrName, AAttrValue: string): TElementParams;
begin
  Result := TElementParams.Create(ATag, '', '', '', AAttrName, AAttrValue)
end;

function ElemByCefList(const A: ICefListValue): TElementParams;
begin
  Result := TElementParams.CreateCefListValue(A)
end;


procedure ContextSetPreferenceIfCan(const AContext: ICefRequestContext;
  const AName: string; const AValue: ICefValue);
begin
  TCefFastTask.New(TID_UI,
    procedure
    var
      //res: Boolean;
      err: ustring;
    begin
      {res := }AContext.SetPreference(AName, AValue, err);
     // if not res then
      //  gApp.Log.Error('fail context.SetPreference %s "%s"', [AName, err]);
    end);
end;

procedure ContextSetPreferenceIfCan(const AContext: ICefRequestContext;
  const AName, AValue: string);
var cefval: ICefValue;
begin
  cefval := TCefValueRef.New;
  cefval.SetString(AValue);
  ContextSetPreferenceIfCan(AContext, AName, cefval)
end;

procedure ContextSetPreferenceIfCan(const AContext: ICefRequestContext;
  const AName: string; const AValue: Boolean);
var cefval: ICefValue;
begin
  cefval := TCefValueRef.New;
  cefval.SetBool(Ord(AValue));
  ContextSetPreferenceIfCan(AContext, AName, cefval)
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

end.
