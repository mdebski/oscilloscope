# Oscilloscope
Simple oscilloscope/logic-analyzer on FPGA with VGA display. Designed for basys2 evaluation board with spartan-3E-100k processor.
Supports probing up to 40Mhz (smooth regulation < ~5Mhz), toggled by slope on selected inputs.

## Action shots
https://github.com/mdebski/oscilloscope/blob/master/photos/screenshot.png
https://github.com/mdebski/oscilloscope/blob/master/photos/board.png

## Inputs
* btn0 -> reset
* btn1, btn2 -> change prescaler (freq / or * 10)
* btn3 -> toggle mode
* pmod JA(0 to 3), JB(0 to 3) -> data inputs
* sw(0 to 7) -> toggle enabled on n-th input
* JC(0 to 3) -> input from impulsers (regulate frequency and line position)




