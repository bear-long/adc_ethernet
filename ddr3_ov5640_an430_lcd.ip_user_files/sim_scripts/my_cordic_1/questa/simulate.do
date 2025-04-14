onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib my_cordic_1_opt

do {wave.do}

view wave
view structure
view signals

do {my_cordic_1.udo}

run -all

quit -force
