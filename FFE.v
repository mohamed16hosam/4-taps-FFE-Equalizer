module FFE 
#(parameter width = 'd12)
(
input               	          clk,
input           	              rst,
input   		 				  load_sig,
input      signed  [width-1:0] 	  ffe_in_data,
output reg signed  [width-1:0] 	  ffe_out_data,
output reg                    	  ffe_out_valid
); 
reg								enable_counter;
reg 		[width-1:0] 		out_mux1;
reg 		[width-1:0] 		out_mux2;
reg 		[width-1:0] 		out_mux3;
reg         [1:0]       		counter;
reg 	    					buffer_sync[0:5];
reg 	    [width-1:0] 		ffe_data_store[0:3];
wire 	    [2*width-1:0]			mult_out;
wire							nor_out;
reg 		[width-1:0]			reg_sync;
wire		[width-1:0]			add_comb;
integer i,j ; 


wire signed [width-1:0] tabs_mem [3:0]; //(h0,h1,h2,h3)
/****************************************************************************************************************/

/********** Accuracy ( 6-bit >> integer && 6-bit >> fraction) *******************************/	
assign		tabs_mem[3] = 12'h020;  // h0 =  0.5 (register in the most left)
assign      tabs_mem[2] = 12'hff0;  // h1 = -0.25
assign		tabs_mem[1] = 12'h00a;  // h2 =  0.15625
assign		tabs_mem[0] = 12'hff6;  // h3 = -0.0625


 /**************************First reg*************************/
 always @(posedge clk or negedge rst)
 begin
	 if(!rst)
		begin
		reg_sync<= 0 ;
		end
	 else if(load_sig)
		begin
		 reg_sync <= ffe_in_data ;
		end
 end 
  /**************************First reg*************************/
  always @ (posedge clk or negedge rst)
  begin
    if(!rst)begin
      buffer_sync[0] <= 'b0; 
    end
    else  begin
      buffer_sync[0] <=load_sig;
    end
	end  
  
  always @ (posedge clk or negedge rst)
  begin
    for(j=1; j<6; j=j+1) begin
    if(!rst)begin
      buffer_sync[j] <= 0; 
    end
    else begin
      buffer_sync[j] <= buffer_sync[j-1];
    end
end
end

/************************ medium chain logic ***********************/ 
  always @ (posedge clk or negedge rst)
  begin

    if(!rst)begin
      ffe_data_store[0] <= 'b0; 
    end
    else if(buffer_sync[1]) begin
      ffe_data_store[0] <=reg_sync;
    end
	end

  always @ (posedge clk or negedge rst)
  begin
  for(i=1; i<4; i=i+1) begin
    if(!rst)begin
      ffe_data_store[i] <=0 ; 
    end
    else if(buffer_sync[1]) begin
      ffe_data_store[i] <= ffe_data_store[i-1];
    end
	end
end
///////////////////////////////////////////////////////////
 always @(posedge clk or negedge rst)
 begin
  if(!rst )
   begin
     enable_counter <= 0 ;
   end
  else if (buffer_sync[1])
   begin
      enable_counter<= 1 ;
   end
  end
/************************ MUX (1) ***********************/ 
  always @(*) begin
    case (counter)
      2'b00: out_mux1 = ffe_data_store[3];
      2'b01: out_mux1 = ffe_data_store[2];
      2'b10: out_mux1 = ffe_data_store[1];
      2'b11: out_mux1 = ffe_data_store[0];
    endcase
  end
/************************ Counter ***********************/ 
 always @(posedge clk or negedge rst)
 begin
  if(!rst )
   begin
     counter <= 0 ;
   end
  else if (enable_counter)
   begin
     counter <= counter+1 ;
   end
  end
/************************ MUX (2) ***********************/ 
  always @(*) begin
    case (counter)
      2'b00: out_mux2 = tabs_mem[0];
      2'b01: out_mux2 = tabs_mem[1];
      2'b10: out_mux2 = tabs_mem[2];
      2'b11: out_mux2 = tabs_mem[3];
    endcase
  end  
  
  ////////////////////////////////////////////
  
  assign mult_out=out_mux1*out_mux2;
  assign nor_out=(counter[0] || counter[1]);
  
/************************ MUX (3) ***********************/ 
  always @(*) begin
    case (nor_out)
      2'b0: out_mux3 = 0;
      2'b1: out_mux3 =ffe_out_data;
    endcase
  end   
  
  /////////////////////////////////////////////
  
  assign add_comb=out_mux3+mult_out[17:6];
  
  ////////////////////////////////////////////
 always @(posedge clk or negedge rst)
 begin
  if(!rst )
   begin
     ffe_out_data <= 0 ;
   end
  else 
   begin
     ffe_out_data <= add_comb;
   end
  end
///////////////////////////////////////////////
 always @(posedge clk or negedge rst)
 begin
  if(!rst )
   begin
     ffe_out_valid <= 0 ;
   end
   else begin
     ffe_out_valid<=buffer_sync[5];
   end
  end 
  
  
endmodule