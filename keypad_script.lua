--Важно Для редактировани использовать редактор, где можно ставить кодировку UTF-8. 
--При кодировке ANSI ломаются скрипты обработки



function init() --функция иницализации
     ConfigCan(1,1000);
	 setOutConfig(1,2)	
	 setOutConfig(2,2)	
     setOutConfig(3,2)	
     setOutConfig(4,2)	 
     setOutConfig(5,2)	
	 setOutConfig(6,2)	
	 setOutConfig(7,2)	
     setOutConfig(8,2)	
     setOutConfig(9,2)	 
     setOutConfig(10,2)
	 setOutConfig(11,2)	
	 setOutConfig(12,2)	
     setOutConfig(13,2)	
     setOutConfig(14,2)	 
     setOutConfig(15,2)
	 setOutConfig(16,2)	
	 setOutConfig(17,2)	
     setOutConfig(18,2)	
     setOutConfig(19,2)	 
     setOutConfig(20,2)
end
----
-- немножко вкинуну херни про системные функции
--
main = function ()
  
  
	local start_enable = false
	
    local KeyBoard		= KeyPad8:new(0x15)--создание объекта клавиатура c адресом 0x15
	
	local Key1Counter   = Counter:new(0,3,0,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)
	local Key2Counter   = Counter:new(0,3,0,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)
	local Key3Counter   = Counter:new(0,3,0,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)
	local Key4Counter   = Counter:new(0,3,0,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)
	local Key5Counter   = Counter:new(0,3,0,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)local Key1Counter   = Counter:new(0,3,0,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)
	local Key6Counter   = Counter:new(0,3,0,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)	
	local Key7Counter   = Counter:new(0,3,0,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)
	local Key8Counter   = Counter:new(0,3,0,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)
	

    
    
    init()
	
					
	KeyBoard:setBackLigthBrigth( 15 )	-- подсветка клавиатуры		
	

   
	while true do		
		KeyBoard:process() --процесс работы с клавиатурой
				
		
				
		Key1Counter:process(KeyBoard:getKey(1),false,false);
		KeyBoard:setLedRed( 1,  Key1Counter:get() ==1 )
		KeyBoard:setLedGreen( 1,  Key1Counter:get() ==2 )
		KeyBoard:setLedBlue( 1,  Key1Counter:get() ==3 )
		
		setOut(1, Key1Counter:get() ==1)
		setOut(2, Key1Counter:get() ==2)
		setOut(3, Key1Counter:get() ==3)
		
		
		Key2Counter:process(KeyBoard:getKey(2),false,false);
		KeyBoard:setLedRed( 2,  Key2Counter:get() ==1 )
		KeyBoard:setLedGreen( 2,  Key2Counter:get() ==2 )
		KeyBoard:setLedBlue( 2,  Key2Counter:get() ==3 )
		
		setOut(4, Key2Counter:get() ==1)
		
		 
		Key3Counter:process(KeyBoard:getKey(3),false,false);
		KeyBoard:setLedRed( 3,  Key3Counter:get() ==1 )
		KeyBoard:setLedGreen( 3,  Key3Counter:get() ==2 )
		KeyBoard:setLedBlue( 3,  Key3Counter:get() ==3 )
		
		setOut(5, Key3Counter:get() ==1)
		setOut(6, Key3Counter:get() ==2)
		setOut(7, Key3Counter:get() ==3)
		
		Key4Counter:process(KeyBoard:getKey(4),false,false);
		KeyBoard:setLedRed( 4,  Key4Counter:get() ==1 )
		KeyBoard:setLedGreen( 4,  Key4Counter:get() ==2 )
		KeyBoard:setLedBlue( 4,  Key4Counter:get() ==3 )
		
		setOut(8, Key4Counter:get() ==3)
		
		Key5Counter:process(KeyBoard:getKey(5),false,false);
		KeyBoard:setLedRed( 5,  Key5Counter:get() ==1 )
		KeyBoard:setLedGreen( 5,  Key5Counter:get() ==2 )
		KeyBoard:setLedBlue( 5,  Key5Counter:get() ==3 )
		
		setOut(9,  Key5Counter:get() ==1)
		setOut(10, Key5Counter:get() ==2)
		setOut(11, Key5Counter:get() ==3)
		
		Key6Counter:process(KeyBoard:getKey(6),false,false);
		KeyBoard:setLedRed( 6,  Key6Counter:get() ==1 )
		KeyBoard:setLedGreen( 6,  Key6Counter:get() ==2 )
		KeyBoard:setLedBlue( 6,  Key6Counter:get() ==3 )
		
		setOut(12,  Key6Counter:get() ==1)
		setOut(13, Key6Counter:get() ==2)
		setOut(14, Key6Counter:get() ==3)
		
		Key7Counter:process(KeyBoard:getKey(7),false,false);
		KeyBoard:setLedRed( 7,  Key7Counter:get() ==1 )
		KeyBoard:setLedGreen( 7,  Key7Counter:get() ==2 )
		KeyBoard:setLedBlue( 7,  Key7Counter:get() ==3 )
		
		setOut(15,  Key7Counter:get() ==1)
		setOut(16, Key7Counter:get() ==2)
		setOut(17, Key7Counter:get() ==3)
		
		Key8Counter:process(KeyBoard:getKey(8),false,false);
		KeyBoard:setLedRed( 8,  Key8Counter:get() ==1 )
		KeyBoard:setLedGreen( 8,  Key8Counter:get() ==2 )
		KeyBoard:setLedBlue( 8,  Key8Counter:get() ==3 )
		
		setOut(18, Key8Counter:get() ==1)
		setOut(19, Key8Counter:get() ==2)
		setOut(20, Key8Counter:get() ==3)
		 
		 
					
		   
	   Yield() 
	end
end