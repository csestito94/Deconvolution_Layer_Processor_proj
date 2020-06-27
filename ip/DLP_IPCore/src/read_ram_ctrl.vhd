-- Designer: Cristian Sestito
-- Control unit for Simple Dual Port RAM readings

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity read_ram_ctrl is
    generic (
    LAT: integer := 7; -- initial latency
    ASIZE: integer := 11); -- address generator size
    port(
    clk: in std_logic;
    rst: in std_logic;
    en_fsm: in std_logic;
    MDPTH: in std_logic_vector(ASIZE-1 downto 0);
    enb: out std_logic;
    addrb: out std_logic_vector(ASIZE-1 downto 0));
end read_ram_ctrl;

architecture arch_read_ctrl of read_ram_ctrl is

type state_type is (init,latency,start,read_en,reset,stop);

signal curr_state, next_state: state_type := init;

-- General counter signals
signal gen_en: std_logic;
signal gen_rst : std_logic;
signal gen_cnt: unsigned(ASIZE downto 0); 

-- Read addresses generator signals
signal rd_en: std_logic;
signal rd_rst : std_logic;
signal rd_cnt: unsigned(ASIZE-1 downto 0); 

begin

gen_counter: process(clk)
begin
    if rising_edge(clk) then
        if gen_rst = '1' then
            gen_cnt <= (others => '0');
        elsif gen_en = '1' then
            gen_cnt <= gen_cnt+1;
        end if;
    end if;
end process;

rd_counter: process(clk)
begin
    if rising_edge(clk) then
        if rd_rst = '1' then
            rd_cnt <= (others => '0');
        elsif rd_en = '1' then
            rd_cnt <= rd_cnt+1;
        end if;
    end if;
end process;

state_reg_proc: process(clk)
begin
    if rising_edge(clk) then
        if rst = '1' then
            curr_state <= init;
         else
            curr_state <= next_state;
        end if;
    end if;
end process;

next_state_logic: process(curr_state,en_fsm,gen_cnt)
begin
    case curr_state is
        when init =>
            if en_fsm = '1' then
                next_state <= latency;
            else
                next_state <= init;
            end if;
        when latency =>
            if gen_cnt = to_unsigned(LAT-2,gen_cnt'length) then 
                next_state <= start;
            else
                next_state <= latency;
            end if;
        when start =>
            next_state <= read_en; 
        when read_en =>
            if gen_cnt = unsigned(MDPTH) then 
                next_state <= reset;
            else
                next_state <= read_en;
            end if;  
        when reset =>
            if en_fsm = '1' then
                next_state <= read_en;
            else
                next_state <= stop;
            end if;
        when stop =>
            if en_fsm = '1' then
                next_state <= read_en;
            else
                next_state <= stop;
            end if;
    end case;
end process;

output_logic: process(curr_state,en_fsm)
begin
    case curr_state is
        when init =>
            gen_en <= '0';
            rd_en <= '0';
            gen_rst <= '1';
            rd_rst <= '1';
        when latency =>
            gen_en <= en_fsm;
            rd_en <= '0';
            gen_rst <= '0';
            rd_rst <= '1';  
        when start =>
            gen_en <= en_fsm;
            rd_en <= '0';
            gen_rst <= '1';
            rd_rst <= '1';              
        when read_en =>
            gen_en <= en_fsm;
            rd_en <= en_fsm;
            gen_rst <= '0';
            rd_rst <= '0';       
        when reset =>
            gen_en <= en_fsm;
            rd_en <= '1';
            gen_rst <= '1';
            rd_rst <= '1';   
        when stop =>
            gen_en <= '0';
            rd_en <= '0';
            gen_rst <= '1';
            rd_rst <= '1';    
    end case;
end process;

addrb <= std_logic_vector(rd_cnt);
enb <= rd_en;

end arch_read_ctrl;

