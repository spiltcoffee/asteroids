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

//______________________________________________________//
//                                                      //
// SwinGame Asteroids - Copyright SpiltCoffee 2010-2013 //
//______________________________________________________//
