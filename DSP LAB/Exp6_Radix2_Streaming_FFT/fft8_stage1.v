// fft8_stage1.v - First stage of 8-point FFT (delay=4)
module fft8_stage1 #(
    parameter INT  = 69,
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

// Delay line of length 4
reg signed [W-1:0] mem_r [0:3];
reg signed [W-1:0] mem_i [0:3];

// Control
reg [7:0] count;
reg primed;

// Twiddle factors (Q(INT.FRAC) format)
localparam ONE = (1 << FRAC);
localparam SQ  = ((1 << FRAC) * 707) / 1000;  // ~1/√2

// Index for memory access when count >= 4
wire [7:0] idx = count - 4;   // unsigned wrap, safe when count>=4

// Butterfly inputs
wire signed [W-1:0] a_r = (count >= 4) ? mem_r[idx] : {W{1'b0}};
wire signed [W-1:0] a_i = (count >= 4) ? mem_i[idx] : {W{1'b0}};
wire signed [W-1:0] b_r = xr_in;
wire signed [W-1:0] b_i = xi_in;

// Twiddle factor selection for stage 1 - now using 'reg'
reg signed [W-1:0] wr, wi;

always @(*) begin
    case (idx[1:0])   // use lower 2 bits (0..3)
        2'b00: begin wr = ONE; wi = 0;      end
        2'b01: begin wr = SQ;  wi = -SQ;    end
        2'b10: begin wr = 0;   wi = -ONE;   end
        2'b11: begin wr = -SQ; wi = -SQ;    end
        default: begin wr = ONE; wi = 0;    end
    endcase
end

// Butterfly: sum = a+b , diff = a-b
wire signed [W:0] sum_r = a_r + b_r;
wire signed [W:0] sum_i = a_i + b_i;
wire signed [W:0] diff_r = a_r - b_r;
wire signed [W:0] diff_i = a_i - b_i;

// Complex multiply: (diff) * (wr + j wi)
wire signed [2*W-1:0] prod_r = diff_r * wr - diff_i * wi;
wire signed [2*W-1:0] prod_i = diff_r * wi + diff_i * wr;

// Scale back by FRAC (twiddle factors are in Q(INT.FRAC) format)
wire signed [W-1:0] diff_tw_r = prod_r >>> FRAC;
wire signed [W-1:0] diff_tw_i = prod_i >>> FRAC;

// Control FSM
integer i;
always @(posedge clk or posedge rst) begin
    if (rst) begin
        count   <= 0;
        primed  <= 0;
        valid_out <= 0;
        xr_out <= 0;
        xi_out <= 0;
        for (i = 0; i < 4; i = i + 1) begin
            mem_r[i] <= 0;
            mem_i[i] <= 0;
        end
    end else begin
        valid_out <= 0;
        xr_out <= 0;
        xi_out <= 0;

        if (count < 4) begin
            // Priming phase
            if (valid_in) begin
                mem_r[count] <= xr_in;
                mem_i[count] <= xi_in;
                if (primed) begin
                    valid_out <= 1;
                    xr_out <= mem_r[count];
                    xi_out <= mem_i[count];
                end
                if (count == 3) count <= 4;
                else count <= count + 1;
            end else if (primed) begin
                valid_out <= 1;
                xr_out <= mem_r[count];
                xi_out <= mem_i[count];
                if (count == 3) begin
                    count <= 0;
                    primed <= 0;
                end else count <= count + 1;
            end
        end else begin
            // Processing phase
            if (valid_in) begin
                valid_out <= 1;
                xr_out <= sum_r[W-1:0];   // drop carry bit
                xi_out <= sum_i[W-1:0];
                mem_r[idx] <= diff_tw_r;
                mem_i[idx] <= diff_tw_i;
                if (count == 7) begin
                    count <= 0;
                    primed <= 1;
                end else count <= count + 1;
            end
        end
    end
end

endmodule