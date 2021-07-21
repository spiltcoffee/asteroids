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

program GameMain;
{$IFNDEF UNIX} {$r GameLauncher.res} {$ENDIF}
uses sgCore, sgResources, asAudio, asConstants, asGameLoop, asLogo, asMenuCommands, asTypes, SysUtils;

procedure Main();
var
  state: TState;
  menu: TMenu;
  player, enemy: TShip;
  asteroids: TAsteroidArray;
  bullets: TBulletArray;
  debris: TDebrisArray;
  notes: TNoteArray;
begin
  LoadGameOptions(state);

  SetupAudio(state);

  OpenGraphicsWindow('Asteroids', state.res.width, state.res.height, state.fullscreen, true, false, true);
  ShowMyLogo();

  SetupGame(state,menu,player,enemy,asteroids,bullets,debris,notes);

  repeat // The game loop...
    GameProcessEvents(state,menu,player);
    CreateObjects(state,menu,player,enemy,asteroids,bullets,debris);
    CollideObjects(state,player,enemy,asteroids,bullets,debris,notes);
    MoveGame(state,menu,player,enemy,asteroids,bullets,debris,notes);
    DrawGame(state,menu,player,enemy,asteroids,bullets,debris,notes);
    RefreshScreen(FRAMES_PER_SECOND);
  until WindowCloseRequested() or state.quit;

  EndAudio();
  ReleaseAllResources();
  try
    Halt(0);
  except on Exception do
    WriteLn('Exception On Close');
  end;
end;

begin
  Main();
end.
