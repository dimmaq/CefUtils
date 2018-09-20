unit uCefScriptEmpty;

interface

uses
  uLoggerInterface,
  //
  uCefScriptBase;

type
  TCefScriptEmpty  = class(TCefScriptBase)
  private
  protected
    function DoStartEvent: Boolean; override;
  public
    procedure AppLog(const ALevel: TLogLevel; const A: string); override;
    class function GetName: string; override;
  end;

implementation


{ TCefScriptEmpty }

procedure TCefScriptEmpty.AppLog(const ALevel: TLogLevel; const A: string);
begin

end;

function TCefScriptEmpty.DoStartEvent: Boolean;
begin
  Result := False
end;

class function TCefScriptEmpty.GetName: string;
begin
  Result := 'empty'
end;

end.
