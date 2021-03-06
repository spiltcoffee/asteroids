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

unit asMenu;

interface
  uses sgTypes, asTypes;
  procedure LoadMainMenu(var menu: TMenu);
  procedure LoadOptionsMenu(var menu: TMenu);
  procedure LoadPauseMenu(var menu: TMenu);
  procedure LoadSubmitScoreMenu(var menu: TMenu; const state: TState);
  procedure LoadGameOverMenu(var menu: TMenu; const state: TState);
  procedure LoadHighScoresMenu(var menu: TMenu);

  procedure SetupMenu(var menu: TMenu);

  procedure StartMenuCommand(command: MenuCommand; var state: TState; var menu: TMenu);

  procedure EndMenuCommand(var state: TState; var menu: TMenu; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray; var notes: TNoteArray);

  procedure MoveMenu(var menu: TMenu; var state: TState);

  procedure DrawMenu(const menu: TMenu; const state: TState);

implementation
  uses sgCore, sgGraphics, sgInput, sgText, asAudio, asConstants, asDraw, asExtras, asHighScores, asMenuCommands, Sysutils;

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
      SetLength(item,5);
      item[0].text := 'FullScreen: ';
      item[0].command := Fullscreen;
      item[1].text := 'Resolution: ';
      item[1].command := Resolution;
      item[2].text := 'SFX Volume: ';
      item[2].command := SFXVolume;
      item[3].text := 'Music Volume: ';
      item[3].command := MVolume;
      item[4].text := 'Back to Main Menu';
      item[4].command := SaveOptions;

      for i := 0 to High(item) do with item[i] do
      begin
        pos.x := 400 - TextWidth(FontNamed('menuFont'),text);
        pos.y := 300 - ((MENU_ITEM_PADDING * High(item)) div 2) + (MENU_ITEM_PADDING * i);
        kind := Option;
      end;
      item[4].kind := Select;
      item[4].pos.x += TextWidth(FontNamed('menuFont'),item[3].text) / 2;
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
      item[1].text := 'Save Score';
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
      item[0].text := 'Save Score';
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

  procedure SetupMenu(var menu: TMenu);
  begin
    LoadMainMenu(menu);

    menu.selected := 0;
    menu.visible := true;
    menu.disabled := false;
    menu.pos.x := ScreenWidth() / 2 - 400;
    menu.pos.y := ScreenHeight() / 2 - 300;
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
        EndMusic();
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
      SFXVolume: begin
        if KeyDown(VK_RIGHT) and (state.sfxvolume < 100) then
          state.sfxvolume += 1
        else if KeyDown(VK_LEFT) and (state.sfxvolume > 0) then
          state.sfxvolume -= 1;
      end;
      MVolume: begin
        if KeyDown(VK_RIGHT) and (state.musicvolume < 100) then
          state.musicvolume += 1
        else if KeyDown(VK_LEFT) and (state.musicvolume > 0) then
          state.musicvolume -= 1;
        UpdateMusic(state);
      end;
    end;
  end;

  procedure MoveMenu(var menu: TMenu; var state: TState);
  begin
    if KeyTyped(VK_DOWN) and (menu.selected < High(menu.item)) and (menu.item[menu.selected + 1].kind <> Nothing) then
    begin
      PlayMenuChangeEffect(state);
      menu.selected += 1;
    end
    else if KeyTyped(VK_UP) and (menu.selected > Low(menu.item)) and (menu.item[menu.selected - 1].kind <> Nothing)then
    begin
      PlayMenuChangeEffect(state);
      menu.selected -= 1;
    end
    else if KeyTyped(VK_RETURN) and ((menu.item[menu.selected].kind = Select) or (menu.item[menu.selected].kind = Input)) and (menu.item[menu.selected].command <> NoCommand) then
    begin
      PlayMenuSelectEffect(state);
      StartMenuCommand(menu.item[menu.selected].command,state,menu);
    end
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
      SFXVolume: result := IntToStr(state.sfxvolume) + '%';
      MVolume: result := IntToStr(state.musicvolume) + '%';
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
    DrawText('Final Release',ColorGreen,FontNamed('menuFont'),ScreenWidth() - TextWidth(FontNamed('menuFont'),'Final Release') - 10,ScreenHeight() - MENU_ITEM_HEIGHT - 10);

    menuFont := FontNamed('menuFont');
    for i := 0 to High(menu.item) do with menu.item[i] do
    begin
      DrawText(text,ColorGreen,menuFont,menu.pos.x + pos.x,menu.pos.y + pos.y - MENU_ITEM_HEIGHT / 2);
      if (kind = Option) or ((kind = Input) and not state.readingtext) then
        DrawText(GetMenuOption(command,state),ColorGreen,menuFont,menu.pos.x + 400,menu.pos.y + pos.y - MENU_ITEM_HEIGHT / 2);
      if menu.selected = i then
        DrawShape(ShipPoints,menu.pos.x + pos.x - MENU_ITEM_SELECT_OFFSET, menu.pos.y + pos.y,0,colorGreen);
    end;
  end;

end.
