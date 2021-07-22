unit Unit5;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Unit6, SfmlWindow, SfmlSystem, SfmlGraphics,
  Vcl.StdCtrls, Unit7, uTextField, Unit8;

type
  TForm5 = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Memo1: TMemo;
    Frame81: TFrame8;
    procedure Button1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Frame81Resize(Sender: TObject);
    procedure Frame81MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Frame81MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Frame81MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  TTestThread = class(TThread)
  private
    //FForm: TForm6;
    //FFrame: TFrame7;
    FSFMLWindow: TSfmlRenderWindow;
    FHNDLPointer: TSfmlWindowHandle;
    FHNDL: HWND;

    FViewCenter: TSfmlVector2f;
  public
    constructor Create(ASuspended: boolean; AHNDL: HWND);
    destructor Destroy; override;

    procedure Execute; override;

    procedure MousePressMove(X, Y: integer);
    procedure MousePress;
    //property UsedFrame: TFrame7 read FFrame write FFrame;
  end;

var
  Form5: TForm5;
  thr: TTestThread;
  frame: TFrame7;

procedure Log(mess: string);

implementation

{$R *.dfm}

uses typinfo;

var mousepressed: boolean;
mousepresscoord: TSfmlVector2u;

procedure Log(mess: string);
begin
  form5.Memo1.Lines.Add(mess);
end;

{ TTestThread }

constructor TTestThread.Create(ASuspended: boolean; AHNDL: HWND);
begin
  inherited Create(ASuspended);

  FHNDL := AHNDL;
  FreeOnTerminate := false;
end;

destructor TTestThread.Destroy;
begin
  inherited Destroy;
end;

procedure TTestThread.MousePressMove(X, Y: integer);
var moveVec: TSfmlVector2f;
view: TSfmlView;
begin
  moveVec.X := FViewCenter.X + X;
  moveVec.Y := FViewCenter.Y + Y;
  view := FSFMLWindow.View;
  view.Center := moveVec;
  FSFMLWindow.View := view;
end;

procedure TTestThread.MousePress;
var view: TSfmlView;
begin
  view := FSFMLWindow.View;
  FViewCenter := view.Center;
end;

procedure TTestThread.Execute;
var Event: TSfmlEvent;
sh: TSfmlRectangleShape;
tf, tf2: TTextField;
textFieldBGColor: TSfmlColor;
mainClock: TSfmlClock;
clockElapsed: TSfmlTime;
view: TSfmlView;
vec: TSfmlVector2f;
frect: TSfmlFloatRect;
begin
  {FForm := TForm6.Create(Application);
  FForm.Show;
  FForm.Constraints.MaxWidth := 500;
  FForm.Constraints.MaxHeight := 300;   }
  //FForm.WindowState := wsMaximized;
  //FFrame := TFrame7.Create(nil);
  //FFrame.Parent := Form5.Panel3;

  //FHNDL := FForm.Handle;
  //FHNDL := FFrame.Handle;
  FHNDLPointer := Pointer(FHNDL);
  FSFMLWindow := TSfmlRenderWindow.Create(FHNDLPointer);
  FSFMLWindow.SetFramerateLimit(120);

  sh := TSfmlRectangleShape.Create;
  sh.FillColor := SfmlTransparent;
  sh.Position := TSfmlVector2f.Create(1, 1);
  sh.OutlineColor := SfmlRed;
  sh.OutlineThickness := 1;
  //sh.Size := TSfmlVector2f.Create(100, 100);

  view := FSFMLWindow.View;
  vec := view.Size;
  vec.X := vec.X - 2;
  vec.Y := vec.Y - 2;
  sh.Size := vec;
  //view.Zoom(0.5);
  vec.X := -150;
  vec.Y := 0;
  //view.Move(vec);
  vec := view.Size;
  Log('Size='+floattostr(vec.X)+','+floattostr(vec.Y));
  vec := view.Center;
  FViewCenter := vec;
  Log('Center='+floattostr(vec.X)+','+floattostr(vec.Y));
  frect := view.Viewport;
  Log('Viewport='+floattostr(frect.Left)+','+floattostr(frect.Top)+','+floattostr(frect.Width)+','+floattostr(frect.Height));
  FSFMLWindow.View := view;

  tf := TTextField.Create(TSfmlFloatRect.Create(10, 250, 300, 50),'H:\RADStudioProjects\Evgeny\CSFML_test3\Win32\Debug\arial.ttf',30);
  tf.TextFieldType := tfDateTime;
  tf.TextString := '"Время "hh%0nn%2ss%T:';
  //textField.TextString := textField.TextString + '656666666666666';
  tf.TextColor := SfmlYellow;
  textFieldBGColor := SfmlBlue;
  textFieldBGColor.A := 100;
  tf.BGColor := textFieldBGColor;
  tf.TextSpeed := 80;
  tf.TextHorizontalAlign := tahcenter;
  tf.TextVerticalAlign := tavCenter;
  tf.DebugMode := true;

  tf2 := TTextField.Create(TSfmlFloatRect.Create(10, 320, 300, 50),'H:\RADStudioProjects\Evgeny\CSFML_test3\Win32\Debug\arial.ttf',30);
  tf2.TextFieldType := tfAlwaysRunning;
  tf2.TextString := 'Test string Привет';
  tf2.TextColor := SfmlWhite;
  tf2.BGColor := SfmlBlack;
  tf2.TextSpeed := 80;
  tf2.DebugMode := true;

  mainClock := TSfmlClock.Create;

  while (FSFMLWindow.IsOpen = true)and(Terminated = false) do
  begin
    while FSFMLWindow.PollEvent(Event) = true do
    begin
      // Close window : exit
      if Event.EventType = sfEvtClosed then FSFMLWindow.Close;

      if Event.EventType = sfEvtKeyPressed then
      begin
        if Event.Key.Code = sfKeyLeft then
        begin
          view := FSFMLWindow.View;
          view.Move(TSfmlVector2f.Create(-10, 0));
          FSFMLWindow.View := view;
        end;
      end;
    end;

    clockElapsed := mainClock.Restart;
    tf.Update(clockElapsed.MicroSeconds);
    tf2.Update(clockElapsed.MicroSeconds);

    //Application.ProcessMessages;
    //Application.HandleMessage;
    FSFMLWindow.Clear(SfmlBlack);
    tf.Draw(FSFMLWindow);
    tf2.Draw(FSFMLWindow);
    FSFMLWindow.Draw(sh);
    FSFMLWindow.Display;
  end;

  tf.Free;
  tf2.Free;
  sh.Free;
  mainClock.Free;
  FSFMLWindow.Close;
  FSFMLWindow.Free;
  //FForm.Free;
  //FFrame.Free;
end;

procedure TForm5.Button1Click(Sender: TObject);
begin
  Log('Frame size='+inttostr(form5.Frame81.Width)+','+inttostr(form5.Frame81.Height));
  thr := TTestThread.Create(false, form5.Frame81.Handle);
end;

procedure TForm5.Button2Click(Sender: TObject);
begin
  frame := TFrame7.Create(Self);
  frame.Parent := Form5;
  frame.Visible := true;

  frame.Align := alNone;
  frame.Left := 10;
  //frame.Show;
end;

procedure TForm5.Button3Click(Sender: TObject);
begin
  if Assigned(thr) then
  begin
    //thr.UsedFrame.Width := thr.UsedFrame.Width - 50;
    form5.Frame81.Width := form5.Frame81.Width -50;
  end;
end;

procedure TForm5.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Assigned(thr) then
  begin
    thr.Terminate;
    thr.WaitFor;
    thr.Free;
  end;

  CanClose := true;
end;

procedure TForm5.FormCreate(Sender: TObject);
begin
  mousepressed := false;
end;

procedure TForm5.Frame81MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Frame81.FrameMouseDown(Sender, Button, Shift, X, Y);

  if Button = mbLeft then
  begin
    mousepressed := true;
    mousepresscoord.X := x;
    mousepresscoord.Y := y;
    if assigned(thr) then thr.MousePress;
  end;
end;

procedure TForm5.Frame81MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var mx, my: integer;
begin
  //Log('OnMouseMove , Coord='+inttostr(x)+','+inttostr(y));
  if mousepressed = true then
  begin
    mx := mousepresscoord.X - X;
    my := mousepresscoord.Y - Y;
    //Log('Moved by '+inttostr(mx)+','+inttostr(my));
    if Assigned(thr) then
    begin
      thr.MousePressMove(mx, my);
    end;
  end;
end;

procedure TForm5.Frame81MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Log('OnMouseUp, Coord='+inttostr(x)+','+inttostr(y));
  mousepressed := false;
end;

procedure TForm5.Frame81Resize(Sender: TObject);
begin
  Frame81.FrameResize(Sender);

end;

end.
