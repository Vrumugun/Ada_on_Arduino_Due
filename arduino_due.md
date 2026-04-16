
# Alire

https://github.com/godunko/a0b-atsam3x8e
https://github.com/godunko/a0b-examples
https://github.com/godunko/a0b-gpio

https://github.com/BrentSeidel/Ada-Arduino-Due
https://github.com/BrentSeidel/BBS-BBB-Ada/
https://github.com/BrentSeidel/BBS-Ada

alr init --bin hello_pico
alr init --bin uart_example2

# convert elf to binary

alr exec -- arm-eabi-objcopy -O binary .\bin\hello_arduino .\bin\hello_arduino.bin
alr exec -- arm-eabi-objcopy -O binary .\bin\led_timer_main .\bin\led_timer.bin

# bossac

Press "Erase" and "Reset" next on the board.

bossac -p COM3 -U false -e -w -v -b hello_arduino.bin -R
bossac -p COM3 -U false -e -w -v -b led_timer.bin -R
bossac -p COM3 -U false -e -w -v -b uart_example.bin -R


## 1. Build
$env:Path += ";C:\Program Files\Alire\bin"
cd C:\GitHub\Ada_Testing\Arduino_Due\hello_arduino
alr build --development

## 2. Convert ELF -> BIN (absolute path to objcopy)
& "C:\Users\simon\AppData\Local\alire\cache\toolchains\gnat_arm_elf_15.2.1_a927173b\bin\arm-eabi-objcopy.exe" `
  -O binary .\bin\hello_arduino .\bin\hello_arduino.bin

## 3. Put board into bootloader (1200 baud touch on Programming port)
$p = New-Object System.IO.Ports.SerialPort COM3,1200,None,8,one
$p.Open(); $p.Close()

## 4. Flash immediately
cd C:\GitHub\Ada_Testing\Arduino_Due\bossac\1.6.1-arduino
.\bossac -p COM3 -U false -e -w -v -b "C:\GitHub\Ada_Testing\Arduino_Due\hello_arduino\bin\hello_arduino.bin" -R
