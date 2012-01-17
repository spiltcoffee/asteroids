//
//just some extra crap
//

//Min and Max

function Min(a, b: Integer): Integer; overload;
begin
  if (a < b) then
    result := a
  else
    result := b;
end;

function Min(a, b: Double): Double; overload;
begin
  if (a < b) then
    result := a
  else
    result := b;
end;

function Max(a, b: Integer): Integer; overload;
begin
  if (a > b) then
    result := a
  else
    result := b;
end;

function Max(a, b: Double): Double; overload;
begin
  if (a > b) then
    result := a
  else
    result := b;
end;

//some specific Remove array procedures

procedure Remove(var array_in: TAsteroidArray; index: integer); overload;
var
  i: integer;
begin
  for i := index to High(array_in)-1 do
    array_in[i] := array_in[i+1];
  SetLength(array_in,Length(array_in)-1);
end;

procedure Remove(var array_in: TBulletArray; index: integer); overload;
var
  i: integer;
begin
  for i := index to High(array_in)-1 do
    array_in[i] := array_in[i+1];
  SetLength(array_in,Length(array_in)-1);
end;

procedure Remove(var array_in: TDebrisArray; index: integer); overload;
var
  i: integer;
begin
  for i := index to High(array_in)-1 do
    array_in[i] := array_in[i+1];
  SetLength(array_in,Length(array_in)-1);
end;

procedure Remove(var array_in: TNoteArray; index: integer); overload;
var
  i: integer;
begin
  for i := index to High(array_in)-1 do
    array_in[i] := array_in[i+1];
  SetLength(array_in,Length(array_in)-1);
end;

procedure Remove(var array_in: TMenuItemArray; index: integer); overload;
var
  i: integer;
begin
  for i := index to High(array_in)-1 do
    array_in[i] := array_in[i+1];
  SetLength(array_in,Length(array_in)-1);
end;