
    --- ************************************************************************
    --- simple cpu design
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
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

---[cpu entity]-----------------------------------------------------------------

entity cpu_entity is
    port(
        DEBUG  : inout std_logic;
        RD     : out   std_logic;
        WR     : out   std_logic;
        CLK    : in    std_logic;
        RST    : in    std_logic;
        DATABUS: in    std_logic_vector(7 downto 0);
        ADDRBUS: out   std_logic_vector(7 downto 0)
    );

end cpu_entity;

---[cpu architecture]-----------------------------------------------------------------

architecture cpu_architecture of cpu_entity is

    shared variable initiated: boolean := false;

begin

    -- RST process
    process(RST, CLK)

        variable is_opcode   : boolean := true;
        variable last_instr  : std_logic_vector(7 downto 0);
        variable inst_pointer: std_logic_vector(7 downto 0) := "00000000";
        variable register_a  : std_logic_vector(7 downto 0) := "00000000";
        variable register_b  : std_logic_vector(7 downto 0) := "00000000";

    begin

        if RST = '1' then
            RD      <= '1';
            ADDRBUS <= "00000000";
            WR      <= '0';
        elsif CLK'event and CLK = '1' then

            RD <= '0';

            -- opcode section
            if is_opcode = true then

                is_opcode  := false;
                last_instr := DATABUS;

                -- JMP   INSTRUCTION
                if    DATABUS = "00000000" then
                    inst_pointer := std_logic_vector(signed(inst_pointer) + 1);
                    ADDRBUS      <= inst_pointer;
                    RD           <= transport '1' after 10 ns;

                -- JMPA  INSTRUCTION
                elsif DATABUS = "00000001" then
                    inst_pointer := register_a;
                    is_opcode    := true;
                    ADDRBUS      <= register_a;
                    RD           <= transport '1' after 10 ns;

                -- JMPB  INSTRUCTION
                elsif DATABUS = "00000010" then
                    inst_pointer := register_b;
                    is_opcode    := true;
                    ADDRBUS      <= register_b;
                    RD           <= transport '1' after 10 ns;

                -- MOVA  INSTRUCTION
                elsif DATABUS = "00000011" then
                    inst_pointer := std_logic_vector(signed(inst_pointer) + 1);
                    ADDRBUS      <= inst_pointer;
                    RD           <= transport '1' after 10 ns;

                -- MOVB  INSTRUCTION
                elsif DATABUS = "00000100" then
                    inst_pointer := std_logic_vector(signed(inst_pointer) + 1);
                    ADDRBUS      <= inst_pointer;
                    RD           <= transport '1' after 10 ns;

                -- ADDAB INSTRUCTION
                elsif DATABUS = "00000101" then
                    is_opcode    := true;
                    inst_pointer := std_logic_vector(signed(inst_pointer) + 1);
                    register_a   := std_logic_vector(signed(register_a) + signed(register_b));
                    ADDRBUS      <= inst_pointer;
                    RD           <= transport '1' after 10 ns;

                -- NOP   INSTRUCTION
                elsif DATABUS = "00000110" then
                    is_opcode    := true;
                    inst_pointer := std_logic_vector(signed(inst_pointer) + 1);
                    ADDRBUS      <= inst_pointer;
                    RD           <= transport '1' after 10 ns;

                end if;

            -- parameter section
            else

                is_opcode := true;

                -- JMP  INSTRUCTION
                if   last_instr = "00000000" then
                    inst_pointer := DATABUS;
                    ADDRBUS      <= inst_pointer;
                    RD           <= transport '1' after 10 ns;

                -- MOVA INSTRUCTION
                elsif last_instr = "00000011" then
                    inst_pointer := std_logic_vector(signed(inst_pointer) + 1);
                    ADDRBUS      <= inst_pointer;
                    register_a   := DATABUS;
                    RD           <= transport '1' after 10 ns;

                -- MOVB INSTRUCTION
                elsif last_instr = "00000100" then
                    inst_pointer := std_logic_vector(signed(inst_pointer) + 1);
                    ADDRBUS      <= inst_pointer;
                    register_b   := DATABUS;
                    RD           <= transport '1' after 10 ns;
                end if;

            end if; -- opcode decoding

        end if; -- RST statement

    end process;

end cpu_architecture;
