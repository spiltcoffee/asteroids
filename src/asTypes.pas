{
    SwinGame Asteroids
    Copyright (C) 2013  SpiltCoffee

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <https://www.gnu.org/licenses/>.
}

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

    TMap = array of array of Integer;

    TPath = record
      points: array of Point2D;
      current: Integer;
      looped: Boolean;
    end;

    TPathFindEnum = (pfNone, pfUp, pfRight, pfDown, pfLeft);

const
    C_PathFindPoint: array[TPathFindEnum] of Point2D = ((x: 0; y: 0), (x: 0; y: -1), (x: 1; y: 0), (x: 0; y: 1), (x: -1; y: 0)); //use to find neighbour
    C_PathFindOpposite: array[TPathFindEnum] of TPathFindEnum = (pfNone, pfDown, pfLeft, pfUp, pfRight);

type
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
      map: TMap;
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
      debug: Boolean;
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

    TShipKind = (
      sk1ShipPlayer,
      sk1ShipAI,
      sk2ShipUFO,
      sk2ShipAI
    );

    TMoveState = (
      smAlign,
      smSeek,
      smStop
    );

    TArriveState = (
      ssMove,
      ssArrive
    );

const
    C_MoveStateStrings: array[TMoveState] of string = (
      'align',
      'seek',
      'stop'
    );

    C_ArriveStateStrings: array[TArriveState] of string = (
      'move',
      'arrive'
    );

type

    TShipAction = (
      saMoveToEnemy,
      saEvadeEnemy,
      saEvadeAsteroid,
      saShootEnemy,
      saShootAsteroid,
      saIdle
    );

const
    C_ShipActionStrings: array[TShipAction] of String = (
      'Move To Enemy',
      'Evade Enemy',
      'Evade Asteroid',
      'Shoot Enemy',
      'Shoot Asteroid',
      'Idle'
    );

type
    TController = record
      move_state: TMoveState;
      arrive_state: TArriveState;
      pathfind_timeout: Integer;
      gob_timeout: Integer;
      target: Point2D;
      action: TShipAction;
    end;

    TShip = record
      kind: TShipKind;
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
      path: TPath;
      shooting: Boolean;
      color: Integer;
      kills: Integer;
      deaths: Integer;
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
      kind: TShipKind;
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

    TActionUtilFunc = function (const ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; var target: Point2D): Integer;
    TActionProc = procedure (var ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; const target: Point2D; var rotation: Double; var thrust: Boolean; var shooting: Boolean);

implementation

end.
