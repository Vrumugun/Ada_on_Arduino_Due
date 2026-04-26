# Time triggered system example with Ada on Arduino Due Hardware

Based on examples in the book "The Engineering of Reliable Embedded Systems" by Michael J. Pont.

## What it does:

- Implements scheduler for time triggered system.
- Add tasks for watchdog, heartbeat, debug communication, ...

## Build:

- alr build --development
- alr exec -- arm-eabi-objcopy -O binary .\bin\time_triggered_system_2 .\bin\time_triggered_system_2.bin
- Press ERASE on the board.
- Press RESET on the board.
- ..\bossac\1.6.1-arduino\bossac -p COM8 -U false -e -w -v -b bin\time_triggered_system_2.bin -R

## Test

Open a serial terminal on COM8 at 9600 baud, 8N1.
You should see the heartbeat message printed repeatedly.
