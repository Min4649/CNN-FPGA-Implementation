#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/mman.h>
#include <sys/time.h>
#include <math.h>
//#include "address_map_arm_brl4.h"
#include "mnist_in.dat"

#define FIXED_POINT_FRACTIONAL 9
// main bus; PIO
#define FPGA_AXI_BASE 	0xC4000000
#define FPGA_AXI_SPAN   0x00001000
// main axi bus base
void *h2p_virtual_base;

//write_enables
#define MNIST_WE  0xF0
#define MNIST_WADDR 0xD0
#define MNIST_WDATA 0xE0
#define MNIST_LOAD_DONE 0x100
volatile unsigned int * mnist_wdata_ptr = NULL;
volatile unsigned int * mnist_we_ptr = NULL;
volatile unsigned int * mnist_waddr_ptr = NULL;
volatile unsigned int * mnist_load_done = NULL;



volatile unsigned int * result_0_ptr = NULL ;
volatile unsigned int * result_1_ptr = NULL ;
volatile unsigned int * result_2_ptr = NULL ;
volatile unsigned int * result_3_ptr = NULL ;
volatile unsigned int * result_4_ptr = NULL ;
volatile unsigned int * result_5_ptr = NULL ;
volatile unsigned int * result_6_ptr = NULL ;
volatile unsigned int * result_7_ptr = NULL ;
volatile unsigned int * result_8_ptr = NULL ;
volatile unsigned int * result_9_ptr = NULL ;
volatile unsigned int * done_ptr = NULL ;
#define FPGA_PIO_0 0x00
#define FPGA_PIO_1 0x10
#define FPGA_PIO_2 0x20
#define FPGA_PIO_3 0x30
#define FPGA_PIO_4 0x40
#define FPGA_PIO_5 0x50
#define FPGA_PIO_6 0x60
#define FPGA_PIO_7 0x70
#define FPGA_PIO_8 0x80
#define FPGA_PIO_9 0x90
#define FPGA_DONE 0xA0
int fd;

double result[10]={0};

double fixed_to_double(fixed_val) {
  double double_val;
  if(fixed_val > 67108864) //if the sign bit is 1
    double_val = ((double)(fixed_val - 134217728))/512; // 26843546 = 2^2 - 1
  else
    double_val = ((double)(fixed_val))/512;
  return double_val;
};

int i;
int main(void)
{

	// Declare volatile pointers to I/O registers (volatile
	// means that IO load and store instructions will be used
	// to access these pointer locations,

	// === get FPGA addresses ==================
    // Open /dev/mem
	if( ( fd = open( "/dev/mem", ( O_RDWR | O_SYNC ) ) ) == -1 ) 	{
		printf( "ERROR: could not open \"/dev/mem\"...\n" );
		return( 1 );
	}

	// ===========================================
	// get virtual address for
	// AXI bus addr
	h2p_virtual_base = mmap( NULL, FPGA_AXI_SPAN, ( PROT_READ | PROT_WRITE ), MAP_SHARED, fd, FPGA_AXI_BASE);
	if( h2p_virtual_base == MAP_FAILED ) {
		printf( "ERROR: mmap3() failed...\n" );
		close( fd );
		return(1);
	}
 
  mnist_load_done = (unsigned int *)(h2p_virtual_base + MNIST_LOAD_DONE);
  mnist_we_ptr = (unsigned int *)(h2p_virtual_base + MNIST_WE);
  mnist_waddr_ptr  = (unsigned int *)(h2p_virtual_base + MNIST_WADDR);
  mnist_wdata_ptr = (unsigned int *)(h2p_virtual_base + MNIST_WDATA);
  *(mnist_load_done) = 0;
  *(mnist_we_ptr) = 0;
  *(mnist_waddr_ptr) = 0;
  *(mnist_wdata_ptr) = 0;
  
  
  for(i=0;i<784; i++) {
      *(mnist_we_ptr) = 0;
      *(mnist_waddr_ptr) = i;
      *(mnist_wdata_ptr) = mnist_in[i];
      *(mnist_we_ptr) = 1;
  }
  *(mnist_load_done) = 1;


    // Get the addresses that map to the two parallel ports on the AXI bus
  result_0_ptr  = (unsigned int *)(h2p_virtual_base + FPGA_PIO_0);
  result_1_ptr  = (unsigned int *)(h2p_virtual_base + FPGA_PIO_1);
  result_2_ptr  = (unsigned int *)(h2p_virtual_base + FPGA_PIO_2);
  result_3_ptr  = (unsigned int *)(h2p_virtual_base + FPGA_PIO_3);
  result_4_ptr  = (unsigned int *)(h2p_virtual_base + FPGA_PIO_4);
  result_5_ptr  = (unsigned int *)(h2p_virtual_base + FPGA_PIO_5);
  result_6_ptr  = (unsigned int *)(h2p_virtual_base + FPGA_PIO_6);
  result_7_ptr  = (unsigned int *)(h2p_virtual_base + FPGA_PIO_7);
  result_8_ptr  = (unsigned int *)(h2p_virtual_base + FPGA_PIO_8);
  result_9_ptr  = (unsigned int *)(h2p_virtual_base + FPGA_PIO_9);
  done_ptr = (unsigned int *)(h2p_virtual_base + FPGA_DONE);


        printf("done = %u \n" , *(done_ptr));
        printf("result0 = %u \n", *(result_0_ptr));
        printf("result1 = %u \n", *(result_1_ptr));
        printf("result2 = %u \n", *(result_2_ptr));
        printf("result3 = %u \n", *(result_3_ptr));
        printf("result4 = %u \n", *(result_4_ptr));
        printf("result5 = %u \n", *(result_5_ptr));
        printf("result6 = %u \n", *(result_6_ptr));
        printf("result7 = %u \n", *(result_7_ptr));
        printf("result8 = %u \n", *(result_8_ptr));
        printf("result9 = %u\n\n", *(result_9_ptr));
        result[0]=fixed_to_double(*(result_0_ptr));
        result[1]=fixed_to_double(*(result_1_ptr));
        result[2]=fixed_to_double(*(result_2_ptr));
        result[3]=fixed_to_double(*(result_3_ptr));
        result[4]=fixed_to_double(*(result_4_ptr));
        result[5]=fixed_to_double(*(result_5_ptr));
        result[6]=fixed_to_double(*(result_6_ptr));
        result[7]=fixed_to_double(*(result_7_ptr));
        result[8]=fixed_to_double(*(result_8_ptr));
        result[9]=fixed_to_double(*(result_9_ptr));
        for(i = 0; i<10; i++){
          printf("result %d = %f \n", i, result[i]);
        }
        printf("\n");
 //end of while



}
