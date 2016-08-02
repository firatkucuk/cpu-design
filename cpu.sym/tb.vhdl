
    --- ************************************************************************
    --- simple cpu design testbench
    --- ************************************************************************
    --- firat[at]kucuk[dot]org
    --- ************************************************************************
    --- Cts Oca 28 14:17:42 2006
    --- ************************************************************************
    --- copyleft 2005, Fırat KÜÇÜK
    --- ************************************************************************
    ---
    --- This program is free software; you can redistribute it and/or modify
    --- it under the terms of the GNU General Public License as published by
    --- the Free Software Foundation; either version 2 of the License, or
    --- (at your option) any later version.
    ---
    --- This program is distributed in the hope that it will be useful,
    --- but WITHOUT ANY WARRANTY; without even the implied warranty of
    --- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    --- GNU Library General Public License for more details.
    ---
    --- You should have received a copy of the GNU General Public License
    --- along with this program; if not, write to the Free Software
    --- Foundation, Inc., 59 Temple Place - Suite 330, Boston,
    --- MA 02111-1307, USA.
    ---
    --- ************************************************************************

---[required libraries]---------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

---[dummy entity]---------------------------------------------------------------

entity dummy_entity is
    -- dummy entity
end dummy_entity;

---[dummy architecture]---------------------------------------------------------

architecture tb_architecture of dummy_entity is

    component cpu_entity
        port(
            DEBUG  : inout std_logic;
            RD     : out   std_logic;
            WR     : out   std_logic;
            CLK    : in    std_logic;
            RST    : in    std_logic;
            DATABUS: in    std_logic_vector(7 DOWNTO 0);
            ADDRBUS: out   std_logic_vector(3 DOWNTO 0)
        );
    end component;

    signal RD, WR, CLK, RST, DEBUG: std_logic;
    signal DATABUS, ADDRBUS       : std_logic_vector(7 DOWNTO 0);
begin

    CPU: cpu_entity port map(
        DEBUG   => DEBUG,
        RD      => RD,
        WR      => WR,
        CLK     => CLK,
        RST     => RST,
        DATABUS => DATABUS,
        ADDRBUS => ADDRBUS
    );

    -- CLOCK signal generator
    process
    begin

        CLK <= '0';
        wait for 10 ns;
        CLK <= '1';
        wait for 10 ns;

    end process;


    -- initializing processor
    process
        variable reset: boolean := false;
    begin

        if reset = false then

            wait for 25 ns;

            reset := true;
            RST   <= '1';

        else
            wait until (CLK'event) and (CLK = '1');
            RST <= '0';
        end if;

    end process;


    -- memory simulation
    process(RD, CLK)
    begin

        if RD'event and RD = '1' then

            -- scenario
            --------------------------------------
            -- 00: 00 02 : JMP   02
            -- 02: 03 05 : MOVA  05
            -- 04: 01    : JMPA
            -- 05: 04 08 : MOVB  08
            -- 07: 02    : JMPB
            -- 08: 05    : ADDAB
            -- 09: 01    : JMPA
            -- 0A: 06    : NOP
            -- 0B: 06    : NOP
            -- 0C: 06    : NOP
            -- 0D: 00 00 : JMP   00
            --------------------------------------

            -- JMP  OFFSET
            if    ADDRBUS = "00000000" then DATABUS <= "00000000" after 10 ns;
            elsif ADDRBUS = "00000001" then DATABUS <= "00000010" after 10 ns;

            -- MOVA DATA
            elsif ADDRBUS = "00000010" then DATABUS <= "00000011" after 10 ns;
            elsif ADDRBUS = "00000011" then DATABUS <= "00000101" after 10 ns;

            -- JMPA
            elsif ADDRBUS = "00000100" then DATABUS <= "00000001" after 10 ns;

            -- MOVB DATA
            elsif ADDRBUS = "00000101" then DATABUS <= "00000100" after 10 ns;
            elsif ADDRBUS = "00000110" then DATABUS <= "00001000" after 10 ns;

            -- JMPB
            elsif ADDRBUS = "00000111" then DATABUS <= "00000010" after 10 ns;

            -- ADDAB
            elsif ADDRBUS = "00001000" then DATABUS <= "00000101" after 10 ns;

            -- JMPA
            elsif ADDRBUS = "00001001" then DATABUS <= "00000001" after 10 ns;

            -- NOP
            elsif ADDRBUS = "00001010" then DATABUS <= "00000110" after 10 ns;

            -- NOP
            elsif ADDRBUS = "00001011" then DATABUS <= "00000110" after 10 ns;

            -- NOP
            elsif ADDRBUS = "00001100" then DATABUS <= "00000110" after 10 ns;

            -- JMP  OFFSET
            elsif ADDRBUS = "00001101" then DATABUS <= "00000000" after 10 ns;
            elsif ADDRBUS = "00001110" then DATABUS <= "00000000" after 10 ns;

            end if;

        end if;

    end process;


end tb_architecture;






