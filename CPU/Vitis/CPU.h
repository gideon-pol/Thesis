#pragma once
#include "ROM.h"
#include "RAM.h"
#include "ALU.h"
#include "types.h"

#include <iostream>
#include <stdint.h>
#include "hls_print.h"

class CPU {
public:
	CPU(ROM program){
		rom = program;
	};

	void Start(){
		static Bit32 registers[4];
		#pragma HLS ARRAY_PARTITION variable=registers complete dim=0
		std::cout << std::hex;

		while(!stopped){
		#pragma HLS pipeline II=4
			Instruction IR = Instruction(rom.Get(PC));
			Bit32 LITR = rom.Get(PC+1);

			std::cout << "op code: " << IR.OpCode << std::endl;
			if(IR.OpCode == OP_STOP){
				stopped = true;
				std::cout << "<<------- CPU halted ------->>" << std::endl;
			}

			Bit32 RA = registers[IR.Register1];
			Bit32 RB = registers[IR.Register2];
			Bit32 inputY = IR.UsesLiteral ? LITR : RB;

			Bit32 computedValue;
			if(IR.ReadsMemory()){
				computedValue = ram.Get(inputY.range(15, 0));
			} else {
				computedValue = alu.Calculate(IR, RA, inputY);
			}

			if(IR.WritesToRegister()){
				registers[IR.Register1] = computedValue;
			}

			if(IR.WritesToMemory()){
				ram.Set(RA.range(15, 0), inputY);
			}

			if(IR.IsJumpInstr() && alu.CmpFlagRaised(IR)){
				PC = inputY.range(15, 0);
			} else {
				PC += IR.UsesLiteral ? 2 : 1;
			}
		}
	}
private:
	ROM rom;
	RAM ram;
	ALU alu;

	Address PC = 0;

	bool stopped = false;
};
