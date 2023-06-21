#include "types.h"

Instruction::Instruction(){
	this->Data = 0;
}

Instruction::Instruction(Bit32 data){
	this->Data = data;
//	this->OpCode = data.range(23, 16);
//	this->Register1 = data.range(15, 12);
//	this->Register2 = data.range(11, 8);
//	this->UsesLiteral = data[1] == 1;

//	std::cout << "INSTRUCTION: OP: " << this->OpCode << " R1: " << this->Register1 << " R2: " << this->Register2 << " LIT: " << this->UsesLiteral << std::endl;
}

Bit8 Instruction::GetOpCode(){
	return Data.range(23, 16);
}

Bit8 Instruction::GetRegister1(){
	return Data.range(15, 12);
}

Bit8 Instruction::GetRegister2(){
	return Data.range(11, 8);
}

bool Instruction::UsesLiteral(){
	return Data[1] == 1;
}
//
//Bit32 Instruction::AsLiteral(){
//	return data;
//}

bool Instruction::IsJumpInstr(){
	return GetOpCode().range(7, 3) == 0b01000;
}

bool Instruction::WritesToRegister(){
	Bit32 OpCode = GetOpCode();
	return (
			OpCode == 0b00000010 ||
			OpCode == 0b00000100 ||
			OpCode.range(7, 3) == 0b00010
	);
}

bool Instruction::ReadsMemory(){
	return (GetOpCode() == 0b00000100);
}

bool Instruction::WritesToMemory(){
	return (GetOpCode() == 0b00000011);
}
