#pragma once
#include "types.h"

class RAM {
public:
	void Set(ap_int<16> addr, Bit32 val){
		data[addr] = val;
	}

	Bit32 Get(ap_int<16> addr){
		return data[addr];
	}
private:
	Bit32 data[1024];
};
