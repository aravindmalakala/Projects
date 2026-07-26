module immediate_generator (

    input  wire [31:0] instruction,
    input  wire [2:0]  imm_type,

    output reg  [63:0] imm_out

);


always @(*) begin

    case(imm_type)

        // I-Type Immediate
        3'b000: begin

            imm_out = {{52{instruction[31]}},
                       instruction[31:20]};

        end


        // S-Type Immediate
        3'b001: begin

            imm_out = {{52{instruction[31]}},
                       instruction[31:25],
                       instruction[11:7]};

        end


        // B-Type Immediate
        3'b010: begin

            imm_out = {{51{instruction[31]}},
                       instruction[31],
                       instruction[7],
                       instruction[30:25],
                       instruction[11:8],
                       1'b0};

        end


        // U-Type Immediate
        3'b011: begin

            imm_out = {{32{instruction[31]}},
                       instruction[31:12],
                       12'b0};

        end


        // J-Type Immediate
        3'b100: begin

            imm_out = {{43{instruction[31]}},
                       instruction[31],
                       instruction[19:12],
                       instruction[20],
                       instruction[30:21],
                       1'b0};

        end


        default: begin

            imm_out = 64'd0;

        end


    endcase

end


endmodule