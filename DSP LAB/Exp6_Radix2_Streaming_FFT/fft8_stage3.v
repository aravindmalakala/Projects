// fft8_stage3.v - Third stage of 8-point FFT (delay=1)
module fft8_stage3 #(
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

// Delay line of length 1 (single register)
reg signed [W-1:0] mem_r;
reg signed [W-1:0] mem_i;

reg [7:0] count;
reg primed;

localparam ONE = (1 << FRAC);
wire signed [W-1:0] wr = ONE;
wire signed [W-1:0] wi = 0;

wire signed [W-1:0] a_r = (count >= 1) ? mem_r : {W{1'b0}};
wire signed [W-1:0] a_i = (count >= 1) ? mem_i : {W{1'b0}};
wire signed [W-1:0] b_r = xr_in;
wire signed [W-1:0] b_i = xi_in;

wire signed [W:0] sum_r = a_r + b_r;
wire signed [W:0] sum_i = a_i + b_i;
wire signed [W:0] diff_r = a_r - b_r;
wire signed [W:0] diff_i = a_i - b_i;

wire signed [2*W-1:0] prod_r = diff_r * wr - diff_i * wi;
wire signed [2*W-1:0] prod_i = diff_r * wi + diff_i * wr;
wire signed [W-1:0] diff_tw_r = prod_r >>> FRAC;
wire signed [W-1:0] diff_tw_i = prod_i >>> FRAC;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        count <= 0; primed <= 0; valid_out <= 0; xr_out <= 0; xi_out <= 0;
        mem_r <= 0; mem_i <= 0;
    end else begin
        valid_out <= 0; xr_out <= 0; xi_out <= 0;
        if (count < 1) begin
            if (valid_in) begin
                mem_r <= xr_in; mem_i <= xi_in;
                if (primed) begin
                    valid_out <= 1;
                    xr_out <= mem_r;
                    xi_out <= mem_i;
                end
                count <= 1;
            end else if (primed) begin
                valid_out <= 1;
                xr_out <= mem_r;
                xi_out <= mem_i;
                count <= 0;
                primed <= 0;
            end
        end else begin
            if (valid_in) begin
                valid_out <= 1;
                xr_out <= sum_r[W-1:0];
                xi_out <= sum_i[W-1:0];
                mem_r <= diff_tw_r;
                mem_i <= diff_tw_i;
                if (count == 1) begin
                    count <= 0;
                    primed <= 1;
                end else begin
                    count <= count + 1;
                end
            end
        end
    end
end

endmodule