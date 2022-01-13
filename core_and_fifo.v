
module Core_Fifo#(parameter n=4)
  (clk, data, src, des, WR, RD, Coreout, FIFOout, emp, full);
  
  input clk, WR, RD;
  input [3:0] src, des;
  input [14*n-9:0] data;
  
  output reg [15:0]Coreout;
  output reg [15:0]FIFOout;
  output emp, full;
  
  reg [15:0] FIFO[0:n];
  reg [($clog2(n+1))-1:0] Core_Count=0;
  reg [($clog2(n+1))-1:0] FIFO_Count=0;
  
  
assign FIFO[0] = {2'b00, src[3:0], des[3:0], data[14*n-9:14*n-14]};
  genvar i;
   generate
     for(i=1; i<n-1; i=i+1)
       begin
         assign FIFO[i] = {2'b01, data[14*(n-i)-1:14*(n-i)-14]};
       end
   endgenerate
  
  assign FIFO[n-1]={2'b10, data[13:0]};
  
  assign emp = (FIFO_Count==0 && Core_Count==0)?1'b1:1'b0;
  assign full = (Core_Count==n+1)?1'b1:1'b0;

  always@(posedge clk)
    begin
      if(WR==1'b1 && RD ==1'b0)
        begin
          if(Core_Count<n)
            begin
              Coreout<=FIFO[Core_Count];
              Core_Count<=Core_Count+1;
            end
        end
      

      else if(WR==1'b0 && RD==1'b1)
        begin
          Core_Count<=0;
          if(FIFO_Count<n)
            begin
              FIFOout<=	FIFO[FIFO_Count];
              FIFO_Count<=FIFO_Count+1;
            end
          
          else
            begin
              FIFO_Count<=0;
            end
        end
    end
  
endmodule