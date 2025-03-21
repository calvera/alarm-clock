module integer_divider #(
    parameter DIVIDER = 16
)(
    input   logic clk_in,
    input   logic reset,
    output	logic strobe_out
);
    localparam MAX = DIVIDER-2;
    localparam C_BITS = $clog2(MAX);

    reg	[C_BITS:0] counter;
    always_ff @(posedge clk_in or posedge reset) begin
        if (reset) begin
            counter <= MAX;
            strobe_out <= 1'b0;
        end
        else
            begin
                counter <= counter - 1'b1;
                if (counter[C_BITS]) begin
                    counter <= MAX;
                    strobe_out <= 1'b1;
                end
                else begin
                    strobe_out <= 1'b0;
                end
            end
    end

endmodule
