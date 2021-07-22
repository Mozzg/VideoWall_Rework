unit uFieldBase;

interface

uses SFMLGraphics;

type
  TFieldBase = class(TObject)
  private
    FBoundRect: TSfmlFloatRect;
    FBGColor: TSfmlColor;
    FElapsedMicroseconds: UInt64;
    FDebugMode: boolean;
  protected
    FNeedsRecalculate: boolean;
    FRenderSprite: TSfmlSprite;
    FRenderTexture: TSfmlRenderTexture;
    FDebugRect: TSfmlRectangleShape;

    procedure Recalculate; virtual; abstract;
    procedure EnsureRecalculate; virtual; abstract;

    procedure SetBGColor(const AColor: TSfmlColor); virtual;
    procedure SetElapsed(const AElapsed: Uint64); virtual;
    procedure SetBounds(const ABounds: TSfmlFloatRect); virtual;
    procedure SetDebugMode(const AMode: boolean); virtual;
    function GetNeedsRecalculate: boolean; virtual;
  public
    constructor Create; overload; virtual;
    constructor Create(const ABounds: TSfmlFloatRect); overload; virtual;
    destructor Destroy; override;

    function Update(const AElapsedMicrosec: Uint64): boolean; virtual; abstract;
    function UpdateTick(const AElapsedMicrosec: Uint64): boolean; virtual; abstract;
    procedure Draw(AWindow: TSfmlRenderWindow); virtual; abstract;

    property BGColor: TSfmlColor read FBGColor write SetBGColor;
    property InternalMicro: Uint64 read FElapsedMicroseconds write SetElapsed;
    property FieldBounds: TSfmlFloatRect read FBoundRect write SetBounds;
    property DebugMode: boolean read FDebugMode write SetDebugMode;
    property NeedsRecalculate: boolean read GetNeedsRecalculate;
  end;

implementation

uses
  Math,
  SysUtils,
  SfmlSystem
  ;

{ TFieldBase }

constructor TFieldBase.Create;
begin
  Create(TSfmlFloatRect.Create(0, 0, 100, 100));
end;

constructor TFieldBase.Create(const ABounds: TSfmlFloatRect);
var OutlineCol: TSfmlColor;
begin
  inherited Create;

  FBoundRect := ABounds;
  FRenderTexture := TSfmlRenderTexture.Create(floor(FBoundRect.Width), floor(FBoundRect.Height), false);
  FRenderTexture.Smooth := true;
  FRenderSprite := TSfmlSprite.Create(FRenderTexture.RawTexture);
  FRenderSprite.Position := TSfmlVector2f.Create(FBoundRect.Left, FBoundRect.Top);
  FDebugMode := false;
  FDebugRect := TSfmlRectangleShape.Create;
  FDebugRect.Position := TSfmlVector2f.Create(FBoundRect.Left + 1, FBoundRect.Top + 1);
  FDebugRect.Size := TSfmlVector2f.Create(FBoundRect.Width - 2, FBoundRect.Height - 2);
  FDebugRect.FillColor := SfmlTransparent;
  OutlineCol.R := 0;
  OutlineCol.G := 255;
  OutlineCol.B := 0;
  OutlineCol.A := 100;
  FDebugRect.OutlineColor := OutlineCol;
  FDebugRect.OutlineThickness := 1;
  FBGColor := SfmlTransparent;
  FElapsedMicroseconds := 0;
  FNeedsRecalculate := true;
end;

destructor TFieldBase.Destroy;
begin
  if Assigned(FRenderSprite) then FreeAndNil(FRenderSprite);
  if Assigned(FRenderTexture) then FreeAndNil(FRenderTexture);
  if Assigned(FDebugRect) then FreeAndNil(FDebugRect);

  inherited Destroy;
end;

procedure TFieldBase.SetBGColor(const AColor: TSfmlColor);
begin
  FBGColor := AColor;
end;

procedure TFieldBase.SetElapsed(const AElapsed: Uint64);
begin
  FElapsedMicroseconds := AElapsed;
end;

procedure TFieldBase.SetBounds(const ABounds: TSfmlFloatRect);
begin
  FBoundRect := ABounds;
end;

procedure TFieldBase.SetDebugMode(const AMode: boolean);
begin
  FDebugMode := AMode;
end;

function TFieldBase.GetNeedsRecalculate: boolean;
begin
  Result := FNeedsRecalculate;
end;


end.
