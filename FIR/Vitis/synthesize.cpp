//#include "fir.h"
//
#include "hls_task.h"
#include "hls_stream.h"
//#include "hls_thread.h"
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



void fir_syn(hls::stream<int16>& input, hls::stream<int16>& output){
	static int16 taps[TAP_COUNT] = {
			1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1,
			1, 1
			// = {1,5,3,4};
	};

	static int16 a_result[TAP_COUNT];
	static int16 m_result[TAP_COUNT];

	int16 in = input.read();

	for(int i = 0; i < TAP_COUNT; i++){
		#pragma HLS UNROLL

		a_result[i] = m_result[i] + (i == TAP_COUNT-1 ? (int16)0 : a_result[i+1]);
		m_result[i] = in * taps[i];
	}

	output.write(a_result[0]);
}
//
//void syn5(int16* in, int16* out){
//	while(true){
//
//	}
//}
//
//void syn(int16* in, int16* out){
//
//#pragma HLS DATAFLOW
//	hls_thread_local hls::stream<int16> s_in;
//	hls_thread_local hls::stream<int16> s_out;
//
//	hls_thread_local hls::task t1(fir, s_in, s_out);
//
////	s_in.write(*in);
//
//	int16 input[] = {1,5,3,4,5,6,7,8,9,10,11,15,13,14,15,16,17,18,19,50};
//	for(int i = 0; i < 50; i++){
//		s_in.write(input[i]);
//
//		int16 output = s_out.read();
//		*out = output;
//	}
//}
