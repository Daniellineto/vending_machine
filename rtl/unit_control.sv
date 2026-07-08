import vending_pkg::*;

module unit_control (
    input  logic clk,
    input  logic rst,
    input  logic confirm,
    input  logic cancel,
    input  logic [1:0] coin_in,
    input  logic can_sell,

    output logic dispense,
    output logic error,
    output logic [2:0] state_out,

    output logic credit_load,
    output logic mem_read,
    output logic mem_write,
    output logic change_en
);

    state_t current_state, next_state;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            current_state <= IDLE;
        end else if (cancel) begin
            current_state <= IDLE;
        end else begin
            current_state <= next_state;
        end
    end

    always_comb begin
        next_state = current_state;

        case (current_state)
            IDLE: begin
                if (coin_in != COIN_NONE) begin
                    next_state = COLLECT;
                end
            end
            COLLECT: begin
                if (confirm) begin
                    next_state = CHECK;
                end
            end
            CHECK: begin
                if (can_sell) begin
                    next_state = DISPENSE;
                end else begin
                    next_state = ERROR;
                end
            end
            DISPENSE: begin
                next_state = CHANGE;
            end
            CHANGE: begin
                next_state = IDLE;
            end
            ERROR: begin
                next_state = current_state;
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    always_comb begin
        dispense    = 1'b0;
        error       = 1'b0;
        credit_load = 1'b0;
        mem_read    = 1'b0;
        mem_write   = 1'b0;
        change_en   = 1'b0;
        state_out   = current_state;

        case (current_state)
            IDLE: begin
                credit_load = (coin_in != COIN_NONE);
            end
            COLLECT: begin
                credit_load = (coin_in != COIN_NONE);
            end
            CHECK: begin
                mem_read = 1'b1;
            end
            DISPENSE: begin
                dispense  = 1'b1;
                mem_write = 1'b1;
            end
            CHANGE: begin
                change_en = 1'b1;
            end
            ERROR: begin
                error = 1'b1;
            end
            default: begin
            end
        endcase
    end

endmodule
