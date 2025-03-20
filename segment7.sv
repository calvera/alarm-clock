`include "segment7_pkg.sv"

/* verilator lint_off IMPORTSTAR */
import segment7_pkg::*;

module segment7 #(
    parameter int SEGMENTS = 4,
    parameter int C_BITS = $clog2(SEGMENTS),
    parameter polarity_t SEGMENT_SELECT_ACTIVE = ACTIVE_LOW,
    parameter polarity_t SEGMENTS_ACTIVE = ACTIVE_LOW
)(
    input logic [C_BITS-1:0] counter,
    input logic enable,
    input logic [SEGMENTS-1:0] digit_enable,
    input digit_t [SEGMENTS-1:0] digit,
    input logic [SEGMENTS-1:0] decimal_point,
    output segment_output_t segments,
    output logic [SEGMENTS-1:0] segment_sel
);

    typedef logic [6:0] segment_pattern_t;

    // Segment decoder function implementation
    function segment_output_t segment7_decoder(
        input digit_t number,
        input logic dec_point
    );
        segment_pattern_t segment_pattern;

        case (number)
            4'h0: segment_pattern = 7'b0111111;
            4'h1: segment_pattern = 7'b0000110;
            4'h2: segment_pattern = 7'b1011011;
            4'h3: segment_pattern = 7'b1001111;
            4'h4: segment_pattern = 7'b1100110;
            4'h5: segment_pattern = 7'b1101101;
            4'h6: segment_pattern = 7'b1111101;
            4'h7: segment_pattern = 7'b0000111;
            4'h8: segment_pattern = 7'b1111111;
            4'h9: segment_pattern = 7'b1101111;
            4'ha: segment_pattern = 7'b1110111;
            4'hb: segment_pattern = 7'b1111100;
            4'hc: segment_pattern = 7'b0111001;
            4'hd: segment_pattern = 7'b1011110;
            4'he: segment_pattern = 7'b1111001;
            4'hf: segment_pattern = 7'b1110001;
            default: segment_pattern = 7'b0000000;
        endcase

        return {dec_point, segment_pattern};
    endfunction

    logic current_dec_point;
    assign current_dec_point = enable & decimal_point[counter];

    logic current_enable;
    assign current_enable = enable & digit_enable[counter];

    logic [SEGMENTS-1:0] segment_sel_internal;
    assign segment_sel_internal = (current_enable ? 4'h1 : 4'b0 ) << counter;

    // Segment select output logic
    always_comb begin
        case (SEGMENT_SELECT_ACTIVE)
            ACTIVE_LOW:  segment_sel = ~segment_sel_internal;
            ACTIVE_HIGH: segment_sel = segment_sel_internal;
        endcase
    end

    // Segment output logic
    segment_output_t segments_internal;
    assign segments_internal = segment7_decoder(digit[counter], current_dec_point);

    always_comb begin
        case (SEGMENTS_ACTIVE)
            ACTIVE_LOW:  segments = ~segments_internal;
            ACTIVE_HIGH: segments = segments_internal;
        endcase
    end

    // Parameter checks
    initial begin
        if ((SEGMENTS & (SEGMENTS - 1)) != 0) begin
            $fatal(1, "Parameter SEGMENTS must be a power of 2");
        end
        if (SEGMENTS < 1) begin
            $fatal(1, "Parameter SEGMENTS must be positive");
        end
    end

endmodule
