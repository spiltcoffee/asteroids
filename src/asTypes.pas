unit asTypes;

interface
  uses sgTypes;

  type
    FadeKind = (
      NoFade,
      FadeIn,
      FadeOut
    );

    MenuCommand = (
      NoCommand,
      Start,
      Resume,
      GotoMain,
      LoadMain,
      SaveOptions,
      LoadOptions,
      LoadScores,
      GameOver,
      LoadGameOver,
      LoadSubmitScore,
      EnterName,
      SaveScore,
      Fullscreen,
      Resolution,
      SFXVolume,
      MVolume,
      Quit
    );

    MenuItemKind = (
      Nothing,
      Select,
      Option,
      Input
    );

    TCollision = record
      i: Integer;
      j: Integer;
    end;
    TCollisionArray = array of TCollision;

    TState = record
      playing: Boolean;
      paused: Boolean;
      fullscreen: Boolean;
      res: Size;
      sfxvolume: Integer;
      musicvolume: Integer;
      quit: Boolean;
      transition: FadeKind;
      time: Integer;
      perform: MenuCommand;
      score: Integer;
      readingtext: Boolean;
      name: String;
      submitscore: Boolean;
      lives: Integer;
      next: Integer; //points for next life
      enemylives: Integer;
      enemynext: Integer; //points for next enemy
      pos: Point2D; //for drawing things
      ignoreCollision: TCollisionArray;
    end;

    TMenuItem = record
      text: String;
      command: MenuCommand;
      kind: MenuItemKind;
      pos: Point2D;
    end;
    TMenuItemArray = array of TMenuItem;

    TMenu = record
      title: String;
      subtitle: String;
      item: TMenuItemArray;
      selected: Integer;
      visible: Boolean;
      disabled: Boolean;
      pos: Point2D;
    end;

    THighScore = record
      name: String;
      score: Integer;
    end;
    THighScoreArray = array of THighScore;

    Rotation = record
      speed: Double;
      angle: Double;
    end;

    ShipKind = (
      SK_SHIP_PLAYER,
      SK_SHIP_AI,
      SK_UFO_AI
    );

    TSteerState = (
      ssSeek,
      ssCorrect,
      ssStop,
      ssAlign
    );

const
C_SteerStateStrings: array[TSteerState] of string = (
      'align',
      'seek',
      'correct',
      'stop'
      );
type

    TController = record
      steer_state: TSteerState;
    end;

    TShip = record
      kind: ShipKind;
      point: Point2DArray;
      rot: Double;
      pos: Point2D; //position
      vel: Vector; //velocity
      rad: Double; //radius
      last: Integer;
      alive: Boolean;
      shields: Integer;
      respawn: Integer;
      int: Integer; //interval (for bullet)
      thrust: Boolean;
      controller: TController;
    end;

    TAsteroid = record
      point: Point2DArray;
      rot: Rotation;
      pos: Point2D; //position
      vel: Vector; //velocity
      rad: Double; //radius
      maxsize: Integer;
      last: Integer; //last asteroid collided with
    end;
    TAsteroidArray = array of TAsteroid;

    TBullet = record
      pos: Point2D;
      vel: Vector;
      life: Integer;
      kind: ShipKind;
    end;
    TBulletArray = array of TBullet;

    DebrisKind = (
      Line,
      Spark,
      Circle
    );
    TDebris = record
      kind: DebrisKind;
      point: Point2DArray;
      pos: Point2D;
      rot: Rotation;
      vel: Vector;
      life: Integer;
      col: Color;
    end;
    TDebrisArray = array of TDebris;

    TNote = record
      text: String;
      pos: Point2D;
      vel: Vector;
      life: Integer;
      col: Color;
    end;
    TNoteArray = array of TNote;

    CollisionObject = record
      pos: Point2D;
      vel: Vector;
      rotspeed: Double;
      mass: Double;
      damage: Integer;
    end;

implementation

end.
