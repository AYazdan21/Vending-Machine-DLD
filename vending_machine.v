module vending_machine (
    input wire clk,
    input wire reset,
    input wire [3:0] product_select,  // P1, P2, P3, P4
    input wire [3:0] coin_insert,     // 10¢, 20¢, 50¢, $1
    output reg [7:0] lcd_display,     // LCD display for status
    output reg [7:0] lcd_amount,      // LCD display for inserted amount
    output reg [7:0] lcd_change,      // LCD display for change to be returned
    output reg dispense,              // Motor control for dispensing items
    output reg [3:0] led_status       // LEDs for status
);

    // State definitions
    parameter IDLE = 3'b000;
    parameter PRODUCT_SELECTED = 3'b001;
    parameter WAITING_FOR_PAYMENT = 3'b010;
    parameter DISPENSING = 3'b011;
    parameter ERROR = 3'b100;

    reg [2:0] current_state;
    reg [2:0] next_state;

    // Product prices (in cents)
    parameter PRICE_P1 = 100;
    parameter PRICE_P2 = 150;
    parameter PRICE_P3 = 200;
    parameter PRICE_P4 = 250;

    // Coin values (in cents)
    parameter COIN_10C = 10;
    parameter COIN_20C = 20;
    parameter COIN_50C = 50;
    parameter COIN_1D = 100;

    reg [7:0] total_inserted;
    reg [7:0] selected_price;
    reg [3:0] stock [3:0];  // Stock for P1, P2, P3, P4

    // Initial stock levels
    initial begin
        stock[0] = 5;
        stock[1] = 5;
        stock[2] = 5;
        stock[3] = 5;
    end

    // State machine
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= IDLE;
            total_inserted <= 0;
            lcd_display <= 8'h00;
            lcd_amount <= 8'h00;
            lcd_change <= 8'h00;
            dispense <= 0;
            led_status <= 4'b0000;
        end else begin
            current_state <= next_state;
        end
    end

    // Next state logic
    always @(*) begin
        next_state = current_state;
        case (current_state)
            IDLE: begin
                if (product_select != 4'b0000) begin
                    case (product_select)
                        4'b0001: if (stock[0] > 0) selected_price = PRICE_P1; else next_state = ERROR;
                        4'b0010: if (stock[1] > 0) selected_price = PRICE_P2; else next_state = ERROR;
                        4'b0100: if (stock[2] > 0) selected_price = PRICE_P3; else next_state = ERROR;
                        4'b1000: if (stock[3] > 0) selected_price = PRICE_P4; else next_state = ERROR;
                        default: selected_price = 0;
                    endcase
                    if (next_state != ERROR)
                        next_state = PRODUCT_SELECTED;
                end
            end
            PRODUCT_SELECTED: begin
                if (coin_insert != 4'b0000) begin
                    case (coin_insert)
                        4'b0001: total_inserted = total_inserted + COIN_10C;
                        4'b0010: total_inserted = total_inserted + COIN_20C;
                        4'b0100: total_inserted = total_inserted + COIN_50C;
                        4'b1000: total_inserted = total_inserted + COIN_1D;
                        default: total_inserted = total_inserted;
                    endcase
                    next_state = WAITING_FOR_PAYMENT;
                end
            end
            WAITING_FOR_PAYMENT: begin
                if (total_inserted >= selected_price) begin
                    next_state = DISPENSING;
                end else if (coin_insert != 4'b0000) begin
                    case (coin_insert)
                        4'b0001: total_inserted = total_inserted + COIN_10C;
                        4'b0010: total_inserted = total_inserted + COIN_20C;
                        4'b0100: total_inserted = total_inserted + COIN_50C;
                        4'b1000: total_inserted = total_inserted + COIN_1D;
                        default: total_inserted = total_inserted;
                    endcase
			next_state = WAITING_FOR_PAYMENT;
                end else if (total_inserted < selected_price && coin_insert == 4'b0000) begin
                    next_state = ERROR;
                end else begin
		    next_state = WAITING_FOR_PAYMENT;
		end	
            end
            DISPENSING: begin
                dispense = 1;
                case (product_select)
                    4'b0001: stock[0] = stock[0] - 1;
                    4'b0010: stock[1] = stock[1] - 1;
                    4'b0100: stock[2] = stock[2] - 1;
                    4'b1000: stock[3] = stock[3] - 1;
                endcase
                lcd_change = total_inserted - selected_price;
                next_state = IDLE;
            end
            ERROR: begin
                led_status = 4'b1111; // Indicate error with LEDs
                if (reset) begin
                    next_state = IDLE;
                end
            end
        endcase
    end

    // Output logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                lcd_display = 8'h49; // "I" for Idle
                lcd_amount = 0;
                lcd_change = 0;
                dispense = 0;
                led_status = 4'b0000;
            end
            PRODUCT_SELECTED: begin
                lcd_display = 8'h50; // "P" for Product Selected
            end
            WAITING_FOR_PAYMENT: begin
                lcd_display = 8'h57; // "W" for Waiting
                lcd_amount = total_inserted;
            end
            DISPENSING: begin
                lcd_display = 8'h44; // "D" for Dispensing
            end
            ERROR: begin
                lcd_display = 8'h45; // "E" for Error
            end
        endcase
    end
endmodule

