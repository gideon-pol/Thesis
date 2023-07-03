#pragma once
#include "hls_task.h"
#include "hls_stream.h"
#include "ap_int.h"

#define TAP_COUNT 32
typedef ap_int<16> int16;

template<class T, int c>
T fir(T taps[c], T sample){
	static T shift_reg[c];

	for(int i = 0; i < c-1; i++){
		#pragma HLS UNROLL

		shift_reg[i] = sample * taps[i] + shift_reg[i+1];
	}

	return shift_reg[0];
}

void fir_task_syn(hls::stream<int16>& input, hls::stream<int16>& output){
	static int16 taps[TAP_COUNT] = {
				5, 5, 5, 5, 5, 5,
				5, 5, 5, 5, 5, 5,
				5, 5, 5, 5, 5, 5,
				5, 5, 5, 5, 5, 5,
				5, 5, 5, 5, 5, 5,
				5, 5
	};
	int16 in = input.read();

	output.write(fir<int16, TAP_COUNT>(taps, in));
}