unit USettings;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.NumberBox;

type
  TFSettings = class(TForm)
    nbColumns: TNumberBox;
    nbRows: TNumberBox;
    nbWallPercentage: TNumberBox;
    nbAnimationTime: TNumberBox;
    cbOverflow: TCheckBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FSettings: TFSettings;

implementation

{$R *.dfm}

end.
