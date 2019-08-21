unit uCefScriptNav;

interface

uses
  System.SysUtils,
  //
  //
  uCefScriptBase, uCefScriptNavBase, uCefWebAction;

type
  TCefScriptNavFunc = TFunc<Boolean>;
  TCefScriptNavProc0 = TProc;

  TCefScriptNav = class(TCefScriptNavBase)
  private
  protected
    FUrl: string;
    FNavFunc: TCefScriptNavFunc;
    FNavProc0: TCefScriptNavProc0;
    function DoNavEvent(const AWebAction: TCefWebAction): Boolean; override;
  public
    constructor Create(const AActionName, AUrl: string; const ANavFunc: TCefScriptNavFunc;
      const ANavProc0: TCefScriptNavProc0;
      const ASetIsNav: Boolean; const AParent: TCefScriptBase); overload;
    constructor Create(const AActionName, AUrl: string; const ASetIsNav: Boolean;
      const AParent: TCefScriptBase); overload;
    class function GetScriptName: string; override;
  end;


implementation

{ TCefScriptNav }

constructor TCefScriptNav.Create(const AActionName, AUrl: string; const ANavFunc: TCefScriptNavFunc;
  const ANavProc0: TCefScriptNavProc0;
  const ASetIsNav: Boolean; const AParent: TCefScriptBase);
begin
  inherited Create(AActionName, ASetIsNav, AParent);
  FNavProc0 := ANavProc0;
  FNavFunc := ANavFunc;
  FUrl := AUrl;
end;

constructor TCefScriptNav.Create(const AActionName, AUrl: string; const ASetIsNav: Boolean;
  const AParent: TCefScriptBase);
begin
  Create(AActionName, AUrl, nil, nil, ASetIsNav, AParent);
end;

function TCefScriptNav.DoNavEvent(const AWebAction: TCefWebAction): Boolean;
begin
  if Assigned(FNavProc0) then
  begin
    FNavProc0();
    Result := True
  end
  else
  if Assigned(FNavFunc) then
  begin
    Result := FNavFunc()
  end
  else
  begin
    Nav(FUrl);
    Result := True
  end;
end;

class function TCefScriptNav.GetScriptName: string;
begin
  Result := 'nav'
end;

end.

