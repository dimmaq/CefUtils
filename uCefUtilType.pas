unit uCefUtilType;

interface

uses
  System.SysUtils, System.Types;

type
  TCefControllerBase = class
  public
    Cursor: TPoint;
    Speed: Integer;
    constructor Create;
  end;

implementation

uses
  uCefUtilConst;

{ TCefControllerBase }

constructor TCefControllerBase.Create;
begin
  Cursor := TPoint.Create(0, 0);
  Speed := SPEED_DEF;
end;

end.
