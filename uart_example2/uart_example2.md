# Ada UART Example for Arduino Due #2

Hello from Ada UART on Arduino Due!

## What it does:

- Enables PMC clocks for UART and PIOA.
- Configures PA8/PA9 to peripheral A for UART RX/TX.
- Configures UART0 as 115200 8N1 (no parity).
- Repeatedly transmits the test message with CRLF.

## Build:

- alr build --development
- alr exec -- arm-eabi-objcopy -O binary .\bin\uart_example2 .\bin\uart_example2.bin
- Press ERASE on the board.
- Press RESET on the board.
- ..\bossac\1.6.1-arduino\bossac -p COM3 -U false -e -w -v -b bin\uart_example2.bin -R

## Test

Open a serial terminal on COM3 at 9600 baud, 8N1.
You should see the message printed repeatedly.
