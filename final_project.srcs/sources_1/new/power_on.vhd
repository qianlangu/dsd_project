----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 2023/05/13 15:22:28
-- Design Name: 
-- Module Name: power_on - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity power_on is
    Port ( RST : in STD_LOGIC;
           CLK :in std_logic;
           OV_PWDN:out STD_LOGIC;
           OV_RST:out std_logic;
           ready:out std_logic);
end power_on;

architecture Behavioral of power_on is
signal DELAY_6MS: integer range 0 to 300001:=300000;
signal DELAY_2MS: integer range 0 to 100001:=100000;
signal DELAY_21MS: integer range 0 to 1050001:=1050000;
signal CNT_6MS_reg,CNT_6MS_next: std_logic_vector(19 downto 0);
signal CNT_2MS_reg,CNT_2MS_next: std_logic_vector(17 downto 0);
signal CNT_21MS_reg,CNT_21MS_next: std_logic_vector(21 downto 0);
signal PWDN_signal: std_logic;
signal RST_signal: std_logic;
begin
PWDN_signal<='0'when CNT_6MS_reg>=DELAY_6MS else '1';
process(RST,CLK) is
begin
if RST ='0' then
    CNT_6MS_reg<=(others=>'0');
elsif rising_edge(CLK) then
    if PWDN_signal ='1' then
        CNT_6MS_reg<=CNT_6MS_reg+1;
    end if;
end if;
end process;

OV_PWDN<='0' when CNT_6MS_reg>=DELAY_6MS else '1';
RST_signal<='1' when CNT_2MS_reg>=DELAY_2MS else '0';

process(RST,CLK) is
begin
if RST ='0' then
    CNT_2MS_reg<=(others=>'0');
elsif rising_edge(CLK) then
    if PWDN_signal ='0' and RST_signal ='0' then
        CNT_2MS_reg<=CNT_2MS_reg+1;
    end if;
end if;
end process;

OV_RST<='1' when CNT_2MS_reg>=DELAY_2MS else '0';


process(RST,CLK) is
begin
if RST ='0' then
    CNT_21MS_reg<=(others=>'0');
elsif rising_edge(CLK) then
    if RST_signal = '1'  then
        CNT_21MS_reg<=CNT_21MS_reg+1;
    end if;
end if;
end process;
ready<= '1' when CNT_21MS_reg>=DELAY_21MS else '0';

end Behavioral;
