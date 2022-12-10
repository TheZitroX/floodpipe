{
    file:       UPipeTypeFunctions.pas
    author:     John Lienau
    title:      PipeTypeFunctions unit of project Floodpipe
    version:    v1.0
    date:       03.08.2022
    copyright:  Copyright (c) 2022  

    brief:      This unit contains all the functions that are used to
                handle the pipeTypeList
}

unit UPipeTypeFunctions;

interface

uses UTypedefine;

procedure appendPipeTypeNode(var pipeTypeList: TPipeTypeList;
  pipeTypeNode: PPipeTypeNode);
procedure appendPipeType(var pipeTypeList: TPipeTypeList; cellItem: TCellItem;
  cellRotation: TCellRotation);
procedure delPipeTypeList(var pipeTypeList: TPipeTypeList);
function isPipeTypeListEmpty(pipeTypeList: TPipeTypeList): boolean;
procedure delFirstPipeTypeNode(var pipeTypeList: TPipeTypeList);
procedure getRandomType(pipeTypeList: TPipeTypeList; var cellItem:TCellItem; var cellRotation:TCellRotation);
function pipeTypeListLength(pipeTypeList: TPipeTypeList):integer;

implementation

procedure appendPipeTypeNode(var pipeTypeList: TPipeTypeList;
  pipeTypeNode: PPipeTypeNode);
begin
    if (pipeTypeList.firstNode = nil) then
    begin
        pipeTypeList.firstNode := pipeTypeNode;
        pipeTypeList.lastNode := pipeTypeNode;
    end
    else
    begin
        pipeTypeList.lastNode^.next := pipeTypeNode;
        pipeTypeList.lastNode := pipeTypeNode;
    end;
end;

procedure appendPipeType(var pipeTypeList: TPipeTypeList; cellItem: TCellItem;
  cellRotation: TCellRotation);
var
    pipeTypeNode: PPipeTypeNode;
begin
    new(pipeTypeNode);
    pipeTypeNode.cellItem := cellItem;
    pipeTypeNode.cellRotation := cellRotation;
    pipeTypeNode.next := nil;
    appendPipeTypeNode(pipeTypeList, pipeTypeNode);
end;

procedure delFirstPipeTypeNode(var pipeTypeList: TPipeTypeList);
var
    tempPipeTypeNode: PPipeTypeNode;
begin
    if (pipeTypeList.firstNode <> nil) then
    begin
        tempPipeTypeNode := pipeTypeList.firstNode;
        pipeTypeList.firstNode := pipeTypeList.firstNode^.next;
        dispose(tempPipeTypeNode);
    end;
end;

function isPipeTypeListEmpty(pipeTypeList: TPipeTypeList): boolean;
begin
    isPipeTypeListEmpty := pipeTypeList.firstNode = nil;
end;

procedure delPipeTypeList(var pipeTypeList: TPipeTypeList);
begin
    while (not isPipeTypeListEmpty(pipeTypeList)) do
        delFirstPipeTypeNode(pipeTypeList);
    pipeTypeList.lastNode := nil;
end;

{
    gets a random cellitem- and rotation from pipeTypeList

    @param  IN:     the pipeTypeList
            IN/OUT: cellItem gets a random item in list
                    cellRotation gets a random rotation
}
procedure getRandomType(pipeTypeList: TPipeTypeList; var cellItem:TCellItem; var cellRotation:TCellRotation);
var
    i, listLength:integer;
    pipeTypeListRunner:PPipeTypeNode;
begin
    if (pipeTypeList.firstNode <> nil) then
    begin
        listLength := pipeTypeListLength(pipeTypeList);

        // get random of listlength
        i := random(listLength);
        pipeTypeListRunner := pipeTypeList.firstNode;
        while ((pipeTypeListRunner <> nil) and (i > 0)) do
        begin
            pipeTypeListRunner := pipeTypeListRunner^.next;
            dec(i);
        end;

        cellItem := pipeTypeListrunner^.cellItem;
        cellrotation := pipeTypeListrunner^.cellRotation;
    end;
end;

{
    gets the length of the pipetypeList

    @param  IN:     the pipeetypelist
            RETURN: length of the list
}
function pipeTypeListLength(pipeTypeList: TPipeTypeList):integer;
var
    listLength:integer;
    pipeTypeListRunner:PPipeTypeNode;
begin
    listLength := 0;
    pipeTypeListRunner := pipeTypeList.firstNode;
    while (pipeTypeListRunner <> nil) do
    begin
        inc(listLength);
        pipeTypeListRunner := pipeTypeListRunner^.next;
    end;
    pipeTypeListLength := listLength;
end;
end.
