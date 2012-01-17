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