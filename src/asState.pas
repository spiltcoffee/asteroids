unit asState;

interface
  uses asTypes;

  function NeedMoreAsteroids(const score: Integer; const asteroids: TAsteroidArray): Boolean;

  procedure SetupState(var state: TState);

  procedure UpdateState(var state: TState; const player: TShip; var notes: TNoteArray);

  procedure DrawState(const state: TState; const ship1, ship2: TShip);

implementation
  uses sgCore, sgGeometry, sgGraphics, sgText, sgTypes, asConstants, asDraw, asNotes, SysUtils, Math, asInfluenceMap;

  function GetTargetAsteroidCount(const score: Integer): Integer;
  begin
	result := Min(Trunc(score / (STATE_ASTEROID_SCORE_INTERVAL)) + ASTEROID_MINCOUNT, ASTEROID_MAXCOUNT);
  end;

  function NeedMoreAsteroids(const score: Integer; const asteroids: TAsteroidArray): Boolean;
  begin
    result := Length(asteroids) < GetTargetAsteroidCount(score);
  end;

  procedure SetupState(var state: TState);
  begin
    with state do
    begin
      playing := false;
      paused := false;
      quit := false;
      score := 0;
      readingtext := false;
      name := '';
      submitscore := true;
      lives := 3;
      next := PLAYER_LIFE_INTERVAL; //next life
      enemylives := 0;
      enemynext := ENEMY_SPAWN_INTERVAL;
      pos.x := 20;
      pos.y := 35;
      transition := NoFade;
      time := 0;
      perform := NoCommand;
      debug := False;
    end;
  end;

  procedure UpdateState(var state: TState; const player: TShip; var notes: TNoteArray); //for pos, In MoveGame()
  begin
    //if (PointPointDistance(state.pos,player.pos) < STATE_PLAYERMOVEDIST) then
    //begin
    //  if player.pos.y < (ScreenHeight() / 2) then
    //    state.pos.y := ScreenHeight() - 35
    //  else
    //    state.pos.y := 35;
    //end;

    if state.next < state.score then
    begin
      state.lives += 1;
      state.next += PLAYER_LIFE_INTERVAL;
      CreateNote(notes,'Life Gained',player.pos,player.vel + VectorFromAngle(270,2),ColorGreen);
    end;
    if state.enemynext < state.score then
    begin
      state.enemylives += 1;
      state.enemynext += ENEMY_SPAWN_INTERVAL;
    end;

    if state.time > 0 then
      state.time -= 1;
  end;

  procedure DrawState(const state: TState; const ship1, ship2: TShip);
  var
    smallFont: Font;
    fadeColor: Color;
  begin
    if state.playing then
    begin
      smallFont := FontNamed('mediumFont');
      //DrawShape(ShipPoints,state.pos.x,state.pos.y + 10,270,ColorWhite);
      //DrawText('x '+IntToStr(state.lives),ColorWhite,smallFont,state.pos.x + 12,state.pos.y);
      //DrawText(IntToStr(state.score),ColorWhite,smallFont,state.pos.x - 6,state.pos.y - 25);
      DrawText('Kills: ' + IntToStr(ship1.kills),ship1.color,smallFont,14, 10);
      DrawText('Deaths: ' + IntToStr(ship1.deaths),ship1.color,smallFont,14, 25);

      DrawText('Kills: ' + IntToStr(ship2.kills),ship2.color,smallFont,14, ScreenHeight() - 40);
      DrawText('Deaths: ' + IntToStr(ship2.deaths),ship2.color,smallFont,14, ScreenHeight() - 25);
    end;
    if state.time > 0 then
    begin
      if state.transition = FadeIn then
        fadeColor := ColorBlack + $01000000 * Trunc(state.time / STATE_FADE_TIME * 255)
      else if state.transition = FadeOut then
        fadeColor := ColorBlack - $01000000 * Trunc(state.time / STATE_FADE_TIME * 255)
      else if state.quit then
        fadeColor := ColorBlack;
      DrawRectangle(fadeColor,true,0,0,ScreenWidth(),ScreenHeight());
    end;
  end;

end.

//______________________________________________________//
//                                                      //
// SwinGame Asteroids - Copyright SpiltCoffee 2010-2013 //
//______________________________________________________//
