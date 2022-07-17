{
  file:			UMain.pas
  title:		Crosswise
  author:		John Lienau (yourmom@ctemplar.com)
  version:		1.0
  date:			09.06.2022
  copyright:	Copyright (c) 2022

  brief:		This is the main-unit of the Delphi-Project Crosswise.
                It generates the mainform with the logic of the game.

                Constants and types are defined in the units of UMainTypeDefine and UProperties.
                Also mostly used function are seperated to the unit UMainFuctions.
}

// todo gamelogic
// todo highlight selected item in inventory with a red rectangle
// todo filehandler - create, read, write, (save optinons etc.)
// todo settings showmodal erstellen

// optimize inventory field design?

UNIT UMAIN;

    interface

        uses
            Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
            System.Classes, Vcl.Graphics,
            Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
            PNGImage, MMSystem, System.UITypes,

            UProperties, UMainTypeDefine, UMainFunctions, UFileHandler, UPixelFunctions, UGameLogic;

        type
            TMainForm = class(TForm)
                    // panel
                    mainGamePanel:TPanel;
                    infoPanel:TPanel;
                    aktionenPanel:TPanel;
                    playAreaPanel:TPanel;
                    optionButtonsPanel:TPanel;
                    gamefieldPanel:TPanel;
                    copyrightLabel:TLabel;

                    procedure FormCreate(Sender:TObject);
                    // procedure fieldClick(Sender: TObject);
                    procedure fieldClick(Sender:TObject; Button:TMouseButton; Shift:TShiftState; mouseX, mouseY:Integer);
                    procedure optionButtonNewGameOnClick(Sender:TObject);
                    procedure optionButtonLoadGameOnClick(Sender:TObject);
                    procedure optionButtonQuitOnClick(Sender:TObject);
                    procedure optionButtonSaveGameOnClick(Sender: TObject);
                    procedure gamefieldPanelClick(Sender: TObject);
                    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
                end;

        var
            MainForm:TMainForm;

            // infoPanel text
            pointCounterLabel:TLabel;
            
            gamefields:TGamefields;

            // players physical inventory
            playerfields:TPlayerfields;
            itemBitmapList:TImageList;
            // players nametags
            playerNameTagList:TStaticNameTagList;

            // just a simple game background
            gamefieldPanelBackground:TImage;

            // optionButtons
            optionButtonNewGame:TButton;
            optionButtonLoadGame:TButton;
            optionButtonSaveGame:TButton;
            optionButtonQuitGame:TButton;

            // gamevariable
            playerCount:integer;
            selectedItem:TSelectedItem;
            playerList:TPlayerList;
            playersTurn:TPlayersTurn;
            gamefieldList:TGamefileGamefieldList;


    implementation

        {$R *.dfm}

        {
            @brief when x button is pressed, the user is asked if he wants to close the game or keep playing

            @param Sender as TObject not used
                    CanClose as Boolean, changed to true, the game will close after
        }
        procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
            begin
                if MessageDlg('Close the Game?', mtConfirmation, [mbOk, mbCancel], 0) = mrCancel then
                    CanClose := False;
            end;


        {
            @brief if the user checkmarked items and clicks on the gamefieldPanel then
                all checkmarked gamefields clear

            @param Sender as TObject not used
        }
        procedure TMainForm.gamefieldPanelClick(Sender: TObject);
            begin
                // todo when fields are highlighted then remove highlight and reset them
                showmessage('hello World');
            end;

        {
            @brief  when called, the game will close with a bye massage

            @param  Sender as TObject not used
        }
        procedure TMainForm.optionButtonQuitOnClick(Sender: TObject);
            begin
                if MessageDlg('Close the Game?', mtConfirmation, [mbOk, mbCancel], 0) = mrOk then
                    Application.Terminate();
            end;

        procedure TMainForm.optionButtonSaveGameOnClick(Sender: TObject);
            var
                saveDialog:TSaveDialog;
                filename:String;

            begin
                saveDialog := TSaveDialog.Create(MainForm);
                with saveDialog do
                    begin
                        // GAME_FILE_TYPE is to show just the crosswise data and folders
                        Filter := '|*' + GAME_FILE_TYPE;
                        // to start showing the gameSaves folder
                        InitialDir := GetCurrentDir() + GAME_FILE_DEFAULT_DIR;
                    end;

                if saveDialog.Execute then
                    begin
                        filename := saveDialog.FileName;
                        // when user did not specify the ending of filename the ending is added
                        if not filename.endswith(GAME_FILE_TYPE) then
                            filename := concat(filename, GAME_FILE_TYPE);

                        // todo when file exists, ask the user to overwrite it
                        if fileexists(filename) then
                            showmessage('This File exists already!')
                        // write the file if not already existing
                        else
                            begin
                                if writeVariablesToGameSave(filename, gamefieldList, playerList, playersTurn, playerCount) then
                                    showmessage('Count not save the game!')
                                else showmessage('Game has been saved.');
                            end;
                    end;
                saveDialog.free();
            end;

        {
            @brief  when called, a new game will start after confirmation of the user

            @param  Sender as TObject not used
        }
        procedure TMainForm.optionButtonNewGameOnClick(Sender: TObject);
            begin
                // todo settings menu 
            
                playersTurn := PLAYER_ONE;
            end;

        {
            @brief  when called, the user has to select a file, 
                    he is forced to take a GAME_FILE_TYPE file type.
                    when canceled, the game continius to play.

                    if the file does not exist or is currupted,
                    a message with the problem will be displayed.

            @param  Sender as TObject not used
        }
        procedure TMainForm.optionButtonLoadGameOnClick(Sender: TObject);
            var
                openDialog:TOpenDialog;

            begin
                openDialog := TOpenDialog.Create(MainForm);
                with openDialog do
                    begin
                        // GAME_FILE_TYPE is to show just the crosswise data and folders
                        Filter := '|*' + GAME_FILE_TYPE;
                        // to start showing the gameSaves folder
                        InitialDir := GetCurrentDir() + GAME_FILE_DEFAULT_DIR;
                    end;

                if openDialog.Execute then
                    begin
                        // for the case, that the user messed up to select an existing file
                        if not fileexists(openDialog.FileName) then
                            showmessage('Selected File does not exist!')
                        // when its not read, tell the user it failed to read
                        else if not readGameSaveToVariables(openDialog.FileName, gamefieldList, playerList, playersTurn, playerCount) then
                            showmessage('Error: Could not read from file')
                        // set variables to game
                        else 
                            begin
                                setGamefieldsStateFromGamefieldList(gamefields, gamefieldList);
                                setPlayerInventoryFromPlayerList(playerfields, playerList);
                                setPlayerCaptionFromPlayerList(playerNameTagList, playerList);
                                // todo set gamestates to playing

                                checkGamefield(gamefields, playerList);
                                
                                playSound(SOUND_GAME_START, 0, SND_ASYNC);
                            end;
                    end;
                openDialog.free();
            end;

        {
            @brief  This procedure is called by a OnMouseDown function,
                    it needs the parameter, but aint used

                    when called, a fieldType-check is performt (gamefield or itemfield)
                    the itemfield, in inventory, will get selected.

                    the gamefield (when an item was selected) will perform the procedure
                    of the selected item (when something was selected).

                    If a stone on the gamefield is changed there will be a stats-update

            @param  Sender as TObject
                    Button as TMouseButton
                    Shift as TShiftState
                    mouseX, mouseY as Integer
                    -> none of these is used in this procedure
        }
        procedure TMainForm.fieldClick(Sender:TObject; Button:TMouseButton; Shift:TShiftState; mouseX, mouseY:Integer);
            var
                gamefield:TGamefield;
                playerInventory, itemField:integer;

            begin
                gamefield := TGamefield(Sender);

                // to split up into gamefield or playerInventory
                if(isGamefieldType(gamefield)) then
                    begin
                        // todo other sounds
                        playSound(SOUND_MOVE, 0, SND_ASYNC);

                        // todo set to selected item
                        setGamefieldNameStatus(gamefield, integer(TItemEnum(FIELD_BLUE)));
                        setGamefieldImageToNameState(gamefield);

                        checkGamefield(gamefields, playerList);
                    end
                else
                    begin
                        playerInventory := getXFromGamefieldName(gamefield.name);
                        itemField := getYFromGamefieldName(gamefield.name);
                        showmessage('hello world from inventory @' + inttostr(playerInventory) + inttostr(itemField));
                    end;
            end;

        {
            @brief  Once called at the application start,
                    it creates all in the game needed fields, buttons ect.

                    it sets a default gamestate of not playing and starts with a
                    idle gamefieldlayout //todo idle gamefieldlayout

            @param  Sender as TObject -> not used
        }
        procedure TMainForm.FormCreate(Sender: TObject);
            procedure createPlayAreaPanel();
                begin
                    playAreaPanel.Top := (gamefieldPanel.Height div 2) - (playAreaPanel.Height div 2) + PANEL_OFFSET;
                    playAreaPanel.Left := (gamefieldPanel.Width div 2) - (playAreaPanel.Width div 2) + PANEL_OFFSET;
                    playAreaPanel.Caption := '';
                    playAreaPanel.Visible := true;
                    playAreaPanel.Enabled := true;
                end;
            
            // Creating GAMEFIELD_COLUMNS^2 fields
            procedure createGamefields();
                procedure setRandomTile(gamefield:TGamefield);
                    var
                        i:integer;
                    
                    begin
                        i := random(6) + 1;
                        setGamefieldNameStatus(gamefield, i);
                        setGamefieldImageToNameState(gamefield);
                    end;
                var
                    i, j:integer;

                begin
                    for i := 0 to GAMEFIELD_COLUMNS - 1 do
                        for j := 0 to GAMEFIELD_COLUMNS - 1 do
                            begin
                                gamefields[i, j] := TGamefield.Create(MainForm);
                                with gamefields[i, j] do
                                    begin
                                        Parent := playAreaPanel;
                                        Name := 'c' + inttostr(integer(FIELD_EMTY)) + 'x' + intToStr(i) + 'y' + intToStr(j);
                                        Top := i * RACTANGLE_WIDTH + PANEL_OFFSET;
                                        Left := j * RACTANGLE_WIDTH + PANEL_OFFSET;
                                        Width := RACTANGLE_WIDTH;
                                        Height := RACTANGLE_WIDTH;
                                        OnMouseDown := fieldClick;
                                        stretch := true;
                                    end;

                                setRandomTile(gamefields[i, j]);
                            end;
                end;

            procedure createPlayerfieldsAndTags();
                // todo bring moveplayerfields horizontally and vertically as one function together!
                procedure placePlayerfieldsHorizontally(i:integer);
                    var
                        j, plusGamefield, directionOffset:integer;

                    begin
                        if(i = 0) then
                            begin
                                plusGamefield := 1;
                                directionOffset := 1
                            end
                        else
                            begin
                                plusGamefield := 0;
                                directionOffset := -1;
                            end;

                        for j := 0 to PLAYER_PANEL_COUNT - 1 do
                            begin
                                // dont question this calculations. it works, i promiss.
                                playerfields[i, j].Top := playAreaPanel.Top + (GAMEFIELD_WIDTH * plusGamefield) + (PLAYER_PANEL_OFFSET * directionOffset) + (RACTANGLE_WIDTH * (plusGamefield - 1));
                                playerfields[i, j].Left := playAreaPanel.Left + (GAMEFIELD_WIDTH div 2) - (RACTANGLE_WIDTH * 2) + (RACTANGLE_WIDTH * j);
                            end;

                        // place the playerTag in the middle
                        with playerNameTagList[i] do
                            begin
                                Top := playerfields[i, 0].Top + PLAYER_NAMETAG_TOP_OFFSET;
                                Left := playerfields[i, 0].Left;
                            end;
                    end;

                procedure placePlayerfieldsVertically(i:integer);
                    var
                        j, plusGamefield, directionOffset:integer;

                    begin
                        if(i = 3) then
                            begin
                                plusGamefield := 1;
                                directionOffset := 1
                            end
                        else
                            begin
                                plusGamefield := 0;
                                directionOffset := -1;
                            end;
                        
                        for j := 0 to PLAYER_PANEL_COUNT - 1 do
                            begin
                                playerfields[i, j].Top := playAreaPanel.Top + (GAMEFIELD_WIDTH div 2) - (RACTANGLE_WIDTH * 2) + (RACTANGLE_WIDTH * j);
                                playerfields[i, j].Left := playAreaPanel.Left + (GAMEFIELD_WIDTH * plusGamefield) + ((PLAYER_PANEL_OFFSET + PLAYER_PANEL_VERTICAL_EXTRA_OFFSET) * directionOffset) + (RACTANGLE_WIDTH * (plusGamefield - 1));
                            end;

                        // optimize 4th tag should be in right-to-left and positioned bit to the right
                        // place the playerTag in the middle
                        with playerNameTagList[i] do
                            begin
                                Top := playerfields[i, 0].Top + PLAYER_NAMETAG_TOP_OFFSET;
                                Left := playerfields[i, 0].Left;
                            end;
                    end;
                    
                var
                    i, j:integer;

                begin
                    // to create the playertag- and inventory
                    for i := 0 to PLAYER_COUNT_MAX - 1 do
                        begin
                            playerNameTagList[i] := TStaticText.Create(MainForm);
                            with playerNameTagList[i] do
                                begin
                                    Parent := gamefieldPanel;
                                    Name := 'playerNameTag' + intToStr(i);

                                    // textsettings
                                    BorderStyle := sbsSingle;
                                    Alignment := taCenter;
                                    Font.Style := Font.Style + [TFontStyle.fsBold];
                                    Caption := PLAYER_NAMETAG_NAME_PREFIX + inttostr(i + 1);
                                end;

                            for j := 0 to PLAYER_PANEL_COUNT - 1 do
                                begin
                                    playerfields[i, j] := TGamefield.Create(MainForm);
                                    with playerfields[i, j] do
                                        begin
                                            Parent := gamefieldPanel;
                                            Name := 'x' + intToStr(i) + 'y' + intToStr(j);
                                            Width := RACTANGLE_WIDTH;
                                            Height := RACTANGLE_WIDTH;
                                            OnMouseDown := fieldClick;
                                            Picture.LoadFromFile(TILE_PLAYERFIELD_EMTY);
                                        end;
                                end;
                            
                            // to separate the playerfields horizontally and vertically
                            if(i mod 2 = 0) then
                                placePlayerfieldsHorizontally(i)
                            else
                                placePlayerfieldsVertically(i);

                            // set inventory
                            playerList[i].isAI := false;
                            for j := 0 to INVENTORY_MAX - 1 do
                                begin
                                    playerList[i].inventory[j] := TItemEnum(j + 1);
                                    setPictureFromItem(playerfields[i, j], playerList[i].inventory[j]);
                                end;
                        end;
                end;

            procedure createBackgroundImage();
                begin
                    gamefieldPanelBackground := TImage.Create(MainForm);
                    with gamefieldPanelBackground do
                        begin
                            Parent := gamefieldPanel;
                            Align := alClient;
                            Width := gamefieldPanel.Width - PANEL_OFFSET;
                            Picture.LoadFromFile(GAMEFIELD_BACKGROUND);
                            stretch := true;
                            Onclick := gamefieldPanelClick;
                        end;
                end;

            {
                @brief  Creates 4 Buttons with spacing on MainForm
                        Parent is optionButtonsPanel
            }
            procedure createOptionButtons();
                var
                    i, topPosition, leftPosition:integer;

                {
                    @brief  Creates a Button with passed positions, names and onclick fucntioncall

                    @param  button as the Changed button
                            topPos and leftPos as integer
                            buttonName, buttonCaption as string
                            functionPointer as TNotifyEvent
                }
                procedure createOptionButton(var button:TButton; topPos, leftPos:integer; buttonName, buttonCaption:string; functionPointer:TNotifyEvent);
                    begin
                        button := TButton.Create(MainForm);
                        with button do
                            begin
                                Top := topPos;
                                Left := leftPos;
                                Width := OPTION_BUTTON_WIDTH;
                                Height := OPTION_BUTTON_HEIGHT;
                                Parent := optionButtonsPanel;
                                Name := buttonName;
                                Caption := buttonCaption;
                                OnClick := functionPointer;
                            end;
                    end;

                begin
                    // leftPosition is calculated to get the buttons in the center of optionButtonsPanel
                    leftPosition := (optionButtonsPanel.Width div 2) - (OPTION_BUTTON_WIDTH div 2);
                    // for the spacing on topPosition
                    for i := 0 to 3 do
                        begin
                            // topPosition is calculated to get the buttonspacing
                            topPosition := (OPTION_BUTTON_HEIGHT div 3) * (i + 1) + (OPTION_BUTTON_HEIGHT * i);
                            case i of
                                0: createOptionButton(optionButtonNewGame, topPosition, leftPosition, 'optionButtonNewGame', 'New', nil);
                                1: createOptionButton(optionButtonLoadGame, topPosition, leftPosition, 'optionButtonCreateLoadGame', 'Load', optionButtonLoadGameOnClick);
                                2: createOptionButton(optionButtonSaveGame, topPosition, leftPosition, 'optionButtonCreateSaveGame', 'Save', optionButtonSaveGameOnClick);
                                3: createOptionButton(optionButtonQuitGame, topPosition, leftPosition, 'optionButtonCreateQuitGame', 'Quit', optionButtonQuitOnClick);
                            end;
                        end;
                end;

            procedure createAktionPanel();
                begin
                    pointCounterLabel := TLabel.Create(MainForm);
                    with pointCounterLabel do
                        begin
                            Parent := aktionenPanel;
                            Name := 'pointCounterLabel';
                            Caption := 'Hello World!';
                            Align := alTop;
                        end;
                end;
            
            begin
                createPlayAreaPanel();
                createBackgroundImage();
                createGamefields();
                createPlayerfieldsAndTags();
                createOptionButtons();
                createAktionPanel();
            end;
end.
