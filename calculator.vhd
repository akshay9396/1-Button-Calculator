library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity calculator is
	port(
	--declare clock as input
        CLK : in std_logic;

	--declare reset as input
        RESET : in std_logic;

	--declare button as input and assign all 16 bits = 0
        BUTTON :  in std_logic_vector ;

	--declare LED as output and assign all 8 bits to 0
        LED : out std_logic_vector(7 downto 0) := (others => 0);
		);
		
end entity calculator;

architecture behavioral of Calculator is

	type state_type is (IDLE_STATE , BUTTON_PRESSED_STATE , COMPUTATION_STATE , LED_DISPLAY_STATE);

	--Assign State to IDLE 
	signal fsm_state : state_type := IDLE_STATE;

	--Use Clock Counter to increment the clock cycles
	signal clock_counter : integer range 0 to (12e6)-1 := 0;

	--Use bit counter to count 2 bytes 
	signal bit_counter : integer range 0 to 15 := 0;
	
	--for storing the temporary result
	signal result : std_logic_vector(7 downto 0) := (others => 0);
	
	--Use counter to introduce delay for LED blinking
	signal led_delay : integer range 0 to (50e3)-1 :=0;
	
	-- Use counter for LED blinking for bit confirmation
	signal led_blink : integer range 0 to 7 :- (others => 0);
	
	--declare Accumulator for storing the bits and initialize all 16 bits to 0
	signal ACCUMULATOR_REGISTER : std_logic_vector(15 downto 0) := (others => 0);
	

	begin

    process (CLK) is

        begin

        if rising_edge(CLK) then
		
		--If reset is pressed, then reset states, inputs, counters, outputs
        if RESET = 1 then

			BUTTON <= 1;
			
			ACCUMULATOR_REGISTER <= 0;
 
            LED <= '00000000';

            clock_counter <= 0;

            bit_counter <= 0;
	
	    fsm_state <= IDLE_STATE ;
		
		else

	case fsm_state is

		when IDLE_STATE =>

                	LED <= '00000000';
			--If Button pressed  
                	if BUTTON = 0 then

	                	state <= BUTTON_PRESSED_STATE;
					else
					
						state <= IDLE_STATE;

                	end if;
		break;
					
		when BUTTON_PRESSED_STATE =>

			for bit_counter in 0 to 15 loop
				
			
				clock_counter <= clock_counter + 1;
				
				if clock_counter <= (12e6)-1 and BUTTON = 1 then
					
					ACCUMULATOR_REGISTER[bit_counter] <= 1;
				
					LED[led_blink] <= 1; 
					
					--delay of 15e3 
					if rising_edge(CLK) then
						led_delay=led_delay+1;
					end if;
					
					if led_delay = (50e3)-1 then
						LED[led_blink] <= 0;
					led_delay <= 0;
					end if;
					
					LED[led_blink] <= 1; 
					
					if rising_edge(CLK) then
					led_delay=led_delay+1;
					end if;
					
					if led_delay = (50e3)-1 then
					LED[led_blink] <= 1;
					led_delay <= 0;
					end if;
					
					
				else
					ACCUMULATOR_REGISTER[bit_counter] <= 0;
					LED[led_blink] <= 1; 
					
					--delay
					if rising_edge(CLK) then
					led_delay=led_delay+1;
					end if;
					
					if led_delay = (50e3)-1 then
					LED[led_blink] <= 0;
					led_delay <= 0;
					end if;
				end if;
				
				if led_blink = 7 then
						led_blink <=0;
				end if;
				
				
				if(bit_counter == 15)
					if rising_edge(CLK) then
					led_delay=led_delay+1;
					end if;
					
					if led_delay = (50e3)-1 then
					LED[led_blink] <= 0;
					led_delay <= 0;
					
					--Blink all LED's to indicate all bits are initialized and are ready for computation
					LED <= '11111111';

					if rising_edge(CLK) then
					led_delay=led_delay+1;
					end if;
					
					if led_delay = (50e3)-1 then
					LED <= '00000000'; -- Turn off all the LEDs
					led_delay <= 0;
					end if;
					
					
					--Change state and set the counters zero 
					clock_counter <= 0;
					bit_counter <= 0;
					led_delay <= 0;
				end if;
				
				led_blink <= led_blink+1;
				
				
				
			end loop;
			
			fsm_state <= COMPUTATION_STATE;
		break;
			
		when COMPUTATION_STATE =>
		
			result <= ACCUMULATOR_REGISTER [15 downto 8] + ACCUMULATOR_REGISTER [7 downto 0];
			
			fsm_state <= LED_DISPLAY_STATE;
		break;
			
			
		when LED_DISPLAY_STATE =>
			LED <= result;
			fsm_state <= IDLE_STATE;
		break;
		
		end case;
		end if;
		end if;
		end process;
	end architecture behavioral;