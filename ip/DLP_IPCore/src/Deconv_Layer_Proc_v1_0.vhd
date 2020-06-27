-- Designer: Cristian Sestito
-- TOP LEVEL MODULE

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Deconv_Layer_Proc_v1_0 is
	generic (
		-- Users to add parameters here

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Slave Bus Interface S00_AXI
		C_S00_AXI_DATA_WIDTH	: integer	:= 32;
		C_S00_AXI_ADDR_WIDTH	: integer	:= 4
	);
	port (
		-- Users to add ports here

        -- input activations interface signals
        s00_axis_aclk: in std_logic;
        s00_axis_aresetn: in std_logic;
        s00_axis_tready: out std_logic;
        s00_axis_tdata: in std_logic_vector(47 downto 0);
        s00_axis_tlast: in std_logic;
        s00_axis_tvalid: in std_logic;
        -- coefficients interface signals
        s01_axis_aclk: in std_logic;
        s01_axis_aresetn: in std_logic;
        s01_axis_tready: out std_logic;
        s01_axis_tdata: in std_logic_vector(63 downto 0);
        s01_axis_tlast: in std_logic;
        s01_axis_tvalid: in std_logic; 
        -- output activations interface signals
        m00_axis_aclk: in std_logic;
        m00_axis_aresetn: in std_logic;
        m00_axis_tvalid: out std_logic;
        m00_axis_tdata: out std_logic_vector(127 downto 0);
        m00_axis_tlast: out std_logic;
        m00_axis_tready: in std_logic;
        m00_axis_tuser: out std_logic; 
        
		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXI
		s00_axi_aclk	: in std_logic;
		s00_axi_aresetn	: in std_logic;
		s00_axi_awaddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_awprot	: in std_logic_vector(2 downto 0);
		s00_axi_awvalid	: in std_logic;
		s00_axi_awready	: out std_logic;
		s00_axi_wdata	: in std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_wstrb	: in std_logic_vector((C_S00_AXI_DATA_WIDTH/8)-1 downto 0);
		s00_axi_wvalid	: in std_logic;
		s00_axi_wready	: out std_logic;
		s00_axi_bresp	: out std_logic_vector(1 downto 0);
		s00_axi_bvalid	: out std_logic;
		s00_axi_bready	: in std_logic;
		s00_axi_araddr	: in std_logic_vector(C_S00_AXI_ADDR_WIDTH-1 downto 0);
		s00_axi_arprot	: in std_logic_vector(2 downto 0);
		s00_axi_arvalid	: in std_logic;
		s00_axi_arready	: out std_logic;
		s00_axi_rdata	: out std_logic_vector(C_S00_AXI_DATA_WIDTH-1 downto 0);
		s00_axi_rresp	: out std_logic_vector(1 downto 0);
		s00_axi_rvalid	: out std_logic;
		s00_axi_rready	: in std_logic
	);
end Deconv_Layer_Proc_v1_0;

architecture arch_imp of Deconv_Layer_Proc_v1_0 is

	-- component declaration
	component Deconv_Layer_Proc_v1_0_S00_AXI is
		generic (
		C_S_AXI_DATA_WIDTH	: integer	:= 32;
		C_S_AXI_ADDR_WIDTH	: integer	:= 4
		);
		port (
        last_ch: out std_logic;
        sr_depth: out std_logic_vector(4 downto 0);
        MDPTH: out std_logic_vector(10 downto 0);
        W: out std_logic_vector(5 downto 0);
        Wext: out std_logic_vector(5 downto 0);
        Pad: out std_logic_vector(6 downto 0);
        ndata: out std_logic_vector(10 downto 0);
		S_AXI_ACLK	: in std_logic;
		S_AXI_ARESETN	: in std_logic;
		S_AXI_AWADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_AWPROT	: in std_logic_vector(2 downto 0);
		S_AXI_AWVALID	: in std_logic;
		S_AXI_AWREADY	: out std_logic;
		S_AXI_WDATA	: in std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_WSTRB	: in std_logic_vector((C_S_AXI_DATA_WIDTH/8)-1 downto 0);
		S_AXI_WVALID	: in std_logic;
		S_AXI_WREADY	: out std_logic;
		S_AXI_BRESP	: out std_logic_vector(1 downto 0);
		S_AXI_BVALID	: out std_logic;
		S_AXI_BREADY	: in std_logic;
		S_AXI_ARADDR	: in std_logic_vector(C_S_AXI_ADDR_WIDTH-1 downto 0);
		S_AXI_ARPROT	: in std_logic_vector(2 downto 0);
		S_AXI_ARVALID	: in std_logic;
		S_AXI_ARREADY	: out std_logic;
		S_AXI_RDATA	: out std_logic_vector(C_S_AXI_DATA_WIDTH-1 downto 0);
		S_AXI_RRESP	: out std_logic_vector(1 downto 0);
		S_AXI_RVALID	: out std_logic;
		S_AXI_RREADY	: in std_logic
		);
	end component Deconv_Layer_Proc_v1_0_S00_AXI;
	
	component DECONV_LAYER_TOP is
        port(
        -- signals from AXILITE
        last_ch: in std_logic;
        sr_depth: in std_logic_vector(4 downto 0);
        MDPTH: in std_logic_vector(10 downto 0);
        W: in std_logic_vector(5 downto 0);
        Wext: in std_logic_vector(5 downto 0);
        Pad: in std_logic_vector(6 downto 0);
        ndata: in std_logic_vector(10 downto 0);
        -- input activations interface signals
        s00_axis_aclk: in std_logic;
        s00_axis_aresetn: in std_logic;
        s00_axis_tready: out std_logic;
        s00_axis_tdata: in std_logic_vector(47 downto 0);
        s00_axis_tlast: in std_logic;
        s00_axis_tvalid: in std_logic;
        -- coefficients interface signals
        s01_axis_aclk: in std_logic;
        s01_axis_aresetn: in std_logic;
        s01_axis_tready: out std_logic;
        s01_axis_tdata: in std_logic_vector(63 downto 0);
        s01_axis_tlast: in std_logic;
        s01_axis_tvalid: in std_logic; 
        -- output activations interface signals
        m00_axis_aclk: in std_logic;
        m00_axis_aresetn: in std_logic;
        m00_axis_tvalid: out std_logic;
        m00_axis_tdata: out std_logic_vector(127 downto 0);
        m00_axis_tlast: out std_logic;
        m00_axis_tready: in std_logic;
        m00_axis_tuser: out std_logic); 
    end component;
        
    signal last_ch: std_logic;
    signal sr_depth: std_logic_vector(4 downto 0);
    signal MDPTH: std_logic_vector(10 downto 0);
    signal W: std_logic_vector(5 downto 0);
    signal Wext: std_logic_vector(5 downto 0);
    signal Pad: std_logic_vector(6 downto 0);
    signal ndata: std_logic_vector(10 downto 0);

begin

-- Instantiation of Axi Bus Interface S00_AXI
Deconv_Layer_Proc_v1_0_S00_AXI_inst : Deconv_Layer_Proc_v1_0_S00_AXI
	generic map (
		C_S_AXI_DATA_WIDTH	=> C_S00_AXI_DATA_WIDTH,
		C_S_AXI_ADDR_WIDTH	=> C_S00_AXI_ADDR_WIDTH
	)
	port map (
        last_ch => last_ch,
        sr_depth => sr_depth,
        MDPTH => MDPTH,
        W => W,
        Wext => Wext,
        Pad => Pad,
        ndata => ndata,
		S_AXI_ACLK	=> s00_axi_aclk,
		S_AXI_ARESETN	=> s00_axi_aresetn,
		S_AXI_AWADDR	=> s00_axi_awaddr,
		S_AXI_AWPROT	=> s00_axi_awprot,
		S_AXI_AWVALID	=> s00_axi_awvalid,
		S_AXI_AWREADY	=> s00_axi_awready,
		S_AXI_WDATA	=> s00_axi_wdata,
		S_AXI_WSTRB	=> s00_axi_wstrb,
		S_AXI_WVALID	=> s00_axi_wvalid,
		S_AXI_WREADY	=> s00_axi_wready,
		S_AXI_BRESP	=> s00_axi_bresp,
		S_AXI_BVALID	=> s00_axi_bvalid,
		S_AXI_BREADY	=> s00_axi_bready,
		S_AXI_ARADDR	=> s00_axi_araddr,
		S_AXI_ARPROT	=> s00_axi_arprot,
		S_AXI_ARVALID	=> s00_axi_arvalid,
		S_AXI_ARREADY	=> s00_axi_arready,
		S_AXI_RDATA	=> s00_axi_rdata,
		S_AXI_RRESP	=> s00_axi_rresp,
		S_AXI_RVALID	=> s00_axi_rvalid,
		S_AXI_RREADY	=> s00_axi_rready
	);

	-- Add user logic here

    DLP: DECONV_LAYER_TOP 
    port map(
    last_ch => last_ch,
    sr_depth => sr_depth,
    MDPTH => MDPTH,
    W => W,
    Wext => Wext,
    Pad => Pad,
    ndata => ndata,
    s00_axis_aclk => s00_axis_aclk,
    s00_axis_aresetn => s00_axis_aresetn,
    s00_axis_tready => s00_axis_tready,
    s00_axis_tdata => s00_axis_tdata,
    s00_axis_tlast => s00_axis_tlast,
    s00_axis_tvalid => s00_axis_tvalid,
    s01_axis_aclk => s01_axis_aclk,
    s01_axis_aresetn => s01_axis_aresetn,
    s01_axis_tready => s01_axis_tready,
    s01_axis_tdata => s01_axis_tdata,
    s01_axis_tlast => s01_axis_tlast,
    s01_axis_tvalid => s01_axis_tvalid,
    m00_axis_aclk => m00_axis_aclk,
    m00_axis_aresetn => m00_axis_aresetn,
    m00_axis_tvalid => m00_axis_tvalid,
    m00_axis_tdata => m00_axis_tdata,
    m00_axis_tlast => m00_axis_tlast,
    m00_axis_tready => m00_axis_tready,
    m00_axis_tuser => m00_axis_tuser);
	-- User logic ends

end arch_imp;
