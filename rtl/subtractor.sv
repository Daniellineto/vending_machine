module subtractor (
    input  logic change_en,
    input  logic [7:0] credit,
    input  logic [7:0] price,
    output logic [7:0] change
);

    assign change = change_en ? (credit - price) : 8'd0;

endmodule
