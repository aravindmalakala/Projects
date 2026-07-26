// fft8_stage2.v - Second stage of 8-point FFT (delay=2)
module fft8_stage2 #(
    parameter INT  = 6,
    parameter FRAC = 5,
    parameter W    = INT + FRAC
)(
    input  clk,
    input  rst,
    input  valid_in,
    input  signed [W-1:0] xr_in,
    input  signed [W-1:0] xi_in,

    output reg valid_out,
    output reg signed [W-1:0] xr_out,
    output reg signed [W-1:0] xi_out
);

// Delay line of length 2
reg signed [W-1:0] mem_r [0:1];
reg signed [W-1:0] mem_i [0:1];

reg [7:0] count;
reg primed;

localparam ONE = (1 << FRAC);
wire [7:0] idx = count - 2;

wire signed [W-1:0] a_r = (count >= 2) ? mem_r[idx] : {W{1'b0}};
wire signed [W-1:0] a_i = (count >= 2) ? mem_i[idx] : {W{1'b0}};
wire signed [W-1:0] b_r = xr_in;
wire signed [W-1:0] b_i = xi_in;

// Twiddle factors: even index -> 1, odd index -> -j
reg signed [W-1:0] wr, wi;

always @(*) begin
    if (idx[0] == 1'b0) begin
        wr = ONE; wi = 0;
    end else begin
        wr = 0; wi = -ONE;
    end
end

wire signed [W:0] sum_r = a_r + b_r;
wire signed [W:0] sum_i = a_i + b_i;
wire signed [W:0] diff_r = a_r - b_r;
wire signed [W:0] diff_i = a_i - b_i;

wire signed [2*W-1:0] prod_r = diff_r * wr - diff_i * wi;
wire signed [2*W-1:0] prod_i = diff_r * wi + diff_i * wr;
wire signed [W-1:0] diff_tw_r = prod_r >>> FRAC;
wire signed [W-1:0] diff_tw_i = prod_i >>> FRAC;

integer i;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        count <= 0; primed <= 0; valid_out <= 0; xr_out <= 0; xi_out <= 0;
        for (i = 0; i < 2; i = i + 1) begin mem_r[i] <= 0; mem_i[i] <= 0; end
    end else begin
        valid_out <= 0; xr_out <= 0; xi_out <= 0;
        if (count < 2) begin
            if (valid_in) begin
                mem_r[count] <= xr_in; mem_i[count] <= xi_in;
                if (primed) begin valid_out <= 1; xr_out <= mem_r[count]; xi_out <= mem_i[count]; end
                if (count == 1) count <= 2; else count <= count + 1;
            end else if (primed) begin
                valid_out <= 1; xr_out <= mem_r[count]; xi_out <= mem_i[count];
                if (count == 1) begin count <= 0; primed <= 0; end else count <= count + 1;
            end
        end else begin
            if (valid_in) begin
                valid_out <= 1; xr_out <= sum_r[W-1:0]; xi_out <= sum_i[W-1:0];
                mem_r[idx] <= diff_tw_r; mem_i[idx] <= diff_tw_i;
                if (count == 3) begin count <= 0; primed <= 1; end else count <= count + 1;
            end
        end
    end
end

endmodule