#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include "CPU.h"

void synthesis(bool* halted){
	*halted = false;

	Bit32 instructions[] = {
			0x20002,
			0x0,
			0x100002,
			0x1,
			0x400002,
			0x2,
			0x0,
			0x0,
			0xff,
			0x00
		};

	ROM program = ROM((Bit32*)&instructions);
	CPU cpu = CPU(program);
	cpu.Start();
	*halted = true;
}
