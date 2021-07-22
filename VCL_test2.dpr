program VCL_test2;

uses
  FastMM4,
  Vcl.Forms,
  Unit5 in 'Unit5.pas' {Form5},
  Unit6 in 'Unit6.pas' {Form6},
  Unit7 in 'Unit7.pas' {Frame7: TFrame},
  Unit8 in 'Unit8.pas' {Frame8: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm5, Form5);
  Application.Run;
end.
