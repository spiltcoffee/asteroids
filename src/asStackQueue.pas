unit asStackQueue;

interface
  uses asTypes, sgTypes;

type
  NodePtr = ^Node;
  Node = record
    data: Point2D;
    next: NodePtr;
    prev: NodePtr;
  end;
  TLinkedList = record
    first: NodePtr;
    last: NodePtr;
  end;

  procedure SetupList(var list: TLinkedList);
  procedure AppendNode(var list: TLinkedList; value: Point2D);
  procedure AppendUniqueNode(var list: TLinkedList; value: Point2D);
  function SpliceNode(var list: TLinkedList; pos: Integer): Point2D;
  procedure DestroyList(var list: TLinkedList);

  function CountNodes(const list: TLinkedList): Integer;
  function GetNodeValue(var list: TLinkedList; pos: Integer): Point2D;

  procedure Enqueue(var queue: TLinkedList; value: Point2D);
  function Dequeue(var list: TLinkedList): Point2D;

  procedure Push(var stack: TLinkedList; value: Point2D);
  function Pop(var list: TLinkedList): Point2D;

implementation
  uses SysUtils;

procedure SetupList(var list: TLinkedList); //only call at the very beginning, as it won't dispose of nodes
begin
  list.first := nil;
  list.last := nil;
end;

procedure DestroyList(var list: TLinkedList);
begin
  while CountNodes(list) > 0 do begin
    Dequeue(list);
  end;
  list.first := nil;
  list.last := nil;
end;

function CountNodes(const list: TLinkedList): Integer;
var
  curNode: NodePtr;
begin
  curNode := list.first;
  result := 0;
  while CurNode <> nil do begin
    curNode := curNode^.next;
    result += 1;
  end;
end;

procedure AppendNode(var list: TLinkedList; value: Point2D);
var
  newNode: NodePtr;
begin
  New(newNode);
  newNode^.data := value;
  newNode^.next := nil;
  newNode^.prev := list.last;

  if list.last <> nil then
    list.last^.next := newNode;
  list.last := newNode;
  if list.first = nil then
    list.first := newNode;
end;

procedure AppendUniqueNode(var list: TLinkedList; value: Point2D);
var
  found: Boolean;
  curNode: NodePtr;
begin
  found := False;
  curNode := list.first;

  while not found and (curNode <> nil) do begin
    if (curNode^.data.x = value.x) and (curNode^.data.y = value.y) then begin
      found := True;
    end;

    curNode := curNode^.next;
  end;

  if not found then begin
    AppendNode(list, value);
  end;
end;

function SpliceNode(var list: TLinkedList; pos: Integer): Point2D;
var
  curNode: NodePtr;
  i: Integer;
begin
  i := 0;
  if (pos < CountNodes(list)) and (pos >= 0) then begin
    curNode := list.first;
    while curNode <> nil do begin
      if i = pos then begin
        result := curNode^.data;

        if curNode^.prev <> nil then begin
          curNode^.prev^.next := curNode^.next;
        end
        else begin
          list.first := curNode^.next;
        end;

        if curNode^.next <> nil then begin
          curNode^.next^.prev := curNode^.prev;
        end
        else begin
          list.last := curNode^.prev;
        end;
        Dispose(curNode);
        curNode := nil;
      end;
      i += 1;
    end;
  end
  else begin
    WriteLn('Invalid List Index ', pos);
  end;
end;

function GetNodeValue(var list: TLinkedList; pos: Integer): Point2D;
var
  curNode: NodePtr;
  i: Integer;
begin
  result.x := 0;
  result.y := 0;
  i := 0;
  if pos < CountNodes(list) then begin
    curNode := list.first;
    while curNode <> nil do begin
      if i = pos then begin
        result := curNode^.data;
        curNode := nil;
      end;
      i += 1;
    end;
  end;
end;

procedure Enqueue(var queue: TLinkedList; value: Point2D);
begin
  AppendNode(queue,value);
end;

function Dequeue(var list: TLinkedList): Point2D;
var
  tempPtr: NodePtr;
begin
  result.x := 0;
  result.y := 0;
  if list.first <> nil then begin
    result := list.first^.data;
    tempPtr := list.first;
    list.first := list.first^.next;
    if (list.first <> nil) and (list.first^.next <> nil) then begin
      list.first^.next^.prev := nil;
    end;
    if list.first = nil then begin
      list.last := nil;
    end;
    Dispose(tempPtr);
  end;
end;

procedure Push(var stack: TLinkedList; value: Point2D);
begin
  AppendNode(stack,value);
end;

function Pop(var list: TLinkedList): Point2D;
var
  tempPtr: NodePtr;
begin
  result.x := 0;
  result.y := 0;
  if list.last <> nil then
  begin
    result := list.last^.data;
    tempPtr := list.last;
    list.last := list.last^.prev;
    if (list.last <> nil) and (list.last^.prev <> nil) then begin
      list.last^.prev^.next := nil;
    end;
    if list.last = nil then begin
      list.first := nil;
    end;
    Dispose(tempPtr);
  end;
end;

end.

//______________________________________________________//
//                                                      //
// SwinGame Asteroids - Copyright SpiltCoffee 2010-2013 //
//______________________________________________________//
