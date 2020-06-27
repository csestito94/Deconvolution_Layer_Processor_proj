-- The Deconvolution Layer Processor TESTBENCH

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity DECONV_LAYER_TB is
--  Port ( );
end DECONV_LAYER_TB;

architecture Behavioral of DECONV_LAYER_TB is

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
signal sr_depth: std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(30,5));
signal MDPTH: std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(1154,11));
signal W: std_logic_vector(5 downto 0) := std_logic_vector(to_unsigned(31,6));
signal Wext: std_logic_vector(5 downto 0) := std_logic_vector(to_unsigned(32,6));
signal Pad: std_logic_vector(6 downto 0) := std_logic_vector(to_unsigned(69,7));
signal ndata: std_logic_vector(10 downto 0) := std_logic_vector(to_unsigned(1155,11));
   
signal s00_axis_aclk: std_logic;
signal s00_axis_aresetn: std_logic;
signal s00_axis_tready: std_logic;
signal s00_axis_tdata: std_logic_vector(47 downto 0);
signal s00_axis_tlast: std_logic;
signal s00_axis_tvalid: std_logic;
    
signal s01_axis_aclk: std_logic;
signal s01_axis_aresetn: std_logic;
signal s01_axis_tready: std_logic;
signal s01_axis_tdata: std_logic_vector(63 downto 0);
signal s01_axis_tlast: std_logic;
signal s01_axis_tvalid: std_logic;    

signal m00_axis_aclk: std_logic;
signal m00_axis_aresetn: std_logic;
signal m00_axis_tvalid: std_logic;
signal m00_axis_tdata: std_logic_vector(127 downto 0);
signal m00_axis_tlast: std_logic;
signal m00_axis_tready: std_logic;
signal m00_axis_tuser: std_logic;

constant clkp: time := 10 ns;

begin

uut: DECONV_LAYER_TOP 
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

s00_axis_aclk_proc: process
begin
    s00_axis_aclk <= '1';
    wait for clkp/2;
    s00_axis_aclk <= '0';
    wait for clkp/2;
end process;

m00_axis_aclk_proc: process
begin
    m00_axis_aclk <= '1';
    wait for clkp/2;
    m00_axis_aclk <= '0';
    wait for clkp/2;
end process;

s01_axis_aclk_proc: process
begin
    s01_axis_aclk <= '1';
    wait for clkp/2;
    s01_axis_aclk <= '0';
    wait for clkp/2;
end process;

s01_axis_proc: process
begin
    s01_axis_aresetn <= '0';
    s01_axis_tvalid <= '0';
    s01_axis_tlast <= '0';
    s01_axis_tdata <= (others => '0');
    wait for 3*clkp;
    s01_axis_aresetn <= '1';
    s01_axis_tvalid <= '1'; 
    s01_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(5,16));
    s01_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(5,16));
    s01_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(5,16));
    s01_axis_tdata(63 downto 48) <= std_logic_vector(to_unsigned(0,16));
    wait for clkp;
    
    -- 1st packet
    for j in 0 to 4 loop
        for k in 0 to 4 loop
            s01_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(5-k,16));
            s01_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(5-k,16));
            s01_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(5-k,16));
            s01_axis_tdata(63 downto 48) <= std_logic_vector(to_unsigned(0,16));
            wait for clkp;
        end loop;
    end loop;    
    for j in 0 to 3 loop
        for k in 0 to 4 loop
            s01_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(5-k,16));
            s01_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(5-k,16));
            s01_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(5-k,16));
            s01_axis_tdata(63 downto 48) <= std_logic_vector(to_unsigned(0,16));
            wait for clkp;
        end loop;
    end loop;
    for k in 0 to 3 loop
        s01_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(5-k,16));
        s01_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(5-k,16));
        s01_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(5-k,16));
        s01_axis_tdata(63 downto 48) <= std_logic_vector(to_unsigned(0,16));
        wait for clkp;
    end loop;
    s01_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(1,16));
    s01_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(1,16));
    s01_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(1,16));
    s01_axis_tdata(63 downto 48) <= std_logic_vector(to_unsigned(0,16));
    s01_axis_tlast <= '1';
    wait for clkp;
    s01_axis_tlast <= '0';
    s01_axis_tvalid <= '0';
    
    wait for clkp;
    
    -- 2nd packet
    for j in 0 to 4 loop
        for k in 0 to 4 loop
            s01_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(5-k,16));
            s01_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(5-k,16));
            s01_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(5-k,16));
            s01_axis_tdata(63 downto 48) <= std_logic_vector(to_unsigned(0,16));
            wait for clkp;
        end loop;
    end loop;    
    for j in 0 to 3 loop
        for k in 0 to 4 loop
            s01_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(5-k,16));
            s01_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(5-k,16));
            s01_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(5-k,16));
            s01_axis_tdata(63 downto 48) <= std_logic_vector(to_unsigned(0,16));
            wait for clkp;
        end loop;
    end loop;
    for k in 0 to 3 loop
        s01_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(5-k,16));
        s01_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(5-k,16));
        s01_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(5-k,16));
        s01_axis_tdata(63 downto 48) <= std_logic_vector(to_unsigned(0,16));
        wait for clkp;
    end loop;
    s01_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(1,16));
    s01_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(1,16));
    s01_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(1,16));
    s01_axis_tdata(63 downto 48) <= std_logic_vector(to_unsigned(0,16));
    s01_axis_tlast <= '1';
    wait for clkp;
    s01_axis_tlast <= '0';
    s01_axis_tvalid <= '0';    
    
    wait for ((34*34-50))*clkp;
    s01_axis_tvalid <= '1';
    
    --3rd packet
    for j in 0 to 3 loop
        for k in 0 to 4 loop
            s01_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(5-k,16));
            s01_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(5-k,16));
            s01_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(5-k,16));
            s01_axis_tdata(63 downto 48) <= std_logic_vector(to_unsigned(0,16));
            wait for clkp;
        end loop;
    end loop;
    for k in 0 to 3 loop
        s01_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(5-k,16));
        s01_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(5-k,16));
        s01_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(5-k,16));
        s01_axis_tdata(63 downto 48) <= std_logic_vector(to_unsigned(0,16));
        wait for clkp;
    end loop;
    s01_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(1,16));
    s01_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(1,16));
    s01_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(1,16));
    s01_axis_tdata(63 downto 48) <= std_logic_vector(to_unsigned(0,16));
    s01_axis_tlast <= '1';
    wait for clkp;
    s01_axis_tlast <= '0';
    s01_axis_tvalid <= '0';
    
    wait;

end process;

s00_axis_proc: process
begin
    s00_axis_aresetn <= '0';
    m00_axis_aresetn <= '0';
    s00_axis_tvalid <= '0';
    s00_axis_tlast <= '0';
    s00_axis_tdata <= (others => '0');
    last_ch <= '0';
    sr_depth <= std_logic_vector(to_unsigned(30,5));
    MDPTH <= std_logic_vector(to_unsigned(1154,11));
    W <= std_logic_vector(to_unsigned(31,6));
    Wext <= std_logic_vector(to_unsigned(32,6));
    Pad <= std_logic_vector(to_unsigned(69,7));
    wait for 3*clkp;
    s00_axis_aresetn <= '1';
    m00_axis_aresetn <= '1';
    wait for 50*clkp;
    s00_axis_tvalid <= '1'; 
    s00_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(1,16));
    s00_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(1,16));
    s00_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(1,16));
    wait for clkp;
 
    -- 1st group of feature maps
    for j in 0 to 30 loop
        for k in 0 to 31 loop
            s00_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(1,16));
            s00_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(1,16));
            s00_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(1,16));
            wait for clkp;
        end loop;
        for k in 0 to 1 loop
            s00_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(0,16));
            s00_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(0,16));
            s00_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(0,16));
            wait for clkp;
        end loop;
    end loop; 
    
    last_ch <= '1';
    
    for k in 0 to 30 loop
        s00_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(1,16));
        s00_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(1,16));
        s00_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(1,16));
        wait for clkp; 
    end loop;
    s00_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(1,16));
    s00_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(1,16));
    s00_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(1,16)); 
    s00_axis_tlast <= '1';
    wait for clkp;
    s00_axis_tlast <= '0';
    --s00_axis_tvalid <= '0';
    
    --last_ch <= '1';
    
    wait for (70-1)*clkp;
    --s00_axis_tvalid <= '1';
    wait for clkp;
    
    --last_ch <= '1';
    -- 2nd group of feature maps
    for j in 0 to 30 loop
        for k in 0 to 31 loop
            s00_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(1,16));
            s00_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(1,16));
            s00_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(1,16));
            wait for clkp;
        end loop;
        for k in 0 to 1 loop
            s00_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(0,16));
            s00_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(0,16));
            s00_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(0,16));
            wait for clkp;
        end loop;
    end loop; 
    for k in 0 to 30 loop
        s00_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(1,16));
        s00_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(1,16));
        s00_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(1,16));
        wait for clkp;  
    end loop;
    s00_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(1,16));
    s00_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(1,16));
    s00_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(1,16)); 
    s00_axis_tlast <= '1';
    wait for clkp;
    s00_axis_tlast <= '0';
    s00_axis_tvalid <= '0';    
    
    wait for (70-1)*clkp;
    s00_axis_tvalid <= '1';
    wait for clkp;
    
--    last_ch <= '0';
--    -- 3rd group of feature maps
--    for j in 0 to 30 loop
--        for k in 0 to 31 loop
--            s00_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(1,16));
--            s00_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(1,16));
--            s00_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(1,16));
--            wait for clkp;
--        end loop;
--        for k in 0 to 1 loop
--            s00_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(0,16));
--            s00_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(0,16));
--            s00_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(0,16));
--            wait for clkp;
--        end loop;
--    end loop; 
--    for k in 0 to 30 loop
--        s00_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(1,16));
--        s00_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(1,16));
--        s00_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(1,16));
--        wait for clkp; 
--    end loop;
--    s00_axis_tdata(15 downto 0) <= std_logic_vector(to_unsigned(1,16));
--    s00_axis_tdata(31 downto 16) <= std_logic_vector(to_unsigned(1,16));
--    s00_axis_tdata(47 downto 32) <= std_logic_vector(to_unsigned(1,16)); 
--    s00_axis_tlast <= '1';
--    wait for clkp;
--    s00_axis_tvalid <= '0';      
--    wait for clkp; 

    wait;

end process;

m00_axis_tready <= '1';

end Behavioral;

