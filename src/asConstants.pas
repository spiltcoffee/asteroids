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

unit asConstants;

interface
  const
    MAX_SPEED = 50; //this game's speed of light! :D (except bullets can still go faster... :S)
    MAX_ROTATION = 24;
    BUFFER = 50;
    FRAMES_PER_SECOND = 30;

    SHAKE_FACTOR = 6; //+- 1 around this value will be used
    COLLISION_MODIFIER = 40;

    STATE_PLAYERMOVEDIST = 200; //pixels from player until score and lives will be moved
    STATE_FADE_TIME = 30;
    STATE_ASTEROID_SCORE_INTERVAL = 750;

    MENU_ITEM_PADDING = 30;
    MENU_ITEM_HEIGHT = 22;
    MENU_ITEM_SELECT_OFFSET = 20;

    NOTE_LIFE = 60;

    PLAYER_LIFE_INTERVAL = 50000;
    PLAYER_MASS = 500;
    PLAYER_THRUST_AMPLITUDE = 8;
    PLAYER_ACCELERATION = 0.25;
    PLAYER_INDICATOR_BUFFER = 24;
    PLAYER_INDICATOR_SIZE = 9; //distance of points from centre of indicator
    PLAYER_RESPAWN_HIGH = 250;
    PLAYER_RESPAWN_SHOW = 100;
    PLAYER_RESPAWN_FLASH = 10;
    PLAYER_ROTATION_SPEED = 6;
    PLAYER_SHIELD_HIGH = 200;
    PLAYER_SHIELD_FLASH = 20;
    PLAYER_BULLET_INTERVAL = 60;

    AI_DANGER_CLOSE = 15;

    AI_STOP_TARGET_SPEED = 1;
    AI_STOP_MIN_SPEED = 0.2;
    AI_STOP_ACCURACY_MIN = 0.8;
    AI_SEEK_TARGET_SPEED = 5;
    AI_SEEK_ACCURACY_MIN = 0.8;
    AI_EVADE_TARGET_SPEED = 4;
    AI_EVADE_ASTEROID_DIST = 150;
    AI_EVADE_ACCURACY_MIN = 0.5;
    AI_EVADE_BUFFER = 120;
    AI_EVADE_ENEMY_BUFFER = -150;
    AI_EVADE_TIME_MIN = 120;
    AI_EVADE_DIST_MIN = 200;
    AI_EVADE_STEP = 0.5;
    AI_SHOOT_STEP = 0.5;
    AI_SHOOT_ACCURACY_FACTOR = 500;
    AI_SHOOT_ACCURACY_MIN = 0.99995;

    AI_PATHFIND_TIMEOUT = 30;
    AI_GOB_TIMEOUT = 10;

    PATH_DIST_NEXT = 50;

    ENEMY_SPAWN_INTERVAL = 20000;
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

    ASTEROID_MINCOUNT = 25; //starting amount of asteroids
    ASTEROID_MAXCOUNT = 200; //maximum amount of asteroids that we can spawn
    ASTEROID_MAXPOINTS = 10;
    ASTEROID_MINPOINTS = 6;
    ASTEROID_DENSITY = 10;
    ASTEROID_MAXSIZE = 50;
    ASTEROID_MINSIZE = 10;
    ASTEROID_MAXROTATION = 5;
    ASTEROID_MINDISTFROMPLAYER = 75;
    ASTEROID_MAXCREATION = 5; //how many times to try and create an asteroid per frame
    ASTEROID_SPEED_MULTIPLIER = 4;
    ASTEROID_MINSCORE = 50;

    BULLET_SPEED = 8;
    BULLET_RADIUS = 2;
    BULLET_START = 40;
    BULLET_END = -10;
    BULLET_DAMAGE = 0.85;

    SPARK_AVG_SPEED = 3;
    SPARK_POINT_MODIFIER = 2;
    SPARK_ACCELERATION = 0.98;
    SPARK_START = 40;

    DEBRIS_START = 75;
    DEBRIS_SPEED_MODIFIER = 3;
    DEBRIS_MAXROTATION = 15;

    MAP_CELL_SIZE = 50;
    MAP_RADIUS_BUFFER = 1;
    MAP_FALL_OFF = 5;
    MAP_FALL_OFF_MAX = 300;
    MAP_IMPASS = 500;

implementation

end.
