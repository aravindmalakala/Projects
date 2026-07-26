`timescale 1ns/1ps

module tb_division;

reg  signed [32:0] a;
reg  signed [32:0] b;
wire signed [32:0] div;

// LUT memory inside testbench
reg signed [32:0] lut_table [0:63];

integer file;
integer i;
integer val;
integer status;   // required for $fscanf

// Instantiate division module
division uut (
    .a(a),
    .b(b),
    .lut(lut_table),
    .div(div)
);

initial begin
    // read LUT
    file = $fopen("lut.txt","r");

    for(i=0;i<64;i=i+1) begin
        status = $fscanf(file,"%d\n",val);
        lut_table[i] = val;
    end

    $fclose(file);

    // write results
    file = $fopen("results.txt","w");

    a=15; b=23; #20;  $fwrite(file,"%0d %0d %0d\n",a,b,div);
    a=10; b=79; #20;  $fwrite(file,"%0d %0d %0d\n",a,b,div);
    a=25; b=113; #20; $fwrite(file,"%0d %0d %0d\n",a,b,div);
    a=17; b=199; #20; $fwrite(file,"%0d %0d %0d\n",a,b,div);
    a=8;  b=13;  #20; $fwrite(file,"%0d %0d %0d\n",a,b,div);
    a=12; b=17;  #20; $fwrite(file,"%0d %0d %0d\n",a,b,div);
    a=9;  b=19;  #20; $fwrite(file,"%0d %0d %0d\n",a,b,div);
    a=21; b=31;  #20; $fwrite(file,"%0d %0d %0d\n",a,b,div);
    a=25; b=41;  #20; $fwrite(file,"%0d %0d %0d\n",a,b,div);

    $fclose(file);
    $finish;
end

endmodule