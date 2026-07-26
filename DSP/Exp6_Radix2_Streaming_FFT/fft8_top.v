// fft8_top.v - 8-point Radix-2 SDF DIF FFT top level
module fft8_top #(
    parameter IN_INT = 3,
    parameter FRAC   = 5,
    parameter IN_W   = IN_INT + FRAC,
    parameter INT    = 6,
    parameter W      = INT + FRAC
)(
    input  clk,
    input  rst,
    input  valid_in,
    input  signed [IN_W-1:0] xr_in,
    input  signed [IN_W-1:0] xi_in,

    output valid_out,
    output signed [W-1:0] xr_out,
    output signed [W-1:0] xi_out
);

// Extend input to internal word width (sign extension)
wire signed [W-1:0] xr_ext = {{(W-IN_W){xr_in[IN_W-1]}}, xr_in};
wire signed [W-1:0] xi_ext = {{(W-IN_W){xi_in[IN_W-1]}}, xi_in};

// Stage connections
wire v1, v2;
wire signed [W-1:0] s1r, s1i, s2r, s2i, s3r, s3i;

fft8_stage1 #(.INT(INT), .FRAC(FRAC), .W(W)) u_stage1 (
    .clk(clk), .rst(rst),
    .valid_in(valid_in),
    .xr_in(xr_ext), .xi_in(xi_ext),
    .valid_out(v1),
    .xr_out(s1r), .xi_out(s1i)
);

fft8_stage2 #(.INT(INT), .FRAC(FRAC), .W(W)) u_stage2 (
    .clk(clk), .rst(rst),
    .valid_in(v1),
    .xr_in(s1r), .xi_in(s1i),
    .valid_out(v2),
    .xr_out(s2r), .xi_out(s2i)
);

fft8_stage3 #(.INT(INT), .FRAC(FRAC), .W(W)) u_stage3 (
    .clk(clk), .rst(rst),
    .valid_in(v2),
    .xr_in(s2r), .xi_in(s2i),
    .valid_out(valid_out),
    .xr_out(s3r), .xi_out(s3i)
);

assign xr_out = s3r;
assign xi_out = s3i;

endmodule
