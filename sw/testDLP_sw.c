/******************************************************************************
*
* Copyright (C) 2009 - 2014 Xilinx, Inc.  All rights reserved.
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* Use of the Software is limited solely to applications:
* (a) running on a Xilinx device, or
* (b) that interact with a Xilinx device through a bus or interconnect.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
* XILINX  BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF
* OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
* SOFTWARE.
*
* Except as contained in this notice, the name of the Xilinx shall not be used
* in advertising or otherwise to promote the sale, use or other dealings in
* this Software without prior written authorization from Xilinx.
*
******************************************************************************/

/*
 * helloworld.c: simple test application
 *
 * This application configures UART 16550 to baud rate 9600.
 * PS7 UART (Zynq) is not initialized by this application, since
 * bootrom/bsp configures it to baud rate 115200
 *
 * ------------------------------------------------
 * | UART TYPE   BAUD RATE                        |
 * ------------------------------------------------
 *   uartns550   9600
 *   uartlite    Configurable only in HW design
 *   ps7_uart    115200 (configured by bootrom/bsp)
 */

#include <stdio.h>
#include "platform.h"
#include "xil_printf.h"
#include "xparameters.h"
#include "xil_io.h"
#include "xil_cache.h"



int main()
{
    init_platform();

    print("Deconvolution HW Test\n\r");

    u32 statusReg = 0;

    /* Cache disabling */
    Xil_DCacheDisable();

    /* Kernel generic row */
    signed char row[20] = {5,5,5,0,4,4,4,0,3,3,3,0,2,2,2,0,1,1,1,0};

    /* Writing coefficients into DDR */
	for (u32 r = 0; r < 20; r++) {
		for (u32 i = 0; i < 20; i++) {
			Xil_Out16(0x01000000 + 2*(r*20+i),row[i]);
		}
	}

    /* Writing ifmap ch 1 into DDR */
    for (u32 i = 0; i < 2*32; i++) {
    	for (u32 j = 0; j < 2*32; j++) {
    		Xil_Out16(0x01100000 + 2*(i*32+j), 1);
    	}
    }

    /* Writing ifmap ch 2 into DDR */
    for (u32 i = 0; i < 2*32; i++) {
    	for (u32 j = 0; j < 2*32; j++) {
    		Xil_Out16(0x01200000 + 2*(i*32+j), 1);
    	}
    }

    /* Writing ifmap ch 3 into DDR */
    for (u32 i = 0; i < 2*32; i++) {
    	for (u32 j = 0; j < 2*32; j++) {
    		Xil_Out16(0x01300000 + 2*(i*32+j), 1);
    	}
    }

    /* DMA/VDMAs reset */
    Xil_Out32(XPAR_AXI_DMA_0_BASEADDR + 0x0, 0x4);
    Xil_Out32(XPAR_AXI_DMA_0_BASEADDR + 0x0, 0x0);
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + 0x0, 0x4);
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + 0x0, 0x0);
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + 0x30, 0x4);
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR + 0x30, 0x0);
	Xil_Out32(XPAR_AXI_VDMA_1_BASEADDR + 0x0, 0x4);
	Xil_Out32(XPAR_AXI_VDMA_1_BASEADDR + 0x0, 0x0);
	Xil_Out32(XPAR_AXI_VDMA_1_BASEADDR + 0x30, 0x4);
	Xil_Out32(XPAR_AXI_VDMA_1_BASEADDR + 0x30, 0x0);
	Xil_Out32(XPAR_AXI_VDMA_2_BASEADDR + 0x0, 0x4);
	Xil_Out32(XPAR_AXI_VDMA_2_BASEADDR + 0x0, 0x0);
	Xil_Out32(XPAR_AXI_VDMA_2_BASEADDR + 0x30, 0x4);
	Xil_Out32(XPAR_AXI_VDMA_2_BASEADDR + 0x30, 0x0);
	Xil_Out32(XPAR_AXI_VDMA_3_BASEADDR + 0x30, 0x4);
	Xil_Out32(XPAR_AXI_VDMA_3_BASEADDR + 0x30, 0x0);

    /* DLP Configuration */
    Xil_Out32(XPAR_DECONV_LAYER_PROC_V1_0_0_BASEADDR,0x3D);
    Xil_Out32(XPAR_DECONV_LAYER_PROC_V1_0_0_BASEADDR + 0x4,0x22C0FC82);
    Xil_Out32(XPAR_DECONV_LAYER_PROC_V1_0_0_BASEADDR + 0x8,1155);

    /* DMA0: MM2S channel configuration */
    Xil_Out32(XPAR_AXI_DMA_0_BASEADDR + 0x0, 0x1); // start MM2S Channel
    Xil_Out32(XPAR_AXI_DMA_0_BASEADDR + 0x18, 0x01000000); // Coeff SourceAddr

	/* VDMA0: S2MM channel configuration*/
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR+0x30, 0x11011); // VDMA0 running
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR+0xAC, 0x01400000); // VDMA0 frame buffer
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR+0xA8, 2*136); // STRIDE = 2*34*4
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR+0xA4, 136); // HSIZE = 34*4

	/* VDMA2: S2MM channel configuration*/
	Xil_Out32(XPAR_AXI_VDMA_2_BASEADDR+0x30, 0x11011); // VDMA0 running
	Xil_Out32(XPAR_AXI_VDMA_2_BASEADDR+0xAC, 0x01400088); // VDMA0 frame buffer
	Xil_Out32(XPAR_AXI_VDMA_2_BASEADDR+0xA8, 2*136); // STRIDE = 2*34*4
	Xil_Out32(XPAR_AXI_VDMA_2_BASEADDR+0xA4, 136); // HSIZE = 34*4

	/* VDMA1: S2MM channel configuration*/
	Xil_Out32(XPAR_AXI_VDMA_1_BASEADDR+0x30, 0x11011); // VDMA0 running
	Xil_Out32(XPAR_AXI_VDMA_1_BASEADDR+0xAC, 0x01500000); // VDMA0 frame buffer
	Xil_Out32(XPAR_AXI_VDMA_1_BASEADDR+0xA8, 2*136); // STRIDE = 2*34*4
	Xil_Out32(XPAR_AXI_VDMA_1_BASEADDR+0xA4, 136); // HSIZE = 34*4

	/* VDMA3: S2MM channel configuration*/
	Xil_Out32(XPAR_AXI_VDMA_3_BASEADDR+0x30, 0x11011); // VDMA0 running
	Xil_Out32(XPAR_AXI_VDMA_3_BASEADDR+0xAC, 0x01500088); // VDMA0 frame buffer 0
	Xil_Out32(XPAR_AXI_VDMA_3_BASEADDR+0xA8, 2*136); // STRIDE = 2*34*4
	Xil_Out32(XPAR_AXI_VDMA_3_BASEADDR+0xA4, 136); // HSIZE = 34*4

	/* VDMAs S2MM enabled */
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR+0xA0, 34); // VSIZE = 34. Trigger for VDMA
	Xil_Out32(XPAR_AXI_VDMA_2_BASEADDR+0xA0, 34); // VSIZE = 34. Trigger for VDMA
	Xil_Out32(XPAR_AXI_VDMA_1_BASEADDR+0xA0, 34); // VSIZE = 34. Trigger for VDMA
	Xil_Out32(XPAR_AXI_VDMA_3_BASEADDR+0xA0, 34); // VSIZE = 34. Trigger for VDMA

    /* 1st coeff packet */
    Xil_Out32(XPAR_AXI_DMA_0_BASEADDR + 0x28, 400); // ByteToTransfer 2*50*4 = 200 bytes

    /* VDMA0: MM2S channel configuration */
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR+0x0, 0x11011); // VDMA0 running 10081
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR+0x5C, 0x01100000); // VDMA0 frame buffer 0
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR+0x58, 2048); // STRIDE = HSIZE
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR+0x54, 2048); // HSIZE = 32*32*2

    /* VDMA1: MM2S channel configuration */
	Xil_Out32(XPAR_AXI_VDMA_1_BASEADDR+0x0, 0x11011); // VDMA0 running 10081
	Xil_Out32(XPAR_AXI_VDMA_1_BASEADDR+0x5C, 0x01200000); // VDMA0 frame buffer 0
	Xil_Out32(XPAR_AXI_VDMA_1_BASEADDR+0x58, 2048); // STRIDE = HSIZE
	Xil_Out32(XPAR_AXI_VDMA_1_BASEADDR+0x54, 2048); // HSIZE = 32*32*2

    /* VDMA2: MM2S channel configuration */
	Xil_Out32(XPAR_AXI_VDMA_2_BASEADDR+0x0, 0x11011); // VDMA0 running 10081
	Xil_Out32(XPAR_AXI_VDMA_2_BASEADDR+0x5C, 0x01300000); // VDMA0 frame buffer 0
	Xil_Out32(XPAR_AXI_VDMA_2_BASEADDR+0x58, 2048); // STRIDE = HSIZE
	Xil_Out32(XPAR_AXI_VDMA_2_BASEADDR+0x54, 2048); // HSIZE = 32*32*2


    /*statusReg = Xil_In32(XPAR_AXI_DMA_0_BASEADDR + 0x4);
    while((statusReg & 4096) != 4096) {
    	statusReg = Xil_In32(XPAR_AXI_DMA_0_BASEADDR + 0x4);
    }

	/* 2nd coeff packet */
	Xil_Out32(XPAR_AXI_DMA_0_BASEADDR + 0x28, 200); // ByteToTransfer 50*4 = 200 bytes

	/* 1st fmap group */
	Xil_Out32(XPAR_AXI_VDMA_0_BASEADDR+0x50, 1); // VSIZE = 1. Trigger for VDMA
	Xil_Out32(XPAR_AXI_VDMA_1_BASEADDR+0x50, 1); // VSIZE = 1. Trigger for VDMA
	Xil_Out32(XPAR_AXI_VDMA_2_BASEADDR+0x50, 1); // VSIZE = 1. Trigger for VDMA

	/*3rd coeff packet */
	//Xil_Out32(XPAR_AXI_DMA_0_BASEADDR + 0x28, 200); // ByteToTransfer 50*4 = 200 bytes

	/* Last channel */
	//Xil_Out32(XPAR_DECONV_LAYER_PROC_V1_0_0_BASEADDR,0x3D);

    while((statusReg & 4096) != 4096) {
    	statusReg = Xil_In32(XPAR_AXI_VDMA_0_BASEADDR + 0x34);
    }

    statusReg = Xil_In32(XPAR_AXI_VDMA_0_BASEADDR + 0x4);
    xil_printf("VDMA0_MM2S_SR: %x\n\r", statusReg);
    statusReg = Xil_In32(XPAR_AXI_VDMA_2_BASEADDR + 0x4);
    xil_printf("VDMA2_MM2S_SR: %x\n\r", statusReg);
    statusReg = Xil_In32(XPAR_AXI_VDMA_0_BASEADDR + 0x34);
    xil_printf("VDMA0_S2MM_SR: %x\n\r", statusReg);
    statusReg = Xil_In32(XPAR_AXI_VDMA_2_BASEADDR + 0x34);
    xil_printf("VDMA2_S2MM_SR: %x\n\r", statusReg);
    statusReg = Xil_In32(XPAR_AXI_VDMA_1_BASEADDR + 0x4);
    xil_printf("VDMA1_MM2S_SR: %x\n\r", statusReg);
    statusReg = Xil_In32(XPAR_AXI_VDMA_1_BASEADDR + 0x34);
    xil_printf("VDMA1_S2MM_SR: %x\n\r", statusReg);
    statusReg = Xil_In32(XPAR_AXI_VDMA_3_BASEADDR + 0x34);
    xil_printf("VDMA3_S2MM_SR: %x\n\r", statusReg);

    xil_printf("Test completed\n\r");

    /*xil_printf("Reading output data 1...\n");
    u32 rout,addr;
    for (u32 i = 0; i < 10; i++) {
    	rout = Xil_In32(0x01100000 + 4*i);
    	addr = 0x01400000+4*i;
    	xil_printf("Addr %d: %x\n\r", i, addr);
    	xil_printf("Data %d: %x\n\r", i, rout);
    }

    /* Reading transfered data into DDR */
    xil_printf("Reading output data 1...\n");
    u32 rout;
    /*for (u32 i = 0; i < 2278; i++) {
    	rout = Xil_In32(0x01400000 + 4*i);
    	xil_printf("Data %d: %x\n\r", i, rout);
    } */
    /*xil_printf("Reading output data 2...\n");
    for (u32 i = 0; i < 2278; i++) {
    	rout = Xil_In32(0x01500000 + 4*i);
    	xil_printf("Data %d: %x\n\r", i, rout);
    } */

    cleanup_platform();
    return 0;
}


