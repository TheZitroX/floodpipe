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
    procedure panelRedraw(
        mainWidth, mainHeight:integer;
        var panelGameArea:TPanel;
        var panelGamefield:TPanel;
        var panelRightSideArea:TPanel;
        var panelRightSideInfo:TPanel;
        var panelButtons:TPanel);

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
                // caption := '';
                caption := panelName;
            end;
        end;

        {
            Gives each panel its position and size,
            relativ to the width and height of the FMain size

            @param  mainWidth: width of FMain
                    mainHeight: newHeight of FMain
                    var panelGameArea: the Gamearea panel
        }
        procedure panelRedraw(
            mainWidth, mainHeight:integer;
            var panelGameArea:TPanel;
            var panelGamefield:TPanel;
            var panelRightSideArea:TPanel;
            var panelRightSideInfo:TPanel;
            var panelButtons:TPanel);

            procedure setDimentions(
                var panel:TPanel;
                newTop, newLeft, newWidth, newHeight:integer);
            begin
                with panel do
                begin
                    Top := newTop;
                    Left := newLeft;
                    Width := newWidth;
                    Height := newHeight;
                end;
            end;

            var
                tempHeight:integer;
        begin
            // panelGameArea
            setDimentions(
                panelGameArea,
                0, 0, // pos(0, 0)
                (mainWidth * 80) div 100, // 80% of the Width
                mainHeight
            );
            // panelGamefield
            tempHeight := (mainHeight * 80) div 100; // 80% of Height
            setDimentions(
                panelGamefield,
                panelGameArea.Height - tempHeight, // height of panelGamearea - height of panelGamefield
                (panelGameArea.Width - tempHeight) div 2, // (width of panelGamearea - height of panelGamefield) / 2
                tempHeight,
                tempHeight
            );
            // panelRightSideArea
            setDimentions(
                panelRightSideArea,
                0, // top of FMain
                (mainWidth * 80) div 100, // 80% of the Width
                (mainWidth * 20) div 100, // 20% of the Width
                mainHeight
            );
            // panelRightSideInfo
            setDimentions(
                panelRightSideInfo,
                0, // top of FMain
                0, // 80% of the Width
                panelRightSideArea.Width,
                (panelRightSideArea.Height * 33) div 100 // 33% height of panelRightSideArea
            );
            // panelRightSideInfo
            setDimentions(
                panelButtons,
                (panelRightSideArea.Height * 33) div 100, // 33% height of panelRightSideArea
                0,
                panelRightSideArea.Width,
                (panelRightSideArea.Height * 67) div 100 // 67% height of panelRightSideArea
            );
        end;

    end.