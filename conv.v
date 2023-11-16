// Модуль: модуль свертки переменной длины
 // Функция: вычислить результат свертки двух регистров заданной длины, входные данные регистра обновляются в реальном времени, результат свертки помещается в регистр и выводится в реальном времени
 // Использование метода: ввести часы, сбросить сброс низкого уровня, чтобы очистить регистр нестабильного состояния, загрузить высокое входное значение для вычисления,
 // out вытягивает значение выходного регистра результата
module CONV(
 input reg reset, // Сброс, очистка всех регистров
 input reg clk, // часы
 input wire signed [7: 0] CONV_iData0, // входные данные
 input wire signed [7: 0] CONV_iData1, // входные данные
 output reg signed [15: 0] CONV_oData // данные вывода
);
 
parameter LengthOfConv = 8; // Длина свертки
parameter InState = 4'b0001,ConvState = 4'b0010,OutState = 4'b0100,ClrState = 4'b1000;
 
 // Три регистра типа памяти
reg [7:0] CONV_iData0reg[LengthOfConv - 1:0];
reg [7:0] CONV_iData1reg[LengthOfConv - 1:0];
reg [15:0] CONV_oDatareg[2*LengthOfConv - 2:0];


 reg change;
reg [7: 0] index0;
reg [7: 0] index1; // Эти два предназначены для инициализации и очистки
 
reg [7: 0] index_input; // счетчик ввода
reg [7: 0] index_conv;
reg [7: 0] index_conv2; // Счетчик свертки
reg [7:0]  index_convs; //index_convs<=index_conv2 + index_conv;
reg [7: 0] index_output; // счетчик вывода u
reg [7: 0] index_clr; // выводить счетчик
 
reg [3:0] state,nextstate;
 
initial
	 begin
        index_convs <= 0;
		index0 <= 0;
		index1 <= 0;
		index_input <= 8'b0;
		index_conv	<= 8'b0;		
		index_conv2 <= 8'b0;
		index_output<= 8'b0;
		index_clr <= 8'b0;  
		state <= InState;
		nextstate <= ConvState;
	end
 always @ (posedge clk) // Используйте несколько тактов, чтобы очистить регистр ввода свертки и регистр результата
begin
	if(reset == 0)
	begin
		CONV_iData0reg[index0] <= 8'b0;
		CONV_iData1reg[index0] <= 8'b0;
		CONV_oDatareg[index1] <= 16'b0;
		if(index0  == LengthOfConv - 1) 
			index0 = 8'b0;  
		else
			index0 <= index0 + 8'b1;
		if(index1  == LengthOfConv * 2 - 2) 
			index1 = 8'b0;  
		else
			index1 <= index1 + 8'b1;
	end
	else
	begin
		 if (state == InState) // ввод данных
		begin
			begin
				CONV_iData0reg[index_input] <= CONV_iData0;
				CONV_iData1reg[index_input] <= CONV_iData1;
				index_input <= index_input + 8'b1;
				 CONV_oData <= 0; // Когда преобразование не окончено, на выходе будет 0
			end
			if(index_input >= LengthOfConv - 1)
			begin
				index_input <= 8'b0;
				state <= nextstate;
				nextstate  <= OutState;
			end
		end
		 if (state == ConvState) // Рассчитываем свертку
		begin
			  CONV_oData <= 0; // Когда преобразование не окончено, на выходе будет 0
			 if(index_conv2  <= LengthOfConv-1 &&index_conv  <= LengthOfConv-1 )
			 index_convs<=index_conv2 + index_conv;
				CONV_oDatareg[index_conv2 + index_conv] = CONV_oDatareg[index_conv2 + index_conv] + CONV_iData0reg[index_conv2]*CONV_iData1reg[index_conv];
			 if (index_conv2 == LengthOfConv) // Используется для замены при вложении цикла, внутренний уровень
			begin
				index_conv2 <= 8'b0; 
				index_conv <= index_conv + 8'b1;
			end
			else
				index_conv2 <= index_conv2 + 8'b1; 
				
			if(index_conv  == LengthOfConv )
			begin
				index_conv <= 8'b0; 
				index_conv2 <= 8'b0; // h
				//clearflag <= ~clearflag;
				state <= nextstate;
				nextstate  <= ClrState;
			end
		end	 
		 if (state == OutState) // состояние вывода
		begin
			CONV_oData <= CONV_oDatareg[index_output];
			index_output <= index_output + 8'b1;
			 if (index_output == LengthOfConv * 2-2) // Еще один период завершит вывод, но будет феномен выхода за пределы, который равен 0 (потому что мы его очистили)
			begin
				 index_output <= 8'b0; // Из-за характеристик неблокирующего присваивания здесь должно быть от 0 до LengthOfConv * 2
				state <= nextstate;
				nextstate  <= InState;
			end			
		end 
		 if (state == ClrState) // очистить состояние
		begin
			 CONV_oData <= 0; // Когда преобразование не окончено, на выходе будет 0
			CONV_oDatareg[index_clr] = 0;
			index_clr<= index_clr + 8'b1;
			if(index_clr  == LengthOfConv * 2 - 1 )
			begin
				index_clr <= 8'b0;  
				state <= nextstate;
				nextstate  <= ConvState;
			end			
		end 
	end
end
endmodule