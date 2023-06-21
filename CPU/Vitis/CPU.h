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
//		#pragma HLS ARRAY_PARTITION variable=registers complete dim=0
		std::cout << std::hex;
		int d = 0;

		while(!stopped){
		#pragma HLS pipeline II=4
			IR = Instruction(rom.Get(PC));
			LITR = rom.Get(PC+1);

			std::cout << "op code: " << IR.GetOpCode() << std::endl;
			if(IR.GetOpCode() == OP_STOP){
				stopped = true;
				std::cout << "<<------- CPU halted ------->>" << std::endl;
			}

			std::cout << "IR: " << IR.Data << std::endl;
			std::cout << "LITR: " << LITR << std::endl;

			RA = registers[IR.GetRegister1()];
			RB = registers[IR.GetRegister2()];
			std::cout << "RA: " << RA << " RB: " << RB << std::endl;
			inputY = IR.UsesLiteral() ? LITR : RB;


			if(IR.ReadsMemory()){
				computedValue = ram.Get(inputY.range(15, 0));
				std::cout << "RAM: " << " read value " << computedValue << " from " << inputY.range(15, 0) << std::endl;
			} else {
				computedValue = alu.Calculate(IR, RA, inputY);
				std::cout << "ALU: " << computedValue << std::endl;
			}


			if(IR.WritesToRegister()){
				std::cout << "REGISTER: Writing " << computedValue << " to register " << IR.GetRegister1() << std::endl;
				registers[IR.GetRegister1()] = computedValue;
			}

			if(IR.WritesToMemory()){
				std::cout << "RAM: Writing " << inputY << " to address " << RA.range(15, 0) << std::endl;
				ram.Set(RA.range(15, 0), inputY);
			}

			if(IR.IsJumpInstr() && alu.CmpFlagRaised(IR)){
				std::cout << "Jumping to address " << inputY.range(15, 0) << std::endl;
				PC = inputY.range(15, 0);
			} else {
				PC += IR.UsesLiteral() ? 2 : 1;
			}
			d++;
		}
	}
private:
	enum Stage {Fetch, Decode, Execute, Store};
	Stage stage = Stage::Fetch;
	ROM rom;
	RAM ram;
	ALU alu;

	Instruction IR;
	Bit32 LITR;
	Address PC = 0;

	Bit32 RA;
	Bit32 RB;

	Bit32 inputY;

	Bit32 computedValue;


	bool stopped = false;
};
