library ieee;
use ieee.std_logic_1164.ALL;
use ieee.numeric_std.ALL;

entity ov5640_capture is
    port (
        pclk  : in   std_logic;
        vsync : in   std_logic;
        href  : in   std_logic;
        d     : in   std_logic_vector ( 7 downto 0);
        addr  : out  std_logic_vector (17 downto 0);
        dout  : out  std_logic_vector (11 downto 0);
        we    : out  std_logic
    );
end ov5640_capture;

architecture behavioral of ov5640_capture is
   signal d_latch      : std_logic_vector(15 downto 0) := (others => '0');
   signal address      : std_logic_vector(18 downto 0) := (others => '0');
   signal address_next : std_logic_vector(18 downto 0) := (others => '0');
   signal wr_hold      : std_logic_vector( 1 downto 0)  := (others => '0');
   
begin
   addr <= address(18 downto 1);
   process(pclk)
   begin
      if rising_edge(pclk) then

         if vsync = '1' then 
            address <= (others => '0');
            address_next <= (others => '0');
            wr_hold <= (others => '0');
         else
            
            dout    <= d_latch(11 downto 8) & d_latch(7 downto 4) & d_latch(3 downto 0); 
            address <= address_next;
            we      <= wr_hold(1);
            wr_hold <= wr_hold(0) & (href and not wr_hold(0));
            d_latch <= d_latch( 7 downto  0) & d;

            if wr_hold(1) = '1' then
               address_next <= std_logic_vector(unsigned(address_next)+1);
            end if;
         end if;
      end if;
   end process;
end behavioral;
