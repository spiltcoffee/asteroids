function NeedMoreAsteroids(const density: Double; const asteroids: TAsteroidArray): Boolean;
var
  totalAsteroidRadius: Double;
  i: Integer;
begin
  totalAsteroidRadius := 0;
  for i := 0 to High(asteroids) do
    totalAsteroidRadius += asteroids[i].rad;
  result := (Round((ScreenWidth() * ScreenHeight()) / density) > totalAsteroidRadius);
end;

procedure SetupState(var state: TState); //In SetupGame()
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
    next := PLAYER_LIFE_INTERVAL;
    enemylives := 0;
    enemynext := Trunc(state.density * ENEMY_LIFE_INTERVAL_BASE) + Rnd(Trunc(state.density * ENEMY_LIFE_INTERVAL_VAR)) + 1 - Trunc(state.density * ENEMY_LIFE_INTERVAL_VAR) div 2;
    density := STATE_START_DENSITY;
    pos.x := 20;
    pos.y := 35;
    transition := NoFade;
    time := 0;
    perform := NoCommand;
  end;
end;

procedure UpdateState(var state: TState; const player: TShip; var notes: TNoteArray); //for pos, In MoveGame()
begin
  if (PointPointDistance(state.pos,player.pos) < STATE_PLAYERMOVEDIST) then
  begin
    if player.pos.y < (ScreenHeight() / 2) then
      state.pos.y := ScreenHeight() - 35
    else
      state.pos.y := 35;
  end;

  if state.next < state.score then
  begin
    state.lives += 1;
    state.next += PLAYER_LIFE_INTERVAL;
    CreateNote(notes,'Life Gained',player.pos,player.vel + VectorFromAngle(270,2),ColorGreen);
  end;
  if state.enemynext < state.score then
  begin
    state.enemylives += 1;
    state.enemynext := state.score + Trunc(state.density * ENEMY_LIFE_INTERVAL_BASE) + Rnd(Trunc(state.density * ENEMY_LIFE_INTERVAL_VAR)) + 1 - Trunc(state.density * ENEMY_LIFE_INTERVAL_VAR) div 2;
  end;
  
  if state.time > 0 then
    state.time -= 1;
end;

procedure DrawState(const state: TState);
var
  smallFont: Font;
  fadeColor: Color;
begin
  if state.playing then
  begin
    smallFont := FontNamed('mediumFont');
    DrawShape(PlayerShip(),state.pos.x,state.pos.y + 10,270,ColorWhite);
    DrawText('x '+IntToStr(state.lives),ColorWhite,smallFont,state.pos.x + 12,state.pos.y);
    DrawText(IntToStr(state.score),ColorWhite,smallFont,state.pos.x - 6,state.pos.y - 25);
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