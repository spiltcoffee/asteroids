unit asGameLoop;

interface
  uses asTypes;

  procedure GameProcessEvents(var state: TState; var menu: TMenu);

  procedure SetupGame(var state: TState; var menu: TMenu; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray; var notes: TNoteArray);

  procedure CreateObjects(var state: TState; var menu: TMenu; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray);

  procedure CollideObjects(var state: TState; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray; var notes: TNoteArray);

  procedure MoveGame(var state: TState; var menu: TMenu; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray; var notes: TNoteArray);

  procedure DrawGame(const state: TState; const menu: TMenu; const player, enemy: TShip; const asteroids: TAsteroidArray; const bullets: TBulletArray; const debris: TDebrisArray; const notes: TNoteArray);

implementation
  uses sgCamera, sgCore, sgGeometry, sgGraphics, sgInput, sgTypes, asAsteroids, asAudio,
       asCollisions, asConstants, asDraw, asEnemy, asEffects, asExtras, asMenu, asNotes,
       asPlayer, asState;

  procedure GameProcessEvents(var state: TState; var menu: TMenu);
  begin
    ProcessEvents();

    if state.readingtext and (not ReadingText() or TextEntryCancelled()) then
    begin
      state.name := TextReadAsASCII();
      state.readingtext := false;
      menu.disabled := false;
    end
    else if state.playing and not menu.disabled and KeyTyped(VK_ESCAPE) then
    begin
      state.paused := not state.paused;
      menu.visible := not menu.visible;
      if state.paused then
      begin
        StopAllSoundEffects();
        PlayMenuChangeEffect(state);
      end;
    end
    else if (KeyDown(VK_LALT) or KeyDown(VK_RALT)) and KeyTyped(VK_RETURN) then
    begin
      ToggleFullScreen();
      state.fullscreen := not state.fullscreen;
    end
    else if menu.visible and not menu.disabled and (KeyTyped(VK_UP) or KeyTyped(VK_DOWN) or KeyDown(VK_LEFT) or KeyDown(VK_RIGHT) or KeyTyped(VK_RETURN)) then
      MoveMenu(menu,state);
  end;

  procedure SetupGame(var state: TState; var menu: TMenu; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray; var notes: TNoteArray);
  begin
    LoadFonts();
    StartMusic();

    SetupState(state);
    state.transition := FadeIn;
    state.time := STATE_FADE_TIME;
    state.perform := NoCommand;
    
    SetupMenu(menu);

    CreatePlayer(player);
    
    SetupEnemy(enemy);
    
    SetLength(asteroids,0);
    
    while NeedMoreAsteroids(state.density,asteroids) do
      CreateAsteroid(asteroids,player);
    
    SetLength(bullets,0);
    SetLength(debris,0);
    SetLength(notes,0);
  end;

  procedure CreateObjects(var state: TState; var menu: TMenu; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray);
  begin
    if not state.paused then
    begin
      if (player.respawn > 0) then
        player.respawn -= 1;

      if not player.alive and state.playing then
      begin
        if (state.lives > 0) and (player.respawn < PLAYER_RESPAWN_SHOW) then
        begin
          PlayRespawnEffect(state);
          ResetPlayer(player,state);
        end
        else if (state.lives = 0) and (player.respawn = 0) then
        begin
          StartMenuCommand(GameOver,state,menu);
        end;
      end;

      while NeedMoreAsteroids(state.density,asteroids) do
        CreateAsteroid(asteroids,player,true);

      if player.alive and (player.int = 0) and KeyDown(VK_SPACE) then
      begin
        PlayBulletEffect(state);
        player.int := PLAYER_BULLET_INTERVAL;
        CreateBullet(bullets,player,player); //second player is kinda pointless, but I got nothing else to put there!
      end;

      if not enemy.alive and (state.enemylives > 0) then
      begin
        CreateEnemy(enemy,player,asteroids);
      end;

      if enemy.alive and player.alive and (enemy.int = 0) and CreateBullet(bullets,enemy,player) then
      begin
        PlayBulletEffect(state);
        enemy.int := ENEMY_BULLET_INTERVAL;
      end;
    end;
  end;
  
  procedure CollideObjects(var state: TState; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray; var notes: TNoteArray);
  var
    i, j: Integer;
  begin
    if not state.paused then
    begin
      //player collide enemy
      if player.alive and enemy.alive and (PointPointDistance(player.pos, enemy.pos) <= (player.rad + ENEMY_RADIUS_OUT)) then
      begin
        Collide(player,enemy);
        PlayCollisionEffect(state);
        CreateSparks(debris,4,FindCollisionPoint(player.pos,player.rad,enemy.pos,ENEMY_RADIUS_OUT));
        if (player.shields < 0) then
        begin
          PlayShipExplodeEffect(state);
          CreateSparks(debris,4,FindCollisionPoint(player.pos,player.rad,enemy.pos,ENEMY_RADIUS_OUT));
          KillPlayer(player,state,debris,notes);
        end
        else if (player.respawn = 0) then
          PlayAlarmEffect(state);
        if (enemy.shields <= 0) then
        begin
          PlayShipExplodeEffect(state);
          EndEnemyEffect();
          CreateSparks(debris,4,FindCollisionPoint(player.pos,player.rad,enemy.pos,ENEMY_RADIUS_OUT));
          KillEnemy(enemy,state,debris,notes);
        end;
      end;

      //asteroid collide asteroid
      for i := 0 to (High(asteroids) - 1) do
      begin
        for j := (i + 1) to High(asteroids) do
        begin
          if PointPointDistance(asteroids[i].pos, asteroids[j].pos) <= (asteroids[i].rad + asteroids[j].rad) then
          begin
            if (asteroids[i].last <> j) and (asteroids[j].last <> i) then
            begin
              Collide(asteroids[i],asteroids[j]);
              PlayCollisionEffect(state);
              CreateSparks(debris,4,FindCollisionPoint(asteroids[i].pos,asteroids[i].rad,asteroids[j].pos,asteroids[j].rad));
              asteroids[i].last := j;
              asteroids[j].last := i;
            end
          end
          else if (asteroids[i].last = j) and (asteroids[j].last = i) then
          begin
            asteroids[i].last := -1;
            asteroids[j].last := -1;
          end;
        end;
      end;

      //asteroid collide player, asteroid collide enemy, asteroid collide bullet
      i := 0;
      while i < Length(asteroids) do
      begin
        if player.alive and (PointPointDistance(asteroids[i].pos, player.pos) <= (asteroids[i].rad + player.rad)) then
        begin
          if player.last <> i then
          begin
            player.last := i;
            Collide(asteroids[i],player);
            PlayCollisionEffect(state);
            CreateSparks(debris,4,FindCollisionPoint(asteroids[i].pos,asteroids[i].rad,player.pos,player.rad));
            if (player.shields < 0) then
            begin
              PlayShipExplodeEffect(state);
              CreateSparks(debris,4,FindCollisionPoint(asteroids[i].pos,asteroids[i].rad,player.pos,player.rad));
              KillPlayer(player,state,debris,notes);
            end
            else if (player.respawn = 0) then
              PlayAlarmEffect(state);
          end;
        end
        else if (player.last = i) then
        begin
          player.last := -1;
        end;

        if enemy.alive and (PointPointDistance(asteroids[i].pos, enemy.pos) <= (asteroids[i].rad + ENEMY_RADIUS_OUT)) then
        begin
          if enemy.last <> i then
          begin
            enemy.last := i;
            Collide(asteroids[i],enemy);
            PlayCollisionEffect(state);
            CreateSparks(debris,4,FindCollisionPoint(asteroids[i].pos,asteroids[i].rad,enemy.pos,ENEMY_RADIUS_OUT));
            if (enemy.shields <= 0) then
            begin
              PlayShipExplodeEffect(state);
              EndEnemyEffect();
              CreateSparks(debris,4,FindCollisionPoint(asteroids[i].pos,asteroids[i].rad,enemy.pos,ENEMY_RADIUS_OUT));
              KillEnemy(enemy,debris);
            end;
          end;
        end
        else if (enemy.last = i) then
        begin
          enemy.last := -1;
        end;

        j := 0;
        while j < Length(bullets) do
        begin
          if (PointPointDistance(asteroids[i].pos, bullets[j].pos) <= (asteroids[i].rad + BULLET_RADIUS)) and (bullets[j].life > 0) then
          begin
            PlayAsteroidExplodeEffect(state);
            if bullets[j].kind = SK_PLAYER then
              DestroyAsteroid(asteroids,i,bullets[j].pos,state,debris,notes)
            else
              DestroyAsteroid(asteroids,i,bullets[j].pos,debris);
            CreateSparks(debris,8,bullets[j].pos);
            Remove(bullets,j);
            i -= 1;
            j -= 1;
            break;
          end;
          j += 1;
        end;
        i += 1;
      end;
      
      //bullet collide player, bullet collide enemy
      i := 0;
      while i < Length(bullets) do
      begin
        if player.alive and (PointPointDistance(player.pos, bullets[i].pos) <= (player.rad + BULLET_RADIUS)) and (bullets[i].life > 0) and (bullets[i].kind = SK_ENEMY) then
        begin
          PlayCollisionEffect(state);
          if (player.respawn = 0) then
            player.shields -= Trunc(PLAYER_SHIELD_HIGH*0.50);
          if (player.shields < 0) then
          begin
            PlayShipExplodeEffect(state);
            KillPlayer(player,state,debris,notes);
          end
          else if (player.respawn = 0) then
            PlayAlarmEffect(state);
          CreateSparks(debris,8,bullets[i].pos);
          Remove(bullets,i);
          ShakeScreen();
          i -= 1;
        end
        else if enemy.alive and (PointPointDistance(enemy.pos, bullets[i].pos) <= (ENEMY_RADIUS_OUT + BULLET_RADIUS)) and (bullets[i].life > 0) and (bullets[i].kind = SK_PLAYER) then
        begin
          if (enemy.respawn = 0) then
            enemy.shields -= Trunc(ENEMY_SHIELD_HIGH*0.99);
          if (enemy.shields < 0) then
          begin
            PlayShipExplodeEffect(state);
            EndEnemyEffect();
            KillEnemy(enemy,state,debris,notes);
          end;
          CreateSparks(debris,8,bullets[i].pos);
          Remove(bullets,i);
          i -= 1;
        end;
        i += 1;
      end;

      // find it's sign, invert it, and multiply that against it's absolute value less one
      if CameraX() <> 0 then
        SetCameraX((CameraX() / abs(CameraX())) * -1 * (abs(CameraX()) - 1));
      if CameraY() <> 0 then
        SetCameraY((CameraY() / abs(CameraY())) * -1 * (abs(CameraY()) - 1));
    end
    else if (CameraX() <> 0) or (CameraY <> 0) then
    begin
      SetCameraX(0);
      SetCameraY(0);
    end;
  end;

  procedure MoveGame(var state: TState; var menu: TMenu; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray; var notes: TNoteArray);
  var
    i: Integer;
  begin
    UpdateState(state,player,notes);
    if (state.perform <> NoCommand) and (state.time = 0) then
      EndMenuCommand(state,menu,player,enemy,asteroids,bullets,debris,notes);

    if not state.paused then
    begin
      if player.alive then
        MovePlayer(player,state);

      if enemy.alive then
        MoveEnemy(enemy,state,player,asteroids);

      for i := 0 to High(asteroids) do
        MoveAsteroid(asteroids[i]);
      
      i := 0;
      while i <= High(bullets) do
      begin
        MoveBullet(bullets[i]);
        if bullets[i].life <= (BULLET_END + 1) then
        begin
          Remove(bullets,i);
          i -= 1;
        end;
        i += 1;
      end;
      
      i := 0;
      while i <= High(debris) do
      begin
        MoveDebris(debris[i]);
        if debris[i].life <= 0 then
        begin
          Remove(debris,i);
          i -= 1;
        end;
        i += 1;
      end;
      
      i := 0;
      while i <= High(notes) do
      begin
        MoveNote(notes[i]);
        if notes[i].life <= 0 then
        begin
          Remove(notes,i);
          i -= 1;
        end;
        i += 1;
      end;
    end;
  end;

  procedure DrawGame(const state: TState; const menu: TMenu; const player, enemy: TShip; const asteroids: TAsteroidArray; const bullets: TBulletArray; const debris: TDebrisArray; const notes: TNoteArray);
  var
    i: Integer;
  begin
    ClearScreen();

    for i := 0 to High(notes) do
      DrawNote(notes[i]);
    
    if player.alive then
      DrawPlayer(player);

    if enemy.alive then
      DrawEnemy(enemy);
      
    for i := 0 to High(asteroids) do
      DrawAsteroid(asteroids[i]);
      
    for i := 0 to High(bullets) do
      DrawBullet(bullets[i]);
    
    for i := 0 to High(debris) do
      DrawDebris(debris[i]);
    
    if menu.visible then
      DrawMenu(menu,state);
    
    DrawState(state);
  end;

end.