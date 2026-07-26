`timescale 1ns / 1ps
module tb_direct;

reg clk;
reg rst;
reg signed [15:0] x_in;
wire signed [39:0] y_out;

parameter SAMPLES = 1000;
parameter TAPS    = 100;

reg signed [15:0] x_signal1 [0:999];
reg signed [15:0] x_signal2 [0:999];
reg signed [15:0] x_signal3 [0:999];

integer i;
integer fid_1, fid_2, fid_3;
integer dummy_1, dummy_2, dummy_3;
integer fid_out1, fid_out2, fid_out3;

direct uut(
    .clk(clk),
    .rst(rst),
    .x_in(x_in),
    .y_out(y_out)
);

initial clk = 0;
always #5 clk = ~clk;

initial begin
    fid_1 = $fopen("sinewave1_q214.txt","r");
    for(i = 0; i < 1000; i = i + 1)
        dummy_1 = $fscanf(fid_1,"%d",x_signal1[i]);
    $fclose(fid_1);

    fid_2 = $fopen("sinewave2_q214.txt","r");
    for(i = 0; i < 1000; i = i + 1)
        dummy_2 = $fscanf(fid_2,"%d",x_signal2[i]);
    $fclose(fid_2);

    fid_3 = $fopen("sinewave3_q214.txt","r");
    for(i = 0; i < 1000; i = i + 1)
        dummy_3 = $fscanf(fid_3,"%d",x_signal3[i]);
    $fclose(fid_3);

    fid_out1 = $fopen("output_direct1_q214.txt","w");
    fid_out2 = $fopen("output_direct2_q214.txt","w");
    fid_out3 = $fopen("output_direct3_q214.txt","w");

    // Reset
    rst = 1;
    #20;
    rst = 0;

    // Process sinewave1
    for(i = 0; i < 1000; i = i + 1) begin
        x_in = x_signal1[i];
        #10;
        $fwrite(fid_out1, "%d\n", y_out);
    end
    // Flush pipeline with zeros
    for(i = 0; i < TAPS-1; i = i + 1) begin
        x_in = 16'sd0;
        #10;
        $fwrite(fid_out1, "%d\n", y_out);
    end

    // Reset for next signal
    rst = 1;
    #20;
    rst = 0;

    // Process sinewave2
    for(i = 0; i < 1000; i = i + 1) begin
        x_in = x_signal2[i];
        #10;
        $fwrite(fid_out2, "%d\n", y_out);
    end
    // Flush pipeline with zeros
    for(i = 0; i < TAPS-1; i = i + 1) begin
        x_in = 16'sd0;
        #10;
        $fwrite(fid_out2, "%d\n", y_out);
    end

    // Reset for next signal
    rst = 1;
    #20;
    rst = 0;

    // Process sinewave3
    for(i = 0; i < 1000; i = i + 1) begin
        x_in = x_signal3[i];
        #10;
        $fwrite(fid_out3, "%d\n", y_out);
    end
    // Flush pipeline with zeros
    for(i = 0; i < TAPS-1; i = i + 1) begin
        x_in = 16'sd0;
        #10;
        $fwrite(fid_out3, "%d\n", y_out);
    end

    $fclose(fid_out1);
    $fclose(fid_out2);
    $fclose(fid_out3);
    $finish;
end

endmodule