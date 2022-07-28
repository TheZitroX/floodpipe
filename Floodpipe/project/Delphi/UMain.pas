{
    file:       UMain.pas
    author:     John Lienau
    title:      Main unit of project Floodpipe
    version:    v1.0
    date:       28.07.2022
    copyright:  Copyright (c) 2022

    brief:      Main implementations of all units of the project Floodpipe
}

unit UMain;

interface

uses
	Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
	Vcl.Controls, Vcl.Forms, Vcl.Dialogs,

	UProperties;

type
	TFMain = class(TForm)
		procedure FormCanResize(Sender: TObject; var NewWidth,
			NewHeight: Integer; var Resize: Boolean);
		//procedure WMSizing(var Message: TMessage);
	private
		{ Private-Deklarationen }
	public
		{ Public-Deklarationen }
        // todo create lable
	end;

var
	FMain: TFMain;

implementation

{$R *.dfm}

{
    On Resize the aspect ratio will be maintained

    Sender: not used
    var NewWidth: used to get the Width
    var NewHeight: changed the height of the form
}
procedure TFMain.FormCanResize(
    Sender: TObject;
    var NewWidth, NewHeight: Integer;
    var Resize: Boolean);
begin
    NewHeight:=round(MAIN_FORM_ASPECT_RATIO * NewWidth);
end;

end.