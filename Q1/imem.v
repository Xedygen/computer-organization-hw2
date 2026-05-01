module imem (
    input [31:0] a,
    output [31:0] rd
);
    reg [31:0] ROM[0:63];

    initial begin
        $readmemh("memfile.hex", ROM);
    end

    assign rd = ROM[a[31:2]];
endmodule
