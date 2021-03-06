`timescale 1ns / 1ps

module state_machine
( 
    input logic clk, rst, start_btn, clear_btn, stop_btn,
    output logic ltr_flag, led0,
    output logic [3:0] digit0, digit1, digit2, digit3
);

typedef enum logic [5:0] {init = 6'b000001, start = 6'b000010, delay = 6'b000100, count = 6'b001000, stop = 6'b010000, bad_stop = 6'b100000} state_type;

state_type curr_state, next_state;
logic load_counter, clear_counter, enable_counter, zero_count, timer_go, timer_clr;
logic [3:0] random_val, timer_d0, timer_d1, timer_d2, timer_d3;

univ_bin_counter #(.N(32)) counter(.clk(clk), .reset(rst), .syn_clr(clear_counter), .load(load_counter), .en(enable_counter), .up(0), .d(100000000*random_val), .max_tick(), .min_tick(zero_count), .q());
//univ_bin_counter #(.N(4)) counter(.clk(clk), .reset(rst), .syn_clr(clear_counter), .load(load_counter), .en(enable_counter), .up(0), .d(random_val), .max_tick(), .min_tick(zero_count), .q());
LFSR_fib168pi rng(.clk(clk), .reset(rst), .seed(28'b1110_1100_0111_1110_0111_0110_1100), .r(random_val));
stop_watch_if stop_watch(.clk(clk), .go(timer_go), .clr(rst | timer_clr), .d3(timer_d3), .d2(timer_d2), .d1(timer_d1), .d0(timer_d0));

always_ff @(posedge clk, posedge rst) begin
    if(rst == 1'b1) begin
        curr_state <= init;
    end
    else begin
        curr_state <= next_state;
    end
end

always_comb begin
    next_state = curr_state;
    case(curr_state)
        init:
            begin
                ltr_flag  = 1;
                digit0    = 4'b1010;
                digit1    = 4'b0101;
                digit2    = 4'b1111;
                digit3    = 4'b1111;
                led0      = 0;
                timer_go  = 0;
                timer_clr = 1;
                
                enable_counter = 0;
                load_counter   = 0;
                clear_counter  = 1;
                
                if(start_btn == 1'b1) begin
                    next_state = start;
                end
            end
        start:
            begin
                ltr_flag  = 0;
                digit0    = 4'b1111;
                digit1    = 4'b1111;
                digit2    = 4'b1111;
                digit3    = 4'b1111;
                led0      = 0;
                timer_go  = 0;
                timer_clr = 0;
                
                enable_counter = 0;
                clear_counter  = 0;
                load_counter   = 1;
                
                next_state = delay;
            end
        delay:
            begin
                ltr_flag  = 0;
                digit0    = 4'b1111;
                digit1    = 4'b1111;
                digit2    = 4'b1111;
                digit3    = 4'b1111;
                led0      = 0;
                timer_go  = 0;
                timer_clr = 0;
            
                load_counter   = 0;
                enable_counter = 1;
                clear_counter  = 0;
                
                if(zero_count == 1) begin
                    next_state = count;
                end
                else if(stop_btn == 1'b1) begin
                    next_state = bad_stop;
                end
            end
        count:
            begin
                ltr_flag  = 0;
                led0      = 1;
                timer_go  = 1;
                timer_clr = 0;
                digit0    = timer_d0;
                digit1    = timer_d1;
                digit2    = timer_d2;
                digit3    = timer_d3;
            
                load_counter   = 0;
                enable_counter = 0;
                clear_counter  = 0;
                
                if(stop_btn == 1'b1) begin
                    next_state = stop;
                end
                else if((digit3 == 1) && (~|digit2) && (~|digit1) && (~|digit0)) begin
                    next_state = stop;
                end
            end
        stop:
            begin
                ltr_flag  = 0;
                led0      = 1;
                timer_go  = 0;
                timer_clr = 0;
                digit0    = timer_d0;
                digit1    = timer_d1;
                digit2    = timer_d2;
                digit3    = timer_d3;
            
                load_counter   = 0;
                enable_counter = 0;
                clear_counter  = 0;
                
                if(clear_btn == 1'b1) begin
                    next_state = init;
                end
            end
        bad_stop:
            begin
                ltr_flag  = 0;
                led0      = 0;
                timer_go  = 0;
                timer_clr = 0;
                digit0    = 4'b1001;
                digit1    = 4'b1001;
                digit2    = 4'b1001;
                digit3    = 4'b1001;
            
                load_counter   = 0;
                enable_counter = 0;
                clear_counter  = 0;
                
                if(clear_btn == 1'b1) begin
                    next_state = init;
                end
            end
        default:
            begin
                next_state = init;
                ltr_flag   = 0;
                digit0     = 4'b1111;
                digit1     = 4'b1111;
                digit2     = 4'b1111;
                digit3     = 4'b1111;
                led0       = 0;
                timer_go   = 0;
                timer_clr  = 0;
                
                load_counter   = 0;
                enable_counter = 0;
                clear_counter  = 0;
            end
    endcase
end


endmodule
