`timescale 1ns/1ps

module exp_fixed_point;

    integer n, i;

    // Parameters
    integer FS = 48000;
    integer N  = 48000;

    // Sine LUT 
    real sine_lut [0:47];
    real x;

    // Quantized values
    real x_2_14, x_4_12, x_8_4;
    real e_2_14, e_4_12, e_8_4;

    integer q214, q412, q84;

    // File handles
    integer f_x, f_q214, f_q412, f_q84;
    integer f_e214, f_e412, f_e84;

    initial begin
        // Generating LUT
        for (i = 0; i < 48; i = i + 1)
            sine_lut[i] = 2.0 * $sin(2.0 * 3.14159265359 * i / 48.0);

        // Open files
        f_x    = $fopen("x.txt", "w");

        f_q214 = $fopen("x_2_14.txt", "w");
        f_q412 = $fopen("x_4_12.txt", "w");
        f_q84  = $fopen("x_8_4.txt", "w");

        f_e214 = $fopen("err_2_14.txt", "w");
        f_e412 = $fopen("err_4_12.txt", "w");
        f_e84  = $fopen("err_8_4.txt", "w");

        // For loading data
        for (n = 0; n < N; n = n + 1) begin

            x = sine_lut[n % 48];

            // quantization
            q214 = $rtoi(x * (1 << 14));
            q412 = $rtoi(x * (1 << 12));
            q84  = $rtoi(x * (1 << 4));

            x_2_14 = q214 / (1.0 * (1 << 14));
            x_4_12 = q412 / (1.0 * (1 << 12));
            x_8_4  = q84  / (1.0 * (1 << 4));

            // Errors 
            e_2_14 = x - x_2_14;
            e_4_12 = x - x_4_12;
            e_8_4  = x - x_8_4;

            // Write files
            $fwrite(f_x,    "%f\n", x);
            $fwrite(f_q214, "%f\n", x_2_14);
            $fwrite(f_q412, "%f\n", x_4_12);
            $fwrite(f_q84,  "%f\n", x_8_4);

            $fwrite(f_e214, "%f\n", e_2_14);
            $fwrite(f_e412, "%f\n", e_4_12);
            $fwrite(f_e84,  "%f\n", e_8_4);
        end

        // Close files
        $fclose(f_x);
        $fclose(f_q214);
        $fclose(f_q412);
        $fclose(f_q84);
        $fclose(f_e214);
        $fclose(f_e412);
        $fclose(f_e84);

        $finish;
    end

endmodule
