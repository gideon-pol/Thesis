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
};
