unit asShipController;

interface
  uses sgTypes, asTypes;

  procedure ShipPlayer(var player: TShip; const state: TState; var rotation: Double; var thrust: Boolean; var shooting: Boolean);

  procedure ShipAI(var ship: TShip; var rotation: Double; var thrust: Boolean; var shooting: Boolean);

  procedure AIArrive(var ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean; const wrap: Boolean = True);
  procedure AIMove(var ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean; const wrap: Boolean = True);

  procedure AIAlign(const ship: TShip; const target: Point2D; var rotation: Double; const wrap: Boolean);
  procedure AISeek(const ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean; const wrap: Boolean);
  procedure AIStop(const ship: TShip; var rotation: Double; var thrust: Boolean);
  procedure AIEvade(const ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean);
  //checks if the ship would need to start turning and stopping right now in order to successfully stop on something or avoid something
  function AIDistToStop(const ship: TShip): Double;

  function AICalcAccuracy(const ship_rot: Double; const source_pos, target_pos: Vector): Double; overload;
  function AICalcAccuracy(const ship_vector: Vector; const source_pos, target_pos: Vector): Double; overload;

implementation
  uses sgCore, sgGeometry, sgInput, asAudio, asConstants, asDraw, sgGraphics, asEffects, asNotes, asOffscreen,
  sysutils, asPath;

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

  procedure ShipAI(var ship: TShip; var rotation: Double; var thrust: Boolean; var shooting: Boolean);
  var
    target: Point2D;
  begin
    target := CurrentPoint(ship.path);

    AIArrive(ship, target, rotation, thrust, false);

    shooting := False;
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
    vel_accuracy := AICalcAccuracy(ship.vel, ship.pos, target);
    facing_accuracy := AICalcAccuracy(ship.rot, ship.pos, target);

    //state machine time!
    cur_state := ship.controller.move_state;

    //then statemachine it
    //transitions
    case cur_state of
      smAlign: begin
        if facing_accuracy > AI_ACCURACY_MIN then
          cur_state := smSeek
        else if speed > AI_STOP_TARGET_SPEED then
          cur_state := smStop;
      end;
      smSeek: begin
        if (vel_accuracy < AI_ACCURACY_MIN) then
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
    //first, rotate
    AIAlign(ship, target, rotation, wrap);
    //then thrust
    if VectorMagnitude(ship.vel) < AI_SEEK_TARGET_SPEED then begin
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

    accuracy := AICalcAccuracy(ship.rot, ship.pos, ship.pos + stop_vector);

    if (accuracy > AI_ACCURACY_MIN) then begin
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

    accuracy := AICalcAccuracy(ship.rot, ship.pos + evade_vector, evade_vector);

    if (accuracy > AI_ACCURACY_MIN) and (VectorMagnitude(ship.vel) < AI_EVADE_TARGET_SPEED) then begin
      thrust := True;
    end;
  end;

  function AIDistToStop(const ship: TShip): Double;
  var
    vel_vector: Vector;
    facing_vector: Vector;
    angle: Double;
    speed: Double;
    time_to_turn: Double;
    time_to_stop: Double;
  begin
    vel_vector := UnitVector(ship.vel) * -1;
    facing_vector := UnitVector(VectorFromAngle(ship.rot, 1.0));

    angle := CalculateAngle(facing_vector, vel_vector);
    time_to_turn := abs(angle) / PLAYER_ROTATION_SPEED;

    speed := VectorMagnitude(ship.vel);
    time_to_stop := speed / PLAYER_ACCELERATION;

    result := (time_to_turn + time_to_stop) * speed;
  end;

  function AICalcAccuracy(const ship_rot: Double; const source_pos, target_pos: Vector): Double; overload;
  begin
    result := AICalcAccuracy(VectorFromAngle(ship_rot, 1.0), source_pos, target_pos);
  end;

  function AICalcAccuracy(const ship_vector: Vector; const source_pos, target_pos: Vector): Double; overload;
  begin
    result := DotProduct(UnitVector(ship_vector), VectorFromAngle(CalculateAngleWithWrap(source_pos, target_pos), 1.0));
  end;

end.
