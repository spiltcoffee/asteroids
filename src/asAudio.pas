unit asAudio;

interface
  uses asTypes;

  procedure SetupAudio(const state: TState);
  procedure EndAudio();

  procedure StartMusic();
  procedure EndMusic();
  procedure UpdateMusic(const state: TState);
  
  procedure StopAllSoundEffects();

  procedure PlayAsteroidExplodeEffect(const state: Tstate);

  procedure PlayAlarmEffect(const state: TState);

  procedure PlayBulletEffect(const state: TState);

  procedure PlayCollisionEffect(const state: TState);

  procedure PlayShipExplodeEffect(const state: Tstate);
  
  procedure PlayRespawnEffect(const state: Tstate);

  procedure StartThrusterEffect(const state: TState);
  procedure EndThrusterEffect();
  
  procedure StartEnemyEffect(const state: TState);
  procedure EndEnemyEffect();
  
  procedure PlayMenuSelectEffect(const state: TState);
  procedure PlayMenuChangeEffect(const state: TState);

implementation
  uses sgAudio, sgCore, sgResources, Sysutils;

  procedure SetupAudio(const state: TState);
  begin
    OpenAudio();
    LoadResourceBundle('sounds.txt', False);
    SetMusicVolume(state.musicvolume/100);
  end;

  procedure EndAudio();
  begin
    ReleaseResourceBundle('sounds.txt');
    CloseAudio();
  end;

  procedure StartMusic();
  begin
    if not MusicPlaying() then
      FadeMusicIn(MusicNamed('asBackground'),-1,1000);
  end;

  procedure EndMusic();
  begin
    FadeMusicOut(1000);
  end;

  procedure UpdateMusic(const state: TState);
  begin
    SetMusicVolume(state.musicvolume/100);
  end;

  procedure StopAllSoundEffects();
  var
    i: Integer;
  begin
    if SoundEffectPlaying(SoundEffectNamed('asAsteroidExplode')) then
      StopSoundEffect(SoundEffectNamed('asAsteroidExplode'));
    
    if SoundEffectPlaying(SoundEffectNamed('asAlarm')) then
      StopSoundEffect(SoundEffectNamed('asAlarm'));
    
    if SoundEffectPlaying(SoundEffectNamed('asBullet')) then
      StopSoundEffect(SoundEffectNamed('asBullet'));
    
    for i := 1 to 6 do if SoundEffectPlaying(SoundEffectNamed('asCollision'+IntToStr(i))) then
      StopSoundEffect(SoundEffectNamed('asCollision'+IntToStr(i)));
    
    if SoundEffectPlaying(SoundEffectNamed('asEnemy')) then
      StopSoundEffect(SoundEffectNamed('asEnemy'));
    
    if SoundEffectPlaying(SoundEffectNamed('asShipExplode')) then
      StopSoundEffect(SoundEffectNamed('asShipExplode'));
    
    if SoundEffectPlaying(SoundEffectNamed('asThruster')) then
      StopSoundEffect(SoundEffectNamed('asThruster'));
  end;
  
  procedure PlayAsteroidExplodeEffect(const state: TState);
  begin
    PlaySoundEffect(SoundEffectNamed('asAsteroidExplode'),state.sfxvolume/100);
  end;

  procedure PlayAlarmEffect(const state: TState);
  begin
    if SoundEffectPlaying(SoundEffectNamed('asAlarm')) then
      StopSoundEffect(SoundEffectNamed('asAlarm'));
    PlaySoundEffect(SoundEffectNamed('asAlarm'),state.sfxvolume/100);
  end;

  procedure PlayBulletEffect(const state: TState);
  begin
    PlaySoundEffect(SoundEffectNamed('asBullet'),state.sfxvolume/100);
  end;

  procedure PlayCollisionEffect(const state: TState);
  begin
    PlaySoundEffect(SoundEffectNamed('asCollision'+IntToStr(Rnd(6)+1)),state.sfxvolume/100);
  end;

  procedure PlayShipExplodeEffect(const state: TState);
  begin
    PlaySoundEffect(SoundEffectNamed('asShipExplode'),state.sfxvolume/100);
  end;
  
  procedure PlayRespawnEffect(const state: TState);
  begin
    PlaySoundEffect(SoundEffectNamed('asRespawn'),state.sfxvolume/100);
  end;

  procedure StartThrusterEffect(const state: TState);
  begin
    if not SoundEffectPlaying(SoundEffectNamed('asThruster')) then
      PlaySoundEffect(SoundEffectNamed('asThruster'),-1,state.sfxvolume/100);
  end;

  procedure EndThrusterEffect();
  begin
    if SoundEffectPlaying(SoundEffectNamed('asThruster')) then
      StopSoundEffect(SoundEffectNamed('asThruster'));
  end;
  
  procedure StartEnemyEffect(const state: TState);
  begin
    if not SoundEffectPlaying(SoundEffectNamed('asEnemy')) then
      PlaySoundEffect(SoundEffectNamed('asEnemy'),-1,state.sfxvolume/100);
  end;

  procedure EndEnemyEffect();
  begin
    if SoundEffectPlaying(SoundEffectNamed('asEnemy')) then
      StopSoundEffect(SoundEffectNamed('asEnemy'));
  end;
  
  procedure PlayMenuSelectEffect(const state: TState);
  begin
    PlaySoundEffect(SoundEffectNamed('asMenuSelect'),state.sfxvolume/100);
  end;

  procedure PlayMenuChangeEffect(const state: TState);
  begin
    PlaySoundEffect(SoundEffectNamed('asMenuChange'),state.sfxvolume/100);
  end;
  
end.