unit asShipController;

interface
  uses sgTypes, asTypes;

  procedure MovePlayer(var player: TShip; const state: TState; var rotation: Double; var thrust: Boolean);

  procedure ShipAI(var ship: TShip; var rotation: Double; var thrust: Boolean);
  procedure AIMove(var ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean);

  procedure AIAlign(const ship: TShip; const target: Point2D; var rotation: Double);
  procedure AISeek(const ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean);
  procedure AIStop(const ship: TShip; var rotation: Double; var thrust: Boolean);
  //checks if the ship would need to start turning and stopping right now in order to successfully stop on something or avoid something
  function AIDistToStop(const ship: TShip): Double;

  function CalcAccuracy(const ship_rot: Double; const source_pos, target_pos: Vector): Double; overload;
  function CalcAccuracy(const ship_vector: Vector; const source_pos, target_pos: Vector): Double; overload;

implementation
  uses sgCore, sgGeometry, sgInput, asAudio, asConstants, asDraw, sgGraphics, asEffects, asNotes, asOffscreen,
  sysutils, asPath;

  procedure MovePlayer(var player: TShip; const state: TState; var rotation: Double; var thrust: Boolean);
  begin
    rotation := 0;
    if KeyDown(VK_LEFT) and not KeyDown(VK_RIGHT) then
      rotation := -1
    else if KeyDown(VK_RIGHT) and not KeyDown(VK_LEFT) then
      rotation := 1;

    thrust := False;
    if KeyDown(VK_UP) then
      thrust := True;
  end;

  procedure ShipAI(var ship: TShip; var rotation: Double; var thrust: Boolean);
  var
    target: Point2D;
    cur_state: TShipState;
    distance: Double;
    dist_to_stop: Double;
    speed: Double;
  begin
    target := CurrentPoint(ship.path);
    distance := PointPointDistance(ship.pos, target);
    dist_to_stop := AIDistToStop(ship);
    speed := VectorMagnitude(ship.vel);

    cur_state := ship.controller.state;

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
        AIMove(ship, target, rotation, thrust)
      end;
      ssArrive: begin
        AIStop(ship, rotation, thrust);
      end;
    end;
  end;

  procedure AIMove(var ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean);
  var
    speed: Double;
    facing_accuracy, vel_accuracy: Double;
    cur_state: TMoveState;
  begin
    //magnitude of velocity gives speed
    speed := VectorMagnitude(ship.vel);

    //calculate "accuracy" of ship
    vel_accuracy := CalcAccuracy(ship.vel, ship.pos, target);
    facing_accuracy := CalcAccuracy(ship.rot, ship.pos, target);

    //state machine time!
    cur_state := ship.controller.move_state;

    //then statemachine it
    //transitions
    case cur_state of
      smAlign: begin
        if facing_accuracy > 0.8 then
          cur_state := smSeek
        else if speed > 1 then
          cur_state := smStop;
      end;
      smSeek: begin
        if (vel_accuracy < 0.8) then
          cur_state := smStop;
      end;

      smStop: begin
        if speed < 1 then
          cur_state := smAlign;
      end;
    end;

    //actions
    case cur_state of
      smAlign: begin
        AIAlign(ship, target, rotation);
      end;
      smSeek: begin
        AISeek(ship, target, rotation, thrust);
      end;
      smStop: begin
        AIStop(ship, rotation, thrust);
      end;
    end;

    ship.controller.move_state := cur_state;
  end;

  procedure AIAlign(const ship: TShip; const target: Point2D; var rotation: Double);
  var
    target_angle: Double;
  begin
    target_angle := CalculateAngleWithWrap(ship.pos, target);

    if target_angle - ship.rot > 180 then
      target_angle -= 360
    else if ship.rot - target_angle > 180 then
      target_angle += 360;

    rotation := 1;
    if abs(target_angle - ship.rot) < PLAYER_ROTATION_SPEED then
      rotation := abs(target_angle - ship.rot) / PLAYER_ROTATION_SPEED;

    if target_angle < ship.rot then
      rotation *= -1;
  end;

  procedure AISeek(const ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean);
  begin
    //first, rotate
    AIAlign(ship, target, rotation);
    //then thrust
    if VectorMagnitude(ship.vel) < 5 then
      thrust := True;
  end;

  procedure AIStop(const ship: TShip; var rotation: Double; var thrust: Boolean);
  var
    accuracy: Double;
  begin
    AIAlign(ship, ship.pos - ship.vel, rotation);

    accuracy := CalcAccuracy(ship.rot, ship.pos, ship.pos - ship.vel);

    if (accuracy > 0.8) then
      thrust := True;
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

  function CalcAccuracy(const ship_rot: Double; const source_pos, target_pos: Vector): Double; overload;
  begin
    result := CalcAccuracy(VectorFromAngle(ship_rot, 1.0), source_pos, target_pos);
  end;

  function CalcAccuracy(const ship_vector: Vector; const source_pos, target_pos: Vector): Double; overload;
  begin
    result := DotProduct(UnitVector(ship_vector), VectorFromAngle(CalculateAngleWithWrap(source_pos, target_pos), 1.0));
  end;

end.
