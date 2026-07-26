module exp_2 (
    input  signed [17:0] a_q314,    // Q(3,14)
    input  signed [17:0] b_q512,    // Q(5,12)

    output signed [20:0] sum_q614,  // Q(6,14)
    output signed [20:0] sub_q614,  // Q(6,14)
    output signed [35:0] mul_q926   // Q(9,26)
);

    //ADD/SUB ALIGNMENT 

    wire signed [20:0] a_q614;
    assign a_q614 = {{3{a_q314[17]}}, a_q314};

    wire signed [20:0] b_q614;
    assign b_q614 = {{1{b_q512[17]}}, b_q512, 2'b00};

    assign sum_q614 = a_q614 + b_q614;
    assign sub_q614 = a_q614 - b_q614;

    //SHIFT-ADD MULTIPLIER

    wire signed [35:0] a_ext;
    wire signed [35:0] partial [17:0];
    wire signed [35:0] mul_temp;

    assign a_ext = {{18{a_q314[17]}}, a_q314};

    genvar i;
    generate
        for(i = 0; i < 17; i = i + 1) begin : MULT_STAGE
            assign partial[i] = b_q512[i] ? (a_ext <<< i) : 36'sd0;
        end
    endgenerate

    // sign bit handling
    assign partial[17] = b_q512[17] ? -(a_ext <<< 17) : 36'sd0;

    assign mul_temp =
          partial[0]  + partial[1]  + partial[2]  + partial[3]  +
          partial[4]  + partial[5]  + partial[6]  + partial[7]  +
          partial[8]  + partial[9]  + partial[10] + partial[11] +
          partial[12] + partial[13] + partial[14] + partial[15] +
          partial[16] + partial[17];

    assign mul_q926 = mul_temp;

endmodule
