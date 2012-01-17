unit asMenuCommands;

// Asteroids! Unit - Menu Commands
// A specific sub unit for the Menu Unit

interface
  uses asTypes;

  procedure StartGame(var state: TState; var menu: TMenu; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray; var notes: TNoteArray); overload;
  
  procedure EndGame(var state: TState; var menu: TMenu; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray; var notes: TNoteArray); overload;
  
  function ApplyGameOptions(const state: TState): Boolean;
  
  procedure SaveGameOptions(const state: TState);
  
  procedure LoadGameOptions(var state: TState);

implementation
  uses sgCore, sgGraphics, asConstants, asAsteroids, asEnemy, asMenu, asPlayer, asState, Sysutils;
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

end.