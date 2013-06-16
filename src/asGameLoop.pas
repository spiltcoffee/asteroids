unit asGameLoop;

interface
  uses asTypes;

  procedure GameProcessEvents(var state: TState; var menu: TMenu; var ship: TShip);

  procedure SetupGame(var state: TState; var menu: TMenu; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray; var notes: TNoteArray);

  procedure CreateObjects(var state: TState; var menu: TMenu; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray);

  procedure CollideObjects(var state: TState; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray; var notes: TNoteArray);

  procedure MoveGame(var state: TState; var menu: TMenu; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray; var notes: TNoteArray);

  procedure DrawGame(const state: TState; const menu: TMenu; const player, enemy: TShip; const asteroids: TAsteroidArray; const bullets: TBulletArray; const debris: TDebrisArray; const notes: TNoteArray);

implementation
  uses sgCamera, sgCore, sgGeometry, sgGraphics, sgInput, sgTypes, asAsteroids, asAudio,
       asCollisions, asConstants, asDraw, asEnemy, asEffects, asExtras, asMenu, asNotes,
       asShip, asState, asInfluenceMap, asPath

       {REMOVE}, SysUtils;

  procedure GameProcessEvents(var state: TState; var menu: TMenu; var ship: TShip);
  begin
    ProcessEvents();

    if state.readingtext and (not ReadingText() or TextEntryCancelled()) then begin
      state.name := TextReadAsASCII();
      state.readingtext := false;
      menu.disabled := false;
    end
    else if state.playing and not menu.disabled and KeyTyped(VK_ESCAPE) then begin
      state.paused := not state.paused;
      menu.visible := not menu.visible;

      if state.paused then begin
        StopAllSoundEffects();
        PlayMenuChangeEffect(state);
      end;
    end
    else if (KeyDown(VK_LMETA) or KeyDown(VK_RMETA)) and KeyTyped(VK_Q) then begin
      state.quit := true
    end
    else if (KeyDown(VK_LALT) or KeyDown(VK_RALT)) and KeyTyped(VK_RETURN) then begin
      ToggleFullScreen();
      state.fullscreen := not state.fullscreen;
    end
    else if KeyTyped(VK_BACKQUOTE) then begin
      if (KeyDown(VK_LMETA) or KeyDown(VK_RMETA)) then begin
        if ship.kind = sk1ShipPlayer then begin
          ship.kind := sk1ShipAI;
        end
        else begin
          ship.kind := sk1ShipPlayer;
        end;
      end
      else begin
        state.debug := not state.debug;
      end;
    end
    else if menu.visible and not menu.disabled and (KeyTyped(VK_UP) or KeyTyped(VK_DOWN) or KeyDown(VK_LEFT) or KeyDown(VK_RIGHT) or KeyTyped(VK_RETURN)) then begin
      MoveMenu(menu,state);
    end;
  end;

  procedure SetupGame(var state: TState; var menu: TMenu; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray; var notes: TNoteArray);
  begin
    LoadFonts();
    StartMusic();

    SetupState(state);
    CreateMap(state.map, state.res);
    state.transition := FadeIn;
    state.time := STATE_FADE_TIME;
    state.perform := NoCommand;

    SetupMenu(menu);

    CreateShip(player);
    player.path := CreateEmptyPath;

    CreateShip(enemy, sk2ShipAI);
    enemy.path := CreateEmptyPath;

    SetLength(asteroids,0);

    while NeedMoreAsteroids(state.score, asteroids) do
      CreateAsteroid(asteroids,player);

    SetLength(bullets,0);
    SetLength(debris,0);
    SetLength(notes,0);
  end;

  procedure CreateObjects(var state: TState; var menu: TMenu; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray);
  begin
    if not state.paused then begin
      if (player.respawn > 0) then
        player.respawn -= 1;
      if (enemy.respawn > 0) then
        enemy.respawn -= 1;

      if state.playing then begin

        if not player.alive and (player.respawn < PLAYER_RESPAWN_SHOW) then begin
          PlayRespawnEffect(state);
          SpawnShip(player, debris, asteroids, enemy);
        end;

        if not enemy.alive and (enemy.respawn < PLAYER_RESPAWN_SHOW) then begin
          PlayRespawnEffect(state);
          SpawnShip(enemy, debris, asteroids, player);
        end;

      end;

      while NeedMoreAsteroids(state.score, asteroids) do begin
        CreateAsteroid(asteroids,player,true);
      end;

      if player.alive and (player.int = 0) and player.shooting then begin
        PlayBulletEffect(state);
        player.int := PLAYER_BULLET_INTERVAL;
        CreateBullet(bullets,player,enemy);
      end;
      player.shooting := False;

      if enemy.alive and (enemy.int = 0) and enemy.shooting then begin
        PlayBulletEffect(state);
        enemy.int := PLAYER_BULLET_INTERVAL;
        CreateBullet(bullets,enemy,player);
      end;
      enemy.shooting := False;

      if state.playing then begin
        ResetMap(state.map);
      end;
    end;
  end;

  procedure CollideObjects(var state: TState; var player, enemy: TShip; var asteroids: TAsteroidArray; var bullets: TBulletArray; var debris: TDebrisArray; var notes: TNoteArray);
  var
    i, j, new, cur, del: Integer;
    ignoreCollision, collision: TCollisionArray;
    collisionCount, destroy: array of Integer;
    collisionPoint: Point2D;
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
          KillShip(player, debris);
          enemy.kills += 1;
        end;

        if (enemy.shields < 0) then
        begin
          PlayShipExplodeEffect(state);
          CreateSparks(debris,4,FindCollisionPoint(player.pos,player.rad,enemy.pos,ENEMY_RADIUS_OUT));
          KillShip(enemy, debris);
          player.kills += 1;
        end;

        if (player.respawn = 0) or (enemy.respawn = 0) then
          PlayAlarmEffect(state);
      end;

      ///                 ///
      //ASTEROID COLLISIONS//
      ///                 ///

      //initialise new ignore collision array
      SetLength(ignoreCollision, 0);
      //initialise collision array
      SetLength(collision, 0);
      //initialise collision count array
      SetLength(collisionCount,Length(asteroids));
      for cur := 0 to High(collisionCount) do begin
        collisionCount[cur] := 0;
      end;
      //initialise destroy array
      SetLength(destroy,0);

      //while i < asteroids.length
      for i := 0 to High(asteroids) - 1 do begin
        //while j = i + 1; j < asteroids.length
        j := i + 1;
        for j := i + 1 to High(asteroids) do begin
          //imprecise check (i, j) - look for possible collisions
          //also check that i and j are not in the ignore collision array
          if ImpreciseCheck(asteroids[i], asteroids[j]) then begin
            if not PreviouslyCollided(state.ignoreCollision, i, j) then begin
              //store (i, j) in collision array
              SetLength(collision, Length(collision) + 1);
              new := High(collision);
              collision[new].i := i;
              collision[new].j := j;
              //set i and j in collision count array to +1
              collisionCount[i] += 1;
              collisionCount[j] += 1;
            end
            else begin
              //add i and j to new ignore collision array
              SetLength(ignoreCollision, Length(ignoreCollision) + 1);
              new := High(ignoreCollision);
              ignoreCollision[new].i := i;
              ignoreCollision[new].j := j;
            end;
          end;
        end;
      end;

      cur := 0;
      //while collision array
      while (cur < Length(collision)) do begin
        i := collision[cur].i;
        j := collision[cur].j;
        //precise check (i, j) - determine if asteroids actually collided - remove collision if precise check fails
        if not PreciseCheck(asteroids[i], asteroids[j]) then begin
          //remove from collisions
          Remove(collision, cur);
          //set i and j collision count array to -1
          collisionCount[i] -= 1;
          collisionCount[j] -= 1;
        end
        else begin
          cur += 1;
        end;
      end;

      //loop collision count array
      for cur := 0 to High(collisionCount) do begin
        //if count > 1
        if (collisionCount[cur] > 1) then begin
          //remove any collisions with this asteroid from collision array
          del := 0;
          while (del < Length(collision)) do begin
            if (collision[del].i = cur) or (collision[del].j = cur) then begin
              Remove(collision, del);
            end
            else begin
              del += 1;
            end;
          end;
          //add to destroy array
          SetLength(destroy, Length(destroy) + 1);
          new := High(destroy);
          destroy[new] := cur;
        end;
      end;

      new := Length(ignoreCollision);
      SetLength(ignoreCollision, Length(ignoreCollision) + Length(collision));

      for cur := 0 to High(collision) do begin
        i := collision[cur].i;
        j := collision[cur].j;
        //perform collision
        Collide(asteroids[i], asteroids[j]);
        PlayCollisionEffect(state);
        CreateSparks(debris,4,FindCollisionPoint(asteroids[i].pos,asteroids[i].rad,asteroids[j].pos,asteroids[j].rad));
        //add to ignore collision array
        ignoreCollision[new].i := i;
        ignoreCollision[new].j := j;
        new += 1;
      end;

      //loop destroy array
      for cur := High(destroy) downto 0 do begin
        //choose a random position around the center of the asteroid as the collision point
        collisionPoint := asteroids[destroy[cur]].pos + VectorFromAngle(Rnd() * 360, 1);
        //destroy the asteroid
        PlayAsteroidExplodeEffect(state);
        CreateSparks(debris,8,collisionPoint);
        DestroyAsteroid(asteroids, destroy[cur], collisionPoint, debris);

        //loop through ignore collision array
        for del := 0 to High(ignoreCollision) do begin
          //if any number in array is higher than the asteroid being destroyed, shift down by 1
          if (ignoreCollision[del].j > destroy[cur]) then begin
            ignoreCollision[del].j -= 1;
            if (ignoreCollision[del].i > destroy[cur]) then begin
              ignoreCollision[del].i -= 1;
            end;
          end;
        end;
      end;

      state.ignoreCollision := ignoreCollision;

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
              KillShip(player, debris);
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
            if (enemy.shields < 0) then
            begin
              PlayShipExplodeEffect(state);
              CreateSparks(debris,4,FindCollisionPoint(asteroids[i].pos,asteroids[i].rad,enemy.pos,ENEMY_RADIUS_OUT));
              KillShip(enemy, debris);
            end
            else if (enemy.respawn = 0) then
              PlayAlarmEffect(state);
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
        if player.alive and (PointPointDistance(player.pos, bullets[i].pos) <= (player.rad + BULLET_RADIUS)) and (bullets[i].life > 0) and (bullets[i].kind <> player.kind) then
        begin
          PlayCollisionEffect(state);
          if (player.respawn = 0) then
            player.shields -= Trunc(PLAYER_SHIELD_HIGH * BULLET_DAMAGE);
          if (player.shields < 0) then
          begin
            PlayShipExplodeEffect(state);
            KillShip(player, debris);
            enemy.kills += 1;
          end
          else if (player.respawn = 0) then
            PlayAlarmEffect(state);
          CreateSparks(debris,8,bullets[i].pos);
          Remove(bullets,i);
          if player.kind = sk1ShipPlayer then begin
            ShakeScreen();
          end;
          i -= 1;
        end
        else if enemy.alive and (PointPointDistance(enemy.pos, bullets[i].pos) <= (ENEMY_RADIUS_OUT + BULLET_RADIUS)) and (bullets[i].life > 0) and (bullets[i].kind <> enemy.kind) then
        begin
          PlayCollisionEffect(state);
          if (enemy.respawn = 0) then
            enemy.shields -= Trunc(ENEMY_SHIELD_HIGH * BULLET_DAMAGE);
          if (enemy.shields < 0) then
          begin
            PlayShipExplodeEffect(state);
            KillShip(enemy, debris);
            player.kills += 1;
          end
          else if (enemy.respawn = 0) then
            PlayAlarmEffect(state);
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

    if not state.paused then begin
      if state.playing then begin
        UpdateMap(state.map, asteroids);
      end;

      if player.alive then begin
        MoveShip(player, state, asteroids, enemy);
        UpdatePath(player.path, player.pos);
      end;

      if enemy.alive then begin
        MoveShip(enemy, state, asteroids, player);
        UpdatePath(enemy.path, enemy.pos);
      end;

      for i := 0 to High(asteroids) do begin
        MoveAsteroid(asteroids[i]);
      end;

      i := 0;
      while i <= High(bullets) do begin
        MoveBullet(bullets[i]);

        if bullets[i].life <= (BULLET_END + 1) then begin
          Remove(bullets,i);
          i -= 1;
        end;

        i += 1;
      end;

      i := 0;
      while i <= High(debris) do begin
        MoveDebris(debris[i]);

        if debris[i].life <= 0 then begin
          Remove(debris,i);
          i -= 1;
        end;

        i += 1;
      end;

      i := 0;
      while i <= High(notes) do begin
        MoveNote(notes[i]);

        if notes[i].life <= 0 then begin
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

    if state.debug then begin
      DrawMap(state.map, state.res);
    end;

    for i := 0 to High(notes) do begin
      DrawNote(notes[i]);
    end;

    if player.alive then begin
      DrawShip(player);
      if state.debug then begin
        DrawPath(player);
        DrawCircle(player.color, player.controller.target, 10);
      end;
    end;

    if enemy.alive then begin
      DrawShip(enemy);
      if state.debug then begin
        DrawPath(enemy);
        DrawCircle(enemy.color, enemy.controller.target, 10);
      end;
    end;

    for i := 0 to High(asteroids) do begin
      DrawAsteroid(asteroids[i]);
    end;

    for i := 0 to High(bullets) do begin
      DrawBullet(bullets[i]);
    end;

    for i := 0 to High(debris) do begin
      DrawDebris(debris[i]);
    end;

    if menu.visible then begin
      DrawMenu(menu,state);
    end;

    DrawState(state, player, enemy);
  end;

end.
