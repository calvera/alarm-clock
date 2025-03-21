module alarm_clock (
    input logic clk_in, // 50MHz / 25000 = 2kHz
    input logic reset,
    input logic show_seconds,
    output logic [3:0] DIG,
    output logic [7:0] SEG
);

    logic [4:0] sec_low;
    logic [3:0] sec_high;
    logic [3:0] min_low;
    logic [3:0] min_high;
    logic [3:0] hour_low;
    logic [1:0] hour_high;
    digit_t [3:0] digit;
    logic [3:0] dig_en;
    logic [3:0] decimal_point;

    logic half_seconds;
    logic seconds10;
    logic minutes;
    logic minutes10;
    logic hour;
    logic hour10;
    logic refresh_clk;
    logic r;
    logic ss;
    logic pll_clk;
    logic [1:0] counter;

    // PLL instantiation
    pll pll_inst (
        .inclk0(clk_in),
        .c0(pll_clk)
    );

    assign r = ~reset;
    assign ss = ~show_seconds;

    // Counter for display refresh
    integer_divider #(
    .DIVIDER(8)
    ) refresh (
        .clk_in(pll_clk),
        .reset(r),
        .strobe_out(refresh_clk)
    );

    counting #(
    .COUNTING_BITS(2)
    ) counting_instance (
        .clk_in(refresh_clk),
        .reset(r),
        .use_max_2nd(),
        .max_reached(),
        .count(counter)
    );

    // 1Hz clock generator
    integer_divider #(
    .DIVIDER(1000) // 1Hz = 2000
    ) half_secs (
        .clk_in(pll_clk),
        .reset(r),
        .strobe_out(half_seconds)
    );

    // Seconds low digit
    counting #(
        .COUNTING_BITS(5),
        .MAX(19)
    ) sl (
        .clk_in(half_seconds),
        .reset(r),
        .max_reached(seconds10),
        .count(sec_low),
        .use_max_2nd()
    );

    // Seconds high digit
    counting #(
        .COUNTING_BITS(4),
        .MAX(5)
    ) sh (
        .clk_in(seconds10),
        .reset(r),
        .max_reached(minutes),
        .count(sec_high),
        .use_max_2nd()
    );

    // Minutes low digit
    counting #(
        .COUNTING_BITS(4),
        .MAX(9)
    ) ml (
        .clk_in(minutes),
        .reset(r),
        .max_reached(minutes10),
        .count(min_low),
        .use_max_2nd()
    );

    // Minutes high digit
    counting #(
        .COUNTING_BITS(4),
        .MAX(5)
    ) mh (
        .clk_in(minutes10),
        .reset(r),
        .count(min_high),
        .max_reached(hour),
        .use_max_2nd()
    );

    // Hours low digit
    counting #(
        .COUNTING_BITS(4),
        .MAX(9),
        .MAX_2ND(3)
    ) hl (
        .clk_in(hour),
        .reset(r),
        .max_reached(hour10),
        .count(hour_low),
        .use_max_2nd(hour_high[1])
    );

    // Hours high digit
    counting #(
        .COUNTING_BITS(2),
        .MAX(2)
    ) hh (
        .clk_in(hour10),
        .reset(r),
        .count(hour_high),
        .max_reached(),
        .use_max_2nd()
    );

    always_comb begin
        decimal_point = { 1'b0, sec_low[0], 2'b0 };
        if (!ss) begin
            digit = {hour_high, hour_low, min_high, min_low};
            dig_en = { hour_high[1] | hour_high[0], 3'b111};
        end else begin
            digit = {4'h0, 4'h0, sec_high, sec_low[4:1]};
            dig_en = { 4'b11 };
        end
    end

    // Display multiplexing logic
    // Seven segment display multiplexer
    segment7 mux (
        .enable(1'b1),
        .counter(counter),
        .digit(digit),
        .digit_enable(dig_en),
        .decimal_point(decimal_point),
        .segment_sel(DIG),
        .segments(SEG)
    );

endmodule