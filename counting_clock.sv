module counting_clock #(
    parameter DIVIDER = 16,
    parameter COUNTING_BITS = 16
) (
    input  logic clk_in,
    input  logic reset,
    output logic clk_out,
    output logic [COUNTING_BITS-1:0] counting
);

    logic clk_internal;
    reg [COUNTING_BITS-1:0] counter;

    clock #(
    .DIVIDER(DIVIDER)
    ) clk_inst (
        .clk_in(clk_in),
        .reset(reset),
        .clk_out(clk_internal)
    );

    always_ff @(posedge clk_internal or posedge reset) begin
        if (reset) begin
            counter <= {COUNTING_BITS{1'b0}};
        end else begin
            counter <= counter + 1'b1;
        end
    end

    assign clk_out = clk_internal;
    assign counting = counter;

endmodule
