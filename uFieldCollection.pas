unit uFieldCollection;

interface

uses
  SfmlGraphics,
  uTextField
  ;

type
  TFieldCollection=class(TObject)
  private
    FFieldArr: array of TTextField;
    FSize: cardinal;

    FCurrentMicro: Uint64;
    FRedrawTickMicro: Uint64;

    procedure SetSize(ASize: cardinal);
    function GetField(AIndex: integer): TTextField;
  public
    constructor Create(const AWidth, AHeight, ASize: cardinal; AFont: string);
    destructor Destroy; override;

    procedure AddField(AField: TTextField);
    procedure CalculateRedrawTick;

    function Update(const AElapsedMicrosec: Uint64): boolean;
    procedure Draw(AWindow: TSfmlRenderWindow);

    property Size: cardinal read FSize write SetSize;
    property Fields[AIndex: integer]: TTextField read GetField;
  end;

implementation

uses
  Math,
  SysUtils
  ;

{ TFieldCollection }

constructor TFieldCollection.Create(const AWidth, AHeight, ASize: cardinal; AFont: string);
var i, k, l: integer;
j: integer;
bounds, b2, inter: TSfmlFloatRect;
col: TSfmlColor;
b: boolean;
//speeds: array of cardinal;
begin
  inherited Create;

  FSize := ASize;
  FCurrentMicro := 0;
  FRedrawTickMicro := 1000000;

  randomize;
  SetLength(FFieldArr, ASize);
  for i := Low(FFieldArr) to High(FFieldArr) do
  begin
    repeat
      b := true;
      bounds.Width := 100 + random(500);
      bounds.Height := 10 + random(100);
      bounds.Left := random(Floor(AWidth - bounds.Width));
      bounds.Top := random(Floor(AHeight - bounds.Height));

      for j := 0 to i-1 do
      begin
        b2 := FFieldArr[j].FieldBounds;
        if SfmlFloatRectIntersects(bounds, b2, inter) = true then
        begin
          b := false;
          break;
        end;
      end;
    until b = true;

    FFieldArr[i] := TTextField.Create(bounds, AFont, random(20)+10);
    FFieldArr[i].TextFieldType := tfAlwaysRunning;
    FFieldArr[i].TextString := 'Test'+inttostr(i);
    col.Value := random(2147483647);
    col.A := 255;
    FFieldArr[i].TextColor := col;
    col.Value := random(2147483647);
    //col.A := 255;
    FFieldArr[i].BGColor := col;

    //j := ((10 + random(200)) div 10) * 10;
    //j := 30;
    //case random(3) of
    case 2 of
      0: j := 60;
      1: j := 120;
      2: j := 30;
    end;
    FFieldArr[i].TextSpeed := j;
    Writeln('Speed='+inttostr(j));

    FFieldArr[i].TextHorizontalAlign := tahCenter;
    FFieldArr[i].TextVerticalAlign := tavTop;
    //FFieldArr[i].TextRunningSpace := trs0_5;
  end;

  CalculateRedrawTick;

  {//считаем наименьший общий знаменатель
  j := 1;
  for i := Low(speeds) to High(speeds) do
    j := j * speeds[i];
  if j > 5000 then j := 5000;
  k := j;  //нужный нам наименьший общий знаменатель
  for i := maxspeed to j do
  begin
    //проверяем число
    b := true;
    for l := Low(speeds) to High(speeds) do
      if (i mod speeds[l]) <> 0 then
      begin
        b := false;
        break;
      end;

    if b = true then
    begin
      k := i;
      break;
    end;
  end;

  tickSpeed := k;
  writeln('Minimal FPS='+inttostr(tickSpeed));

  //выставляем вычислинную скорость
  for i := Low(FFieldArr) to High(FFieldArr) do
    FFieldArr[i].FieldUpdateTickCount := tickSpeed div FFieldArr[i].TextSpeed;

  //вычисляем, через сколько микро нужно давать обновление
  FRedrawTickMicro := 1000000 div tickSpeed;
  writeln('tickMicro='+inttostr(FRedrawTickMicro));

  setlength(speeds, 0);  }
end;

destructor TFieldCollection.Destroy;
var i: integer;
begin
  for i := Low(FFieldArr) to High(FFieldArr) do
  begin
    if Assigned(FFieldArr[i]) then FreeAndNil(FFieldArr[i]);
  end;

  inherited Destroy;
end;

procedure TFieldCollection.CalculateRedrawTick;
var speeds: array of cardinal;
i, j, k, l: integer;
b: boolean;
minspeed, maxspeed: cardinal;
tickSpeed: cardinal;
begin
  SetLength(speeds, 0);

  minspeed := 10000;
  maxspeed := 0;

  for i := Low(FFieldArr) to High(FFieldArr) do
  begin
    j := FFieldArr[i].TextSpeed;
    //добавляем скорости без повторений
    b := true;
    for k := Low(speeds) to High(speeds) do
      if speeds[k] = j then
      begin
        b := false;
        break;
      end;
    if b = true then
    begin
      k := length(speeds);
      setlength(speeds, k+1);
      speeds[k] := j;
    end;

    if j < minspeed then minspeed := j;
    if j > maxspeed then maxspeed := j;
  end;

  //считаем наименьший общий знаменатель
  j := 1;
  for i := Low(speeds) to High(speeds) do
    j := j * speeds[i];
  if j > 5000 then j := 5000;
  k := j;  //нужный нам наименьший общий знаменатель
  for i := maxspeed to j do
  begin
    //проверяем число
    b := true;
    for l := Low(speeds) to High(speeds) do
      if (i mod speeds[l]) <> 0 then
      begin
        b := false;
        break;
      end;

    if b = true then
    begin
      k := i;
      break;
    end;
  end;

  tickSpeed := k;
  writeln('Minimal FPS='+inttostr(tickSpeed));

  //вычисляем, через сколько микро нужно давать обновление
  FRedrawTickMicro := 1000000 div tickSpeed;
  writeln('tickMicro='+inttostr(FRedrawTickMicro));

  //выставляем вычислинную скорость
  for i := Low(FFieldArr) to High(FFieldArr) do
    //FFieldArr[i].FieldUpdateTickCount := tickSpeed div FFieldArr[i].TextSpeed;
    FFieldArr[i].SetFieldUpdateTickCount(tickSpeed div FFieldArr[i].TextSpeed, FRedrawTickMicro);
end;

procedure TFieldCollection.SetSize(ASize: cardinal);
begin

end;

function TFieldCollection.GetField(AIndex: integer): TTextField;
begin
  Result := FFieldArr[AIndex];
end;

procedure TFieldCollection.AddField(AField: TTextField);
var i: integer;
begin
  i := length(FFieldArr);
  setlength(FFieldArr, i+1);
  //FFieldArr[i] := AField;
  FFieldArr[i] := TTextField.Create(AField.FieldBounds, AField.FontPath, AField.TextSize);
  FFieldArr[i].TextString := AField.TextString;
  FFieldArr[i].TextColor := AField.TextColor;
  FFieldArr[i].TextStyle := AField.TextStyle;
  FFieldArr[i].TextSpeed := AField.TextSpeed;
  FFieldArr[i].TextFieldType := AField.TextFieldType;
  FFieldArr[i].TextHorizontalAlign := AField.TextHorizontalAlign;
  FFieldArr[i].TextVerticalAlign := AField.TextVerticalAlign;
  FFieldArr[i].TextRunningSpace := AField.TextRunningSpace;
  FFieldArr[i].BGColor := AField.BGColor;

  CalculateRedrawTick;
end;

function TFieldCollection.Update(const AElapsedMicrosec: Uint64): boolean;
var b,b1: boolean;
i: integer;
elaps: Uint64;
begin
  result := false;

  FCurrentMicro := FCurrentMicro + AElapsedMicrosec;

  if FCurrentMicro >= FRedrawTickMicro then
  begin
    elaps := FCurrentMicro - (FCurrentMicro - FRedrawTickMicro);
    FCurrentMicro := FCurrentMicro - FRedrawTickMicro;

    b := false;
    for i := Low(FFieldArr) to High(FFieldArr) do
    begin
      b1 := FFieldArr[i].UpdateTick(elaps);

      if b1 = true then
      begin
        b := true;
      end;
      //if (b = true)and(b1 = false) then Writeln('Desync');

      //writeln('Col='+inttostr(j));
    end;
    //if b = false then writeln('false');

    result := b;
  end;


  {b := false;
  for i := Low(FFieldArr) to High(FFieldArr) do
  begin
    b1 := FFieldArr[i].Update(AElapsedMicrosec);
    if b1 = true then b := true;
    if (b = true)and(b1 = false) then Writeln('Desync');
  end;
  result := b;  }
end;

procedure TFieldCollection.Draw(AWindow: TSfmlRenderWindow);
var i: integer;
begin
  for i := Low(FFieldArr) to High(FFieldArr) do
    FFieldArr[i].Draw(AWindow);
end;

end.
