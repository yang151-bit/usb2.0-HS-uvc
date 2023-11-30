/******************************************************************************
Copyright 2022 GOWIN SEMICONDUCTOR CORPORATION

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

The Software is used with products manufacturered by GOWIN Semconductor only
unless otherwise authorized by GOWIN Semiconductor.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
******************************************************************************/
`include "uvc_defs.v"
module frame
(
    input              CLK_I     ,       //clock
    input              RST_I     ,       //reset
    input              FIFO_AFULL_I,     //
    input              FIFO_EMPTY_I,     //
    input              SOF_I     ,       //
    output [7:0]       DATA_O    ,       //
    output             DVAL_O    ,       //
    output [7:0]       FRAME_O   ,
    output [31:0]      PTS_O
);

localparam HERADER_LEN = 12;
localparam WIDTH  = `WIDTH ;//480;
localparam HEIGHT = `HEIGHT;//20;//320;
localparam PAYLOAD_SIZE = `PAYLOAD_SIZE;
localparam FRAME_SIZE = WIDTH * HEIGHT * 2;

//==============================================================
//======Header Generate
reg sof_d0;
reg sof_d1;
wire sof_rise;
always @(posedge CLK_I or posedge RST_I) begin
    if (RST_I) begin
        sof_d0 <= 1'b0;
        sof_d1 <= 1'b0;
    end
    else begin
        sof_d0 <= SOF_I;
        sof_d1 <= sof_d0;
    end
end
assign sof_rise = (sof_d0)&(~sof_d1);


reg [10:0] sofCounts;
reg [10:0] sofCounts_reg;
reg [3:0] sof_1ms;
always @(posedge CLK_I or posedge RST_I) begin
    if (RST_I) begin
        sofCounts <= 11'd0;
        sof_1ms <= 4'd0;
    end
    else begin
        if (sof_rise) begin
            if (sof_1ms >= 4'd7) begin
                sof_1ms <= 4'd0;
            end
            else begin
                sof_1ms <= sof_1ms + 4'd1;
            end
        end
        if ((sof_rise)&&(sof_1ms == 3'd7)) begin
            sofCounts <= sofCounts + 'd1;
        end
    end
end

reg [31:0] pts;
reg [31:0] pts_reg;
always @(posedge CLK_I or posedge RST_I) begin
    if (RST_I) begin
        pts <= 32'd0;
    end
    else begin
        pts <= pts + 32'd1;
    end
end

//==============================================================
//======Frame Start and Over
reg [7:0] frame_r;
reg [15:0] byte_cnt;
reg [11:0] color_cnt;
reg [31:0] expectPixels;
reg frame_valid;
assign DATA_O = dout;
assign DVAL_O = dval;
reg [7:0] moving_pixel;
reg [7:0] dout;
reg       dval;
reg pkt_end;

assign FRAME_O = pkt_end ? frame_r | 8'h02 : frame_r;
assign PTS_O   = pts_reg;

always @(posedge CLK_I or posedge RST_I) begin
    if(RST_I)
        pkt_end <= 0;
    else if(expectPixels > FRAME_SIZE - PAYLOAD_SIZE - HERADER_LEN)
        pkt_end <= 1;
    else if(~frame_valid)
        pkt_end <= 0;
end

always @(posedge CLK_I or posedge RST_I) begin
    if (RST_I) begin
        frame_valid <= 1'b0;
        dout <= 8'd0;
        dval <= 1'd0;
        byte_cnt <= 16'd0;
        color_cnt <= 12'd0;
        expectPixels <= 32'd0;
        frame_r <= 8'h0C;
        pts_reg <= 32'd0;
        sofCounts_reg <= 11'd0;
        moving_pixel <= 8'd0;
    end
    else
        if (frame_valid) begin
            if(FIFO_AFULL_I == 1'b0) begin
                dval <= 1'b1;
                byte_cnt <= byte_cnt + 16'd1;
                if (color_cnt >= 12'd480 - 1) begin
                    color_cnt <= 12'd0;
                end
                else begin
                    color_cnt <= color_cnt + 4'd1;
                end
                if (expectPixels >= FRAME_SIZE - 1'b1) begin
                    frame_valid <= 1'b0;
                    expectPixels <= 32'd0;
                    frame_r <= {frame_r[7:1],frame_r[0]^1'b1};
                end
                else begin
                    expectPixels <= expectPixels + 1'b1;
                end
                //if (expectPixels <= 480 - 1'b1) begin
                //    dout <= 8'h1F;
                //end
                //else begin
                //    dout <= 8'h1F;
                //end

                //if (1) // best case
                ////if (byte_cnt<1024) //worst case
                ////if (byte_cnt<16) //The more consequitive ones there are the more times txready will go low causing the buffer to hold data
                //   dout <= 8'hFF;
                //else
                //   dout <= 0;
                    //*/
                ///*
                if (color_cnt < 12'd80 - moving_pixel) begin //RED
                    case (byte_cnt[1:0])
                        2'd0 : dout <= 8'h20;
                        2'd1 : dout <= 8'h60;
                        2'd2 : dout <= 8'h20;
                        2'd3 : dout <= 8'hDC;
                    endcase
                end
                else if (color_cnt < 12'd160 - moving_pixel) begin //GREEN
                    case (byte_cnt[1:0])
                        2'd0 : dout <= 8'h00;//20;//
                        2'd1 : dout <= 8'h00;//60;//
                        2'd2 : dout <= 8'h00;//20;//
                        2'd3 : dout <= 8'h00;//DC;//
                    endcase
                end
                else if (color_cnt < 12'd240 - moving_pixel) begin //BLUE
                    case (byte_cnt[1:0])
                        2'd0 : dout <= 8'h10;//20;//
                        2'd1 : dout <= 8'hD0;//60;//
                        2'd2 : dout <= 8'h10;//20;//
                        2'd3 : dout <= 8'h70;//DC;//
                    endcase
                end
                else if (color_cnt < 12'd320 - moving_pixel) begin //RED
                    case (byte_cnt[1:0])
                        2'd0 : dout <= 8'h20;//20;//
                        2'd1 : dout <= 8'h60;//60;//
                        2'd2 : dout <= 8'h20;//20;//
                        2'd3 : dout <= 8'hDC;//DC;//
                    endcase
                end
                else if (color_cnt < 12'd400 - moving_pixel) begin //GREEN
                    case (byte_cnt[1:0])
                        2'd0 : dout <= 8'h00;//20;//
                        2'd1 : dout <= 8'h00;//60;//
                        2'd2 : dout <= 8'h00;//20;//
                        2'd3 : dout <= 8'h00;//DC;//
                    endcase
                end
                else if (color_cnt < 12'd480 - moving_pixel) begin //BLUE
                    case (byte_cnt[1:0])
                        2'd0 : dout <= 8'h10;//20;//
                        2'd1 : dout <= 8'hD0;//60;//
                        2'd2 : dout <= 8'h10;//20;//
                        2'd3 : dout <= 8'h70;//DC;//
                    endcase
                end
                else begin
                    case (byte_cnt[1:0])
                        2'd0 : dout <= 8'h20;
                        2'd1 : dout <= 8'h60;
                        2'd2 : dout <= 8'h20;
                        2'd3 : dout <= 8'hDC;
                    endcase
                end
                //*/
            end
            else begin
                dval <= 1'b0;
            end
        end
        else if ((sof_cnt == 16'd0)&&(sof_rise)) begin
            if (FIFO_EMPTY_I) begin
                if (color_cnt >= 480) begin
                    color_cnt <= 12'd4;
                end
                else if (color_cnt >= 476) begin
                    color_cnt <= 12'd0;
                end
                else begin
                    color_cnt <= color_cnt + 12'd4;
                end
                frame_valid <= 1'b1;
                pts_reg <= pts;
                sofCounts_reg <= sofCounts;
            end
            byte_cnt <= 16'd0;
            //color_cnt <= 4'd0;
            expectPixels <= 32'd0;
            dout <= 8'd0;
            dval <= 1'd0;
        end
        else begin
            byte_cnt <= 16'd0;
            //color_cnt <= 4'd0;
            expectPixels <= 32'd0;
            dout <= 8'd0;
            dval <= 1'd0;
        end
end

//==============================================================
//======microframe control frame rate
reg [15:0] sof_cnt;
always @(posedge CLK_I or posedge RST_I) begin
    if (RST_I) begin
        sof_cnt <= 16'd0;
    end
    else begin
        if (sof_rise) begin
            if (sof_cnt >= 103) begin
                sof_cnt <= 16'd0;
            end
            else begin
                sof_cnt <= sof_cnt + 16'd1;
            end
        end
    end
end



//==============================================================
//==============================================================
//==============================================================
//==============================================================
//==============================================================













endmodule




