{
    file:       UFunctions.pas
    author:     John Lienau
    title:      Floodpipe functions
    version:    v1.0
    date:       30.07.2022
    copyright:  Copyright (c) 2022

    brief:      Mostly used functions by the main unit of Floodpipe
}

unit UFunctions;

    interface

    uses 
        vcl.Forms, sysutils, vcl.extctrls, vcl.controls;

    // public functions
    procedure panelSetup(var panel:TPanel; panelParent:TWinControl; panelName:string);

    implementation

        {
            setup for the panel
            parent and name to variables
            and the caption to empty

            @param  panel the target
                    panelParent the parent of target panel
                    parentName the name of the target panel
        }
        procedure panelSetup(var panel:TPanel; panelParent:TWinControl; panelName:string);
        begin
            panel := TPanel.Create(panelParent);
            with panel do
            begin
                Parent := panelParent;
                Name := panelName;
                caption := '';
            end;
        end;

    end.