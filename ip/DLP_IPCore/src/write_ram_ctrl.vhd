-- Designer: Cristian Sestito
-- Control unit for Simple Dual Port RAM writings

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity write_ram_ctrl is
    generic (
    LAT: integer := 10; -- initial latency
    ASIZE: integer := 11); -- address generator size
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
end write_ram_ctrl;

architecture arch_write_ctrl of write_ram_ctrl is

type state_type is (init,latency,start,write_en,reset,last_write_en,stop);

signal curr_state, next_state: state_type := init;

-- General counter signals
signal gen_en: std_logic;
signal gen_rst : std_logic;
signal gen_cnt: unsigned(ASIZE downto 0); 

-- Write addresses generator signals
signal wr_en: std_logic;
signal wr_rst : std_logic;
signal wr_cnt: unsigned(ASIZE-1 downto 0); 

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

wr_counter: process(clk)
begin
    if rising_edge(clk) then
        if wr_rst = '1' then
            wr_cnt <= (others => '0');
        elsif wr_en = '1' then
            wr_cnt <= wr_cnt+1;
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

next_state_logic: process(curr_state,en_fsm,gen_cnt,last_ch_in)
begin
    case curr_state is
        when init =>
            if en_fsm = '1' then
                next_state <= latency;
            else
                next_state <= init;
            end if;
        when latency =>
            if gen_cnt = to_unsigned((LAT+3)-2,gen_cnt'length) then 
                next_state <= start;
            else
                next_state <= latency;
            end if;
        when start =>
            if last_ch_in = '1' then
                next_state <= last_write_en;
            else
                next_state <= write_en;
            end if;
        when write_en =>
            if gen_cnt = unsigned(MDPTH) then 
                next_state <= reset;
            else
                next_state <= write_en;
            end if;   
        when reset =>
            if last_ch_in = '1' then
                next_state <= last_write_en; 
            else
                next_state <= write_en;
            end if;
        when last_write_en =>
            if gen_cnt = unsigned(MDPTH) then   
                if en_fsm = '1' then
                    next_state <= reset;
                else
                    next_state <= stop;
                end if;
            else
                next_state <= last_write_en;
            end if;
        when stop =>
            if en_fsm = '1' then
                next_state <= reset;
            else
                next_state <= stop;
            end if;
    end case;
end process;

output_logic: process(curr_state,en_fsm)
begin
    case curr_state is
        when init =>
            wea <= '0';
            gen_en <= '0';
            wr_en <= '0';
            gen_rst <= '1';
            wr_rst <= '1';
            last_ch_out <= '0';
        when latency =>
            wea <= '0';
            gen_en <= en_fsm;
            wr_en <= '0';
            gen_rst <= '0';
            wr_rst <= '1';  
            last_ch_out <= '0';
        when start =>
            wea <= '0';
            gen_en <= en_fsm;
            wr_en <= en_fsm;
            gen_rst <= '1';
            wr_rst <= '1';  
            last_ch_out <= '0';            
        when write_en =>
            wea <= '1';
            gen_en <= en_fsm;
            wr_en <= en_fsm;
            gen_rst <= '0';
            wr_rst <= '0';              
            last_ch_out <= '0';
        when reset =>
            wea <= '1';
            gen_en <= en_fsm;
            wr_en <= en_fsm;
            gen_rst <= '1';
            wr_rst <= '1';  
            last_ch_out <= '0';             
        when last_write_en =>
            wea <= '1';
            gen_en <= en_fsm;
            wr_en <= en_fsm;
            gen_rst <= '0';
            wr_rst <= '0';              
            last_ch_out <= '1';          
        when stop =>
            wea <= '0';
            gen_en <= '0';
            wr_en <= '0';
            gen_rst <= '1';
            wr_rst <= '1';
            last_ch_out <= '0';
    end case;
end process;

addra <= std_logic_vector(wr_cnt);
ena <= wr_en;

end arch_write_ctrl;

