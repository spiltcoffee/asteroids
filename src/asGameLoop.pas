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
       asShip, asState

       {REMOVE}, SysUtils;

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
    else if (KeyDown(VK_LMETA) or KeyDown(VK_RMETA)) and KeyTyped(VK_Q) then
      state.quit := true
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

    CreateShip(player);

    SetupEnemy(enemy);

    SetLength(asteroids,0);

    while NeedMoreAsteroids(state.score, asteroids) do
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
          ResetShip(player,state);
        end
        else if (state.lives = 0) and (player.respawn = 0) then
        begin
          StartMenuCommand(GameOver,state,menu);
        end;
      end;

      while NeedMoreAsteroids(state.score, asteroids) do
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
          KillShip(player,state,debris,notes);
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

      ///                 ///
      //ASTEROID COLLISIONS//
      ///                 ///

      //asteroid collide asteroid

{   try
      while i < Length(asteroids) - 1 do
      i := 0;
      begin
        j := i + 1;
        while j < Length(asteroids) do
        begin
          if PointPointDistance(asteroids[i].pos, asteroids[j].pos) <= (asteroids[i].rad + asteroids[j].rad) then
          begin
            if (asteroids[i].last <> j) and (asteroids[j].last <> i) then
            begin
              //check asteroid[i] to make sure it won't instantly collide with it's last asteroid
              if (asteroids[i].last > -1) and (PointPointDistance(asteroids[i].pos, asteroids[asteroids[i].last].pos) <= (asteroids[i].rad + asteroids[asteroids[i].last].rad)) then
              begin
                last := asteroids[i].last; //keep it for later
                DestroyTwoAsteroids(asteroids, i, last, FindCollisionPoint(asteroids[i].pos,asteroids[i].rad,asteroids[last].pos,asteroids[last].rad), debris);

                //I could explain what this does, or you could just nod, smile, and accept that this prevents access violations from occurring
                if asteroids[asteroids[last].last].last = last then
                  asteroids[asteroids[last].last].last := -1;


                if i > last then //move back one if the other one we removed was before i
                  i -= 1;

                //start the next loop of j
                j := i;
              end
              //check asteroid[j] to make sure it won't instantly collide with it's last asteroid
              else if (asteroids[j].last > -1) and (PointPointDistance(asteroids[j].pos, asteroids[asteroids[j].last].pos) <= (asteroids[j].rad + asteroids[asteroids[j].last].rad)) then
              begin
                last := asteroids[j].last;
                DestroyTwoAsteroids(asteroids, j, last, FindCollisionPoint(asteroids[j].pos,asteroids[j].rad,asteroids[last].pos,asteroids[last].rad), debris);

                //And again. Nod, smile, accept. Easy :)
                if asteroids[asteroids[last].last].last = last then
                  asteroids[asteroids[last].last].last := -1;

                if i > last then //move back one if the other one we removed was before i
                  i -= 1;
                if j > last then //move back one if the other one we removed was before j
                  i -= 1;
              end
              else
              begin
                Collide(asteroids[i],asteroids[j]);
                PlayCollisionEffect(state);
                CreateSparks(debris,4,FindCollisionPoint(asteroids[i].pos,asteroids[i].rad,asteroids[j].pos,asteroids[j].rad));
                asteroids[i].last := j;
                asteroids[j].last := i;
              end
            end
          end
          else if (asteroids[i].last = j) and (asteroids[j].last = i) then
          begin
            asteroids[i].last := -1;
            asteroids[j].last := -1;
          end;
          j += 1;
        end;
        i += 1;
      end;
    except
      on E: Exception do
      begin
        WriteLn('Exception Caught! (You silly duffer!)');
        WriteLn('i = ' + IntToStr(i));
        WriteLn('i.last = ' + IntToStr(asteroids[i].last));
        WriteLn('j = ' + IntToStr(j));
        WriteLn('j.last = ' + IntToStr(asteroids[j].last));
      end;
    end;
}

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
              KillShip(player,state,debris,notes);
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
            if bullets[j].kind = SK_SHIP_PLAYER then
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
        if player.alive and (PointPointDistance(player.pos, bullets[i].pos) <= (player.rad + BULLET_RADIUS)) and (bullets[i].life > 0) and (bullets[i].kind <> SK_SHIP_PLAYER) then
        begin
          PlayCollisionEffect(state);
          if (player.respawn = 0) then
            player.shields -= Trunc(PLAYER_SHIELD_HIGH*0.50);
          if (player.shields < 0) then
          begin
            PlayShipExplodeEffect(state);
            KillShip(player,state,debris,notes);
          end
          else if (player.respawn = 0) then
            PlayAlarmEffect(state);
          CreateSparks(debris,8,bullets[i].pos);
          Remove(bullets,i);
          ShakeScreen();
          i -= 1;
        end
        else if enemy.alive and (PointPointDistance(enemy.pos, bullets[i].pos) <= (ENEMY_RADIUS_OUT + BULLET_RADIUS)) and (bullets[i].life > 0) and (bullets[i].kind = SK_SHIP_PLAYER) then
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
        MoveShip(player,state,asteroids);

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
      DrawShip(player);

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
