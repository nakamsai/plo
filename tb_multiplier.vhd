library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_multiplier is
end tb_multiplier;

architecture behavior of tb_multiplier is
    component parallel_multiplier
        Port ( A, B : in STD_LOGIC_VECTOR(3 downto 0);
               P : out STD_LOGIC_VECTOR(7 downto 0));
    end component;

    signal A, B : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal P : STD_LOGIC_VECTOR(7 downto 0);
begin
    uut: parallel_multiplier port map(A => A, B => B, P => P);

    stim_proc: process
    begin
        for i in 0 to 15 loop
            for j in 0 to 15 loop
                A <= std_logic_vector(to_unsigned(i, 4));
                B <= std_logic_vector(to_unsigned(j, 4));
                wait for 10 ns;
                assert P = std_logic_vector(to_unsigned(i * j, 8))
                    report "Multiplication error for " & integer'image(i) & " * " & integer'image(j)
                    severity error;
            end loop;
        end loop;
        wait;
    end process;
end behavior;
