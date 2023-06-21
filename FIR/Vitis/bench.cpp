#include "fir.h"

//using namespace hls;

int main(){
//	hls_thread_local hls::stream<int16> s_taps;
	hls_thread_local hls::stream<int16> s_in;
	hls_thread_local hls::stream<int16> s_out;

	hls_thread_local hls::task t1(fir_task, s_in, s_out);

	int16 input[] = {1,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3};
	for(int i = 0; i < 30; i++){
		s_in.write(input[i]);

		int16 output = s_out.read();

		std::cout << "Calculated output: " << output << std::endl;
	}
}
