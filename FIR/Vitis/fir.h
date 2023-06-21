#ifndef FIR_H
#define FIR_H

#include "hls_task.h"
#include "hls_stream.h"
//#include "hls_thread.h"
#include "ap_int.h"

using namespace hls;

//typedef ap_int<16> int16;

//const int TAP_COUNT = 2;
//typedef ap_int<16> int16;
//template<int c>
//void fir(hls::stream<int16>& taps, hls::stream<int16>& input, hls::stream<int16>& output){
////	static int16 taps[TAP_COUNT] = {1,2};
//
//	static int16 a_result[c];
//	static int16 m_result[c];
//
//	int16 in = input.read();
//
//	for(int i = 0; i < c; i++){
//		#pragma HLS UNROLL
//		m_result[i] = in * taps.read(); //[i];
//		a_result[i] = m_result[i] + a_result[i+1]; //(i == c-1 ? (int16)0 : a_result[i+1]);
//	}
//
//	m_result[i] = in * taps.read();
//	a_result[i] = m_result[i];
//
//	output.write(a_result[0]);
//}


#define TAP_COUNT 32
typedef ap_int<16> int16;
//template<int c>

template<class T, int c>
T fir(T taps[c], T sample){
	static T shift_reg[c];

	for(int i = 0; i < c-1; i++){
		#pragma HLS UNROLL

		shift_reg[i] = sample * taps[i] + shift_reg[i+1];
	}

	return shift_reg[0];
}

void fir_task(hls::stream<int16>& input, hls::stream<int16>& output){
	static int16 taps[TAP_COUNT] = {
				1, 1, 1, 1, 1, 1,
				1, 1, 1, 1, 1, 1,
				1, 1, 1, 1, 1, 1,
				1, 1, 1, 1, 1, 1,
				1, 1, 1, 1, 1, 1,
				1, 1};
	int16 in = input.read();

	output.write(fir<int16, TAP_COUNT>(taps, in));
}

void task(hls::stream<int16>& input, hls::stream<int16>& output){
	static int16 taps[TAP_COUNT] = {
			1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1,
			1, 1, 1, 1, 1, 1,
			1, 1};

//	static int16 a_result[TAP_COUNT];
//	static int16 m_result[TAP_COUNT];
	static int16 shift_reg[TAP_COUNT];

	int16 in = input.read();

	for(int i = 0; i < TAP_COUNT-1; i++){
		#pragma HLS UNROLL

		shift_reg[i] = in * taps[i] + shift_reg[i+1];
//		a_result[i] = m_result[i] + (i == TAP_COUNT-1 ? (int16)0 : a_result[i+1]);
//		m_result[i] = in * taps[i];
	}

	output.write(shift_reg[0]);
}
#endif
