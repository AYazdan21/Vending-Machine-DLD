module vending_machine_tb;
    reg clk;
    reg reset;
    reg [3:0] product_select;
    reg [3:0] coin_insert;
    wire [7:0] lcd_display;
    wire [7:0] lcd_amount;
    wire [7:0] lcd_change;
    wire dispense;
    wire [3:0] led_status;

    vending_machine uut (
        .clk(clk),
        .reset(reset),
        .product_select(product_select),
        .coin_insert(coin_insert),
        .lcd_display(lcd_display),
        .lcd_amount(lcd_amount),
        .lcd_change(lcd_change),
        .dispense(dispense),
        .led_status(led_status)
    );

    initial begin
        // Initialize signals
        clk = 0;
        reset = 1;
        product_select = 4'b0000;
        coin_insert = 4'b0000;

        // Reset the system
        #10 reset = 0;

        // Scenario 1: Select Product 1 and insert exact amount
        #10 product_select = 4'b0001;  // Select P1
        #10 product_select = 4'b0000;  // Deselect
        #10 coin_insert = 4'b1000;     // Insert $1
        #10 coin_insert = 4'b0000;
        #20;  // Wait for dispensing
        #10 reset = 1;
        #10 reset = 0;

        // Scenario 2: Select Product 2 and insert more than required amount
        #10 product_select = 4'b0010;  // Select P2
        #10 product_select = 4'b0000;
        #10 coin_insert = 4'b1000;     // Insert $1
        #10 coin_insert = 4'b0000;
        #10 coin_insert = 4'b0100;     // Insert 50¢
        #10 coin_insert = 4'b0000;
        #10 coin_insert = 4'b0001;     // Insert 10¢ (Excess)
        #10 coin_insert = 4'b0000;
        #20;  // Wait for dispensing
        #10 reset = 1;
        #10 reset = 0;

        // Scenario 3: Select Product 3 and insert insufficient amount
        #10 product_select = 4'b0100;  // Select P3
        #10 product_select = 4'b0000;
        #10 coin_insert = 4'b0100;     // Insert 50¢
        #10 coin_insert = 4'b0000;
        #10 coin_insert = 4'b0001;     // Insert 10¢
        #10 coin_insert = 4'b0000;
        #20;  // Wait to check for error
        #10 reset = 1;
        #10 reset = 0;

        // Scenario 4: Out-of-stock condition
        // Simulating by setting the stock of Product 4 to 0
        uut.stock[3] = 0;
        #10 product_select = 4'b1000;  // Select P4 (out of stock)
        #10 product_select = 4'b0000;
        #20;  // Wait to check for error
        #10 reset = 1;
        #10 reset = 0;

        // Scenario 5: Multiple products and payments
        #10 product_select = 4'b0001;  // Select P1
        #10 product_select = 4'b0000;
        #10 coin_insert = 4'b1000;     // Insert $1
        #10 coin_insert = 4'b0000;
        #20;  // Wait for dispensing
        #10 reset = 1;
        #10 reset = 0;
        
        #10 product_select = 4'b0010;  // Select P2
        #10 product_select = 4'b0000;
        #10 coin_insert = 4'b0100;     // Insert 50¢
        #10 coin_insert = 4'b0000;
        #10 coin_insert = 4'b1000;     // Insert $1
        #10 coin_insert = 4'b0000;
        #20;  // Wait for dispensing

        $finish;
    end

    always #5 clk = ~clk;

    // Display outputs
    always @(posedge clk) begin
        $display("Time: %0t, State: %d, LCD: %h, Amount: %h, Change: %h, Dispense: %b, LED Status: %b, Total Inserted: %d", 
            $time, uut.current_state, lcd_display, lcd_amount, lcd_change, dispense, led_status, uut.total_inserted);
    end
endmodule

