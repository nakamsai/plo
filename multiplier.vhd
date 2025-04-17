library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- AND Gate
entity and_gate is
    Port ( A, B : in STD_LOGIC;
           Y    : out STD_LOGIC);
end and_gate;

architecture Behavioral of and_gate is
begin
    Y <= A and B;
end Behavioral;

-- OR Gate
entity or_gate is
    Port ( A, B : in STD_LOGIC;
           Y    : out STD_LOGIC);
end or_gate;

architecture Behavioral of or_gate is
begin
    Y <= A or B;
end Behavioral;

-- NOT Gate
entity not_gate is
    Port ( A : in STD_LOGIC;
           Y : out STD_LOGIC);
end not_gate;

architecture Behavioral of not_gate is
begin
    Y <= not A;
end Behavioral;

-- XOR Gate (built using NOT, AND, OR gates)
entity xor_gate is
    Port ( A, B : in STD_LOGIC;
           Y    : out STD_LOGIC);
end xor_gate;

architecture Structural of xor_gate is
    signal nA, nB, A_and_nB, nA_and_B: STD_LOGIC;
begin
    U1: entity work.not_gate port map(A => A, Y => nA);
    U2: entity work.not_gate port map(A => B, Y => nB);
    U3: entity work.and_gate port map(A => A, B => nB, Y => A_and_nB);
    U4: entity work.and_gate port map(A => nA, B => B, Y => nA_and_B);
    U5: entity work.or_gate port map(A => A_and_nB, B => nA_and_B, Y => Y);
end Structural;

-- Half Adder (SUM = A XOR B, CARRY = A AND B)
entity half_adder is
    Port ( A, B : in STD_LOGIC;
           SUM, CARRY : out STD_LOGIC);
end half_adder;

architecture Structural of half_adder is
begin
    U1: entity work.xor_gate port map(A => A, B => B, Y => SUM);
    U2: entity work.and_gate port map(A => A, B => B, Y => CARRY);
end Structural;

-- Full Adder (SUM = A XOR B XOR Cin, Cout = (A AND B) OR (Cin AND (A XOR B)))
entity full_adder is
    Port ( A, B, Cin : in STD_LOGIC;
           SUM, Cout : out STD_LOGIC);
end full_adder;

architecture Structural of full_adder is
    signal S1, C1, C2: STD_LOGIC;
begin
    U1: entity work.xor_gate port map(A => A, B => B, Y => S1);
    U2: entity work.xor_gate port map(A => S1, B => Cin, Y => SUM);
    U3: entity work.and_gate port map(A => S1, B => Cin, Y => C1);
    U4: entity work.and_gate port map(A => A, B => B, Y => C2);
    U5: entity work.or_gate port map(A => C1, B => C2, Y => Cout);
end Structural;

-- 4×4 Parallel Multiplier (using partial products and adder tree)
entity parallel_multiplier is
    Port ( A, B : in STD_LOGIC_VECTOR(3 downto 0);
           P    : out STD_LOGIC_VECTOR(7 downto 0));
end parallel_multiplier;

architecture Structural of parallel_multiplier is
    signal pp : STD_LOGIC_VECTOR(15 downto 0); -- Partial products (4×4 = 16)
    signal s  : STD_LOGIC_VECTOR(5 downto 0);  -- Sum signals
    signal c  : STD_LOGIC_VECTOR(9 downto 0);  -- Carry signals
begin
    -- Generate partial products (A[i] AND B[j])
    pp(0)  <= A(0) and B(0);  pp(1) <= A(0) and B(1);  pp(2)  <= A(0) and B(2);  pp(3)  <= A(0) and B(3);
    pp(4)  <= A(1) and B(0);  pp(5) <= A(1) and B(1);  pp(6)  <= A(1) and B(2);  pp(7)  <= A(1) and B(3);
    pp(8)  <= A(2) and B(0);  pp(9) <= A(2) and B(1);  pp(10) <= A(2) and B(2);  pp(11) <= A(2) and B(3);
    pp(12) <= A(3) and B(0);  pp(13) <= A(3) and B(1); pp(14) <= A(3) and B(2);  pp(15) <= A(3) and B(3);

    -- Adder tree to sum partial products
    HA1: entity work.half_adder port map(A => pp(1), B => pp(4), SUM => s(0), CARRY => c(0));
    FA1: entity work.full_adder port map(A => pp(2), B => pp(5), Cin => pp(8), SUM => s(1), Cout => c(1));
    FA2: entity work.full_adder port map(A => pp(3), B => pp(6), Cin => pp(9), SUM => s(2), Cout => c(2));
    FA3: entity work.full_adder port map(A => pp(7), B => pp(10), Cin => pp(12), SUM => s(3), Cout => c(3));
    FA4: entity work.full_adder port map(A => pp(11), B => pp(13), Cin => c(3), SUM => s(4), Cout => c(4));
    FA5: entity work.full_adder port map(A => pp(14), B => pp(15), Cin => c(4), SUM => s(5), Cout => c(5));

    -- Final product assembly
    P(0) <= pp(0);  -- LSB
    P(1) <= s(0);
    FA6: entity work.full_adder port map(A => s(1), B => c(0), Cin => '0', SUM => P(2), Cout => c(6));
    FA7: entity work.full_adder port map(A => s(2), B => c(1), Cin => c(6), SUM => P(3), Cout => c(7));
    FA8: entity work.full_adder port map(A => s(3), B => c(2), Cin => c(7), SUM => P(4), Cout => c(8));
    FA9: entity work.full_adder port map(A => s(4), B => c(8), Cin => c(5), SUM => P(5), Cout => c(9));
    FA10: entity work.full_adder port map(A => s(5), B => '0', Cin => c(9), SUM => P(6), Cout => P(7));  -- MSB
end Structural;
