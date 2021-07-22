program CSFML;

{$APPTYPE CONSOLE}

{$I SFML.inc}

{$R *.res}

uses
  FastMM4,
  SysUtils,
  Classes,
  SfmlAudio in 'SFML\Source\SfmlAudio.pas',
  SfmlGraphics in 'SFML\Source\SfmlGraphics.pas',
  SfmlNetwork in 'SFML\Source\SfmlNetwork.pas',
  SfmlSystem in 'SFML\Source\SfmlSystem.pas',
  SfmlWindow in 'SFML\Source\SfmlWindow.pas',
  uFieldBase in 'uFieldBase.pas',
  uTextField in 'uTextField.pas',
  uFieldCollection in 'uFieldCollection.pas',
  Math,
  uGraphicsField in 'uGraphicsField.pas',
  uSerialThread in 'SynSerial\uSerialThread.pas';

var
Window: TSfmlRenderWindow;
Event: TSfmlEvent;
Mode: TSfmlVideoMode;

mainClock: TSfmlClock;
clockElapsed: TSfmlTime;
forceRedrawClock: TSfmlClock;
fpsClock: TSfmlClock;

fpsCounter: int64;
cyclesCounter: int64;
fpsCyclesFont: TSfmlFont;
fpsCyclesText: TSfmlText;
fpsNum: double;
cyclesNum: double;

textField, tf2, tf3, tf4, tf5: TTextField;
textFieldBGColor: TSfmlColor;
fieldsUpdated: boolean;

myfont: TSfmlFont;
mytext: TSfmlText;
//vec: TSfmlVector2f;
coll: TFieldCollection;

RectShape: TSfmlRectangleShape;
//RectImage: TSfmlImage;
RectTexture: TSfmlTexture;

graph: TGraphicsField;

temp: Int64;

begin
  try
    Mode.Width := 1000;
    Mode.Height := 900;
    Mode.BitsPerPixel := 32;

    //Window := TSfmlRenderWindow.Create(Mode, 'SFML Window', [sfResize, sfClose], nil);
    Window := TSfmlRenderWindow.Create(Mode, 'SFML Window', [sfClose], nil);

    tf2 := TTextField.Create(TSfmlFloatRect.Create(100, 100, 100, 100), 'arial.ttf', 20);
    tf2.BGColor := SfmlRed;

    tf3 := TTextField.Create(TSfmlFloatRect.Create(100, 270, 100, 100), 'arial.ttf', 20);
    tf3.BGColor := SfmlRed;

    tf4 := TTextField.Create(TSfmlFloatRect.Create(700, 100, 100, 100), 'arial.ttf', 20);
    tf4.BGColor := SfmlRed;

    tf5 := TTextField.Create(TSfmlFloatRect.Create(700, 270, 100, 100), 'arial.ttf', 20);
    tf5.BGColor := SfmlRed;

    //----------------------------->>>>>>>>  tgifimage, tgifrenderer
    textField := TTextField.Create(TSfmlFloatRect.Create(200, 200, 500, 70), 'arial.ttf', 28);
    //textField.TextFieldType := tfDateTime;
    textField.TextFieldType := tfAlwaysRunning;
    textField.TextString := '"Время "hh%0nn%2ss%T:';
    //textField.TextString := textField.TextString + '656666666666666';
    textField.TextColor := SfmlYellow;
    textFieldBGColor := SfmlBlue;
    textFieldBGColor.A := 100;
    textField.BGColor := textFieldBGColor;
    textField.TextSpeed := 80;
    textField.TextHorizontalAlign := tahcenter;
    textField.TextVerticalAlign := tavCenter;
    //(trsNone, trsSpace, trs3Space, trsRemaining, trs0_5, trs1_0, trs1_5, trs2_0);
    //textField.TextRunningSpace := trsRemaining;

    coll := TFieldCollection.Create(window.Size.X, window.Size.Y, 1, 'arial.ttf');
    coll.AddField(textField);
    coll.AddField(tf2);
    coll.AddField(tf3);
    coll.AddField(tf4);
    coll.AddField(tf5);

    myfont := TSfmlFont.Create('arial.ttf');
    myText := TSfmlText.Create('Test123', myfont);
    myText.CharacterSize := 20;
    myText.FillColor := SfmlWhite;

    RectShape := TSfmlRectangleShape.Create;
    RectShape.Position := TSfmlVector2f.Create(110, 450);
    RectShape.Size := TSfmlVector2f.Create(400, 400);
    //RectShape.FillColor := SfmlTransparent;
    Writeln('Col='+inttostr(RectShape.FillColor.R)+','+inttostr(RectShape.FillColor.g)+','+inttostr(RectShape.FillColor.b)+','+inttostr(RectShape.FillColor.a));
    RectShape.OutlineColor := SfmlGreen;
    RectShape.OutlineThickness := 1;

    //RectImage := TSfmlImage.Create('sans.gif');
    //RectTexture := TSfmlTexture.Create(Floor(RectShape.Size.X), Floor(RectShape.Size.Y));
    //RectTexture.UpdateFromImage(RectImage, 0, 0);
    //RectShape.SetTexture(RectTexture.Handle, false);

    mainClock := TSfmlClock.Create;
    forceRedrawClock := TSfmlClock.Create;
    fpsClock := TSfmlClock.Create;

    fpsCyclesFont := TSfmlFont.Create('arial.ttf');
    fpsCyclesText := TSfmlText.Create('', fpsCyclesFont);
    fpsCyclesText.CharacterSize := 12;
    fpsCyclesText.Color := SfmlWhite;

    graph := TGraphicsField.Create(TSfmlFloatRect.Create(300,80,50,50), gftStaticPicture);
    graph.LoadFromFile('img.jpg');
    //graph.LoadFromFile('test_empty.bmp');
    graph.GraphicsHorizontalAlign := gahStretch;
    graph.GraphicsVerticalAlign := gavStretch;
    graph.DebugMode := true;

    fpsCounter := 0;
    cyclesCounter := 0;

    Window.Clear(SfmlBlack);
    Window.Display;

    while Window.IsOpen = true do
    begin
      inc(cyclesCounter);

      while Window.PollEvent(Event) = true do
      begin
        // Close window : exit
        if Event.EventType = sfEvtClosed then
          Window.Close;

        if Event.EventType = sfEvtKeyPressed then
        begin
          if Event.Key.Code = sfKeyK then
          begin
            writeln('pressed K');
            coll.Fields[1].TextString := '"Test string, time="hh%5:nn%6.ss%7,%T.';
            //coll.CalculateRedrawTick;
            //coll.Fields[0].SetTextString('Test');
          end;
        end;
      end;

      clockElapsed := mainClock.Restart;
      fieldsUpdated := textField.Update(clockElapsed.MicroSeconds);
      //fieldsUpdated := coll.Update(clockElapsed.MicroSeconds);

      if (fieldsUpdated = false)and(forceRedrawClock.ElapsedTime.MicroSeconds < 1000000) then
      begin
        TThread.Yield;
        continue;
      end;

      if forceRedrawClock.ElapsedTime.MicroSeconds >= 1000000 then
      begin
        forceRedrawClock.Restart;
      end;

      inc(fpsCounter);

      //display fps cycles
      if fpsClock.ElapsedTime.MicroSeconds >=1000000 then
      begin
        temp := fpsClock.Restart.MicroSeconds;
        fpsNum := (1000000 / temp) * fpsCounter;
        cyclesNum := (1000000 / temp) * cyclesCounter;
        fpsCyclesText.UnicodeString := 'FPS='+inttostr(floor(fpsNum))+#13+#10+'Cycles='+floattostr(cyclesNum)+#13+#10+'MicroSec='+inttostr(temp);
        fpsCounter := 0;
        cyclesCounter := 0;
      end;

      Window.Clear(SfmlBlack);
      //coll.Draw(Window);
      textField.Draw(Window);
      {tf2.Draw(Window);
      tf3.Draw(Window);
      tf4.Draw(Window);
      tf5.Draw(Window);   }
      //Window.Draw(RectShape);
      //graph.Draw(Window);

      //Window.Draw(mytext);
      //vec := mytext.Origin;
      //vec.Y := vec.Y + 100;
      //mytext.Origin := vec;
      //vec := mytext.Position;
      //vec.Y := vec.Y + 100;
      //mytext.Position := vec;
      //Window.Draw(mytext);

      Window.Draw(fpsCyclesText);
      Window.Display;
    end;

    //cleaning
    if Assigned(textField) then FreeAndNil(textField);
    tf2.Free;
    tf3.Free;
    tf4.Free;
    tf5.Free;
    RectShape.Free;
    //RectImage.Free;
    RectTexture.Free;
    coll.Free;
    mainClock.Free;
    forceRedrawClock.Free;
    fpsClock.Free;
    fpsCyclesText.Free;
    fpsCyclesFont.Free;
    graph.Free;
    Window.Free;

    mytext.Free;
    myfont.Free;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
