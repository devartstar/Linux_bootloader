## Task

*Basic Line Editor with Backspace support*

Extend our line reader to support backspace (0x08):
- Remove the last character from buffer
- Erase it from the screen
- Prevent underflow when buffer is empty

This is exactly how early UNIX shells, bootloaders, and microkernels used to
implement their command lines!
