//!!TODO!! (higher = more important)
//add sounds
// - as player is firing, reduce the volume of the bullet being fired, so it's not as distracting

//!!ORDER!!
//Instances: state {p}, menu {p}, note {d}, player, enemy, asteroid, bullet, debris, note {p}, menu {d}, state {d}
//Procedures: Process Input, Create, Collide, Destroy, Move, Draw, Refresh Screen (only do first and last two when paused :D)

program GameMain;
{$IFNDEF UNIX} {$r GameLauncher.res} {$ENDIF}
uses sgAudio, sgCore, sgResources, asGameLoop, asLogo, asMenuCommands, asTypes;

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
  OpenAudio();

  LoadGameOptions(state);
  OpenGraphicsWindow('Asteroids', state.res.width, state.res.height, state.fullscreen, true, false);
  LoadResourceBundle('sounds.txt', False);
  ShowMyLogo();
  
  SetupGame(state,menu,player,enemy,asteroids,bullets,debris,notes);

  repeat // The game loop...
    GameProcessEvents(state,menu);
    CreateObjects(state,menu,player,enemy,asteroids,bullets);
    CollideObjects(state,player,enemy,asteroids,bullets,debris,notes);
    MoveGame(state,menu,player,enemy,asteroids,bullets,debris,notes);
    DrawGame(state,menu,player,enemy,asteroids,bullets,debris,notes);
    RefreshScreen(30);
  until WindowCloseRequested() or state.quit;

  ReleaseResourceBundle('sounds.txt');
  CloseAudio();
  ReleaseAllResources();
end;

begin
  Main();
end.
