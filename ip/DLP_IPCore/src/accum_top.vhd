-- Designer: Cristian Sestito
-- The fmaps Accumulator (TOP LEVEL)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--library xil_defaultlib;
--use xil_defaultlib.array_def.all;

entity accum_top is
    generic(
    ABIN: integer := 11; -- address word size
    LAT: integer := 7); -- initial latency
    port(
    clk: in std_logic;
    rst: in std_logic;
    s_valid: in std_logic;
    ce: in std_logic;
    last_ch: in std_logic; 
    MDPTH: in std_logic_vector(ABIN-1 downto 0);
    I: in std_logic_vector(47 downto 0);
    Q: out std_logic_vector(15 downto 0));
end accum_top;

architecture arch_accum of accum_top is

component dsp_accum is
    port(
    clk: in std_logic;
    rst: in std_logic;
    ce: in std_logic;
    A: in std_logic_vector(29 downto 0);
    B: in std_logic_vector(17 downto 0);
    C: in std_logic_vector(47 downto 0);
    P: out std_logic_vector(47 downto 0));
end component;

component RAM_SDP is
    generic(
    DBIN: integer := 11; 
    N: integer := 48); 
    port(
    clk: in std_logic;
    ena: in std_logic;
    enb: in std_logic;
    wea: in std_logic;
    addra: in std_logic_vector(DBIN-1 downto 0);
    addrb: in std_logic_vector(DBIN-1 downto 0);
    dia: in std_logic_vector(N-1 downto 0);
    dob: out std_logic_vector(N-1 downto 0));
end component;

component read_ram_ctrl is
    generic (
    LAT: integer := 7; 
    ASIZE: integer := 11); 
    port(
    clk: in std_logic;
    rst: in std_logic;
    en_fsm: in std_logic;
    MDPTH: in std_logic_vector(ASIZE-1 downto 0);
    enb: out std_logic;
    addrb: out std_logic_vector(ASIZE-1 downto 0));
end component;

component write_ram_ctrl is
    generic (
    LAT: integer := 10; 
    ASIZE: integer := 11); 
    port(
    clk: in std_logic;
    rst: in std_logic;
    en_fsm: in std_logic;
    last_ch_in: in std_logic;
    MDPTH: in std_logic_vector(ASIZE-1 downto 0);
    ena: out std_logic;
    wea: out std_logic;
    addra: out std_logic_vector(ASIZE-1 downto 0);
    last_ch_out: out std_logic);
end component;

signal accum: std_logic_vector(47 downto 0);
signal sum_res: std_logic_vector(47 downto 0);
signal dia: std_logic_vector(47 downto 0);
signal ena: std_logic;
signal wea: std_logic;
signal addra: std_logic_vector(ABIN-1 downto 0);
signal enb: std_logic;
signal addrb: std_logic_vector(ABIN-1 downto 0);
signal last_ch_int: std_logic;

begin

sum: dsp_accum port map(clk=>clk,rst=>rst,ce=>ce,A=>I(47 downto 18),B=>I(17 downto 0),C=>accum,P=>sum_res);

with last_ch_int select dia <=
    sum_res when '0',
    (others => '0') when others;
    
mem: RAM_SDP generic map(DBIN=>ABIN,N=>48)
    port map(clk=>clk,ena=>ena,enb=>enb,wea=>wea,addra=>addra,addrb=>addrb,dia=>dia,dob=>accum);

r_ctrl: read_ram_ctrl generic map (LAT=>LAT,ASIZE=>ABIN) 
    port map(clk=>clk,rst=>rst,en_fsm=>ce,MDPTH=>MDPTH,enb=>enb,addrb=>addrb);

w_ctrl: write_ram_ctrl generic map (LAT=>LAT,ASIZE=>ABIN) 
    port map(clk=>clk,rst=>rst,en_fsm=>ce,last_ch_in=>last_ch,MDPTH=>MDPTH,ena=>ena,wea=>wea,addra=>addra,last_ch_out=>last_ch_int);

Q <= sum_res(15 downto 0); -- 16-bit quantization

end arch_accum;
