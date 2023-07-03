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

			std::cout << "IR: " << IR.Data << std::endl;
			std::cout << "LITR: " << LITR << std::endl;

			Bit32 RA = registers[IR.Register1];
			Bit32 RB = registers[IR.Register2];
			std::cout << "RA: " << RA << " RB: " << RB << std::endl;
			Bit32 inputY = IR.UsesLiteral ? LITR : RB;

			Bit32 computedValue;
			if(IR.ReadsMemory()){
				computedValue = ram.Get(inputY.range(15, 0));
				std::cout << "RAM: " << " read value " << computedValue << " from " << inputY.range(15, 0) << std::endl;
			} else {
				computedValue = alu.Calculate(IR, RA, inputY);
				std::cout << "ALU: " << computedValue << std::endl;
			}

			if(IR.WritesToRegister()){
				std::cout << "REGISTER: Writing " << computedValue << " to register " << IR.Register1 << std::endl;
				registers[IR.Register1] = computedValue;
			}

			if(IR.WritesToMemory()){
				std::cout << "RAM: Writing " << inputY << " to address " << RA.range(15, 0) << std::endl;
				ram.Set(RA.range(15, 0), inputY);
			}

			if(IR.IsJumpInstr() && alu.CmpFlagRaised(IR)){
				std::cout << "Jumping to address " << inputY.range(15, 0) << std::endl;
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
