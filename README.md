# Vending Machine - Digital Logic Design Project

A fully functional vending machine implementation in Verilog featuring state machine control, product selection, coin handling, and change calculation.

## Overview

This project implements a digital vending machine controller using Verilog HDL. The design uses a finite state machine (FSM) to manage product selection, payment processing, dispensing, and error handling. It supports multiple products with different prices, accepts various coin denominations, and calculates change automatically.

## Features

- **4 Product Selection**: Support for 4 different products (P1-P4) with configurable prices
- **Multi-Coin Support**: Accepts 10¢, 20¢, 50¢, and $1 coins
- **Automatic Change Calculation**: Computes and displays change when overpayment occurs
- **Stock Management**: Tracks inventory for each product
- **LCD Display Interface**: Shows machine status, inserted amount, and change
- **LED Status Indicators**: Visual feedback for machine state
- **Error Handling**: Detects out-of-stock and insufficient payment conditions
- **Motor Control**: Dispense signal for product delivery mechanism

## Product Pricing

| Product | Price  |
|---------|--------|
| P1      | $1.00  |
| P2      | $1.50  |
| P3      | $2.00  |
| P4      | $2.50  |

## Coin Denominations

| Coin | Value |
|------|-------|
| 10¢  | $0.10 |
| 20¢  | $0.20 |
| 50¢  | $0.50 |
| $1   | $1.00 |

## State Machine

The vending machine operates using a 5-state FSM:

```
IDLE → PRODUCT_SELECTED → WAITING_FOR_PAYMENT → DISPENSING → IDLE
                    ↓                ↓
                  ERROR ← ← ← ← ← ← ←
```

### States

1. **IDLE**: Waiting for product selection
2. **PRODUCT_SELECTED**: Product chosen, waiting for first coin
3. **WAITING_FOR_PAYMENT**: Accumulating coins until sufficient payment
4. **DISPENSING**: Dispensing product and calculating change
5. **ERROR**: Out-of-stock or insufficient payment condition

## Module Interface

### Inputs

| Signal           | Width | Description                                    |
|------------------|-------|------------------------------------------------|
| `clk`            | 1     | System clock                                   |
| `reset`          | 1     | Asynchronous reset (active high)               |
| `product_select` | 4     | One-hot encoded product selection (P1-P4)      |
| `coin_insert`    | 4     | One-hot encoded coin insertion (10¢/20¢/50¢/$1)|

### Outputs

| Signal        | Width | Description                              |
|---------------|-------|------------------------------------------|
| `lcd_display` | 8     | Status display (I/P/W/D/E)               |
| `lcd_amount`  | 8     | Total amount inserted (in cents)         |
| `lcd_change`  | 8     | Change to be returned (in cents)         |
| `dispense`    | 1     | Motor control signal for dispensing      |
| `led_status`  | 4     | LED indicators for machine status        |

### LCD Display Codes

| Code | ASCII | Meaning            |
|------|-------|--------------------|
| 0x49 | 'I'   | Idle               |
| 0x50 | 'P'   | Product Selected   |
| 0x57 | 'W'   | Waiting for Payment|
| 0x44 | 'D'   | Dispensing         |
| 0x45 | 'E'   | Error              |

## File Structure

```
Vending Machine DLD Project/
├── vending_machine.v       # Main vending machine module
├── vending_machine_tb.v    # Testbench with multiple scenarios
├── DLDVM.mpf              # ModelSim project file
└── README.md              # This file
```

## Simulation

The project includes a comprehensive testbench (`vending_machine_tb.v`) that validates the following scenarios:

### Test Scenarios

1. **Exact Payment**: Select P1 ($1.00) and insert exactly $1.00
2. **Overpayment**: Select P2 ($1.50) and insert $1.60, verify change calculation
3. **Insufficient Payment**: Select P3 ($2.00) and insert only $0.60, verify error handling
4. **Out-of-Stock**: Attempt to purchase P4 when stock is 0, verify error state
5. **Multiple Transactions**: Sequential purchases to test state transitions

### Running the Simulation

#### Using ModelSim

```bash
# Compile the design
vlog vending_machine.v vending_machine_tb.v

# Run simulation
vsim -c vending_machine_tb -do "run -all; quit"

# Or with GUI
vsim vending_machine_tb
run -all
```

#### Using Icarus Verilog

```bash
# Compile
iverilog -o vending_machine_sim vending_machine.v vending_machine_tb.v

# Run
vvp vending_machine_sim

# View waveform (if using VCD)
gtkwave dump.vcd
```

## Usage Example

### Purchasing Product 2 ($1.50)

1. **Select Product**: Set `product_select = 4'b0010` (P2)
2. **Insert Coins**:
   - Insert $1: `coin_insert = 4'b1000`
   - Insert 50¢: `coin_insert = 4'b0100`
3. **Dispense**: Machine automatically dispenses when payment is sufficient
4. **Change**: If overpaid, `lcd_change` displays the change amount

### Sample Waveform Output

```
Time: 0, State: 0, LCD: 49, Amount: 00, Change: 00, Dispense: 0, LED Status: 0000
Time: 10, State: 1, LCD: 50, Amount: 00, Change: 00, Dispense: 0, LED Status: 0000
Time: 20, State: 2, LCD: 57, Amount: 64, Change: 00, Dispense: 0, LED Status: 0000
Time: 30, State: 3, LCD: 44, Amount: 64, Change: 00, Dispense: 1, LED Status: 0000
```

## Design Considerations

### Stock Management

- Initial stock: 5 units per product
- Stock decrements automatically upon successful dispensing
- Out-of-stock condition triggers ERROR state

### Payment Logic

- Coins are accumulated in `total_inserted` register
- Payment is validated against `selected_price`
- Change = `total_inserted - selected_price`

### Reset Behavior

- Asynchronous reset clears all registers
- Returns machine to IDLE state
- Resets total_inserted to 0
- Can be used to clear ERROR state

## Synthesis Considerations

- **Clock Domain**: Single clock domain design
- **Reset Strategy**: Asynchronous reset, synchronous release
- **Registers**: All outputs are registered for timing closure
- **Combinational Logic**: Next state logic is purely combinational
- **Resource Usage**: Minimal - suitable for small FPGAs (e.g., Xilinx Spartan, Intel Cyclone)

## Known Limitations

1. **Coin Insertion Timing**: Assumes one coin per clock cycle
2. **Change Mechanism**: Displays change amount but doesn't simulate physical coin return
3. **Stock Persistence**: Stock resets to initial values on system reset
4. **Single Transaction**: Must complete or reset before starting new transaction

## Future Enhancements

- [ ] Add coin return mechanism for cancelled transactions
- [ ] Implement non-volatile stock storage
- [ ] Add 7-segment display decoder for better visualization
- [ ] Support for bill acceptor ($5, $10, $20)
- [ ] Transaction logging and sales reporting
- [ ] Keypad interface for product code entry
- [ ] Temperature sensor integration for refrigerated products
- [ ] Network connectivity for remote monitoring

## Tools & Technologies

- **HDL**: Verilog (IEEE 1364-2001)
- **Simulation**: ModelSim / Icarus Verilog
- **Synthesis**: Compatible with Xilinx Vivado, Intel Quartus
- **Target**: FPGA or ASIC implementation

## License

This project is available for educational purposes. Feel free to use and modify for learning and academic projects.

## Author

Digital Logic Design Course Project

## Acknowledgments

- Developed as part of Digital Logic Design coursework
- Implements fundamental FSM design principles
- Demonstrates practical application of sequential logic

---

**Note**: This is an educational project demonstrating digital design concepts. For production vending machines, additional safety, security, and reliability features would be required.
