unit uCefUtilType;

interface

uses
  System.SysUtils, System.Types, System.Math,
  //
  uCefUtilConst;

type
  TCefUISpeed = Byte;

  TCefControllerBase = class
  public
    Cursor: TPoint;
    Speed: TCefUISpeed;
    constructor Create;
    function Pause: Integer;
  end;

function SpeedToPause(A: TCefUISpeed): Integer;

const
  SPEED_DEF: TCefUISpeed = High(TCefUISpeed) div 2;

implementation

function SpeedToPause(A: TCefUISpeed): Integer;
begin
  Result := Round(Power(A / (High(TCefUISpeed) * 100), -1));
end;


{ TCefControllerBase }

constructor TCefControllerBase.Create;
begin
  Cursor := TPoint.Create(0, 0);
  Speed := SPEED_DEF;
end;

function TCefControllerBase.Pause: Integer;
begin
  Result := SpeedToPause(Speed)
end;

end.
