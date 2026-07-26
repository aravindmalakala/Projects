module alu_control (

    input  wire [1:0] alu_op,
    input  wire [2:0] funct3,
    input  wire       funct7,
    output reg  [3:0] alu_control

);
always @(*) begin
    case(alu_op)

        // Load and Store instructions
        // Always require ADD for address calculation
        2'b00: begin
            alu_control = 4'b0000;

        end
        // Branch instructions
        // BEQ uses subtraction
        2'b01: begin
            alu_control = 4'b0001;
        end
        // R-Type instructions
        2'b10: begin
            case(funct3) // ADD / SUB
                3'b000: begin
                    if(funct7)
                        alu_control = 4'b0001; // SUB

                    else
                        alu_control = 4'b0000; // ADD

                end
                // SLL
                3'b001: begin

                    alu_control = 4'b0101;

                end
                // SLT
                3'b010: begin

                    alu_control = 4'b1000;
                end
                // XOR
                3'b100: begin

                    alu_control = 4'b0100;

                end
                // SRL / SRA
                3'b101: begin
                    if(funct7)
                        alu_control = 4'b0111; // SRA

                    else
                        alu_control = 4'b0110; // SRL

                end
                // OR
                3'b110: begin

                    alu_control = 4'b0011;
                end
                // AND
                3'b111: begin

                    alu_control = 4'b0010;

                end
                default: begin
                    alu_control = 4'b0000;
                end
            endcase

        end
        default: begin

            alu_control = 4'b0000;
        end
    endcase
end
endmodule