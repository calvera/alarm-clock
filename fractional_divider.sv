module fractional_divider #(
    parameter NUMERATOR = 1,
    parameter DENOMINATOR = 16
)(
    input   logic clk_in,
    output	logic strobe_out
);
    localparam C_BITS = $clog2(DENOMINATOR);

    reg	[C_BITS-1:0] counter;
    always_ff @(posedge clk_in) begin
        { strobe_out, counter } <= counter + NUMERATOR;
    end

endmodule
