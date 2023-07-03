#pragma once
#include "ap_int.h"

#define OP_STOP 	-1
#define OP_MOV		0b00000010
#define OP_STORE	0b00000011
#define OP_LOAD		0b00000100
#define OP_CMP 		0b00011000
#define OP_JE  		0b01000001
#define OP_JNE 		0b01000010
#define OP_JG  		0b01000011
#define OP_JS  		0b01000100

typedef ap_int<1> Bit;
typedef ap_int<8> Bit8;
typedef ap_int<16> Address;
typedef ap_int<32> Bit32;

class Instruction {
public:
	Instruction();
	Instruction(Bit32 data);
	Bit8 OpCode;
	Bit8 Register1;
	Bit8 Register2;
	bool UsesLiteral;

	Bit32 Data;

	bool IsJumpInstr();

	bool WritesToRegister();

	bool ReadsMemory();

	bool WritesToMemory();
};
