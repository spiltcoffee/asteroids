//=============================================================================
// sgCore.pas
//=============================================================================
//
// The Core unit contains the main SwinGame routines and data types. These will
// be required by any game using the API.
//
// Change History:
//
// Version 3:
// - 2010-02-01: Aaron  : Added ColorToStr
// - 2010-01-04: Andrew : Fixed ColorFrom to include RGB and A
// - 2009-12-18: Andrew : Added screen rect cache
// - 2009-11-11: Andrew : Updated amask for screen surface.
// - 2009-11-10: Andrew : Added sn and csn tags, and added comments to code
//                      : Removed Timers
// - 2009-10-16: Andrew : Fixed order of free notifier calls
// - 2009-10-02: Andrew : Added random color, reset timer
// - 2009-09-11: Andrew : Added tracing code
// - 2009-07-28: Andrew : Calling ShowLogos splash screen
//                      : Added simple random funtions.
// - 2009-07-27: Andrew : Added code to cycle auto release pool for Objective C
// - 2009-07-24: Andrew : Added additional HSB code and renamed other color function
// - 2009-07-10: Andrew : Moved initialisation code to sgShared
// - 2009-07-02: Andrew : Added comments for Timer exporting.
// - 2009-06-29: Andrew : Renamed timer and version related functions,
//                      : Added comments to color and timer functions and procedures.
//                      : Changed UnPause timer to ResumeTimer
// - 2009-06-26: Andrew : Fixed FPS calculation.
// - 2009-06-23: Clinton: Initial format/comment cleanup...
//                      : Reordered / grouped all methods
//                      : Removed private ClearArray (only one line)
//                      : Renamed private _fpsData, _screen and _lastUpdateTime
//                      : Renamed private _InitFPSData and removed params
//                      : Renamed FPSCalcInfo to FPSData, renamed internals
//
// - 2009-06-23: Andrew: Added getting and setting of AppPath
// - 2009-06-05: Andrew: Moved out shared data/functions
// - 2009-06-04: Andrew: Started on processing comments.
//
// Version 2:
// - 2008-12-17: Andrew: Moved all integers to LongInt
// - 2008-12-10: Andrew: Added Matrix type to Core.
//                       Removed W from Vector
//                       Added Rotate and Zoom to Sprite
//                       Moved to manual double buffer
//                       Added matrix to allow matrix manipulation in Shapes package
// - 2008-12-09: Andrew: Added in correction to fix issue with FPC 2.2.2 on Mac.
//
// Version 1.1.6:
// - 2008-05-09: Andrew: Added tracing for OpenGraphicsWindow
// Version 1.1:
// - 2008-04-02: Andrew: Added handling of other resources
// - 2008-03-09: Andrew: Added extra exception handling
// - 2008-02-16: Andrew: Added Mac boot support, and
//                       Fixed scr bitmap to have width and height
// - 2008-01-28: Andrew: Fixed Toggle issue.
// - 2008-01-27: Andrew: Implemented the Change of Screen size fix..
//                       Found a different bug which means that the changes
//                       were not needed. Need to test in windows
// - 2008-01-21: Aki: Implemented timer
// - 2008-01-17: Aki + Andrew: Refactor
//
// Version 1.0:
// - Various
//=============================================================================

{$I sgTrace.inc}
{$IFDEF UNIX}
  {$IFNDEF DARWIN}
    {$linklib gcc}
  {$ENDIF}
{$ENDIF}

/// SwinGame's Core is responsible for core functionality such as creating
/// the game window, coordinating event processing, and refreshing the
/// screen. Core also contains components that can be used to create and
/// manage timers, sleep during execution, and other time related management.
///
/// @module Core
/// @static
unit sgCore;

//=============================================================================
interface
  uses sgTypes, SDL;
//=============================================================================


  //----------------------------------------------------------------------------
  // Library Version
  //----------------------------------------------------------------------------

  /// Retrieves a string representing the version of SwinGame that is executing.
  /// This can be used to check that the version supports the features required
  /// for your game.
  ///
  /// @lib
  function SwinGameVersion(): String;



  //----------------------------------------------------------------------------
  // Exception Notification/Message
  //----------------------------------------------------------------------------

  /// This function can be used to retrieve a message containing the details of
  /// the last error that occurred in SwinGame.
  ///
  /// @lib
  function ExceptionMessage(): String;

  /// This function tells you if an error occurred with the last operation in
  /// SwinGame.
  ///
  /// @lib
  function ExceptionOccured(): Boolean;



  //----------------------------------------------------------------------------
  // Icon / Window Open / Screen Size / Resize
  //----------------------------------------------------------------------------

  /// Sets the icon for the window. This must be called before openning the
  /// graphics window. The icon is loaded as a bitmap, though this can be from
  /// any kind of bitmap file.
  ///
  /// @param filename The name of the file to load as the images icon
  ///
  ///Side Effects
  /// - The icon will be loaded and used as the windows icon when the window
  /// is opened.
  ///
  /// @lib
  procedure SetIcon(filename: String);

  /// Opens the graphical window so that it can be drawn onto. You can set the
  /// icon for this window using SetIcon. The window itself is only drawn when
  /// you call RefreshScreen. All windows are opened at 32 bits per pixel. You
  /// can toggle fullscreen using ToggleFullScreen. The window is closed when
  /// the application terminates.
  ///
  /// @param caption The caption for the window
  /// @param width The width of the window
  /// @param height The height of the window
  ///
  /// Side Effects:
  /// - A graphical window is opened
  ///
  /// @lib
  /// @uname OpenGraphicsWindow
  /// @sn openGraphicsWindow:%s width:%s height:%s
  procedure OpenGraphicsWindow(caption: String; width, height: LongInt; fullscreen, border, mouse, logo: Boolean); overload;

  /// Opens the graphical window as an 800 x 600 window. See OpenGramhicsWinddow
  /// for more options.
  /// @param caption: The caption for the window
  ///
  /// Side Effects:
  /// - A graphical window is opened
  ///
  /// @lib OpenGraphicsWindow(caption, 800, 600)
  /// @uname OpenGraphicsWindow800x600
  /// @sn openGraphicsWindow:%s
  procedure OpenGraphicsWindow(caption: String); overload;

  /// Changes the size of the screen.
  ///
  /// @param width, height: The new width and height of the screen
  ///
  /// Side Effects:
  /// - The screen changes to the specified size
  ///
  /// @lib
  /// @sn changeScreenSizeToWidth:%s height:%s
  procedure ChangeScreenSize(width, height: LongInt);

  /// Switches the application to full screen or back from full screen to
  /// windowed.
  ///
  /// Side Effects:
  /// - The window switched between fullscreen and windowed
  ///
  /// @lib
  procedure ToggleFullScreen();

  /// Returns whether fullscreen is enabled or not
  ///
  /// @returns: Boolean value for whether fullscreen is on or not
  ///
  /// @lib
  function IsFullScreen(): Boolean;

  /// Toggle the Window border mode. This enables you to toggle from a bordered
  /// window to a borderless window.
  ///
  /// @lib
  procedure ToggleWindowBorder();

  /// Returns the width of the screen currently displayed.
  ///
  /// @returns: The screen's width
  ///
  /// @lib
  ///
  /// @class Core
  /// @static
  /// @getter ScreenWidth
  function ScreenWidth(): LongInt;

  /// Returns the height of the screen currently displayed.
  ///
  /// @returns: The screen's height
  ///
  /// @lib
  ///
  /// @class Core
  /// @static
  /// @getter ScreenHeight
  function ScreenHeight(): LongInt;

  /// Saves the current screen a bitmap file. The file will be saved into the
  /// current directory.
  ///
  /// @param basename   The base name for the screen shot. e.g. "GemCollector"
  ///
  /// Side Effects:
  /// - Saves the current screen image to a bitmap file.
  ///
  /// @lib TakeScreenshot
  procedure TakeScreenshot(basename: String);



  //----------------------------------------------------------------------------
  // Game-loop Essentials: WindowOpen, ProcessEvents, WindowClose
  //----------------------------------------------------------------------------

  /// Checks to see if the window has been asked to close. You need to handle
  /// this if you want the game to end when the window is closed. This value
  /// is updated by the ProcessEvents routine.
  ///
  /// @returns: True if the window has been requested to close.
  ///
  /// @lib WindowCloseRequested
  function WindowCloseRequested(): Boolean;

  /// ProcessEvents allows the SwinGame API to react to user interactions. This
  /// routine checks the current keyboard and mouse states. This routine must
  /// be called frequently within your game loop to enable user interaction.
  ///
  /// Side Effects
  /// - Reads user interaction events
  /// - Updates keys down, text input, etc.
  ///
  /// @lib ProcessEvents
  procedure ProcessEvents();


  //----------------------------------------------------------------------------
  // Refreshing the screen
  //----------------------------------------------------------------------------

  /// Draws the current drawing to the screen. This must be called to display
  /// anything to the screen. This will draw all drawing operations, as well
  /// as the text being entered by the user.
  ///
  /// Side Effects:
  /// - The current drawing is shown on the screen.
  ///
  /// @lib RefreshScreen
  procedure RefreshScreen(); overload;

  /// Refresh with a target FPS. This will delay a period of time that will
  /// approximately meet the targetted frames per second.
  ///
  /// @lib RefreshScreenRestrictFPS
  procedure RefreshScreen(TargetFPS: UInt32); overload;


  //----------------------------------------------------------------------------
  // Random
  //----------------------------------------------------------------------------

  /// Generates a random number between 0 and 1.
  ///
  /// @lib
  function Rnd() : Single; overload;

  /// Generates a random integer up to (but not including) ubound. Effectively,
  /// the ubound value specifies the number of random values to create.
  ///
  /// @lib RndUpto
  function Rnd(ubound: LongInt): LongInt; overload;


  //----------------------------------------------------------------------------
  // Color
  //----------------------------------------------------------------------------

  /// Maps a color from a given bitmap. This is used when determining color
  /// keys for transparent images.
  ///
  /// @param bmp:   the bitmap to get the color for
  /// @param apiColor:     The api color to match
  /// @returns:           The color matched to the bitmaps pixel format
  ///
  /// @lib ColorFromBitmap
  /// @sn colorFrom:%s apiColor:%s
  function ColorFrom(bmp: Bitmap; apiColor: Color): Color;

  /// Creates and returns a random color where R, G, B and A are all randomised.
  ///
  /// @lib
  function RandomColor(): Color;

  /// Creates and returns a random color where R, G, and B are all randomised, and A is set
  /// to the passed in value.
  ///
  /// @param alpha: the opacity of the random color
  ///
  /// @lib
  function RandomRGBColor(alpha: Byte): Color;

  /// Gets a color given its RGBA components.
  ///
  /// @param red, green, blue, alpha:  Components of the color
  /// @returns: The matching colour
  ///
  /// @lib
  /// @sn rgbaColorRed:%s green:%s blue:%s alpha:%s
  function RGBAColor(red, green, blue, alpha: Byte): Color;

  /// Gets a color given its RGB components.
  ///
  /// @param red, green, blue:   Components of the color
  /// @returns:                 The matching colour
  ///
  /// @lib RGBAColor(red, green, blue, 255)
  /// @uname RGBColor
  /// @sn rgbColorRed:%s green:%s blue:%s
  function RGBColor(red, green, blue: Byte): Color;

  /// Gets a color given its RGBA components.
  ///
  /// @lib
  /// @sn colorComponentsOf:%s red:%s green:%s blue:%s alpha:%s
  procedure ColorComponents(c: Color; out r, g, b, a: byte);


  /// returns color to string.
  ///
  /// @lib
  function  ColorToString(c: Color): string;

  /// Returns a color from a floating point RBG value set.
  ///
  /// @param r,g,b: Components for color 0 = none 1 = full
  ///
  /// @lib
  /// @sn rgbFloatColorRed:%s green:%s blue:%s
  function RGBFloatColor(r,g,b: Single): Color;

  /// Returns a color from a floating point RBGA value set.
  ///
  /// @param r,g,b,a: Components for color 0 = none 1 = full
  ///
  /// @lib
  /// @sn rgbaFloatColorRed:%s green:%s blue:%s alpha:%s
  function RGBAFloatColor(r,g,b, a: Single): Color;

  /// Returs a color from the HSB input.
  ///
  /// @param hue, saturation, brightness: Values between 0 and 1
  /// @returns The matching color
  ///
  /// @lib
  /// @sn hsbColorHue:%s sat:%s bri:%s
  function HSBColor(hue, saturation, brightness: Single): Color;

  /// Get the transpareny value of `color`.
  ///
  /// @lib
  function TransparencyOf(c: Color): byte;

  /// Get the red value of `color`.
  ///
  /// @lib
  function RedOf(c: Color): byte;

  /// Get the green value of `color`.
  ///
  /// @lib
  function GreenOf(c: Color): byte;

  /// Get the blue value of `color`.
  ///
  /// @lib
  function BlueOf(c: Color): byte;

  /// Gets the hue, saturation, and brightness values from
  /// the color.
  ///
  /// @lib
  /// @sn hsbValueOf:%s hue:%s sat:%s bri:%s
  procedure HSBValuesOf(c: Color; out h, s, b: Single);

  /// Get the hue of the `color`.
  ///
  /// @lib
  function HueOf(c: Color): Single;

  /// Get the saturation of the `color`.
  ///
  /// @lib
  function SaturationOf(c: Color) : Single;

  /// Get the brightness of the `color`.
  ///
  /// @lib
  function BrightnessOf(c: Color) : Single;


  //----------------------------------------------------------------------------
  // Refresh / Delay / Framerate
  //----------------------------------------------------------------------------

  /// Returns the average framerate for the last 10 frames as an integer.
  ///
  /// @returns     The current average framerate
  ///
  /// @lib
  function GetFramerate(): LongInt;

  /// Gets the number of milliseconds that have passed. This can be used to
  /// determine timing operations, such as updating the game elements.
  ///
  /// @returns     The number of milliseconds passed
  ///
  /// @lib
  function GetTicks(): UInt32;

  /// Puts the process to sleep for a specified number of
  /// milliseconds. This can be used to add delays into your
  /// game.
  ///
  /// @param time - The number of milliseconds to sleep
  ///
  /// Side Effects
  /// - Delay before returning
  ///
  /// @lib
  procedure Delay(time: UInt32);

  /// Returns the calculated framerate averages, highest, and lowest values along with
  /// the suggested rendering color.
  ///
  /// @lib
  /// @sn calculateFramerateAvg:%s high:%s low:%s color:%s
  procedure CalculateFramerate(out average, highest, lowest: String; out textColor: Color);


  var
    //Preset colours, do not change these values.
    ColorBlue, ColorGreen, ColorRed, ColorWhite, ColorBlack, ColorYellow,
    ColorPink, ColorTurquoise, ColorGrey, ColorMagenta, ColorTransparent,
    ColorLightGrey, ColorOrange: Color;

//=============================================================================
implementation
  uses
    SysUtils, Math, Classes, //System
    SDL_Image, SDL_gfx, //SDL
    sgSavePNG, sgShared, sgTrace, sgEventProcessing, //SwinGame shared library code
    sgResources, sgGeometry, sgImages, sgInput, sgUserInterface; //SwinGame
//=============================================================================


  type
    // Details required for the Frames per second calculations.
    FPSData = record
      values: Array [0..59] of Single;
      pos: LongInt;
      max, min, avg: Single;
      ready: Boolean;
    end;

  var
    // Timing details related to calculating FPS
    _lastUpdateTime: UInt32;
    _screen: PSDL_Surface;
    _fpsData: FPSData;

  //---------------------------------------------------------------------------

  //---------------------------------------------------------------------------

  //Used to initialise the Frame Per Second data structure.
  procedure _InitFPSData();
  var
    i: LongInt;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', '_InitFPSData');
    {$ENDIF}

    // clear the array of values
    for i := Low(_fpsData.values) to High(_fpsData.values) do
      _fpsData.values[i] := 0;
    // zero the current insert position, and the loop count
    _fpsData.pos := 0;
    //_fpsData.loops := 0;
    // set the moving range and average to sensitble defaults
    _fpsData.max := 0;
    _fpsData.min := 0;
    _fpsData.avg := 0;
    _fpsData.ready := false;
    {$IFDEF TRACE}
      TraceExit('sgCore', '_InitFPSData');
    {$ENDIF}
  end;

  //----------------------------------------------------------------------------
  // Library Version
  //----------------------------------------------------------------------------

  function SwinGameVersion(): String;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'SwinGameVersion');
    {$ENDIF}
    result := DLL_VERSION;
    {$IFDEF TRACE}
      TraceExit('sgCore', 'SwinGameVersion');
    {$ENDIF}
  end;

  //----------------------------------------------------------------------------
  // Exception Notification/Message
  //----------------------------------------------------------------------------

  function ExceptionMessage(): String;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'ExceptionMessage');
    {$ENDIF}
    result := ErrorMessage;
    {$IFDEF TRACE}
      TraceExit('sgCore', 'ExceptionMessage');
    {$ENDIF}
  end;

  function ExceptionOccured(): Boolean;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'ExceptionOccured');
    {$ENDIF}
    result := HasException;
    {$IFDEF TRACE}
      TraceExit('sgCore', 'ExceptionOccured');
    {$ENDIF}
  end;

  //----------------------------------------------------------------------------
  // Set Icon / Window Open / Screen Size / Resize
  //----------------------------------------------------------------------------

  procedure _SetupScreen();
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', '_SetupScreen');
    {$ENDIF}
    if screen = nil then New(screen)
    else if (screen^.surface <> nil) then SDL_FreeSurface(screen^.surface);

    with _screen^.format^ do
    begin
      screen^.surface := SDL_CreateRGBSurface(SDL_HWSURFACE,
                                             ScreenWidth(), ScreenHeight(), 32,
                                             RMask, GMask, BMask,
                                             $ffffffff and not RMask
                                                and not GMask
                                                and not BMask);

      //WriteLn(RMask, ':', GMask, ':', BMask, ':', screen^.surface^.format^.AMask);

      //Turn off alpha blending for when scr is blit onto _screen
      SDL_SetAlpha(screen^.surface, 0, 255);
      SDL_FillRect(screen^.surface, @screen^.surface^.clip_rect, 0);

      baseSurface := screen^.surface;

      screen^.width := _screen^.w;
      screen^.height := _screen^.h;
      screenRect := BitmapRectangle(0,0,screen);
    end;
    {$IFDEF TRACE}
      TraceExit('sgCore', '_SetupScreen');
    {$ENDIF}
  end;

  /// Sets up the graphical window for the specified width and height.
  /// Sets the caption of the window, and the icon if one is specified.
  procedure _InitSDL(caption: String; screenWidth, screenHeight: LongInt);
  var
    icon: PSDL_Surface;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'InitSDL');
    {$ENDIF}

    if (screenWidth < 1) or (screenHeight < 1) then
    begin
      RaiseException('Screen Width and Height must be greater then 0 when opening a Graphical Window');
      exit;
    end;

    if Length(iconFile) > 0 then
    begin
      try
        icon := IMG_Load(PChar(iconFile));
        SDL_WM_SetIcon(icon, 0);
        SDL_FreeSurface(icon);
      except
        RaiseException('The icon file specified could not be loaded');
        exit;
      end;
    end;

    _screen := SDL_SetVideoMode(screenWidth, screenHeight, 32, SDL_HWSURFACE or SDL_DOUBLEBUF);
    if _screen = nil then
    begin
      RaiseException('Unable to create window drawing surface... ' + SDL_GetError());
      exit;
    end;

    _SetupScreen();
    if length(caption) > 0 then
      SDL_WM_SetCaption(PChar(caption), nil);

    {$IFDEF TRACE}
      TraceExit('sgCore', '_InitSDL');
    {$ENDIF}
  end;

  procedure SetIcon(filename: String);
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'SetIcon');
    {$ENDIF}
    iconFile := filename;
    {$IFDEF TRACE}
      TraceExit('sgCore', 'SetIcon');
    {$ENDIF}
  end;

  procedure OpenGraphicsWindow(caption: String; width: LongInt; height: LongInt; fullscreen, border, mouse, logo: Boolean); overload;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'OpenGraphicsWindow', caption + ': W' + IntToStr(width) + ': H' + IntToStr(height));
    {$ENDIF}

    if screen <> nil then
    begin
      RaiseException('Screen has been created. Cannot create multiple windows.');
      exit;
    end;

    try
      _InitSDL(caption, width, height);
      _InitFPSData();

      //Init the colors
      ColorWhite := RGBAColor(255, 255, 255, 255);
      ColorGreen := RGBAColor(0, 255, 0, 255);
      ColorBlue := RGBAColor(0, 0, 255, 255);
      ColorBlack := RGBAColor(0, 0, 0, 255);
      ColorRed := RGBAColor(255, 0, 0, 255);
      ColorYellow := RGBAColor(255, 255, 0, 255);
      ColorPink := RGBAColor(255, 20, 147, 255);
      ColorTurquoise := RGBAColor(0, 206, 209, 255);
      ColorGrey := RGBAColor(128, 128, 128, 255);
      ColorMagenta := RGBAColor(255, 0, 255, 255);
      ColorTransparent := RGBAColor(0, 0, 0, 0);
      ColorLightGrey := RGBAColor(200, 200, 200, 255);
      ColorOrange := RGBAColor(255, 153, 0, 255);

      GUISetForegroundColor(ColorGreen);
      GUISetBackgroundColor(ColorBlack);

      SDL_FillRect(screen^.surface, nil, ColorGrey);
      stringColor(screen^.surface, screenWidth div 2 - 30, screenHeight div 2, PChar('Loading ...'), ToGFXColor(ColorWhite));
      RefreshScreen();
    except on e: Exception do
      begin
        RaiseException('Error in OpenGraphicsWindow: ' + e.Message);
        exit;
      end;
    end;

    {$IFDEF TRACE}
      TraceIf(tlInfo, 'sgCore', 'Info', 'OpenGraphicsWindow', 'Window is open (' + caption + ' ' + IntToStr(width) + 'x' + IntToStr(height) + ')');
    {$ENDIF}

    if fullscreen then
      ToggleFullScreen();
    if not border then
      ToggleWindowBorder();
    ShowMouse(mouse);

	if logo then
		ShowLogos();
    LoadResourceBundle('FileDialog.txt');
    {$IFDEF TRACE}
      TraceExit('sgCore', 'OpenGraphicsWindow');
    {$ENDIF}
  end;


  procedure OpenGraphicsWindow(caption: String); overload;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'OpenGraphicsWindow');
    {$ENDIF}
    OpenGraphicsWindow(caption, 800,600, false, true, true, true);
    {$IFDEF TRACE}
      TraceExit('sgCore', 'OpenGraphicsWindow');
    {$ENDIF}
  end;

  procedure ToggleFullScreen();
  var
    oldScr: PSDL_Surface;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'ToggleFullScreen');
    {$ENDIF}
    oldScr := _screen;

    try
      //Remember... _screen is a pointer to screen buffer, not a "surface"!
      _screen := SDL_SetVideoMode(oldScr^.w, oldScr^.h, 32, oldScr^.flags xor SDL_FULLSCREEN);
    except on exc: Exception do
    end;
    {$IFDEF TRACE}
      TraceExit('sgCore', 'ToggleFullScreen');
    {$ENDIF}
  end;

  function IsFullScreen(): Boolean;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'IsFullScreen');
    {$ENDIF}

    result := (_screen^.flags and SDL_FULLSCREEN) > 0;

    {$IFDEF TRACE}
      TraceExit('sgCore', 'IsFullScreen');
    {$ENDIF}
  end;

  procedure ToggleWindowBorder();
  var
    oldScr: PSDL_Surface;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'ToggleWindowBorder');
    {$ENDIF}
    oldScr := _screen;

    try
      //Remember... _screen is a pointer to screen buffer, not a "surface"!
      _screen := SDL_SetVideoMode(oldScr^.w, oldScr^.h, 32, oldScr^.flags xor SDL_NOFRAME);
    except on exc: Exception do
    end;
    {$IFDEF TRACE}
      TraceExit('sgCore', 'ToggleWindowBorder');
    {$ENDIF}
  end;

  procedure ChangeScreenSize(width, height: LongInt);
  var
    oldScr: PSDL_Surface;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'ChangeScreenSize');
    {$ENDIF}
    if (screen = nil) then
    begin
      RaiseException('Screen has not been created. Unable to get screen width.');
      exit;
    end;

    if (width < 1) or (height < 1) then
    begin
      RaiseException('Screen Width and Height must be greater then 0 when resizing a Graphical Window');
      exit;
    end;

    if (width = ScreenWidth()) and (height = ScreenHeight()) then exit;

    oldScr := _screen;
    _screen := SDL_SetVideoMode(width, height, 32, oldScr^.flags);
    _SetupScreen();
    {$IFDEF TRACE}
      TraceExit('sgCore', 'ChangeScreenSize');
    {$ENDIF}
  end;

  function ScreenWidth(): LongInt;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'ScreenWidth');
    {$ENDIF}
    if (_screen = nil) then
    begin
      RaiseException('Screen has not been created. Unable to get screen width.');
      exit;
    end;

    result := _screen^.w;
    {$IFDEF TRACE}
      TraceExit('sgCore', 'ScreenWidth');
    {$ENDIF}
  end;

  function ScreenHeight(): LongInt;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'ScreenHeight');
    {$ENDIF}
    if (_screen = nil) then
    begin
      RaiseException('Screen has not been created. Unable to get screen height.');
      exit;
    end;
    result := _screen^.h;
    {$IFDEF TRACE}
      TraceExit('sgCore', 'ScreenHeight');
    {$ENDIF}
  end;

  procedure TakeScreenShot(basename: String);
  var
    path: String;
    filename: String;
    i: LongInt;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'TakeScreenShot');
    {$ENDIF}

    path := IncludeTrailingPathDelimiter(GetUserDir()) + 'Desktop' + PathDelim;
    if not DirectoryExists(path) then
      path := IncludeTrailingPathDelimiter(GetUserDir());

    filename := basename + '.png';

    i := 1;

    while FileExists(path + filename) do
    begin
      filename := basename + IntToStr(i) + '.png';
      i := i + 1;
    end;

    //if SDL_SaveBMP(screen^.surface, PChar(path + filename)) = -1 then
    if not png_save_surface(path + filename, screen^.surface) then
    begin
      RaiseException('Failed to save ' + basename + ': ' + SDL_GetError());
      exit;
    end;
    {$IFDEF TRACE}
      TraceExit('sgCore', 'TakeScreenShot');
    {$ENDIF}
  end;

  //----------------------------------------------------------------------------
  // Refresh / Delay / Framerate
  //----------------------------------------------------------------------------

  procedure Delay(time: UInt32);
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'Delay');
    {$ENDIF}
    if time > 0 then SDL_Delay(time);
    {$IFDEF TRACE}
      TraceExit('sgCore', 'Delay');
    {$ENDIF}
  end;

  function GetTicks(): UInt32;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'GetTicks');
    {$ENDIF}
    result := SDL_GetTicks();
    {$IFDEF TRACE}
      TraceExit('sgCore', 'GetTicks');
    {$ENDIF}
  end;

  function GetFramerate(): LongInt;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'GetFramerate');
    {$ENDIF}
    if _fpsData.avg = 0 then
      result := 60
    else
      result := Round(1000 / _fpsData.avg);
    {$IFDEF TRACE}
      TraceExit('sgCore', 'GetFramerate');
    {$ENDIF}
  end;

  procedure CalculateFramerate(out average, highest, lowest: String; out textColor: Color);
  var
    avg, hi, lo: Single;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'CalculateFramerate');
    {$ENDIF}
    if not _fpsData.ready then
    begin
      textColor := ColorBlue;
      average :='??.?';
      highest :='??.?';
      lowest  :='??.?';
      {$IFDEF TRACE}
        TraceExit('sgCore', 'CalculateFramerate');
      {$ENDIF}
      exit;
    end;

    if _fpsData.avg = 0 then
      avg := 9999
    else
      avg := (1000 / _fpsData.avg);

    lo := (1000 / _fpsData.max);
    hi := (1000 / _fpsData.min);

    Str(avg:4:1, average);
    Str(hi:4:1, highest);
    Str(lo:4:1, lowest);

    if avg < 10 then
      textColor := ColorRed
    else if avg < 50 then
      textColor := ColorYellow
    else
      textColor := ColorGreen;

    {$IFDEF TRACE}
      TraceExit('sgCore', 'CalculateFramerate');
    {$ENDIF}
  end;


  procedure _UpdateFPSData(delta: UInt32);
    function RunningAverage(var values: Array of Single; newValue: UInt32; var pos: LongInt): Single;
    var
      i: LongInt;
      sum: Double;
    begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', '_UpdateFPSData');
    {$ENDIF}
      // insert the newValue as the position specified
      values[pos] := newValue;

      // calculate the sum for the average
      sum := 0;
      for i := Low(values) to High(values) do
        sum := sum + values[i];
      result := sum / Length(values);

      //Inc position index, and wrap-around to start if needed
      pos := pos + 1;
      if pos > High(values) then
      begin
        pos := Low(values);
        if not _fpsData.ready then
        begin
          _fpsData.max := _fpsData.avg;
          _fpsData.min := _fpsData.avg;
          _fpsData.ready := True;
        end;
      end;
    end;
  begin
    _fpsData.avg := RunningAverage(_fpsData.values, delta, _fpsData.pos);

    if _fpsData.avg = 0.0 then _fpsData.avg := 0.01;

    //Adjust the min/maxes
    if _fpsData.ready then
    begin
      if _fpsData.avg > _fpsData.max then _fpsData.max := _fpsData.avg
      else if _fpsData.avg < _fpsData.min then _fpsData.min := _fpsData.avg;
    end;
    {$IFDEF TRACE}
      TraceExit('sgCore', '_UpdateFPSData');
    {$ENDIF}
  end;



  //----------------------------------------------------------------------------
  // Game Loop Essentials
  //----------------------------------------------------------------------------

  function WindowCloseRequested(): Boolean;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'WindowCloseRequested');
    {$ENDIF}

    if sdlManager = nil then begin
      result := false;
    end
    else begin
      result := sdlManager.HasQuit();
    end;

    {$IFDEF TRACE}
      TraceExit('sgCore', 'WindowCloseRequested');
    {$ENDIF}
  end;

  procedure ProcessEvents();
  var
    x, y: LongInt;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'ProcessEvents');
    {$ENDIF}
    {$ifdef DARWIN}
    // CyclePool();
    {$endif}
    SDL_GetRelativeMouseState(x, y);
    sdlManager.ProcessEvents();
    {$IFDEF TRACE}
      TraceExit('sgCore', 'ProcessEvents');
    {$ENDIF}
  end;

  procedure RefreshScreen(); overload;
  var
    nowTime: UInt32;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'RefreshScreen');
    {$ENDIF}
    //Draw then delay
    sdlManager.DrawCollectedText(screen^.surface);
    SDL_BlitSurface(screen^.surface, nil, _screen, nil);
    SDL_Flip(_screen);

    nowTime := GetTicks();
    _UpdateFPSData(nowTime - _lastUpdateTime); // delta
    _lastUpdateTime := nowTime;
    {$IFDEF TRACE}
      TraceExit('sgCore', 'RefreshScreen');
    {$ENDIF}
  end;

  procedure RefreshScreen(TargetFPS: UInt32); overload;
  var
    nowTime: UInt32;
    delta, delayTime: UInt32;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'RefreshScreen');
    {$ENDIF}
    sdlManager.DrawCollectedText(screen^.surface);
    SDL_BlitSurface(screen^.surface, nil, _screen, nil);
    SDL_Flip(_screen);

    nowTime := GetTicks();
    delta := nowTime - _lastUpdateTime;

    //dont sleep if 1ms remaining...
    while (delta + 1) * TargetFPS < 1000 do
    begin
      delayTime := (1000 div TargetFPS) - delta;
      Delay(delayTime);
      nowTime := GetTicks();
      delta := nowTime - _lastUpdateTime;
    end;

    _UpdateFPSData(delta);
    _lastUpdateTime := nowTime;
    {$IFDEF TRACE}
      TraceExit('sgCore', 'RefreshScreen');
    {$ENDIF}
  end;

  //----------------------------------------------------------------------------
  // Colour
  //----------------------------------------------------------------------------
  function  ColorToString(c: Color): string;
  var
  r,g,b,a : byte;
  begin
  colorComponents(c,r,g,b,a);
  result:=IntToStr(r)+','+IntToStr(g)+','+IntToStr(b)+','+IntToStr(a);
  end;

  procedure ColorComponents(c: Color; out r, g, b, a: byte);
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'ColorComponents');
    {$ENDIF}
    if baseSurface = nil then
    begin
      RaiseException('Cannot read screen format. Ensure window is open.');
      exit;
    end;
    SDL_GetRGBA(c, baseSurface^.Format, @r, @g, @b, @a);
    {$IFDEF TRACE}
      TraceExit('sgCore', 'ColorComponents');
    {$ENDIF}
  end;

  function RedOf(c: Color): byte;
  var
    r,g,b,a: Byte;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'RedOf');
    {$ENDIF}
    ColorComponents(c, r, g, b, a);
    result := r;
    {$IFDEF TRACE}
      TraceExit('sgCore', 'RedOf');
    {$ENDIF}
  end;

  function GreenOf(c: Color): byte;
  var
    r,g,b,a: Byte;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'GreenOf');
    {$ENDIF}
    ColorComponents(c, r, g, b, a);
    result := g;
    {$IFDEF TRACE}
      TraceExit('sgCore', 'GreenOf');
    {$ENDIF}
  end;

  function BlueOf(c: Color): byte;
  var
    r,g,b,a: Byte;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'BlueOf');
    {$ENDIF}
    ColorComponents(c, r, g, b, a);
    result := b;
    {$IFDEF TRACE}
      TraceExit('sgCore', 'BlueOf');
    {$ENDIF}
  end;

  function TransparencyOf(c: Color): byte;
  var
    r,g,b,a: Byte;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'TransparencyOf');
    {$ENDIF}
    ColorComponents(c, r, g, b, a);
    result := a;
    {$IFDEF TRACE}
      TraceExit('sgCore', 'TransparencyOf');
    {$ENDIF}
  end;

  procedure HSBValuesOf(c: Color; out h, s, b: Single);
  var
    red, green, blue, alpha: byte;
    rf, gf, bf: Single;
    minRGB, maxRGB, delta: Single;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'HSBValuesOf');
    {$ENDIF}
     H := 0.0 ;

     ColorComponents(c, red, green, blue, alpha);

     rf := red / 255;
     gf := green / 255;
     bf := blue / 255;

     minRGB := Min(Min(rf, gf), bf);
     maxRGB := Max(Max(rf, gf), bf);
     delta := (maxRGB - minRGB);

     b := maxRGB;
     if (maxRGB <> 0.0) then s := delta / maxRGB
     else s := 0.0;

     if (s <> 0.0) then
     begin
       if rf = maxRGB then h := (gf - bf) / Delta
       else
         if gf = maxRGB then h := 2.0 + (bf - rf) / Delta
         else
           if bf = maxRGB then h := 4.0 + (rf - gf) / Delta
     end
     else h := -1.0;
     h := h * 60 ;
     if h < 0.0 then h := h + 360.0;

     h := h / 360.0;
    {$IFDEF TRACE}
      TraceExit('sgCore', 'HSBValuesOf');
    {$ENDIF}
  end;

  function HueOf(c: Color) : Single;
  var
    s, b: Single;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'HueOf');
    {$ENDIF}
    HSBValuesOf(c, result, s, b);
    {$IFDEF TRACE}
      TraceExit('sgCore', 'HueOf');
    {$ENDIF}
  end;

  function SaturationOf(c: Color) : Single;
  var
    h, b: Single;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'SaturationOf');
    {$ENDIF}
    HSBValuesOf(c, h, result, b);
    {$IFDEF TRACE}
      TraceExit('sgCore', 'SaturationOf');
    {$ENDIF}
  end;

  function BrightnessOf(c: Color) : Single;
  var
    h, s: Single;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'BrightnessOf');
    {$ENDIF}
    HSBValuesOf(c, h, s, result);
    {$IFDEF TRACE}
      TraceExit('sgCore', 'BrightnessOf');
    {$ENDIF}
  end;

  function ColorFrom(bmp: Bitmap; apiColor: Color): Color;
  var
    r,g,b,a: Byte;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'ColorFrom');
    {$ENDIF}
    if (bmp = nil) or (bmp^.surface = nil) then
    begin
      RaiseException('Unable to get color as bitmap not specified');
      exit;
    end;

    ColorComponents(apiColor, r, g, b, a);

    result := SDL_MapRGBA(bmp^.surface^.format, r, g, b, a);
    {$IFDEF TRACE}
      TraceExit('sgCore', 'ColorFrom');
    {$ENDIF}
  end;

  function RGBAColor(red, green, blue, alpha: Byte): Color;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'RGBAColor');
    {$ENDIF}
    if (baseSurface = nil) or (baseSurface^.format = nil) then
    begin
      RaiseException('Unable to get RGBAColor as the window is not open');
      exit;
    end;

    try
      result := SDL_MapRGBA(baseSurface^.format, red, green, blue, alpha);
    except
      RaiseException('Error occured while trying to get a color from RGBA components');
      exit;
    end;
    {$IFDEF TRACE}
      TraceExit('sgCore', 'RGBAColor');
    {$ENDIF}
  end;

  function RGBColor(red, green, blue: Byte): Color;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'RGBColor');
    {$ENDIF}
    result := RGBAColor(red, green, blue, 255);
    {$IFDEF TRACE}
      TraceExit('sgCore', 'RGBColor');
    {$ENDIF}
  end;

  function RGBFloatColor(r,g,b: Single): Color;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'RGBFloatColor');
    {$ENDIF}
    result := RGBColor(Round(r * 255), Round(g * 255), Round(b * 255));
    {$IFDEF TRACE}
      TraceExit('sgCore', 'RGBFloatColor');
    {$ENDIF}
  end;

  function RGBAFloatColor(r,g,b, a: Single): Color;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'RGBAFloatColor');
    {$ENDIF}
    result := RGBAColor(Round(r * 255), Round(g * 255), Round(b * 255), Round(a * 255));
    {$IFDEF TRACE}
      TraceExit('sgCore', 'RGBAFloatColor');
    {$ENDIF}
  end;

  function HSBColor(hue, saturation, brightness: Single): Color;
  var
    domainOffset: Single;
    red, green, blue: Single;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'HSBColor');
    {$ENDIF}
    if brightness = 0 then
    begin
      result := ColorBlack;
      exit;
    end;

    if saturation = 0 then
    begin
      result := RGBFloatColor(brightness, brightness, brightness);
      exit;
    end;

    if hue < 1.0 / 6 then
    begin // red domain... green ascends
      domainOffset := hue;
      red   := brightness;
      blue  := brightness * (1.0 - saturation);
      green := blue + (brightness - blue) * domainOffset * 6;
    end
    else if hue < 2.0 / 6 then
    begin // yellow domain; red descends
      domainOffset := hue - 1.0 / 6;
      green := brightness;
      blue  := brightness * (1.0 - saturation);
      red   := green - (brightness - blue) * domainOffset * 6;
    end
    else if hue < 3.0 / 6 then
    begin // green domain; blue ascends
      domainOffset := hue - 2.0 / 6;
      green := brightness;
      red   := brightness * (1.0 - saturation);
      blue  := red + (brightness - red) * domainOffset * 6;
    end
    else if hue < 4.0 / 6 then
    begin // cyan domain; green descends
      domainOffset := hue - 3.0 / 6;
      blue  := brightness;
      red   := brightness * (1.0 - saturation);
      green := blue - (brightness - red) * domainOffset * 6;
    end
    else if hue < 5.0 / 6 then
    begin // blue domain; red ascends
      domainOffset := hue - 4.0 / 6;
      blue  := brightness;
      green := brightness * (1.0 - saturation);
      red   := green + (brightness - green) * domainOffset * 6;
    end
    else
    begin // magenta domain; blue descends
      domainOffset := hue - 5.0 / 6;
      red   := brightness;
      green := brightness * (1.0 - saturation);
      blue  := red - (brightness - green) * domainOffset * 6;
    end;

    result := RGBFloatColor(red, green, blue);
    {$IFDEF TRACE}
      TraceExit('sgCore', 'HSBColor');
    {$ENDIF}
  end;

  function RandomColor(): Color;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'RandomColor');
    {$ENDIF}
    result := RGBAFloatColor(Rnd(), Rnd(), Rnd(), Rnd());
    {$IFDEF TRACE}
      TraceExit('sgCore', 'RandomColor');
    {$ENDIF}
  end;

  function RandomRGBColor(alpha: Byte): Color;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'RandomRGBColor');
    {$ENDIF}
    result := RGBAColor(Byte(Rnd(256)), Byte(Rnd(256)), Byte(Rnd(256)), alpha);
    {$IFDEF TRACE}
      TraceExit('sgCore', 'RandomRGBColor');
    {$ENDIF}
  end;

  //----------------------------------------------------------------------------
  // Random
  //----------------------------------------------------------------------------

  function Rnd() : Single; overload;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'Rnd');
    {$ENDIF}
    result := System.Random();
    {$IFDEF TRACE}
      TraceExit('sgCore', 'Rnd');
    {$ENDIF}
  end;

  function Rnd(ubound: LongInt): LongInt; overload;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'Rnd');
    {$ENDIF}
    result := System.Random(ubound);
    {$IFDEF TRACE}
      TraceExit('sgCore', 'Rnd');
    {$ENDIF}
  end;


//=============================================================================

  initialization
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'initialization');
    {$ENDIF}

    InitialiseSwinGame();

    {$IFDEF TRACE}
      TraceExit('sgCore', 'initialization');
    {$ENDIF}
  end;

//=============================================================================

  finalization
  begin
    {$IFDEF TRACE}
      TraceEnter('sgCore', 'finalization');
    {$ENDIF}

    RegisterFreeNotifier(nil);

    {$IFDEF TRACE}
      TraceExit('sgCore', 'finalization');
    {$ENDIF}
  end;

end.
