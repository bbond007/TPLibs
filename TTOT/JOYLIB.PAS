unit JoyLib;

Interface

{ Define constants for use as JoystickButton and JoystickPosition parameters }
const JoystickAButton1 = $10;
      JoystickAButton2 = $20;
      JoystickBButton1 = $40;
      JoystickBButton2 = $80;
      JoystickAAxisX   = $01;
      JoystickAAxisY   = $02;
      JoystickBAxisX   = $04;
      JoystickBAxisY   = $08;

function JoystickButton(buttonnum : byte) : boolean;
function JoystickPosition(axisnum : byte) : word;

Implementation

const JOYSTICKPORT = $201;

{ Button returns true is button is pressed }
function JoystickButton(buttonnum : byte) : boolean;
begin
  JoystickButton := (Port[JOYSTICKPORT] and buttonnum) = 0;
end;

{ Returns position value of joystick. The value returned is highly
  dependent on machine speed. Changing the setting of the computer's
  Turbo speed button will affect the value returned.
  Returns $FFFF if the joystick is not connected
}
function JoystickPosition(axisnum : byte) : word;
var count : word;
begin
  asm
    mov word ptr count, 0
    cli          { Disable interrupts so they don't interfere with timing }
    mov dx, JOYSTICKPORT   { Write dummy byte to joystick port }
    out dx, al
    @joystickloop:
    inc count              { Add one to count }
    cmp count, $FFFF       { Check for time out }
    je @done
    in al, dx              { Get joystick port value }
    and al, axisnum        { Test the appropriate bit }
    jne @joystickloop
    @done:
    sti                    { Enable interrupts again }
  end;
  JoystickPosition := count;
end;

end.

