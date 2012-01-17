unit asConstants;

interface
  const
    MAX_SPEED = 50; //this game's speed of light! :D (except bullets can still go faster... :S)
    MAX_ROTATION = 24;
    BUFFER = 50;

    SHAKE_FACTOR = 6; //+- 1 around this value will be used
    COLLISION_MODIFIER = 40;

    STATE_START_DENSITY = 2000; //pixels per radii
    STATE_END_DENSITY = 1000; //player should have to destroy 1000 asteroids before density maxes out
    STATE_PLAYERMOVEDIST = 200; //pixels from player until score and lives will be moved
    STATE_FADE_TIME = 30;
    
    MENU_ITEM_PADDING = 30;
    MENU_ITEM_HEIGHT = 22;
    MENU_ITEM_SELECT_OFFSET = 20;
    
    NOTE_LIFE = 60;
    
    PLAYER_LIFE_INTERVAL = 50000;
    PLAYER_MASS = 500;
    PLAYER_THRUST_AMPLITUDE = 8;
    PLAYER_ACCELERATION = 0.1;
    PLAYER_INDICATOR_BUFFER = 24;
    PLAYER_INDICATOR_SIZE = 9; //distance of points from centre of indicator
    PLAYER_RESPAWN_HIGH = 250;
    PLAYER_RESPAWN_SHOW = 190;
    PLAYER_RESPAWN_FLASH = 10;
    PLAYER_SHIELD_HIGH = 200;
    PLAYER_SHIELD_FLASH = 20;
    PLAYER_BULLET_INTERVAL = 10;

    ENEMY_LIFE_INTERVAL_BASE = 10;
    ENEMY_LIFE_INTERVAL_VAR = 2; //modifier for variance for the next enemy's spawn
    ENEMY_MASS = 750;
    ENEMY_RADIUS_OUT = 12;
    ENEMY_RADIUS_IN = 6;
    ENEMY_COLLISION_MODIFIER = 100;
    ENEMY_ASTEROIDDANGERDIST = 75;
    ENEMY_PLAYERDANGERDIST = 25;
    ENEMY_PLAYERSHOOTDIST = 150;
    ENEMY_ACCELERATION = 0.2;
    ENEMY_MAXSPEED = 4.5;
    ENEMY_SHIELD_HIGH = 200;
    ENEMY_SHIELD_FLASH = 20;
    ENEMY_BULLET_INTERVAL = 50;
    
    ASTEROID_MAXPOINTS = 10;
    ASTEROID_MINPOINTS = 6;
    ASTEROID_DENSITY = 10;
    ASTEROID_MAXSIZE = 50;
    ASTEROID_MINSIZE = 10;
    ASTEROID_MAXROTATION = 5;
    ASTEROID_MINDISTFROMPLAYER = 75;
    ASTEROID_MAXCREATION = 5; //how many times to try and create an asteroid per frame
    
    BULLET_SPEED = 6;
    BULLET_RADIUS = 2;
    BULLET_START = 40;
    BULLET_END = -10;

    SPARK_AVG_SPEED = 3;
    SPARK_POINT_MODIFIER = 2;
    SPARK_ACCELERATION = 0.98;
    SPARK_START = 40;

    DEBRIS_START = 75;
    DEBRIS_SPEED_MODIFIER = 3;
    DEBRIS_MAXROTATION = 15;

implementation
    
end.