//=============================================================================
// sgTimers.pas
//=============================================================================
//
// The Timer unit contains the code used to control time based activity for
// games using SwinGame.
//
// Change History:
//
// Version 3:
// - 2009-11-09: Andrew : Started Timers unit
//
//=============================================================================


/// SwinGame Timers can be used to manage time based actions in your game. Each
/// timer keeps track of the number of milliseconds that have ellapsed since
/// the timer was started. They can be paused, stopped, restarted, etc.
///
/// @module Timers
/// @static
unit sgTimers;

//=============================================================================
interface
  uses sgTypes, SDL;
//=============================================================================
  
  
  
  //----------------------------------------------------------------------------
  // Timers
  //----------------------------------------------------------------------------
  
  /// Create and return a new Timer. The timer will not be started, and will have
  /// an initial 'ticks' of 0.
  ///
  /// @lib
  ///
  /// @class Timer
  /// @constructor
  /// @sn init
  function CreateTimer(): Timer;
  
  /// Free a created timer.
  ///
  /// @lib
  ///
  /// @class Timer
  /// @dispose
  procedure FreeTimer(var toFree: Timer);
  
  /// Start a timer recording the time that has passed.
  ///
  /// @lib
  /// 
  /// @class Timer
  /// @method Start
  procedure StartTimer(toStart: Timer);
  
  /// Stop the timer. The time is reset to 0 and you must
  /// recall start to begin the timer ticking again.
  /// 
  /// @lib
  /// 
  /// @class Timer
  /// @method Stop
  procedure StopTimer(toStop: Timer);
  
  /// Pause the timer, getting ticks from a paused timer
  /// will continue to return the same time.
  /// 
  /// @lib
  /// 
  /// @class Timer
  /// @method Pause
  procedure PauseTimer(toPause: Timer);
  
  /// Resumes a paused timer.
  ///
  /// @lib
  ///
  /// @class Timer
  /// @method Resume
  procedure ResumeTimer(toUnpause: Timer);
  
  /// Resets the time of a given timer
  ///
  /// @lib
  ///
  /// @class Timer
  /// @method Reset
  procedure ResetTimer(tmr: Timer);
  
  /// Gets the number of ticks (milliseconds) that have passed since the timer
  /// was started/reset. When paused the timer's ticks will not advance until
  /// the timer is once again resumed.
  ///
  /// @lib
  ///
  /// @class Timer
  /// @getter Ticks
  function TimerTicks(toGet: Timer): UInt32;
  
  
  
//=============================================================================
implementation
  uses sgTrace, sgShared;
//=============================================================================

function CreateTimer(): Timer;
begin
  {$IFDEF TRACE}
    TraceEnter('sgTimers', 'CreateTimer');
  {$ENDIF}
  New(result);
  with result^ do
  begin
    startTicks := 0;
    pausedTicks := 0;
    paused := false;
    started := false;
  end;
  {$IFDEF TRACE}
    TraceExit('sgTimers', 'CreateTimer');
  {$ENDIF}
end;

procedure ResetTimer(tmr: Timer);
begin
  {$IFDEF TRACE}
    TraceEnter('sgTimers', 'ResetTimer');
  {$ENDIF}
  tmr^.startTicks := SDL_GetTicks();
  {$IFDEF TRACE}
    TraceEnter('sgTimers', 'ResetTimer');
  {$ENDIF}
end;

procedure FreeTimer(var toFree: Timer);
begin
  {$IFDEF TRACE}
    TraceEnter('sgTimers', 'FreeTimer');
  {$ENDIF}
  
  if Assigned(toFree) then
  begin
    Dispose(toFree);
    CallFreeNotifier(toFree);
  end;
  
  toFree := nil;
  
  {$IFDEF TRACE}
    TraceExit('sgTimers', 'FreeTimer');
  {$ENDIF}
end;

procedure StartTimer(toStart: Timer);
begin
  {$IFDEF TRACE}
    TraceEnter('sgTimers', 'StartTimer');
  {$ENDIF}
  if not Assigned(toStart) then begin RaiseException('No timer supplied'); exit; end;
  
  with toStart^ do
  begin
    started := true;
    paused := false;
    startTicks := SDL_GetTicks();
  end;
  {$IFDEF TRACE}
    TraceExit('sgTimers', 'StartTimer');
  {$ENDIF}
end;

procedure StopTimer(toStop: Timer);
begin
  {$IFDEF TRACE}
    TraceEnter('sgTimers', 'StopTimer');
  {$ENDIF}
  if not Assigned(toStop) then begin RaiseException('No timer supplied'); exit; end;
  with toStop^ do
  begin
    started := false;
    paused := false;
  end;
  {$IFDEF TRACE}
    TraceExit('sgTimers', 'StopTimer');
  {$ENDIF}
end;

procedure PauseTimer(toPause: Timer);
begin
  {$IFDEF TRACE}
    TraceEnter('sgTimers', 'PauseTimer');
  {$ENDIF}
  if not Assigned(toPause) then begin RaiseException('No timer supplied'); exit; end;
  with toPause^ do
  begin
    if started and (not paused) then
    begin
      paused := true;
      pausedTicks := SDL_GetTicks() - startTicks;
    end;
  end;
  {$IFDEF TRACE}
    TraceExit('sgTimers', 'PauseTimer');
  {$ENDIF}
end;

procedure ResumeTimer(toUnpause: Timer);
begin
  {$IFDEF TRACE}
    TraceEnter('sgTimers', 'ResumeTimer');
  {$ENDIF}
  if not Assigned(toUnpause) then begin RaiseException('No timer supplied'); exit; end;
  with toUnpause^ do
  begin
    if paused then
    begin
      paused := false;
      startTicks := SDL_GetTicks() - pausedTicks;
      pausedTicks := 0;
    end;
  end;
  {$IFDEF TRACE}
    TraceExit('sgTimers', 'ResumeTimer');
  {$ENDIF}
end;

function TimerTicks(toGet: Timer): UInt32;
begin
  {$IFDEF TRACE}
    TraceEnter('sgTimers', 'TimerTicks');
  {$ENDIF}
  
  if not Assigned(toGet) then begin RaiseException('No timer supplied'); exit; end;
  
  with toGet^ do
  begin
    if started then
    begin
      if paused then result := pausedTicks
      else result := SDL_GetTicks() - startTicks;
      exit;
    end;
  end;
  result := 0;
  {$IFDEF TRACE}
    TraceExit('sgTimers', 'TimerTicks');
  {$ENDIF}
end;


end.
