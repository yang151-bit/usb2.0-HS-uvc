module usb_camera
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // output          uart_rx_o,
    // input           uart_tx_i,

    // ULPI Interface
    input           rst_n,
    output          ulpi_reset_o,
    inout [7:0]     ulpi_data_io,
    output          ulpi_stp_o,
    input           ulpi_nxt_i,
    input           ulpi_dir_i,
    input           ulpi_clk60_i
);

// USB clock / reset
wire usb_clk_w;
wire usb_rst_w;

wire clk_bufg_w;

assign clk_bufg_w = ~ulpi_clk60_i;
assign usb_clk_w = clk_bufg_w;

reg [3:0]  rst_q;

always @(posedge usb_clk_w or negedge rst_n) 
if (~rst_n)
    rst_q <= 4'b1111;
else
    rst_q <= {rst_q[2:0], 1'b0};

assign usb_rst_w = rst_q[3];

// ULPI Buffers
wire [7:0] ulpi_out_w;
wire [7:0] ulpi_in_w;
wire       ulpi_stp_w;


assign ulpi_data_io = ulpi_dir_i ? 8'hz : ulpi_out_w;
assign ulpi_in_w = ulpi_data_io;


assign ulpi_stp_o = ulpi_stp_w;

// USB Core
usb_uvc_top
u_usb_uvc_top
(
     .clk_i(usb_clk_w)
    ,.rst_i(usb_rst_w)

    // ULPI
    ,.ulpi_data_out_i(ulpi_in_w)
    ,.ulpi_dir_i(ulpi_dir_i)
    ,.ulpi_nxt_i(ulpi_nxt_i)
    ,.ulpi_data_in_o(ulpi_out_w)
    ,.ulpi_stp_o(ulpi_stp_w)
);

assign ulpi_reset_o = 1'b1;

endmodule