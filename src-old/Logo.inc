//
//procedure for displaying my logo before the menu
//

procedure ShowMyLogo();
var
  i: Integer;
  XCenter, YCenter: LongInt;
  //isStep: Boolean;
  isPaused: Boolean;
  isSkip: Boolean;
  
  procedure InnerProcessEvents();
  begin
    ProcessEvents();
    if (KeyDown(vk_LSUPER) or KeyDown(vk_LCTRL)) and KeyTyped(vk_p) then
    begin
      isPaused := not isPaused;
    end;
    if WindowCloseRequested() or KeyDown(vk_Escape) then isSkip := true;
  end;
begin
  
  isPaused := false;
  isSkip := false;

  XCenter := ScreenWidth() div 2;
  YCenter := ScreenHeight() div 2;
  
  LoadResourceBundle('mylogo.txt', False);

  ClearScreen();
  
  i := 1;
  while isPaused or (i < 60) do
  begin
    i += 1;
    InnerProcessEvents();
    RefreshScreen(60);
    if isSkip then break;
  end;

  DrawBitmap(BitmapNamed('MyLogo'), XCenter - 128, YCenter - 128);

  i := 1;
  while isPaused or (i < 120) do
  begin
    i += 1;
    InnerProcessEvents();
    RefreshScreen(60);
    if isSkip then break;
  end;
  
  ClearScreen();
  
  i := 1;
  while isPaused or (i < 60) do
  begin
    i += 1;
    InnerProcessEvents();
    DrawBitmap(BitmapNamed('MyLogo'), XCenter - 128, YCenter - 128);
    DrawRectangle(ColorBlack + ($01000000 * Trunc(i / 60 * 255)),true,0,0,ScreenWidth(),ScreenHeight());
    RefreshScreen(60);
    if isSkip then break;
  end;
end;