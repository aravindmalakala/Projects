module optimized_pipeline (
    input  wire                clk,
    input  wire                rst,
    input  wire signed [15:0]  x_in,
    output reg  signed [39:0]  y_out
);

parameter TAPS = 100;
parameter HALF = TAPS / 2;

wire signed [15:0] h [0:HALF-1];

// Coefficients
assign h[0]  = -16'sd3;    assign h[1]  = -16'sd7;    assign h[2]  = -16'sd9;
assign h[3]  = -16'sd8;    assign h[4]  = -16'sd3;    assign h[5]  =  16'sd4;
assign h[6]  =  16'sd11;   assign h[7]  =  16'sd15;   assign h[8]  =  16'sd14;
assign h[9]  =  16'sd6;    assign h[10] = -16'sd7;    assign h[11] = -16'sd21;
assign h[12] = -16'sd29;   assign h[13] = -16'sd26;   assign h[14] = -16'sd11;
assign h[15] =  16'sd13;   assign h[16] =  16'sd38;   assign h[17] =  16'sd52;
assign h[18] =  16'sd47;   assign h[19] =  16'sd20;   assign h[20] = -16'sd22;
assign h[21] = -16'sd64;   assign h[22] = -16'sd87;   assign h[23] = -16'sd78;
assign h[24] = -16'sd33;   assign h[25] =  16'sd36;   assign h[26] =  16'sd104;
assign h[27] =  16'sd141;  assign h[28] =  16'sd125;  assign h[29] =  16'sd52;
assign h[30] = -16'sd57;   assign h[31] = -16'sd164;  assign h[32] = -16'sd222;
assign h[33] = -16'sd197;  assign h[34] = -16'sd83;   assign h[35] =  16'sd91;
assign h[36] =  16'sd263;  assign h[37] =  16'sd360;  assign h[38] =  16'sd324;
assign h[39] =  16'sd139;  assign h[40] = -16'sd156;  assign h[41] = -16'sd465;
assign h[42] = -16'sd661;  assign h[43] = -16'sd625;  assign h[44] = -16'sd285;
assign h[45] =  16'sd352;  assign h[46] =  16'sd1194; assign h[47] =  16'sd2077;
assign h[48] =  16'sd2811; assign h[49] =  16'sd3227;

// Registers
reg signed [15:0] x_delay  [0:TAPS-1];
reg signed [16:0] sd       [0:HALF-1][0:HALF-2];
reg signed [39:0] mul_reg  [0:HALF-1];
reg signed [39:0] sum_pipe [0:HALF-2];

integer i, j;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        // Reset delay line
        for (i = 0; i < TAPS; i = i + 1)
            x_delay[i] <= 16'sd0;

        // Reset FIR pipeline
        for (i = 0; i < HALF; i = i + 1) begin
            mul_reg[i] <= 40'sd0;
            for (j = 0; j < HALF-1; j = j + 1)
                sd[i][j] <= 17'sd0;
        end

        for (i = 0; i < HALF-1; i = i + 1)
            sum_pipe[i] <= 40'sd0;

        y_out <= 40'sd0;
    end
    else begin
        // Shift register
        for (i = TAPS-1; i > 0; i = i - 1)
            x_delay[i] <= x_delay[i-1];
        x_delay[0] <= x_in;

        // Stage 0
        mul_reg[0] <= (x_delay[0] + x_delay[TAPS-1]) * h[0];

        // Stages 1..HALF-1
        for (i = 1; i < HALF; i = i + 1) begin
            sd[i][0] <= x_delay[i] + x_delay[TAPS-1-i];
            for (j = 1; j < i; j = j + 1)
                sd[i][j] <= sd[i][j-1];
            mul_reg[i] <= sd[i][i-1] * h[i];
        end

        // Accumulator pipeline
        sum_pipe[0] <= mul_reg[0];
        for (i = 1; i < HALF-1; i = i + 1)
            sum_pipe[i] <= sum_pipe[i-1] + mul_reg[i];

        // Output
        y_out <= sum_pipe[HALF-2] + mul_reg[HALF-1];
    end
end

endmodulez x