library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

entity power_on_delay is
    Port ( RST : in STD_LOGIC;
           CLK :in std_logic;
           pwdn_cam:out STD_LOGIC;
           reset_cam:out std_logic;
           ready:out std_logic);
end power_on_delay;

architecture Behavioral of power_on_delay is
    signal pwdn_signal: std_logic;
    signal rst_signal: std_logic;
    signal t2ms: integer range 0 to 100001:=100000;
    signal t6ms: integer range 0 to 300001:=300000;
    signal t21ms: integer range 0 to 1050001:=1050000;
    signal t2_reg: std_logic_vector(17 downto 0);
    signal t6_reg: std_logic_vector(19 downto 0);
    signal t21_reg: std_logic_vector(21 downto 0);
    
begin
PWDN_signal<='0'when t6_reg>=t6ms else '1';

process(RST,CLK) is
begin
if RST ='0' then
   t6_reg<=(others=>'0');
elsif rising_edge(CLK) then
    if PWDN_signal ='1' then
        t6_reg<=t6_reg+1;
    end if;
end if;
end process;

pwdn_cam<='0' when t6_reg>=t6ms else '1';
RST_signal<='1' when t2_reg>=t2ms else '0';

process(RST,CLK) is
begin
if RST ='0' then
    t2_reg<=(others=>'0');
elsif rising_edge(CLK) then
    if PWDN_signal ='0' and RST_signal ='0' then
        t2_reg<=t2_reg+1;
    end if;
end if;
end process;

reset_cam<='1' when t2_reg>=t2ms 
    else '0';

process(RST,CLK) is
begin
if RST ='0' then
   t21_reg<=(others=>'0');
elsif rising_edge(CLK) then
    if RST_signal = '1'  then
       t21_reg<=t21_reg+1;
    end if;
    
end if;

end process;

ready<= '1' when t21_reg>=t21ms else '0';

end Behavioral;
