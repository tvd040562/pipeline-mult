comp:
	iverilog -g2005-sv src/ba_pipelined.v verify/pipelined_mult_tb.v
run:
	./a.out 
view:
	gtkwave tb_pipelined_mult.vcd
