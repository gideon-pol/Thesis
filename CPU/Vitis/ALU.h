#pragma once
#include "types.h"
#include <bitset>

class ALU {
public:
	Bit32 Calculate(Instruction instr, Bit32 input1, Bit32 input2){
		switch(instr.OpCode){
			case OP_CMP:
				compareInt(input1, input2);
				break;
		}

		switch(instr.OpCode.range(7, 4)){
			case 0b0001:
				return calculateInt(instr.OpCode, input1, input2);
			case 0b0010:
				break;
			case 0b0011:
				break;
			default:
				return input2;
		}

		return input2;
	}

	bool CmpFlagRaised(Instruction instr){
		switch(instr.OpCode){
			case OP_JE:
				return equalFlag;
			case OP_JNE:
				return !equalFlag;
			case OP_JG:
				return greaterThanFlag;
			case OP_JS:
				return smallerThanFlag;
		}

		return true;
	}
private:
	void compareInt(Bit32 input1, Bit32 input2){
		smallerThanFlag = input1 < input2;
		equalFlag = input1 == input2;
		greaterThanFlag = input1 > input2;
	}

	Bit32 calculateInt(Bit8 opCode, Bit32 input1, Bit32 input2){
		switch(opCode.range(3, 0)){
			case 0b0000:
				return input1 + input2;
			case 0b0001:
				return input1 - input2;
			case 0b0010:
				return input1 * input2;
			case 0b0100:
				return -input1;
		}

		return 0;
	}

	bool equalFlag = false;
	bool smallerThanFlag = false;
	bool greaterThanFlag = false;
};

