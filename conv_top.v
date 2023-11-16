`timescale 1ns/1ns
 
 
module CONV_top();
    
parameter period = 1;
 
parameter Rst0State = 2'b00; // Предполагается, что начальное значение состояния равно 0
parameter Rst1State = 2'b01;
parameter WorkState = 2'b10;
    
reg reset;
reg clk;
reg  [7:0] CONV_iData0;
reg  [7:0] CONV_iData1;
wire [15:0] CONV_oData;
reg  [15:0] index_reset; 
reg  [1:0]  State;

always #( 1 ) clk = ! clk;
initial begin
    clk = 0;
  //  reset = 0;
    $display("Running testbench");
    #100;
   reset = 1;
    #10000000;
    $finish();
end

always @(posedge clk)
begin
    case(State)
	 Rst0State: // запускаем сброс
	begin		
		reset <= 0;
		index_reset <= 0;
		State <= Rst1State;
	end

	 Rst1State: // Сохраняем сброс, сброс завершается
		begin
			if(index_reset <= 16'hfe)
			begin
				index_reset <= index_reset + 1;
			end
			else
			begin
				//index_reset <= 0;
				State <= WorkState;
				reset <= 1;
			end
		end
	
	 WorkState: // ввод данных
			begin
				reset <= 1;
				State <= WorkState;
				CONV_iData0 = -8'd120;
				CONV_iData1 = 8'd55;
			end
            default: State <= Rst0State;
    endcase
end
  /*
always @(posedge clk)
begin
	 if (State == Rst0State) // запускаем сброс
	begin		
		reset <= 0;
		index_reset <= 0;
		State <= Rst1State;
	end
	else 
	 if (State == Rst1State) // Сохраняем сброс, сброс завершается
		begin
			if(index_reset <= 16'hfe)
			begin
				index_reset <= index_reset + 1;
			end
			else
			begin
				//index_reset <= 0;
				State <= WorkState;
				reset <= 1;
			end
		end
		else
			 if (State == WorkState) // ввод данных
			begin
				reset <= 1;
				State <= WorkState;
				CONV_iData0 = 8'h01;
				CONV_iData1 = 8'h01;
			end
end
 */

// always 
// begin
// 	//# period clk = !clk;	
// 	# 1 clk = !clk;
// end
 
 


CONV CONV0(
	.reset(reset),
	.clk(clk),
	.CONV_iData0(CONV_iData0),
	.CONV_iData1(CONV_iData1),
	.CONV_oData(CONV_oData)
);
endmodule 