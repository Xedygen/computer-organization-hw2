module controller (
    input [6:0] op,
    input [2:0] funct3,
    input funct7_5,
    input zero,
    output resultsrc_0, resultsrc_1,
    output memwrite,
    output pcsrc, alusrc,
    output regwrite, jump,
    output [1:0] immsrc,
    output [2:0] alucontrol
);
    wire [1:0] aluop;
    wire branch;
    
    maindec md (
        .op(op),
        .resultsrc({resultsrc_1, resultsrc_0}),
        .memwrite(memwrite),
        .branch(branch),
        .alusrc(alusrc),
        .regwrite(regwrite),
        .jump(jump),
        .immsrc(immsrc),
        .aluop(aluop)
    );
    
    aludec ad (
        .opb5(op[5]),
        .funct3(funct3),
        .funct7_5(funct7_5),
        .aluop(aluop),
        .alucontrol(alucontrol)
    );
    
    assign pcsrc = jump | (branch & zero);
endmodule

module maindec (
    input [6:0] op,
    output reg [1:0] resultsrc,
    output reg memwrite,
    output reg branch,
    output reg alusrc,
    output reg regwrite,
    output reg jump,
    output reg [1:0] immsrc,
    output reg [1:0] aluop
);
    always @(*) begin
        case (op)
            7'b0000011: begin // lw
                regwrite = 1; immsrc = 2'b00; alusrc = 1; memwrite = 0;
                resultsrc = 2'b01; branch = 0; aluop = 2'b00; jump = 0;
            end
            7'b0100011: begin // sw
                regwrite = 0; immsrc = 2'b01; alusrc = 1; memwrite = 1;
                resultsrc = 2'bxx; branch = 0; aluop = 2'b00; jump = 0;
            end
            7'b0110011: begin // R-type
                regwrite = 1; immsrc = 2'bxx; alusrc = 0; memwrite = 0;
                resultsrc = 2'b00; branch = 0; aluop = 2'b10; jump = 0;
            end
            7'b1100011: begin // beq
                regwrite = 0; immsrc = 2'b10; alusrc = 0; memwrite = 0;
                resultsrc = 2'bxx; branch = 1; aluop = 2'b01; jump = 0;
            end
            7'b0010011: begin // I-type ALU
                regwrite = 1; immsrc = 2'b00; alusrc = 1; memwrite = 0;
                resultsrc = 2'b00; branch = 0; aluop = 2'b10; jump = 0; 
            end
            7'b1101111: begin // jal
                regwrite = 1; immsrc = 2'b11; alusrc = 1'bx; memwrite = 0;
                resultsrc = 2'b10; branch = 0; aluop = 2'bxx; jump = 1;
            end
            default: begin
                regwrite = 0; immsrc = 2'b00; alusrc = 0; memwrite = 0;
                resultsrc = 2'b00; branch = 0; aluop = 2'b00; jump = 0;
            end
        endcase
    end
endmodule

module aludec (
    input opb5,
    input [2:0] funct3,
    input funct7_5,
    input [1:0] aluop,
    output reg [2:0] alucontrol
);
    always @(*) begin
        case (aluop)
            2'b00: alucontrol = 3'b000; // add
            2'b01: alucontrol = 3'b001; // sub
            2'b10: begin // R-type or I-type ALU
                case (funct3)
                    3'b000: begin
                        if ({opb5, funct7_5} == 2'b11) alucontrol = 3'b001; // sub
                        else alucontrol = 3'b000; // add
                    end
                    3'b010: alucontrol = 3'b101; // slt, slti
                    3'b110: alucontrol = 3'b011; // or, ori
                    3'b111: alucontrol = 3'b010; // and, andi
                    3'b101: begin
                        if (funct7_5) alucontrol = 3'b100; // srai
                        else alucontrol = 3'bxxx;
                    end
                    default: alucontrol = 3'bxxx;
                endcase
            end
            default: alucontrol = 3'bxxx;
        endcase
    end
endmodule
