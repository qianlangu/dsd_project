library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity capture is
    port (
        clk  : in   std_logic;
        vsync : in   std_logic;
        href  : in   std_logic;
        d     : in   std_logic_vector ( 7 downto 0);
        addr  : out  std_logic_vector (17 downto 0);
        do  : out  std_logic_vector (11 downto 0);
        o    : out  std_logic
    );
end capture;

architecture behavioral of capture is
   signal latch      : std_logic_vector(15 downto 0) := (others => '0');
   signal address      : std_logic_vector(18 downto 0) := (others => '0');
   signal add_nxt : std_logic_vector(18 downto 0) := (others => '0');
   signal w     : std_logic_vector( 1 downto 0)  := (others => '0');
   
begin
   addr <= address(18 downto 1);
   process(clk)
   begin
      if rising_edge(clk) then
         if vsync = '1' then 
            w <= (others => '0');
            address <= (others => '0');
            add_nxt <= (others => '0');
         else
            o <= w(1);
            do <= latch(11 downto 8) & latch(7 downto 4) & latch(3 downto 0); 
            address <= add_nxt;
            w <= w(0) & (href and not w(0));
            latch <= latch( 7 downto  0) & d;
            if w(1) = '1' then
               add_nxt <= std_logic_vector(unsigned(add_nxt)+1);
            end if;
            
         end if;
      end if;
   end process;
   
end behavioral;
