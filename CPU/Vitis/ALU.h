#pragma once
#include "types.h"
#include <bitset>

class ALU {
public:
	Bit32 Calculate(Instruction instr, Bit32 input1, Bit32 input2){
//#pragma HLS DATAFLOW
		switch(instr.GetOpCode()){
			case 0b00011000:
				compareInt(input1, input2);
				break;
		}

		switch(instr.GetOpCode().range(7, 4)){
			case 0b0001:
				return calculateInt(instr.GetOpCode(), input1, input2);
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
		switch(instr.GetOpCode()){
			case 0b01000001:
				return equalFlag;
			case 0b01000010:
				return !equalFlag;
			case 0b01000011:
				return greaterThanFlag;
			case 0b01000100:
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
//			case 0b011:
//				return input1 / input2;
			case 0b0100:
				return -input1;
//			case 0b101:
//				return (int)input1 << (int)input2;
//			case 0b110:
//				return (int)input1 >> (int)input2;
		}

		return 0;
	}

	bool equalFlag = false;
	bool smallerThanFlag = false;
	bool greaterThanFlag = false;
};

