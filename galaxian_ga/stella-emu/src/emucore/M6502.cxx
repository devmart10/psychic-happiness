//============================================================================
//
// MM     MM  6666  555555  0000   2222
// MMMM MMMM 66  66 55     00  00 22  22
// MM MMM MM 66     55     00  00     22
// MM  M  MM 66666  55555  00  00  22222  --  "A 6502 Microprocessor Emulator"
// MM     MM 66  66     55 00  00 22
// MM     MM 66  66 55  55 00  00 22
// MM     MM  6666   5555   0000  222222
//
// Copyright (c) 1995-2018 by Bradford W. Mott, Stephen Anthony
// and the Stella Team
//
// See the file "License.txt" for information on usage and redistribution of
// this file, and for a DISCLAIMER OF ALL WARRANTIES.
//============================================================================

#ifdef DEBUGGER_SUPPORT
  #include "Debugger.hxx"
  #include "Expression.hxx"
  #include "CartDebug.hxx"
  #include "PackedBitArray.hxx"
  #include "TIA.hxx"
  #include "Base.hxx"
  #include "M6532.hxx"
  #include <Windows.h>

  // Flags for disassembly types
  #define DISASM_CODE  CartDebug::CODE
//   #define DISASM_GFX   CartDebug::GFX  // TODO - uncomment when needed
//   #define DISASM_PGFX  CartDebug::PGFX // TODO - uncomment when needed
  #define DISASM_DATA  CartDebug::DATA
//   #define DISASM_ROW   CartDebug::ROW  // TODO - uncomment when needed
  #define DISASM_WRITE CartDebug::WRITE
  #define DISASM_NONE  0
#else
  // Flags for disassembly types
  #define DISASM_CODE  0
//   #define DISASM_GFX   0   // TODO - uncomment when needed
//   #define DISASM_PGFX  0   // TODO - uncomment when needed
  #define DISASM_DATA  0
//   #define DISASM_ROW   0   // TODO - uncomment when needed
  #define DISASM_NONE  0
  #define DISASM_WRITE 0
#endif
#include "Settings.hxx"
#include "Vec.hxx"

#include "System.hxx"
#include "M6502.hxx"

#ifdef GENETIC_ENABLED
void printM6502inst(uInt16 pc, uInt8 inst);
void dumpRegisters(uInt8 A, uInt8 X, uInt8 Y, uInt8 SP, uInt8 IR, uInt16 PC);
#endif

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
M6502::M6502(const Settings& settings)
  : myExecutionStatus(0),
    mySystem(nullptr),
    mySettings(settings),
    A(0), X(0), Y(0), SP(0), IR(0), PC(0),
    N(false), V(false), B(false), D(false), I(false), notZ(false), C(false),
    icycles(0),
    myNumberOfDistinctAccesses(0),
    myLastAddress(0),
    myLastPeekAddress(0),
    myLastPokeAddress(0),
    myLastPeekBaseAddress(0),
    myLastPokeBaseAddress(0),
    myLastSrcAddressS(-1),
    myLastSrcAddressA(-1),
    myLastSrcAddressX(-1),
    myLastSrcAddressY(-1),
    myDataAddressForPoke(0),
    myOnHaltCallback(nullptr),
    myHaltRequested(false),
    myGhostReadsTrap(true),
    myStepStateByInstruction(false)
{
#ifdef DEBUGGER_SUPPORT
  myDebugger = nullptr;
  myJustHitReadTrapFlag = myJustHitWriteTrapFlag = false;
#endif
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void M6502::install(System& system)
{
  // Remember which system I'm installed in
  mySystem = &system;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void M6502::reset()
{
  // Clear the execution status flags
  myExecutionStatus = 0;

  // Set registers to random or default values
  bool devSettings = mySettings.getBool("dev.settings");
  const string& cpurandom = mySettings.getString(devSettings ? "dev.cpurandom" : "plr.cpurandom");
  SP = BSPF::containsIgnoreCase(cpurandom, "S") ?
          mySystem->randGenerator().next() : 0xfd;
  A  = BSPF::containsIgnoreCase(cpurandom, "A") ?
          mySystem->randGenerator().next() : 0x00;
  X  = BSPF::containsIgnoreCase(cpurandom, "X") ?
          mySystem->randGenerator().next() : 0x00;
  Y  = BSPF::containsIgnoreCase(cpurandom, "Y") ?
          mySystem->randGenerator().next() : 0x00;
  PS(BSPF::containsIgnoreCase(cpurandom, "P") ?
          mySystem->randGenerator().next() : 0x20);

  icycles = 0;

  // Load PC from the reset vector
  PC = uInt16(mySystem->peek(0xfffc)) | (uInt16(mySystem->peek(0xfffd)) << 8);

  myLastAddress = myLastPeekAddress = myLastPokeAddress = myLastPeekBaseAddress = myLastPokeBaseAddress;
  myLastSrcAddressS = myLastSrcAddressA =
    myLastSrcAddressX = myLastSrcAddressY = -1;
  myDataAddressForPoke = 0;

  myHaltRequested = false;
  myGhostReadsTrap = mySettings.getBool("dbg.ghostreadstrap");
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
inline uInt8 M6502::peek(uInt16 address, uInt8 flags)
{
  handleHalt();

  ////////////////////////////////////////////////
  // TODO - move this logic directly into CartAR
  if(address != myLastAddress)
  {
    myNumberOfDistinctAccesses++;
    myLastAddress = address;
  }
  ////////////////////////////////////////////////
  mySystem->incrementCycles(SYSTEM_CYCLES_PER_CPU);
  icycles += SYSTEM_CYCLES_PER_CPU;
  uInt8 result = mySystem->peek(address, flags);
  myLastPeekAddress = address;

#ifdef DEBUGGER_SUPPORT
  if(myReadTraps.isInitialized() && myReadTraps.isSet(address)
     && (myGhostReadsTrap || flags != DISASM_NONE))
  {
    myLastPeekBaseAddress = myDebugger->getBaseAddress(myLastPeekAddress, true); // mirror handling
    int cond = evalCondTraps();
    if(cond > -1)
    {
      myJustHitReadTrapFlag = true;
      stringstream msg;
      msg << "RTrap" << (flags == DISASM_NONE ? "G[" : "[") << Common::Base::HEX2 << cond << "]"
        << (myTrapCondNames[cond].empty() ? ": " : "If: {" + myTrapCondNames[cond] + "} ");
      myHitTrapInfo.message = msg.str();
      myHitTrapInfo.address = address;
    }
  }
#endif  // DEBUGGER_SUPPORT

  return result;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
inline void M6502::poke(uInt16 address, uInt8 value, uInt8 flags)
{
  ////////////////////////////////////////////////
  // TODO - move this logic directly into CartAR
  if(address != myLastAddress)
  {
    myNumberOfDistinctAccesses++;
    myLastAddress = address;
  }
  ////////////////////////////////////////////////
  mySystem->incrementCycles(SYSTEM_CYCLES_PER_CPU);
  icycles += SYSTEM_CYCLES_PER_CPU;
  mySystem->poke(address, value, flags);
  myLastPokeAddress = address;

#ifdef DEBUGGER_SUPPORT
  if(myWriteTraps.isInitialized() && myWriteTraps.isSet(address))
  {
    myLastPokeBaseAddress = myDebugger->getBaseAddress(myLastPokeAddress, false); // mirror handling
    int cond = evalCondTraps();
    if(cond > -1)
    {
      myJustHitWriteTrapFlag = true;
      stringstream msg;
      msg << "WTrap[" << Common::Base::HEX2 << cond << "]" << (myTrapCondNames[cond].empty() ? ": " : "If: {" + myTrapCondNames[cond] + "} ");
      myHitTrapInfo.message = msg.str();
      myHitTrapInfo.address = address;
    }
  }
#endif  // DEBUGGER_SUPPORT
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void M6502::requestHalt()
{
  if (!myOnHaltCallback) throw runtime_error("onHaltCallback not configured");
  myHaltRequested = true;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
inline void M6502::handleHalt()
{
  if (myHaltRequested) {
    myOnHaltCallback();
    myHaltRequested = false;
  }
}

void M6502::dumpMemory() {

}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
bool M6502::execute(uInt32 number)
{
  const bool status = _execute(number);

#ifdef DEBUGGER_SUPPORT
  // Debugger hack: this ensures that stepping a "STA WSYNC" will actually end at the
  // beginning of the next line (otherwise, the next instruction would be stepped in order for
  // the halt to take effect). This is safe because as we know that the next cycle will be a read
  // cycle anyway.
  handleHalt();

  // Make sure that the hardware state matches the current system clock. This is necessary
  // to maintain a consistent state for the debugger after stepping.
  mySystem->tia().updateEmulation();
  mySystem->m6532().updateEmulation();
#endif

  return status;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
inline bool M6502::_execute(uInt32 number)
{
  // Clear all of the execution status bits except for the fatal error bit
  myExecutionStatus &= FatalErrorBit;

#ifdef DEBUGGER_SUPPORT
  TIA& tia = mySystem->tia();
  M6532& riot = mySystem->m6532();
#endif

<<<<<<< HEAD
=======
#ifdef GENETIC_ENABLED
  /*
  uInt8 _6000 = myPeek(0x6000, 0);
  if (_6000) {
	  printf("0x6000: %x\n", _6000);
	  printf(" - coin1: %d\n", _6000 & 0x1 ? 1 : 0);
	  printf(" - coin2: %d\n", _6000 & 0x2 ? 1 : 0);
	  printf(" - p1 left: %d\n", _6000 & 0x4 ? 1 : 0);
	  printf(" - p1 right: %d\n", _6000 & 0x8 ? 1 : 0);
	  printf(" - p1 shoot: %d\n", _6000 & 0x10 ? 1 : 0);
	  printf(" - table ??: %d\n", _6000 & 0x20 ? 1 : 0);
	  printf(" - test: %d\n", _6000 & 0x40 ? 1 : 0);
	  printf(" - service: %d\n", _6000 & 0x80 ? 1 : 0);
  }

  uInt8 _6800 = myPeek(0x6800, 0);
  if (_6800) {
	  printf("0x6800: %x\n", _6800);
	  printf(" - p1 start: %d\n", _6800 & 0x1 ? 1 : 0);
	  printf(" - p2 start: %d\n", _6800 & 0x2 ? 1 : 0);
	  printf(" - p2 left: %d\n", _6800 & 0x4 ? 1 : 0);
	  printf(" - p2 right: %d\n", _6800 & 0x8 ? 1 : 0);
	  printf(" - p2 shoot: %d\n", _6800 & 0x10 ? 1 : 0);
	  printf(" - unused: %d\n", _6800 & 0x20 ? 1 : 0);
	  printf(" - dip sw1: %d\n", _6800 & 0x40 ? 1 : 0);
	  printf(" - dip sw2: %d\n", _6800 & 0x80 ? 1 : 0);
  }

  uInt8 _823c = myPeek(0x823c, 0);
  if (_823c == 0) {
	  printf("0x823c: %x\n", _823c);
  }
  */

  for (uInt32 i = 0x80; i < 0x100; i = i + 0x0002) {
	  uInt16 low = myPeek(i, DISASM_CODE);
	  uInt16 high = (uInt16(myPeek(i + 1, DISASM_CODE)) << 8);
	  uInt16 intermediate = high | uInt8(low);

	  if (intermediate == 390) {
			// printf("390 at %x\n", i);
	  }
	  // printf("----------------\n");
  }
#endif

>>>>>>> 2ecff67b40f262560b4e45a5844f8c13924840e6
  // Loop until execution is stopped or a fatal error occurs
  for(;;)
  {
    for(; !myExecutionStatus && (number != 0); --number)
    {
  #ifdef DEBUGGER_SUPPORT
      if(myJustHitReadTrapFlag || myJustHitWriteTrapFlag)
      {
        bool read = myJustHitReadTrapFlag;
        myJustHitReadTrapFlag = myJustHitWriteTrapFlag = false;

        if (startDebugger(myHitTrapInfo.message, myHitTrapInfo.address, read)) return true;
      }

      if(myBreakPoints.isInitialized() && myBreakPoints.isSet(PC) && startDebugger("BP: ", PC))
        return true;

      int cond = evalCondBreaks();
      if(cond > -1)
      {
        stringstream msg;
        msg << "CBP[" << Common::Base::HEX2 << cond << "]: " << myCondBreakNames[cond];
        if (startDebugger(msg.str())) return true;
      }

      cond = evalCondSaveStates();
      if(cond > -1)
      {
        stringstream msg;
        msg << "conditional savestate [" << Common::Base::HEX2 << cond << "]";
        myDebugger->addState(msg.str());
      }
  #endif  // DEBUGGER_SUPPORT

      uInt16 operandAddress = 0, intermediateAddress = 0;
      uInt8 operand = 0;

      // Reset the peek/poke address pointers
      myLastPeekAddress = myLastPokeAddress = myDataAddressForPoke = 0;

      icycles = 0;
      // Fetch instruction at the program counter
      IR = peek(PC++, DISASM_CODE);  // This address represents a code section

      // Call code to execute the instruction
      switch(IR)
      {
        // 6502 instruction emulation is generated by an M4 macro file
        #include "M6502.ins"

        default:
          // Oops, illegal instruction executed so set fatal error flag
          myExecutionStatus |= FatalErrorBit;
      }

  #ifdef DEBUGGER_SUPPORT
      if(myStepStateByInstruction)
      {
        // Check out M6502::execute for an explanation.
        handleHalt();

        tia.updateEmulation();
        riot.updateEmulation();
      }
  #endif
    }

    // See if we need to handle an interrupt
    if((myExecutionStatus & MaskableInterruptBit) ||
        (myExecutionStatus & NonmaskableInterruptBit))
    {
      // Yes, so handle the interrupt
      interruptHandler();
    }

    // See if execution has been stopped
    if(myExecutionStatus & StopExecutionBit)
    {
      // Yes, so answer that everything finished fine
      return true;
    }

    // See if a fatal error has occured
    if(myExecutionStatus & FatalErrorBit)
    {
      // Yes, so answer that something when wrong
      return false;
    }

    // See if we've executed the specified number of instructions
    if(number == 0)
    {
      // Yes, so answer that everything finished fine
      return true;
    }
  }
}

#ifdef GENETIC_ENABLED
void printM6502inst(uInt16 pc, uInt8 inst) {
	uInt8 A = inst >> 5;
	uInt8 B = (inst & 0x1C) >> 2;
	uInt8 C = inst & 0x3;

	printf("PC: %X, IR: ", pc);

	switch (A) {
		case 0:
			switch (C) {
			case 0:
				switch (B) {
				case 0:
					printf("BRK impl\n");
					break;
				case 2:
					printf("PHP impl\n");
					break;
				case 4:
					printf("BPL rel\n");
					break;
				case 6:
					printf("CLC impl\n");
					break;
				}
				break;
			case 1:
				switch (B) {
				case 0:
					printf("ORA X, ind\n");
					break;
				case 1:
					printf("ORA zpg\n");
					break;
				case 2:
					printf("ORA #\n");
					break;
				case 3:
					printf("ORA abs\n");
					break;
				case 4:
					printf("ORA ind, Y\n");
					break;
				case 5:
					printf("ORA zpg, X\n");
					break;
				case 6:
					printf("ORA abs, Y\n");
					break;
				case 7:
					printf("ORA abs, X\n");
					break;
				}
				break;
			case 2:
				switch (B) {
				case 1:
					printf("ASL zpg\n");
					break;
				case 2:
					printf("ASL A\n");
					break;
				case 3:
					printf("ASL abs\n");
					break;
				case 5:
					printf("ASL zpg, X\n");
					break;
				case 7:
					printf("ASL abs, X\n");
					break;
				}
				break;
			}
			break;
		case 1:
			switch (C) {
			case 0:
				switch (B) {
				case 0:
					printf("JSR abs\n");
					break;
				case 1:
					printf("BIT zpg\n");
					break;
				case 2:
					printf("PLP impl\n");
					break;
				case 3:
					printf("BIT abs\n");
					break;
				case 4:
					printf("BMI rel\n");
					break;
				case 6:
					printf("SEC impl\n");
					break;
				}
				break;
			case 1:
				switch (B) {
				case 0:
					printf("AND X, ind\n");
					break;
				case 1:
					printf("AND zpg\n");
					break;
				case 2:
					printf("AND #\n");
					break;
				case 3:
					printf("AND abs\n");
					break;
				case 4:
					printf("AND ind, Y\n");
					break;
				case 5:
					printf("AND zpg, X\n");
					break;
				case 6:
					printf("AND abs, Y\n");
					break;
				case 7:
					printf("AND abs, X\n");
					break;
				}
				break;
			case 2:
				switch (B) {
				case 1:
					printf("ROL zpg\n");
					break;
				case 2:
					printf("ROL A\n");
					break;
				case 3:
					printf("ROL abs\n");
					break;
				case 5:
					printf("ROL zpg, X\n");
					break;
				case 7:
					printf("ROL abs, X\n");
					break;
				}
				break;
			}
			break;
		case 2:
			switch (C) {
			case 0:
				switch (B) {
				case 0:
					printf("RTI impl\n");
					break;
				case 2:
					printf("PHA impl\n");
					break;
				case 3:
					printf("JMP abs\n");
					break;
				case 4:
					printf("BVC rel\n");
					break;
				case 6:
					printf("CLI impl\n");
					break;
				}
				break;
			case 1:
				switch (B) {
				case 0:
					printf("EOR X, ind\n");
					break;
				case 1:
					printf("EOR zpg\n");
					break;
				case 2:
					printf("EOR #\n");
					break;
				case 3:
					printf("EOR abs\n");
					break;
				case 4:
					printf("EOR ind, Y\n");
					break;
				case 5:
					printf("EOR zpg, X\n");
					break;
				case 6:
					printf("EOR abs, Y\n");
					break;
				case 7:
					printf("EOR abs, X\n");
					break;
				}
				break;
			case 2:
				switch (B) {
				case 1:
					printf("LSR zpg\n");
					break;
				case 2:
					printf("LSR A\n");
					break;
				case 3:
					printf("LSR abs\n");
					break;
				case 5:
					printf("LSR zpg, X\n");
					break;
				case 7:
					printf("LSR abs, X\n");
					break;
				}
				break;
			}
			break;
		case 3:
			switch (C) {
			case 0:
				switch (B) {
				case 0:
					printf("RTS impl\n");
					break;
				case 2:
					printf("PLA impl\n");
					break;
				case 3:
					printf("JMP ind\n");
					break;
				case 4:
					printf("BVS rel\n");
					break;
				case 6:
					printf("SEI impl\n");
					break;
				}
				break;
			case 1:
				switch (B) {
				case 0:
					printf("ADC X, ind\n");
					break;
				case 1:
					printf("ADC zpg\n");
					break;
				case 2:
					printf("ADC #\n");
					break;
				case 3:
					printf("ADC abs\n");
					break;
				case 4:
					printf("ADC ind, Y\n");
					break;
				case 5:
					printf("ADC zpg, X\n");
					break;
				case 6:
					printf("ADC abs, Y\n");
					break;
				case 7:
					printf("ADC abs, X\n");
					break;
				}
				break;
			case 2:
				switch (B) {
				case 1:
					printf("ROR zpg\n");
					break;
				case 2:
					printf("ROR A\n");
					break;
				case 3:
					printf("ROR abs\n");
					break;
				case 5:
					printf("ROR zpg, X\n");
					break;
				case 7:
					printf("ROR abs, X\n");
					break;
				}
				break;
			}
			break;
		case 4:
			switch (C) {
			case 0:
				switch (B) {
				case 1:
					printf("STY zpg\n");
					break;
				case 2:
					printf("DEY impl\n");
					break;
				case 3:
					printf("STY abs\n");
					break;
				case 4:
					printf("BCC rel\n");
					break;
				case 5:
					printf("STY zpg, X\n");
					break;
				case 6:
					printf("TYA implm\n");
					break;
				}
				break;
			case 1:
				switch (B) {
				case 0:
					printf("STA X, ind\n");
					break;
				case 1:
					printf("STA zpg\n");
					break;
				case 3:
					printf("STA abs\n");
					break;
				case 4:
					printf("STA ind, Y\n");
					break;
				case 5:
					printf("STA zpg, X\n");
					break;
				case 6:
					printf("STA abs, Y\n");
					break;
				case 7:
					printf("STA abs, X\n");
					break;
				}
				break;
			case 2:
				switch (B) {
				case 1:
					printf("ROR zpg\n");
					break;
				case 2:
					printf("ROR A\n");
					break;
				case 3:
					printf("ROR abs\n");
					break;
				case 5:
					printf("ROR zpg, X\n");
					break;
				case 7:
					printf("ROR abs, X\n");
					break;
				}
				break;
			}
			break;
		case 5:
			switch (C) {
			case 0:
				switch (B) {
				case 0:
					printf("LDY #\n");
					break;
				case 1:
					printf("LDY zpg\n");
					break;
				case 2:
					printf("TAY impl\n");
					break;
				case 3:
					printf("LDY abs\n");
					break;
				case 4:
					printf("BCS rel\n");
					break;
				case 5:
					printf("LDY zpg, X\n");
					break;
				case 6:
					printf("CLV impl\n");
					break;
				case 7:
					printf("LDY abs, X\n");
					break;
				}
				break;
			case 1:
				switch (B) {
				case 0:
					printf("LDA X, ind\n");
					break;
				case 1:
					printf("LDA zpg\n");
					break;
				case 2:
					printf("LDA #\n");
					break;
				case 3:
					printf("LDA abs\n");
					break;
				case 4:
					printf("LDA ind, Y\n");
					break;
				case 5:
					printf("LDA zpg, X\n");
					break;
				case 6:
					printf("LDA abs, Y\n");
					break;
				case 7:
					printf("LDA abs, X\n");
					break;
				}
				break;
			case 2:
				switch (B) {
				case 0:
					printf("LDX #\n");
					break;
				case 1:
					printf("LDX zpg\n");
					break;
				case 2:
					printf("TAX impl\n");
					break;
				case 3:
					printf("LDX abs\n");
					break;
				case 5:
					printf("LDX zpg, Y\n");
					break;
				case 6:
					printf("TSX impl\n");
					break;
				case 7:
					printf("LDX abs, Y\n");
					break;
				}
				break;
			}
			break;
		case 6:
			switch (C) {
			case 0:
				switch (B) {
				case 0:
					printf("CPY #\n");
					break;
				case 1:
					printf("CPY zpg\n");
					break;
				case 2:
					printf("INY impl\n");
					break;
				case 3:
					printf("CPY abs\n");
					break;
				case 4:
					printf("BNE rel\n");
					break;
				case 6:
					printf("CLD impl\n");
					break;
				}
				break;
			case 1:
				switch (B) {
				case 0:
					printf("CMP X, ind\n");
					break;
				case 1:
					printf("CMP zpg\n");
					break;
				case 2:
					printf("CMP #\n");
					break;
				case 3:
					printf("CMP abs\n");
					break;
				case 4:
					printf("CMP ind, Y\n");
					break;
				case 5:
					printf("CMP zpg, X\n");
					break;
				case 6:
					printf("CMP abs, Y\n");
					break;
				case 7:
					printf("CMP abs, X\n");
					break;
				}
				break;
			case 2:
				switch (B) {
				case 1:
					printf("DEC zpg\n");
					break;
				case 2:
					printf("DEX impl\n");
					break;
				case 3:
					printf("DEC abs\n");
					break;
				case 5:
					printf("DEC zpg, X\n");
					break;
				case 7:
					printf("DEC abs, Y\n");
					break;
				}
				break;
			}
			break;
		case 7:
			switch (C) {
			case 0:
				switch (B) {
				case 0:
					printf("CPX #\n");
					break;
				case 1:
					printf("CPX zpg\n");
					break;
				case 2:
					printf("INX impl\n");
					break;
				case 3:
					printf("CPX abs\n");
					break;
				case 4:
					printf("BEQ rel\n");
					break;
				case 6:
					printf("SED impl\n");
					break;
				}
				break;
			case 1:
				switch (B) {
				case 0:
					printf("SBC X, ind\n");
					break;
				case 1:
					printf("SBC zpg\n");
					break;
				case 2:
					printf("SBC #\n");
					break;
				case 3:
					printf("SBC abs\n");
					break;
				case 4:
					printf("SBC ind, Y\n");
					break;
				case 5:
					printf("SBC zpg, X\n");
					break;
				case 6:
					printf("SBC abs, Y\n");
					break;
				case 7:
					printf("SBC abs, X\n");
					break;
				}
				break;
			case 2:
				switch (B) {
				case 1:
					printf("INC zpg\n");
					break;
				case 2:
					printf("NOP impl\n");
					break;
				case 3:
					printf("INC abs\n");
					break;
				case 5:
					printf("INC zpg, X\n");
					break;
				case 7:
					printf("INC abs, X\n");
					break;
				}
				break;
			}
			break;
	}
}

void dumpRegisters(uInt8 A, uInt8 X, uInt8 Y, uInt8 SP, uInt8 IR, uInt16 PC) {
	printf("  A: %X\n  X: %X\n  Y: %X\n  SP: %X\n  IR: %X\n  PC: %X\n", A, X, Y, SP, IR, PC);
}
#endif

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void M6502::interruptHandler()
{
  // Handle the interrupt
  if((myExecutionStatus & MaskableInterruptBit) && !I)
  {
    mySystem->incrementCycles(7 * SYSTEM_CYCLES_PER_CPU);
    mySystem->poke(0x0100 + SP--, (PC - 1) >> 8);
    mySystem->poke(0x0100 + SP--, (PC - 1) & 0x00ff);
    mySystem->poke(0x0100 + SP--, PS() & (~0x10));
    D = false;
    I = true;
    PC = uInt16(mySystem->peek(0xFFFE)) | (uInt16(mySystem->peek(0xFFFF)) << 8);
  }
  else if(myExecutionStatus & NonmaskableInterruptBit)
  {
    mySystem->incrementCycles(7 * SYSTEM_CYCLES_PER_CPU);
    mySystem->poke(0x0100 + SP--, (PC - 1) >> 8);
    mySystem->poke(0x0100 + SP--, (PC - 1) & 0x00ff);
    mySystem->poke(0x0100 + SP--, PS() & (~0x10));
    D = false;
    PC = uInt16(mySystem->peek(0xFFFA)) | (uInt16(mySystem->peek(0xFFFB)) << 8);
  }

  // Clear the interrupt bits in myExecutionStatus
  myExecutionStatus &= ~(MaskableInterruptBit | NonmaskableInterruptBit);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
bool M6502::save(Serializer& out) const
{
  const string& CPU = name();

  try
  {
    out.putString(CPU);

    out.putByte(A);    // Accumulator
    out.putByte(X);    // X index register
    out.putByte(Y);    // Y index register
    out.putByte(SP);   // Stack Pointer
    out.putByte(IR);   // Instruction register
    out.putShort(PC);  // Program Counter

    out.putBool(N);    // N flag for processor status register
    out.putBool(V);    // V flag for processor status register
    out.putBool(B);    // B flag for processor status register
    out.putBool(D);    // D flag for processor status register
    out.putBool(I);    // I flag for processor status register
    out.putBool(notZ); // Z flag complement for processor status register
    out.putBool(C);    // C flag for processor status register

    out.putByte(myExecutionStatus);

    // Indicates the number of distinct memory accesses
    out.putInt(myNumberOfDistinctAccesses);
    // Indicates the last address(es) which was accessed
    out.putShort(myLastAddress);
    out.putShort(myLastPeekAddress);
    out.putShort(myLastPokeAddress);
    out.putShort(myDataAddressForPoke);
    out.putInt(myLastSrcAddressS);
    out.putInt(myLastSrcAddressA);
    out.putInt(myLastSrcAddressX);
    out.putInt(myLastSrcAddressY);

    out.putBool(myHaltRequested);
    out.putBool(myStepStateByInstruction);
    out.putBool(myGhostReadsTrap);
  }
  catch(...)
  {
    cerr << "ERROR: M6502::save" << endl;
    return false;
  }

  return true;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
bool M6502::load(Serializer& in)
{
  const string& CPU = name();

  try
  {
    if(in.getString() != CPU)
      return false;

    A = in.getByte();    // Accumulator
    X = in.getByte();    // X index register
    Y = in.getByte();    // Y index register
    SP = in.getByte();   // Stack Pointer
    IR = in.getByte();   // Instruction register
    PC = in.getShort();  // Program Counter

    N = in.getBool();    // N flag for processor status register
    V = in.getBool();    // V flag for processor status register
    B = in.getBool();    // B flag for processor status register
    D = in.getBool();    // D flag for processor status register
    I = in.getBool();    // I flag for processor status register
    notZ = in.getBool(); // Z flag complement for processor status register
    C = in.getBool();    // C flag for processor status register

    myExecutionStatus = in.getByte();

    // Indicates the number of distinct memory accesses
    myNumberOfDistinctAccesses = in.getInt();
    // Indicates the last address(es) which was accessed
    myLastAddress = in.getShort();
    myLastPeekAddress = in.getShort();
    myLastPokeAddress = in.getShort();
    myDataAddressForPoke = in.getShort();
    myLastSrcAddressS = in.getInt();
    myLastSrcAddressA = in.getInt();
    myLastSrcAddressX = in.getInt();
    myLastSrcAddressY = in.getInt();

    myHaltRequested = in.getBool();
    myStepStateByInstruction = in.getBool();
    myGhostReadsTrap = in.getBool();
  }
  catch(...)
  {
    cerr << "ERROR: M6502::load" << endl;
    return false;
  }

  return true;
}

#ifdef DEBUGGER_SUPPORT
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void M6502::attach(Debugger& debugger)
{
  // Remember the debugger for this microprocessor
  myDebugger = &debugger;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
uInt32 M6502::addCondBreak(Expression* e, const string& name)
{
  myCondBreaks.emplace_back(e);
  myCondBreakNames.push_back(name);

  updateStepStateByInstruction();

  return uInt32(myCondBreaks.size() - 1);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
bool M6502::delCondBreak(uInt32 idx)
{
  if(idx < myCondBreaks.size())
  {
    Vec::removeAt(myCondBreaks, idx);
    Vec::removeAt(myCondBreakNames, idx);

    updateStepStateByInstruction();

    return true;
  }
  return false;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void M6502::clearCondBreaks()
{
  myCondBreaks.clear();
  myCondBreakNames.clear();

  updateStepStateByInstruction();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
const StringList& M6502::getCondBreakNames() const
{
  return myCondBreakNames;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
uInt32 M6502::addCondSaveState(Expression* e, const string& name)
{
  myCondSaveStates.emplace_back(e);
  myCondSaveStateNames.push_back(name);

  updateStepStateByInstruction();

  return uInt32(myCondSaveStates.size() - 1);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
bool M6502::delCondSaveState(uInt32 idx)
{
  if(idx < myCondSaveStates.size())
  {
    Vec::removeAt(myCondSaveStates, idx);
    Vec::removeAt(myCondSaveStateNames, idx);

    updateStepStateByInstruction();

    return true;
  }
  return false;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void M6502::clearCondSaveStates()
{
  myCondSaveStates.clear();
  myCondSaveStateNames.clear();

  updateStepStateByInstruction();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
const StringList& M6502::getCondSaveStateNames() const
{
  return myCondSaveStateNames;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
uInt32 M6502::addCondTrap(Expression* e, const string& name)
{
  myTrapConds.emplace_back(e);
  myTrapCondNames.push_back(name);

  updateStepStateByInstruction();

  return uInt32(myTrapConds.size() - 1);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
bool M6502::delCondTrap(uInt32 brk)
{
  if(brk < myTrapConds.size())
  {
    Vec::removeAt(myTrapConds, brk);
    Vec::removeAt(myTrapCondNames, brk);

    updateStepStateByInstruction();

    return true;
  }
  return false;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void M6502::clearCondTraps()
{
  myTrapConds.clear();
  myTrapCondNames.clear();

  updateStepStateByInstruction();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
const StringList& M6502::getCondTrapNames() const
{
  return myTrapCondNames;
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
void M6502::updateStepStateByInstruction()
{
  myStepStateByInstruction = myCondBreaks.size() || myCondSaveStates.size() ||
                             myTrapConds.size();
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
bool M6502::startDebugger(const string& message, int address, bool read)
{
  handleHalt();

  mySystem->tia().updateEmulation();
  mySystem->m6532().updateEmulation();

  return myDebugger->start(message, address, read);
}

#endif  // DEBUGGER_SUPPORT
