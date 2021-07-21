{
    SwinGame Asteroids
    Copyright (C) 2013  SpiltCoffee

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
}

unit asExtras;

interface
  uses asTypes;

  procedure Remove(var array_in: TAsteroidArray; index: integer); overload;
  procedure Remove(var array_in: TBulletArray; index: integer); overload;
  procedure Remove(var array_in: TDebrisArray; index: integer); overload;
  procedure Remove(var array_in: TNoteArray; index: integer); overload;
  procedure Remove(var array_in: TMenuItemArray; index: integer); overload;
  procedure Remove(var array_in: TCollisionArray; index: integer); overload;

implementation

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

  procedure Remove(var array_in: TCollisionArray; index: integer); overload;
  var
    i: integer;
  begin
    for i := index to High(array_in)-1 do
      array_in[i] := array_in[i+1];
    SetLength(array_in,Length(array_in)-1);
  end;

end.
