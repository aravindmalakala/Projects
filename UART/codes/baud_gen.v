module baud_gen(
    input clk,
    input rst,
    output reg baud_tick
);

reg [12:0] counter;

always @(posedge clk or posedge rst)
begin
    if(rst)
    begin
        counter <= 13'd0;
        baud_tick <= 1'b0;
    end
    else
    begin
        if(counter == 13'd5207)
        begin
            counter <= 13'd0;
            baud_tick <= 1'b1;
        end
        else
        begin
            counter <= counter + 1'b1;
            baud_tick <= 1'b0;
        end
    end
end

endmodule