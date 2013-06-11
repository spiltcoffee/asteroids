//=============================================================================
// sgResources.pas
//=============================================================================
// Change History:
//
// Version 3:
// - 2009-12-21: Andrew : Moved bundle loading into the bundles directory.
//                      : Added the ability to load bundles within bundles.
// - 2009-12-18: Andrew : Removed links to old mappy tile code... need new map code
// - 2009-12-10: Andrew : Switched to DrawCell for start up animation
//                      : Added reading of cell information on bitmap loading
//                      : Switched to use Animation
// - 2009-12-07: Andrew : Moved out loading of image, font, and tilemap resources
// - 2009-11-10: Andrew : Changed sn to csn tags
// - 2009-11-06: Andrew : Moved out loading of audio resources... others to follow
// - 2009-10-16: Andrew : Moved free notifier, and ensured free notifier called after dispose
// - 2009-09-11: Andrew : Fixed to load resources without needing path
// - 2009-07-29: Andrew : Renamed Get... functions and check for opened audio
// - 2009-07-28: Andrew : Added ShowLogos splash screen
// - 2009-07-17: Andrew : Small fixes for return types.
// - 2009-07-14: Andrew : Added resource loading and freeing procedures.
//                      : Added FreeNotifier
// - 2009-07-08: Andrew : Fixed iterator use in release all
// - 2009-07-05: Clinton: Fixed delphi-support for ExtractDelimited, formatting
// - 2009-07-03: Andrew : Fixed header comments
// - 2009-06-23: Andrew : Created
//
//=============================================================================

{$I sgTrace.inc}

/// @module Resources
unit sgResources;

//=============================================================================
interface
  uses sgTypes;
//=============================================================================

  //----------------------------------------------------------------------------
  // Bundle handling routines
  //----------------------------------------------------------------------------

  /// Load a resource bundle showing load progress.
  ///
  /// @lib
  /// @sn loadResourceBundleNamed:%s showingProgress:%s
  procedure LoadResourceBundle(name: String; showProgress: Boolean); overload;

  /// Load a resource bundle showing load progress.
  ///
  /// @lib LoadResourceBundle(name, True)
  /// @uname LoadResourceBundleWithProgress
  procedure LoadResourceBundle(name: String); overload;

  /// Load a resource bundle mapping it to a given name, showing progress.
  ///
  /// @lib
  /// @sn mapResourceBundle:%s filename:%s showProgress:%s
  procedure MapResourceBundle(name, filename: String; showProgress: Boolean);

  /// Release the resource bundle with the given name.
  ///
  /// @lib
  procedure ReleaseResourceBundle(name: String);

  /// Returns true if the resource bundle is loaded.
  ///
  /// @lib
  function HasResourceBundle(name: String): Boolean;


  //----------------------------------------------------------------------------
  // Release all resources procedure
  //----------------------------------------------------------------------------

  /// Release all of the resources loaded by SwinGame.
  ///
  /// @lib
  procedure ReleaseAllResources();


  //----------------------------------------------------------------------------
  // Resource Path and Application Path
  //----------------------------------------------------------------------------

  /// Returns the path to a resource based on a base path and a the resource kind.
  ///
  /// @lib
  /// @sn pathToResourceBase:%s filename:%s resourceKind:%s
  function PathToResourceWithBase(path, filename: String; kind: ResourceKind): String; overload; // forward;

  /// Returns the path to a resource based on a base path and a the resource kind.
  ///
  /// @lib PathToOtherResourceWithBase
  /// @sn pathToResourceBase:%s filename:%s
  function PathToResourceWithBase(path, filename: String): String; overload; // forward;

  /// Returns the path to a resource given its filename, kind, and any subPaths. For example: to load
  /// the image 'bullet01.png' from the 'bullets' subdirectory you pass in 'bullet01.png' as the filename,
  /// ImageResource as the kind, and 'bullets' as the subPaths. This will then return the full path
  /// to the resource according to the platform in question.
  /// For example: .../Resources/images/bullets/bullet01.png
  ///
  /// @lib PathToResourceWithSubPaths
  /// @sn pathToResourceFilename:%s kind:%s subPaths:%s
  function PathToResource(filename: String; kind: ResourceKind; subPaths: StringArray): String; overload;

  /// Returns the path to the filename for a given file resource.
  ///
  /// @lib PathToResource
  /// @sn pathToResourceFilename:%s kind:%s
  function PathToResource(filename: String; kind: ResourceKind): String; overload;

  /// Returns the path to the filename within the game's resources folder.
  ///
  /// @lib PathToOtherResource
  /// @sn pathToResourceFilename:%s
  function PathToResource(filename: String): String; overload;

  /// Returns the path to the file with the passed in name for a given resource
  /// kind. This checks if the path exists, throwing an exception if the file
  /// does not exist in the expected locations.
  ///
  /// @lib
  /// @sn filenameFor:%s ofKind:%s
  function FilenameToResource(name: String; kind: ResourceKind): String;

  /// Sets the path to the executable. This path is used for locating game
  /// resources.
  ///
  /// @lib SetAppPathWithExe
  /// @sn setAppPath:%s withExe:%s
  procedure SetAppPath(path: String; withExe: Boolean); overload;

  /// Sets the path to the executable. This path is used for locating game
  /// resources.
  ///
  /// @lib SetAppPath
  procedure SetAppPath(path: String); overload;

  /// Returns the application path set within SwinGame. This is the path
  /// used to determine the location of the game's resources.
  ///
  /// @lib
  function AppPath(): String;


  //----------------------------------------------------------------------------
  // Startup related code
  //----------------------------------------------------------------------------

  /// Show the Swinburne and SwinGame logos for 1 second
  ///
  /// @lib
  procedure ShowLogos();


  //----------------------------------------------------------------------------
  // Notifier of resource freeing
  //----------------------------------------------------------------------------

  /// Using this procedure you can register a callback that is executed
  /// each time a resource is freed. This is called by different versions of
  /// SwinGame to keep track of resources and should not be called by user code.
  ///
  /// @lib
  procedure RegisterFreeNotifier(fn: FreeNotifier);


//=============================================================================
implementation
//=============================================================================

  uses SysUtils, StrUtils, Classes, // system
       stringhash, sgUtils,      // libsrc
       SDL, SDL_Mixer, SDL_ttf, SDL_Image,
       sgCore, sgText, sgAudio, sgGraphics, sgInput, sgCharacters, sgShared,
       sgSprites, sgTrace, sgImages, sgAnimations, sgUserInterface, sgMaps; // Swingame

  //----------------------------------------------------------------------------
  // Global variables for resource management.
  //----------------------------------------------------------------------------

  var
    _Bundles: TStringHash;
    // The full path location of the current executable (or script). This is
    // particuarly useful when determining the path to resources (images, maps,
    // sounds, music etc).


  procedure RegisterFreeNotifier(fn: FreeNotifier);
  begin
    {$IFDEF TRACE}
      TraceEnter('sgResources', 'sgResources.RegisterFreeNotifier');
      Trace('sgResources', 'Info', 'sgResources.RegisterFreeNotifier', 'fn: ' + HexStr(fn));
    {$ENDIF}
    _FreeNotifier := fn;
    {$IFDEF TRACE}
      TraceExit('sgResources', 'sgResources.RegisterFreeNotifier');
    {$ENDIF}

  end;

  //----------------------------------------------------------------------------
  // Private types
  //----------------------------------------------------------------------------

  type
    //
    // Used in loading bundles
    //
    TResourceIdentifier = record
      name, path: String;
      data: Array of LongInt;
      kind: ResourceKind;
    end;

    //
    // Used to store bundle details
    //
    TResourceBundle = class(tObject)
    public
      identifiers: array of TResourceIdentifier;
      constructor Create();
      procedure add(res: tResourceIdentifier);
      procedure LoadResources(showProgress: Boolean; kind: ResourceKind); overload;
      procedure LoadResources(showProgress: Boolean); overload;
      procedure ReleaseResources();
    end;

  //----------------------------------------------------------------------------
  // Private type functions/procedures
  //----------------------------------------------------------------------------

  constructor TResourceBundle.create();
  begin
    inherited create;
    SetLength(identifiers, 0);
  end;

  procedure TResourceBundle.add(res: tResourceIdentifier);
  begin
    SetLength(identifiers, Length(identifiers) + 1);
    identifiers[High(identifiers)] := res;
  end;

  procedure TResourceBundle.LoadResources(showProgress: Boolean; kind: ResourceKind); //overload;
  var
    current: tResourceIdentifier;
    i: LongInt;

    procedure rbLoadFont();
    begin
      if Length(current.data) <> 1 then
      begin
        RaiseException('Font must have a size assigned. ' + current.name);
        exit;
      end;
      MapFont(current.name, current.path, current.data[0])
    end;

    procedure rbLoadBitmap();
    var
      bmp: Bitmap;
    begin
      bmp := MapBitmap(current.name, current.path);

      if Length(current.data) > 0 then
      begin
        if Length(current.data) <> 5 then
        begin
            RaiseException('Invalid number of values for bitmap ' + current.name + ' expected 5 values for width, height, cellRows, cellCols, cellCount');
            exit;
        end;

        BitmapSetCellDetails(bmp, current.data[0], current.data[1], current.data[2], current.data[3], current.data[4]);
      end;
    end;

  begin
    for i := Low(identifiers) to High(identifiers) do
    begin
      current := identifiers[i];

      if current.kind = kind then
      begin
        case kind of
          BundleResource:     MapResourceBundle(current.name, current.path, false);
          BitmapResource:     rbLoadBitmap();
          FontResource:       rbLoadFont();
          SoundResource:      MapSoundEffect(current.name, current.path);
          MusicResource:      MapMusic(current.name, current.path);
          MapResource:        MapMap(current.name, current.path);
          AnimationResource:  MapAnimationTemplate(current.name, current.path);
          PanelResource:      MapPanel(current.name, current.path);
          CharacterResource:  MapCharacter(current.name, current.path);
          else
            RaiseException('Unkown recource kind in LoadResources' + IntToStr(LongInt(kind)));
        end;
      end;
    end;
  end;

  procedure TResourceBundle.LoadResources(showProgress: Boolean); //overload;
  var
    kind: ResourceKind;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgResources', 'TResourceBundle.LoadResources');
    {$ENDIF}

    for kind := Low(ResourceKind) to High(ResourceKind) do
    begin
      {$IFDEF TRACE}
        Trace('sgResources', 'Info', 'TResourceBundle.LoadResources', 'Calling for ' + IntToStr(LongInt(kind)));
      {$ENDIF}
      LoadResources(showProgress, kind);
    end;
    {$IFDEF TRACE}
      TraceExit('sgResources', 'TResourceBundle.LoadResources');
    {$ENDIF}
  end;

  procedure TResourceBundle.ReleaseResources();
  var
    current: tResourceIdentifier;
    i: LongInt;
  begin

    for i := Low(identifiers) to High(identifiers) do
    begin
      current := identifiers[i];

      case current.kind of
        BundleResource:     ReleaseResourceBundle(current.name);
        BitmapResource:     ReleaseBitmap(current.name);
        FontResource:       ReleaseFont(current.name);
        SoundResource:      ReleaseSoundEffect(current.name);
        MusicResource:      ReleaseMusic(current.name);
        PanelResource:      ReleasePanel(current.name);
        // MapResource:        ReleaseTileMap(current.name);
        AnimationResource:  ReleaseAnimationTemplate(current.name);
        CharacterResource:  ReleaseCharacter(current.name);
      end;
    end;
    SetLength(identifiers, 0);
  end;

  //----------------------------------------------------------------------------

  procedure ReleaseAllResources();
  begin
    ReleaseAllAnimationTemplates();
    ReleaseAllFonts();
    ReleaseAllBitmaps();
    ReleaseAllMusic();
    ReleaseAllSoundEffects();
    ReleaseAllPanels();
    ReleaseAllMaps();
    ReleaseAllCharacters();
    _Bundles.deleteAll();
  end;

  //----------------------------------------------------------------------------

  function StringToResourceKind(kind: String): ResourceKind;
  begin
    kind := Uppercase(Trim(kind));
    if kind = 'BUNDLE' then result := BundleResource
    else if kind = 'BITMAP'     then result := BitmapResource
    else if kind = 'SOUND'      then result := SoundResource
    else if kind = 'MUSIC'      then result := MusicResource
    else if kind = 'FONT'       then result := FontResource
    else if kind = 'MAP'        then result := MapResource
    else if kind = 'ANIM'       then result := AnimationResource
    else if kind = 'PANEL'      then result := PanelResource
    else if kind = 'CHARACTER'  then result := CharacterResource
    else result := OtherResource;
  end;

  function FilenameToResource(name: String; kind: ResourceKind): String;
  begin
    result := name;

    if not FileExists(result) then
    begin
      result := PathToResource(name, kind);

      if not FileExists(result) then
      begin
        RaiseException('Unable to locate resource at ' + result);
        result := '';
        exit;
      end;
    end;
  end;

  //----------------------------------------------------------------------------

  procedure LoadResourceBundle(name: String; showProgress: Boolean); overload;
  begin
    MapResourceBundle(name, name, showProgress);
  end;

  // Called to read in each line of the resource bundle.
  // ptr is a pointer to a tResourceBundle to load details into
  procedure ProcessBundleLine(const line: LineData; ptr: Pointer);
  var
    delim: TSysCharSet;
    i: LongInt;
    current: tResourceIdentifier;
  begin
    delim := [ ',' ]; //comma delimited

    current.kind := StringToResourceKind(ExtractDelimited(1, line.data, delim));
    current.name := ExtractDelimited(2, line.data, delim);

    if Length(current.name) = 0 then
    begin
      RaiseException('No name for resource.');
      exit;
    end;

    current.path := ExtractDelimited(3, line.data, delim);

    if Length(current.path) = 0 then
    begin
      RaiseException('No path supplied for resource.');
      exit;
    end;

    if CountDelimiter(line.data, ',') > 2 then
    begin
      SetLength(current.data, CountDelimiter(line.data, ',') - 2);

      for i := 4 to CountDelimiter(line.data, ',') + 1 do //Start reading from the 4th position (after the 3rd ,)
      begin
        if not TryStrToInt(ExtractDelimited(i, line.data, delim), current.data[i - 4]) then
        begin
          RaiseException('Invalid data expected a whole number at position ' + IntToStr(i + 1));
          exit;
        end;
      end;
    end
    else
    begin
      SetLength(current.data, 0);
    end;

    //WriteLn('Bundle: ', current.name, ' - ', current.path, ' - ', current.size);
    tResourceBundle(ptr).add(current);
  end;

  procedure MapResourceBundle(name, filename: String; showProgress: Boolean);
  var
    bndl: tResourceBundle;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgResources', 'LoadResourceBundle');
    {$ENDIF}

    if _Bundles.containsKey(name) then
    begin
      RaiseException('Error loaded Resource Bundle resource twice, ' + name);
      exit;
    end;

    bndl := tResourceBundle.Create();
    ProcessLinesInFile(filename, BundleResource, @ProcessBundleLine, bndl);
    bndl.LoadResources(showProgress);

    if not _Bundles.setValue(name, bndl) then //store bundle
    begin
      bndl.ReleaseResources();
      bndl.Free();
      RaiseException('Error loaded Bundle twice, ' + name);
      exit;
    end;

    {$IFDEF TRACE}
      TraceExit('sgResources', 'LoadResourceBundle');
    {$ENDIF}
  end;

  procedure LoadResourceBundle(name: String); overload;
  begin
    LoadResourceBundle(name, True);
  end;

  function HasResourceBundle(name: String): Boolean;
  begin
    result := _Bundles.containsKey(name);
  end;

  procedure ReleaseResourceBundle(name: String);
  var
    bndl: tResourceBundle;
  begin
    if HasResourceBundle(name) then
    begin
      bndl := tResourceBundle(_Bundles.remove(name));
      bndl.ReleaseResources();
      bndl.Free();
    end;
  end;

  //----------------------------------------------------------------------------




  function PathToResourceWithBase(path, filename: String; kind: ResourceKind): String; overload;
  begin
    case kind of
    {$ifdef UNIX}
      BundleResource:     result := PathToResourceWithBase(path, 'bundles/' + filename);
      FontResource:       result := PathToResourceWithBase(path, 'fonts/' + filename);
      SoundResource:      result := PathToResourceWithBase(path, 'sounds/' + filename);
      BitmapResource:     result := PathToResourceWithBase(path, 'images/' + filename);
      MapResource:        result := PathToResourceWithBase(path, 'maps/' + filename);
      AnimationResource:  result := PathToResourceWithBase(path, 'animations/' + filename);
      PanelResource:      result := PathToResourceWithBase(path, 'panels/' + filename);
      CharacterResource:  result := PathToResourceWithBase(path, 'characters/' + filename);
    {$else}
      BundleResource:     result := PathToResourceWithBase(path, 'bundles\' + filename);
      FontResource:       result := PathToResourceWithBase(path, 'fonts\' + filename);
      SoundResource:      result := PathToResourceWithBase(path, 'sounds\' + filename);
      BitmapResource:     result := PathToResourceWithBase(path, 'images\' + filename);
      MapResource:        result := PathToResourceWithBase(path, 'maps\' + filename);
      AnimationResource:  result := PathToResourceWithBase(path, 'animations\' + filename);
      PanelResource:      result := PathToResourceWithBase(path, 'panels\' + filename);
      CharacterResource:  result := PathToResourceWithBase(path, 'characters\' + filename);
    {$endif}

      else result := PathToResourceWithBase(path, filename);
    end;
  end;

  function PathToResourceWithBase(path, filename: String): String; overload;
  begin
    {$ifdef UNIX}
      {$ifdef DARWIN}
        result := path + '/../Resources/';
      {$else}
        result := path + '/Resources/';
      {$endif}
    {$else}
    //Windows
      result := path + '\Resources\';
    {$endif}
    result := result + filename;
  end;

  function PathToResource(filename: String): String; overload;
  begin
    result := PathToResourceWithBase(applicationPath, filename);
  end;

  function PathToResource(filename: String; kind: ResourceKind): String; overload;
  begin
    result := PathToResourceWithBase(applicationPath, filename, kind);
  end;

  function PathToResource(filename: String; kind: ResourceKind; subPaths: StringArray): String; overload;
  var
    temp: String;
    i: LongInt;
  begin
    if Length(subPaths) > 0 then
    begin
      temp := '';

      for i := 0 to High(subPaths) do
      begin
        {$ifdef UNIX}
          temp := temp + subPaths[i] + '/';
        {$else} // Windows
          temp := temp + subPaths[i] + '\';
        {$endif}
      end;

      filename := temp + filename;
    end;

    result := PathToResource(filename, kind)
  end;

  procedure SetAppPath(path: String); overload;
  begin
    SetAppPath(path, True);
  end;

  procedure SetAppPath(path: String; withExe: Boolean);
  begin
    if withExe then applicationPath := ExtractFileDir(path)
    else applicationPath := path;
  end;

  function AppPath(): String;
  begin
    result := applicationPath;
  end;


//----------------------------------------------------------------------------

  procedure ShowLogos();
  const
    ANI_X = 143;
    ANI_Y = 134;
    ANI_W = 546;
    ANI_H = 327;
    ANI_V_CELL_COUNT = 6;
    ANI_CELL_COUNT = 11;
  var
    i: LongInt;
    f: Font;
    txt: String;
    oldW, oldH, XOffset, YOffset: LongInt;
    //isStep: Boolean;
    isPaused: Boolean;
    isSkip: Boolean;
    startAni: Animation;

    procedure InnerProcessEvents();
    begin
      ProcessEvents();
      if (KeyDown(vk_LSUPER) or KeyDown(vk_LCTRL)) and KeyTyped(vk_p) then
      begin
        isPaused := not isPaused;
      end;
      if WindowCloseRequested() or KeyDown(vk_Escape) then isSkip := true;
    end;
  begin

    isPaused := false;
    isSkip := false;

    {$IFDEF TRACE}
      TraceEnter('sgResources', 'ShowLogos');
    {$ENDIF}
    try
      try
        XOffset := (ScreenWidth() div 2) - 400;
        YOffset := (ScreenHeight() div 2) - 300;
        oldW := ScreenWidth();
        oldH := ScreenHeight();
        if (oldW < 800) or (oldH < 600) then
          ChangeScreenSize(800, 600);

        LoadResourceBundle('splash.txt', False);

        ClearScreen();
        DrawBitmap(BitmapNamed('Swinburne'), 286 + XOffset, 171 + YOffset);
        f := FontNamed('ArialLarge');
        txt := 'SwinGame API by Swinburne University of Technology';
        DrawText(txt, ColorWhite, f, ((ScreenWidth() - TextWidth(f, txt)) div 2), 500 + YOffset);
        f := FontNamed('LoadingFont');
        DrawText(DLL_VERSION, ColorWhite, f, 5 + XOffset, 580 + YOffset);

        i := 1;
        while isPaused or (i < 60) do
        begin
          i += 1;
          InnerProcessEvents();
          RefreshScreen(60);
          if isSkip then break;
        end;

        startAni := CreateAnimation('splash', AnimationTemplateNamed('Startup'));

        while not AnimationEnded(startAni) do
        begin
          DrawBitmap(BitmapNamed('SplashBack'), 0 + XOffset, 0 + YOffset);

          DrawAnimation(startAni, BitmapNamed('SwinGameAni'), ANI_X + XOffset, ANI_Y + YOffset);
          UpdateAnimation(startAni);

          RefreshScreen();
          InnerProcessEvents();
          if isSkip then break;
          Delay(15);
        end;

        while SoundEffectPlaying(SoundEffectNamed('SwinGameStart')) or isPaused do
        begin
          InnerProcessEvents();
          if isSkip then break;
        end;

      except on e:Exception do
        {$IFDEF TRACE}
        begin
          Trace('sgResources', 'Error', 'ShowLogos', 'Error loading and drawing splash.');
          Trace('sgResources', 'Error', 'ShowLogos', e.Message);
        end;
        {$ENDIF}
      end;
    finally
      try
        ReleaseResourceBundle('splash.txt');
      except on e1: Exception do
        {$IFDEF TRACE}
        begin
          Trace('sgResources', 'Error', 'ShowLogos', 'Error freeing splash.');
          Trace('sgResources', 'Error', 'ShowLogos', e1.Message);
         end;
        {$ENDIF}
      end;

      if (oldW < 800) or (oldH < 600) then
        ChangeScreenSize(oldW, oldH);
    end;

    {$IFDEF TRACE}
      TraceExit('sgResources', 'ShowLogos');
    {$ENDIF}
  end;



//=============================================================================

  initialization
  begin
    {$IFDEF TRACE}
      TraceEnter('sgResources', 'initialization');
    {$ENDIF}

    InitialiseSwinGame();

    _Bundles := TStringHash.Create(False, 1024);

    try
        if ParamCount() >= 0 then SetAppPath(ParamStr(0), True)
    except
    end;

    {$IFDEF TRACE}
      TraceExit('sgResources', 'initialization');
    {$ENDIF}
  end;

end.
