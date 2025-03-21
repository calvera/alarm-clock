module clock #(
    parameter DIVIDER = 16
) (
    input  logic clk_in,
    input  logic reset,
    output logic clk_out
);

    localparam C_TICKS = DIVIDER - 1;
    localparam C_BITS = $clog2(C_TICKS);

    reg [C_BITS:0] counter;
    logic temp_clk;

    always_ff @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= C_TICKS[C_BITS:0];
            temp_clk <= 1'b0;
        end else begin
            counter <= counter - 1'b1;
            if (counter[C_BITS]) begin
                temp_clk <= 1'b1;
                counter <= C_TICKS[C_BITS:0];
            end
            else begin
                temp_clk <= 1'b0;
            end
        end
    end

    assign clk_out = temp_clk;

endmodule
