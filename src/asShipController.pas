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

unit asShipController;

interface
  uses sgTypes, asTypes;

  procedure ShipPlayer(var player: TShip; const state: TState; var rotation: Double; var thrust: Boolean; var shooting: Boolean);

  procedure ShipAI(var ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; var rotation: Double; var thrust: Boolean; var shooting: Boolean);

  procedure AIArrive(var ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean; const wrap: Boolean = True);
  procedure AIMove(var ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean; const wrap: Boolean = True);

  procedure AIAlign(const ship: TShip; const target: Point2D; var rotation: Double; const wrap: Boolean);
  procedure AISeek(const ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean; const wrap: Boolean);
  procedure AIStop(const ship: TShip; var rotation: Double; var thrust: Boolean);
  procedure AIEvade(const ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean);
  procedure AIShoot(const ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean; var shooting: Boolean);

  function AITimeToTurn(const ship: TShip): Double;
  //calculates how much time would be taken before being able to stop
  function AITimeToStop(const ship: TShip): Double;
  //calculates how much distance would be covered before being able to stop
  function AIDistToStop(const ship: TShip): Double;

  //calculates a value between 1.0 and -1.0 that represents how accuracte the ship is in respect to a target
  function AICalcAccuracy(const ship_rot: Double; const source_pos, target_pos: Point2D; const wrap: Boolean): Double; overload;
  function AICalcAccuracy(const ship_vector: Vector; const source_pos, target_pos: Point2D; const wrap: Boolean): Double; overload;

  function AISpeedInFacing(const rot: Double; const vel: Vector): Double;

implementation
  uses sgCore, sgGeometry, sgInput, asAudio, asConstants, asDraw, sgGraphics, asEffects, asNotes, asOffscreen,
       sysutils, asPath, asShipUtilities;

  procedure ShipPlayer(var player: TShip; const state: TState; var rotation: Double; var thrust: Boolean; var shooting: Boolean);
  begin
    rotation := 0;
    if KeyDown(VK_LEFT) and not KeyDown(VK_RIGHT) then
      rotation := -1
    else if KeyDown(VK_RIGHT) and not KeyDown(VK_LEFT) then
      rotation := 1;

    thrust := False;
    if KeyDown(VK_UP) then
      thrust := True;

    shooting := False;
    if KeyDown(VK_SPACE) then
      shooting := True;
  end;

  procedure ShipAI(var ship: TShip; const asteroids: TAsteroidArray; const enemy: TShip; const map: TMap; var rotation: Double; var thrust: Boolean; var shooting: Boolean);
  var
    action: TShipAction;
    best_action: TShipAction;
    utility: Integer;
    best_action_utility: Integer;
    ActionUtilFunc: TActionUtilFunc;
    ActionProc: TActionProc;
    target: Point2D;
    best_target: Point2D;
  begin
    rotation := 0;
    thrust := False;
    shooting := False;

    if ship.controller.gob_timeout = 0 then begin
      best_action_utility := -1;
      best_target.x := 0;
      best_target.y := 0;

      Write('Utilities: ');

      for action in [Low(TShipAction)..High(TShipAction)] do begin
        target.x := 0;
        target.y := 0;

        Write(C_ShipActionStrings[action], ', ');

        try
          ActionUtilFunc := GetActionUtil(action);
          utility := ActionUtilFunc(ship, asteroids, enemy, map, target);

          if (best_action_utility = -1) or (utility < best_action_utility) then begin
            best_action := action;
            best_action_utility := utility;
            best_target := target;

          end;

        except
          on E: Exception do begin
            WriteLn('Exception in asShipController.ShipAI when running Utility: ' + E.Message);
            raise;
          end;
        end;

      end;

      WriteLn();
      WriteLn('Action: ', C_ShipActionStrings[best_action]);

      ship.controller.action := best_action;
      ship.controller.target := best_target;
      ship.controller.gob_timeout := AI_GOB_TIMEOUT;
    end
    else begin
      ship.controller.gob_timeout -= 1;
    end;

    try
      ActionProc := GetAction(ship.controller.action);
      ActionProc(ship, asteroids, enemy, map, ship.controller.target, rotation, thrust, shooting);
    except
      on E: Exception do begin
        WriteLn('Exception in asShipController.ShipAI when running Action: ' + E.Message);
        raise;
      end;
    end;
  end;

  procedure AIArrive(var ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean; const wrap: Boolean = True);
  var
    cur_state: TArriveState;
    distance: Double;
    dist_to_stop: Double;
    speed: Double;
  begin
    distance := PointPointDistance(ship.pos, target);
    dist_to_stop := AIDistToStop(ship);
    speed := VectorMagnitude(ship.vel);

    cur_state := ship.controller.arrive_state;

    //transitions!
    case cur_state of
      ssMove: begin
        if (speed > 0) and (dist_to_stop > distance) then begin
          cur_state := ssArrive;
        end;
      end;
      ssArrive: begin
        if dist_to_stop < distance then begin
          cur_state := ssMove;
        end;
      end;
    end;

    //actions!
    case cur_state of
      ssMove: begin
        if cur_state <> ship.controller.arrive_state then begin
          ship.controller.move_state := smAlign;
        end;
        AIMove(ship, target, rotation, thrust)
      end;
      ssArrive: begin
        AIStop(ship, rotation, thrust);
      end;
    end;
  end;

  procedure AIMove(var ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean; const wrap: boolean = True);
  var
    speed: Double;
    facing_accuracy, vel_accuracy: Double;
    cur_state: TMoveState;
  begin
    //magnitude of velocity gives speed
    speed := VectorMagnitude(ship.vel);

    //calculate "accuracy" of ship
    vel_accuracy := AICalcAccuracy(ship.vel, ship.pos, target, wrap);
    facing_accuracy := AICalcAccuracy(ship.rot, ship.pos, target, wrap);

    //state machine time!
    cur_state := ship.controller.move_state;

    //then statemachine it
    //transitions
    case cur_state of
      smAlign: begin
        if facing_accuracy > AI_SEEK_ACCURACY_MIN then
          cur_state := smSeek
        else if speed > AI_STOP_TARGET_SPEED then
          cur_state := smStop;
      end;
      smSeek: begin
        if (vel_accuracy < AI_SEEK_ACCURACY_MIN) then
          cur_state := smStop;
      end;

      smStop: begin
        if speed < AI_STOP_TARGET_SPEED then
          cur_state := smAlign;
      end;
    end;

    //actions
    case cur_state of
      smAlign: begin
        AIAlign(ship, target, rotation, wrap);
      end;
      smSeek: begin
        AISeek(ship, target, rotation, thrust, wrap);
      end;
      smStop: begin
        AIStop(ship, rotation, thrust);
      end;
    end;

    ship.controller.move_state := cur_state;
  end;

  procedure AIAlign(const ship: TShip; const target: Point2D; var rotation: Double; const wrap: Boolean);
  var
    target_angle: Double;
  begin
    if wrap then begin
      target_angle := CalculateAngleWithWrap(ship.pos, target);
    end
    else begin
      target_angle := CalculateAngleBetween(ship.pos, target);
    end;

    if target_angle - ship.rot > 180 then begin
      target_angle -= 360
    end
    else if ship.rot - target_angle > 180 then begin
      target_angle += 360;
    end;

    rotation := 1;
    if abs(target_angle - ship.rot) < PLAYER_ROTATION_SPEED then begin
      rotation := abs(target_angle - ship.rot) / PLAYER_ROTATION_SPEED;
    end;

    if target_angle < ship.rot then begin
      rotation *= -1;
    end;
  end;

  procedure AISeek(const ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean; const wrap: Boolean);
  begin
    AIAlign(ship, target, rotation, wrap);

    if AISpeedInFacing(ship.rot, ship.vel) < AI_SEEK_TARGET_SPEED then begin
      thrust := True;
    end;
  end;

  procedure AIStop(const ship: TShip; var rotation: Double; var thrust: Boolean);
  var
    stop_vector: Point2D;
    accuracy: Double;
  begin
    stop_vector := ship.vel * -1;
    AIAlign(ship, ship.pos + stop_vector, rotation, False);

    accuracy := AICalcAccuracy(ship.rot, ship.pos, ship.pos + stop_vector, False);

    if (accuracy > AI_STOP_ACCURACY_MIN) and (VectorMagnitude(ship.vel) > AI_STOP_MIN_SPEED) then begin
      thrust := True;
    end;
  end;

  procedure AIEvade(const ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean);
  var
    accuracy: Double;
    evade_vector: Vector;
  begin
    evade_vector := VectorFromAngle(CalculateAngleWithWrap(ship.pos, target), 1.0) * -1;

    AIAlign(ship, ship.pos + evade_vector, rotation, False);

    accuracy := AICalcAccuracy(ship.rot, ship.pos, ship.pos + evade_vector, False);

    if (accuracy > AI_EVADE_ACCURACY_MIN) and (AISpeedInFacing(ship.rot, ship.vel) < AI_EVADE_TARGET_SPEED) then begin
      thrust := True;
    end;
  end;

  procedure AIShoot(const ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean; var shooting: Boolean);
  var
    accuracy: Double;
  begin
    AIAlign(ship, target, rotation, False);

    accuracy := AICalcAccuracy(ship.rot, ship.pos, target, False);

    if (accuracy > AI_SHOOT_ACCURACY_MIN) then begin
      shooting := True;
    end;
  end;

  function AITimeToTurn(const ship: TShip): Double;
  var
    vel_vector: Vector;
    facing_vector: Vector;
    angle: Double;
  begin
    vel_vector := UnitVector(ship.vel) * -1;
    facing_vector := UnitVector(VectorFromAngle(ship.rot, 1.0));

    angle := CalculateAngle(facing_vector, vel_vector);
    result := abs(angle) / PLAYER_ROTATION_SPEED;
  end;

  function AITimeToStop(const ship: TShip): Double;
  var
    speed: Double;
  begin
    speed := VectorMagnitude(ship.vel);
    result := speed / PLAYER_ACCELERATION;
  end;

  function AIDistToStop(const ship: TShip): Double;
  var
    speed: Double;
  begin
    speed := VectorMagnitude(ship.vel);
    result := AITimeToTurn(ship) * speed + (0.5 * PLAYER_ACCELERATION * AITimeToStop(ship));
  end;

  function AICalcAccuracy(const ship_rot: Double; const source_pos, target_pos: Point2D; const wrap: Boolean): Double; overload;
  begin
    result := AICalcAccuracy(VectorFromAngle(ship_rot, 1.0), source_pos, target_pos, wrap);
  end;

  function AICalcAccuracy(const ship_vector: Vector; const source_pos, target_pos: Point2D; const wrap: Boolean): Double; overload;
  var
    angle: Double;
    target_vector: Vector;
  begin
    if wrap then begin
      angle := CalculateAngleWithWrap(source_pos, target_pos);
    end
    else begin
      angle := CalculateAngleBetween(source_pos, target_pos);
    end;

    target_vector := VectorFromAngle(angle, 1.0);
    result := DotProduct(UnitVector(ship_vector), target_vector);
  end;

  function AISpeedInFacing(const rot: Double; const vel: Vector): Double;
  var
    facing_vector: Vector;
  begin
    facing_vector := VectorFromAngle(rot, 1.0);
    result := DotProduct(facing_vector, UnitVector(vel)) * VectorMagnitude(vel);
  end;

end.
