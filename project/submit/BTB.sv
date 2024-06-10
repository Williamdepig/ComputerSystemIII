module BTB #(
    parameter DEPTH = 32,
    parameter ADDR_WIDTH = 64,
    parameter STATE_NUM = 2
) (
    input clk,
    input rst,
    input stall,
    input [ADDR_WIDTH-1:0] pc_if,
    output jump_if,
    output [ADDR_WIDTH-1:0] pc_target_if,
    
    input [ADDR_WIDTH-1:0] pc_exe,
    input [ADDR_WIDTH-1:0] pc_target_exe,
    input jump_exe,
    input is_jump_exe
);

    localparam INDEX_BEGIN = 1;
    localparam INDEX_LEN = $clog2(DEPTH); // == log_2 (DEPTH) == 4
    localparam INDEX_END = INDEX_BEGIN+INDEX_LEN-1;  // == 4
    localparam TAG_BEGIN = INDEX_END+1; // == 5
    localparam TAG_END = ADDR_WIDTH-1;  // == 63
    localparam TAG_LEN = TAG_END-TAG_BEGIN+1; // 59

    typedef logic [TAG_LEN-1:0] tag_t; // 58:0
    typedef logic [INDEX_LEN-1:0] index_t; // 3:0
    typedef logic [STATE_NUM-1:0] state_t; // 1:0
    typedef logic [ADDR_WIDTH-1:0] addr_t; // 63:0

    typedef struct{
        tag_t tag;
        addr_t target;
        state_t state;
        logic valid;
    } BTBLine;

    BTBLine btb [DEPTH-1:0];

    tag_t tag_exe;
    index_t index_exe; 
    BTBLine btb_exe; 
    assign tag_exe = pc_exe[TAG_END:TAG_BEGIN];
    assign index_exe = pc_exe[INDEX_END:INDEX_BEGIN]; 
    assign btb_exe = btb[index_exe];

    
    tag_t tag_if;
    index_t index_if;
    BTBLine btb_if;
    assign tag_if = pc_if[TAG_END:TAG_BEGIN];
    assign index_if = pc_if[INDEX_END:INDEX_BEGIN];
    assign btb_if = btb[index_if];

    state_t next_state;
    integer i;
    logic lock;
    assign pc_target_if = btb_if.target;
    assign jump_if = btb_if.valid && btb_if.tag == tag_if ? btb_if.state[1] : 0;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                btb[i] <= '{default : 0};
            end
        end else if (is_jump_exe & ~lock) begin
            btb[index_exe].state <= next_state;
            btb[index_exe].target <= jump_exe ? pc_target_exe : btb[index_exe].target;
            btb[index_exe].valid <= 1;
            btb[index_exe].tag <= tag_exe;
        end
    end

    always @(*) begin
        next_state = 2'b00; 
        if (is_jump_exe) begin
            if (btb_exe.valid) begin
                case(btb_exe.state)
                    2'b00: next_state = jump_exe ? 2'b01 : 2'b00;
                    2'b01: next_state = jump_exe ? 2'b11 : 2'b00;
                    2'b10: next_state = jump_exe ? 2'b11 : 2'b00;
                    2'b11: next_state = jump_exe ? 2'b11 : 2'b10;
                    default: next_state = 2'b00;
                endcase
            end
            else begin
                next_state = 2'b00;
            end
        end
    end
    always @(posedge clk) begin
        if (rst) begin
            lock <= 0;
        end else if (stall) begin
            lock <= 1;
        end else begin
            lock <= 0;
        end

    end
endmodule