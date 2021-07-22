unit uGraphicsField;

interface

uses
  uFieldBase,
  SFMLGraphics
  ;

type
  //types of Graphics field
  TGraphicsFieldType = (gftStaticPicture, gftAnimatedPicture);
  //horizontal alligment
  TGraphicsAlignHorizontal = (gahLeft, gahCenter, gahRight, gahStretch);
  //vertical aligment
  TGraphicsAlignVertical = (gavTop, gavCenter, gavBottom, gavStretch);

  IGraphicsWorker = Interface(IInterface)
    ['{DC6937B9-7266-4895-88C9-E4D71EC8C2F2}']
    function GetGraphicsReady: boolean;
    procedure SetUpdateTickCount(const ACount: cardinal; const MicrosecPerTick: Uint64);
    function Update(const AElapsed: Uint64): boolean;
    function UpdateTick(const AElapsed: Uint64): boolean;
    procedure Draw(AWindow: TSfmlRenderWindow); overload;
    procedure Draw(ARenderTexture: TSfmlRenderTexture); overload;
    procedure Recalculate;
    function LoadFromFile(const AFileName: string): boolean;
    property GraphicsReady: boolean read GetGraphicsReady;
  End;

  TGraphicsField = class(TFieldBase)
  private
    FGraphicsType: TGraphicsFieldType;
    FGraphicsHorizontalAlign: TGraphicsAlignHorizontal;
    FGraphicsVerticalAlign: TGraphicsAlignVertical;

    FGraphicsWorker: IGraphicsWorker;

    procedure CreateGraphicsWorker;

    procedure SetGraphicsType(AType: TGraphicsFieldType);
    function GetGraphicsReady: boolean;
    procedure SetHorizontalAlign(AHorizontalAlign: TGraphicsAlignHorizontal);
    procedure SetVerticalAlign(AVerticalAlign: TGraphicsAlignVertical);
  protected
    procedure Recalculate; override;
    procedure EnsureRecalculate; override;
  public
    constructor Create; overload; override;
    constructor Create(const ABounds: TSfmlFloatRect); overload; override;
    constructor Create(const ABounds: TSfmlFloatRect; AFieldType: TGraphicsFieldType); overload;
    destructor Destroy; override;

    function Update(const AElapsedMicrosec: Uint64): boolean; override;
    function UpdateTick(const AElapsedMicrosec: Uint64): boolean; override;
    procedure Draw(AWindow: TSfmlRenderWindow); overload; override;
    procedure Draw(ARenderTexture: TSfmlRenderTexture); overload;

    function LoadFromFile(const AFile: string): boolean;

    property GraphicsFieldType: TGraphicsFieldType read FGraphicsType write SetGraphicsType;
    property GraphicsReady: boolean read GetGraphicsReady;
    property GraphicsHorizontalAlign: TGraphicsAlignHorizontal read FGraphicsHorizontalAlign write SetHorizontalAlign;
    property GraphicsVerticalAlign: TGraphicsAlignVertical read FGraphicsVerticalAlign write SetVerticalAlign;
  end;

  TGraphicsWorkerStaticPicture = class(TInterfacedObject, IGraphicsWorker)
  private
    FParent: TGraphicsField;
    FImage: TSfmlImage;
    FSprite: TSfmlSprite;
    FTexture: TSfmlTexture;
    FGraphicsRady: boolean;
    FSupportedExtensions: array of string; //jpg, bmp, png, tga, gif, psd

    function SupportedFileExtension(const AExtension: string): boolean;
    //IGraphicsWorker
    function GetGraphicsReady: boolean;
    procedure SetUpdateTickCount(const ACount: cardinal; const MicrosecPerTick: Uint64);
    function Update(const AElapsed: Uint64): boolean;
    function UpdateTick(const AElapsed: Uint64): boolean;
    procedure Draw(AWindow: TSfmlRenderWindow); overload;
    procedure Draw(ARenderTexture: TSfmlRenderTexture); overload;
    procedure Recalculate;
    function LoadFromFile(const AFileName: string): boolean;
  public
    constructor Create(AParentObj: TGraphicsField);
    destructor Destroy; override;

    property GraphicsReady: boolean read GetGraphicsReady;
  end;

implementation

uses
  SysUtils,
  Math,
  //Vcl.Imaging.GIFImg,
  //System.TypInfo,
{$IFDEF FPC}Graphics,{$ELSE}Vcl.Graphics,{$ENDIF}
  SfmlSystem
  ;

////////////////////////////////////////////////////////////////////////////////
{ TGraphicsField }
////////////////////////////////////////////////////////////////////////////////

constructor TGraphicsField.Create;
begin
  Create(TSfmlFloatRect.Create(0, 0, 100, 100), gftStaticPicture);
end;

constructor TGraphicsField.Create(const ABounds: TSfmlFloatRect);
begin
  Create(ABounds, gftStaticPicture);
end;

constructor TGraphicsField.Create(const ABounds: TSfmlFloatRect; AFieldType: TGraphicsFieldType);
begin
  inherited Create(ABounds);

  FGraphicsType := gftStaticPicture;
  FNeedsRecalculate := true;
  FGraphicsHorizontalAlign := gahLeft;
  FGraphicsVerticalAlign := gavTop;

  CreateGraphicsWorker;
end;

destructor TGraphicsField.Destroy;
begin
  FGraphicsWorker := nil;

  inherited Destroy;
end;

procedure TGraphicsField.CreateGraphicsWorker;
begin
  FGraphicsWorker := nil;

  case FGraphicsType of
    gftAnimatedPicture:;
    else FGraphicsWorker := TGraphicsWorkerStaticPicture.Create(Self);
  end;
end;

procedure TGraphicsField.SetGraphicsType(AType: TGraphicsFieldType);
begin
  if FGraphicsType <> AType then
  begin
    FGraphicsType := AType;
    CreateGraphicsWorker;
    FNeedsRecalculate := true;
  end;
end;

function TGraphicsField.GetGraphicsReady: boolean;
begin
  if Assigned(FGraphicsWorker) then Result := FGraphicsWorker.GraphicsReady
  else Result := false;
end;

procedure TGraphicsField.SetHorizontalAlign(AHorizontalAlign: TGraphicsAlignHorizontal);
begin
  if FGraphicsHorizontalAlign <> AHorizontalAlign then
  begin
    FGraphicsHorizontalAlign := AHorizontalAlign;
    FNeedsRecalculate := true;
  end;
end;

procedure TGraphicsField.SetVerticalAlign(AVerticalAlign: TGraphicsAlignVertical);
begin
  if FGraphicsVerticalAlign <> AVerticalAlign then
  begin
    FGraphicsVerticalAlign := AVerticalAlign;
    FNeedsRecalculate := true;
  end;
end;

procedure TGraphicsField.Recalculate;
begin
  if Assigned(FGraphicsWorker) then FGraphicsWorker.Recalculate;
end;

procedure TGraphicsField.EnsureRecalculate;
begin
  if NeedsRecalculate then Recalculate;
end;

function TGraphicsField.Update(const AElapsedMicrosec: Uint64): boolean;
begin
  if Assigned(FGraphicsWorker) then Result := FGraphicsWorker.Update(AElapsedMicrosec)
  else Result := false;
end;

function TGraphicsField.UpdateTick(const AElapsedMicrosec: Uint64): boolean;
begin
  if Assigned(FGraphicsWorker) then Result := FGraphicsWorker.UpdateTick(AElapsedMicrosec)
  else Result := false;
end;

procedure TGraphicsField.Draw(AWindow: TSfmlRenderWindow);
begin
  if Assigned(FGraphicsWorker) then FGraphicsWorker.Draw(AWindow);
  if DebugMode = true then AWindow.Draw(FDebugRect);
end;

procedure TGraphicsField.Draw(ARenderTexture: TSfmlRenderTexture);
begin
  if Assigned(FGraphicsWorker) then FGraphicsWorker.Draw(ARenderTexture);
  if DebugMode = true then ARenderTexture.Draw(FDebugRect);
end;

function TGraphicsField.LoadFromFile(const AFile: string): boolean;
begin
  if Assigned(FGraphicsWorker) then Result := FGraphicsWorker.LoadFromFile(AFile)
  else Result := false;

  FNeedsRecalculate := Result;
end;

////////////////////////////////////////////////////////////////////////////////
{ TGraphicsWorkerStaticPicture }
////////////////////////////////////////////////////////////////////////////////

constructor TGraphicsWorkerStaticPicture.Create(AParentObj: TGraphicsField);
begin
  inherited Create;

  FParent := AParentObj;
  FImage := TSfmlImage.Create(100, 100);
  FSprite := TSfmlSprite.Create;
  FTexture := nil;
  setlength(FSupportedExtensions, 6);
  FSupportedExtensions[0] := '.jpg';
  FSupportedExtensions[1] := '.bmp';
  FSupportedExtensions[2] := '.png';
  FSupportedExtensions[3] := '.tga';
  FSupportedExtensions[4] := '.gif';
  FSupportedExtensions[5] := '.psd';
  FGraphicsRady := false;
end;

destructor TGraphicsWorkerStaticPicture.Destroy;
begin
  if Assigned(FImage) then FreeAndNil(FImage);
  if Assigned(FSprite) then FreeAndNil(FSprite);
  if Assigned(FTexture) then FreeAndNil(FTexture);

  setlength(FSupportedExtensions, 0);

  inherited Destroy;
end;

function TGraphicsWorkerStaticPicture.GetGraphicsReady: boolean;
begin
  Result := FGraphicsRady;
end;

procedure TGraphicsWorkerStaticPicture.SetUpdateTickCount(const ACount: cardinal; const MicrosecPerTick: Uint64);
begin
  //don't need update, so ignore this call
end;

function TGraphicsWorkerStaticPicture.Update(const AElapsed: Uint64): boolean;
begin
  //don't need to update static picture
  FParent.EnsureRecalculate;
  Result := false;
end;

function TGraphicsWorkerStaticPicture.UpdateTick(const AElapsed: Uint64): boolean;
begin
  //don't need to update static picture
  FParent.EnsureRecalculate;
  Result := false;
end;

procedure TGraphicsWorkerStaticPicture.Draw(AWindow: TSfmlRenderWindow);
begin
  if FGraphicsRady = false then exit;

  FParent.EnsureRecalculate;

  AWindow.Draw(FParent.FRenderSprite);
end;

procedure TGraphicsWorkerStaticPicture.Draw(ARenderTexture: TSfmlRenderTexture);
begin
  if FGraphicsRady = false then exit;

  FParent.EnsureRecalculate;

  ARenderTexture.Draw(FParent.FRenderSprite);
end;

procedure TGraphicsWorkerStaticPicture.Recalculate;
var w, h: cardinal;
scaleFactors: TSfmlVector2f;
pos: TSfmlVector2f;
begin
  if FGraphicsRady = false then exit;

  //load image to texture and sprite
  w := FImage.Size.X;
  h := FImage.Size.Y;
  if Assigned(FTexture) then FreeAndNil(FTexture);
  FTexture := TSfmlTexture.Create(FImage.Handle);
  FSprite.SetTexture(FTexture, true);

  scaleFactors := TSfmlVector2f.Create(1, 1);
  pos := TSfmlVector2f.Create(0, 0);
  //align horizontaly
  case FParent.GraphicsHorizontalAlign of
    gahStretch:
    begin
      pos.X := 0;
      scaleFactors.X := FParent.FieldBounds.Width / w;
    end;
    gahCenter: pos.X := (Floor(FParent.FieldBounds.Width) div 2) - (w div 2);
    gahRight: pos.X := FParent.FieldBounds.Width - w;
    else pos.X := 0;  //default - leftAlign
  end;
  //align vertically
  case FParent.GraphicsVerticalAlign of
    gavStretch:
    begin
      pos.Y := 0;
      scaleFactors.Y := FParent.FieldBounds.Height / h;
    end;
    gavCenter: pos.Y := (Floor(FParent.FieldBounds.Height) div 2) - (h div 2);
    gavBottom: pos.Y := FParent.FieldBounds.Height - h;
    else pos.Y := 0;  //default - alignTop
  end;

  FSprite.Position := pos;
  FSprite.ScaleFactor := scaleFactors;

  //drawing
  FParent.FRenderTexture.Clear(FParent.BGColor);
  FParent.FRenderTexture.Draw(FSprite);
  FParent.FRenderTexture.Display;

  FParent.FRenderSprite.SetTexture(FParent.FRenderTexture.RawTexture, true);
  FParent.FRenderSprite.Position := TSfmlVector2f.Create(FParent.FieldBounds.Left, FParent.FieldBounds.Top);

  FParent.FNeedsRecalculate := false;
end;

function TGraphicsWorkerStaticPicture.LoadFromFile(const AFileName: string): boolean;
var str: string;
begin
  //check if we support it
  if FileExists(AFileName, false) = false then Exit(false);
  if SupportedFileExtension(ExtractFileExt(AFileName)) = false then Exit(false);

  //if we support it, load an image
  Result := FImage.LoadFromFile(AFileName);
  FGraphicsRady := Result;
  //rest will be done in Recalculate method
  //FNeedsRecalculate is set in parent method
end;

function TGraphicsWorkerStaticPicture.SupportedFileExtension(const AExtension: string): boolean;
var i: integer;
begin
  Result := false;
  for i := Low(FSupportedExtensions) to High(FSupportedExtensions) do
    if FSupportedExtensions[i] = AExtension then
      Exit(true);
end;

end.
