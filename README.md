# Ada on Arduino Due:

Some examples running Ada on Arduino Due HW

### Other code used in these examples:

- https://github.com/godunko/a0b-atsam3x8e
- https://github.com/godunko/a0b-examples
- https://github.com/godunko/a0b-gpio
- https://github.com/BrentSeidel/Ada-Arduino-Due
- https://github.com/BrentSeidel/BBS-BBB-Ada/
- https://github.com/BrentSeidel/BBS-Ada

## Alire:

- Add Alire to path in Powershell: $env:Path += ";C:\Program Files\Alire\bin"
- alr init --bin hello_pico
- alr init --bin uart_example2

### Convert elf to binary:

- alr exec -- arm-eabi-objcopy -O binary .\bin\hello_arduino .\bin\hello_arduino.bin

### Bossac:

- Press "Erase" and "Reset" next on the board.
- bossac -p COM3 -U false -e -w -v -b hello_arduino.bin -R
