//=============================================================================
// sgSprites.pas
//=============================================================================
//
// Create and manage sprites in SwinGame.
//
// Change History:
//
// Version 3.0:
// - 2009-12-21: Andrew : Added the ability to toggle visible layers.
//                      : Added width/height of layers and layer offsets
//                      : Added rectangle calculation code for sprite layers
// - 2009-12-20: Andrew : Added code to manage sprite layers (show, hide, reorder, etc)
// - 2009-12-18: Andrew : Moved to new sprite format.
// - 2009-11-10: Andrew : Changed sn and csn tags
// - 2009-10-16: Andrew : Called the free notifier to ensure Sprites are freed
// - 2009-07-06: Andrew : Added property access routines for Sprite data
// - 2009-06-29: Andrew : Renamed CurrentWidth to SpriteWidth
//                      : Renamed CurrentHeight to SpriteHeight
//                      : Renamed IsSpriteOnScreenAt to SpriteOnScreenAt
// - 2009-06-20: Andrew : Created Sprites unit.
//
//=============================================================================

/// SwinGame Sprites are game elements that can be moved, and animated. Sprites are
/// located at a position in the game, have a velocity, and an animation. The 
/// Sprite can also have arbitary data associated with it for game specific purposes.
///
/// @module Sprites
unit sgSprites;

//=============================================================================
interface
  uses sgTypes;
//=============================================================================
  
  /// Returns a `Vector` that is the difference in the position of two sprites
  /// (``s1`` and ``s2``).
  ///
  /// @lib
  /// @sn vectorFromSprite:%s toSprite:%s
  ///
  /// @class Sprite
  /// @method VectorTo
  /// @csn vectorToSprite:%s
  function VectorFromTo(s1, s2: Sprite): Vector;
  
  /// Returns a `Vector` that is the difference in location from the center of
  /// the sprite ``s`` to the point ``pt``.
  ///
  /// @lib
  /// @sn vectorFromCenterOfSprite:%s toPoint:%s
  ///
  /// @class Sprite
  /// @overload VectorTo VectorToPoint
  /// @csn vectorToPoint:%s
  function VectorFromCenterSpriteToPoint(s: Sprite; const pt: Point2D): Vector;
  
  
  //---------------------------------------------------------------------------
  // Sprite routines
  //---------------------------------------------------------------------------
  
  /// Creates a sprite for the passed in bitmap image. The sprite will use the cell information within the 
  /// sprite if it is animated at a later stage. This version of CreateSprite will initialise the sprite to use
  /// pixel level collisions, no animation, the layer have name 'layer1'.
  /// 
  /// @lib CreateBasicSprite
  /// 
  /// @class Sprite
  /// @constructor
  /// @csn initWithBitmap:%s
  function CreateSprite(layer: Bitmap): Sprite; overload;
  
  /// Creates a sprite for the passed in bitmap image. The sprite will use the cell information within the 
  /// sprite if it is animated at a later stage. This version of CreateSprite will initialise the sprite to use
  /// pixel level collisions, no animation, and the specified layer have name.
  /// 
  /// @lib CreateSpriteWithLayer
  /// 
  /// @class Sprite
  /// @constructor
  /// @csn initWithBitmap:%s layerNamed:%s
  function CreateSprite(layer: Bitmap; layerName: String): Sprite; overload;
  
  /// Creates a sprite for the passed in bitmap image. The sprite will use the cell information within the 
  /// sprite if it is animated at a later stage. This version of CreateSprite will initialise the sprite to use
  /// pixel level collisions, the specified animation template, the layer have name 'layer1'.
  /// 
  /// @lib CreateSpriteWithAnimation
  /// 
  /// @class Sprite
  /// @constructor
  /// @csn initWithBitmap:%s animationTemplate:%s
  function CreateSprite(layer: Bitmap; ani: AnimationTemplate): Sprite; overload;
  
  /// Creates a sprite for the passed in bitmap image. The sprite will use the cell information within the 
  /// sprite if it is animated at a later stage. This version of CreateSprite will initialise the sprite to use
  /// pixel level collisions, the specified animation template, and layer name.
  /// 
  /// @lib CreateSpriteWithLayerAndAnimation
  /// 
  /// @class Sprite
  /// @constructor
  /// @csn initWithBitmap:%s layerNamed:%s animationTemplate:%s
  function CreateSprite(layer: Bitmap; layerName: String; ani: AnimationTemplate): Sprite; overload;
  
  /// Creates a sprite for the passed in bitmap images. The sprite will use the cell information within the 
  /// sprite if it is animated at a later stage. This version of CreateSprite will initialise the sprite to use
  /// pixel level collisions, no animation, the layer names 'layer1', 'layer2',... .
  /// 
  /// @lib CreateLayeredSprite
  /// 
  /// @class Sprite
  /// @constructor
  /// @csn initWithBitmaps:%s
  function CreateSprite(const layers: BitmapArray): Sprite; overload;
  
  /// Creates a sprite for the passed in bitmap images. The sprite will use the cell information within the 
  /// sprite if it is animated at a later stage. This version of CreateSprite will initialise the sprite to use
  /// pixel level collisions, no animation, and the specified layer names.
  /// 
  /// @lib CreateLayeredSpriteWithLayerNames
  /// 
  /// @class Sprite
  /// @constructor
  /// @csn initWithBitmaps:%s layerNames:%s
  function CreateSprite(const layers: BitmapArray; const layerNames: StringArray): Sprite; overload;
  
  /// Creates a sprite for the passed in bitmap images. The sprite will use the cell information within the 
  /// sprite if it is animated at a later stage. This version of CreateSprite will initialise the sprite to use
  /// pixel level collisions, the specified animation template, the layer names 'layer1', 'layer2',... .
  /// 
  /// @lib CreateLayeredSpriteWithAnimationTemplate
  /// 
  /// @class Sprite
  /// @constructor
  /// @csn initWithBitmaps:%s animationTemplate:%s
  function CreateSprite(const layers: BitmapArray; ani: AnimationTemplate): Sprite; overload;
  
  /// Creates a sprite for the passed in bitmap images. The sprite will use the cell information within the 
  /// sprite if it is animated at a later stage. This version of CreateSprite will initialise the sprite to use
  /// pixel level collisions, no animation, the layer names 'layer1', 'layer2',... .
  /// 
  /// @lib CreateLayeredSpriteWithLayerNamesAndAnimationTemplate
  /// 
  /// @class Sprite
  /// @constructor
  /// @csn initWithBitmaps:%s layerNames:%s animationTemplate:%s
  function CreateSprite(const layers: BitmapArray; const layerNames: StringArray; ani: AnimationTemplate): Sprite; overload;
  
  /// Free the resources associated with a sprite.
  /// 
  /// @lib
  /// @class Sprite
  /// @dispose
  procedure FreeSprite(var s : Sprite);
  
  
  //---------------------------------------------------------------------------
  // Layer code
  //---------------------------------------------------------------------------
  
  /// Adds a new layer to the sprite.
  /// 
  /// @lib
  /// @sn sprite:%s addLayer:%s named:%s
  ///
  /// @class Sprite
  /// @method AddLayer
  /// @csn addLayer:%s named:%s
  function SpriteAddLayer(s: Sprite; newLayer: Bitmap; layerName: String): LongInt;
  
  /// Returns the bitmap of the indicated layer of the sprite.
  ///
  /// @lib SpriteLayerNamed
  /// @sn sprite:%s layerNamed:%s
  ///
  /// @class Sprite
  /// @method LayerNamed
  /// @csn layerNamed:%s
  function SpriteLayer(s: Sprite; name: String): Bitmap; overload;
  
  /// Returns the bitmap of the indicated layer of the sprite.
  ///
  /// @lib SpriteLayerAtIdx
  /// @sn sprite:%s layerAtIdx:%s
  ///
  /// @class Sprite
  /// @method LayerAtIdx
  /// @csn layerAtIdx:%s
  function SpriteLayer(s: Sprite; idx: LongInt): Bitmap; overload;
  
  /// Returns the index of the specified layer.
  ///
  /// @lib SpriteLayerIndex
  /// @sn sprite:%s indexOfLayer:%s
  ///
  /// @class Sprite
  /// @method IndexOfLayer
  /// @csn indexOfLayer:%s
  function SpriteLayerIndex(s: Sprite; name: String): LongInt;
  
  /// Returns the name of the specified layer.
  ///
  /// @lib SpriteLayerName
  /// @sn sprite:%s layerName:%s
  ///
  /// @class Sprite
  /// @method LayerName
  /// @csn layerName:%s
  function SpriteLayerName(s: Sprite; idx: LongInt): String;
  
  /// Show the specified layer of the sprite.
  ///
  /// @lib SpriteShowLayerNamed
  /// @sn sprite:%s showLayerNamed:%s
  ///
  /// @class Sprite
  /// @overload ShowLayer ShowLayerNamed
  /// @csn showLayerNamed:%s
  function SpriteShowLayer(s: Sprite; name: String): LongInt; overload;
  
  /// Show the specified layer of the sprite.
  ///
  /// @lib SpriteShowLayer
  /// @sn sprite:%s showLayer:%s
  ///
  /// @class Sprite
  /// @method ShowLayer
  /// @csn showLayer:%s
  function SpriteShowLayer(s: Sprite; id: LongInt): LongInt; overload;
  
  /// Hide the specified layer of the sprite.
  ///
  /// @lib SpriteHideLayerNamed
  /// @sn sprite:%s hideLayerNamed:%s
  ///
  /// @class Sprite
  /// @overload HideLayer HideLayerNamed
  /// @csn hideLayerNamed:%s
  procedure SpriteHideLayer(s: Sprite; name: String); overload;
  
  /// Hide the specified layer of the sprite.
  ///
  /// @lib SpriteHideLayer
  /// @sn sprite:%s hideLayer:%s
  ///
  /// @class Sprite
  /// @method HideLayer
  /// @csn hideLayer:%s
  procedure SpriteHideLayer(s: Sprite; id: LongInt); overload;
  
  /// Toggle the visibility of the specified layer of the sprite.
  ///
  /// @lib SpriteToggleLayerNamedVisible
  /// @sn sprite:%s toggleVisibleLayerNamed:%s
  ///
  /// @class Sprite
  /// @overload ToggleLayerVisible ToggleLayerNamedVisible
  /// @csn toggleLayerNamedVisible:%s
  procedure SpriteToggleLayerVisible(s: Sprite; name: String); overload;
  
  /// Toggle the visibility of the specified layer of the sprite.
  ///
  /// @lib SpriteToggleLayerVisible
  /// @sn sprite:%s toggleVisibleLayer:%s
  ///
  /// @class Sprite
  /// @method ToggleLayerVisible
  /// @csn toggleLayerVisible:%s
  procedure SpriteToggleLayerVisible(s: Sprite; id: LongInt); overload;
  
  /// Returns the index (z-order) of the sprite's layer.
  ///
  /// @lib SpriteVisibleIndexOfLayerNamed
  /// @sn sprite:%s visibleIndexOfLayerNamed:%s
  ///
  /// @class Sprite
  /// @overload VisibleIndexOfLayer VisibleIndexOfLayerNamed
  /// @csn visibleIndexOfLayerNamed:%s
  function SpriteVisibleIndexOfLayer(s: Sprite; name: String): LongInt; overload;
  
  /// Returns the index (z-order) of the sprite's layer.
  ///
  /// @lib SpriteVisibleIndexOfLayer
  /// @sn sprite:%s visibleIndexOfLayer:%s
  ///
  /// @class Sprite
  /// @method VisibleIndexOfLayer
  /// @csn visibleIndexOfLayer:%s
  function SpriteVisibleIndexOfLayer(s: Sprite; id: LongInt): LongInt; overload;
  
  /// Returns the number of layers within the Sprite.
  ///
  /// @lib
  ///
  /// @class Sprite
  /// @getter LayerCount
  function SpriteLayerCount(s: Sprite): LongInt;
  
  ///Returns the number of layers that are currently visible for the sprite.
  ///
  /// @lib
  ///
  /// @class Sprite
  /// @getter VisibleLayerCount
  function SpriteVisibleLayerCount(s: Sprite): LongInt;
  
  /// Returns the ids of the layers that are currently visible. In order back to front.
  ///
  /// @lib
  ///
  /// @class Sprite
  /// @getter VisibleLayerIds
  /// @length SpriteVisibleLayerCount
  function SpriteVisibleLayerIds(s: Sprite) : LongIntArray;
  
  /// Returns the bitmaps of the layers in the Sprite.
  ///
  /// @lib
  ///
  /// @class Sprite
  /// @getter Layers
  /// @length SpriteLayerCount
  function SpriteLayers(s: Sprite): BitmapArray;
  
  /// Returns the offets of the layers in the Sprite.
  ///
  /// @lib
  ///
  /// @class Sprite
  /// @getter LayerOffsets
  /// @length SpriteLayerCount
  function SpriteLayerOffsets(s: Sprite): Point2DArray;
  
  /// Sets the layer offsets for the sprite.
  ///
  /// @lib
  /// @sn sprite:%s setLayerOffsets:%s
  ///
  /// @class Sprite
  /// @setter LayerOffsets
  /// @length SpriteLayerCount
  procedure SpriteSetLayerOffsets(s: Sprite; values: Point2DArray);
  
  /// Gets the offset of the specified layer.
  ///
  /// @lib SpriteLayerOffsetNamed
  /// @sn sprite:%s offsetOfLayerNamed:%s
  ///
  /// @class Sprite
  /// @overload LayerOffset LayerNamedOffset
  /// @csn offsetOfLayerNamed:%s 
  function SpriteLayerOffset(s: Sprite; name: String): Point2D; overload;
  
  /// Gets the offset of the specified layer.
  ///
  /// @lib
  /// @sn sprite:%s offsetOfLayer:%s
  ///
  /// @class Sprite
  /// @method LayerOffset
  /// @csn offsetOfLayer:%s 
  function SpriteLayerOffset(s: Sprite; idx: LongInt): Point2D; overload;
  
  /// Sets the offset of the specified layer.
  ///
  /// @lib SpriteSetLayerOffsetNamed
  /// @sn sprite:%s setOffsetOfLayer:%s to:%s
  ///
  /// @class Sprite
  /// @overload SetLayerOffset SetLayerNamedOffset
  /// @csn layerNamed:%s setOffset:%s 
  procedure SpriteSetLayerOffset(s: Sprite; name: String; const value: Point2D); overload;
  
  /// Sets the offset of the specified layer.
  ///
  /// @lib
  /// @sn sprite:%s setOffsetOfLayer:%s to:%s
  ///
  /// @class Sprite
  /// @overload SetLayerOffset SetLayerNamedOffset
  /// @csn layerNamed:%s setOffset:%s 
  procedure SpriteSetLayerOffset(s: Sprite; idx: LongInt; const value: Point2D); overload;
  
  /// Returns the index of the n'th (idx parameter) visible layer.
  /// 
  /// @lib
  /// @sn sprite:%s visibleLayer:%s
  ///
  /// @class Sprite
  /// @method VisibleLayer
  function SpriteVisibleLayer(s: Sprite; idx: LongInt): LongInt;
  
  /// Sends the layer specified to the back in the visible layer order.
  /// 
  /// @lib
  /// @sn sprite:%s sendLayerToBack:%s
  ///
  /// @class Sprite
  /// @method SendLayerToBack
  procedure SpriteSendLayerToBack(s: Sprite; visibleLayer: LongInt);
  
  /// Sends the layer specified backward in the visible layer order.
  /// 
  /// @lib
  /// @sn sprite:%s sendLayerToBackward:%s
  ///
  /// @class Sprite
  /// @method SendLayerToBackward
  procedure SpriteSendLayerBackward(s: Sprite; visibleLayer: LongInt);
  
  /// Sends the layer specified forward in the visible layer order.
  /// 
  /// @lib
  /// @sn sprite:%s sendLayerForward:%s
  ///
  /// @class Sprite
  /// @method SendLayerForward
  procedure SpriteBringLayerForward(s: Sprite; visibleLayer: LongInt);
  
  /// Sends the layer specified to the front in the visible layer order.
  /// 
  /// @lib
  /// @sn sprite:%s sendLayerToFront:%s
  ///
  /// @class Sprite
  /// @method SendLayerToFront
  procedure SpriteBringLayerToFront(s: Sprite; visibleLayer: LongInt);
  
  /// Gets a rectangle that surrounds the indicated layer.
  ///
  /// @lib SpriteLayerNamedRectangle
  /// @sn sprite:%s rectangleForLayerNamed:%s
  /// 
  /// @class Sprite
  /// @method RectangleForLayerNamed
  function SpriteLayerRectangle(s: Sprite; name: String): Rectangle; overload;
  
  /// Gets a rectangle that surrounds the indicated layer.
  ///
  /// @lib
  /// @sn sprite:%s rectangleForLayer:%s
  /// 
  /// @class Sprite
  /// @method RectangleForLayer
  function SpriteLayerRectangle(s: Sprite; idx: LongInt): Rectangle; overload;
  
  /// Returns the collision rectangle for the specified sprite.
  ///
  /// @lib
  /// 
  /// @class Sprite
  /// @getter CollisionRectangle
  function SpriteCollisionRectangle(s: Sprite): Rectangle;
  
  /// Gets a circle in the bounds of the indicated layer.
  ///
  /// @lib SpriteLayerNamedCircle
  /// @sn sprite:%s circleForLayerNamed:%s
  /// 
  /// @class Sprite
  /// @method CircleForLayerNamed
  function SpriteLayerCircle(s: Sprite; name: String): Circle; overload;
  
  /// Gets a circle in the bounds of the indicated layer.
  ///
  /// @lib
  /// @sn sprite:%s circleForLayer:%s
  /// 
  /// @class Sprite
  /// @method CircleForLayer
  function SpriteLayerCircle(s: Sprite; idx: LongInt): Circle; overload;
  
  /// Gets a circle in the bounds of the base layer of the indicated sprite.
  ///
  /// @lib
  /// @sn spriteCircle:%s
  /// 
  /// @class Sprite
  /// @method Circle
  function SpriteCircle(s: Sprite): Circle; overload;
  
  /// Gets a circle in the bounds of the indicated sprite's collision rectangle.
  ///
  /// @lib
  /// 
  /// @class Sprite
  /// @method CollisionCircle
  function SpriteCollisionCircle(s: Sprite): Circle;
  
  
  //---------------------------------------------------------------------------
  // Animation code
  //---------------------------------------------------------------------------
  
  /// Restart the sprite's current animation, this will play a sound if the
  /// first cell of the animation is associated with a sound effect.
  /// 
  /// @lib
  /// 
  /// @class Sprite
  /// @method ReplayAnimation
  procedure SpriteReplayAnimation(s : Sprite);
  
  /// Restart the sprite's current animation, this will play a sound if
  /// withSound is true and the first cell of the animation is associated with a sound effect.
  /// 
  /// @lib ReplayAnimationWithSound
  /// @sn sprite:%s replayAnimationWithSound:%s
  /// 
  /// @class Sprite
  /// @overload ReplayAnimation ReplayAnimationWithSound
  /// @csn replayAnimationWithSound:%s
  procedure SpriteReplayAnimation(s: Sprite; withSound: Boolean);
  
  /// Start playing an animation from the sprite's animation template.
  /// This will play a sound effect if the first cell of the animation
  /// has a sound.
  /// 
  /// @lib SpriteStartAnimationNamed
  /// @sn sprite:%s startAnimationNamed:%s
  /// 
  /// @class Sprite
  /// @overload StartAnimation StartAnimationNamed
  /// @csn startAnimationNamed:%s
  procedure SpriteStartAnimation(s: Sprite; named: String); overload;
  
  /// Start playing an animation from the sprite's animation template.
  /// The withSound parameter determines whether to play a sound effect 
  /// if the first cell of the animation has a sound.
  /// 
  /// @lib SpriteStartAnimationNamedWithSound
  /// @sn sprite:%s startAnimationNamed:%s withSound:%s
  /// 
  /// @class Sprite
  /// @overload StartAnimation StartAnimationNamedWithSound
  /// @csn startAnimationNamed:%s withSound:%s
  procedure SpriteStartAnimation(s: Sprite; named: String; withSound: Boolean); overload;
  
  /// Start playing an animation from the sprite's animation template.
  /// This will play a sound effect if the first cell of the animation
  /// has a sound.
  /// 
  /// @lib SpriteStartAnimation
  /// @sn sprite:%s startAnimation:%s
  /// 
  /// @class Sprite
  /// @method StartAnimation
  /// @csn startAnimation:%s
  procedure SpriteStartAnimation(s: Sprite; idx: LongInt); overload;
  
  /// Start playing an animation from the sprite's animation template.
  /// The withSound parameter determines whether to play a sound effect 
  /// if the first cell of the animation has a sound.
  /// 
  /// @lib SpriteStartAnimationWithSound
  /// @sn sprite:%s startAnimation:%s withSound:%s
  /// 
  /// @class Sprite
  /// @overload StartAnimation StartAnimationWithSound
  /// @csn startAnimation:%s withSound:%s
  procedure SpriteStartAnimation(s: Sprite; idx: LongInt; withSound: Boolean); overload;
  
  /// Update the position and animation details of the Sprite.
  /// This will play a sound effect if the new cell of the animation
  /// has a sound.
  ///
  /// @lib UpdateSpritePctWithSound(s, 1.0, true)
  /// @uname UpdateSprite
  /// @sn updateSprite:%s
  ///
  /// @class Sprite
  /// @method Update
  procedure UpdateSprite(s: Sprite); overload;
  
  /// Update the position and animation details of the Sprite.
  /// This will play a sound effect if the new cell of the animation
  /// has a sound and withSound is true.
  ///
  /// @lib UpdateSpritePctWithSound(s, 1.0, withSound)
  /// @uname UpdateSpriteWithSound
  /// @sn updateSprite:%s withSound:%s
  /// 
  /// @class Sprite
  /// @overload Update UpdateWithSound
  /// @csn updateWithSound:%s
  procedure UpdateSprite(s: Sprite; withSound:Boolean); overload;
  
  /// Update the position and animation details of the Sprite by a 
  /// given percentage of a single unit of movement/animation.
  /// This will play a sound effect if the new cell of the animation
  /// has a sound.
  ///  
  /// @lib UpdateSpritePctWithSound(s, pct, true)
  /// @sn updateSprite:%s percent:%s
  ///
  /// @class Sprite
  /// @overload Update UpdatePercent
  /// @csn updatePercent:%s
  procedure UpdateSprite(s: Sprite; pct: Single); overload;
  
  /// Update the position and animation details of the Sprite by a 
  /// given percentage of a single unit of movement/animation.
  /// This will play a sound effect if the new cell of the animation
  /// has a sound and withSound is true.
  ///  
  /// @lib UpdateSpritePctWithSound
  /// @sn updateSprite:%s percent:%s withSound:%s
  /// 
  /// @class Sprite
  /// @overload Update UpdatePercentWithSound
  /// @csn updatePercent:%s withSound:%s
  procedure UpdateSprite(s: Sprite; pct: Single; withSound: Boolean); overload;
  
  /// @lib UpdateSpriteAnimationPctWithSound(s, 1.0, true)
  /// @uname UpdateSpriteAnimation
  /// @class Sprite
  /// @method UpdateAnimation
  procedure UpdateSpriteAnimation(s: Sprite); overload;
  
  /// @lib UpdateSpriteAnimationPctWithSound(s, 1.0, withSound)
  procedure UpdateSpriteAnimation(s: Sprite; withSound: Boolean); overload;
  
  /// @lib UpdateSpriteAnimationPctWithSound(s, pct, true)
  /// @class Sprite
  /// @overload UpdateAnimation UpdateAnimationPct
  procedure UpdateSpriteAnimation(s: Sprite; pct: Single); overload;
  
  /// @lib UpdateSpriteAnimationPctWithSound
  procedure UpdateSpriteAnimation(s: Sprite; pct: Single; withSound: Boolean); overload;
  
  
  /// @lib DrawSpriteOffsetXY
  /// @class Sprite
  /// @overload Draw DrawOffsetXY
  procedure DrawSprite(s : Sprite; xOffset, yOffset: LongInt); overload;
  /// @lib DrawSpriteOffsetPoint
  /// @class Sprite
  /// @overload Draw DrawOffsetPoint
  procedure DrawSprite(s : Sprite; const position: Point2D); overload;
  /// @lib DrawSpriteOffsetXY(s, 0, 0)
  /// @uname DrawSprite
  /// @class Sprite
  /// @method Draw
  procedure DrawSprite(s : Sprite); overload;
  
  /// @lib MoveSprite(s, 1.0)
  /// @uname MoveSprite
  /// @class Sprite
  /// @method Move
  procedure MoveSprite(s: Sprite); overload;
  
  /// @lib MoveSprite
  /// @class Sprite
  /// @overload Move MovePct
  procedure MoveSprite(s: Sprite; pct: Single); overload;
    
  /// @lib MoveSpriteVecPct(s, velocity, 1.0)
  /// @uname MoveSpriteVec
  /// @class Sprite
  /// @overload Move MoveVec
  procedure MoveSprite(s : Sprite; const velocity: Vector); overload;
    
  /// @lib MoveSpriteVecPct
  /// @class Sprite
  ///@overload Move MoveVecPct
  procedure MoveSprite(s : Sprite; const velocity: Vector; pct: Single); overload;

  /// @lib
  /// @class Sprite
  /// @method MoveTo
  procedure MoveSpriteTo(s : Sprite; x,y : LongInt);
  
  //---------------------------------------------------------------------------
  // Sprite Screen Position Tests 
  //---------------------------------------------------------------------------

  /// Returns True if a pixel of the `Sprite` ``s`` is at the screen location
  /// specified (``x`` and ``y``) which is converted to a world location.
  ///
  /// @lib
  /// @class Sprite
  /// @method OnScreenAt
  function SpriteOnScreenAt(s: Sprite; x, y: LongInt): Boolean; overload;

  /// Returns True if a pixel of the `Sprite` ``s`` is at the screen location
  /// specified (``pt``), which is converted to a world location.
  ///
  /// @lib SpriteOnScreenAtPoint
  /// @class Sprite
  /// @overload OnScreenAt OnScreenAtPoint
  function SpriteOnScreenAt(s: Sprite; const pt: Point2D): Boolean; overload;
  
  /// @lib
  /// @class Sprite
  /// @method IsOffscreen
  function IsSpriteOffscreen(s : Sprite): Boolean;
  
  
  
  //---------------------------------------------------------------------------
  // Sprite Width and Heigth - CenterPoint
  //---------------------------------------------------------------------------
  
  /// The current Height of the sprite (aligned to the Y axis).
  ///
  /// @lib
  /// @class Sprite
  /// @getter Height
  function SpriteHeight(s: Sprite): LongInt;
  
  /// @lib SpriteLayerNamedHeight
  function SpriteLayerHeight(s: Sprite; name: String): LongInt; overload;
  /// @lib SpriteLayerHeight
  function SpriteLayerHeight(s: Sprite; idx: LongInt): LongInt; overload;
  
  /// The current Width of the sprite (aligned to the X axis).
  /// 
  /// @lib
  /// @class Sprite
  /// @getter Width
  function SpriteWidth(s: Sprite): LongInt;
  
  /// @lib SpriteLayerNamedWidth
  function SpriteLayerWidth(s: Sprite; name: String): LongInt; overload;
  /// @lib SpriteLayerWidth
  function SpriteLayerWidth(s: Sprite; idx: LongInt): LongInt; overload;
  
  /// Returns the center point of the passed in Sprite. This uses the Sprite's 
  /// Position, Width and Height.
  ///
  /// @lib CenterPoint
  ///
  /// @class Sprite
  /// @getter CenterPoint
  function CenterPoint(s: Sprite): Point2D; overload;
  
  //---------------------------------------------------------------------------
  // Sprite velocity
  //---------------------------------------------------------------------------
  
  /// @lib
  /// @class Sprite
  /// @getter Velocity
  function SpriteVelocity(s: Sprite): Vector;

  /// @lib
  /// @class Sprite
  /// @setter Velocity
  procedure SpriteSetVelocity(s: Sprite; const value: Vector);

  //---------------------------------------------------------------------------
  // Sprite CellCount
  //---------------------------------------------------------------------------
  
  /// Returns a rectangle of the current cell within the Sprite's image.
  ///
  /// @lib
  ///
  /// @class Sprite
  /// @getter CurrentCellRectangle
  function SpriteCurrentCellRectangle(s: Sprite): Rectangle;
  
  /// Returns the rectangle representing the location of the Sprite on the
  /// screen.
  ///
  /// @lib
  ///
  /// @class Sprite
  /// @getter ScreenRectangle
  function SpriteScreenRectangle(s: Sprite): Rectangle;
  
  //---------------------------------------------------------------------------
  // Sprite X,Y
  //---------------------------------------------------------------------------
  
  /// @lib
  /// @class Sprite
  /// @setter X
  procedure SpriteSetX(s: Sprite; value: Single);
    
  /// @lib
  /// @class Sprite
  /// @getter X
  function SpriteX(s: Sprite): Single;
  
  /// @lib
  /// @class Sprite
  /// @setter Y
  procedure SpriteSetY(s: Sprite; value: Single);
    
  /// @lib
  /// @class Sprite
  /// @getter Y
  function SpriteY(s: Sprite): Single;
  
  //---------------------------------------------------------------------------
  // Sprite position
  //---------------------------------------------------------------------------
  
  /// @lib
  /// @class Sprite
  /// @getter Position
  function SpritePosition(s: Sprite): Point2D;

  /// @lib
  /// @class Sprite
  /// @setter Position
  procedure SpriteSetPosition(s: Sprite; const value: Point2D);
  
  //---------------------------------------------------------------------------
  // Sprite DX,DY
  //---------------------------------------------------------------------------
  
  /// @lib
  /// @class Sprite
  /// @setter DX
  procedure SpriteSetDX(s: Sprite; value: Single);
    
  /// @lib
  /// @class Sprite
  /// @getter DX
  function SpriteDX(s: Sprite): Single;
  
  /// @lib
  /// @class Sprite
  /// @setter DY
  procedure SpriteSetDY(s: Sprite; value: Single);
    
  /// @lib
  /// @class Sprite
  /// @getter DY
  function SpriteDY(s: Sprite): Single;
  
  //---------------------------------------------------------------------------
  // Sprite speed and heading
  //---------------------------------------------------------------------------
  
  /// Returns the current speed (distance travelled per update) of the Sprite.
  ///
  /// @lib
  /// @class Sprite
  /// @getter Speed
  function SpriteSpeed(s: Sprite): Single;
  
  /// Alters the speed of the Sprite without effecting the direction.
  ///
  /// @lib
  /// @class Sprite
  /// @setter Speed
  procedure SpriteSetSpeed(s: Sprite; value: Single);
  
  /// Returns the direction the Sprite is heading in degrees.
  ///
  /// @lib
  /// @class Sprite
  /// @getter Heading
  function SpriteHeading(s: Sprite): Single;
  
  /// Alters the direction the Sprite is heading without changing the speed.
  ///
  /// @lib
  /// @class Sprite
  /// @setter Heading
  procedure SpriteSetHeading(s: Sprite; value: Single);
  
  //---------------------------------------------------------------------------
  // Sprite Current Frame
  //---------------------------------------------------------------------------
  
  /// Returns the current animation cell for an Animated Sprite. The cell is
  /// updated when the sprite's animation data is updated.
  ///
  /// @lib
  /// @class Sprite
  /// @getter CurrentCell
  function SpriteCurrentCell(s: Sprite): LongInt;
  
  //---------------------------------------------------------------------------
  // Sprite collision details
  //---------------------------------------------------------------------------
  
  /// @lib
  function SpriteCollisionBitmap(s: Sprite): Bitmap;
  /// @lib
  procedure SpriteSetCollisionBitmap(s: Sprite; bmp: Bitmap);
  
  /// @lib
  function SpriteCollisionKind(s: Sprite): CollisionTestKind;
  
  /// @lib
  procedure SpriteSetCollisionKind(s: Sprite; value: CollisionTestKind);
  
  /// Indicates if the sprites animation has ended.
  /// 
  /// @lib
  /// @class Sprite
  /// @getter AnimationHasEnded
  function SpriteAnimationHasEnded(s: Sprite): Boolean;
  
  //---------------------------------------------------------------------------
  // Sprite mass
  //---------------------------------------------------------------------------
  
  /// This indicates the mass of the Sprite for any of the collide methods from
  /// Physics. The mass of two colliding sprites will determine the relative
  /// velocitys after the collision.
  /// 
  /// @lib
  /// @class Sprite
  /// @getter Mass
  function SpriteMass(s: Sprite): Single;
  
  /// Allows you to change the mass of a Sprite.
  ///
  /// @lib
  /// @class Sprite
  /// @setter Mass
  procedure SpriteSetMass(s: Sprite; value: Single);
  
  //---------------------------------------------------------------------------
  // Sprite rotation
  //---------------------------------------------------------------------------
  
  /// This indicates the angle of rotation of the Sprite. This will rotate any 
  /// images of the sprite before drawing, which can be very slow. Avoid using
  /// this method with bitmap based Sprites where possible.
  /// 
  /// @lib
  /// @class Sprite
  /// @getter Rotation
  function SpriteRotation(s: Sprite): Single;

  /// Allows you to change the rotation of a Sprite.
  ///
  /// @lib
  /// @class Sprite
  /// @setter Rotation
  procedure SpriteSetRotation(s: Sprite; value: Single);
  
  //---------------------------------------------------------------------------
  // Sprite scale
  //---------------------------------------------------------------------------
  
  /// This indicates the scale (0 to 1.0) of the Sprite. This will scale any 
  /// images of the sprite before drawing, which can be very slow. Avoid using
  /// this method with bitmap based Sprites where possible.
  /// 
  /// @lib
  /// @class Sprite
  /// @getter Scale
  function SpriteScale(s: Sprite): Single;

  /// Allows you to change the scale of a Sprite.
  ///
  /// @lib
  /// @class Sprite
  /// @setter Scale
  procedure SpriteSetScale(s: Sprite; value: Single);
  
  //---------------------------------------------------------------------------
  // Sprite value code
  //---------------------------------------------------------------------------
  
  /// Returns the count of sprite's values
  ///
  /// @lib
  ///
  /// @class Sprite
  /// @getter ValueCount 
  function SpriteValueCount(s: Sprite) : LongInt;
  
  /// Returns the names of all of the values of the sprite
  ///
  /// @lib
  ///
  /// @class Sprite
  /// @getter ValueNames
  /// @length SpriteValueCount
  function SpriteValueNames(s: Sprite) : StringArray; 
  
  /// Returns the sprite's value at the index specified
  ///
  /// @lib
  /// @sn sprite:%s valueAt:%s
  ///
  /// @class Sprite
  /// @overload Value ValueAt
  function SpriteValue(s: Sprite; index: LongInt): Single; overload;
  
  /// Returns the indicated value of the sprite
  ///
  /// @lib SpriteValueNamed
  /// @sn sprite:%s valueOf:%s
  ///
  /// @class Sprite
  /// @method Value
  function SpriteValue(s: Sprite; name: String): Single; overload;
  
  /// Adds a new kind of value to the Sprite
  /// 
  /// @lib SpriteAddValue
  /// @sn sprite:%s addValue:%s
  /// 
  /// @class Sprite
  /// @method AddValue
  procedure SpriteAddValue(s: Sprite; name: String);
  
  /// Adds a new kind of value to the Sprite, setting the initial value
  /// to the value passed in.
  /// 
  /// @lib SpriteAddValueWithInitialValue
  /// @sn sprite:%s addValue:%s initally:%s
  /// 
  /// @class Sprite
  /// @overload AddValue AddValueWithDefault
  /// @csn addValue:%s initally:%s
  procedure SpriteAddValue(s: Sprite; name: String; initVal: Single);
  
  /// Assigns a value to the Sprite.
  ///
  /// @lib SpriteSetValueNamed
  /// @sn sprite:%s setValueNamed:%s to:%s
  ///
  /// @class Sprite
  /// @overload SetValue SetValueNamed
  /// @csn setValueNamed:%s to:%s
  procedure SpriteSetValue(s: Sprite; name: String; val: Single); overload;
  
  /// Assigns a value to the Sprite.
  ///
  /// @lib SpriteSetValue
  /// @sn sprite:%s setValue:%s to:%s
  ///
  /// @class Sprite
  /// @method SetValue
  /// @csn setValue:%s to:%s
  procedure SpriteSetValue(s: Sprite; idx: LongInt; val: Single); overload;
  
  
//=============================================================================
implementation
  uses
    Classes, SysUtils, Math, // System
    sgNamedIndexCollection, //libsrc
    sgAnimations, sgGraphics, sgGeometry, sgCore, sgCamera, sgShared, sgResources, sgImages; //SwinGame
//=============================================================================

  
  const
    MASS_IDX      = 0;  // The index of the sprite's mass value
    ROTATION_IDX  = 1;  // The index of the sprite's rotation value
    SCALE_IDX     = 2;  // The index of the sprite's scale value
    // WIDTH_IDX     = 3;  // The index of the sprite's width value
    // HEIGHT_IDX    = 4;  // The index of the sprite's height value
    
  
  function VectorFromTo(s1, s2: Sprite): Vector;
  begin
    result := VectorFromPoints(CenterPoint(s1), CenterPoint(s2));
  end;

  function VectorFromCenterSpriteToPoint(s: Sprite; const pt: Point2D): Vector;
  begin
    result := VectorFromPoints(CenterPoint(s), pt);
  end;
  
  function CreateSprite(layer: Bitmap): Sprite; overload;
  begin
    result := CreateSprite(layer, 'layer0', nil);
  end;
  
  function CreateSprite(layer: Bitmap; layerName: String): Sprite; overload;
  begin
    result := CreateSprite(layer, layerName, nil);
  end;
  
  function CreateSprite(layer: Bitmap; ani: AnimationTemplate): Sprite; overload;
  begin
    result := CreateSprite(layer, 'layer0', ani);
  end;
  
  function CreateSprite(layer: Bitmap; layerName: String; ani: AnimationTemplate): Sprite; overload;
  var
    layerNames: StringArray;
    layers: BitmapArray;
  begin
    SetLength(layerNames, 1);
    SetLength(layers, 1);
    
    layerNames[0] := layerName;
    layers[0] := layer;
    
    result := CreateSprite(layers, layerNames, ani);
  end;
  
  function CreateSprite(const layers: BitmapArray): Sprite; overload;
  begin
    result := CreateSprite(layers, AnimationTemplate(nil));
  end;
  
  function CreateSprite(const layers: BitmapArray; const layerNames: StringArray): Sprite; overload;
  begin
    result := CreateSprite(layers, layerNames, nil);
  end;
  
  function CreateSprite(const layers: BitmapArray; ani: AnimationTemplate): Sprite; overload;
  var
    layerNames: StringArray;
    i: LongInt;
  begin
    SetLength(layerNames, Length(layers));
    for i := 0 to High(layers) do
    begin
      layerNames[i] := 'layer' + IntToStr(i);
    end;
    
    result := CreateSprite(layers, layerNames, ani);
  end;
  
  function CreateSprite(const layers: BitmapArray; const layerNames: StringArray; ani: AnimationTemplate): Sprite; overload;
  var
    i, count: LongInt;
  begin
    result := nil; 
    count := Length(layers);
    
    if count <> Length(layerNames) then begin RaiseException('The number of layers and layer names do not match.'); exit; end;
    if count = 0 then begin exit; end;
      
    //Allocate the space for the sprite
    New(result);
    
    //Set lengths of the layer arrays
    SetLength(result^.layers, count);
    SetLength(result^.layerOffsets, count);
    
    for i := 0 to High(result^.layers) do
    begin
      result^.layers[i] := layers[i];
      result^.layerOffsets[i] := PointAt(0,0);
      
      // Make sure that this image can be used interchangably with the other layers of the
      // sprite.
      if not BitmapsInterchangable(result^.layers[i], result^.layers[0]) then
      begin
        Dispose(result);
        result := nil;
        RaiseException('Layer ' + IntToStr(i) + ' is not the interchangable with the other layers of this sprite.');
        exit;
      end;
    end;
    
    // Setup the layer name <-> id mapping
    InitNamedIndexCollection(result^.layerIds, layerNames);
    
    // Set the first layer as visible.
    SetLength(result^.visibleLayers, 1);
    result^.visibleLayers[0] := 0;                //The first layer (at idx 0) is drawn
    
    // Setup the values
    SetLength(result^.values, 3);
    InitNamedIndexCollection(result^.valueIds);
    
    AddName(result^.valueIds, 'mass');            //idx 0 = mass, default to 1
    result^.values[MASS_IDX]      := 1;
    
    AddName(result^.valueIds, 'rotation');        //idx 1 = rotation, default to 0
    result^.values[ROTATION_IDX]  := 0;
    
    AddName(result^.valueIds, 'scale');           //idx 2 = scale, default to 1
    result^.values[SCALE_IDX]     := 1;
    
    // Position the sprite
    result^.position              := PointAt(0,0);
    
    // Initialise sprite movement
    result^.velocity              := VectorTo(0,0);
    
    // Setup animation detials
    result^.animationTemplate     := ani;
    result^.animationData         := nil;
    
    // Setup collision details
    result^.collisionKind         := PixelCollisions;
    result^.collisionBitmap       := result^.layers[0];
  end;
  
  // //
  // // Update the buffered image for rotation and scaling of a bitmap based sprite.
  // //
  // procedure UpdateSpriteBuffers(s: Sprite);
  // var
  //   dest: Bitmap; //temporary surface
  //   srcX, srcY: LongInt; //for image parts
  // begin
  //   if (s^.rotation = s^.bufferedRotation) and (s^.scale = s^.bufferedScale) then exit;
  //   if (s^.bufferBmp <> nil) then FreeBitmap(s^.bufferBmp);
  //   if (s^.rotation = 0) and (s^.scale = 1) then exit; //no need to transform
  // 
  //   //Draw non-transformed bitmap onto temp surface
  //   dest := CreateBitmap(s^.width, s^.height);
  // 
  //   if s^.spriteKind <> AnimMultiSprite then
  //     DrawBitmap(dest, s^.bitmaps[s^.currentCell], 0, 0)
  //   else
  //   begin
  //     with s^ do
  //     begin
  //       srcX := (currentCell mod cols) * width;
  //       srcY := (currentCell - (currentCell mod cols)) div cols * height;
  //     end;
  // 
  //     MakeOpaque(s^.bitmaps[0]);
  //     DrawBitmapPart(dest, s^.bitmaps[0], srcX, srcY, s^.width, s^.height, 0, 0);
  //     MakeTransparent(s^.bitmaps[0]);
  //   end;
  // 
  //   s^.bufferBmp := RotateScaleBitmap(dest, s^.rotation, s^.scale);
  // 
  //   FreeBitmap(dest);
  // end;

  procedure FreeSprite(var s : Sprite);
  begin
    if Assigned(s) then
    begin
      // Free arrays
      SetLength(s^.layers, 0);
      SetLength(s^.visibleLayers, 0);
      SetLength(s^.values, 0);
      SetLength(s^.layerOffsets, 0);
      
      // Free the name <-> id maps
      FreeNamedIndexCollection(s^.layerIds);
      FreeNamedIndexCollection(s^.valueIds);
      
      // Free pointers
      FreeAnimation(s^.animationData);
      
      // Nil pointers to resources managed by sgResources
      s^.animationTemplate := nil;
      s^.collisionBitmap := nil;
      
      //Free buffered rotation image
      // if s^.bufferBmp <> nil then FreeBitmap(s^.bufferBmp);
      // s^.bufferBmp := nil;
      
      //Dispose sprite
      CallFreeNotifier(s);
      
      Dispose(s);
      s := nil;
    end;
  end;
  
  function SpriteAddLayer(s: Sprite; newLayer: Bitmap; layerName: String): LongInt;
  begin
    if newLayer = nil then begin RaiseException('Cannot add non-existing bitmap to Sprite'); exit; end;
    if s = nil then begin RaiseException('No sprite to add to'); exit; end;
    
    result := AddName(s^.layerIds, layerName);
    if (result <> Length(s^.layers)) then begin RaiseException('Error adding layer ' + layerName); exit; end;
    
    //Resize the array
    SetLength(s^.layers, Length(s^.layers) + 1);
    SetLength(s^.layerOffsets, Length(s^.layerOffsets) + 1);
    
    //Add the values to the array
    s^.layers[result] := newLayer;
    s^.layerOffsets[result] := PointAt(0,0);
  end;
  
  procedure SpriteReplayAnimation(s: Sprite);
  begin
    SpriteReplayAnimation(s, true);
  end;
  
  procedure SpriteReplayAnimation(s: Sprite; withSound: Boolean);
  begin
    if s = nil then exit;
    
    RestartAnimation(s^.animationData, withSound);
  end;
  
  procedure SpriteStartAnimation(s: Sprite; named: String);
  begin
    SpriteStartAnimation(s, named, true);
  end;
  
  procedure SpriteStartAnimation(s: Sprite; named: String; withSound: Boolean);
  begin
    SpriteStartAnimation(s, AnimationIndex(s^.animationTemplate, named), withSound);
  end;
  
  procedure SpriteStartAnimation(s: Sprite; idx: LongInt);
  begin
    SpriteStartAnimation(s, idx, true);
  end;
  
  procedure SpriteStartAnimation(s: Sprite; idx: LongInt; withSound: Boolean);
  begin
    if not assigned(s) then exit;
    if not assigned(s^.animationTemplate) then exit;
    
    if assigned(s^.animationData) then
      AssignAnimation(s^.animationData, idx, s^.animationTemplate, withSound)
    else
      s^.animationData := CreateAnimation(idx, s^.animationTemplate, withSound);
  end;
  
  procedure UpdateSpriteAnimation(s: Sprite); overload;
  begin
    UpdateSpriteAnimation(s, 1.0, true);
  end;
  
  procedure UpdateSpriteAnimation(s: Sprite; withSound: Boolean); overload;
  begin
    UpdateSpriteAnimation(s, 1.0, withSound);
  end;
  
  procedure UpdateSpriteAnimation(s: Sprite; pct: Single); overload;
  begin
    UpdateSpriteAnimation(s, pct, true);
  end;
  
  procedure UpdateSpriteAnimation(s: Sprite; pct: Single; withSound: Boolean); overload;
  begin
    if not assigned(s) then exit;
    UpdateAnimation(s^.animationData, pct, withSound);
  end;

  procedure UpdateSprite(s: Sprite); overload;
  begin
    UpdateSprite(s, 1.0, true);
  end;
  
  procedure UpdateSprite(s: Sprite; withSound: Boolean); overload;
  begin
    UpdateSprite(s, 1.0, withSound);
  end;
  
  procedure UpdateSprite(s: Sprite; pct: Single); overload;
  begin
    UpdateSprite(s, pct, true);
  end;
  
  procedure UpdateSprite(s: Sprite; pct: Single; withSound: Boolean); overload;
  begin
    MoveSprite(s, pct);
    UpdateSpriteAnimation(s, pct, withSound);
  end;
  
  procedure DrawSprite(s: Sprite); overload;
  begin
    DrawSprite(s, 0, 0);
  end;

  procedure DrawSprite(s : Sprite; const position: Point2D); overload;
  begin
    DrawSprite(s, Round(position.x), Round(position.y));
  end;

  procedure DrawSprite(s: Sprite; xOffset, yOffset: LongInt); overload;
  var
    i, idx: LongInt;
  begin
    if not Assigned(s) then begin RaiseException('No sprite supplied'); exit; end;
    
    for i := 0 to High(s^.visibleLayers) do
    begin
      idx := s^.visibleLayers[i];
      DrawCell(SpriteLayer(s, idx), SpriteCurrentCell(s), 
        Round(s^.position.x + xOffset + s^.layerOffsets[idx].x), 
        Round(s^.position.y + yOffset + s^.layerOffsets[idx].y));
    end;
  end;

  function IsSpriteOffscreen(s : Sprite): Boolean;
  begin
    if s = nil then 
      result := false
    else
      result := not RectOnScreen(SpriteLayerRectangle(s, 0));
  end;

  procedure MoveSprite(s : Sprite; const velocity : Vector); overload;
  begin
    MoveSprite(s, velocity, 1.0);
  end;

  procedure MoveSprite(s : Sprite; const velocity : Vector; pct: Single); overload;
  var
    mvmt: Vector;
  //   trans: Matrix2D;
  begin
    if not Assigned(s) then begin RaiseException('No sprite supplied'); exit; end;
    
    // if s^.rotation <> 0 then
    // begin
    //   trans := RotationMatrix(-s^.rotation);
    //   mvmt := MatrixMultiply(trans, velocity);
    // end
    // else  
    mvmt := velocity;
       
    s^.position.x := s^.position.x + (pct * mvmt.x);
    s^.position.y := s^.position.y + (pct * mvmt.y);
  end;

  procedure MoveSpriteTo(s : Sprite; x,y : LongInt);
  begin
    if s = nil then begin RaiseException('No sprite supplied'); exit; end;
  
    s^.position.x := x;
    s^.position.y := y;
  end;

  procedure MoveSprite(s: Sprite); overload;
  begin
    MoveSprite(s, 1.0);
  end;  

  procedure MoveSprite(s: Sprite; pct: Single); overload;
  begin
    MoveSprite(s, s^.velocity, pct);
  end;

  function SpriteOnScreenAt(s: Sprite; x, y: LongInt): Boolean; overload;
  var
    cellRect: Rectangle;
    wx, wy: Single;
  begin
    result := false;
    
    if not assigned(s) then exit;
    
    wx := ToWorldX(x);
    wy := ToWorldY(y);
    
    if wy > s^.position.y + SpriteHeight(s) then      result := false
    else if wy < s^.position.y then                   result := false
    else if wx > s^.position.x + SpriteWidth(s) then  result := false
    else if wx < s^.position.x then                   result := false
    else if s^.collisionKind = AABBCollisions then    result := true
    else
    begin
      cellRect := SpriteCurrentCellRectangle(s);
      result := PixelDrawnAtPoint(s^.collisionBitmap, Round(wx - s^.position.x + cellRect.x), Round(wy - s^.position.y + cellRect.y));
    end;
  end;

  function SpriteOnScreenAt(s: Sprite; const pt: Point2D): Boolean; overload;
  begin
    result := SpriteOnScreenAt(s, Round(pt.x), Round(pt.y));
  end;

  function SpriteVelocity(s: Sprite): Vector;
  begin
    result := s^.velocity;
  end;

  procedure SpriteSetVelocity(s: Sprite; const value: Vector);
  begin
    s^.velocity := value;
  end;
  
  function SpriteCurrentCellRectangle(s: Sprite): Rectangle;
  begin
    if (not Assigned(s)) then
      result := RectangleFrom(0,0,0,0)
    else
      result := BitmapRectangleOfCell(s^.layers[0], AnimationCurrentCell(s^.animationData));
  end;
  
  function SpriteScreenRectangle(s: Sprite): Rectangle;
  begin
    if (not Assigned(s)) or (not Assigned(s^.animationData)) then
      result := RectangleFrom(0,0,0,0)
    else
      result := ToScreen(SpriteLayerRectangle(s, 0));
  end;
  
  procedure SpriteSetX(s: Sprite; value: Single);
  begin
    s^.position.x := value;
  end;
    
  function SpriteX(s: Sprite): Single;
  begin
    result := s^.position.x;
  end;
  
  procedure SpriteSetY(s: Sprite; value: Single);
  begin
    s^.position.y := value;
  end;
    
  function SpriteY(s: Sprite): Single;
  begin
    result := s^.position.y;
  end;
  
  function SpriteLayer(s: Sprite; name: String): Bitmap;
  begin
    if not assigned(s) then result := nil
    else result := SpriteLayer(s, IndexOf(s^.layerIds, name));
  end;
  
  function SpriteLayer(s: Sprite; idx: LongInt): Bitmap;
  begin
    if not assigned(s) then result := nil
    else if (idx < 0) or (idx > High(s^.layers)) then begin result := nil; RaiseException('Sprite layer index out of range - ' + IntToStr(idx)); exit; end
    else result := s^.layers[idx];
  end;
  
  function SpriteLayerIndex(s: Sprite; name: String): LongInt;
  begin
    if not assigned(s) then result := -1
    else result := IndexOf(s^.layerIds, name);
  end;
  
  function SpriteLayerName(s: Sprite; idx: LongInt): String;
  begin
    if not assigned(s) then result := ''
    else result := NameAt(s^.layerIds, idx);
  end;
  
  function SpriteShowLayer(s: Sprite; name: String): LongInt;
  begin
    if not assigned(s) then result := -1
    else result := SpriteShowLayer(s, IndexOf(s^.layerIds, name));
  end;
  
  function SpriteShowLayer(s: Sprite; id: LongInt): LongInt;
  begin
    if not assigned(s) then result := -1
    else
    begin
      //Scan for the current ID
      result := SpriteVisibleIndexOfLayer(s, id);
      if result >= 0 then exit;
      
      //Extend layers and add index
      SetLength(s^.visibleLayers, Length(s^.visibleLayers) + 1);
      result := High(s^.visibleLayers);
      s^.visibleLayers[result] := id;
    end;
  end;
  
  procedure SpriteHideLayer(s: Sprite; name: String);
  begin
    if not assigned(s) then exit
    else SpriteHideLayer(s, IndexOf(s^.layerIds, name));
  end;
  
  procedure SpriteHideLayer(s: Sprite; id: LongInt);
  var
    i, idx: LongInt;
  begin
    idx := SpriteVisibleIndexOfLayer(s, id);
    if idx < 0 then exit; // The layer is not shown
    
    //Shift all later layers back over removed layer
    for i := idx to High(s^.visibleLayers) - 1 do
    begin
      s^.visibleLayers[i] := s^.visibleLayers[i + 1];
    end;
    
    //Resize the array to remove element
    SetLength(s^.visibleLayers, Length(s^.visibleLayers) - 1);
  end;
  
  procedure SpriteToggleLayerVisible(s: Sprite; name: String); overload;
  begin
    if not assigned(s) then exit
    else SpriteToggleLayerVisible(s, IndexOf(s^.layerIds, name));
  end;
  
  procedure SpriteToggleLayerVisible(s: Sprite; id: LongInt); overload;
  begin
    if SpriteVisibleIndexOfLayer(s, id) < 0 then 
      SpriteShowLayer(s, id)
    else
      SpriteHideLayer(s, id);
  end;
  
  function SpriteLayerCount(s: Sprite): LongInt;
  begin
    if not assigned(s) then result := 0
    else result := Length(s^.layers);
  end;
  
  function SpriteVisibleLayerCount(s: Sprite): LongInt;
  begin
    if not assigned(s) then result := 0
    else result := Length(s^.visibleLayers);
  end;
  
  function SpriteVisibleLayerIds(s: Sprite) : LongIntArray;
  begin
    if not assigned(s) then result := nil
    else result := s^.visibleLayers;
  end;
  
  function SpriteLayers(s: Sprite): BitmapArray;
  begin
    if not assigned(s) then result := nil
    else result := s^.layers;
  end;
  
  function SpriteLayerOffsets(s: Sprite): Point2DArray;
  begin
    if not Assigned(s) then begin result := nil; exit; end;
    result := s^.layerOffsets;
  end;
  
  procedure SpriteSetLayerOffsets(s: Sprite; values: Point2DArray);
  var
    i: LongInt;
  begin
    if not Assigned(s) then exit;
    if not Length(values) = Length(s^.layerOffsets) then begin RaiseException('Unable to set sprite layer offsets as lengths are not equal.'); exit; end;
    
    for i := 0 to High(values) do
    begin
      s^.layerOffsets[i] := values[i];
    end;
  end;
  
  function SpriteLayerOffset(s: Sprite; name: String): Point2D;
  begin
    if not assigned(s) then result := PointAt(0,0)
    else result := SpriteLayerOffset(s, IndexOf(s^.layerIds, name));
  end;
  
  function SpriteLayerOffset(s: Sprite; idx: LongInt): Point2D;
  begin
    if not assigned(s) then result := PointAt(0,0)
    else if (idx < 0) or (idx >= Length(s^.layerOffsets)) then begin RaiseException('Error fetching layer offset out of range.'); result := PointAt(0,0); exit; end
    else result := s^.layerOffsets[idx];
  end;
  
  procedure SpriteSetLayerOffset(s: Sprite; name: String; const value: Point2D);
  begin
    if assigned(s) then
      SpriteSetLayerOffset(s, IndexOf(s^.layerIds, name), value);
  end;
  
  procedure SpriteSetLayerOffset(s: Sprite; idx: LongInt; const value: Point2D);
  begin
    if assigned(s) then
      s^.layerOffsets[idx] := value;
  end;
  
  function SpriteVisibleIndexOfLayer(s: Sprite; name: String): LongInt;
  begin
    if not assigned(s) then result := -1
    else result := SpriteVisibleIndexOfLayer(s, IndexOf(s^.layerIds, name));
  end;
  
  function SpriteVisibleIndexOfLayer(s: Sprite; id: LongInt): LongInt;
  var
    i: LongInt;
  begin
    result := -1;
    if not assigned(s) then exit
    else
    begin
      for i := 0 to High(s^.visibleLayers) do
      begin
        if s^.visibleLayers[i] = id then 
        begin
          result := i;
          exit;
        end;
      end;
    end;
  end;
  
  function SpriteVisibleLayer(s: Sprite; idx: LongInt): LongInt;
  begin
    result := -1;
    if not assigned(s) then exit
    else result := s^.visibleLayers[idx];
  end;
  
  procedure Swap(var val1, val2: LongInt);
  var
    temp: LongInt;
  begin
    temp := val1;
    val1 := val2;
    val2 := temp;
  end;
  
  procedure SpriteSendLayerToBack(s: Sprite; visibleLayer: LongInt);
  var
    i: LongInt;
  begin
    if not assigned(s) then exit;
    //Check not last or beyond in array
    if (visibleLayer < 0) or (visibleLayer >= Length(s^.visibleLayers) - 1) then exit;
    
    // Bubble layer up
    for i := visibleLayer to High(s^.visibleLayers) - 1 do
    begin
      Swap(s^.visibleLayers[i], s^.visibleLayers[i + 1]);
    end;
  end;
  
  procedure SpriteSendLayerBackward(s: Sprite; visibleLayer: LongInt);
  begin
    if not assigned(s) then exit;
    //Check not last or beyond in array
    if (visibleLayer < 0) or (visibleLayer >= Length(s^.visibleLayers) - 1) then exit;
    
    Swap(s^.visibleLayers[visibleLayer], s^.visibleLayers[visibleLayer + 1]);
  end;
  
  procedure SpriteBringLayerForward(s: Sprite; visibleLayer: LongInt);
  begin
    if not assigned(s) then exit;
    //Check not first or lower
    if (visibleLayer < 1) or (visibleLayer >= Length(s^.visibleLayers)) then exit;
    
    Swap(s^.visibleLayers[visibleLayer], s^.visibleLayers[visibleLayer - 1]);
  end;
  
  procedure SpriteBringLayerToFront(s: Sprite; visibleLayer: LongInt);
  var
    i: LongInt;
  begin
    if not assigned(s) then exit;
    //Check not last or beyond in array
    if (visibleLayer < 0) or (visibleLayer >= Length(s^.visibleLayers) - 1) then exit;
    
    // Bubble layer down
    for i := visibleLayer downto 1 do
    begin
      Swap(s^.visibleLayers[i], s^.visibleLayers[i - 1]);
    end;
  end;
  
  function SpriteLayerRectangle(s: Sprite; name: String): Rectangle; overload;
  begin
    if not assigned(s) then result := RectangleFrom(0,0,0,0)
    else result := SpriteLayerRectangle(s, IndexOf(s^.layerIds, name));
  end;
  
  function SpriteLayerRectangle(s: Sprite; idx: LongInt): Rectangle; overload;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgSprites', 'SpriteLayerRectangle(s: Sprite; idx: LongInt): Rectangle', '');
    {$ENDIF}
    
    if not assigned(s) then result := RectangleFrom(0,0,0,0)
    else result := BitmapCellRectangle(s^.position.x + s^.layerOffsets[idx].x, s^.position.y + s^.layerOffsets[idx].y, s^.layers[idx]);
      
    {$IFDEF TRACE}
      TraceExit('sgSprites', 'SpriteLayerRectangle(s: Sprite; idx: LongInt): Rectangle', '');
    {$ENDIF}
  end;
  
  function SpriteCollisionRectangle(s: Sprite): Rectangle; overload;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgSprites', 'SpriteCollisionRectangle(s: Sprite): Rectangle', '');
    {$ENDIF}
    
    if not assigned(s) then result := RectangleFrom(0,0,0,0)
    else result := BitmapCellRectangle(s^.position.x, s^.position.y, s^.collisionBitmap);
    
    {$IFDEF TRACE}
      TraceExit('sgSprites', 'SpriteCollisionRectangle(s: Sprite): Rectangle', '');
    {$ENDIF}
  end;
  
  function SpriteCircle(s: Sprite): Circle; overload;
  begin
    result := SpriteLayerCircle(s, 0);
  end;
  
  function SpriteLayerCircle(s: Sprite; name: String): Circle; overload;
  begin
    if not assigned(s) then result := CircleAt(0,0,0)
    else result := SpriteLayerCircle(s, IndexOf(s^.layerIds, name));
  end;
  
  function SpriteLayerCircle(s: Sprite; idx: LongInt): Circle; overload;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgSprites', 'SpriteLayerCircle(s: Sprite): Circle', '');
    {$ENDIF}
    
    if not assigned(s) then result := CircleAt(0, 0, 0)
    else if (idx < 0) or (idx > High(s^.layers)) then begin RaiseException('Layer out of range in SpriteLayerCircle.'); result := CircleAt(0,0,0); exit; end
    else
    begin
      result := BitmapCellCircle(s^.layers[idx], CenterPoint(s));
    end;
    
    {$IFDEF TRACE}
      TraceExit('sgSprites', 'SpriteLayerCircle(s: Sprite): Circle', '');
    {$ENDIF}
  end;
  
  function SpriteCollisionCircle(s: Sprite): Circle;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgSprites', 'SpriteLayerCircle(s: Sprite): Circle', '');
    {$ENDIF}
    
    if (not assigned(s)) or (not assigned(s^.collisionBitmap)) then result := CircleAt(0, 0, 0)
    else result := BitmapCellCircle(s^.collisionBitmap, CenterPoint(s));
    
    {$IFDEF TRACE}
      TraceExit('sgSprites', 'SpriteLayerCircle(s: Sprite): Circle', '');
    {$ENDIF}
    
  end;
  
  
  //---------------------------------------------------------------------------
  // Sprite position
  //---------------------------------------------------------------------------
  
  function SpritePosition(s: Sprite): Point2D;
  begin
    result := s^.position;
  end;
  
  procedure SpriteSetPosition(s: Sprite; const value: Point2D);
  begin
    s^.position := value;
  end;
  
  //---------------------------------------------------------------------------
  // Sprite DX,DY
  //---------------------------------------------------------------------------
  
  procedure SpriteSetDX(s: Sprite; value: Single);
  begin
    s^.velocity.x := value;
  end;
  
  function SpriteDX(s: Sprite): Single;
  begin
    result := s^.velocity.x;
  end;
  
  procedure SpriteSetDY(s: Sprite; value: Single);
  begin
    s^.velocity.y := value;
  end;
  
  function SpriteDY(s: Sprite): Single;
  begin
    result := s^.velocity.y;
  end;
  
  //---------------------------------------------------------------------------
  // Sprite speed and heading
  //---------------------------------------------------------------------------
  
  function SpriteSpeed(s: Sprite): Single;
  begin
    result := VectorMagnitude(s^.velocity);
  end;
  
  procedure SpriteSetSpeed(s: Sprite; value: Single);
  begin
    s^.velocity := VectorMultiply(UnitVector(s^.velocity), value);
  end;
  
  function SpriteHeading(s: Sprite): Single;
  begin
    result := VectorAngle(s^.velocity);
  end;
  
  procedure SpriteSetHeading(s: Sprite; value: Single);
  begin
    s^.velocity := VectorFromAngle(value, VectorMagnitude(s^.velocity));
  end;
  
  //---------------------------------------------------------------------------
  // Sprite Current cell
  //---------------------------------------------------------------------------
  
  function SpriteCurrentCell(s: Sprite): LongInt;
  begin
    if not assigned(s) then result := -1
    else result := AnimationCurrentCell(s^.animationData);
  end;
  
  function SpriteAnimationHasEnded(s: Sprite): Boolean;
  begin
    if not assigned(s) then result := false
    else result := AnimationEnded(s^.animationData);
  end;
  
  //---------------------------------------------------------------------------
  // Sprite width/height
  //---------------------------------------------------------------------------
  
  function SpriteLayerHeight(s: Sprite; name: String): LongInt; overload;
  begin
    if not Assigned(s) then result := 0
    else result := SpriteLayerHeight(s, IndexOf(s^.layerIds, name));
  end;
  
  function SpriteLayerHeight(s: Sprite; idx: LongInt): LongInt; overload;
  begin
    if not Assigned(s) then result := 0
    else if (idx < 0) or (idx >= Length(s^.layers)) then result := 0
    else result := s^.layers[idx]^.cellH;
  end;
  
  function SpriteLayerWidth(s: Sprite; name: String): LongInt; overload;
  begin
    if not assigned(s) then result := 0
    else result := SpriteLayerWidth(s, IndexOf(s^.layerIds, name));
  end;
  
  function SpriteLayerWidth(s: Sprite; idx: LongInt): LongInt; overload;
  begin
    if not Assigned(s) then result := 0
    else if (idx < 0) or (idx >= Length(s^.layers)) then result := 0
    else result := s^.layers[idx]^.cellW;
  end;  
  
  function SpriteWidth(s: Sprite): LongInt;
  begin
    result := SpriteLayerWidth(s, 0);
  end;
  
  function SpriteHeight(s: Sprite): LongInt;
  begin
    result := SpriteLayerHeight(s, 0);
  end;
  
  
  //---------------------------------------------------------------------------
  // Sprite mass
  //---------------------------------------------------------------------------
  
  function SpriteMass(s: Sprite): Single;
  begin
    result := s^.values[MASS_IDX];
  end;
  
  procedure SpriteSetMass(s: Sprite; value: Single);
  begin
    s^.values[MASS_IDX] := value;
  end;
  
  //---------------------------------------------------------------------------
  // Sprite rotation
  //---------------------------------------------------------------------------
  
  function SpriteRotation(s: Sprite): Single;
  begin
    result := s^.values[ROTATION_IDX];
  end;
  
  procedure SpriteSetRotation(s: Sprite; value: Single);
  begin
    s^.values[ROTATION_IDX] := value;
  end;
  
  //---------------------------------------------------------------------------
  // Sprite scale
  //---------------------------------------------------------------------------
  
  function SpriteScale(s: Sprite): Single;
  begin
    result := s^.values[SCALE_IDX];
  end;
  
  procedure SpriteSetScale(s: Sprite; value: Single);
  begin
    s^.values[SCALE_IDX] := value;
  end;
  
  //---------------------------------------------------------------------------
  // Sprite center point
  //---------------------------------------------------------------------------
  
  function CenterPoint(s: Sprite): Point2D;
  begin
    {$IFDEF TRACE}
      TraceEnter('sgSprites', 'CenterPoint(s: Sprite): Point2D', '');
    {$ENDIF}
    
    result.x := s^.position.x + SpriteWidth(s) / 2;
    result.y := s^.position.y + SpriteHeight(s) / 2;
    
    {$IFDEF TRACE}
      TraceExit('sgSprites', 'CenterPoint(s: Sprite): Point2D', '');
    {$ENDIF}
  end;
  
  //---------------------------------------------------------------------------
  // Sprite collision details
  //---------------------------------------------------------------------------
  
  function SpriteCollisionKind(s: Sprite): CollisionTestKind;
  begin
    if not assigned(s) then result := AABBCollisions
    else result := s^.collisionKind;
  end;
  
  procedure SpriteSetCollisionKind(s: Sprite; value: CollisionTestKind);
  begin
    if assigned(s) then s^.collisionKind := value;
  end;
  
  function SpriteCollisionBitmap(s: Sprite): Bitmap;
  begin
    if not assigned(s) then result := nil
    else result := s^.collisionBitmap;
  end;
    
  procedure SpriteSetCollisionBitmap(s: Sprite; bmp: Bitmap);
  begin
    if assigned(s) then s^.collisionBitmap := bmp;
  end;
  
  //---------------------------------------------------------------------------
  // Sprite value code
  //---------------------------------------------------------------------------
  
  function SpriteValueCount(s: Sprite) : LongInt;
  begin
    result := -1;
    if not Assigned(s) then exit;
    
    result := NameCount(s^.valueIds);
  end;
  
  function SpriteValueNames(s: Sprite) : StringArray; 
  begin
    SetLength(result, 0);
    if not Assigned(s) then exit;
    
    result := NamesOf(s^.valueIds);
  end;
  
  function SpriteValue(s: Sprite; index: LongInt): Single; overload;
  begin
    result := 0;
    if not Assigned(s) then exit;
    
    result := s^.values[index];
  end;
  
  function SpriteValue(s: Sprite; name: String): Single; overload;
  begin
    result := 0;
    if not Assigned(s) then exit;
    
    result := SpriteValue(s, IndexOf(s^.valueIds, name));
  end;
  
  procedure SpriteAddValue(s: Sprite; name: String);
  begin
    SpriteAddValue(s, name, 0);
  end;
  
  procedure SpriteAddValue(s: Sprite; name: String; initVal: Single);
  var
    idx: LongInt;
  begin
    if not assigned(s) then exit;
    if HasName(s^.valueIds, name) then exit;
    
    idx := AddName(s^.valueIds, name);
    SetLength(s^.values, Length(s^.values) + 1);
    s^.values[idx] := initVal;
  end;
  
  procedure SpriteSetValue(s: Sprite; name: String; val: Single); overload;
  begin
    if not Assigned(s) then exit;
    
    SpriteSetValue(s, IndexOf(s^.valueIds, name), val);
  end;
  
  procedure SpriteSetValue(s: Sprite; idx: LongInt; val: Single); overload;
  begin
    if not assigned(s) then exit;
    if (idx < 0) or (idx > High(s^.values)) then exit;
    
    s^.values[idx] := val;
  end;
  

//=============================================================================

  initialization
  begin
    InitialiseSwinGame();
  end;
end.