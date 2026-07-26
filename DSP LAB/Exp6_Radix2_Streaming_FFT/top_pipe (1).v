`timescale 1ns / 1ps

module fft_top(
    input clk,
    input rst,
    input signed [7:0] in_real,
    input signed [7:0] in_imag,
    input in_valid,
    output reg signed [10:0] out_real,
    output reg signed [10:0] out_imag,
    output reg out_valid
);

//////////////////////////////////////////////////
// INPUT BUFFER + CONTROL
//////////////////////////////////////////////////
reg signed [7:0] xr[0:7], xi[0:7];
reg [2:0] count;
reg compute;
reg [2:0] out_cnt;
reg sending;

always @(posedge clk) begin
    if(rst) begin
        count   <= 0;
        compute <= 0;
    end
    else begin
        if(in_valid) begin
            xr[count] <= in_real;
            xi[count] <= in_imag;
            if(count == 3'd7) begin
                compute <= 1;
                count   <= 0;
            end
            else
                count <= count + 1;
        end
        // Clear compute after pipeline has consumed it
        if(sending && out_cnt == 3'd7)
            compute <= 0;
    end
end

//////////////////////////////////////////////////
// STAGE 1 — Combinational
//////////////////////////////////////////////////
reg signed [8:0] s1r[0:7], s1i[0:7];

always @(*) begin
    s1r[0] = xr[0] + xr[4];  s1i[0] = xi[0] + xi[4];
    s1r[1] = xr[0] - xr[4];  s1i[1] = xi[0] - xi[4];
    s1r[2] = xr[2] + xr[6];  s1i[2] = xi[2] + xi[6];
    s1r[3] = xr[2] - xr[6];  s1i[3] = xi[2] - xi[6];
    s1r[4] = xr[1] + xr[5];  s1i[4] = xi[1] + xi[5];
    s1r[5] = xr[1] - xr[5];  s1i[5] = xi[1] - xi[5];
    s1r[6] = xr[3] + xr[7];  s1i[6] = xi[3] + xi[7];
    s1r[7] = xr[3] - xr[7];  s1i[7] = xi[3] - xi[7];
end

//////////////////////////////////////////////////
// PIPELINE REGISTER 1  (S1 → S2)
//////////////////////////////////////////////////
reg signed [8:0] p1r[0:7], p1i[0:7];
reg p1_valid;

always @(posedge clk) begin
    if(rst) begin
        p1_valid <= 0;
    end else begin
        // Capture the one-cycle compute pulse
        p1_valid <= compute && !(sending && out_cnt == 3'd7);
        p1r[0] <= s1r[0]; p1r[1] <= s1r[1];
        p1r[2] <= s1r[2]; p1r[3] <= s1r[3];
        p1r[4] <= s1r[4]; p1r[5] <= s1r[5];
        p1r[6] <= s1r[6]; p1r[7] <= s1r[7];
        p1i[0] <= s1i[0]; p1i[1] <= s1i[1];
        p1i[2] <= s1i[2]; p1i[3] <= s1i[3];
        p1i[4] <= s1i[4]; p1i[5] <= s1i[5];
        p1i[6] <= s1i[6]; p1i[7] <= s1i[7];
    end
end

//////////////////////////////////////////////////
// STAGE 2 — Combinational (feeds from p1)
//////////////////////////////////////////////////
reg signed [9:0] s2r[0:7], s2i[0:7];

always @(*) begin
    s2r[0] = p1r[0] + p1r[2];  s2i[0] = p1i[0] + p1i[2];
    s2r[2] = p1r[0] - p1r[2];  s2i[2] = p1i[0] - p1i[2];

    s2r[1] = p1r[1] + p1i[3];  s2i[1] = p1i[1] - p1r[3];
    s2r[3] = p1r[1] - p1i[3];  s2i[3] = p1i[1] + p1r[3];

    s2r[4] = p1r[4] + p1r[6];  s2i[4] = p1i[4] + p1i[6];
    s2r[6] = p1r[4] - p1r[6];  s2i[6] = p1i[4] - p1i[6];

    s2r[5] = p1r[5] + p1i[7];  s2i[5] = p1i[5] - p1r[7];
    s2r[7] = p1r[5] - p1i[7];  s2i[7] = p1i[5] + p1r[7];
end

//////////////////////////////////////////////////
// PIPELINE REGISTER 2  (S2 → S3)
//////////////////////////////////////////////////
reg signed [9:0] p2r[0:7], p2i[0:7];
reg p2_valid;

always @(posedge clk) begin
    if(rst) begin
        p2_valid <= 0;
    end else begin
        p2_valid <= p1_valid;
        p2r[0] <= s2r[0]; p2r[1] <= s2r[1];
        p2r[2] <= s2r[2]; p2r[3] <= s2r[3];
        p2r[4] <= s2r[4]; p2r[5] <= s2r[5];
        p2r[6] <= s2r[6]; p2r[7] <= s2r[7];
        p2i[0] <= s2i[0]; p2i[1] <= s2i[1];
        p2i[2] <= s2i[2]; p2i[3] <= s2i[3];
        p2i[4] <= s2i[4]; p2i[5] <= s2i[5];
        p2i[6] <= s2i[6]; p2i[7] <= s2i[7];
    end
end

//////////////////////////////////////////////////
// MULTIPLIER (unchanged)
//////////////////////////////////////////////////
function signed [10:0] mult707;
    input signed [10:0] x;
    reg signed [23:0] tmp;
begin
    tmp     = x * 24'sd5793;
    mult707 = tmp >>> 13;   // truncate, no rounding bias
end
endfunction

//////////////////////////////////////////////////
// STAGE 3 — Combinational (feeds from p2)
//////////////////////////////////////////////////
reg signed [10:0] Xr[0:7], Xi[0:7];

wire signed [10:0] w1_sum_r = p2r[5] + p2i[5];
wire signed [10:0] w1_sum_i = p2i[5] - p2r[5];
wire signed [10:0] w3_sum_r = p2i[7] - p2r[7];
wire signed [10:0] w3_sum_i = -p2i[7] - p2r[7];

always @(*) begin
    Xr[0] = p2r[0] + p2r[4];  Xi[0] = p2i[0] + p2i[4];
    Xr[4] = p2r[0] - p2r[4];  Xi[4] = p2i[0] - p2i[4];

    Xr[1] = p2r[1] + mult707(w1_sum_r);
    Xi[1] = p2i[1] + mult707(w1_sum_i);
    Xr[5] = p2r[1] - mult707(w1_sum_r);
    Xi[5] = p2i[1] - mult707(w1_sum_i);

    Xr[2] = p2r[2] + p2i[6];  Xi[2] = p2i[2] - p2r[6];
    Xr[6] = p2r[2] - p2i[6];  Xi[6] = p2i[2] + p2r[6];

    Xr[3] = p2r[3] + mult707(w3_sum_r);
    Xi[3] = p2i[3] + mult707(w3_sum_i);
    Xr[7] = p2r[3] - mult707(w3_sum_r);
    Xi[7] = p2i[3] - mult707(w3_sum_i);
end

//////////////////////////////////////////////////
// PIPELINE REGISTER 3  (S3 → Output FSM)
//////////////////////////////////////////////////
reg signed [10:0] p3r[0:7], p3i[0:7];
reg p3_valid;

always @(posedge clk) begin
    if(rst) begin
        p3_valid <= 0;
    end else begin
        p3_valid <= p2_valid;
        p3r[0] <= Xr[0]; p3r[1] <= Xr[1];
        p3r[2] <= Xr[2]; p3r[3] <= Xr[3];
        p3r[4] <= Xr[4]; p3r[5] <= Xr[5];
        p3r[6] <= Xr[6]; p3r[7] <= Xr[7];
        p3i[0] <= Xi[0]; p3i[1] <= Xi[1];
        p3i[2] <= Xi[2]; p3i[3] <= Xi[3];
        p3i[4] <= Xi[4]; p3i[5] <= Xi[5];
        p3i[6] <= Xi[6]; p3i[7] <= Xi[7];
    end
end

//////////////////////////////////////////////////
// OUTPUT FSM  (triggered by p3_valid)
//////////////////////////////////////////////////
always @(posedge clk) begin
    if(rst) begin
        sending   <= 0;
        out_cnt   <= 0;
        out_valid <= 0;
        out_real  <= 0;
        out_imag  <= 0;
    end
    else if(p3_valid && !sending) begin
        sending   <= 1;
        out_cnt   <= 0;
        out_valid <= 0;
    end
    else if(sending) begin
        out_valid <= 1;
        out_real  <= p3r[out_cnt];
        out_imag  <= p3i[out_cnt];
        if(out_cnt == 3'd7) begin
            sending <= 0;
            out_cnt <= 0;
        end
        else
            out_cnt <= out_cnt + 1;
    end
    else begin
        out_valid <= 0;
    end
end

endmodule
