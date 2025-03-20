module counting #(
    parameter COUNTING_BITS = 16,
    parameter MAX = 9
) (
    input  logic clk_in,
    input  logic reset,
    output logic max_reached,
    output logic [COUNTING_BITS-1:0] count
);

always_ff @(posedge clk_in or posedge reset) begin
    if (reset) begin
        count <= 0;
        max_reached <= 1'b0;
    end
    else if (count == COUNTING_BITS'(MAX) && MAX > 0) begin
        count <= 0;
        max_reached <= 1'b1;
    end
    else begin
        count <= count + 1'b1;
        max_reached <= 1'b0;
    end
end

endmodule
