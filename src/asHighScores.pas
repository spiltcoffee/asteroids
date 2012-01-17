unit asHighScores;

// Asteroids! Unit - High Scores
// A specific sub unit for the Menu Unit

interface
  uses asTypes;

  function LoadHighScores(): THighScoreArray;

  procedure SaveHighScores(highScores: THighScoreArray);

  function AmmendHighScores(name: String; score: Integer; test: Boolean = false): Boolean;

  function NewHighScore(score: Integer): Boolean;

implementation
  uses Sysutils;

  function LoadHighScores(): THighScoreArray;
  var
    scoresFile: Text;
    value: String;
    i, valueNum: Integer;
    curChar: Char;
  begin
    SetLength(result,10);
    for i := 0 to High(result) do
    begin
      result[i].name := '-';
      result[i].score := 0;
    end;

    if FileExists(GetAppConfigDir(false) + '/scores.txt') then
    begin
      Assign(scoresFile,GetAppConfigDir(false) + '/scores.txt');
      Reset(scoresFile);
      i := 0;
      while not EOF(scoresFile) and (i < 5) do
      begin
        value := '';
        Read(scoresFile,curChar);
        while (curChar <> ' ') and (curChar <> #10) do
        begin
          value += curChar;
          Read(scoresFile,curChar);
        end;
        if not EOLN(scoresFile) then
        begin
          result[i].name := value;
          ReadLn(scoresFile,value);
          if TryStrToInt(value,valueNum) and (valueNum > 0) then
            result[i].score := valueNum
          else
          begin
            result[i].name := '-';
            result[i].score := 0;
          end;
        end;
        if result[i].name <> '-' then
          i += 1;
      end;
      Close(scoresFile);
    end;
  end;

  procedure SaveHighScores(highScores: THighScoreArray);
  var
    scoresFile: Text;
    i: Integer;
  begin
    if DirectoryExists(GetAppConfigDir(false)) or (not DirectoryExists(GetAppConfigDir(false)) and CreateDir(GetAppConfigDir(false))) then
    begin
      Assign(scoresFile,GetAppConfigDir(false) + '/scores.txt');
      Rewrite(scoresFile);

      for i := 0 to High(highScores) do if highScores[i].name <> '-' then
        WriteLn(scoresFile, highScores[i].name,' ',highScores[i].score);

      Close(scoresFile);
    end;
  end;

  function AmmendHighScores(name: String; score: Integer; test: Boolean = false): Boolean;
  var
    highScores: THighScoreArray;
    inserted: Boolean;
    i, j: Integer;
  begin
    highScores := LoadHighScores();
    inserted := false;
    for i := 0 to High(highScores) do if score > highScores[i].score then
    begin
      for j := High(highScores) - 1 downto i do
        highScores[j + 1] := highScores[j];
      highScores[i].name := name;
      highScores[i].score := score;
      inserted := true;
      break;
    end;

    result := inserted;

    if inserted and not test then
      SaveHighScores(highScores);
  end;

  function NewHighScore(score: Integer): Boolean;
  begin
    result := AmmendHighScores('-', score, true);
  end;

end.