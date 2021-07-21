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

unit asNotes;

interface
  uses sgTypes, asTypes;

  procedure CreateNote(var notes: TNoteArray; text: String; pos: Point2D; vel: Vector; col: Color);

  procedure CreateScore(var notes: TNoteArray; score: Integer; const asteroid: TAsteroid); overload;
  procedure CreateScore(var notes: TNoteArray; score: Integer; const enemy: TShip); overload;

  procedure MoveNote(var note: TNote);

  procedure DrawNote(const note: TNote);

implementation
  uses sgCore, sgGeometry, sgText, asConstants, asOffscreen, Sysutils;

  procedure CreateNote(var notes: TNoteArray; text: String; pos: Point2D; vel: Vector; col: Color);
  var
    new: Integer;
  begin
    SetLength(notes,Length(notes) + 1);
    new := High(notes);
    notes[new].text := text;
    notes[new].pos := pos;
    notes[new].pos.x -= TextWidth(FontNamed('smallFont'),notes[new].text) / 2;
    notes[new].pos.y -= TextHeight(FontNamed('smallFont'),notes[new].text) / 2;
    notes[new].vel := vel;
    notes[new].life := NOTE_LIFE;
    notes[new].col := col;
  end;

  procedure CreateScore(var notes: TNoteArray; score: Integer; const asteroid: TAsteroid); overload;
  begin
    CreateNote(notes,IntToStr(score),asteroid.pos,asteroid.vel + VectorFromAngle(270,2),ColorWhite);
  end;

  procedure CreateScore(var notes: TNoteArray; score: Integer; const enemy: TShip); overload;
  begin
    CreateNote(notes,IntToStr(score),enemy.pos,enemy.vel + VectorFromAngle(270,2),ColorWhite);
  end;

  procedure MoveNote(var note: TNote);
  begin
    note.pos += note.vel;
    WrapPosition(note.pos);

    note.life -= 1;
  end;

  procedure DrawNote(const note: TNote);
  begin
    if note.life > 0 then
      DrawText(note.text,note.col - (($00010101 and note.col )* Trunc((1 - note.life / NOTE_LIFE) * 255)),FontNamed('smallFont'),note.pos);
  end;

end.
