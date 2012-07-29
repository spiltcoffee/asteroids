//!!TODO!! (higher = more important)
//release final version to public - you're done!! :D

//!!ORDER!!
//Instances: state {p}, menu {p}, note {d}, player, enemy, asteroid, bullet, debris, note {p}, menu {d}, state {d}
//Procedures: Process Input, Create, Collide, Destroy, Move, Draw, Refresh Screen (only do first and last two when paused :D)

program GameMain;
{$IFNDEF UNIX} {$r GameLauncher.res} {$ENDIF}
uses sgCore, sgResources, asAudio, asConstants, asGameLoop, asLogo, asMenuCommands, asTypes;

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
    GameProcessEvents(state,menu);
    CreateObjects(state,menu,player,enemy,asteroids,bullets);
    CollideObjects(state,player,enemy,asteroids,bullets,debris,notes);
    MoveGame(state,menu,player,enemy,asteroids,bullets,debris,notes);
    DrawGame(state,menu,player,enemy,asteroids,bullets,debris,notes);
    RefreshScreen(FRAMES_PER_SECOND);
  until WindowCloseRequested() or state.quit;

  EndAudio();
  ReleaseAllResources();
end;

begin
  Main();
end.
