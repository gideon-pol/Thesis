#include "types.h"

Instruction::Instruction(){
	this->Data = 0;
}

Instruction::Instruction(Bit32 data){
	this->Data = data;
	this->OpCode = data.range(23, 16);
	this->Register1 = data.range(15, 12);
	this->Register2 = data.range(11, 8);
	this->UsesLiteral = data[1] == 1;
}

bool Instruction::IsJumpInstr(){
	// checks if instruction is a type of jump instruction
	return OpCode.range(7, 3) == 0b01000;
}

bool Instruction::WritesToRegister(){
	return (
			OpCode == OP_MOV ||
			OpCode == OP_LOAD ||
			// checks if instruction is an arithmetic instruction
			OpCode.range(7, 3) == 0b00010
	);
}

bool Instruction::ReadsMemory(){
	return (OpCode == OP_LOAD);
}

bool Instruction::WritesToMemory(){
	return (OpCode == OP_STORE);
}
