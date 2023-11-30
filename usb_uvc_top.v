//-----------------------------------------------------------------
//                       USB Serial Port
//                            V0.1
//                     Ultra-Embedded.com
//                       Copyright 2020
//
//                 Email: admin@ultra-embedded.com
//
//                         License: LGPL
//-----------------------------------------------------------------
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------

//-----------------------------------------------------------------
//                          Generated File
//-----------------------------------------------------------------
`include "usb_defs.v"
`include "uvc_defs.v"

module usb_uvc_top
//-----------------------------------------------------------------
// Ports
//-----------------------------------------------------------------
(
    // Inputs
     input           clk_i
    ,input           rst_i
    ,input  [  7:0]  ulpi_data_out_i
    ,input           ulpi_dir_i
    ,input           ulpi_nxt_i

    // Outputs
    ,output [  7:0]  ulpi_data_in_o
    ,output          ulpi_stp_o
);

wire  [  7:0]  utmi_data_out_w;
wire  [  7:0]  usb_rx_data_w;
wire           usb_tx_accept_w;
wire           enable_w = 1'h1;
wire           sof;
wire  [  1:0]  utmi_xcvrselect_w;
wire           utmi_termselect_w;
wire           utmi_rxvalid_w;
wire  [  1:0]  utmi_op_mode_w;
wire  [  7:0]  utmi_data_in_w;
wire           utmi_rxerror_w;
wire           utmi_rxactive_w;
wire  [  1:0]  utmi_linestate_w;
wire           usb_tx_valid_w;
wire           usb_rx_accept_w;
wire           utmi_dppulldown_w;
wire  [  7:0]  usb_tx_data_w;
wire           usb_rx_valid_w;
wire           utmi_txready_w;
wire           utmi_txvalid_w;
wire           utmi_dmpulldown_w;

wire [7:0]     usb_txdat;
reg  [9:0]     txdat_len;
reg            usb_txval;
wire           usb_txact;
reg  [1:0]     iso_pid_sel;
wire [7:0]     frame_idx;
wire [31:0]    frame_pts;

usb_uvc_core
u_usb_uvc_core
(
    // Inputs
     .clk_i(clk_i)
    ,.rst_i(rst_i)
    ,.enable_i(enable_w)
    ,.utmi_data_in_i(utmi_data_in_w)
    ,.utmi_txready_i(utmi_txready_w)
    ,.utmi_rxvalid_i(utmi_rxvalid_w)
    ,.utmi_rxactive_i(utmi_rxactive_w)
    ,.utmi_rxerror_i(utmi_rxerror_w)
    ,.utmi_linestate_i(utmi_linestate_w)
    ,.inport_valid_i(usb_tx_valid_w)
    ,.inport_data_i(usb_tx_data_w)
    ,.inport_len_i(txdat_len)
    ,.iso_pid_sel_i(iso_pid_sel)
    ,.frame_i(frame_idx)
    ,.pts_i(frame_pts)

    // Outputs
    ,.utmi_data_out_o(utmi_data_out_w)
    ,.utmi_txvalid_o(utmi_txvalid_w)
    ,.utmi_op_mode_o(utmi_op_mode_w)
    ,.utmi_xcvrselect_o(utmi_xcvrselect_w)
    ,.utmi_termselect_o(utmi_termselect_w)
    ,.utmi_dppulldown_o(utmi_dppulldown_w)
    ,.utmi_dmpulldown_o(utmi_dmpulldown_w)
    ,.inport_accept_o(usb_tx_accept_w)
    ,.txact_o(usb_txact)
    ,.sof_o(sof)
);


ulpi_wrapper
u_usb_phy
(
    // Inputs
     .ulpi_clk60_i(clk_i)
    ,.ulpi_rst_i(rst_i)
    ,.ulpi_data_out_i(ulpi_data_out_i)
    ,.ulpi_dir_i(ulpi_dir_i)
    ,.ulpi_nxt_i(ulpi_nxt_i)
    ,.utmi_data_out_i(utmi_data_out_w)
    ,.utmi_txvalid_i(utmi_txvalid_w)
    ,.utmi_op_mode_i(utmi_op_mode_w)
    ,.utmi_xcvrselect_i(utmi_xcvrselect_w)
    ,.utmi_termselect_i(utmi_termselect_w)
    ,.utmi_dppulldown_i(utmi_dppulldown_w)
    ,.utmi_dmpulldown_i(utmi_dmpulldown_w)

    // Outputs
    ,.ulpi_data_in_o(ulpi_data_in_o)
    ,.ulpi_stp_o(ulpi_stp_o)
    ,.utmi_data_in_o(utmi_data_in_w)
    ,.utmi_txready_o(utmi_txready_w)
    ,.utmi_rxvalid_o(utmi_rxvalid_w)
    ,.utmi_rxactive_o(utmi_rxactive_w)
    ,.utmi_rxerror_o(utmi_rxerror_w)
    ,.utmi_linestate_o(utmi_linestate_w)
);

//-----------------------------------------------------------------
// Data PIDs
//-----------------------------------------------------------------
`define MFRAME_PACKETS3
`define HSSUPPORT

always @(posedge clk_i or posedge rst_i) begin
    if(rst_i) begin
        `ifdef HSSUPPORT
            `ifdef MFRAME_PACKETS3
                iso_pid_sel <= 2'd2;//DATA2
            `elsif MFRAME_PACKETS2
                iso_pid_sel <= 2'd1;//DATA1
            `else
                iso_pid_sel <= 2'd1;//DATA1
            `endif
        `else
            iso_pid_sel <= 2'd0;//DATA0
        `endif
    end
    else begin
        `ifdef HSSUPPORT
            `ifdef MFRAME_PACKETS3
                if (sof) begin
                    if (fifo_afull) begin
                        iso_pid_sel <= 2'd2;//DATA2
                    end
                    else if (fifo_aempty) begin
                        iso_pid_sel <= 2'd0;//DATA0
                    end
                    else begin
                        iso_pid_sel <= 2'd1;//DATA1
                    end
                end
            `elsif MFRAME_PACKETS2
                if (sof) begin
                    //if (fifo_afull) begin
                    //    iso_pid_sel <= 4'b0111;//DATA2
                    //end
                    //else if (fifo_aempty) begin
                    //    iso_pid_sel <= 4'b0011;//DATA0
                    //end
                    //else begin
                    //    iso_pid_sel <= 4'b1011;//DATA1
                    //end
                    iso_pid_sel <= 2'd2;//DATA2
                end
            `else
                iso_pid_sel <= 2'd0;//DATA0
            `endif
        `else
            iso_pid_sel <= 2'd0;//DATA0
        `endif
    end
end

//-----------------------------------------------------------------
// UVC Frame Data
//-----------------------------------------------------------------

wire [7:0] frame_data;
wire frame_dval;

wire fifo_afull;
wire fifo_aempty;
wire fifo_empty;
wire [7:0]  fifo_rdat;
wire        fifo_rden;
reg         fifo_rval;
wire [11:0] fifo_wnum;

assign usb_tx_data_w = fifo_rdat[7:0];
assign fifo_rden = usb_txact & usb_tx_accept_w;

frame u_frame
(
     .CLK_I       (clk_i     )      //clock
    ,.RST_I       (rst_i     )      //reset
    ,.FIFO_AFULL_I(fifo_afull)      //
    ,.FIFO_EMPTY_I(fifo_empty)      //
    ,.SOF_I       (sof       )      //
    ,.DATA_O      (frame_data)      //
    ,.DVAL_O      (frame_dval)      //
    ,.FRAME_O     (frame_idx )
    ,.PTS_O       (frame_pts )
);

fifo_sc_top u_fifo_sc_top(
     .Clk         (clk_i) //input Clk
    ,.Reset       (rst_i  ) //input Reset
    ,.WrEn        (frame_dval) //input WrEn
    ,.Data        (frame_data) //input [7:0] Data
    ,.RdEn        (fifo_rden) //input RdEn
    ,.Q           (fifo_rdat) //output [7:0] Q
    ,.Wnum        (fifo_wnum) //output [11:0] Wnum
    ,.Almost_Empty(fifo_aempty) //output Almost_Empty
    ,.Almost_Full (fifo_afull) //output Almost_Full
    ,.Empty       (fifo_empty) //output Empty
    ,.Full        (Full) //output Full
);

assign usb_tx_valid_w = ~fifo_empty;
// assign usb_tx_valid_w = 1'b0;

//-----------------------------------------------------------------
// UVC Frame Data
//-----------------------------------------------------------------

always@(posedge clk_i or posedge rst_i) begin
    if (rst_i) 
        txdat_len <= 10'd0;
    else if(usb_txact)
        txdat_len <= txdat_len;
    else begin
        if (fifo_afull)
            txdat_len <= 10'd1023;
        else begin
            if (frame_dval)
                txdat_len <= 10'd0;
            else if (fifo_empty)
                txdat_len <= 10'd0;
            else if (fifo_aempty)
                txdat_len <= fifo_wnum + 10'd11;
            else
                txdat_len <= 10'd1023;
        end
    end
end

endmodule

