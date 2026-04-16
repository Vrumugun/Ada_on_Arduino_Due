# Ada LED blink example using timer

Hello from Ada UART on Arduino Due!

## What it does:

- Disable Watchdog
- Configures a periodic timer that will toggle LED PB27

## Build:

- alr build --development
- alr exec -- arm-eabi-objcopy -O binary .\bin\led_timer_main .\bin\led_timer_main.bin
- Press ERASE on the board.
- Press RESET on the board.
- ..\bossac\1.6.1-arduino\bossac -p COM3 -U false -e -w -v -b bin\led_timer_main.bin -R

(change COM3 to whatever COM port your board is connected to)

## Test

LED PB27 should flash with 0.5 Hz frequency.
