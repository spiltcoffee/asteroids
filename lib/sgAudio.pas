//=============================================================================
// sgAudio.pas
//=============================================================================
//
// The Audio unit is responsible for managing SDL audio for music and sound
// effects. This includes initialisation, loading, freeing, playing, and
// checking if music or sound is playing.
//
// Change History:
//
// Version 3:
// - 2010-01-28: David  : Changed MapSoundEffect to use an already
//												loaded bitmap if found
// - 2009-11-10: Andrew : Added sn and csn tags to code
// - 2009-11-06: Andrew : Returned loading code
//                      : Added extra comments and tracing
// - 2009-07-29: Andrew : Open Audio now indicates if audio has been opened.
// - 2009-07-14: Andrew : Removed loading and freeing code.
// - 2009-06-16: Clinton: Commenting/format tweaks
// - 2009-06-04: Andrew : Finished processing comments.
//                        Added fading capabilities.
//                        Fixed comments in implementation.
// Version 2.1:
// - 2009-05-19: Andrew:  Added PlaySoundEffect with volume
//                        Added meta comments
// Version 2.0:
// - 2008-12-17: Andrew: Moved all integers to LongInt
// - 2008-12-16: Andrew: Added volume controls
//
// Version 1.1:
// - 2008-03-09: Andrew: Added extra exception handling
// - 2008-01-17: Aki + Andrew: Refactor
//
// Version 1.0:
// - Various
//=============================================================================

{$I sgTrace.inc}

/// SwinGame's Audio is responsible for loading and playing music and sound
/// effects. The main functionality exists in `LoadMusic`, `PlayMusic`,
/// `LoadSoundEffect`, and `PlaySoundEffect`. Associated with these are the
/// `Music` and `SoundEffect` types.
///
///@module Audio
///@static
unit sgAudio;

//=============================================================================
interface
  uses sgTypes;
//=============================================================================

//----------------------------------------------------------------------------
// Opening and Closing Audio support
//----------------------------------------------------------------------------
  
  /// `TryOpenAudio` attempts to open the audio device for SwinGame to use.
  /// If this fails `TryOpenAudio` returns false to indicate that the audio
  /// device has not opened correctly and audio cannot be played.
  ///
  /// @lib
  function TryOpenAudio(): Boolean;
  
  /// `OpenAudio` is used to initialise the SwinGame audio code. This should be
  /// called at the start of your programs code, and is usually coded into the
  /// starting project templates. After initialising the audio code you can
  /// load and play `Music` using `LoadMusic` and `PlayMusic', load and play
  /// `SoundEffect`s using `LoadSoundEffect` and `PlaySoundEffect`. At the end
  /// of the program you need to call `CloseAudio` to ensure that the audio
  /// code is correctly terminated.
  ///
  /// @lib
  procedure OpenAudio();
  
  /// `AudioOpen` indicates if SwinGame's audio has been opened. Sound effects
  /// and Music can only be played with the audio is open.
  ///
  /// @lib
  function AudioReady(): Boolean;
  
  /// `CloseAudio` is used to clean up the resources used by SwinGame audio. If
  /// `OpenAudio` is called, this must be called to return the resources used
  /// before the program terminates.
  ///
  /// @lib
  procedure CloseAudio();
  
  
  
//----------------------------------------------------------------------------
// Loading & Releasing Sound Effects
//----------------------------------------------------------------------------
  
  /// Loads the `SoundEffect` from the supplied filename. The sound will be loaded
  /// from the Resources/sounds folder unless a full path to the file is passed
  /// in. If you are passing in the full path and you want to ensure that your game
  /// is able to work across multiple platforms correctly then use
  /// `PathToResource` to get the full path to the files in the projects
  /// resources folder.
  ///
  /// LoadSoundEffect can load wav and ogg audio files.
  ///
  /// `FreeSoundEffect` should be called to free the resources used by the 
  /// `SoundEffect` data once the resource is no longer needed.
  ///
  /// @param filename the filename of the sound effect file to load. 
  ///
  /// @lib
  ///
  /// @class SoundEffect
  /// @constructor
  /// @csn initFromPath:%s
  function LoadSoundEffect(filename: String): SoundEffect;
  
  /// Loads and returns a sound effect. The supplied `filename` is used to
  /// locate the sound effect to load. The supplied `name` indicates the 
  /// name to use to refer to this SoundEffect. The `SoundEffect` can then be
  /// retrieved by passing this `name` to the `SoundEffectNamed` function. 
  ///
  /// @lib
  /// @sn mapSoundEffectNamed:%s toFile:%s
  ///
  /// @class SoundEffect
  /// @constructor
  /// @csn initWithName:%s forFilename:%s
  function MapSoundEffect(name, filename: String): SoundEffect;
  
  /// Determines if SwinGame has a sound effect loaded for the supplied name.
  /// This checks against all sounds loaded, those loaded without a name
  /// are assigned the filename as a default
  ///
  /// @lib
  function HasSoundEffect(name: String): Boolean;
  
  /// Returns the `SoundEffect` that has been loaded with the specified name,
  /// see `MapSoundEffect`.
  ///
  /// @lib
  function SoundEffectNamed(name: String): SoundEffect;
  
  /// Releases the SwinGame resources associated with the sound effect of the
  /// specified `name`.
  ///
  /// @lib
  procedure ReleaseSoundEffect(name: String);
  
  /// Releases all of the sound effects that have been loaded.
  ///
  /// @lib
  procedure ReleaseAllSoundEffects();
  
  /// Frees the resources used by a `SoundEffect` resource. All loaded
  /// `SoundEffect`s should be freed once they are no longer needed.
  ///
  /// @lib
  ///
  /// @class SoundEffect
  /// @dispose
  procedure FreeSoundEffect(var effect: SoundEffect);
  
  
//----------------------------------------------------------------------------
// Loading & Releasing Music
//----------------------------------------------------------------------------
  
  /// Loads and returns a music value. The supplied `filename` is used to
  /// locate the music file to load. The supplied `name` indicates the 
  /// name to use to refer to this Music value. The `Music` can then be
  /// retrieved by passing this `name` to the `MusicNamed` function. 
  ///
  /// @lib
  /// @sn mapMusicNamed:%s toFile:%s
  ///
  /// @class Music
  /// @constructor
  /// @csn initWithName:%s forFilename:%s
  function MapMusic(name, filename: String): Music;
  
  /// Determines if SwinGame has a music value loaded for the supplied name.
  /// This checks against all music values loaded using `MapMusic`.
  ///
  /// @lib
  function HasMusic(name: String): Boolean;
  
  /// Returns the `Music` that has been loaded with the specified name.
  /// This works with music data loaded using `MapMusic`.
  ///
  /// @lib
  function MusicNamed(name: String): Music;
  
  /// Releases the music that have been loaded with the supplied name.
  ///
  /// @lib
  procedure ReleaseMusic(name: String);
  
  /// Releases all of the music data that have been loaded.
  ///
  /// @lib
  procedure ReleaseAllMusic();
  
  /// Loads the `Music` from the supplied filename. The music will be loaded
  /// from the Resources/sounds folder unless a full path to the file is passed
  /// in. If you are passing in the full path and you want toensure that your game
  /// is able to work across multiple platforms correctly ensure that you use
  /// `PathToResource` to get the full path to the files in the projects 
  /// resources folder.
  ///
  /// LoadMusic can load mp3, wav and ogg audio files.
  ///
  /// `FreeMusic` should be called to free the resources used by the 
  /// `Music` data once the resource is no longer needed.
  ///
  /// @param filename the filename to the music file to load.
  ///
  /// @lib
  ///
  /// @class Music
  /// @constructor
  /// @csn initFromPath:%s
  function LoadMusic(filename: String): Music;
  
  /// Frees the resources used by a `Music` resource. All loaded
  /// `Music` should be freed once it is no longer needed. 
  ///
  /// @lib
  ///
  /// @class Music
  /// @dispose
  procedure FreeMusic(var mus: Music);
  
  
  
//----------------------------------------------------------------------------
// Playing Sound Effects
//----------------------------------------------------------------------------
  
  /// There are several versions of PlaySoundEffect that can be used to control
  /// the way the sound effect plays, allowing you to control its volume and 
  /// the number of times the code loops. In all cases the started sound effect
  /// is mixed with the currently playing sound effects and music.
  ///
  /// With this version of PlaySoundEffect, the started sound effect will be 
  /// played at full volume.
  ///
  /// @param effect The effect indicates which sound effect to start playing. This
  ///               effect is played once at its full volume.
  ///
  /// @lib PlaySoundEffectWithLoopAndVolume(effect,1,1.0)
  /// @uname PlaySoundEffect
  ///
  /// @class SoundEffect
  /// @method Play
  procedure PlaySoundEffect(effect: SoundEffect); overload;
    
  /// This version of PlaySoundEffect allows you to indicate the number of times
  /// the sound effect is repeated. Setting the loops parameter to -1 will cause
  /// the sound effect to be looped infinitely, setting it to a value larger than
  /// 0 plays the sound effect the number of times indicated, calling with a 
  /// value of 0 means the sound effect is not played.
  ///
  /// @param effect The effect indicates which sound effect to start playing. This
  ///               effect is played once at its full volume.
  ///
  /// @param loops Controls the number of times the sound effect is played. -1
  ///              means the sound effect is repeated infinitely.
  ///
  /// @lib PlaySoundEffectWithLoopAndVolume(effect, loops, 1.0)
  /// @uname PlaySoundEffectWithLoop
  /// @sn playSoundEffect:%s looped:%s
  ///
  /// @class SoundEffect
  /// @overload Play PlayWithLoops
  /// @csn playLooped:%s
  procedure PlaySoundEffect(effect: SoundEffect; loops: LongInt); overload;
        
  /// This version of PlaySoundEffect allows you to control the volume of the 
  /// sounds playback. The vol parameter will take a value between 0 and 1 
  /// indicating the percentage of full volume to play at.
  /// For example, 0.1 plays the sound effect at 10% of its original volume.
  ///
  /// @param effect The effect indicates which sound effect to start playing. 
  /// @param vol Indicates the percentage of the original volume to play the 
  ///            `SoundEffect` at. This must be between 0 and 1.
  ///
  /// @lib PlaySoundEffectWithLoopAndVolume(effect, 1, vol)
  /// @uname PlaySoundEffectWithVolume
  /// @sn playSoundEffect:%s atVolume:%s
  /// @version 2.1
  ///
  /// @class SoundEffect
  /// @overload Play PlayWithVolume
  procedure PlaySoundEffect(effect: SoundEffect; vol: Single); overload;
  
  /// This version of PlaySoundEffect allows you to control both the number
  /// of times the `SoundEffect` is repeated, and its playback volume.
  ///
  /// @param effect The effect indicates which sound effect to start playing. 
  /// @param loops Controls the number of times the sound effect is played.
  /// @param vol Indicates the percentage of the original volume to play the 
  ///            `SoundEffect` at. This must be between 0 and 1.
  ///
  /// @lib PlaySoundEffectWithLoopAndVolume
  /// @sn playSoundEffect:%s looped:%s atVolume:%s
  /// @version 2.0
  ///
  /// @class SoundEffect
  /// @overload Play PlayWithLoopsAndVolume
  procedure PlaySoundEffect(effect: SoundEffect; loops: LongInt; vol: Single); overload;
  
  
  
  //----------------------------------------------------------------------------
  // Playing Music
  //----------------------------------------------------------------------------
  
  /// PlayMusic starts playing a `Music` resource. SwinGame only allows one 
  /// music resource to be played at a time. Starting to play a new music 
  /// resource will stop the currently playing music track. You can also stop
  /// the music by calling `StopMusic`.
  ///
  /// By default SwinGame starts playing music at its full volume. This can be 
  /// controlled by calling `SetMusicVolume`. The current volume can be checked 
  /// with `MusicVolume`.
  ///
  /// To test if a `Music` resource is currently playing you can use the 
  /// `MusicPlaying` function.
  ///
  /// This version of PlayMusic can be used to play background music that is 
  /// looped infinitely. The currently playing music is stopped and the new 
  /// music resource will start playing, and will repeat until `StopMusic` is 
  /// called, or another resource is played. 
  ///
  /// @param mus The `Music` resource to play.
  ///
  /// @lib PlayMusicWithLoops(mus, -1)
  /// @uname PlayMusic
  ///
  /// @class Music
  /// @method Play
  procedure PlayMusic(mus: Music); overload;
  
  /// This version of PlayMusic allows you to control the number of times the 
  /// `Music` resource is repeated. It starts playing the supplied `Music` 
  /// resource, repeating it the numder of times specified in the loops 
  /// parameter. Setting loops to -1 repeats the music infinitely, other values
  /// larger than 0 indicate the number of times that the music should be 
  /// played.
  ///
  /// @param mus The `Music` resource to be played.
  /// @param loops The number of times that the music should be played, -1 for 
  ///              repeat infinitely
  ///
  /// @lib PlayMusicWithLoops
  /// @sn playMusic:%s looped:%s
  ///
  /// @class Music
  /// @overload Play PlayWithLoops
  procedure PlayMusic(mus: Music; loops: LongInt); overload;
  
  /// Fades the music in over a number of milliseconds, and then continues to
  /// play the music repeatedly until the program ends or the music is stopped. 
  /// The music fades from 0 volume up to the currently set music volume.
  /// 
  /// @param mus The `Music` resource to be played.
  /// @param ms The number of milliseconds over which to fade the music in to 
  //            the current music volume.
  ///
  /// @lib FadeMusicIn
  /// @sn playMusic:%s fadeIn:%s
  ///
  /// @class Music
  /// @method FadeIn
  /// @csn playFadeIn:%s
  procedure FadeMusicIn(mus: Music; ms: LongInt); overload;

  /// This version of FadeMusicIn fades the music in then plays the 'Music' 
  /// for a given number of loops.Setting loops to -1 repeats the music 
  /// infinitely, other values larger than 0 indicate the number of times that
  /// the music should be played.
  ///
  /// @param mus The `Music` resource to be played.
  /// @param loops The number of times that the music should be played, -1 for 
  ///              repeat infinitely
  /// @param ms The number of milliseconds over which to fade the music in to 
  ///           the current music volume.
  ///
  /// @lib FadeMusicInWithLoops
  /// @sn playMusic:%s looped:%s fadeIn:%s
  ///
  /// @class Music
  /// @overload FadeIn FadeInWithLoops
  /// @csn playLooped:%s fadeIn:%s
  procedure FadeMusicIn(mus: Music; loops, ms: LongInt); overload;
  
  
  
  //----------------------------------------------------------------------------
  // Query music
  //----------------------------------------------------------------------------
  
  /// This procedure allows you to set the volume of the currently playing 
  /// music. The vol parameter indicates the percentage of the original volume,
  /// for example, 0.1 sets the playback volume to 10% of its full volume.
  ///
  /// @param value Indicates the percentage of the original volume to play the 
  ///            `Music` at. This must be between 0 and 1, e.g. 0.1 is 10%.
  ///
  /// @lib SetMusicVolume
  ///
  /// @class Music
  /// @static
  /// @setter Volume
  procedure SetMusicVolume(value: Single);
  
  /// This function returns the current volume of the music. This will be a 
  /// value between 0 and 1, with 1 indicating 100% of the `Music` resources
  /// volume.
  ///
  /// @returns The volume of the currently playing music.
  ///
  /// @lib MusicVolume
  ///
  /// @class Music
  /// @static
  /// @getter Volume
  function MusicVolume(): Single;
  
  /// This function indicates if music is currently playing. As only one music 
  /// resource can be playing at a time this does not need to be told which
  /// music resource to check for.
  ///
  /// @returns true if the music is playing
  ///
  /// @lib MusicPlaying
  ///
  /// @class Music
  /// @static
  /// @method IsPlaying
  function MusicPlaying(): Boolean;
  
  /// Returns the name that SwinGame uses to refer to this music data. This
  /// name can be used to fetch and release this music resource.
  ///
  /// @lib
  ///
  /// @class Music
  /// @getter Name
  function MusicName(mus: Music): String;
  
  /// Returns the filename that SwinGame uses to load to this music data.
  ///
  /// @lib
  ///
  /// @class Music
  /// @getter Filename
  function MusicFilename(mus: Music): String;
  
  
  
  //----------------------------------------------------------------------------
  // Query Sound Effects
  //----------------------------------------------------------------------------
  
  /// This function can be used to check if a sound effect is currently 
  /// playing. 
  ///
  /// @param effect The sound effect to check.
  /// @returns true if the effect `SoundEffect` is playing.
  ///
  /// @lib SoundEffectPlaying
  ///
  /// @class SoundEffect
  /// @method IsPlaying
  function SoundEffectPlaying(effect: SoundEffect): Boolean;
  
  /// Returns the name that SwinGame uses to refer to this sound effect. This
  /// name can be used to fetch and release this sound effect resource.
  ///
  /// @lib
  ///
  /// @class SoundEffect
  /// @getter Name
  function SoundEffectName(effect: SoundEffect): String;
  
  /// Returns the filename that SwinGame used to load to this sound effect.
  ///
  /// @lib
  ///
  /// @class SoundEffect
  /// @getter Filename
  function SoundEffectFilename(effect: SoundEffect): String;
  
  
  
  //----------------------------------------------------------------------------
  // Stop Music & Sound Effects
  //----------------------------------------------------------------------------
  
  /// Stops all occurances of the effect `SoundEffect` that is currently playing.
  ///
  /// @param effect The sound to stop.
  ///
  /// @lib StopSoundEffect
  ///
  /// @class SoundEffect
  /// @method Stop
  procedure StopSoundEffect(effect: SoundEffect);
    
  /// Stops playing the current music resource.
  ///
  /// @lib StopMusic
  ///
  /// @class Music
  /// @static
  /// @method Stop
  procedure StopMusic();
  
  /// Fades the currently playing music out over a number of milli seconds.
  ///
  /// @param ms The number of milliseconds over which to fade the music to 0 volume.
  ///
  /// @lib FadeMusicOut
  ///
  /// @class Music
  /// @static
  /// @method FadeOut
  procedure FadeMusicOut(ms: LongInt);
  
  
  
//=============================================================================
implementation
  uses
    SysUtils, Classes, 
    stringhash,         // libsrc
    SDL_Mixer, SDL,     // SDL
    sgShared, sgResources, sgTrace;
//=============================================================================

  var
    // Contains the sound channels used to determine if a sound is currently
    // playing and enables us to stop the sound, check if it is playing etc.
    soundChannels: Array[0..31] of Pointer;
    _SoundEffects: TStringHash;
    _Music: TStringHash;
  
  function TryOpenAudio(): Boolean;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'TryOpenAudio', '');
    {$ENDIF}
    
    sgShared.AudioOpen :=  Mix_OpenAudio(MIX_DEFAULT_FREQUENCY, MIX_DEFAULT_FORMAT, 2, 2048 ) >= 0;
    result := sgShared.AudioOpen;
    
    if result then
    begin
      Mix_AllocateChannels(32);
    end;
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'TryOpenAudio', BoolToStr(result, true));
    {$ENDIF}
  end;
  
  procedure OpenAudio();
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'OpenAudio', '');
    {$ENDIF}
    
    if not TryOpenAudio() then RaiseException('Error opening audio device: ' + string(Mix_GetError()));
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'OpenAudio');
    {$ENDIF}
  end;
  
  function AudioReady(): Boolean;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'AudioReady', '');
    {$ENDIF}
    
    result := sgShared.AudioOpen;
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'AudioReady', BoolToStr(result, true));
    {$ENDIF}
  end;
  
  procedure CloseAudio();
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'CloseAudio', '');
    {$ENDIF}
    
    AudioOpen := False;
    Mix_CloseAudio();
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'CloseAudio');
    {$ENDIF}
  end;
  
  procedure SetMusicVolume(value: Single);
  var
    newVol: LongInt;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'SetMusicVolume', FloatToStr(value));
    {$ENDIF}
    
    if (value < 0) then value := 0
    else if value > 1 then value := 1;

    //SDL music volume is 0 - 128
    newVol := Trunc(value * 128);
    Mix_VolumeMusic(newVol);
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'SetMusicVolume');
    {$ENDIF}
  end;
  
  function MusicVolume(): Single;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'MusicVolume', '');
    {$ENDIF}
    
   result := Mix_VolumeMusic(-1) / 128;
   
   {$IFDEF TRACE}
     TraceExit('sgAudio', 'MusicVolume', FloatToStr(result));
   {$ENDIF}
  end;
  
  //----------------------------------------------------------------------------
  
  // Private:
  // Called by MapSoundEffect
  function DoLoadSoundEffect(filename, name: String): SoundEffect;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'DoLoadSoundEffect', name + ' = ' + filename);
    {$ENDIF}
    
    if not FileExists(filename) then
    begin
      filename := PathToResource(filename, SoundResource);
      if not FileExists(filename) then
      begin
        RaiseException('Unable to locate sound effect ' + filename);
        exit;
      end;
    end;
    
    New(result);    
    result^.effect := Mix_LoadWAV(PChar(filename));
    result^.filename := filename;
    result^.name := name;
    
    if result^.effect = nil then
    begin
      Dispose(result);
      RaiseException('Error loading sound effect: ' + MIX_GetError());
      exit;
    end;
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'DoLoadSoundEffect', HexStr(result));
    {$ENDIF}
  end;
  
  function LoadSoundEffect(filename: String): SoundEffect;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'LoadSoundEffect', filename);
    {$ENDIF}
    
    result := MapSoundEffect(filename, filename);
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'LoadSoundEffect');
    {$ENDIF}
  end;
  
  function MapSoundEffect(name, filename: String): SoundEffect;
  var
    obj: tResourceContainer;
    snd: SoundEffect;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'MapSoundEffect', name + ' = ' + filename);
    {$ENDIF}
    
    if not AudioOpen then
    begin
      {$IFDEF TRACE}
        TraceExit('sgAudio', 'MapSoundEffect', 'Audio Closed');
      {$ENDIF}
      exit;
    end;
    
    if _SoundEffects.containsKey(name) then
    begin
      result := SoundEffectNamed(name);
      exit;
    end;
    
    snd := DoLoadSoundEffect(filename, name);
    obj := tResourceContainer.Create(snd);
    
    if not _SoundEffects.setValue(name, obj) then
    begin
      RaiseException('** Leaking: Caused by Sound Effect resource twice, ' + name);
      result := nil;
      exit;
    end;
    result := snd;
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'MapSoundEffect');
    {$ENDIF}
  end;
  
  // private:
  // Called to actually free the resource
  procedure DoFreeSoundEffect(var effect: SoundEffect);
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'DoFreeSoundEffect', 'effect = ' + HexStr(effect));
    {$ENDIF}
    
    if assigned(effect) then
    begin
      CallFreeNotifier(effect);
      
      if assigned(effect^.effect) then
      begin
        Mix_FreeChunk(effect^.effect);
        Dispose(effect);
      end;
    end;
    effect := nil;
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'DoFreeSoundEffect');
    {$ENDIF}
  end;
  
  procedure FreeSoundEffect(var effect: SoundEffect);
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'FreeSoundEffect', 'effect = ' + HexStr(effect));
    {$ENDIF}
    
    if(assigned(effect)) then
    begin
      ReleaseSoundEffect(effect^.name);
    end;
    effect := nil;
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'FreeSoundEffect');
    {$ENDIF}
  end;
  
  procedure ReleaseSoundEffect(name: String);
  var
    snd: SoundEffect;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'ReleaseSoundEffect', 'effect = ' + name);
    {$ENDIF}
    
    snd := SoundEffectNamed(name);
    if (assigned(snd)) then
    begin
      _SoundEffects.remove(name).Free();
      DoFreeSoundEffect(snd);
    end;
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'ReleaseSoundEffect');
    {$ENDIF}
  end;
  
  procedure ReleaseAllSoundEffects();
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'ReleaseAllSoundEffects', '');
    {$ENDIF}
    
    ReleaseAll(_SoundEffects, @ReleaseSoundEffect);
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'ReleaseAllSoundEffects');
    {$ENDIF}
  end;
  
  //----------------------------------------------------------------------------
  
  function DoLoadMusic(filename, name: String): Music;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'DoLoadMusic', name + ' = ' + filename);
    {$ENDIF}
    
    if not FileExists(filename) then
    begin
      filename := PathToResource(filename, SoundResource);
      if not FileExists(filename) then
      begin
        RaiseException('Unable to locate music ' + filename);
        exit;
      end;
    end;
    
    New(result);
    result^.music := Mix_LoadMUS(PChar(filename));
    result^.name := name;
    result^.filename := filename;
    
    if result^.music = nil then
    begin
      dispose(result);
      result := nil;
      RaiseException('Error loading music: ' + SDL_GetError());
      exit;
    end;
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'DoLoadMusic');
    {$ENDIF}
  end;
  
  function LoadMusic(filename: String): Music;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'LoadMusic', filename);
    {$ENDIF}
    
    result := MapMusic(filename, filename);
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'LoadMusic');
    {$ENDIF}
  end;
  
  function MapMusic(name, filename: String): Music;
  var
    obj: tResourceContainer;
    mus: Music;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'MapMusic', name + ' = ' + filename);
    {$ENDIF}
    
    if _Music.containsKey(name) then
    begin
      RaiseException('Error loaded Music resource twice, ' + name);
      result := nil;
      exit;
    end;
    
    mus := DoLoadMusic(filename, name);
    obj := tResourceContainer.Create(mus);
    
    if not _Music.setValue(name, obj) then
    begin
      RaiseException('** Leaking due to loading Music resource twice, ' + name);
      exit;
    end;
    
    result := mus;
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'MapMusic');
    {$ENDIF}
  end;
  
  procedure DoFreeMusic(var mus: Music);
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'DoFreeMusic', 'mus = ' + HexStr(mus));
    {$ENDIF}
    
    if assigned(mus) then
    begin
      CallFreeNotifier(mus);
      if assigned(mus^.music) then
      begin
        Mix_FreeMusic(mus^.music);
      end;
      dispose(mus);
    end;
    mus := nil;
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'DoFreeMusic');
    {$ENDIF}    
  end;
  
  procedure FreeMusic(var mus: Music);
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'FreeMusic', 'mus = ' + HexStr(mus));
    {$ENDIF}
    
    if assigned(mus) then ReleaseMusic(mus^.name);
    mus := nil;
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'FreeMusic');
    {$ENDIF}
  end;
  
  procedure ReleaseMusic(name: String);
  var
    mus: Music;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'ReleaseMusic', name);
    {$ENDIF}
    
    mus := MusicNamed(name);
    if (assigned(mus)) then
    begin
      _Music.remove(name).Free();
      DoFreeMusic(mus);
    end;
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'ReleaseMusic');
    {$ENDIF}
  end;
  
  procedure ReleaseAllMusic();
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'ReleaseAllMusic', '');
    {$ENDIF}
    
    ReleaseAll(_Music, @ReleaseMusic);
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'ReleaseAllMusic');
    {$ENDIF}
  end;
  
  
  
  //----------------------------------------------------------------------------
  
  procedure PlaySoundEffect(effect: SoundEffect; loops: LongInt; vol: Single); overload;
  var
    i: LongInt;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'PlaySoundEffect', HexStr(effect) + ' loops = ' + IntToStr(loops) + ' vol = ' + FloatToStr(vol));
    {$ENDIF}
    
    if not Assigned(effect) then
    begin
      RaiseException('Sound not supplied');
      exit;
    end;
    //dont play if loops = 0
    if loops = 0 then exit;
    
    //correct volume to be between 0 and 1
    if (vol < 0) then vol := 0
    else if vol > 1 then vol := 1;
    
    //alter repeats for multiple loops
    if loops >= 1 then loops := loops- 1;
    
    //play the effect, seaching for a channel
    i := Mix_PlayChannel( -1, effect^.effect, loops);
    if i <> -1 then
    begin
      Mix_Volume(i, Trunc(vol * 128));
      soundChannels[i] := effect;
    end;
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'PlaySoundEffect');
    {$ENDIF}    
  end;
  
  procedure PlaySoundEffect(effect: SoundEffect; loops: LongInt); overload;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'PlaySoundEffect', HexStr(effect) + ' loops = ' + IntToStr(loops));
    {$ENDIF}
    
    PlaySoundEffect(effect, loops, 1.0);
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'PlaySoundEffect');
    {$ENDIF}
  end;
  
  procedure PlaySoundEffect(effect: SoundEffect); overload;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'PlaySoundEffect', HexStr(effect));
    {$ENDIF}
    
    PlaySoundEffect(effect, 1, 1.0);
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'PlaySoundEffect');
    {$ENDIF}    
  end;
  
  procedure PlaySoundEffect(effect: SoundEffect; vol: Single); overload;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'PlaySoundEffect', HexStr(effect) + ' vol = ' + FloatToStr(vol));
    {$ENDIF}
    
   PlaySoundEffect(effect, 1, vol);
   
   {$IFDEF TRACE}
     TraceExit('sgAudio', 'PlaySoundEffect');
   {$ENDIF}
  end;
  
  procedure PlayMusic(mus: Music; loops: LongInt); overload;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'PlayMusic', HexStr(mus) + ' loops = ' + IntToStr(loops));
    {$ENDIF}
    
    if not Assigned(mus) then begin RaiseException('Music not supplied'); exit; end;
    Mix_PlayMusic(mus^.music, loops);
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'PlayMusic');
    {$ENDIF}    
  end;
  
  procedure PlayMusic(mus: Music); overload;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'PlayMusic', HexStr(mus));
    {$ENDIF}
    
    PlayMusic(mus, -1);
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'PlayMusic');
    {$ENDIF}    
  end;

  procedure FadeMusicIn(mus: Music; loops, ms: LongInt); overload;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'FadeMusicIn', HexStr(mus) + ' loops = ' + IntToStr(loops) + ' ms = ' + IntToStr(ms));
    {$ENDIF}
    
    if not Assigned(mus) then begin RaiseException('Music not supplied'); exit; end;
    Mix_FadeInMusic(mus^.music, loops, ms);
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'FadeMusicIn');
    {$ENDIF}
  end;
  
  procedure FadeMusicIn(mus: Music; ms: LongInt); overload;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'FadeMusicIn', HexStr(mus) + ' ms = ' + IntToStr(ms));
    {$ENDIF}
    
    FadeMusicIn(mus, -1, ms);
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'FadeMusicIn');
    {$ENDIF}
  end;
  
  procedure FadeMusicOut(ms: LongInt);
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'FadeMusicOut', IntToStr(ms));
    {$ENDIF}
    
    Mix_FadeOutMusic(ms);
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'FadeMusicOut');
    {$ENDIF}
  end;
  
  function SoundPlaying(effect: Pointer): Boolean;
  var
    i: LongInt;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'SoundPlaying', HexStr(effect));
    {$ENDIF}
    
    result := false;
    
    for i := 0 to High(soundChannels) do
    begin
      if soundChannels[i] = effect then
      begin
        result := result or (Mix_Playing(i) <> 0);
        if result then break;
      end;
    end;
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'SoundPlaying', BoolToStr(result, true));
    {$ENDIF}
  end;
  
  function SoundEffectPlaying(effect: SoundEffect): Boolean;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'SoundEffectPlaying', HexStr(effect));
    {$ENDIF}
    
    result := SoundPlaying(effect);
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'SoundEffectPlaying', BoolToStr(result, true));
    {$ENDIF}
  end;
  
  function MusicPlaying(): Boolean;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'MusicPlaying', '');
    {$ENDIF}
    
    result := Mix_PlayingMusic() <> 0;
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'MusicPlaying', BoolToStr(result, true));
    {$ENDIF}
  end;
  
  //----------------------------------------------------------------------------
  
  function HasSoundEffect(name: String): Boolean;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'HasSoundEffect', name);
    {$ENDIF}
    
    result := _SoundEffects.containsKey(name);
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'HasSoundEffect', BoolToStr(result, true));
    {$ENDIF}
  end;

  function SoundEffectNamed(name: String): SoundEffect;
  var
    tmp : TObject;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'SoundEffectNamed', name);
    {$ENDIF}
    
    tmp := _SoundEffects.values[name];
    if assigned(tmp) then result := SoundEffect(tResourceContainer(tmp).Resource)
    else result := nil;
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'SoundEffectNamed', HexStr(result));
    {$ENDIF}
  end;
  
  function SoundEffectName(effect: SoundEffect): String;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'SoundEffectName', HexStr(effect));
    {$ENDIF}
    
    if assigned(effect) then result := effect^.name
    else result := '';
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'SoundEffectName', result);
    {$ENDIF}
  end;
  
  function SoundEffectFilename(effect: SoundEffect): String;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'SoundEffectFilename', HexStr(effect));
    {$ENDIF}
    
    if assigned(effect) then result := effect^.filename
    else result := '';
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'SoundEffectFilename', result);
    {$ENDIF}
  end;
  
  
  //----------------------------------------------------------------------------
  
  function HasMusic(name: String): Boolean;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'HasMusic', name);
    {$ENDIF}
    
    result := _Music.containsKey(name);
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'HasMusic', BoolToStr(result, true));
    {$ENDIF}
  end;
  
  function MusicNamed(name: String): Music;
  var
    tmp : TObject;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'MusicNamed', name);
    {$ENDIF}
    
    tmp := _Music.values[name];
    if assigned(tmp) then result := Music(tResourceContainer(tmp).Resource)
    else result := nil;
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'MusicNamed', HexStr(result));
    {$ENDIF}
  end;
  
  function MusicName(mus: Music): String;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'MusicName', HexStr(mus));
    {$ENDIF}
    
    if assigned(mus) then result := mus^.name
    else result := '';
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'MusicName', result);
    {$ENDIF}
  end;
  
  function MusicFilename(mus: Music): String;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'MusicFilename', HexStr(mus));
    {$ENDIF}
    
    if assigned(mus) then result := mus^.filename
    else result := '';
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'MusicFilename', result);
    {$ENDIF}
  end;
  
  
  
  //----------------------------------------------------------------------------
  
  procedure StopMusic();
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'StopMusic', '');
    {$ENDIF}
    
    Mix_HaltMusic();
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'StopMusic');
    {$ENDIF}
  end;
  
  procedure StopSoundEffect(effect: SoundEffect);
  var
    i: LongInt;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'StopSoundEffect', HexStr(effect));
    {$ENDIF}
    
    for i := 0 to High(soundChannels) do
    begin
      if soundChannels[i] = effect then
      begin
        Mix_HaltChannel(i);
        soundChannels[i] := nil;
      end;
    end;
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'StopSoundEffect');
    {$ENDIF}
  end;

//=============================================================================

  initialization
  begin
    {$IFDEF TRACE}
      TraceEnter('sgAudio', 'Initialise', '');
    {$ENDIF}
    
    InitialiseSwinGame();
    _SoundEffects := TStringHash.Create(False, 1024);
    _Music := TStringHash.Create(False, 1024);
    
    {$IFDEF TRACE}
      TraceExit('sgAudio', 'Initialise');
    {$ENDIF}
  end;

end.
