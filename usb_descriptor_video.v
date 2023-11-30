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
`include "usb_defs.v"
`include "uvc_defs.v"
module usb_desc #(
        // Vendor ID to report in device descriptor.
        parameter VENDORID = 16'h0403,//fb9a;//16'hfb9a;//16'h08bb;
        // Product ID to report in device descriptor.
        parameter PRODUCTID = 16'h6010,//fb9a;//16'hfb9a;//16'h27c6;
        // Product version to report in device descriptor.
        parameter VERSIONBCD = 16'h0100,//16'h0100;
        // Optional description of manufacturer (max 126 characters).
        parameter VENDORSTR = "Gowinsemi",
        parameter VENDORSTR_LEN = 9,//66;
        // Optional description of product (max 126 characters).
        parameter PRODUCTSTR = "Gowin USB Video",
        parameter PRODUCTSTR_LEN = 15,//34;
        // Optional product serial number (max 126 characters).
        parameter SERIALSTR = "Blank string",
        parameter SERIALSTR_LEN = 0,
        // Support high speed mode.
        parameter HSSUPPORT = 0,
        // Set to true if the device never draws power from the USB bus.
        parameter SELFPOWERED = 0
)
(

        input        CLK                  ,
        input        RESET                ,
        input  [9:0] i_descrom_raddr        ,
        output [7:0] o_descrom_rdat         ,
        output [9:0] o_desc_dev_addr        ,
        output [7:0] o_desc_dev_len         ,
        output [9:0] o_desc_qual_addr       ,
        output [7:0] o_desc_qual_len        ,
        output [9:0] o_desc_fscfg_addr      ,
        output [7:0] o_desc_fscfg_len       ,
        output [9:0] o_desc_hscfg_addr      ,
        output [7:0] o_desc_hscfg_len       ,
        output [9:0] o_desc_oscfg_addr      ,
        output [9:0] o_desc_strlang_addr    ,
        output [9:0] o_desc_strvendor_addr  ,
        output [7:0] o_desc_strvendor_len   ,
        output [9:0] o_desc_strproduct_addr ,
        output [7:0] o_desc_strproduct_len  ,
        output [9:0] o_desc_strserial_addr  ,
        output [7:0] o_desc_strserial_len   ,
        output       o_descrom_have_strings
);

    // Truncate descriptor data to keep only the necessary pieces;
    // either just the full-speed stuff, || full-speed plus high-speed,
    // || full-speed plus high-speed plus string descriptors.


    // Descriptor ROM
    //   addr   0 ..  17 : device descriptor
    //   addr  20 ..  29 : device qualifier
    //   addr  32 ..  98 : full speed configuration descriptor 
    //   addr 112 .. 178 : high speed configuration descriptor
    //   addr 179 :        other_speed_configuration hack
    //   addr 192 .. 195 : string descriptor 0 = supported languages
    //   addr 196 ..     : 3 string descriptors: vendor, product, serial
    localparam  DESC_DEV_ADDR         = 0;
    localparam  DESC_DEV_LEN          = 18;
    localparam  DESC_QUAL_ADDR        = 20;
    localparam  DESC_QUAL_LEN         = 10;
    localparam  DESC_FSCFG_ADDR       = 32;
    localparam  DESC_FSCFG_LEN        = 174;
    localparam  DESC_HSCFG_ADDR       = DESC_FSCFG_ADDR;
    localparam  DESC_HSCFG_LEN        = DESC_FSCFG_LEN;
    localparam  DESC_OSCFG_ADDR       = DESC_HSCFG_ADDR + DESC_HSCFG_LEN;
    localparam  DESC_OSCFG_LEN        = 13;
    localparam  DESC_STRLANG_ADDR     = DESC_OSCFG_ADDR + DESC_OSCFG_LEN;
    localparam  DESC_STRVENDOR_ADDR   = DESC_STRLANG_ADDR + 4;
    localparam  DESC_STRVENDOR_LEN    = 2 + 2*VENDORSTR_LEN;
    localparam  DESC_STRPRODUCT_ADDR  = DESC_STRVENDOR_ADDR + DESC_STRVENDOR_LEN;
    localparam  DESC_STRPRODUCT_LEN   = 2 + 2*PRODUCTSTR_LEN;
    localparam  DESC_STRSERIAL_ADDR   = DESC_STRPRODUCT_ADDR + DESC_STRPRODUCT_LEN;
    localparam  DESC_STRSERIAL_LEN    = 2 + 2*SERIALSTR_LEN;
    localparam  DESC_END_ADDR         = DESC_STRSERIAL_ADDR + DESC_STRSERIAL_LEN;
 
    assign  o_desc_dev_addr        = DESC_DEV_ADDR        ;
    assign  o_desc_dev_len         = DESC_DEV_LEN         ;
    assign  o_desc_qual_addr       = DESC_QUAL_ADDR       ;
    assign  o_desc_qual_len        = DESC_QUAL_LEN        ;
    assign  o_desc_fscfg_addr      = DESC_FSCFG_ADDR      ;
    assign  o_desc_fscfg_len       = DESC_FSCFG_LEN       ;
    assign  o_desc_hscfg_addr      = DESC_HSCFG_ADDR      ;
    assign  o_desc_hscfg_len       = DESC_HSCFG_LEN       ;
    assign  o_desc_oscfg_addr      = DESC_OSCFG_ADDR      ;
    assign  o_desc_strlang_addr    = DESC_STRLANG_ADDR    ;
    assign  o_desc_strvendor_addr  = DESC_STRVENDOR_ADDR  ;
    assign  o_desc_strvendor_len   = DESC_STRVENDOR_LEN   ;
    assign  o_desc_strproduct_addr = DESC_STRPRODUCT_ADDR ;
    assign  o_desc_strproduct_len  = DESC_STRPRODUCT_LEN  ;
    assign  o_desc_strserial_addr  = DESC_STRSERIAL_ADDR  ;
    assign  o_desc_strserial_len   = DESC_STRSERIAL_LEN   ;


    // Truncate descriptor data to keep only the necessary pieces;
    // either just the full-speed stuff, || full-speed plus high-speed,
    // || full-speed plus high-speed plus string descriptors.
    localparam descrom_have_strings = (VENDORSTR_LEN > 0 || PRODUCTSTR_LEN > 0 || SERIALSTR_LEN > 0);
    localparam descrom_len = (HSSUPPORT || descrom_have_strings)?((descrom_have_strings)? DESC_END_ADDR : DESC_OSCFG_ADDR + DESC_OSCFG_LEN) : DESC_FSCFG_ADDR + DESC_FSCFG_LEN;
    assign o_descrom_have_strings = descrom_have_strings;
    reg [7:0] descrom [0 : descrom_len-1];
    integer i;
    integer z;
    
    always @(posedge CLK or posedge RESET)
      if(RESET) begin
        // 18 bytes device descriptor
        descrom[0]  <= 8'h12;// bLength = 18 bytes
        descrom[1]  <= `USB_DESCTYPE_DEVICE;// bDescriptorType = device descriptor
        descrom[2]  <= (HSSUPPORT)? 8'h00 :8'h10;// bcdUSB = 1.10 || 2.00
        descrom[3]  <= (HSSUPPORT)? 8'h02 :8'h01;
        descrom[4]  <= 8'hEF;// bDeviceClass = USB Miscellaneous Class
        descrom[5]  <= 8'h02;// bDeviceSubClass = Common Class
        descrom[6]  <= 8'h01;// bDeviceProtocol = Interface Association Descriptor
        descrom[7]  <= 8'h40;// 08: 40:bMaxPacketSize0 = 64 bytes
        descrom[8]  <= VENDORID[7 : 0];// idVendor
        descrom[9]  <= VENDORID[15 :8];
        descrom[10] <= PRODUCTID[7 :0];// idProduct
        descrom[11] <= PRODUCTID[15 :8];
        descrom[12] <= VERSIONBCD[7 : 0];// bcdDevice
        descrom[13] <= VERSIONBCD[15 : 8];
        descrom[14] <= (VENDORSTR_LEN > 0)?  8'h01: 8'h00;// iManufacturer
        descrom[15] <= (PRODUCTSTR_LEN > 0)? 8'h02: 8'h00;// iProduct
        descrom[16] <= (SERIALSTR_LEN > 0)?  8'h03: 8'h00;// iSerialNumber
        descrom[17] <= 8'h01;                  // bNumConfigurations = 1
        // 2 bytes padding
        descrom[18] <= 8'h00;
        descrom[19] <= 8'h00;
//======USB Device Qualifier Configuration Descriptor
        // 10 bytes device qualifier
        descrom[DESC_QUAL_ADDR + 0] <= 8'h0a;// bLength = 10 bytes
        descrom[DESC_QUAL_ADDR + 1] <= 8'h06;// bDescriptorType = device qualifier
        descrom[DESC_QUAL_ADDR + 2] <= 8'h00;
        descrom[DESC_QUAL_ADDR + 3] <= 8'h02;// bcdUSB = 2.0
        descrom[DESC_QUAL_ADDR + 4] <= 8'h01;// bDeviceClass = Communication Device Class
        descrom[DESC_QUAL_ADDR + 5] <= 8'h00;// bDeviceSubClass = none
        descrom[DESC_QUAL_ADDR + 6] <= 8'h00;// bDeviceProtocol = none
        descrom[DESC_QUAL_ADDR + 7] <= 8'h40;// bMaxPacketSize0 = 64 bytes
        descrom[DESC_QUAL_ADDR + 8] <= 8'h00;// bNumConfigurations = 0
        descrom[DESC_QUAL_ADDR + 9] <= 8'h00;// bReserved
         // 2 bytes padding
        descrom[DESC_QUAL_ADDR + 10] <= 8'h00;
        descrom[DESC_QUAL_ADDR + 11] <= 8'h00;
//======USB Configuration Descriptor
        //---------------- Configuration header -----------------
        descrom[DESC_FSCFG_ADDR + 0] <= 8'h09;// 0 bLength = 9 bytes
        descrom[DESC_FSCFG_ADDR + 1] <= `USB_DESCTYPE_CONFIGURATION;// 1 bDescriptorType = configuration descriptor
        descrom[DESC_FSCFG_ADDR + 2] <= DESC_FSCFG_LEN[7:0];// 2 wTotalLength L
        descrom[DESC_FSCFG_ADDR + 3] <= DESC_FSCFG_LEN[15:8];// 3 wTotalLength H
        descrom[DESC_FSCFG_ADDR + 4] <= 8'h02;// 4 bNumInterfaces = 2
        descrom[DESC_FSCFG_ADDR + 5] <= 8'h01;// 5 bConfigurationValue = 1
        descrom[DESC_FSCFG_ADDR + 6] <= 8'h00;// 6 iConfiguration - index of string
        descrom[DESC_FSCFG_ADDR + 7] <= (SELFPOWERED)? 8'hc0 : 8'h80; // 7 bmAttributes
        descrom[DESC_FSCFG_ADDR + 8] <= 8'hFA;// 8 bMaxPower = 500 mA
        //---------------- Interface Association Descriptor -----------------
        descrom[DESC_FSCFG_ADDR + 9 + 0]  <= 8'h08;// 0 bLength
        descrom[DESC_FSCFG_ADDR + 9 + 1] <= `USB_DESCTYPE_INTERFACE_ASSOCIATION;// 1 bDescriptorType - Interface Association
        descrom[DESC_FSCFG_ADDR + 9 + 2] <= 8'h00;// 2 bFirstInterface - VideoControl i/f
        descrom[DESC_FSCFG_ADDR + 9 + 3] <= 8'h02;// 3 bInterfaceCount - 2 Interfaces
        descrom[DESC_FSCFG_ADDR + 9 + 4] <= `USB_CLASS_VIDEO;// 4 bFunctionClass - Video Class
        descrom[DESC_FSCFG_ADDR + 9 + 5] <= `USB_VIDEO_INTERFACE_COLLECTION;// 5 bFunctionSubClass - Video Interface Collection
        descrom[DESC_FSCFG_ADDR + 9 + 6] <= 8'h00;// 6 bFunctionProtocal - No protocal
        descrom[DESC_FSCFG_ADDR + 9 + 7] <= 8'h02;// 7 iFunction - index of string
        //---------------- Video Control (VC) Interface Descriptor -----------------
        descrom[DESC_FSCFG_ADDR + 17 + 0] <= 8'h09;// 0 bLength
        descrom[DESC_FSCFG_ADDR + 17 + 1] <= `USB_DESCTYPE_INTERFACE;// 1 bDescriptorType - Interface
        descrom[DESC_FSCFG_ADDR + 17 + 2] <= 8'h00;// 2 bInterfaceNumber - Interface 0
        descrom[DESC_FSCFG_ADDR + 17 + 3] <= 8'h00;// 3 bAlternateSetting
        descrom[DESC_FSCFG_ADDR + 17 + 4] <= 8'h01;// 4 bNumEndpoints = 2
        descrom[DESC_FSCFG_ADDR + 17 + 5] <= `USB_CLASS_VIDEO;// 5 bInterfaceClass - Video Class
        descrom[DESC_FSCFG_ADDR + 17 + 6] <= `USB_VIDEO_CONTROL;// 6 bInterfaceSubClass - VideoControl Interface
        descrom[DESC_FSCFG_ADDR + 17 + 7] <= 8'h00;// 7 bInterafceProtocol - No protocal
        descrom[DESC_FSCFG_ADDR + 17 + 8] <= 8'h02;// 8 iInterface - Index of string
        //---------------- Class-specific (VC) Interface Header Descriptor -----------------
        descrom[DESC_FSCFG_ADDR + 26 + 0] <= 8'h0D;// 0 bLength
        descrom[DESC_FSCFG_ADDR + 26 + 1] <= `USB_DESCTYPE_CS_INTERFACE;// 1 bDescriptorType - Interface
        descrom[DESC_FSCFG_ADDR + 26 + 2] <= `USB_VC_HEADER;// 2 bDescriptorSubType - Interface 0
        descrom[DESC_FSCFG_ADDR + 26 + 3] <= 8'h10;// 3 bcdUVC
        descrom[DESC_FSCFG_ADDR + 26 + 4] <= 8'h01;// 4 bcdUVC - Video class revision 1.1
        descrom[DESC_FSCFG_ADDR + 26 + 5] <= 8'h28;// 5 wTotalLength
        descrom[DESC_FSCFG_ADDR + 26 + 6] <= 8'h00;// 6 wTotalLength - till output terminal
        descrom[DESC_FSCFG_ADDR + 26 + 7] <=  8'h00;//60MHz 8'h00;// 7  dwClockFrequency - 100MHz
        descrom[DESC_FSCFG_ADDR + 26 + 8] <=  8'h87;//60MHz 8'hE1;// 8  dwClockFrequency - 100MHz
        descrom[DESC_FSCFG_ADDR + 26 + 9] <=  8'h93;//60MHz 8'hF5;// 9  dwClockFrequency - 100MHz
        descrom[DESC_FSCFG_ADDR + 26 + 10] <= 8'h03;//60MHz 8'h05;// 10 dwClockFrequency - 100MHz
        descrom[DESC_FSCFG_ADDR + 26 + 11] <= 8'h01;// 11 bInCollection - One Streaming Interface
        descrom[DESC_FSCFG_ADDR + 26 + 12] <= 8'h01;// 12 baInterfaceNr - Number of the Streaming interface
        //---------------- Input Terminal (Camera) Descriptor - Represents the CCD sensor---------------- 
        //---------------- (Simulated here in this demo)---------------- 
        descrom[DESC_FSCFG_ADDR + 39 + 0] <= 8'h12;// 0 bLength
        descrom[DESC_FSCFG_ADDR + 39 + 1] <= `USB_DESCTYPE_CS_INTERFACE;// 1 bDescriptorType = Audio Interface Descriptor
        descrom[DESC_FSCFG_ADDR + 39 + 2] <= `USB_VC_INPUT_TERMINAL;// 2 bDescriptorSubtype = 2 Input Terminal
        descrom[DESC_FSCFG_ADDR + 39 + 3] <= 8'h01;// 3 bTerminalID
        descrom[DESC_FSCFG_ADDR + 39 + 4] <= 8'h01;// 4 wTerminalType
        descrom[DESC_FSCFG_ADDR + 39 + 5] <= 8'h02;// 5 wTerminalType - ITT_CAMERA type (CCD Sensor)
        descrom[DESC_FSCFG_ADDR + 39 + 6] <= 8'h00;// 6 bAssocTerminal - No association
        descrom[DESC_FSCFG_ADDR + 39 + 7] <= 8'h00;// 7 iTerminal - Unused
        descrom[DESC_FSCFG_ADDR + 39 + 8] <= 8'h00;// 8 wObjectiveFocalLengthMin - No optical zoom supported
        descrom[DESC_FSCFG_ADDR + 39 + 9] <= 8'h00;// 9 wObjectiveFocalLengthMin - No optical zoom supported
        descrom[DESC_FSCFG_ADDR + 39 + 10] <= 8'h00;// 10 wObjectiveFocalLengthMax - No optical zoom supported
        descrom[DESC_FSCFG_ADDR + 39 + 11] <= 8'h00;// 11 wObjectiveFocalLengthMax - No optical zoom supported
        descrom[DESC_FSCFG_ADDR + 39 + 12] <= 8'h00;// 12 wOcularFocalLength - No optical zoom supported
        descrom[DESC_FSCFG_ADDR + 39 + 13] <= 8'h00;// 13 wOcularFocalLength - No optical zoom supported
        descrom[DESC_FSCFG_ADDR + 39 + 14] <= 8'h03;// 14 bControlSize - 3 bytes
        descrom[DESC_FSCFG_ADDR + 39 + 15] <= 8'h00;// 15 bmControls -
        descrom[DESC_FSCFG_ADDR + 39 + 16] <= 8'h00;// 16 bmControls -
        descrom[DESC_FSCFG_ADDR + 39 + 17] <= 8'h00;// 17 bmControls - No controls are supported
        //---------------- Output Terminal Descriptor ----------------
        descrom[DESC_FSCFG_ADDR + 57 + 0] <= 8'h09;// 0 bLength
        descrom[DESC_FSCFG_ADDR + 57 + 1] <= `USB_DESCTYPE_CS_INTERFACE;// 1 bDescriptorType Interface Descriptor
        descrom[DESC_FSCFG_ADDR + 57 + 2] <= `USB_VC_OUPUT_TERMINAL;// 2 bDescriptorSubtype Output Terminal
        descrom[DESC_FSCFG_ADDR + 57 + 3] <= 8'h02;// 3 bTerminalID
        descrom[DESC_FSCFG_ADDR + 57 + 4] <= 8'h01;// 4 wTerminalType
        descrom[DESC_FSCFG_ADDR + 57 + 5] <= 8'h01;// 5 wTerminalType - ITT_STREAMING type
        descrom[DESC_FSCFG_ADDR + 57 + 6] <= 8'h00;// 6 bAssocTerminal - No association
        descrom[DESC_FSCFG_ADDR + 57 + 7] <= 8'h01;// 7 bSourceID - Source is Input terminal 1
        descrom[DESC_FSCFG_ADDR + 57 + 8] <= 8'h00;// 8 iTerminal - Unused
        //---------------- Standard Interrupt Endpoint Descriptor ----------------
        descrom[DESC_FSCFG_ADDR + 66 + 0] <= 8'h07;// 0 bLength
        descrom[DESC_FSCFG_ADDR + 66 + 1] <= `USB_DESCTYPE_ENDPOINT;// 1 bDescriptorType = Audio Interface Descriptor
        descrom[DESC_FSCFG_ADDR + 66 + 2] <= (`VIDEO_STATUS_EP_NUM | 8'h80);// 2 bEndpointAddress - IN endpoint
        descrom[DESC_FSCFG_ADDR + 66 + 3] <= 8'h03;// 3 bmAttributes - Interrupt transfer
        descrom[DESC_FSCFG_ADDR + 66 + 4] <= 8'h40;// 4 wMaxPacketSize - 64 bytes
        descrom[DESC_FSCFG_ADDR + 66 + 5] <= 8'h00;// 5 wMaxPacketSize - 64 bytes
        descrom[DESC_FSCFG_ADDR + 66 + 6] <= 8'h09;// 6 bInterval - 2^(9-1) microframes = 32ms
        //---------------- Class-specific Interrupt Endpoint Descriptor ----------------
        descrom[DESC_FSCFG_ADDR + 73 + 0] <= 8'h05;// 0 bLength
        descrom[DESC_FSCFG_ADDR + 73 + 1] <= `USB_DESCTYPE_CS_ENDPOINT;// 1 bDescriptorType - Class-specific Endpoint
        descrom[DESC_FSCFG_ADDR + 73 + 2] <= 8'h03;// 2 bDescriptorSubType - Interrupt Endpoint
        descrom[DESC_FSCFG_ADDR + 73 + 3] <= 8'h40;// 3 wMaxTransferSize - 64 bytes
        descrom[DESC_FSCFG_ADDR + 73 + 4] <= 8'h00;// 4 wMaxTransferSize - 64 bytes
        //---------------- Video Steaming Interface Descriptor ----------------
        //---------------- Zero-bandwidth Alternate Setting 0  ----------------
        descrom[DESC_FSCFG_ADDR + 78 + 0] <= 8'h09;// 0 bLength
        descrom[DESC_FSCFG_ADDR + 78 + 1] <= `USB_DESCTYPE_INTERFACE;// 1 bDescriptorType - Interface
        descrom[DESC_FSCFG_ADDR + 78 + 2] <= 8'h01;// 2 bInterfaceNumber - Interface 1
        descrom[DESC_FSCFG_ADDR + 78 + 3] <= 8'h00;// 3 bAlternateSetting - 0
        descrom[DESC_FSCFG_ADDR + 78 + 4] <= 8'h00;// 4 bNumEndpoints - No bandwidth used
        descrom[DESC_FSCFG_ADDR + 78 + 5] <= `USB_CLASS_VIDEO;// 5 bInterfaceClass - Video Class
        descrom[DESC_FSCFG_ADDR + 78 + 6] <= `USB_VIDEO_STREAMING;// 6 bInterfaceSubClass - VideoStreaming Interface
        descrom[DESC_FSCFG_ADDR + 78 + 7] <= 8'h00;// 7 bInterfaceProtocol - No protocol
        descrom[DESC_FSCFG_ADDR + 78 + 8] <= 8'h00;// 8 iInterface - Unused
        //---------------- Class-specific VS Interface Input Header Descriptor ----------------
        descrom[DESC_FSCFG_ADDR + 87 + 0] <= 8'h0E;// 0 bLength
        descrom[DESC_FSCFG_ADDR + 87 + 1] <= `USB_DESCTYPE_CS_INTERFACE;// 1 bDescriptorType - Class-specific Interface
        descrom[DESC_FSCFG_ADDR + 87 + 2] <= `USB_VS_INPUT_HEADER;// 2 bDescriptorSubtype - INPUT HEADER
        descrom[DESC_FSCFG_ADDR + 87 + 3] <= 8'h01;// 3 bNumFormats - One format supported
        descrom[DESC_FSCFG_ADDR + 87 + 4] <= 8'h47;// 4 wTotalLength - Size of class-specific VS descriptor
        descrom[DESC_FSCFG_ADDR + 87 + 5] <= 8'h00;// 5 wTotalLength - Size of class-specific VS descriptor
        descrom[DESC_FSCFG_ADDR + 87 + 6] <= (`VIDEO_DATA_EP_NUM | 8'h80);// 6 bEndpointAddress - Iso EP for video streaming
        descrom[DESC_FSCFG_ADDR + 87 + 7] <= 8'h00;// 7 bmInfo - No dynamic format change
        descrom[DESC_FSCFG_ADDR + 87 + 8] <= 8'h02;// 8 bTerminalLink - Denotes the Output Terminal
        descrom[DESC_FSCFG_ADDR + 87 + 9] <= 8'h01;// 9 bStillCaptureMethod - Method 1 supported
        descrom[DESC_FSCFG_ADDR + 87 + 10] <= 8'h00;// 10 bTriggerSupport - No Hardware Trigger
        descrom[DESC_FSCFG_ADDR + 87 + 11] <= 8'h00;// 11 bTriggerUsage
        descrom[DESC_FSCFG_ADDR + 87 + 12] <= 8'h01;// 12 bControlSize - 1 byte
        descrom[DESC_FSCFG_ADDR + 87 + 13] <= 8'h00;// 13 bmaControls - No Controls supported
        //---------------- Class-specific VS Format Descriptor ----------------
        descrom[DESC_FSCFG_ADDR + 101 + 0] <= 8'h1B;// 0 bLength
        descrom[DESC_FSCFG_ADDR + 101 + 1] <= `USB_DESCTYPE_CS_INTERFACE;// 1 bDescriptorType - Class-specific Interface
        descrom[DESC_FSCFG_ADDR + 101 + 2] <= `USB_VS_FORMAT_UNCOMPRESSED;// 2 bDescriptorSubtype - FORMAT UNCOMPRESSED
        descrom[DESC_FSCFG_ADDR + 101 + 3] <= 8'h01;// 3 bFormatIndex
        descrom[DESC_FSCFG_ADDR + 101 + 4] <= 8'h01;// 4 bNumFrameDescriptors - 1 Frame descriptor followed
        descrom[DESC_FSCFG_ADDR + 101 + 5 ] <= 8'h59;// 5  guidFormat - YUY2 Video format
        descrom[DESC_FSCFG_ADDR + 101 + 6 ] <= 8'h55;// 6  guidFormat - YUY2 Video format
        descrom[DESC_FSCFG_ADDR + 101 + 7 ] <= 8'h59;// 7  guidFormat - YUY2 Video format
        descrom[DESC_FSCFG_ADDR + 101 + 8 ] <= 8'h32;// 8  guidFormat - YUY2 Video format
        descrom[DESC_FSCFG_ADDR + 101 + 9 ] <= 8'h00;// 9  guidFormat - YUY2 Video format
        descrom[DESC_FSCFG_ADDR + 101 + 10] <= 8'h00;// 10 guidFormat - YUY2 Video format
        descrom[DESC_FSCFG_ADDR + 101 + 11] <= 8'h10;// 11 guidFormat - YUY2 Video format
        descrom[DESC_FSCFG_ADDR + 101 + 12] <= 8'h00;// 12 guidFormat - YUY2 Video format
        descrom[DESC_FSCFG_ADDR + 101 + 13] <= 8'h80;// 13 guidFormat - YUY2 Video format
        descrom[DESC_FSCFG_ADDR + 101 + 14] <= 8'h00;// 14 guidFormat - YUY2 Video format
        descrom[DESC_FSCFG_ADDR + 101 + 15] <= 8'h00;// 15 guidFormat - YUY2 Video format
        descrom[DESC_FSCFG_ADDR + 101 + 16] <= 8'hAA;// 16 guidFormat - YUY2 Video format
        descrom[DESC_FSCFG_ADDR + 101 + 17] <= 8'h00;// 17 guidFormat - YUY2 Video format
        descrom[DESC_FSCFG_ADDR + 101 + 18] <= 8'h38;// 18 guidFormat - YUY2 Video format
        descrom[DESC_FSCFG_ADDR + 101 + 19] <= 8'h9B;// 19 guidFormat - YUY2 Video format
        descrom[DESC_FSCFG_ADDR + 101 + 20] <= 8'h71;// 20 guidFormat - YUY2 Video format
        descrom[DESC_FSCFG_ADDR + 101 + 21] <= `BITS_PER_PIXEL;// 21 bBitsPerPixel - 16 bits
        descrom[DESC_FSCFG_ADDR + 101 + 22] <= 8'h01;// 22 bDefaultFrameIndex
        descrom[DESC_FSCFG_ADDR + 101 + 23] <= 8'h00;// 23 bAspectRatioX
        descrom[DESC_FSCFG_ADDR + 101 + 24] <= 8'h00;// 24 bAspectRatioY
        descrom[DESC_FSCFG_ADDR + 101 + 25] <= 8'h00;// 25 bmInterlaceFlags - No interlaces mode
        descrom[DESC_FSCFG_ADDR + 101 + 26] <= 8'h00;// 26 bCopyProtect - No restrictions on duplication
        //---------------- Class-specific VS Frame Descriptor ----------------
        descrom[DESC_FSCFG_ADDR + 128 + 0 ] <= 8'h1E;// 0 bLength
        descrom[DESC_FSCFG_ADDR + 128 + 1 ] <= `USB_DESCTYPE_CS_INTERFACE;// 1 bDescriptorType - Class-specific Interface
        descrom[DESC_FSCFG_ADDR + 128 + 2 ] <= `USB_VS_FRAME_UNCOMPRESSED;// 2 bDescriptorSubtype
        descrom[DESC_FSCFG_ADDR + 128 + 3 ] <= 8'h01;// 3 bFormatIndex
        descrom[DESC_FSCFG_ADDR + 128 + 4 ] <= 8'h01;// 4 bmCapabilities - Still image capture method 1
        descrom[DESC_FSCFG_ADDR + 128 + 5 ] <= {`WIDTH}[7:0];// 5  wWidth - 480 pixels
        descrom[DESC_FSCFG_ADDR + 128 + 6 ] <= {`WIDTH}[15:8];// 6  wWidth - 480 pixels
        descrom[DESC_FSCFG_ADDR + 128 + 7 ] <= {`HEIGHT}[7:0];// 7  wHeight - 320 pixels
        descrom[DESC_FSCFG_ADDR + 128 + 8 ] <= {`HEIGHT}[15:8];// 8  wHeight - 320 pixels
        descrom[DESC_FSCFG_ADDR + 128 + 9 ] <= {`MIN_BIT_RATE}[7:0];// 9  dwMinBitRate
        descrom[DESC_FSCFG_ADDR + 128 + 10] <= {`MIN_BIT_RATE}[15:8];// 10 dwMinBitRate
        descrom[DESC_FSCFG_ADDR + 128 + 11] <= {`MIN_BIT_RATE}[23:16];// 11 dwMinBitRate
        descrom[DESC_FSCFG_ADDR + 128 + 12] <= {`MIN_BIT_RATE}[31:24];// 12 dwMinBitRate
        descrom[DESC_FSCFG_ADDR + 128 + 13] <= {`MAX_BIT_RATE}[7:0];// 13 dwMaxBitRate
        descrom[DESC_FSCFG_ADDR + 128 + 14] <= {`MAX_BIT_RATE}[15:8];// 14 dwMaxBitRate
        descrom[DESC_FSCFG_ADDR + 128 + 15] <= {`MAX_BIT_RATE}[23:16];// 15 dwMaxBitRate
        descrom[DESC_FSCFG_ADDR + 128 + 16] <= {`MAX_BIT_RATE}[31:24];// 16 dwMaxBitRate
        descrom[DESC_FSCFG_ADDR + 128 + 17] <= {`MAX_FRAME_SIZE}[7:0];// 17 dwMaxVideoFrameBufSize
        descrom[DESC_FSCFG_ADDR + 128 + 18] <= {`MAX_FRAME_SIZE}[15:8];// 18 dwMaxVideoFrameBufSize
        descrom[DESC_FSCFG_ADDR + 128 + 19] <= {`MAX_FRAME_SIZE}[23:16];// 19 dwMaxVideoFrameBufSize
        descrom[DESC_FSCFG_ADDR + 128 + 20] <= {`MAX_FRAME_SIZE}[31:24];// 20 dwMaxVideoFrameBufSize
        descrom[DESC_FSCFG_ADDR + 128 + 21] <= {`FRAME_INTERVAL}[7:0];// 21 dwDefaultFrameInterval
        descrom[DESC_FSCFG_ADDR + 128 + 22] <= {`FRAME_INTERVAL}[15:8];// 22 dwDefaultFrameInterval
        descrom[DESC_FSCFG_ADDR + 128 + 23] <= {`FRAME_INTERVAL}[23:16];// 23 dwDefaultFrameInterval
        descrom[DESC_FSCFG_ADDR + 128 + 24] <= {`FRAME_INTERVAL}[31:24];// 24 dwDefaultFrameInterval
        descrom[DESC_FSCFG_ADDR + 128 + 25] <= 8'h01;// 25 dwDefaultFrameIntervalType
        descrom[DESC_FSCFG_ADDR + 128 + 26] <= {`FRAME_INTERVAL}[7:0];// 26 dwFrameInterval
        descrom[DESC_FSCFG_ADDR + 128 + 27] <= {`FRAME_INTERVAL}[15:8];// 27 dwFrameInterval
        descrom[DESC_FSCFG_ADDR + 128 + 28] <= {`FRAME_INTERVAL}[23:16];// 28 dwFrameInterval
        descrom[DESC_FSCFG_ADDR + 128 + 29] <= {`FRAME_INTERVAL}[31:24];// 29 dwFrameInterval
        //Video Streaming Interface Descriptor
        //Alternate Setting 1
        descrom[DESC_FSCFG_ADDR + 158 + 0] <= 8'h09;// 0 bLength
        descrom[DESC_FSCFG_ADDR + 158 + 1] <= `USB_DESCTYPE_INTERFACE;// 1 bDescriptorType - Interface
        descrom[DESC_FSCFG_ADDR + 158 + 2] <= 8'h01;// 2 bInterfaceNumber - Interface 1
        descrom[DESC_FSCFG_ADDR + 158 + 3] <= 8'h01;// 3 bAlternateSetting - 1
        descrom[DESC_FSCFG_ADDR + 158 + 4] <= 8'h01;// 4 bNumEndpoints
        descrom[DESC_FSCFG_ADDR + 158 + 5] <= `USB_CLASS_VIDEO;// 5 bInterfaceClass - Video Class
        descrom[DESC_FSCFG_ADDR + 158 + 6] <= `USB_VIDEO_STREAMING;// 6 bInterfaceSubClass - VideoStreaming Interface
        descrom[DESC_FSCFG_ADDR + 158 + 7] <= 8'h00;// 7 bInterfaceProtocol - No protocol
        descrom[DESC_FSCFG_ADDR + 158 + 8] <= 8'h00;// 8 iInterface - Unused

        //Standard VS Isochronous Video Data Endpoint Descriptor
        descrom[DESC_FSCFG_ADDR + 167 + 0] <= 8'h07;// 0 bLength
        descrom[DESC_FSCFG_ADDR + 167 + 1] <= `USB_DESCTYPE_ENDPOINT;// 1 bDescriptorType
        descrom[DESC_FSCFG_ADDR + 167 + 2] <= (`VIDEO_DATA_EP_NUM | 8'h80);// 2 bEndpointAddress - IN Endpoint
        descrom[DESC_FSCFG_ADDR + 167 + 3] <= 8'h05;// 3 bmAttributes - Isochronous EP (Asynchronous)
        descrom[DESC_FSCFG_ADDR + 167 + 4] <= {`PACKET_SIZE}[7:0];// 4 wMaxPacketSize 1x 1023 bytes
        descrom[DESC_FSCFG_ADDR + 167 + 5] <= {3'd0,{`ADDITIONAL_PACKET}[1:0],{`PACKET_SIZE}[10:8]};// 5 wMaxPacketSize 1x 1023 bytes
        descrom[DESC_FSCFG_ADDR + 167 + 6] <= 8'h01;// 6 bInterval

        //Other Speed Addr
        descrom[DESC_OSCFG_ADDR + 0]  <= 8'h07;// 
        descrom[DESC_OSCFG_ADDR + 1]  <= 8'h00;// 12 bytes padding
        descrom[DESC_OSCFG_ADDR + 2]  <= 8'h00;
        descrom[DESC_OSCFG_ADDR + 3]  <= 8'h00; 
        descrom[DESC_OSCFG_ADDR + 4]  <= 8'h00; 
        descrom[DESC_OSCFG_ADDR + 5]  <= 8'h00; 
        descrom[DESC_OSCFG_ADDR + 6]  <= 8'h00; 
        descrom[DESC_OSCFG_ADDR + 7]  <= 8'h00; 
        descrom[DESC_OSCFG_ADDR + 8]  <= 8'h00; 
        descrom[DESC_OSCFG_ADDR + 9]  <= 8'h00; 
        descrom[DESC_OSCFG_ADDR + 10] <= 8'h00;
        descrom[DESC_OSCFG_ADDR + 11] <= 8'h00; 
        descrom[DESC_OSCFG_ADDR + 12] <= 8'h00; 

        if(descrom_len > DESC_STRLANG_ADDR)begin
            // string descriptor 0 (supported languages)
            descrom[DESC_STRLANG_ADDR + 0] <= 8'h04;                // bLength = 4
            descrom[DESC_STRLANG_ADDR + 1] <= 8'h03;                // bDescriptorType = string descriptor
            descrom[DESC_STRLANG_ADDR + 2] <= 8'h09;
            descrom[DESC_STRLANG_ADDR + 3] <= 8'h04;         // wLangId[0] = 0x0409 = English U.S.
            descrom[DESC_STRVENDOR_ADDR + 0] <= 2 + 2*VENDORSTR_LEN;
            descrom[DESC_STRVENDOR_ADDR + 1] <= 8'h03;
            for(i = 0; i < VENDORSTR_LEN; i = i + 1) begin
                for(z = 0; z < 8; z = z + 1) begin
                    descrom[DESC_STRVENDOR_ADDR+ 2*i + 2][z] <= VENDORSTR[(VENDORSTR_LEN - 1 -i)*8+z];
                end
                descrom[DESC_STRVENDOR_ADDR+ 2*i + 3] <= 8'h00;
            end
            descrom[DESC_STRPRODUCT_ADDR + 0] <= 2 + 2*PRODUCTSTR_LEN;
            descrom[DESC_STRPRODUCT_ADDR + 1] <= 8'h03;
            for(i = 0; i < PRODUCTSTR_LEN; i = i + 1) begin
                for(z = 0; z < 8; z = z + 1) begin
                    descrom[DESC_STRPRODUCT_ADDR + 2*i + 2][z] <= PRODUCTSTR[(PRODUCTSTR_LEN - 1 - i)*8+z];
                end
                descrom[DESC_STRPRODUCT_ADDR + 2*i + 3] <= 8'h00;
            end
            descrom[DESC_STRSERIAL_ADDR + 0] <= 2 + 2*SERIALSTR_LEN;
            descrom[DESC_STRSERIAL_ADDR + 1] <= 8'h03;
            for(i = 0; i < SERIALSTR_LEN; i = i + 1) begin
                for(z = 0; z < 8; z = z + 1) begin
                    descrom[DESC_STRSERIAL_ADDR + 2*i + 2][z] <= SERIALSTR[(SERIALSTR_LEN - 1 - i)*8+z];
                end
                descrom[DESC_STRSERIAL_ADDR + 2*i + 3] <= 8'h00;
            end
        end
      end
    assign o_descrom_rdat = descrom[i_descrom_raddr];
endmodule
