#pragma once
#include "ap_int.h"

#define OP_STOP -1

typedef ap_int<1> Bit;
typedef ap_int<8> Bit8;
typedef ap_int<16> Address;
typedef ap_int<32> Bit32;

class Instruction {
public:
	Instruction();
	Instruction(Bit32 data);
//	Bit8 OpCode;
//	Bit8 Register1;
//	Bit8 Register2;
//	bool UsesLiteral;

	Bit32 Data;

	Bit8 GetOpCode();

	Bit8 GetRegister1();

	Bit8 GetRegister2();

	bool UsesLiteral();

	Bit32 AsLiteral();

	bool IsJumpInstr();

	bool WritesToRegister();

	bool ReadsMemory();

	bool WritesToMemory();
};

//class Value {
//public:
//	Value(ap_int<32> data){
//		this->data = data;
//	}
//private:
//	ap_int<32> data;
//};
