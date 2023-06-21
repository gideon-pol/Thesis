#include "CPU.h"

void synthesis(bool*);

int main(){
	bool finished = false;
	synthesis(&finished);
}

void synthesis(bool* halted){
	*halted = false;

	Bit32 instructions[] = {
			0x00020002,
			0x00000000,
			0x00021002,
			0x00000001,
			0x00023002,
			0x0000000a,
			0x00030002,
			0x00000000,
			0x00121002,
			0x00000002,
			0x00040000,
			0x00100002,
			0x00000001,
			0x00113002,
			0x00000001,
			0x00030000,
			0x00180002,
			0x0000000a,
			0x00440002,
			0x00000008,
			0x00ff0000,
			0x00000000
	};
//#pragma HLS ARRAY_PARTITION variable=instructions complete dim=0

	ROM program = ROM((Bit32*)&instructions);
	CPU cpu = CPU(program);
	cpu.Start();
	*halted = true;
}
