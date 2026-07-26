`timescale 1ns/1ps

module tb_exp_2;

    parameter N = 48000;

    reg signed [17:0] x_q314_mem [0:N-1];
    reg signed [17:0] x_q512_mem [0:N-1];

    reg signed [17:0] a_q314;
    reg signed [17:0] b_q512;

    wire signed [20:0] sum_q614;
    wire signed [20:0] sub_q614;
    wire signed [35:0] mul_q926;

    integer f_sum, f_sub, f_mul;
    integer i, dump_count;

    integer fd1, fd2;
    integer temp1, temp2;
    integer status1, status2;

    // Instantiate DUT
    exp_2 DUT (
        .a_q314(a_q314),
        .b_q512(b_q512),
        .sum_q614(sum_q614),
        .sub_q614(sub_q614),
        .mul_q926(mul_q926)
    );

    // GTKWave dump
    initial begin
        $dumpfile("fixed_point.vcd");
        $dumpvars(0, tb_exp_2);
        dump_count = 0;
    end

    initial begin

        $display("Reading decimal input files...");

        // open decimal input files
        fd1 = $fopen("x_q314.txt", "r");
        fd2 = $fopen("x_q512.txt", "r");

        // read decimal values
        for (i = 0; i < N; i = i + 1) begin
            status1 = $fscanf(fd1, "%d\n", temp1);
            status2 = $fscanf(fd2, "%d\n", temp2);

            x_q314_mem[i] = temp1;
            x_q512_mem[i] = temp2;
        end

        $fclose(fd1);
        $fclose(fd2);

        // open output files
        f_sum = $fopen("sum_q614.txt", "w");
        f_sub = $fopen("sub_q614.txt", "w");
        f_mul = $fopen("mul_q926.txt", "w");

        // initialize inputs
        a_q314 = 0;
        b_q512 = 0;
        #10;

        // apply stimulus
        for (i = 0; i < N; i = i + 1) begin

            a_q314 = x_q314_mem[i];
            b_q512 = x_q512_mem[i];
            #10;

            // write outputs
            $fdisplay(f_sum, "%d", sum_q614);
            $fdisplay(f_sub, "%d", sub_q614);
            $fdisplay(f_mul, "%d", mul_q926);

            // limit waveform dumping
            dump_count = dump_count + 1;
            if (dump_count == 240)
                $dumpoff;
        end

        $fclose(f_sum);
        $fclose(f_sub);
        $fclose(f_mul);

        $display("Simulation complete. Output files generated.");
        $finish;
    end

endmodule
