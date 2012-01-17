//procedure StartGame(var state: TState; var);
//begin
//  state.playing := true;
//end;

procedure LoadMainMenu(var menu: TMenu);
var
  i: Integer;
begin
  with menu do
  begin
    title := 'Asteroids!';
    subtitle := 'By SpiltCoffee';
    selected := 0;
    SetLength(item,4);
    item[0].text := 'Start Game';
    item[0].command := Start;
    item[1].text := 'Options';
    item[1].command := LoadOptions;
    item[2].text := 'High Scores';
    item[2].command := LoadScores;
    item[3].text := 'Quit Game';
    item[3].command := Quit;
    
    for i := 0 to High(item) do with item[i] do
    begin
      pos.x := 400 - TextWidth(FontNamed('menuFont'),text) / 2;
      pos.y := 300 - ((MENU_ITEM_PADDING * High(item)) div 2) + (MENU_ITEM_PADDING * i);
      kind := Select;
    end;
  end;
end;

procedure LoadOptionsMenu(var menu: TMenu);
var
  i: Integer;
begin
  with menu do
  begin
    title := 'Asteroids!';
    subtitle := 'Options';
    selected := 0;
    SetLength(item,4);
    item[0].text := 'FullScreen: ';
    item[0].command := Fullscreen;
    item[1].text := 'Resolution: ';
    item[1].command := Resolution;
    item[2].text := 'Volume: ';
    item[2].command := Volume;
    item[3].text := 'Back to Main Menu';
    item[3].command := SaveOptions;
    
    for i := 0 to High(item) do with item[i] do
    begin
      pos.x := 400 - TextWidth(FontNamed('menuFont'),text);
      pos.y := 300 - ((MENU_ITEM_PADDING * High(item)) div 2) + (MENU_ITEM_PADDING * i);
      kind := Option;
    end;
    item[3].kind := Select;
    item[3].pos.x += TextWidth(FontNamed('menuFont'),item[3].text) / 2;
  end;
end;

procedure LoadPauseMenu(var menu: TMenu);
var
  i: Integer;
begin
  with menu do
  begin
    title := '';
    subtitle := 'Paused';
    selected := 0;
    SetLength(item,3);
    item[0].text := 'Resume Game';
    item[0].command := Resume;
    item[1].text := 'Back to Main Menu';
    item[1].command := GotoMain;
    item[2].text := 'Quit Game';
    item[2].command := Quit;
    
    for i := 0 to High(item) do with item[i] do
    begin
      pos.x := 400 - TextWidth(FontNamed('menuFont'),text) / 2;
      pos.y := 300 - ((MENU_ITEM_PADDING * High(item)) div 2) + (MENU_ITEM_PADDING * i);
      kind := Select;
    end;
  end;
end;

procedure LoadSubmitScoreMenu(var menu: TMenu; const state: TState);
var
  i: Integer;
begin
  with menu do
  begin
    title := 'Submit Score';
    subtitle := 'Final Score: '+IntToStr(state.score);
    selected := 0;
    SetLength(item,3);
    item[0].text := 'Name: ';
    item[0].command := EnterName;
    item[1].text := 'Submit Score';
    item[1].command := SaveScore;
    item[2].text := 'Cancel';
    item[2].command := LoadGameOver;

    for i := 0 to High(item) do with item[i] do
    begin
      pos.x := 400 - TextWidth(FontNamed('menuFont'),text) / 2;
      pos.y := 300 - ((MENU_ITEM_PADDING * High(item)) div 2) + (MENU_ITEM_PADDING * i);
      kind := Select;
    end;
    item[0].kind := Input;
    item[0].pos.x -= TextWidth(FontNamed('menuFont'),item[0].text) / 2;
  end;
end;

procedure SetupMenu(var menu: TMenu);
begin
  LoadMainMenu(menu);

  menu.selected := 0;
  menu.visible := true;
  menu.disabled := false;
  menu.pos.x := ScreenWidth() / 2 - 400;
  menu.pos.y := ScreenHeight() / 2 - 300;
end;

procedure StartGame(var state: TState; var menu: TMenu; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray; var notes: TNoteArray); overload;
begin
  SetupState(state);
  state.playing := true;
  state.transition := FadeIn;
  state.time := STATE_FADE_TIME;
  state.perform := NoCommand;
  
  menu.visible := false;
  menu.disabled := false;
  menu.selected := 0;
  LoadPauseMenu(menu);

  CreatePlayer(player);
  SpawnPlayer(player,state);
  
  SetupEnemy(enemy);
  
  SetLength(asteroids,0);
  
  while NeedMoreAsteroids(state.density,asteroids) do
    CreateAsteroid(asteroids,player);
  
  SetLength(bullets,0);
  SetLength(debris,0);
  SetLength(notes,0);
end;

procedure EndGame(var state: TState; var menu: TMenu; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray; var notes: TNoteArray); overload;
begin
  SetupState(state);
  state.playing := false;
  state.transition := FadeIn;
  state.time := STATE_FADE_TIME;
  state.perform := NoCommand;
  
  SetupMenu(menu);
  menu.visible := true;
  menu.disabled := false;
  menu.selected := 0;
  LoadMainMenu(menu);

  CreatePlayer(player);
  
  SetupEnemy(enemy);
  
  SetLength(asteroids,0);
  
  while NeedMoreAsteroids(state.density,asteroids) do
    CreateAsteroid(asteroids,player);
  
  SetLength(bullets,0);
  SetLength(debris,0);
  SetLength(notes,0);
end;

function ApplyGameOptions(const state: TState): Boolean;
begin
  result := false;
  if (state.res.width <> ScreenWidth()) or (state.res.height <> ScreenHeight()) then
  begin
    ChangeScreenSize(state.res.width,state.res.height);
    result := true;
  end;
  if IsFullscreen() <> state.fullscreen then
  begin
    ToggleFullScreen();
    result := true;
  end;
end;

procedure SaveGameOptions(const state: TState);
var
  optionsFile: Text;
begin
  if DirectoryExists(GetAppConfigDir(false)) or (not DirectoryExists(GetAppConfigDir(false)) and CreateDir(GetAppConfigDir(false))) then
  begin
    Assign(optionsFile,GetAppConfigDir(false) + '/options.txt');
    Rewrite(optionsFile);

    if state.fullscreen then
      WriteLn(optionsFile, 'F ', 1)
    else
      WriteLn(optionsFile, 'F ', 0);
    WriteLn(optionsFile, 'W ', state.res.width);
    WriteLn(optionsFile, 'H ', state.res.height);
    WriteLn(optionsFile, 'V ', state.volume);
    Close(optionsFile);
  end;
end;

procedure LoadGameOptions(var state: TState);
var
  optionsFile: Text;
  key: Char;
  value: String;
  valueNum: Integer;
begin
  //initialise defaults...
  state.fullscreen := false;
  state.res.width := 800;
  state.res.height := 600;
  state.volume := 100;
  if FileExists(GetAppConfigDir(false) + '/options.txt') then
  begin
    Assign(optionsFile,GetAppConfigDir(false) + '/options.txt');
    Reset(optionsFile);
    while not EOF(optionsFile) do
    begin
      Read(optionsFile,key);
      ReadLn(optionsFile,value);
      if TryStrToInt(value,valueNum) then case key of
        'F': if valueNum = 1 then
          state.fullscreen := true;
        'W': state.res.width := valueNum;
        'H': state.res.height := valueNum;
        'V': if (valueNum <= 100) and (valueNum >= 0) then
          state.volume := valueNum;
      end;
    end;

    if not ValidResolution(state.res.width,state.res.height,800,600) then
    begin
      state.res.width := 800;
      state.res.height := 600;
    end;
    Close(optionsFile);
  end;
  //also just to make sure...
  SaveGameOptions(state);
end;

function LoadHighScores(): THighScoreArray;
var
  scoresFile: Text;
  value: String;
  i, valueNum: Integer;
  curChar: Char;
begin
  SetLength(result,10);
  for i := 0 to High(result) do
  begin
    result[i].name := '-';
    result[i].score := 0;
  end;

  if FileExists(GetAppConfigDir(false) + '/scores.txt') then
  begin
    Assign(scoresFile,GetAppConfigDir(false) + '/scores.txt');
    Reset(scoresFile);
    i := 0;
    while not EOF(scoresFile) and (i < 5) do
    begin
      value := '';
      Read(scoresFile,curChar);
      while (curChar <> ' ') and (curChar <> #10) do
      begin
        value += curChar;
        Read(scoresFile,curChar);
      end;
      if not EOLN(scoresFile) then
      begin
        result[i].name := value;
        ReadLn(scoresFile,value);
        if TryStrToInt(value,valueNum) and (valueNum > 0) then
          result[i].score := valueNum
        else
        begin
          result[i].name := '-';
          result[i].score := 0;
        end;
      end;
      if result[i].name <> '-' then
        i += 1;
    end;
    Close(scoresFile);
  end;
end;

procedure SaveHighScores(highScores: THighScoreArray);
var
  scoresFile: Text;
  i: Integer;
begin
  if DirectoryExists(GetAppConfigDir(false)) or (not DirectoryExists(GetAppConfigDir(false)) and CreateDir(GetAppConfigDir(false))) then
  begin
    Assign(scoresFile,GetAppConfigDir(false) + '/scores.txt');
    Rewrite(scoresFile);

    for i := 0 to High(highScores) do if highScores[i].name <> '-' then
      WriteLn(scoresFile, highScores[i].name,' ',highScores[i].score);

    Close(scoresFile);
  end;
end;

function AmmendHighScores(name: String; score: Integer; test: Boolean = false): Boolean;
var
  highScores: THighScoreArray;
  inserted: Boolean;
  i, j: Integer;
begin
  highScores := LoadHighScores();
  inserted := false;
  for i := 0 to High(highScores) do if score > highScores[i].score then
  begin
    for j := High(highScores) - 1 downto i do
      highScores[j + 1] := highScores[j];
    highScores[i].name := name;
    highScores[i].score := score;
    inserted := true;
    break;
  end;

  result := inserted;

  if inserted and not test then
    SaveHighScores(highScores);
end;

function NewHighScore(score: Integer): Boolean;
begin
  result := AmmendHighScores('-', score, true);
end;

procedure LoadGameOverMenu(var menu: TMenu; const state: TState);
var
  i: Integer;
begin
  with menu do
  begin
    title := 'Game Over';
    subtitle := 'Final Score: '+IntToStr(state.score);
    selected := 0;
    SetLength(item,4);
    item[0].text := 'Submit Score';
    item[0].command := LoadSubmitScore;
    item[1].text := 'Try Again';
    item[1].command := Start;
    item[2].text := 'Back to Main Menu';
    item[2].command := GotoMain;
    item[3].text := 'Quit Game';
    item[3].command := Quit;
    
    if not NewHighScore(state.score) or not state.submitscore then
      Remove(item,0);
    
    for i := 0 to High(item) do with item[i] do
    begin
      pos.x := 400 - TextWidth(FontNamed('menuFont'),text) / 2;
      pos.y := 300 - ((MENU_ITEM_PADDING * High(item)) div 2) + (MENU_ITEM_PADDING * i);
      kind := Select;
    end;
  end;
end;

procedure LoadHighScoresMenu(var menu: TMenu);
var
  highScores: THighScoreArray;
  i: Integer;
begin
  with menu do
  begin
    title := 'Asteroids!';
    subtitle := 'High Scores';
    selected := 5;
    SetLength(item,6);
    highScores := LoadHighScores();

    for i := 0 to 4 do with item[i] do
    begin
      text := highScores[i].name + '  ' + IntToStr(highScores[i].score);
      pos.x := 400 - TextWidth(FontNamed('menuFont'),highScores[i].name + ' ');
      pos.y := 300 - ((MENU_ITEM_PADDING * High(item)) div 2) + (MENU_ITEM_PADDING * i);
      kind := Nothing;
    end;
    
    item[5].text := 'Back to Main Menu';
    item[5].pos.x := 400 - TextWidth(FontNamed('menuFont'),item[5].text) / 2;
    item[5].pos.y := 300 - ((MENU_ITEM_PADDING * High(item)) div 2) + (MENU_ITEM_PADDING * 5);
    item[5].command := LoadMain;
    item[5].kind := Select;
  end;
end;

procedure StartMenuCommand(command: MenuCommand; var state: TState; var menu: TMenu);
begin
  case command of
    Start: begin
      state.transition := FadeOut;
      state.time := STATE_FADE_TIME;
      state.perform := Start;
      menu.disabled := true;
    end;
    Resume: begin
      state.paused := false;
      menu.visible := false;
    end;
    GotoMain: begin
      state.transition := FadeOut;
      state.time := STATE_FADE_TIME;
      state.perform := GotoMain;
      menu.disabled := true;
    end;
    LoadMain: begin
      LoadMainMenu(menu);
    end;
    SaveOptions: begin
      if ApplyGameOptions(state) then
      begin
        state.time := 1;
        state.transition := NoFade;
        state.perform := GotoMain;
      end;
      SaveGameOptions(state);
      LoadMainMenu(menu);
    end;
    LoadOptions: begin
      LoadOptionsMenu(menu);
    end;
    LoadScores: begin
      LoadHighScoresMenu(menu);
    end;
    GameOver: begin
      LoadGameOverMenu(menu,state);
      menu.visible := false;
      menu.disabled := true;
      state.playing := false;
      state.paused := false;
      state.time := PLAYER_RESPAWN_HIGH - PLAYER_RESPAWN_SHOW;
      state.transition := NoFade;
      state.perform := GameOver;
    end;
    LoadGameOver: begin
      LoadGameOverMenu(menu,state);
    end;
    LoadSubmitScore: begin
      LoadSubmitScoreMenu(menu,state);
    end;
    EnterName: begin
      state.readingtext := true;
      menu.disabled := true;
      StartReadingTextWithText(state.name,ColorGreen, 24, FontNamed('menuFont'), Trunc(menu.pos.x + 400),Trunc(menu.pos.y + menu.item[0].pos.y - MENU_ITEM_HEIGHT / 2));
    end;
    SaveScore: if state.name <> '' then
    begin
      AmmendHighScores(state.name,state.score);
      state.submitscore := false;
      LoadGameOverMenu(menu,state);
    end;
    Quit: begin
      state.transition := FadeOut;
      state.time := STATE_FADE_TIME;
      state.perform := Quit;
      menu.disabled := true;
    end;
  end;
end;

procedure EndMenuCommand(var state: TState; var menu: TMenu; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray; var notes: TNoteArray);
var
  command: MenuCommand;
begin
  state.time := 0;
  state.transition := NoFade;
  command := state.perform;
  state.perform := NoCommand;
  case command of
    Start: StartGame(state,menu,player,enemy,asteroids,bullets,debris,notes);
    GotoMain: EndGame(state,menu,player,enemy,asteroids,bullets,debris,notes);
    GameOver: begin
      menu.visible := true;
      menu.disabled := false;
    end;
    Quit: begin
      state.quit := true;
      state.time := 2;
    end;
  end;
end;

function GetNewResolution(resolution: Size; next: Boolean = true): Size;
var
  resList: SizeArray;
  i: Integer;
begin
  result := resolution;
  resList := ListResolutions(800,600);
  for i := 0 to High(resList) do
  begin
    if (resList[i].width = resolution.width) and (resList[i].height = resolution.height) then
    begin
      if next and (i < High(resList)) then
        result := resList[i + 1]
      else if not next and (i > 0) then
        result := resList[i - 1];
    end;
  end;
end;

procedure ChangeMenuOption(option: MenuCommand; var state: TState; var menu: TMenu);
begin
  case option of
    Fullscreen: if KeyTyped(VK_LEFT) or KeyTyped(VK_RIGHT) then state.fullscreen := not state.fullscreen;
    Resolution: begin
      if KeyTyped(VK_LEFT) then
        state.res := GetNewResolution(state.res)
      else if KeyTyped(VK_RIGHT) then
        state.res := GetNewResolution(state.res,false);
    end;
    Volume: begin
      if KeyDown(VK_RIGHT) and (state.volume < 100) then
        state.volume += 1
      else if KeyDown(VK_LEFT) and (state.volume > 0) then
        state.volume -= 1;
    end;
  end;
end;

procedure MoveMenu(var menu: TMenu; var state: TState);
begin
  if KeyTyped(VK_DOWN) and (menu.selected < High(menu.item)) and (menu.item[menu.selected + 1].kind <> Nothing) then
    menu.selected += 1
  else if KeyTyped(VK_UP) and (menu.selected > Low(menu.item)) and (menu.item[menu.selected - 1].kind <> Nothing)then
    menu.selected -= 1
  else if KeyTyped(VK_RETURN) and ((menu.item[menu.selected].kind = Select) or (menu.item[menu.selected].kind = Input)) and (menu.item[menu.selected].command <> NoCommand) then
    StartMenuCommand(menu.item[menu.selected].command,state,menu)
  else if (KeyDown(VK_LEFT) or KeyDown(VK_RIGHT)) and (menu.item[menu.selected].kind = Option) and (menu.item[menu.selected].command <> NoCommand) then
    ChangeMenuOption(menu.item[menu.selected].command,state,menu);
end;

function GetMenuOption(option: MenuCommand; const state: TState): String;
begin
  case option of
    Fullscreen: begin
      if state.fullscreen then 
        result := 'Yes'
      else
        result := 'No';
    end;
    Resolution: result := IntToStr(Trunc(state.res.width)) + ' x ' + IntToStr(Trunc(state.res.height));
    Volume: result := IntToStr(state.volume) + '%';
    EnterName: result := state.name;
  end;
end;

procedure DrawMenu(const menu: TMenu; const state: TState);
var
  i: Integer;
  menuFont: Font;
begin
  DrawText(menu.title,ColorGreen,FontNamed('titleFont'),menu.pos.x + 400 - TextWidth(FontNamed('titleFont'),menu.title) / 2,menu.pos.y + 75);
  DrawText(menu.subtitle,ColorGreen,FontNamed('subtitleFont'),menu.pos.x + 400 - TextWidth(FontNamed('subtitleFont'),menu.subtitle) / 2,menu.pos.y + 135);
  DrawText('Release Candidate 2',ColorGreen,FontNamed('menuFont'),ScreenWidth() - TextWidth(FontNamed('menuFont'),'Release Candidate 2') - 10,ScreenHeight() - MENU_ITEM_HEIGHT - 10);
  
  menuFont := FontNamed('menuFont');
  for i := 0 to High(menu.item) do with menu.item[i] do
  begin
    DrawText(text,ColorGreen,menuFont,menu.pos.x + pos.x,menu.pos.y + pos.y - MENU_ITEM_HEIGHT / 2);
    if (kind = Option) or ((kind = Input) and not state.readingtext) then
      DrawText(GetMenuOption(command,state),ColorGreen,menuFont,menu.pos.x + 400,menu.pos.y + pos.y - MENU_ITEM_HEIGHT / 2);
    if menu.selected = i then
      DrawShape(PlayerShip(),menu.pos.x + pos.x - MENU_ITEM_SELECT_OFFSET, menu.pos.y + pos.y,0,colorGreen);
  end;
end;