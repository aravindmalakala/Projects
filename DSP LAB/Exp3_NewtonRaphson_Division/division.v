module division (
    input  signed [32:0] a,
    input  signed [32:0] b,
    input  signed [32:0] lut [0:63],
    output reg signed [32:0] div
);

// Convert to Q16
wire signed [32:0] q_a;
wire signed [32:0] q_b;

assign q_a = a <<< 16;
assign q_b = b <<< 16;

// Normalization
reg signed [32:0] d;
reg signed [6:0] shift;

always @(*) begin
    d = q_b;
    shift = 0;

    while (d >= (33'sd1 <<< 16)) begin
        d = d >>> 1;
        shift = shift + 1;
    end

    while (d < (33'sd1 <<< 15)) begin
        d = d <<< 1;
        shift = shift - 1;
    end
end

// Index for LUT
wire [5:0] index;
assign index = (d - 33'sd32768) >>> 9;

// Initial estimate
reg signed [32:0] x0;
always @(*) begin
    x0 = lut[index];
end

// Newton–Raphson
reg signed [32:0] x;
reg signed [65:0] t1;
reg signed [65:0] t2;
reg signed [65:0] final_mult;

integer j;


always @(*) begin
    // division by zero protection
    if (b == 0) begin
        div = 0;
    end
    else begin
        x = x0;
        for(j=0;j<3;j=j+1) begin
            t1 = d * x;
            t1 = t1 >>> 16;

            t2 = (33'sd2 <<< 16) - t1;

            t2 = x * t2;
            x  = t2 >>> 16;
        end

        // undo normalization
        if (shift >= 0)
            x = x >>> shift;
        else
            x = x <<< (-shift);

        // final division
        final_mult = q_a * x;
        div = final_mult >>> 16;
    end
end

endmodule