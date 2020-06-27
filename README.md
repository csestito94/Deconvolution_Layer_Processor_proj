# An Efficient FPGA-based Deconvolver for Deep Learning Applications
**Submitted for the Xilinx Open Hardware University Design Contest 2020**

**University of Calabria - Department of Informatics, Modeling, Electronics and System Engineering - Rende, Cosenza, Italy**

*Designer: Cristian Sestito, PhD Student*

*Supervisor: Stefania Perri, Associate Professor*

*Board used*: Digilent ZedBoard Zynq-7000 ARM/FPGA SoC Development Board

*Vivado Version*: 2017.4

*Abstract*

In the last few years, efficient implementations of Convolutional Neural Networks (CNNs) have been extensively explored in FPGA-based systems-on-chip. These platforms, in fact, exhibit performances higher than CPUs and power consumption lower than GPUs. 
Generally speaking, convolutions provide low-resolution feature maps from high-resolution ones. Certain tasks also require the opposite, such as image segmentation and generation. However, the latter deconvolution strategy, better known as transposed convolution, does not fit well with typical hardware convolvers. The huge padding needed, in fact, exhibits unbalanced workloads and, thus, computational inefficiency. In order to address these issues, an optimized algorithm has been recently proposed in literature.
This work exploits the latter to present an efficient deconvolver, implemented within a complete embedded system. The standalone architecture, described by means of parametric VHDL constructs, can be easily adapted to different deep learning applications, showing limited resource utilization and noticeable throughput. As a case study, the novel circuit has been integrated within the XC7Z020 SoC to accelerate transposed convolutions in generative networks. Results in terms of resource utilization, performances and power consumption are provided.

*Instructions to build and test project*

Step 1: Decompress the DLP_ES_Block_Design.xpr.zip archive and open the project by using VIVADO.

Step 2: Generate all IP Core Output Products.

Step 3: Run Synthesis,Implementation & Bistream Generation.

Step 4: Export HW results into SDK and launch it.

Step 5: Program the FPGA, open the Serial COM Port and run the configuration in System Debugger mode. 

Step 6: Write the results, stored within the DDR, in a text file by using XSCT prompt. Please refer to the write_to_file_notes.txt within the hw sub-directory for details related to the specific test setup.

Step 7: Open MATLAB and run the final_test.m script. "Test result = 1" will be printed to the command window.

*Notes*

According to the project report, the VHDL codes are highly parameterizable. Therefore, you could modify them to adapt the novel Deconvolution Layer Processor for different application tasks (e.g. semantic segmentation, high-resolution imaging). The MATLAB scripts are also easily parameterizable, so you can verify the correctness of the results for each test performed. Please refer to the additional guide VHDL_template_notes.txt within the doc sub-directory for more details.

Link to YouTube Video: 
