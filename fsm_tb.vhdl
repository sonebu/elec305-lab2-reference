library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity combination_lock_tb is
--  Port ( );
end combination_lock_tb;

architecture Behavioral of combination_lock_tb is
    component combination_lock
       Port (clk  : in std_logic;
             sw   : in std_logic_vector(6 downto 0);
             seg  : out std_logic_vector(6 downto 0);
             led  : out std_logic_vector(6 downto 0);
             an   : out std_logic_vector(3 downto 0);
             btnC : in std_logic_vector(0 downto 0)
             );
    end component;
    signal clk_tb  : std_logic;
    signal seg_tb  : std_logic_vector(6 downto 0);
    signal sw_tb   : std_logic_vector(6 downto 0);
    signal led_tb  : std_logic_vector(6 downto 0);
    signal an_tb   : std_logic_vector(3 downto 0);
    signal btnC_tb : std_logic_vector(0 downto 0);
begin

    dut: entity work.combination_lock port map (clk => clk_tb, sw => sw_tb, seg => seg_tb, led => led_tb, an => an_tb, btnC => btnC_tb);
    
    clk_process :process
    begin
        clk_tb <= '0';
        wait for 5 ns;
        clk_tb <= '1';
        wait for 5 ns;
    end process;
    
    sim_process: process
    begin
        sw_tb <= "0000000";
        btnC_tb(0) <= '0';
        wait for 100 us;

        -- short pulse, shouldn't work
        btnC_tb(0) <= '1';
        wait for 200 us;
        btnC_tb(0) <= '0';
        wait for 500 us;

        -- short pulse, glitch, then another short pulse
        -- together they should have worked, but due to the glitch in between they shouldn't
        btnC_tb(0) <= '1';
        wait for 350 us;
        btnC_tb(0) <= '0';
        wait for 10 us;
        btnC_tb(0) <= '1';
        wait for 350 us;
        btnC_tb(0) <= '0';
        wait for 700 us;

        -- long pulse, should work, state should go from "zero" to "one"
        sw_tb <= "0000000";
        btnC_tb(0) <= '1';
        wait for 700 us;
        btnC_tb(0) <= '0';
        wait for 500 us;

        -- now state transition test
        sw_tb <= "0000001";
        btnC_tb(0) <= '1'; -- this will not work !! because the debouncing period works both ways, we should have waited approx. 150 ms more for this.
        wait for 1 ms;
        btnC_tb(0) <= '0';
        wait for 1 ms;
        
        btnC_tb(0) <= '1'; -- now this will work, state from "one" to "two" 
        wait for 1 ms;
        btnC_tb(0) <= '0';
        wait for 1 ms;

        -- will not work, wrong password, should get locked out at iteration 6
        pwd_check: for k in 0 to 7 loop
            btnC_tb(0) <= '1';
            wait for 1 ms;
            btnC_tb(0) <= '0';
            wait for 1 ms;
        end loop pwd_check;

        sw_tb <= "0000010";
        btnC_tb(0) <= '1'; -- no effect even though it was correct password for the state we had earlier
        wait for 1 ms;
        btnC_tb(0) <= '0';
        wait for 1 ms;

        btnC_tb(0) <= '1'; -- long press --> lockout reset!
        wait for 2 ms;
        btnC_tb(0) <= '0';
        wait for 2 ms;

        sw_tb <= "0000000"; -- zero to one, should work
        btnC_tb(0) <= '1';
        wait for 1 ms;
        btnC_tb(0) <= '0';
        wait for 1 ms;

        sw_tb <= "0000001"; -- one to two, should work
        btnC_tb(0) <= '1';
        wait for 1 ms;
        btnC_tb(0) <= '0';
        wait for 1 ms;

        sw_tb <= "0000010"; -- two to zero, should work
        btnC_tb(0) <= '1';
        wait for 1 ms;
        btnC_tb(0) <= '0';
        wait for 1 ms;

        wait;
        
    end process;

end Behavioral;
