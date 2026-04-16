# Ada UART Echo for Arduino Due #2

## What it does:

- Enables PMC clocks for UART and PIOA.
- Configures PA8/PA9 to peripheral A for UART RX/TX.
- Configures UART0 as 9600 8N1 (no parity).
- Receives a character over UART and sends it back.

## Build:

- alr build --development
- alr exec -- arm-eabi-objcopy -O binary .\bin\time_triggered_system_1 .\bin\time_triggered_system_1.bin
- Press ERASE on the board.
- Press RESET on the board.
- ..\bossac\1.6.1-arduino\bossac -p COM3 -U false -e -w -v -b bin\time_triggered_system_1.bin -R

## Test

Open a serial terminal on COM3 at 9600 baud, 8N1.
You should see the message printed repeatedly.
