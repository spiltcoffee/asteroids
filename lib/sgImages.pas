//=============================================================================
// sgImages.pas
//=============================================================================
//
// The Images unit contains the code related to manipulating and querying
// bitmap structures.
//
// Change History:
//
// Version 3.0:
// - 2010-02-05: Andrew : Added png saving.
// - 2010-02-01: Aaron  : Added BitmapName and BitmapFileName
// - 2010-01-28: David  : Changed DoLoadBitmap to use an already loaded bitmap if found
// - 2010-01-05: David  : Added SetTransparentColor Procedure (Line 701 and 1442)
// - 2010-01-04: David  : Added Save Bitmap Procedure (Line 694 and 1428)
// - 2009-12-21: Andrew : Added Bitmap rectangle calculation code
// - 2009-12-18: Andrew : Added code to check if two images can be used interchangably
// - 2009-12-10: Andrew : Added bitmap drawing functions
// - 2009-12-07: Andrew : Added loading of image resources
// - 2009-11-06: Andrew : Started Images unit.
//
//=============================================================================

/// The Images module contains the code that relates to the manipulating and
/// querying of bitmap structures.
///
/// @module Images
/// @static
unit sgImages;

{$I sgTrace.inc}

//=============================================================================
interface
uses sgTypes;
//=============================================================================


//----------------------------------------------------------------------------
// Bitmap loading routines
//----------------------------------------------------------------------------
  
  /// Creates a bitmap in memory that is the specified width and height (in pixels).
  /// The new bitmap is initially transparent and can be used as the target 
  /// for various drawing operations. Once you have drawn the desired image onto
  /// the bitmap you can call OptimiseBitmap to optimise the surface.
  ///
  /// @lib
  /// @sn createBitmapWidth:%s height:%s
  ///
  /// @class Bitmap
  /// @constructor
  /// @csn initWithWidth:%s andHeight:%s
  function CreateBitmap(width, height: LongInt): Bitmap;

  /// Loads a bitmap from file using where the specified transparent color
  /// is used as a color key for the transparent color.
  ///
  /// @lib LoadBitmapWithTransparentColor
  /// @sn loadBitmapFile:%s colorKeyed:%s withColor:%s
  ///
  /// @class Bitmap
  /// @constructor
  /// @csn initWithPath:%s withTransparency:%s usingColor:%s
  function LoadBitmap(filename: String; transparent: Boolean; transparentColor: Color): Bitmap; overload;

  /// Loads a bitmap from file into a Bitmap variable. This can then be drawn to
  /// the screen. Bitmaps can be of bmp, jpeg, gif, png, etc. Images may also
  /// contain alpha values, which will be drawn correctly by the API. All
  /// bitmaps must be freed using the FreeBitmap once you are finished with
  /// them.
  /// 
  /// @lib
  /// @sn loadBitmapFile:%s
  ///
  /// @class Bitmap
  /// @constructor
  /// @csn initWithPath:%s
  function LoadBitmap(filename : String): Bitmap; overload;

  /// Loads a bitmap with a transparent color key. The transparent color is then
  /// setup as the color key to ensure the image is drawn correctly. Alpha
  /// values of Images loaded in this way will be ignored. All bitmaps must be
  /// freed using the FreeBitmap once you are finished with them.
  ///
  /// @lib LoadBitmapWithTransparentColor(filename, True, transparentColor)
  /// @sn loadBitmapFile:%s withColorKey:%s
  ///
  /// @class Bitmap
  /// @constructor
  /// @csn initWithPath:%s transparentColor:%s
  function LoadTransparentBitmap(filename : String; transparentColor : Color): Bitmap; overload;

  /// Frees a loaded bitmap. Use this when you will no longer be drawing the
  /// bitmap (including within Sprites), and when the program exits.
  ///
  /// @lib
  ///
  /// @class Bitmap
  /// @dispose
  procedure FreeBitmap(var bitmapToFree : Bitmap);
  
  
//----------------------------------------------------------------------------
// Bitmap mapping routines
//----------------------------------------------------------------------------
  
  /// Loads and returns a bitmap. The supplied `filename` is used to
  /// locate the Bitmap to load. The supplied `name` indicates the 
  /// name to use to refer to this Bitmap in SwinGame. The `Bitmap` can then be
  /// retrieved by passing this `name` to the `BitmapNamed` function. 
  ///
  /// @lib
  /// @sn mapBitmapNamed:%s toFile:%s
  ///
  /// @class Bitmap
  /// @constructor
  /// @csn initWithName:%s forFilename:%s
  function MapBitmap(name, filename: String): Bitmap;
  
  /// Loads and returns a bitmap with a given color code use for transparency.
  /// The supplied `filename` is used to locate the Bitmap to load. The supplied
  /// `name` indicates thename to use to refer to this Bitmap in SwinGame. The 
  /// `Bitmap` can then be retrieved by passing this `name` to the `BitmapNamed` function. 
  ///
  /// @lib
  /// @sn mapBitmapNamed:%s toFile:%s colorKey:%s
  ///
  /// @class Bitmap
  /// @constructor
  /// @csn initWithName:%s forFilename:%s andColorKey:%s
  function MapTransparentBitmap(name, filename: String; transparentColor: Color): Bitmap;
  
  /// Determines if SwinGame has a bitmap loaded for the supplied name.
  /// This checks against all bitmaps loaded, those loaded without a name
  /// are assigned the filename as a default.
  ///
  /// @lib
  function HasBitmap(name: String): Boolean;
  
  /// Returns the `Bitmap` that has been loaded with the specified name,
  /// see `MapBitmap`.
  ///
  /// @lib
  function BitmapNamed(name: String): Bitmap;
  
  /// Releases the SwinGame resources associated with the bitmap of the
  /// specified `name`.
  ///
  /// @lib
  procedure ReleaseBitmap(name: String);
  
  /// Releases all of the bitmaps that have been loaded.
  ///
  /// @lib
  procedure ReleaseAllBitmaps();
  
  
//---------------------------------------------------------------------------
// Bitmap querying functions
//---------------------------------------------------------------------------
  
  /// Returns the width of the entire bitmap.
  ///
  /// @lib
  ///
  /// @class Bitmap
  /// @getter Width
  function BitmapWidth(bmp: Bitmap): LongInt; overload;
  
  /// Returns the height of the entire bitmap.
  /// 
  /// @lib
  /// 
  /// @class Bitmap
  /// @getter Height
  function BitmapHeight(bmp: Bitmap): LongInt; overload;
  
  /// Returns the width of a cell within the bitmap.
  /// 
  /// @lib
  /// 
  /// @class Bitmap
  /// @getter CellWidth
  function BitmapCellWidth(bmp: Bitmap): LongInt;
  
  /// Returns the height of a cell within the bitmap.
  ///
  /// @lib
  ///
  /// @class Bitmap
  /// @getter CellHeight
  function BitmapCellHeight(bmp: Bitmap): LongInt;

  /// Checks if a pixel is drawn at the specified x,y location.
  /// 
  /// @lib
  /// @sn pixelOf:%s drawnAtX:%s y:%s
  ///
  /// @class Bitmap
  /// @method PixelDrawnAtPoint  
  /// @csn pixelDrawnAtX:%s y:%s
  function PixelDrawnAtPoint(bmp: Bitmap; x, y: LongInt): Boolean;
  
  /// This is used to define the number of cells in a bitmap, and 
  /// their width and height. The cells are
  /// traversed in rows so that the format would be [0 - 1 - 2] 
  /// [3 - 4 - 5] etc. The count can be used to restrict which of the 
  /// parts of the bitmap actually contain cells that can be drawn.
  ///
  /// @lib
  /// @sn bitmap:%s setCellWidth:%s height:%s columns:%s rows:%s count:%s
  ///
  /// @class Bitmap
  /// @method SetCellDetails
  /// @csn setCellWidth:%s height:%s columns:%s rows:%s count:%s
  procedure BitmapSetCellDetails(bmp: Bitmap; width, height, columns, rows, count: LongInt);
  
  /// Returns the number of cells in the specified bitmap.
  ///
  /// @lib
  ///
  /// @class Bitmap
  /// @getter CellCount
  function BitmapCellCount(bmp: Bitmap): LongInt;
  
  /// Returns the number of rows of cells in the specified bitmap.
  ///
  /// @lib
  ///
  /// @class Bitmap
  /// @getter CellRows
  function BitmapCellRows(bmp: Bitmap): LongInt;
  
  /// Returns the number of columns of cells in the specified bitmap.
  ///
  /// @lib
  ///
  /// @class Bitmap
  /// @getter CellColumns
  function BitmapCellColumns(bmp: Bitmap): LongInt;
  
  /// Are the two bitmaps of a similar format that they could be used in
  /// place of each other. This returns true if they have the same cell
  /// details (count, width, and height).
  ///
  /// @lib
  /// @sn bitmap: %s interchangableWith:%s
  ///
  /// @class Bitmap
  /// @method interchangableWith
  function BitmapsInterchangable(bmp1, bmp2: Bitmap): Boolean;
  
  /// Returns the name of the bitmap
  /// @lib
  /// @class Bitmap
  /// @getter Name
  function BitmapName(bmp:Bitmap): string;
  
  /// Returns the FileName of the bitmap
  /// @lib
  /// @class Bitmap
  /// @getter Filename
  function BitmapfileName(bmp:Bitmap): string;


  //----------------------------------------------------------------------------
  // BitmapCell code
  //----------------------------------------------------------------------------
  
  /// Returns a bitmap cell for the cell of the indicated bitmap.
  ///
  /// @lib
  /// @sn bitmap:%s bitmapCellForCell:%s
  ///
  /// @class Bitmap
  /// @method BitmapCell
  function BitmapCellOf(bmp: Bitmap; cell: LongInt): BitmapCell;
  
  /// Returns true of the two bitmap cells refer to the same cell
  /// in the one bitmap.
  /// 
  /// @lib
  /// @sn bitmapCell:%s isSameAs:%s
  ///
  /// @class BitmapCell
  /// @method SameAs
  function SameBitmapCell(const bmp1, bmp2: BitmapCell): Boolean;
  
  /// Returns the width of the bitmap cell.
  ///
  /// @lib BitmapWidthForCell
  ///
  /// @class BitmapCell
  /// @getter Width
  function BitmapWidth(const bmp: BitmapCell): LongInt; overload;
  
  /// Returns the height of the bitmap cell.
  /// 
  /// @lib BitmapHeightForCell
  /// 
  /// @class BitmapCell
  /// @getter Height
  function BitmapHeight(const bmp: BitmapCell): LongInt; overload;
  
  
//----------------------------------------------------------------------------
// Bitmap -> Circle
//----------------------------------------------------------------------------
  
  /// Creates a circle from within a bitmap, uses the larger of the width and
  /// height.
  ///
  /// @lib
  /// @sn circleFrombitmap:%s atPt:%s
  /// 
  /// @class Bitmap
  /// @method ToCircle
  /// @csn circleAtPt:%s
  function BitmapCircle(bmp: Bitmap; const pt: Point2D): Circle; overload;
  
  /// Creates a circle from within a bitmap, uses the larger of the width and
  /// height.
  ///
  /// @lib BitmapCircleXY
  /// @sn circleFromBitmap:%s atX:%s y:%s
  /// 
  /// @class Bitmap
  /// @overload ToCircle ToCircleXY
  /// @csn circleAtX:%s y:%s
  function BitmapCircle(bmp: Bitmap; x, y: LongInt): Circle; overload;
  
  /// Creates a circle from within a cell in a bitmap, uses the larger of the width and
  /// height.
  ///
  /// @lib
  /// @sn circleFromBitmap:%s cellAtPt:%s
  ///
  /// @class Bitmap
  /// @method ToCellCircle
  /// @csn circleCellAtPT:%s 
  function BitmapCellCircle(bmp: Bitmap; const pt: Point2D): Circle; overload;
  
  /// Creates a circle from within a cell in a bitmap, uses the larger of the width and
  /// height.
  ///
  /// @lib BitmapCellCircleXY
  /// @sn circleBitmap:%s cellAtX:%s y:%s
  ///
  /// @class Bitmap
  /// @overload ToCellCircle ToCellCircleXY
  /// @csn circleCellAtX:%s y:%s
  function BitmapCellCircle(bmp: Bitmap; x,y: LongInt): Circle; overload;
  
  
//---------------------------------------------------------------------------
// Alpha blendings adjusting code
//---------------------------------------------------------------------------
  
  /// Removes any surface level transparency from the supplied bitmap.
  ///
  /// @lib
  ///
  /// @class Bitmap
  /// @method MakeOpaque
  procedure MakeOpaque(bmp: Bitmap);
  
  /// Turns on the surface level transparency for the supplied bitmap, 
  /// and set the transparency value to the percentage supplied in pct.
  ///
  /// @lib
  /// @sn setOpacityOf:%s pct:%s
  /// 
  /// @class Bitmap
  /// @method SetOpacity
  procedure SetOpacity(bmp: Bitmap; pct: Single);
  
  /// Turns on the surface level transparency for the supplied bitmap, the
  /// transparency value is then set to 0 (fully transparent).
  ///
  /// @lib
  /// @class Bitmap
  /// @method MakeTransparent
  procedure MakeTransparent(bmp: Bitmap);
  
  
//---------------------------------------------------------------------------
// Save
//---------------------------------------------------------------------------
  
  /// Saves the bitmap to a png file at the specified location.
  ///
  /// @lib
  ///
  /// @class Bitmap
  /// @method save
  procedure SaveToPNG(bmp: Bitmap; filename: String);
  
//---------------------------------------------------------------------------
// Rotate and Zoom
//---------------------------------------------------------------------------
  
  /// Rotate and Scale the passed in bitmap.
  ///
  /// @lib
  /// @sn transformBitmap:%s rotate:%s scale:%s
  ///
  /// @class Bitmap
  /// @method RotateScaleBitmap
  /// @csn rotate:%s scale:%s
  function RotateScaleBitmap(src: Bitmap; degRot, scale: Single): Bitmap;
  
  /// Setup the passed in bitmap for pixel level collisions.
  ///
  /// @lib
  /// @class Bitmap
  /// @method SetupForCollisions
  procedure SetupBitmapForCollisions(src: Bitmap);

//---------------------------------------------------------------------------
// Optimise
//---------------------------------------------------------------------------

  /// Created bitmaps can be optimised for faster drawing to the screen. This
  /// optimisation should be called only once after all drawing to the bitmap
  /// is complete. Optimisation should not be used if the bitmap is to be
  /// drawn onto in the future. All loaded bitmaps are optimised during loading.
  ///
  /// @lib
  ///
  /// @class Bitmap
  /// @method OptimiseBitmap
  procedure OptimiseBitmap(surface: Bitmap);
  
  
  //---------------------------------------------------------------------------
  // Bitmap drawing routines - clearing
  //---------------------------------------------------------------------------
  
  /// Clear the drawing on the Bitmap to the passed in color.
  ///
  /// @lib
  /// @sn clearSurface:%s color:%s
  ///
  /// @class Bitmap
  /// @overload ClearSurface ClearSurfaceToColor
  /// @csn clearSurfaceTo:%s
  procedure ClearSurface(dest: Bitmap; toColor: Color); overload;
  
  /// Clears the drawing on the Bitmap to black.
  ///
  /// @lib ClearSurfaceToBlack
  ///
  /// @class Bitmap
  /// @method ClearSurface
  procedure ClearSurface(dest: Bitmap); overload;
  
  
  //---------------------------------------------------------------------------
  // Bitmap -> Rectangle functions
  //---------------------------------------------------------------------------
  
  /// Returns a bounding rectangle for the bitmap.
  /// 
  /// @lib BitmapRectXY
  /// @sn rectangleAtX:%s y:%s forBitmap:%s
  ///
  /// @class Bitmap
  /// @overload ToRectangle ToRectangleAtXY
  /// @self 3
  /// @csn toRectangleAtX:%s y:%s
  function BitmapRectangle(x, y: Single; bmp: Bitmap): Rectangle; overload;
  
  /// Returns a bounding rectangle for the bitmap, at the origin.
  /// 
  /// @lib BitmapRectAtOrigin
  ///
  /// @class Bitmap
  /// @overload ToRectangle ToRectangleAtOrigin
  /// @csn toRectangleAtOrigin
  function BitmapRectangle(bmp: Bitmap): Rectangle; overload;
  
  /// Returns a bounding rectangle for a cell of the bitmap at the origin.
  /// 
  /// @lib BitmapCellRectangleAtOrigin
  /// @sn rectangleForBitmapCellAtOrigin:%s
  ///
  /// @class Bitmap
  /// @overload ToCellRectangle ToCellRectangleAtOrigin
  /// @csn toRectangleAtOrigin
  function BitmapCellRectangle(bmp: Bitmap): Rectangle; overload;
  
  /// Returns a rectangle for a cell of the bitmap at the indicated point.
  /// 
  /// @lib BitmapCellRectangle
  /// @sn rectangleAt:%s forBitmapCell:%s
  ///
  /// @class Bitmap
  /// @overload ToCellRectangle ToCellRectangleAtPt
  /// @self 2
  /// @csn toRectangleAt:%s
  function BitmapCellRectangle(const pt: Point2D; bmp: Bitmap): Rectangle; overload;
  
  /// Returns a rectangle for a cell of the bitmap at the indicated point.
  /// 
  /// @lib BitmapCellRectangleXY
  /// @sn rectangleAtX:%s y:%s forBitmapCell:%s
  ///
  /// @class Bitmap
  /// @method ToCellRectangle
  /// @self 2
  /// @csn toRectangleAtX:%s y:%s
  function BitmapCellRectangle(x, y: Single; bmp: Bitmap): Rectangle; overload;
  
  /// Returns a rectangle for the location of the indicated cell within the
  /// bitmap.
  /// 
  /// @lib
  /// @sn bitmap:%s rectangleOfCell:%s
  /// 
  /// @class Bitmap
  /// @method CellRectangle
  /// @csn rectangleCell:%s
  function BitmapRectangleOfCell(src: Bitmap; cell: LongInt): Rectangle;
  
  
  //---------------------------------------------------------------------------
  // Bitmap drawing routines - onto bitmap
  //---------------------------------------------------------------------------
  
  /// Draws the source bitmap onto the destination.
  ///
  /// @lib DrawBitmapOnto
  /// @sn drawOnto:%s bitmap:%s atX:%s y:%s
  ///
  /// @class Bitmap
  /// @method DrawOnto
  /// @self 2
  /// @csn drawOnto:%s atX:%s y:%s
  procedure DrawBitmap(dest: Bitmap; src: Bitmap; x, y : LongInt); overload;
  
  /// Draws the source bitmap onto the destination
  ///
  /// @lib DrawBitmapAtPointOnto
  /// @sn drawOnto:%s bitmap:%s at:%s
  ///
  /// @class Bitmap
  /// @overload DrawOnto DrawAtPointOnto
  /// @self 2
  /// @csn drawOnto:%s at:%s
  procedure DrawBitmap(dest: Bitmap; src: Bitmap; const position : Point2D); overload;
  
  /// Draws the cell of the source bitmap onto the destination.
  ///
  /// @lib DrawBitmapCellOnto
  /// @sn drawOnto:%s bitmapCell:%s atX:%s y:%s
  ///
  /// @class BitmapCell
  /// @method DrawOnto
  /// @self 2
  /// @csn drawOnto:%s atX:%s y:%s
  procedure DrawBitmapCell(dest: Bitmap; const src: BitmapCell; x, y : LongInt); overload;

  /// Draws the cell of the source bitmap onto the destination
  ///
  /// @lib DrawBitmapCellAtPointOnto
  /// @sn drawOnto:%s bitmapCell:%s at:%s
  ///
  /// @class BitmapCell
  /// @overload DrawOnto DrawAtPointOnto
  /// @self 2
  /// @csn drawOnto:%s at:%s
  procedure DrawBitmapCell(dest: Bitmap; const src: BitmapCell; const position : Point2D); overload;

  /// Draw part of the source onto the desitination.
  ///
  /// @lib DrawBitmapPartOnto
  /// @sn drawOnto:%s bitmap:%s srcX:%s srcY:%s srcW:%s srcH:%s atX:%s y:%s
  ///
  /// @class Bitmap
  /// @method DrawPartOnto
  /// @self 2
  /// @csn drawOnto:%s srcX:%s srcY:%s srcW:%s srcH:%s atX:%s y:%s
  procedure DrawBitmapPart(dest: Bitmap; src: Bitmap; srcX, srcY, srcW, srcH, x, y : LongInt); overload;
  
  /// Draw part of the source bitmap onto the destination.
  ///
  /// @lib DrawBitmapPartFromRectOnto
  /// @sn drawOnto:%s bitmap:%s srcRect:%s atX:%s y:%s
  ///
  /// @class Bitmap
  /// @overload DrawPartOnto DrawPartFromRectOnto
  /// @csn drawOnto:%s srcRect:%s atX:%s y:%s
  procedure DrawBitmapPart(dest: Bitmap; src: Bitmap; const source: Rectangle; x, y : LongInt); overload;
  
  /// Draw part of the source bitmap onto the destination
  ///
  /// @lib DrawBitmapPartFromRectAtPointOnto
  /// @sn drawOnto:%s bitmap:%s srcRect:%s at:%s
  ///
  /// @class Bitmap
  /// @overload DrawPartOnto DrawPartFromRectAtPointOnto
  /// @csn drawOnto:%s srcRect:%s at:%s
  procedure DrawBitmapPart(dest: Bitmap; src: Bitmap; const source: Rectangle; const position: Point2D); overload;
  
  /// Draw a cell from a bitmap onto the destination.
  ///
  /// @lib DrawCellOntoXY
  /// @sn drawOnto:%s bitmap:%s cell:%s atX:%s y:%s
  ///
  /// @class Bitmap
  /// @method DrawCellOnto
  /// @csn drawOnto:%s cell:%s atX:%s y:%s
  /// @self 2
  procedure DrawCell(dest: Bitmap; src: Bitmap; cell: LongInt; x, y: Single); overload;
  
  /// Draw a cell from a bitmap onto the destination.
  ///
  /// @lib DrawCellOnto
  /// @sn drawOnto:%s bitmap:%s cell:%s at:%s
  ///
  /// @class Bitmap
  /// @overload DrawCellOnto DrawCellAtPointOnto
  /// @csn drawOnto:%s cell:%s at:%s
  /// @self 2
  procedure DrawCell(dest: Bitmap; src: Bitmap; cell: LongInt; const position: Point2D); overload;
  
  
  //---------------------------------------------------------------------------
  // Bitmap drawing routines - standard
  //---------------------------------------------------------------------------
  
  /// Draw the passed in bitmap onto the game.
  ///
  /// @lib
  /// @sn draw:%s x:%s y:%s
  ///
  /// @class Bitmap
  /// @method Draw
  /// @csn drawAtX:%s y:%s
  procedure DrawBitmap(src : Bitmap; x, y : Single); overload;
  
  /// Draw the passed in bitmap onto the game.
  ///
  /// @lib DrawBitmapAtPoint
  /// @sn draw:%s position:%s
  ///
  /// @class Bitmap
  /// @overload Draw DrawAtPoint
  /// @csn drawAt:%s
  procedure DrawBitmap(src : Bitmap; const position : Point2D); overload;
  
  /// Draw the cell of the passed in bitmap onto the game.
  ///
  /// @lib DrawBitmapCell
  /// @sn bitmapCell:%s drawAtX:%s y:%s
  ///
  /// @class BitmapCell
  /// @method DrawAt
  /// @csn drawAtX:%s y:%s
  procedure DrawBitmapCell(const src : BitmapCell; x, y : Single); overload;
  
  /// Draw the cell of the passed in bitmap onto the game.
  ///
  /// @lib DrawBitmapCellAtPoint
  /// @sn bitmapCell:%s drawAtPosition:%s
  ///
  /// @class BitmapCell
  /// @overload DrawAt DrawAtPoint
  /// @csn drawAt:%s
  procedure DrawBitmapCell(const src : BitmapCell; const position : Point2D); overload;
  
  /// Draw part of a bitmap onto the game
  ///
  /// @lib
  /// @sn draw:%s srcX:%s srcY:%s srcW:%s srcH:%s x:%s y:%s
  ///
  /// @class Bitmap
  /// @method DrawPart
  /// @csn drawSrcX:%s srcY:%s srcW:%s srcH:%s x:%s y:%s
  procedure DrawBitmapPart(src : Bitmap; srcX, srcY, srcW, srcH: LongInt; x, y : Single); overload;
  
  /// Draw part of a bitmap onto the game
  ///
  /// @lib DrawBitmapPartFromRect
  /// @sn draw:%s srcRect:%s x:%s y:%s
  ///
  /// @class Bitmap
  /// @overload DrawPart DrawPartFromRect
  /// @csn drawSrcRect:%s x:%s y:%s
  procedure DrawBitmapPart(src : Bitmap; const source : Rectangle; x, y : Single); overload;
  
  /// Draw part of a bitmap onto the game.
  ///
  /// @lib DrawBitmapPartFromRectAtPoint
  /// @sn bitmap:%s drawPart:%s position:%s
  ///
  /// @class Bitmap
  /// @overload DrawPart DrawPartFromRectAtPoint
  /// @csn drawSrcRect:%s position:%s
  procedure DrawBitmapPart(src : Bitmap; const source : Rectangle; const position : Point2D); overload;
  
  /// Draw a cell from a bitmap onto the game.
  ///
  /// @lib DrawCellXY
  /// @sn bitmap:%s drawCell:%s atX:%s y:%s
  ///
  /// @class Bitmap
  /// @method DrawCell
  /// @csn drawCell:%s atX:%s y:%s
  procedure DrawCell(src: Bitmap; cell: LongInt; x, y: Single); overload;
  
  /// Draw a cell from a bitmap onto the game.
  ///
  /// @lib DrawCell
  /// @sn bitmap:%s drawCell:%s at:%s
  ///
  /// @class Bitmap
  /// @overload DrawCell DrawCellAtPoint
  /// @csn drawCell:%s at:%s
  procedure DrawCell(src: Bitmap; cell: LongInt; const position: Point2D); overload;
  
  
  //---------------------------------------------------------------------------
  // Bitmap drawing routines - onto screen
  //---------------------------------------------------------------------------
  
  /// Draw the bitmap onto the screen.
  ///
  /// @lib
  /// @sn draw:%s onScreenAtX:%s y:%s
  ///
  /// @class Bitmap
  /// @method DrawOnScreen
  /// @csn drawOnScreenAtX:%s y:%s
  procedure DrawBitmapOnScreen(src : Bitmap; x, y : LongInt); overload;
  
  /// Draw the bitmap onto the screen.
  ///
  /// @lib DrawBitmapAtPointOnScreen
  /// @sn draw:%s onScreenAt:%s
  ///
  /// @class Bitmap
  /// @overload DrawOnScreen DrawAtPointOnSreen
  /// @csn drawOnScreenAt:%s
  procedure DrawBitmapOnScreen(src : Bitmap; const position : Point2D); overload;

  /// Draw the cell of the bitmap onto the screen.
  ///
  /// @lib DrawBitmapCellOnScreen
  /// @sn bitmapCell:%s drawOnScreenAtX:%s y:%s
  ///
  /// @class BitmapCell
  /// @method DrawOnScreen
  /// @csn drawOnScreenAtX:%s y:%s
  procedure DrawBitmapCellOnScreen(const src : BitmapCell; x, y : LongInt); overload;

  /// Draw the cell of the bitmap onto the screen.
  ///
  /// @lib DrawBitmapCellAtPointOnScreen
  /// @sn bitmapCell:%s drawOnScreenAt:%s
  ///
  /// @class BitmapCell
  /// @overload DrawOnScreen DrawAtPointOnSreen
  /// @csn drawOnScreenAt:%s
  procedure DrawBitmapCellOnScreen(const src : BitmapCell; const position : Point2D); overload;
  
  /// Draw part of the bitmap on the screen.
  ///
  /// @lib
  /// @sn draw:%s srcX:%s srcY:%s srcW:%s srcH:%s onScreenAtX:%s y:%s
  ///
  /// @class Bitmap
  /// @method DrawPartOnScreen
  /// @csn drawSrcX:%s srcY:%s srcW:%s srcH:%s onScreenAtX:%s y:%s
  procedure DrawBitmapPartOnScreen(src : Bitmap; srcX, srcY, srcW, srcH, x, y : LongInt); overload;
  
  /// Draw part of the bitmap on the screen.
  ///
  /// @lib DrawBitmapPartFromRectOnScreen
  /// @sn draw:%s srcRect:%s onScreenAtX:%s y:%s
  ///
  /// @class Bitmap
  /// @overload DrawPartOnScreen DrawPartFromRectOnScreen
  /// @csn drawSrcRect:%s onScreenAtX:%s y:%s
  procedure DrawBitmapPartOnScreen(src : Bitmap; const source: Rectangle; x, y : LongInt); overload;
  
  /// Draw part of the bitmap on the screen.
  ///
  /// @lib DrawBitmapPartFromRectAtPointOnScreen
  /// @sn draw:%s srcRect:%s onScreenAt:%s
  ///
  /// @class Bitmap
  /// @overload DrawPartOnScreen DrawPartOnFromRectAtPointScreen
  /// @csn drawSrcRect:%s onScreenAt:%s
  procedure DrawBitmapPartOnScreen(src : Bitmap; const source: Rectangle; const position: Point2D); overload;
  
  /// Draw a cell from a bitmap onto the screen.
  ///
  /// @lib DrawCellOnScreenXY
  /// @sn bitmap:%s drawCell:%s onScreenAtX:%s y:%s
  ///
  /// @class Bitmap
  /// @method DrawCell
  /// @csn drawCell:%s onScreenAtX:%s y:%s
  procedure DrawCellOnScreen(src: Bitmap; cell: LongInt; x, y: Single); overload;
  
  /// Draw a cell from a bitmap onto the game.
  ///
  /// @lib DrawCellOnScreen
  /// @sn bitmap:%s drawCell:%s at:%s
  ///
  /// @class Bitmap
  /// @overload DrawCell DrawCellAtPoint
  /// @csn drawCell:%s onScreenAt:%s
  procedure DrawCellOnScreen(src: Bitmap; cell: LongInt; const position: Point2D); overload;
  
  
  //---------------------------------------------------------------------------
  // Bitmap Saving
  //---------------------------------------------------------------------------
  
  /// Save Bitmap to specific directory.
  /// 
  /// @lib
  /// @sn bitmap:%s saveToFile:%s
  ///
  /// @class Bitmap
  /// @method Save
  /// @csn saveToFile:%s
  procedure SaveBitmap(src : Bitmap; filepath : string);
  
  
  //---------------------------------------------------------------------------
  // Bitmap Transparancy
  //---------------------------------------------------------------------------
  
  /// Setting the color passed in to be transparent on the bitmap. This edits the
  /// passed in bitmap, altering the color to transparent.
  /// 
  /// @lib
  /// @sn bitmap:%s setTransparentColor:%s
  ///
  /// @class Bitmap
  /// @method SetTransparentColor 
  procedure SetTransparentColor(src: Bitmap; clr:Color);
  
//=============================================================================
implementation
uses sgCore, sgResources, sgCamera, sgGeometry, sgGraphics,
     stringhash,         // libsrc
     SysUtils, 
     sgSavePNG, sgShared, sgTrace, 
     SDL_gfx, SDL, SDL_Image // sdl
     ;
//=============================================================================

var
  _Images: TStringHash;


//----------------------------------------------------------------------------

function CreateBitmap(width, height: LongInt): Bitmap;
var
  name: String;
  idx: LongInt;
  obj: tResourceContainer;
begin
  {$IFDEF TRACE}
    TraceEnter('sgImages', 'CreateBitmap');
  {$ENDIF}

  if (width < 1) or (height < 1) then
  begin
    RaiseException('Bitmap width and height must be greater then 0');
    exit;
  end;
  if (baseSurface = nil) or (baseSurface^.format = nil) then
  begin
    RaiseException('Unable to CreateBitmap as the window is not open');
    exit;
  end;
  
  New(result);
  
  with baseSurface^.format^ do
  begin
    result^.surface := SDL_CreateRGBSurface(SDL_SRCALPHA, width, height, 32, RMask, GMask, BMask, AMask);
  end;
  
  if result^.surface = nil then
  begin
    Dispose(result);
    RaiseException('Failed to create a bitmap: ' + SDL_GetError());
    exit;
  end;
  
  //
  // Place the bitmap in the _Images hashtable
  //
  obj := tResourceContainer.Create(result);
  
  name := 'Bitmap';
  idx := 0;
  while not _Images.setValue(name, obj) do
  begin
    name := 'Bitmap_' + IntToStr(idx);
    idx := idx + 1;
  end;
  
  result^.width     := width;
  result^.height    := height;
  
  result^.cellW     := width;
  result^.cellH     := height;
  result^.cellCols  := 1;
  result^.cellRows  := 1;
  result^.cellCount := 1;
  
  result^.name      := name;
  result^.filename  := name;
  
  SDL_SetAlpha(result^.surface, SDL_SRCALPHA, 0);
  SDL_FillRect(result^.surface, nil, ColorTransparent);
  
  {$IFDEF TRACE}
    TraceExit('sgImages', 'CreateBitmap', name + ' = ' + HexStr(result));
  {$ENDIF}
end;

// Sets the non-transparent pixels in a Bitmap. This is then used for
// collision detection, allowing the original surface to be optimised.
//
// @param bmp  A pointer to the Bitmap being set
// @param surface The surface with pixel data for this Bitmap
procedure SetNonTransparentPixels(bmp: Bitmap; surface: PSDL_Surface; transparentColor: Color);
var
  r, c: LongInt;
begin
  SetLength(bmp^.nonTransparentPixels, bmp^.width, bmp^.height);

  for c := 0 to bmp^.width - 1 do
  begin
    for r := 0 to bmp^.height - 1 do
    begin
      bmp^.nonTransparentPixels[c, r] := (GetPixel32(surface, c, r) <> transparentColor);
    end;
  end;
end;

function DoLoadBitmap(name, filename: String; transparent: Boolean; transparentColor: Color): Bitmap;
var
  obj: tResourceContainer;
  loadedImage: PSDL_Surface;
  correctedTransColor: Color;
begin
  {$IFDEF TRACE}
    TraceEnter('sgImages', 'LoadBitmap', filename);
  {$ENDIF}
  
  if _Images.containsKey(name) then
  begin
    result := BitmapNamed(name);
    exit;
  end;
  
  result := nil; //start at nil to exit cleanly on error
  
  // Check for file
  if not FileExists(filename) then
  begin
    filename := PathToResource(filename, BitmapResource);
    
    if not FileExists(filename) then
    begin
      RaiseException('Unable to locate bitmap ' + filename);
      exit;
    end;
  end;
  
  //Load the image
  loadedImage := IMG_Load(PChar(filename));
  
  if loadedImage = nil then
  begin
    RaiseException('Error loading image: ' + filename + ': ' + SDL_GetError());
    exit;
  end;
  
  //
  // Image loaded, so create SwinGame bitmap
  //
  new(result);
  
  if not transparent then result^.surface := SDL_DisplayFormatAlpha(loadedImage)
  else result^.surface := SDL_DisplayFormat(loadedImage);
  
  result^.width     := result^.surface^.w;
  result^.height    := result^.surface^.h;
  result^.cellW     := result^.width;
  result^.cellH     := result^.height;
  result^.cellCols  := 1;
  result^.cellRows  := 1;
  result^.cellCount := 1;
  result^.name      := name;
  result^.filename  := filename;
  SetLength(result^.clipStack, 0);
  
  //Determine pixel level collision data
  if transparent then
  begin
    correctedTransColor := ColorFrom(result, transparentColor);
    SDL_SetColorKey(result^.surface, SDL_RLEACCEL or SDL_SRCCOLORKEY, correctedTransColor);
    SetNonTransparentPixels(result, loadedImage, correctedTransColor);
  end
  else
  begin
    SetNonAlphaPixels(result, loadedImage);
  end;
  
  // Free the loaded image if its not the result's surface
  if loadedImage <> result^.surface then SDL_FreeSurface(loadedImage);
  
  //
  // Place the bitmap in the _Images hashtable
  //
  obj := tResourceContainer.Create(result);
  {$IFDEF TRACE}
    Trace('sgImages', 'Info', 'DoLoadBitmap', 'name = ' + name + ' obj = ' + HexStr(obj) + ' _Images = ' + HexStr(_Images));
  {$ENDIF}
  if not _Images.setValue(name, obj) then
  begin
    FreeBitmap(result);
    RaiseException('Error loaded Bitmap resource twice: ' + name + ' for file ' + filename);
    exit;
  end;
  
  {$IFDEF TRACE}
    TraceExit('sgImages', 'LoadBitmap, result = ' + HexStr(result));
  {$ENDIF}
end;

function LoadBitmap(filename: String; transparent: Boolean; transparentColor: Color): Bitmap; overload;
begin
  result := DoLoadBitmap(filename + IntToStr(transparentColor),filename, transparent, transparentColor);
end;

function LoadBitmap(filename: String): Bitmap; overload;
begin
  result := DoLoadBitmap(filename, filename, false, ColorBlack);
end;

function LoadTransparentBitmap(filename: String; transparentColor: Color): Bitmap; overload;
begin
  result := LoadBitmap(filename, true, transparentColor);
end;

// private:
// Called to actually free the resource
procedure DoFreeBitmap(var bitmapToFree : Bitmap);
begin
  {$IFDEF TRACE}
    TraceEnter('sgImages', 'DoFreeBitmap', 'bitmapToFree = ' + HexStr(bitmapToFree));
  {$ENDIF}
  
  if Assigned(bitmapToFree) then
  begin
    if Assigned(bitmapToFree^.surface) then
    begin
      //WriteLn('Free Bitmap - ', HexStr(bitmapToFree^.surface));
      SDL_FreeSurface(bitmapToFree^.surface);
    end;
    bitmapToFree^.surface := nil;
    // SetLength(bitmapToFree^.nonTransparentPixels, 0, 0);
    Dispose(bitmapToFree);
    CallFreeNotifier(bitmapToFree);
    bitmapToFree := nil;
  end;
  
  {$IFDEF TRACE}
    TraceExit('sgImages', 'DoFreeBitmap');
  {$ENDIF}
end;

procedure FreeBitmap(var bitmapToFree : Bitmap);
begin
  {$IFDEF TRACE}
    TraceEnter('sgImages', 'FreeBitmap', 'effect = ' + HexStr(bitmapToFree));
  {$ENDIF}
  
  if(assigned(bitmapToFree)) then
  begin
    ReleaseBitmap(bitmapToFree^.name);
  end;
  bitmapToFree := nil;
  
  {$IFDEF TRACE}
    TraceExit('sgImages', 'FreeBitmap');
  {$ENDIF}
end;


//----------------------------------------------------------------------------

function MapBitmap(name, filename: String): Bitmap;
begin
  {$IFDEF TRACE}
    TraceEnter('sgImages', 'MapBitmap', name + ' -> ' + filename);
  {$ENDIF}
  
  result := DoLoadBitmap(name, filename, false, ColorBlack);
  
  {$IFDEF TRACE}
    TraceExit('sgImages', 'MapBitmap');
  {$ENDIF}
end;

function MapTransparentBitmap(name, filename: String; transparentColor: Color): Bitmap;
begin
  {$IFDEF TRACE}
    TraceEnter('sgImages', 'MapBitmap', name + ' -> ' + filename);
  {$ENDIF}
  
  result := DoLoadBitmap(name, filename, true, transparentColor);
  
  {$IFDEF TRACE}
    TraceExit('sgImages', 'MapBitmap');
  {$ENDIF}
end;

function HasBitmap(name: String): Boolean;
begin
  result := _Images.containsKey(name);
end;

function BitmapNamed(name: String): Bitmap;
var
  tmp : TObject;
begin
  tmp := _Images.values[name];
  if assigned(tmp) then
    result := Bitmap(tResourceContainer(tmp).Resource)
  else 
    result := nil;
end;

procedure ReleaseBitmap(name: String);
var
  bmp: Bitmap;
begin
  {$IFDEF TRACE}
    TraceEnter('sgImages', 'ReleaseBitmap', 'name = ' + name);
  {$ENDIF}

  bmp := BitmapNamed(name);
  if (assigned(bmp)) then
  begin
    _Images.remove(name).Free();
    DoFreeBitmap(bmp);
  end;
  
  {$IFDEF TRACE}
    TraceExit('sgImages', 'ReleaseBitmap');
  {$ENDIF}
end;

procedure ReleaseAllBitmaps();
begin
  ReleaseAll(_Images, @ReleaseBitmap);
end;

//----------------------------------------------------------------------------

function PixelDrawnAtPoint(bmp: Bitmap; x, y: LongInt): Boolean;
begin
  result := (Length(bmp^.nonTransparentPixels) = bmp^.width)
            and ((x >= 0) and (x < bmp^.width))
            and ((y >= 0) and (y < bmp^.height))
            and bmp^.nonTransparentPixels[x, y];
end;

procedure BitmapSetCellDetails(bmp: Bitmap; width, height, columns, rows, count: LongInt);
begin
  bmp^.cellW     := width;
  bmp^.cellH     := height;
  bmp^.cellCols  := columns;
  bmp^.cellRows  := rows;
  bmp^.cellCount := count;
end;

function BitmapCellCount(bmp: Bitmap): LongInt;
begin
  result := bmp^.cellCount;
end;

function BitmapCellRows(bmp: Bitmap): LongInt;
begin
  result := bmp^.cellRows;
end;

function BitmapCellColumns(bmp: Bitmap): LongInt;
begin
  result := bmp^.cellCols;
end;

function BitmapsInterchangable(bmp1, bmp2: Bitmap): Boolean;
begin
  
  if (not assigned(bmp1)) or (not assigned(bmp2)) then
    result := false
  else
    result := (bmp1^.cellCount = bmp2^.cellCount) and
              (bmp1^.cellW = bmp2^.cellW) and
              (bmp1^.cellH = bmp2^.cellH);
end;


//---------------------------------------------------------------------------

procedure MakeOpaque(bmp: Bitmap);
begin
  SDL_SetAlpha(bmp^.surface, 0, 255);
end;

procedure SetOpacity(bmp: Bitmap; pct: Single);
begin
  SDL_SetAlpha(bmp^.surface, SDL_SRCALPHA, Round(pct * 255));
end;

procedure MakeTransparent(bmp: Bitmap);
begin
  SDL_SetAlpha(bmp^.surface, SDL_SRCALPHA, 0);
end;

//---------------------------------------------------------------------------

function RotateScaleBitmap(src: Bitmap; degRot, scale: Single): Bitmap;
var
  name: String;
  obj: TResourceContainer;
  deg: LongInt;
begin
  result := nil;
  if not assigned(src) then exit;
  
  deg := Round(degRot) mod 360;
  
  name := Format('%s|%d|%.2f', [BitmapName(src), deg, scale]);
  
  //WriteLn(name);
  
  if HasBitmap(name) then
  begin
    result := BitmapNamed(name);
    exit;
  end;
  
  New(result);
  obj := tResourceContainer.Create(result);
  if not _Images.setValue(name, obj) then
  begin
    Dispose(result);
    result := nil;
    exit;
  end;
  
  with result^ do
  begin
    surface := rotozoomSurface(src^.surface, deg, scale, 0);
    width   := surface^.w;
    height  := surface^.h;
    
    if degRot = 0 then
      BitmapSetCellDetails(result, Round(src^.cellW * scale), Round(src^.cellH * scale), src^.cellCount, src^.cellRows, src^.cellCount)
    else
      // Cell details are gone
      BitmapSetCellDetails(result, width, height, 1, 1, 1);
    
    SetLength(nonTransparentPixels, 0);
    SetLength(clipStack, 0);
  end;
end;

procedure SetupBitmapForCollisions(src: Bitmap);
begin
  if Length(src^.nonTransparentPixels) <> 0 then exit;
    
  SetNonAlphaPixels(src, src^.surface);
  OptimiseBitmap(src);
end;

//---------------------------------------------------------------------------

procedure OptimiseBitmap(surface: Bitmap);
var
  oldSurface: PSDL_Surface;
begin
  if surface = nil then
  begin
    //RaiseException('No bitmap supplied');
    exit;
  end;
  
  oldSurface := surface^.surface;
  SetNonAlphaPixels(surface, oldSurface);
  surface^.surface := SDL_DisplayFormatAlpha(oldSurface);
  SDL_FreeSurface(oldSurface);
end;

//---------------------------------------------------------------------------

/// Draws one bitmap (src) onto another bitmap (dest).
///
/// @param dest:         The destination bitmap - not optimised!
/// @param src: The bitmap to be drawn onto the destination
/// @param x,y:         The x,y location to draw the bitmap to
///
/// Side Effects:
/// - Draws the src at the x,y location in the destination.
procedure DrawBitmap(dest: Bitmap; src: Bitmap; x, y : LongInt); overload;
var
  offset: SDL_Rect;
begin
  if (dest = nil) or (src = nil) then exit;
  
  offset := NewSDLRect(x, y, 0, 0);
  SDL_BlitSurface(src^.surface, nil, dest^.surface, @offset);
end;

/// Draws part of a bitmap (src) onto another bitmap (dest).
///
/// @param dest:     The destination bitmap - not optimised!
/// @param src: The bitmap to be drawn onto the destination
/// @param srcX, srcY:   The x,y offset to the area to copy in src
/// @param srcW, srcH:   The width and height of the area to copy
/// @param x,y:      The x,y location to draw the bitmap part to
///
/// Side Effects:
/// - Draws part of the src at the x,y location in the destination.
procedure DrawBitmapPart(dest: Bitmap; src: Bitmap; srcX, srcY, srcW, srcH, x, y : LongInt); overload;
var
  offset, source: SDL_Rect;
begin
  if (dest = nil) or (src = nil) then begin {RaiseException('No bitmap supplied');} exit; end;
  if (srcW <= 0) or (srcH <= 0) then begin {RaiseException('Width and Height must be >= 0');} exit; end;
  
  offset := NewSDLRect(x, y, 0, 0);
  source := NewSDLRect(srcX, srcY, srcW, srcH);

  SDL_BlitSurface(src^.surface, @source, dest^.surface, @offset);
end;

procedure DrawBitmapPart(dest: Bitmap; src: Bitmap; const source: Rectangle; x, y : LongInt); overload;
begin
  DrawBitmapPart(dest, src, Round(source.x), Round(source.y), source.width, source.height, x, y);
end;

/// Draws part of a bitmap (src) onto the screen.
///
/// @param src: The bitmap to be drawn onto the screen
/// @param srcX, srcY:  The x,y offset to the area to copy in src
/// @param srcW, srcH:  The width and height of the area to copy
/// @param x,y:       The x,y location to draw the bitmap part to
///
/// Side Effects:
/// - Draws part of the src at the x,y location on the screen.
/// - Effected by visible window
procedure DrawBitmapPartOnScreen(src : Bitmap; srcX, srcY, srcW, srcH, x, y : LongInt); overload;
begin
  DrawBitmapPart(screen, src, srcX, srcY, srcW, srcH, x, y);
end;

procedure DrawBitmapPart(src : Bitmap; srcX, srcY, srcW, srcH: LongInt; x, y : Single); overload;
begin
  DrawBitmapPart(screen, src, srcX, srcY, srcW, srcH, sgCamera.ToScreenX(x), sgCamera.ToScreenY(y));
end;

/// Draws one bitmap (src) onto the screen.
///
/// @param src:  The bitmap to be drawn onto the screen
/// @param x,y:       The x,y location to draw the bitmap to
///
/// Side Effects:
/// - Draws the src at the x,y location on the screen.
procedure DrawBitmapOnScreen(src : Bitmap; x, y : LongInt); overload;
begin
  DrawBitmap(screen, src, x, y);
end;

procedure DrawBitmap(src : Bitmap; x, y : Single); overload;
begin
  DrawBitmap(screen, src, sgCamera.ToScreenX(x), sgCamera.ToScreenY(y));
end;

procedure DrawBitmap(dest: Bitmap; src: Bitmap; const position: Point2D); overload;
begin
  DrawBitmap(dest, src, Round(position.x), Round(position.y));
end;

procedure DrawBitmapPart(dest: Bitmap; src: Bitmap; const source: Rectangle; const position: Point2D); overload;
begin
  DrawBitmapPart(dest, src, source, Round(position.x), Round(position.y));
end;

procedure DrawBitmap(src : Bitmap; const position : Point2D); overload;
begin
  DrawBitmap(src, Round(position.x), Round(position.y));
end;

procedure DrawBitmapPart(src : Bitmap; const source : Rectangle; x, y : Single); overload;
begin
  DrawBitmapPart(src, Round(source.x), Round(source.y), source.width, source.height, x, y);
end;

procedure DrawBitmapPart(src : Bitmap; const source : Rectangle; const position : Point2D); overload;
begin
  DrawBitmapPart(src, source, Round(position.x), Round(position.y));
end;

procedure DrawBitmapPartOnScreen(src : Bitmap; const source: Rectangle; x, y : LongInt); overload;
begin
  DrawBitmapPartOnScreen(src, Round(source.x), Round(source.y), source.width, source.height, x, y);
end;

procedure DrawBitmapPartOnScreen(src : Bitmap; const source: Rectangle; const position: Point2D); overload;
begin
  DrawBitmapPartOnScreen(src, source, Round(position.x), Round(position.y));
end;

procedure DrawBitmapOnScreen(src : Bitmap; const position : Point2D); overload;
begin
  DrawBitmapOnScreen(src, Round(position.x), Round(position.y))
end;

//---------------------------------------------------------------------------

procedure ClearSurface(dest: Bitmap; toColor: Color); overload;
begin
  if dest = nil then
  begin
    RaiseException('Cannot clear, destination bitmap not supplied (nil)');
    exit;
  end;
  SDL_FillRect(dest^.surface, @dest^.surface^.clip_rect, toColor);
end;

procedure ClearSurface(dest: Bitmap); overload;
begin
  ClearSurface(dest, ColorBlack);
end;

//---------------------------------------------------------------------------

procedure DrawCell(dest: Bitmap; src: Bitmap; cell: LongInt; x, y: Single); overload;
begin
  //DrawBitmapPart(dest, src, srcX, srcY, src^.cellW, src^.cellH, x, y);
  DrawBitmapPart(dest, src, BitmapRectangleOfCell(src, cell), Round(x), Round(y));
end;

procedure DrawCell(dest: Bitmap; src: Bitmap; cell: LongInt; const position: Point2D); overload;
begin
  DrawCell(dest, src, cell, Round(position.x), Round(position.y));
end;

procedure DrawCell(src: Bitmap; cell: LongInt; x, y: Single); overload;
begin
  DrawCell(screen, src,  cell, ToScreenX(x), ToScreenY(y));
end;

procedure DrawCell(src: Bitmap; cell: LongInt; const position: Point2D); overload;
begin
  DrawCell(src, cell, Round(position.x), Round(position.y));
end;

procedure DrawCellOnScreen(src: Bitmap; cell: LongInt; x, y: Single); overload;
begin
  DrawCell(screen, src, cell, x, y);
end;

procedure DrawCellOnScreen(src: Bitmap; cell: LongInt; const position: Point2D); overload;
begin
  DrawCell(screen, src, cell, position);
end;

//---------------------------------------------------------------------------

procedure DrawBitmapCell(dest: Bitmap; const src: BitmapCell; x, y : LongInt); overload;
begin
  if src.cell = -1 then
    DrawBitmap(dest, src.bmp, x, y)
  else
    DrawCell(dest, src.bmp, src.cell, x, y);
end;

procedure DrawBitmapCell(dest: Bitmap; const src: BitmapCell; const position : Point2D); overload;
begin
  if src.cell = -1 then
    DrawBitmap(dest, src.bmp, position)
  else
    DrawCell(dest, src.bmp, src.cell, position);
end;

procedure DrawBitmapCell(const src : BitmapCell; x, y : Single); overload;
begin
  if src.cell = -1 then
    DrawBitmap(src.bmp, x, y)
  else
    DrawCell(src.bmp, src.cell, x, y);
end;

procedure DrawBitmapCell(const src : BitmapCell; const position : Point2D); overload;
begin
  if src.cell = -1 then
    DrawBitmap(src.bmp, position)
  else
    DrawCell(src.bmp, src.cell, position);
end;

procedure DrawBitmapCellOnScreen(const src : BitmapCell; x, y : LongInt); overload;
begin
  if src.cell = -1 then
    DrawBitmapOnScreen(src.bmp, x, y)
  else
    DrawCellOnScreen(src.bmp, src.cell, x, y);
end;

procedure DrawBitmapCellOnScreen(const src : BitmapCell; const position : Point2D); overload;
begin
  if src.cell = -1 then
    DrawBitmapOnScreen(src.bmp, position)
  else
    DrawCellOnScreen(src.bmp, src.cell, position);
end;

//---------------------------------------------------------------------------

function BitmapRectangle(x, y: Single; bmp: Bitmap): Rectangle; overload;
begin
  if not Assigned(bmp) then result := RectangleFrom(0,0,0,0)
  else result := RectangleFrom(x, y, bmp^.width, bmp^.height);
end;

function BitmapRectangle(bmp: Bitmap): Rectangle; overload;
begin
  result := BitmapRectangle(0,0,bmp);
end;

function BitmapCellRectangle(x, y: Single; bmp: Bitmap): Rectangle; overload;
begin
  {$IFDEF TRACE}
    TraceEnter('sgImages', 'BitmapCellRectangle(x, y: Single', '');
  {$ENDIF}
  
  if not Assigned(bmp) then result := RectangleFrom(0,0,0,0)
  else result := RectangleFrom(x, y, bmp^.cellW, bmp^.cellH);
  
  {$IFDEF TRACE}
    TraceExit('sgImages', 'BitmapCellRectangle(x, y: Single', '');
  {$ENDIF}
end;

function BitmapCellRectangle(const pt: Point2D; bmp: Bitmap): Rectangle; overload;
begin
  {$IFDEF TRACE}
    TraceEnter('sgImages', 'BitmapCellRectangle(const pt: Point2D', '');
  {$ENDIF}
  
  result := BitmapCellRectangle(pt.x, pt.y, bmp);
  
  {$IFDEF TRACE}
    TraceExit('sgImages', 'BitmapCellRectangle(const pt: Point2D', '');
  {$ENDIF}
end;

function BitmapCellRectangle(bmp: Bitmap): Rectangle; overload;
begin
  {$IFDEF TRACE}
    TraceEnter('sgImages', 'BitmapCellRectangle(bmp: Bitmap): Rectangle', '');
  {$ENDIF}
  
  result := BitmapCellRectangle(0, 0, bmp);
  
  {$IFDEF TRACE}
    TraceExit('sgImages', 'BitmapCellRectangle(bmp: Bitmap): Rectangle', '');
  {$ENDIF}
end;

function BitmapRectangleOfCell(src: Bitmap; cell: LongInt): Rectangle;
begin
  if (cell < 0) or (cell >= src^.cellCount) then
    result := RectangleFrom(0,0,0,0)
  else
  begin
    result.x := (cell mod src^.cellCols) * src^.cellW;
    result.y := (cell - (cell mod src^.cellCols)) div src^.cellCols * src^.cellH;
    result.width := src^.cellW;
    result.height := src^.cellH;
  end;
end;

function BitmapWidth(bmp: Bitmap): LongInt; overload;
begin
  if not assigned(bmp) then result := 0
  else result := bmp^.width;
end;

function BitmapHeight(bmp: Bitmap): LongInt; overload;
begin
  if not assigned(bmp) then result := 0
  else result := bmp^.height;
end;

function SameBitmapCell(const bmp1, bmp2: BitmapCell): Boolean;
begin
  result := (bmp1.bmp = bmp2.bmp) and (bmp1.cell = bmp2.cell);
end;

function BitmapCellOf(bmp: Bitmap; cell: LongInt): BitmapCell;
begin
  result.bmp := bmp;
  if cell >= -1 then result.cell := cell
  else result.cell := -1;
end;

function BitmapWidth(const bmp: BitmapCell): LongInt; overload;
begin
  if bmp.cell = -1 then result := BitmapWidth(bmp.bmp)
  else result := BitmapCellWidth(bmp.bmp);
end;

function BitmapHeight(const bmp: BitmapCell): LongInt; overload;
begin
  if bmp.cell = -1 then result := BitmapHeight(bmp.bmp)
  else result := BitmapCellHeight(bmp.bmp);
end;

function BitmapCellWidth(bmp: Bitmap): LongInt;
begin
  if not assigned(bmp) then result := 0
  else result := bmp^.cellW;
end;

function BitmapCellHeight(bmp: Bitmap): LongInt;
begin
  if not assigned(bmp) then result := 0
  else result := bmp^.cellH;
end;

function BitmapName(bmp:Bitmap): string;
begin
  result:= '';
  if not assigned(bmp) then exit;
  result:=bmp^.name;
end;

function BitmapFilename(bmp:Bitmap): string;
begin
  result:= '';
  if not assigned(bmp) then exit;
  result:=bmp^.filename;
end;

function BitmapCircle(bmp: Bitmap; x, y: LongInt): Circle; overload;
begin
  result := BitmapCircle(bmp, PointAt(x, y));
end;

function BitmapCircle(bmp: Bitmap; const pt: Point2D): Circle; overload;
begin
  {$IFDEF TRACE}
    TraceEnter('sgImages', 'BitmapCircle', '');
  {$ENDIF}
  
  result.center := pt;
  
  if BitmapWidth(bmp) > BitmapHeight(bmp) then
    result.radius := Ceiling(BitmapWidth(bmp) / 2)
  else
    result.radius := Ceiling(BitmapHeight(bmp) / 2);
  
  {$IFDEF TRACE}
    TraceExit('sgImages', 'BitmapCircle', '');
  {$ENDIF}
end;


function BitmapCellCircle(bmp: Bitmap; x, y: LongInt): Circle; overload;
begin
  result := BitmapCellCircle(bmp, PointAt(x, y));
end;

function BitmapCellCircle(bmp: Bitmap; const pt: Point2D): Circle; overload;
begin
  {$IFDEF TRACE}
    TraceEnter('sgImages', 'BitmapCellCircle', '');
  {$ENDIF}
  
  result.center := pt;
  
  if BitmapCellWidth(bmp) > BitmapCellHeight(bmp) then
    result.radius := Ceiling(BitmapCellWidth(bmp) / 2)
  else
    result.radius := Ceiling(BitmapCellHeight(bmp) / 2);
  
  {$IFDEF TRACE}
    TraceExit('sgImages', 'BitmapCellCircle', '');
  {$ENDIF}
end;

//---------------------------------------------------------------------------

procedure SaveBitmap(src: Bitmap; filepath: String);
begin
  SDL_SaveBMP(src^.surface, PChar(filepath));
end;

//---------------------------------------------------------------------------

procedure SetTransparentColor(src: Bitmap; clr:Color);
var
  x,y : integer;
begin
  if not assigned(src) then exit;
  
  for x:= 0 to src^.Width - 1 do
  begin
    for y := 0 to src^.Height - 1 do
    begin
      if (GetPixel(src, x, y) = clr) then PutPixel(src,RGBAColor(0,0,0,0),x,y);
    end;
  end;
end;

procedure SaveToPNG(bmp: Bitmap; filename: String);
begin
  if not assigned(bmp) then exit;
  
  png_save_surface(filename, bmp^.surface);
end;

//=============================================================================

  initialization
  begin
    {$IFDEF TRACE}
      TraceEnter('sgImages', 'initialization');
    {$ENDIF}
    
    InitialiseSwinGame();
    
    _Images := TStringHash.Create(False, 1024);
    
    {$IFDEF TRACE}
      TraceExit('sgImages', 'initialization');
    {$ENDIF}
  end;

//=============================================================================
end.
//=============================================================================
