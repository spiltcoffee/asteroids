unit asShipController;

interface
  uses sgTypes, asTypes;

  procedure MovePlayer(var player: TShip; const state: TState; var thrust: Boolean; var rotation: Double);

  procedure MoveAI(var ship: TShip; const state: TState; const asteroids: TAsteroidArray; var thrust: Boolean; var rotation: Double);

  procedure AIAlign(const ship: TShip; const target: Point2D; var rotation: Double);
  procedure AISeek(const ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean);
  procedure AICorrect(const ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean);
  procedure AIStop(const ship: TShip; var rotation: Double; var thrust: Boolean);

  function CalcAccuracy(const ship_rot: Double; const source_pos, target_pos: Vector): Double; overload;
  function CalcAccuracy(const ship_vector: Vector; const source_pos, target_pos: Vector): Double; overload;

implementation
  uses sgCore, sgGeometry, sgInput, asAudio, asConstants, asDraw, sgGraphics, asEffects, asNotes, asOffscreen,
  sysutils;

  procedure MovePlayer(var player: TShip; const state: TState; var thrust: Boolean; var rotation: Double);
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

  procedure MoveAI(var ship: TShip; const state: TState; const asteroids: TAsteroidArray; var thrust: Boolean; var rotation: Double);
  var
    speed: Double;
    facing_accuracy, vel_accuracy: Double;
    target: Point2D;
    old_state: TSteerState;
    cur_state: TSteerState;
  begin
    target := asteroids[0].pos;

    //magnitude of velocity gives speed
    speed := VectorMagnitude(ship.vel);

    //calculate "accuracy" of ship
    vel_accuracy := CalcAccuracy(ship.vel, ship.pos, target);
    facing_accuracy := CalcAccuracy(ship.rot, ship.pos, target);

    //state machine time!
    cur_state := ship.controller.steer_state;
    old_state := cur_state;

    //then statemachine it
    //transitions
    case cur_state of
      ssAlign: begin
        if facing_accuracy > 0.8 then
          cur_state := ssSeek
        else if speed < 1 then
          cur_state := ssAlign;
      end;
      ssSeek: begin
        if vel_accuracy < 0.8 then
          cur_state := ssCorrect;
      end;
      ssCorrect: begin
        if vel_accuracy < 0.5 then
          cur_state := ssStop
        else if vel_accuracy > 0.8 then
          cur_state := ssSeek;
      end;
      ssStop: begin
        if speed < 1 then
          cur_state := ssAlign;
      end;
    end;

    if cur_state <> old_state then
      WriteLn('state changed: ' + C_SteerStateStrings[old_state] + ' to ' + C_SteerStateStrings[cur_state]);

    //actions
    case cur_state of
      ssAlign: begin
        AIAlign(ship, target, rotation);
      end;
      ssSeek: begin
        AISeek(ship, target, rotation, thrust);
      end;
      ssCorrect: begin
        AICorrect(ship, target, rotation, thrust);
      end;
      ssStop: begin
        AIStop(ship, rotation, thrust);
      end;
    end;

    ship.controller.steer_state := cur_state;
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

  procedure AICorrect(const ship: TShip; const target: Point2D; var rotation: Double; var thrust: Boolean);
  var
    distance: Double;
    ship_vector, target_vector: Vector;
    target_normal: Vector;
    dot: Double;
    angle: Double;
    accuracy: Double;
  begin
    distance := CalculateDistWithWrap(ship.pos, target);

    ship_vector := UnitVector(ship.vel);
    target_vector := VectorFromAngle(CalculateAngleWithWrap(ship.pos, target), 1.0);
    dot := DotProduct(ship_vector, target_vector);
    angle := CalculateAngle(target_vector, ship_vector);

    target_normal := VectorNormal(target_vector) * dot * distance;
    if angle > 0 then begin
      target_normal *= -1;
    end;

    AIAlign(ship, target + target_normal, rotation);

    accuracy := CalcAccuracy(ship.rot, ship.pos, target);

    if (accuracy > 0.8) and (VectorMagnitude(ship.vel) < 5) then
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

  function CalcAccuracy(const ship_rot: Double; const source_pos, target_pos: Vector): Double; overload;
  begin
    result := CalcAccuracy(VectorFromAngle(ship_rot, 1.0), source_pos, target_pos);
  end;

  function CalcAccuracy(const ship_vector: Vector; const source_pos, target_pos: Vector): Double; overload;
  begin
    result := DotProduct(UnitVector(ship_vector), VectorFromAngle(CalculateAngleWithWrap(source_pos, target_pos), 1.0));
  end;

end.
