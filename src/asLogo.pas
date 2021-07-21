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

unit asLogo;

interface
  procedure ShowMyLogo();

implementation
  uses sgAudio, sgCore, sgImages, sgInput, sgGraphics, sgResources, sgTypes;
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
    PlaySoundEffect(SoundEffectNamed('eh'));

    i := 1;
    while isPaused or (i < 90) do
    begin
      i += 1;
      InnerProcessEvents();
      RefreshScreen(60);
      if isSkip then break;
    end;

    ClearScreen();

    i := 1;
    while isPaused or (i < 45) do
    begin
      i += 1;
      InnerProcessEvents();
      DrawBitmap(BitmapNamed('MyLogo'), XCenter - 128, YCenter - 128);
      DrawRectangle(ColorBlack + ($01000000 * Trunc(i / 45 * 255)),true,0,0,ScreenWidth(),ScreenHeight());
      RefreshScreen(60);
      if isSkip then break;
    end;
  end;
end.
