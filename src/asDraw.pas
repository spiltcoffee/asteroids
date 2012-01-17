unit asDraw;

interface
  uses sgTypes, asTypes;
  procedure LoadFonts();
  
  function PointerTriangle(): Point2DArray;

  function PlayerShip(firstOnly: Boolean = false): Point2DArray;

  function CopyRotateTranslate(arrayOfPoints: Point2DArray; pos: Point2D; rot: Double): Point2DArray;

  procedure DrawShape(const point: Point2DArray; const pos: Point2D; const rot: Double; const shapeColor: Color; const complete: Boolean = true); overload;
  procedure DrawShape(const point: Point2DArray; const X, Y: Double; const rot: Double; const shapeColor: Color; const complete: Boolean = true); overload;

  procedure DrawPointer(const player: TShip; shipColor: Color);

implementation
  uses sgGeometry, sgGraphics, sgText, asOffscreen;

  procedure LoadFonts();
  begin
    MapFont('smallFont', 'chintzy.ttf', 12);
    MapFont('mediumFont', 'chintzy.ttf', 14);
    MapFont('menuFont', 'chintzy.ttf', 24);
    MapFont('subtitleFont', 'chintzy.ttf', 48);
    MapFont('titleFont', 'chintzy.ttf', 72);
  end;

  //Point2DArray lists - they don't change, but they do get copied a lot. Any need to keep them in TShip? :D

  function PointerTriangle(): Point2DArray;
  begin
    SetLength(result,3);
    result[0].x := 9;
    result[0].y := 0;
    result[1].x := -5;
    result[1].y := -8;
    result[2].x := -5;
    result[2].y := 8;
  end;

  function PlayerShip(firstOnly: Boolean = false): Point2DArray;
  begin
    if firstOnly then
    begin
      SetLength(result,1);
      result[0].x := 12;
      result[0].y := 0;
    end
    else
    begin
      SetLength(result,4);
      result[0].x := 12;
      result[0].y := 0;
      result[1].x := -6.2;
      result[1].y := -6.5;
      result[2].x := -4;
      result[2].y := 0;
      result[3].x := -6.2;
      result[3].y := 6.5;
    end;
  end;

  //misc functions for drawing common things

  function CopyRotateTranslate(arrayOfPoints: Point2DArray; pos: Point2D; rot: Double): Point2DArray;
  var
    i: Integer;
    translation, rotation: Matrix2D;
  begin
    result := Copy(arrayOfPoints,0,Length(arrayOfPoints)); //so we don't modify the original array of points
    
    translation := TranslationMatrix(pos);
    rotation := RotationMatrix(rot);
    
    for i := 0 to High(result) do
    begin
      result[i] := MatrixMultiply(translation,MatrixMultiply(rotation,result[i])); //rotate, then translate
    end;

  end;


  procedure DrawShape(const point: Point2DArray; const pos: Point2D; const rot: Double; const shapeColor: Color; const complete: Boolean = true); overload;
  var
    i: Integer;
    drawingPoints: Point2DArray;
  begin
    drawingPoints := CopyRotateTranslate(point,pos,rot);

    for i := 0 to High(drawingPoints) do
    begin
      if i < High(drawingPoints) then
        DrawLine(shapeColor,drawingPoints[i],drawingPoints[i + 1])
      else if complete then
        DrawLine(shapeColor,drawingPoints[i],drawingPoints[0]);
    end;
  end;

  procedure DrawShape(const point: Point2DArray; const X, Y: Double; const rot: Double; const shapeColor: Color; const complete: Boolean = true); overload;
  var
    pos: Point2D;
  begin
    pos.x := X;
    pos.y := Y;
    DrawShape(point,pos,rot,shapeColor,complete);
  end;

  procedure DrawPointer(const player: TShip; shipColor: Color);
  var
    side: Integer;
    pos: Point2D;
  begin
    pos := OffscreenSide(player.pos,side);
    DrawShape(PointerTriangle(),pos,45 * side,shipColor);
  end;

end.