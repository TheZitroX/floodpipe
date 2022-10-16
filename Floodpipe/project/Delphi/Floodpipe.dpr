program Floodpipe;

uses
  Vcl.Forms,
  UMain in 'UMain.pas' {FMain},
  USettings in 'USettings.pas' {FSettings};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TFMain, FMain);
  Application.CreateForm(TFSettings, FSettings);
  Application.Run;
end.
