/***************************************************************************************************************/
/*
 Project Name: FFE 
 Module Name: top_design_tb.v 
 Describtion: This Module aim describe verify operation of FFE.
*/
/****************************************************************************************************************/
module FFE_tb ();

//parameters
parameter  width_tb ='d12 ,


//Testbench Signals
reg                        top_clk_tb;
reg                        top_rst_tb;
reg signed  [width_tb-1:0] top_in_data_tb;
reg                        top_in_load_tb;


wire signed [width_tb-1:0] top_data_out_tb;
wire                       top_out_valid_tb;

/****************************************************************************************************************/
initial
 begin
initialize() ;
reset();

//Register Write Operations

do_write('b000001000000);
repeat(3) @(negedge top_clk_tb);
do_write('b000010000000);
repeat(3) @(negedge top_clk_tb);
do_write('b000011000000);
repeat(3) @(negedge top_clk_tb);
do_write('b000100000000);
repeat(3) @(negedge top_clk_tb);


end


/***************************************************************************************************************/
/*************************************************** TASKS *****************************************************/
/***************************************************************************************************************/

/******************************************* Signals Initialization ********************************************/
task initialize ;
 begin
 top_clk_tb = 1'b0 ;  
 top_in_load_tb = 1'b0 ;
 end
endtask

/************************************************** RESET *****************************************************/

task reset ;
 begin
 top_rst_tb = 1'b1 ; 
 #10
 top_rst_tb = 1'b0 ; 
 #10
 top_rst_tb = 1'b1 ; 
 end
endtask

/********************************************** Do write Operation **********************************************/

task do_write ;
 input [width_tb-1:0] data ;
 
 begin
 @(posedge top_clk_tb )
 top_in_load_tb = 1'b1;
 top_in_data_tb = data;
 
 @(posedge top_clk_tb )
 top_in_load_tb = 1'b0;
 end

endtask


/***************************************************************************************************************/
/********************************************** Clock Generator ************************************************/
/***************************************************************************************************************/

always #50 top_clk_tb = ~top_clk_tb ;


/***************************************************************************************************************/
/********************************************* DUT Instantation ************************************************/
/***************************************************************************************************************/
FFE #(.width(width_tb)) DUT(
.clk(top_clk_tb),
.rst(top_rst_tb),
.ffe_in_data(top_in_data_tb),
.load_sig(top_in_load_tb),
.ffe_out_data(top_data_out_tb),
.ffe_out_valid(top_out_valid_tb)
);

endmodule
