unit uTextField;

interface

uses
  SysUtils,
  uFieldBase,
  SFMLGraphics
  ;

type
  //types of text field
  TTextFieldType = (tfStatic, tfOptionalRunning, tfAlwaysRunning, tfScrollUp,
  tfScrollDown, tfScrollUpReplace, tfScrollDownReplace, tfDateTime);
  //horizontal alligment
  TTextAlignHorizontal = (tahLeft, tahCenter, tahRight);
  //vertical aligment
  TTextAlignVertical = (tavTop, tavCenter, tavBottom);
  //running text spacing
  TTextRunningSpacing = (trsNone, trsSpace, trs3Space, trsRemaining, trs0_5, trs1_0, trs1_5, trs2_0);

  ITextWorker = Interface(IInterface)
    ['{24A2C542-9269-4683-98AD-5734B2C0D78D}']
    procedure SetUpdateTickCount(const ACount: cardinal; const MicrosecPerTick: Uint64);
    function Update(const AElapsed: Uint64): boolean;
    function UpdateTick(const AElapsed: Uint64): boolean;
    procedure Draw(AWindow: TSfmlRenderWindow);
    procedure Recalculate;
  End;

  TTextField = class(TFieldBase)
  private
    FTextObject: TSfmlText;
    FFontObject: TSfmlFont;

    FFontPath: string;
    FFieldUpdateTickCount: cardinal;
    FTextString: String;
    FTextSize: Cardinal;
    FTextColor: TSfmlColor;
    FTextStyle: Cardinal;
    FTextSpeed: Cardinal;
    FTextFieldType: TTextFieldType;
    FTextHorizontalAlign: TTextAlignHorizontal;
    FTextVerticalAlign: TTextAlignVertical;
    FTextRunningSpace: TTextRunningSpacing;

    //FNeedsRecalculate: boolean;
    FUsingGoodFont: boolean;

    FBehaviorWorker: ITextWorker;

    procedure Recalculate; override;
    procedure CheckUsingGoodFont;
    procedure CreateBehavior;

    procedure SetFontPath(APath: string);
    procedure SetTextString(AString: String);
    procedure SetTextSize(ASize: cardinal);
    procedure SetTextColor(AColor: TSfmlColor);
    procedure SetTextStyle(AStyle: Cardinal);
    procedure SetTextSpeed(ASpeed: Cardinal);
    procedure SetTextFieldType(ATextFieldType: TTextFieldType);
    procedure SetTextHorizontalAlign(AAlign: TTextAlignHorizontal);
    procedure SetTextVerticalAlign(AAlign: TTextAlignVertical);
    procedure SetTextRunningSpace(ASpace: TTextRunningSpacing);
  protected
    procedure EnsureRecalculate; override;

    procedure SetBounds(const ABounds: TSfmlFloatRect);
  public
    constructor Create; overload; override;
    constructor Create(const ABounds: TSfmlFloatRect); overload; override;
    constructor Create(const ABounds: TSfmlFloatRect; AFontPath: string; const AFontSize: Cardinal); overload; virtual;
    destructor Destroy; override;

    function Update(const AElapsedMicrosec: Uint64): boolean; override;
    function UpdateTick(const AElapsedMicrosec: Uint64): boolean; override;
    procedure Draw(AWindow: TSfmlRenderWindow); override;

    procedure SetFieldUpdateTickCount(ACount: cardinal; AMicrosecPerTick: Uint64);

    //inherited from TFieldBase
    //property BGColor: TSfmlColor read FBGColor write SetBGColor;
    //property InternalMicro: Uint64 read FElapsedMicroseconds write SetElapsed;
    //property FieldBounds: TSfmlFloatRect read FBoundRect write SetBounds;
    //property NeedsRecalculate: boolean read FNeedsRecalculate;
    property FontPath: string read FFontPath write SetFontPath;
    property FieldUpdateTickCount: cardinal read FFieldUpdateTickCount;
    property TextString: String read FTextString write SetTextString;
    property TextSize: cardinal read FTextSize write SetTextSize;
    property TextColor: TSfmlColor read FTextColor write SetTextColor;
    property TextStyle: Cardinal read FTextStyle write SetTextStyle;
    property TextSpeed: Cardinal read FTextSpeed write SetTextSpeed;
    property TextFieldType: TTextFieldType read FTextFieldType write SetTextFieldType;
    property TextHorizontalAlign: TTextAlignHorizontal read FTextHorizontalAlign write SetTextHorizontalAlign;
    property TextVerticalAlign: TTextAlignVertical read FTextVerticalAlign write SetTextVerticalAlign;
    property TextRunningSpace: TTextRunningSpacing read FTextRunningSpace write SetTextRunningSpace;
  end;

  TTextWorkerStatic = class(TInterfacedObject, ITextWorker)
  private
    FParent: TTextField;
    //ITextWorker
    procedure SetUpdateTickCount(const ACount: cardinal; const MicrosecPerTick: Uint64);
    function Update(const AElapsed: Uint64): boolean;
    function UpdateTick(const AElapsed: Uint64): boolean;
    procedure Draw(AWindow: TSfmlRenderWindow);
    procedure Recalculate;
  public
    constructor Create(AParentObj: TTextField);
  end;

  TTextWorkerAlwaysRunning = class(TInterfacedObject, ITextWorker)
  private
    FParent: TTextField;
    FTextRunningRealPos: double;
    FTextRunningClipRect: TSfmlIntRect;
    FPixelsPerMicrosecond: double;
    FTextRunningThreshold: double;
    FUpdateTickCount: cardinal;
    FUpdateTickCurrent: cardinal;
    procedure CalculateAndDrawRunning(ABounds: TSfmlFloatRect);
    //ITextWorker
    procedure SetUpdateTickCount(const ACount: cardinal; const MicrosecPerTick: Uint64);
    function Update(const AElapsed: Uint64): boolean;
    function UpdateTick(const AElapsed: Uint64): boolean;
    procedure Draw(AWindow: TSfmlRenderWindow);
    procedure Recalculate;
  public
    constructor Create(AParentObj: TTextField);
  end;

  TTextWorkerOptionalRunning = class(TInterfacedObject, ITextWorker)
  private
    FParent: TTextField;
    FTextIsRunning: boolean;
    FTextRunningRealPos: double;
    FTextRunningClipRect: TSfmlIntRect;
    FPixelsPerMicrosecond: double;
    FTextRunningThreshold: double;
    FUpdateTickCount: cardinal;
    FUpdateTickCurrent: cardinal;
    procedure CalculateAndDrawRunning(ABounds: TSfmlFloatRect);
    procedure CalculateAndDrawStatic(ABounds: TSfmlFloatRect);
    //ITextWorker
    procedure SetUpdateTickCount(const ACount: cardinal; const MicrosecPerTick: Uint64);
    function Update(const AElapsed: Uint64): boolean;
    function UpdateTick(const AElapsed: Uint64): boolean;
    procedure Draw(AWindow: TSfmlRenderWindow);
    procedure Recalculate;
  public
    constructor Create(AParentObj: TTextField);
  end;

  TTextWorkerDateTime = class(TInterfacedObject, ITextWorker)
  private const FPhaseCount = 8;
  private const FPhaseMicrosec = 250000; //250ms
  private
    FParent: TTextField;
    FCurrentMicrosecGlobal: Uint64;
    FCurrentMicrosecLocal: Uint64;
    FUpdateThresholdMicro: Uint64;
    FCurrentTimePhase: cardinal;
    FPhaseStrings: array [0..FPhaseCount-1] of string;
    FCurrentTextString: string;
    FFormatSettings: TFormatSettings;
    procedure CalculateFormat;
    //ITextWorker
    procedure SetUpdateTickCount(const ACount: cardinal; const MicrosecPerTick: Uint64);
    function Update(const AElapsed: Uint64): boolean;
    function UpdateTick(const AElapsed: Uint64): boolean;
    procedure Draw(AWindow: TSfmlRenderWindow);
    procedure Recalculate;
  public
    constructor Create(AParentObj: TTextField);
  end;

implementation

uses
  Math,
  DateUtils,
  StrUtils,
  SfmlSystem
  ;

////////////////////////////////////////////////////////////////////////////////
{ TTextField }
////////////////////////////////////////////////////////////////////////////////

constructor TTextField.Create;
begin
  Create(TSfmlFloatRect.Create(0, 0, 100, 100));
end;

constructor TTextField.Create(const ABounds: TSfmlFloatRect);
begin
  Create(ABounds, '', 12);
end;

constructor TTextField.Create(const ABounds: TSfmlFloatRect; AFontPath: string; const AFontSize: Cardinal);
var tempVector: TSfmlVector2f;
begin
  inherited Create(ABounds);

  FFontPath := AFontPath;
  FFieldUpdateTickCount := 1;
  FTextString := '';
  FTextSize := AFontSize;
  FTextColor := SfmlWhite;
  FUsingGoodFont := false;
  FTextStyle := sfTextRegular;
  FTextSpeed := 60;
  FTextFieldType := tfStatic;
  FTextHorizontalAlign := tahLeft;
  FTextVerticalAlign := tavTop;
  FTextRunningSpace := trs3Space;

  FFontObject := TSfmlFont.Create(AFontPath);
  FTextObject := TSfmlText.Create;
  tempVector := TSfmlVector2f.Create(0, 0);
  FTextObject.Position := tempVector;
  FTextObject.Origin := tempVector;

  CheckUsingGoodFont;
  CreateBehavior;
end;

destructor TTextField.Destroy;
begin
  if Assigned(FTextObject) then FreeAndNil(FTextObject);
  if Assigned(FFontObject) then FreeAndNil(FFontObject);
  FBehaviorWorker := nil;

  inherited Destroy;
end;

function TTextField.Update(const AElapsedMicrosec: Uint64): boolean;
begin
  InternalMicro := InternalMicro + AElapsedMicrosec;

  if Assigned(FBehaviorWorker) then Result := FBehaviorWorker.Update(AElapsedMicrosec)
  else Result := false;
end;

function TTextField.UpdateTick(const AElapsedMicrosec: Uint64): boolean;
begin
  InternalMicro := InternalMicro + AElapsedMicrosec;

  if Assigned(FBehaviorWorker) then Result := FBehaviorWorker.UpdateTick(AElapsedMicrosec)
  else Result := false;
end;

procedure TTextField.Draw(AWindow: TSfmlRenderWindow);
begin
  if Assigned(FBehaviorWorker) then FBehaviorWorker.Draw(AWindow);
  if DebugMode = true then AWindow.Draw(FDebugRect);
end;

procedure TTextField.EnsureRecalculate;
begin
  if NeedsRecalculate then Recalculate;
end;

procedure TTextField.CheckUsingGoodFont;
begin
  if Assigned(FFontObject.Handle) = false then FUsingGoodFont := false
  else
  begin
    FUsingGoodFont := true;
    FTextObject.Font := FFontObject.Handle;
  end;
end;

procedure TTextField.CreateBehavior;
begin
  FBehaviorWorker := nil;

  case FTextFieldType of
    tfOptionalRunning: FBehaviorWorker := TTextWorkerOptionalRunning.Create(Self);
    tfAlwaysRunning: FBehaviorWorker := TTextWorkerAlwaysRunning.Create(Self);
    tfScrollUp:;
    tfScrollDown:;
    tfScrollUpReplace:;
    tfScrollDownReplace:;
    tfDateTime: FBehaviorWorker := TTextWorkerDateTime.Create(Self);
    else  //static or new
      FBehaviorWorker := TTextWorkerStatic.Create(Self);
  end;
end;

procedure TTextField.SetFontPath(APath: string);
begin
  if FFontPath <> APath then
  begin
    FFontPath := APath;
    try
      if Assigned(FFontObject) then FFontObject.Free;
      FFontObject.Create(FFontPath);
      CheckUsingGoodFont;
    except
      if Assigned(FFontObject) then FFontObject.Free;
      FFontObject.Create('');
    end;
  end;
end;

procedure TTextField.SetFieldUpdateTickCount(ACount: cardinal; AMicrosecPerTick: Uint64);
begin
  FFieldUpdateTickCount := ACount;
  if Assigned(FBehaviorWorker) then FBehaviorWorker.SetUpdateTickCount(FFieldUpdateTickCount, AMicrosecPerTick);
end;

procedure TTextField.SetTextString(AString: String);
begin
  if FTextString <> AString then
  begin
    FTextString := AString;
    FNeedsRecalculate := true;
  end;
end;

procedure TTextField.SetTextSize(ASize: cardinal);
begin
  if FTextSize <> ASize then
  begin
    FTextSize := ASize;
    FNeedsRecalculate := true;
  end;
end;

procedure TTextField.SetTextColor(AColor: TSfmlColor);
begin
  if FTextColor.Value <> AColor.Value then
  begin
    FTextColor := AColor;
    FNeedsRecalculate := true;
  end;
end;

procedure TTextField.SetTextStyle(AStyle: Cardinal);
begin
  if FTextStyle <> AStyle then
  begin
    FTextStyle := AStyle;
    FNeedsRecalculate := true;
  end;
end;

procedure TTextField.SetTextSpeed(ASpeed: Cardinal);
begin
  if FTextSpeed <> ASpeed then
  begin
    FTextSpeed := ASpeed;
    FNeedsRecalculate := true;
  end;
end;

procedure TTextField.SetTextFieldType(ATextFieldType: TTextFieldType);
begin
  if FTextFieldType <> ATextFieldType then
  begin
    FTextFieldType := ATextFieldType;
    CreateBehavior;
    FNeedsRecalculate := true;
  end;
end;

procedure TTextField.SetTextHorizontalAlign(AAlign: TTextAlignHorizontal);
begin
  if FTextHorizontalAlign <> AAlign then
  begin
    FTextHorizontalAlign := AAlign;
    FNeedsRecalculate := true;
  end;
end;

procedure TTextField.SetTextVerticalAlign(AAlign: TTextAlignVertical);
begin
  if FTextVerticalAlign <> AAlign then
  begin
    FTextVerticalAlign := AAlign;
    FNeedsRecalculate := true;
  end;
end;

procedure TTextField.SetTextRunningSpace(ASpace: TTextRunningSpacing);
begin
  if FTextRunningSpace <> ASpace then
  begin
    FTextRunningSpace := ASpace;
    FNeedsRecalculate := true;
  end;
end;

procedure TTextField.SetBounds(const ABounds: TSfmlFloatRect);
begin
  inherited SetBounds(ABounds);
  FNeedsRecalculate := true;
end;

procedure TTextField.Recalculate;
begin
  if Assigned(FBehaviorWorker) then FBehaviorWorker.Recalculate;
end;

////////////////////////////////////////////////////////////////////////////////
{ TTextWorkerStatic }
////////////////////////////////////////////////////////////////////////////////

constructor TTextWorkerStatic.Create(AParentObj: TTextField);
begin
  inherited Create;

  FParent := AParentObj;
end;

procedure TTextWorkerStatic.SetUpdateTickCount(const ACount: cardinal; const MicrosecPerTick: Uint64);
begin
  //we don't neet it in static text
end;

function TTextWorkerStatic.Update(const AElapsed: Uint64): boolean;
begin
  FParent.EnsureRecalculate;
  Result := false;  //we don't need to redraw static text
end;

function TTextWorkerStatic.UpdateTick(const AElapsed: Uint64): boolean;
begin
  FParent.EnsureRecalculate;
  Result := false;  //we don't need to redraw static text
end;

procedure TTextWorkerStatic.Draw(AWindow: TSfmlRenderWindow);
begin
  FParent.EnsureRecalculate;

  if FParent.FUsingGoodFont=false then exit;
  AWindow.Draw(FParent.FRenderSprite);
end;

procedure TTextWorkerStatic.Recalculate;
var bounds, temp: TSfmlFloatRect;
origX, origY: single;
str: string;
begin
  if FParent.FUsingGoodFont = false then exit;

  bounds := TSfmlFloatRect.Create(0, 0, 0, 0);
  //respecting horizontal and vertical align
  //calculating vertical bounds
  FParent.FTextObject.UnicodeString := 'Hxj';
  FParent.FTextObject.Style := FParent.FTextStyle;
  FParent.FTextObject.CharacterSize := FParent.FTextSize;
  FParent.FTextObject.FillColor := FParent.FTextColor;
  temp := FParent.FTextObject.LocalBounds;
  bounds.Height := temp.Height;
  bounds.Top := temp.Top;
  //calculating horizontal bounds
  str := FParent.FTextString;
  {$IFDEF FPC}
  FParent.FTextObject.UnicodeString := UTF8Decode(str);
  {$ELSE}
  FParent.FTextObject.UnicodeString := str;
  {$ENDIF}
  temp := FParent.FTextObject.LocalBounds;
  bounds.Left := temp.Left;
  bounds.Width := temp.Width;

  //calculating horizontal origin
  case FParent.FTextHorizontalAlign of
    tahCenter: origX := Floor((FParent.FieldBounds.Width / 2) - (bounds.Width / 2) - bounds.Left) + 1;
    tahRight: origX := (FParent.FieldBounds.Width - bounds.Width - bounds.Left) - 1;
    else origX := Floor(-bounds.Left) + 1;  //tahLeft
  end;

  //calculating vertical origin
  case FParent.FTextVerticalAlign of
    tavCenter: origY := Floor((FParent.FieldBounds.Height / 2) - (bounds.Height / 2) - bounds.Top) + 1;
    tavBottom: origY := Floor(FParent.FieldBounds.Height - bounds.Height - bounds.Top) - 1;
    else origY := Floor(-bounds.Top) + 1;  //tavTop
  end;
  //setting text origin
  FParent.FTextObject.Origin := TSfmlVector2f.Create(-origX, -origY);

  //drawing
  FParent.FRenderTexture.Clear(FParent.BGColor);
  FParent.FRenderTexture.Draw(FParent.FTextObject);
  FParent.FRenderTexture.Display;

  FParent.FRenderSprite.SetTexture(FParent.FRenderTexture.RawTexture, true);
  FParent.FRenderSprite.Position := TSfmlVector2f.Create(FParent.FieldBounds.Left, FParent.FieldBounds.Top);

  FParent.FNeedsRecalculate := false;
end;

////////////////////////////////////////////////////////////////////////////////
{ TTextWorkerAlwaysRunning }
////////////////////////////////////////////////////////////////////////////////

constructor TTextWorkerAlwaysRunning.Create(AParentObj: TTextField);
begin
  inherited Create;

  FParent := AParentObj;
  FTextRunningRealPos := 0;
  FTextRunningClipRect := TSfmlIntRect.Create(0, 0, Floor(FParent.FieldBounds.Width), Floor(FParent.FieldBounds.Height));
  FPixelsPerMicrosecond := FParent.FTextSpeed / 1000000;
  FUpdateTickCount := 1;
  FUpdateTickCurrent := 0;
  FTextRunningThreshold := 100;
end;

procedure TTextWorkerAlwaysRunning.CalculateAndDrawRunning(ABounds: TSfmlFloatRect);
var spaceDistance: double;
tempBounds: TSfmlFloatRect;
tempOrigin: TSfmlVector2f;
str: string;
begin
  FParent.FTextObject.UnicodeString := ' ';
  tempBounds := FParent.FTextObject.LocalBounds;
  str := FParent.FTextString;
  {$IFDEF FPC}
  FParent.FTextObject.UnicodeString := UTF8Decode(str);
  {$ELSE}
  FParent.FTextObject.UnicodeString := str;
  {$ENDIF}

  case FParent.FTextRunningSpace of
    trsNone: spaceDistance := 3;
    trsSpace: spaceDistance := tempBounds.Width;
    trs3Space: spaceDistance := tempBounds.Width * 3;
    trsRemaining: spaceDistance := FParent.FieldBounds.Width - ABounds.Width + 1;
    trs0_5: spaceDistance := FParent.FieldBounds.Width / 2;
    trs1_0: spaceDistance := FParent.FieldBounds.Width;
    trs1_5: spaceDistance := FParent.FieldBounds.Width * 1.5;
    trs2_0: spaceDistance := FParent.FieldBounds.Width * 2;
  end;
  if spaceDistance < 3 then spaceDistance := 3;
  spaceDistance := Floor(spaceDistance);

  //getting origin and shifting to draw second text
  tempOrigin := FParent.FTextObject.Origin;
  tempOrigin.X := tempOrigin.X + ABounds.Width + spaceDistance;
  //geting current X coordinate
  FTextRunningThreshold := tempOrigin.X - FParent.FTextObject.Origin.X;
  //drawing other texts if needed
  while (tempOrigin.X + ABounds.Width + spaceDistance - FTextRunningThreshold) < {FParent.FieldBounds.Width}tempBounds.Width do
  begin
    tempOrigin.X := tempOrigin.X + ABounds.Width + spaceDistance;
  end;

  //resizing texture
  FParent.FRenderTexture.Recreate(Floor(tempOrigin.X + ABounds.Width + spaceDistance), Floor(FParent.FieldBounds.Height));

  //drawing
  //drawing background color
  FParent.FRenderTexture.Clear(FParent.BGColor);
  //always drawing first text in begining
  tempOrigin := TSfmlVector2f.Create(0, 0);
  FParent.FTextObject.Position := tempOrigin;
  FParent.FRenderTexture.Draw(FParent.FTextObject);
  //always drawing second text
  tempOrigin.X := tempOrigin.X + ABounds.Width + spaceDistance;
  FParent.FTextObject.Position := tempOrigin;
  FParent.FRenderTexture.Draw(FParent.FTextObject);
  //drawing other texts if needed
  while (tempOrigin.X + ABounds.Width + spaceDistance - FTextRunningThreshold) < {FParent.FieldBounds.Width}tempBounds.Width do
  begin
    tempOrigin.X := tempOrigin.X + ABounds.Width + spaceDistance;
    FParent.FTextObject.Position := tempOrigin;
    FParent.FRenderTexture.Draw(FParent.FTextObject);
  end;
  FParent.FRenderTexture.Display;
end;

procedure TTextWorkerAlwaysRunning.SetUpdateTickCount(const ACount: cardinal; const MicrosecPerTick: Uint64);
begin
  FUpdateTickCount := ACount;
end;

function TTextWorkerAlwaysRunning.Update(const AElapsed: Uint64): boolean;
var pos: integer;
begin
  Result := false;
  FParent.EnsureRecalculate;

  FTextRunningRealPos := FTextRunningRealPos + (AElapsed * FPixelsPerMicrosecond);
  if FTextRunningRealPos > FTextRunningThreshold then FTextRunningRealPos := FTextRunningRealPos - FTextRunningThreshold;
  pos := Floor(FTextRunningRealPos);
  if pos <> FTextRunningClipRect.Left then
  begin
    Result := true;
    FTextRunningClipRect.Left := pos;
    FParent.FRenderSprite.TextureRect := FTextRunningClipRect;
  end;
end;

function TTextWorkerAlwaysRunning.UpdateTick(const AElapsed: Uint64): boolean;
var pos: integer;
begin
  Result := false;
  FParent.EnsureRecalculate;

  inc(FUpdateTickCurrent);
  if FUpdateTickCurrent >= FUpdateTickCount then
  begin
    FTextRunningRealPos := FTextRunningRealPos + 1;
    if FTextRunningRealPos > FTextRunningThreshold then FTextRunningRealPos := FTextRunningRealPos - FTextRunningThreshold;
    pos := Floor(FTextRunningRealPos);
    FTextRunningClipRect.Left := pos;
    FParent.FRenderSprite.TextureRect := FTextRunningClipRect;
    FUpdateTickCurrent := 0;
    Result := true;
  end;
end;

procedure TTextWorkerAlwaysRunning.Draw(AWindow: TSfmlRenderWindow);
begin
  FParent.EnsureRecalculate;

  if FParent.FUsingGoodFont=false then exit;
  AWindow.Draw(FParent.FRenderSprite);
end;

procedure TTextWorkerAlwaysRunning.Recalculate;
var bounds, temp: TSfmlFloatRect;
origX, origY: single;
str: string;
begin
  if FParent.FUsingGoodFont = false then exit;

  //respecting only vertical align
  //calculating vertical bounds
  FParent.FTextObject.UnicodeString := 'Hxj';
  FParent.FTextObject.Style := FParent.FTextStyle;
  FParent.FTextObject.CharacterSize := FParent.FTextSize;
  FParent.FTextObject.FillColor := FParent.FTextColor;
  temp := FParent.FTextObject.LocalBounds;
  bounds.Height := temp.Height;
  bounds.Top := temp.Top;
  str := FParent.FTextString;
  {$IFDEF FPC}
  FParent.FTextObject.UnicodeString := UTF8Decode(str);
  {$ELSE}
  FParent.FTextObject.UnicodeString := str;
  {$ENDIF}
  temp := FParent.FTextObject.LocalBounds;
  bounds.Left := temp.Left;
  bounds.Width := temp.Width;

  //calculating vertical origin
  case FParent.FTextVerticalAlign of
    tavCenter: origY := Floor((FParent.FieldBounds.Height / 2) - (bounds.Height / 2) - bounds.Top) + 1;
    tavBottom: origY := Floor(FParent.FieldBounds.Height - bounds.Height - bounds.Top) - 1;
    else origY := Floor(-bounds.Top) + 1;  //tavTop
  end;
  //calculating horizontal origin
  origX := Floor(-bounds.Left) + 1;

  //setting text origin
  FParent.FTextObject.Origin := TSfmlVector2f.Create(-origX, -origY);

  CalculateAndDrawRunning(bounds);

  FParent.FRenderSprite.SetTexture(FParent.FRenderTexture.RawTexture, true);
  FParent.FRenderSprite.Position := TSfmlVector2f.Create(FParent.FieldBounds.Left, FParent.FieldBounds.Top);

  FParent.FNeedsRecalculate := false;
end;

////////////////////////////////////////////////////////////////////////////////
{ TTextWorkerOptionalRunning }
////////////////////////////////////////////////////////////////////////////////

constructor TTextWorkerOptionalRunning.Create(AParentObj: TTextField);
begin
  inherited Create;

  FParent := AParentObj;
  FTextRunningRealPos := 0;
  FTextRunningClipRect := TSfmlIntRect.Create(0, 0, Floor(FParent.FieldBounds.Width), Floor(FParent.FieldBounds.Height));
  FPixelsPerMicrosecond := FParent.FTextSpeed / 1000000;
  FUpdateTickCount := 1;
  FUpdateTickCurrent := 0;
  FTextIsRunning := false;
  FTextRunningThreshold := 100;
end;

procedure TTextWorkerOptionalRunning.CalculateAndDrawRunning(ABounds: TSfmlFloatRect);
var spaceDistance: double;
tempBounds: TSfmlFloatRect;
tempOrigin: TSfmlVector2f;
str: string;
begin
  FParent.FTextObject.UnicodeString := ' ';
  tempBounds := FParent.FTextObject.LocalBounds;
  str := FParent.FTextString;
  {$IFDEF FPC}
  FParent.FTextObject.UnicodeString := UTF8Decode(str);
  {$ELSE}
  FParent.FTextObject.UnicodeString := str;
  {$ENDIF}

  case FParent.FTextRunningSpace of
    trsNone: spaceDistance := 3;
    trsSpace: spaceDistance := tempBounds.Width;
    trs3Space: spaceDistance := tempBounds.Width * 3;
    trsRemaining: spaceDistance := FParent.FieldBounds.Width - ABounds.Width + 1;
    trs0_5: spaceDistance := FParent.FieldBounds.Width / 2;
    trs1_0: spaceDistance := FParent.FieldBounds.Width;
    trs1_5: spaceDistance := FParent.FieldBounds.Width * 1.5;
    trs2_0: spaceDistance := FParent.FieldBounds.Width * 2;
  end;
  if spaceDistance < 3 then spaceDistance := 3;
  spaceDistance := Floor(spaceDistance);

  //getting origin and shifting to draw second text
  tempOrigin := FParent.FTextObject.Origin;
  tempOrigin.X := tempOrigin.X + ABounds.Width + spaceDistance;
  //geting current X coordinate
  FTextRunningThreshold := tempOrigin.X - FParent.FTextObject.Origin.X;
  //drawing other texts if needed
  while (tempOrigin.X + ABounds.Width + spaceDistance - FTextRunningThreshold) < FParent.FieldBounds.Width do
  begin
    tempOrigin.X := tempOrigin.X + ABounds.Width + spaceDistance;
  end;

  //resizing texture
  FParent.FRenderTexture.Recreate(Floor(tempOrigin.X + ABounds.Width + spaceDistance), Floor(FParent.FieldBounds.Height));

  //drawing
  //drawing background color
  FParent.FRenderTexture.Clear(FParent.BGColor);
  //always drawing first text in begining
  tempOrigin := TSfmlVector2f.Create(0, 0);
  FParent.FTextObject.Position := tempOrigin;
  FParent.FRenderTexture.Draw(FParent.FTextObject);
  //always drawing second text
  tempOrigin.X := tempOrigin.X + ABounds.Width + spaceDistance;
  FParent.FTextObject.Position := tempOrigin;
  FParent.FRenderTexture.Draw(FParent.FTextObject);
  //drawing other texts if needed
  while (tempOrigin.X + ABounds.Width + spaceDistance - FTextRunningThreshold) < FParent.FieldBounds.Width do
  begin
    tempOrigin.X := tempOrigin.X + ABounds.Width + spaceDistance;
    FParent.FTextObject.Position := tempOrigin;
    FParent.FRenderTexture.Draw(FParent.FTextObject);
  end;
  FParent.FRenderTexture.Display;
end;

procedure TTextWorkerOptionalRunning.CalculateAndDrawStatic(ABounds: TSfmlFloatRect);
begin
  //resizing texture
  FParent.FRenderTexture.Recreate(Floor(FParent.FieldBounds.Width), Floor(FParent.FieldBounds.Height));

  //drawing
  FParent.FRenderTexture.Clear(FParent.BGColor);
  FParent.FTextObject.Position := TSfmlVector2f.Create(0, 0);
  FParent.FRenderTexture.Draw(FParent.FTextObject);
  FParent.FRenderTexture.Display;
end;

procedure TTextWorkerOptionalRunning.SetUpdateTickCount(const ACount: cardinal; const MicrosecPerTick: Uint64);
begin
  FUpdateTickCount := ACount;
end;

function TTextWorkerOptionalRunning.Update(const AElapsed: Uint64): boolean;
var pos: integer;
begin
  Result := false;
  FParent.EnsureRecalculate;

  if FTextIsRunning = false then exit;

  FTextRunningRealPos := FTextRunningRealPos + (AElapsed * FPixelsPerMicrosecond);
  if FTextRunningRealPos > FTextRunningThreshold then FTextRunningRealPos := FTextRunningRealPos - FTextRunningThreshold;
  pos := Floor(FTextRunningRealPos);
  if pos <> FTextRunningClipRect.Left then
  begin
    Result := true;
    FTextRunningClipRect.Left := pos;
    FParent.FRenderSprite.TextureRect := FTextRunningClipRect;
  end;
end;

function TTextWorkerOptionalRunning.UpdateTick(const AElapsed: Uint64): boolean;
var pos: integer;
begin
  Result := false;
  FParent.EnsureRecalculate;

  if FTextIsRunning = false then exit;

  inc(FUpdateTickCurrent);
  if FUpdateTickCurrent >= FUpdateTickCount then
  begin
    FTextRunningRealPos := FTextRunningRealPos + 1;
    if FTextRunningRealPos > FTextRunningThreshold then FTextRunningRealPos := FTextRunningRealPos - FTextRunningThreshold;
    pos := Floor(FTextRunningRealPos);
    FTextRunningClipRect.Left := pos;
    FParent.FRenderSprite.TextureRect := FTextRunningClipRect;
    FUpdateTickCurrent := 0;
    Result := true;
  end;
end;

procedure TTextWorkerOptionalRunning.Draw(AWindow: TSfmlRenderWindow);
begin
  FParent.EnsureRecalculate;

  if FParent.FUsingGoodFont=false then exit;
  AWindow.Draw(FParent.FRenderSprite);
end;

procedure TTextWorkerOptionalRunning.Recalculate;
var bounds, temp: TSfmlFloatRect;
origX, origY: single;
str: string;
begin
  if FParent.FUsingGoodFont = false then exit;

  //respecting vertical and horizontal align
  //calculating bounds
  FParent.FTextObject.UnicodeString := 'Hxj';
  FParent.FTextObject.Style := FParent.FTextStyle;
  FParent.FTextObject.CharacterSize := FParent.FTextSize;
  FParent.FTextObject.FillColor := FParent.FTextColor;
  temp := FParent.FTextObject.LocalBounds;
  bounds.Height := temp.Height;
  bounds.Top := temp.Top;
  str := FParent.FTextString;
  {$IFDEF FPC}
  FParent.FTextObject.UnicodeString := UTF8Decode(str);
  {$ELSE}
  FParent.FTextObject.UnicodeString := str;
  {$ENDIF}
  temp := FParent.FTextObject.LocalBounds;
  bounds.Left := temp.Left;
  bounds.Width := temp.Width;

  //calculating vertical origin
  case FParent.FTextVerticalAlign of
    tavCenter: origY := Floor((FParent.FieldBounds.Height / 2) - (bounds.Height / 2) - bounds.Top) + 1;
    tavBottom: origY := Floor(FParent.FieldBounds.Height - bounds.Height - bounds.Top) - 1;
    else origY := Floor(-bounds.Top) + 1;  //tavTop
  end;

  //checking if text needs to be running
  if bounds.Width > FParent.FieldBounds.Width then
  begin  //text needs to be running
    FTextIsRunning := true;
    //calculating horizontal origin
    origX := Floor(-bounds.Left) + 1;

    //setting text origin
    FParent.FTextObject.Origin := TSfmlVector2f.Create(-origX, -origY);

    //inside we resize the texture
    CalculateAndDrawRunning(bounds);

    FParent.FRenderSprite.SetTexture(FParent.FRenderTexture.RawTexture, true);
    FParent.FRenderSprite.Position := TSfmlVector2f.Create(FParent.FieldBounds.Left, FParent.FieldBounds.Top);
  end
  else
  begin  //text need to be static
    FTextIsRunning := false;
    //calculating horizontal origin
    case FParent.FTextHorizontalAlign of
      tahCenter: origX := Floor((FParent.FieldBounds.Width / 2) - (bounds.Width / 2) - bounds.Left) + 1;
      tahRight: origX := (FParent.FieldBounds.Width - bounds.Width - bounds.Left) - 1;
      else origX := Floor(-bounds.Left) + 1;  //tahLeft
    end;

    //setting text origin
    FParent.FTextObject.Origin := TSfmlVector2f.Create(-origX, -origY);

    //inside we resize the texture
    CalculateAndDrawStatic(bounds);

    FParent.FRenderSprite.SetTexture(FParent.FRenderTexture.RawTexture, true);
    FParent.FRenderSprite.Position := TSfmlVector2f.Create(FParent.FieldBounds.Left, FParent.FieldBounds.Top);
  end;

  FParent.FNeedsRecalculate := false;
end;

////////////////////////////////////////////////////////////////////////////////
{ TTextWorkerDateTime }
////////////////////////////////////////////////////////////////////////////////

constructor TTextWorkerDateTime.Create(AParentObj: TTextField);
begin
  inherited Create;

  FParent := AParentObj;
  FCurrentMicrosecGlobal := 0;
  FCurrentMicrosecLocal := 0;
  FCurrentTimePhase := 0;
  FUpdateThresholdMicro := 50000;  //lowest update that we need to do is 250ms (4 times per second). Set to 50ms to check multiple times per update.
  FCurrentTextString := FParent.TextString;
  {$IFDEF FPC}
  FFormatSettings := DefaultFormatSettings;
  {$ELSE}
  FFormatSettings := TFormatSettings.Create;
  {$ENDIF}

  CalculateFormat;
end;

procedure TTextWorkerDateTime.SetUpdateTickCount(const ACount: cardinal; const MicrosecPerTick: Uint64);
begin
  //do nothing. We treat UpdateTick as regular Update
end;

function TTextWorkerDateTime.Update(const AElapsed: Uint64): boolean;
var str: string;
begin
  Result := false;
  FParent.EnsureRecalculate;

  FCurrentMicrosecLocal := FCurrentMicrosecLocal + AElapsed;
  FCurrentMicrosecGlobal := FCurrentMicrosecGlobal + AElapsed;
  if FCurrentMicrosecLocal > FUpdateThresholdMicro then
  begin
    FCurrentTimePhase := (FCurrentMicrosecGlobal div FPhaseMicrosec) mod FPhaseCount;
    str := FormatDateTime(FPhaseStrings[FCurrentTimePhase], Now, FFormatSettings);
    {$IFDEF FPC}
    FParent.FTextObject.UnicodeString := UTF8Decode(str);
    {$ELSE}
    FParent.FTextObject.UnicodeString := str;
    {$ENDIF}

    //drawing
    FParent.FRenderTexture.Clear(FParent.BGColor);
    FParent.FRenderTexture.Draw(FParent.FTextObject);
    FParent.FRenderTexture.Display;

    Result := true;
    FCurrentMicrosecLocal := FCurrentMicrosecLocal - FUpdateThresholdMicro;
    if FCurrentMicrosecLocal > 10000000 then FCurrentMicrosecLocal := FCurrentMicrosecLocal - 10000000;  //prevent from overflow
  end;
end;

function TTextWorkerDateTime.UpdateTick(const AElapsed: Uint64): boolean;
begin
  Result := Update(AElapsed);
end;

procedure TTextWorkerDateTime.Draw(AWindow: TSfmlRenderWindow);
begin
  FParent.EnsureRecalculate;

  if FParent.FUsingGoodFont=false then exit;

  AWindow.Draw(FParent.FRenderSprite);
end;

procedure TTextWorkerDateTime.CalculateFormat;
var i, j: integer;
tempStr: String;
dt: TDateTime;

  function ReplaceWithString(const AInput, AMask, AReplace: String; AReplaceWithArgument: boolean): String;
  var k, z: integer;
  begin
    Result := AInput;
    z := 1;
    k := PosEx(AMask, Result, z);
    while k <> 0 do
    begin
      if AReplaceWithArgument = true then
      begin
        delete(Result, k, 3);
        insert('"'+AReplace+'"', Result, k);
        k := k + length(AReplace) + 2;
      end
      else  //AReplaceWithArgument = false
      begin
        delete(Result, k, 2);
        insert('"', Result, k);
        inc(k, 2);
        insert('"', Result, k);
      end;

      z := k;
      k := PosEx(AMask, Result, z);
    end;
  end;

begin
  (* Available formats
  c           Displays the date using the format given by the ShortDateFormat global variable, followed by the time using the format given by the LongTimeFormat global variable. The time is not displayed if the date-time value indicates midnight precisely.
  d           Displays the day as a number without a leading zero (1-31).
  dd          Displays the day as a number with a leading zero (01-31).
  ddd         Displays the day as an abbreviation (Sun-Sat) using the strings given by the ShortDayNames global variable.
  dddd        Displays the day as a full name (Sunday-Saturday) using the strings given by the LongDayNames global variable.
  ddddd       Displays the date using the format given by the ShortDateFormat global variable.
  dddddd      Displays the date using the format given by the LongDateFormat global variable.
  e           (Windows only) Displays the year in the current period/era as a number without a leading zero (Japanese, Korean, and Taiwanese locales only).
  ee          (Windows only) Displays the year in the current period/era as a number with a leading zero (Japanese, Korean, and Taiwanese locales only).
  g           (Windows only) Displays the period/era as an abbreviation (Japanese and Taiwanese locales only).
  gg          (Windows only) Displays the period/era as a full name (Japanese and Taiwanese locales only).
  m           Displays the month as a number without a leading zero (1-12). If the m specifier immediately follows an h or hh specifier, the minute rather than the month is displayed.
  mm          Displays the month as a number with a leading zero (01-12). If the mm specifier immediately follows an h or hh specifier, the minute rather than the month is displayed.
  mmm         Displays the month as an abbreviation (Jan-Dec) using the strings given by the ShortMonthNames global variable.
  mmmm        Displays the month as a full name (January-December) using the strings given by the LongMonthNames global variable.
  yy          Displays the year as a two-digit number (00-99).
  yyyy        Displays the year as a four-digit number (0000-9999).
  h           Displays the hour without a leading zero (0-23).
  hh          Displays the hour with a leading zero (00-23).
  n           Displays the minute without a leading zero (0-59).
  nn          Displays the minute with a leading zero (00-59).
  s           Displays the second without a leading zero (0-59).
  ss          Displays the second with a leading zero (00-59).
  z           Displays the millisecond without a leading zero (0-999).
  zzz         Displays the millisecond with a leading zero (000-999).
  t           Displays the time using the format given by the ShortTimeFormat global variable.
  tt          Displays the time using the format given by the LongTimeFormat global variable.
  am/pm       Uses the 12-hour clock for the preceding h or hh specifier, and displays 'am' for any hour before noon, and 'pm' for any hour after noon. The am/pm specifier can use lower, upper, or mixed case, and the result is displayed accordingly.
  a/p         Uses the 12-hour clock for the preceding h or hh specifier, and displays 'a' for any hour before noon, and 'p' for any hour after noon. The a/p specifier can use lower, upper, or mixed case, and the result is displayed accordingly.
  ampm        Uses the 12-hour clock for the preceding h or hh specifier, and displays the contents of the TimeAMString global variable for any hour before noon, and the contents of the TimePMString global variable for any hour after noon.
  /           Displays the date separator character given by the DateSeparator variable.
  :           Displays the time separator character given by the TimeSeparator variable.
  'xx'/"xx"   Characters enclosed in single or double quotation marks are displayed as such, and do not affect formatting
  %D<char>    Changes DateSeparator variable to <char>.
  %T<char>    Changes TimeSeparator variable to <char>.
  %0          Time separator that is always on.
  %1          Time separator that switches on/off 1 time per second.
  %2          Time separator that switches on/off 2 times per second.
  %4          Time separator that switches on/off 4 times per second.
  %5<char>    Character that switches on/off 1 time per second.
  %6<char>    Character that switches on/off 2 time per second.
  %7<char>    Character that switches on/off 4 time per second.
  *)

  FUpdateThresholdMicro := 50000;  //unless we have miliseconds, then it's 1
  dt := Now;
  FCurrentMicrosecGlobal := SecondOf(dt) * 1000000 + MilliSecondOf(dt) * 1000;
  FCurrentMicrosecLocal := FCurrentMicrosecGlobal mod FUpdateThresholdMicro;
  FCurrentTimePhase := (FCurrentMicrosecGlobal div FPhaseMicrosec) mod FPhaseCount;
  tempStr := FCurrentTextString;
  {$IFDEF FPC}
  FFormatSettings := DefaultFormatSettings;
  {$ELSE}
  FFormatSettings := TFormatSettings.Create;
  {$ENDIF}
  for i := Low(FPhaseStrings) to High(FPhaseStrings) do
    FPhaseStrings[i] := '';

  //checking if we need to do this
  if FCurrentTextString = '' then exit;

  //reading and deleting special character settings if there is any
  //DateSeparator
  i := 1;
  j := PosEx('%D', tempStr, i);
  while j <> 0 do
  begin
    if j <= (length(tempStr) - 2) then
      FFormatSettings.DateSeparator := tempStr[j+2];
    delete(tempStr, j, 3);

    i := j;
    j := PosEx('%D', tempStr, i);
  end;

  //TimeSeparator
  i := 1;
  j := PosEx('%T', tempStr, i);
  while j <> 0 do
  begin
    if j <= (length(tempStr) - 2) then
      FFormatSettings.TimeSeparator := tempStr[j+2];
    delete(tempStr, j, 3);

    i := j;
    j := PosEx('%T', tempStr, i);
  end;

  //check if we have miliseconds in format
  i := Pos('z', tempStr);  //zzz will enable this too
  if (i <> 0) then FUpdateThresholdMicro := 1000;

  //filling string for each phase
  for i := Low(FPhaseStrings) to High(FPhaseStrings) do
  begin
    {FPhaseStrings[i] := tempStr;
    //%0          Time separator that is always on.
    FPhaseStrings[i] := FPhaseStrings[i].Replace('%0', FFormatSettings.TimeSeparator, [rfReplaceAll]);
    //%1          Time separator that switches on/off 1 time per second.
    if (i div 4) = 0 then FPhaseStrings[i] := FPhaseStrings[i].Replace('%1', FFormatSettings.TimeSeparator, [rfReplaceAll])
    else FPhaseStrings[i] := FPhaseStrings[i].Replace('%1', ' ', [rfReplaceAll]);
    //%2          Time separator that switches on/off 2 times per second.
    if ((i div 2) mod 2) = 0 then FPhaseStrings[i] := FPhaseStrings[i].Replace('%2', FFormatSettings.TimeSeparator, [rfReplaceAll])
    else FPhaseStrings[i] := FPhaseStrings[i].Replace('%2', ' ', [rfReplaceAll]);
    //%4          Time separator that switches on/off 4 times per second.
    if (i mod 2) = 0 then FPhaseStrings[i] := FPhaseStrings[i].Replace('%4', FFormatSettings.TimeSeparator, [rfReplaceAll])
    else FPhaseStrings[i] := FPhaseStrings[i].Replace('%4', ' ', [rfReplaceAll]);      }

    {FPhaseStrings[i] := tempStr;
    //%0          Time separator that is always on.
    FPhaseStrings[i] := StringReplaceHelper(FPhaseStrings[i], '%0', FFormatSettings.TimeSeparator, [rfsReplaceAll]);
    //%1          Time separator that switches on/off 1 time per second.
    if (i div 4) = 0 then FPhaseStrings[i] := StringReplaceHelper(FPhaseStrings[i], '%1', FFormatSettings.TimeSeparator, [rfsReplaceAll])
    else FPhaseStrings[i] := StringReplaceHelper(FPhaseStrings[i], '%1', ' ', [rfsReplaceAll]);
    //%2          Time separator that switches on/off 2 times per second.
    if ((i div 2) mod 2) = 0 then FPhaseStrings[i] := StringReplaceHelper(FPhaseStrings[i], '%2', FFormatSettings.TimeSeparator, [rfsReplaceAll])
    else FPhaseStrings[i] := StringReplaceHelper(FPhaseStrings[i], '%2', ' ', [rfsReplaceAll]);
    //%4          Time separator that switches on/off 4 times per second.
    if (i mod 2) = 0 then FPhaseStrings[i] := StringReplaceHelper(FPhaseStrings[i], '%4', FFormatSettings.TimeSeparator, [rfsReplaceAll])
    else FPhaseStrings[i] := StringReplaceHelper(FPhaseStrings[i], '%4', ' ', [rfsReplaceAll]);   }
    FPhaseStrings[i] := tempStr;
    //%0          Time separator that is always on.
    FPhaseStrings[i] := StringReplace(FPhaseStrings[i], '%0', FFormatSettings.TimeSeparator, [rfReplaceAll]);
    //%1          Time separator that switches on/off 1 time per second.
    if (i div 4) = 0 then FPhaseStrings[i] := StringReplace(FPhaseStrings[i], '%1', FFormatSettings.TimeSeparator, [rfReplaceAll])
    else FPhaseStrings[i] := StringReplace(FPhaseStrings[i], '%1', ' ', [rfReplaceAll]);
    //%2          Time separator that switches on/off 2 times per second.
    if ((i div 2) mod 2) = 0 then FPhaseStrings[i] := StringReplace(FPhaseStrings[i], '%2', FFormatSettings.TimeSeparator, [rfReplaceAll])
    else FPhaseStrings[i] := StringReplace(FPhaseStrings[i], '%2', ' ', [rfReplaceAll]);
    //%4          Time separator that switches on/off 4 times per second.
    if (i mod 2) = 0 then FPhaseStrings[i] := StringReplace(FPhaseStrings[i], '%4', FFormatSettings.TimeSeparator, [rfReplaceAll])
    else FPhaseStrings[i] := StringReplace(FPhaseStrings[i], '%4', ' ', [rfReplaceAll]);

    //%5<char>    Character that switches on/off 1 time per second.
    if (i div 4) = 0 then FPhaseStrings[i] := ReplaceWithString(FPhaseStrings[i], '%5', '', false)
    else FPhaseStrings[i] := ReplaceWithString(FPhaseStrings[i], '%5', ' ', true);
    //%6<char>    Character that switches on/off 2 time per second.
    if ((i div 2) mod 2) = 0 then FPhaseStrings[i] := ReplaceWithString(FPhaseStrings[i], '%6', '', false)
    else FPhaseStrings[i] := ReplaceWithString(FPhaseStrings[i], '%6', ' ', true);
    //%7<char>    Character that switches on/off 4 time per second.
    if (i mod 2) = 0 then FPhaseStrings[i] := ReplaceWithString(FPhaseStrings[i], '%7', '', false)
    else FPhaseStrings[i] := ReplaceWithString(FPhaseStrings[i], '%7', ' ', true);
  end;

  //calculate and change TextSpeed in parent to make correct calculation when using UpdateTick
  i := 1000000 div FUpdateThresholdMicro;
  if i > 120 then i := 120;
  FParent.FTextSpeed := i;
end;

procedure TTextWorkerDateTime.Recalculate;
var bounds, temp: TSfmlFloatRect;
origX, origY: single;
str: string;
begin
  if FParent.FUsingGoodFont = false then exit;

  //get the string from parent
  FCurrentTextString := FParent.TextString;
  //calculating needed variables
  CalculateFormat;

  bounds := TSfmlFloatRect.Create(0, 0, 0, 0);
  //respecting horizontal and vertical align
  //calculating vertical bounds
  FParent.FTextObject.UnicodeString := 'Hxj';
  FParent.FTextObject.Style := FParent.FTextStyle;
  FParent.FTextObject.CharacterSize := FParent.FTextSize;
  FParent.FTextObject.FillColor := FParent.FTextColor;
  temp := FParent.FTextObject.LocalBounds;
  bounds.Height := temp.Height;
  bounds.Top := temp.Top;
  //calculating horizontal bounds
  str := FormatDateTime(FPhaseStrings[0], Now, FFormatSettings);
  {$IFDEF FPC}
  FParent.FTextObject.UnicodeString := UTF8Decode(str);
  {$ELSE}
  FParent.FTextObject.UnicodeString := str;
  {$ENDIF}
  temp := FParent.FTextObject.LocalBounds;
  bounds.Left := temp.Left;
  bounds.Width := temp.Width;

  //calculating horizontal origin
  case FParent.FTextHorizontalAlign of
    tahCenter: origX := Floor((FParent.FieldBounds.Width / 2) - (bounds.Width / 2) - bounds.Left) + 1;
    tahRight: origX := (FParent.FieldBounds.Width - bounds.Width - bounds.Left) - 1;
    else origX := Floor(-bounds.Left) + 1;  //tahLeft
  end;

  //calculating vertical origin
  case FParent.FTextVerticalAlign of
    tavCenter: origY := Floor((FParent.FieldBounds.Height / 2) - (bounds.Height / 2) - bounds.Top) + 1;
    tavBottom: origY := Floor(FParent.FieldBounds.Height - bounds.Height - bounds.Top) - 1;
    else origY := Floor(-bounds.Top) + 1;  //tavTop
  end;
  //setting text origin
  FParent.FTextObject.Origin := TSfmlVector2f.Create(-origX, -origY);

  //drawing
  FParent.FRenderTexture.Clear(FParent.BGColor);
  FParent.FRenderTexture.Draw(FParent.FTextObject);
  FParent.FRenderTexture.Display;

  FParent.FRenderSprite.SetTexture(FParent.FRenderTexture.RawTexture, true);
  FParent.FRenderSprite.Position := TSfmlVector2f.Create(FParent.FieldBounds.Left, FParent.FieldBounds.Top);

  FParent.FNeedsRecalculate := false;
end;

end.
