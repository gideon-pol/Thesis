#pragma once
#include "types.h"

class ROM {
public:
	ROM(){}
	ROM(Bit32* prog){
		program = prog;
	}

	Instruction GetInstruction(ap_int<16> addr){
		return Instruction(program[addr]);
	}

	Bit32 Get(ap_int<16> addr){
		return program[addr];
	}
private:
	Bit32* program;
	//Bit32 data[8] = { 0x20002, 0x0, 0x100002, 0x1, 0x400002, 0x2, 0x0, 0x0 };
};
