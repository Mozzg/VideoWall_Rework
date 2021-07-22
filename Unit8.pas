unit Unit8;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TFrame8 = class(TFrame)
    procedure FrameMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FrameResize(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses Unit5, TypInfo;

procedure TFrame8.FrameMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  Log('MouseDownFrame Button='+GetEnumName(System.TypeInfo(TMouseButton),ord(Button))+' Coord='+inttostr(x)+','+inttostr(y));
end;

procedure TFrame8.FrameResize(Sender: TObject);
begin
  Log('Frame resize event');
end;

end.
