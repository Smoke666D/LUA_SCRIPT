--Важно Для редактировани использовать редактор, где можно ставить кодировку UTF-8. 
--При кодировке ANSI ломаются скрипты обработки

<<<<<<< HEAD


function init() --функция иницализации
    ConfigCan(1,1000);
	setOutConfig(1,4)
	setOutConfig(2,4)
	setOutConfig(3,4)
	setOutConfig(4,4)
	setOutConfig(5,4)
	setOutConfig(6,4)
	setOutConfig(7,4)
	setOutConfig(8,4)
	setOutConfig(9,4)
	setOutConfig(10,4)
	setOutConfig(11,4)
	setOutConfig(12,4)
	setOutConfig(13,4)
	setOutConfig(14,4)
	setOutConfig(15,4)
	setOutConfig(16,4)
	setOutConfig(17,4)
	setOutConfig(18,4)
	setOutConfig(19,4)
	setOutConfig(20,4)
=======


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
>>>>>>> 6834365a65e2d38d409842e9db1990f83eb299da
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
	local CanAIN1		= CanOut:new(0x29, 300)
	local CanAIN2		= CanOut:new(0x30, 300)
	local CanAIN3		= CanOut:new(0x31, 300)
	
    
    
    init()
	
					
	KeyBoard:setBackLigthBrigth( 15 )	-- подсветка клавиатуры		
	

   
	while true do	


		CanAIN1:setByte(1,(getAin(1)//1) & 0xFF)
		CanAIN1:setByte(2,(((getAin(1)*100)%100)//1) & 0xFF)
		CanAIN1:setByte(3,(getAin(2)//1) & 0xFF)
		CanAIN1:setByte(4,(((getAin(2)*100)%100)//1) & 0xFF)
		CanAIN1:setByte(5,(getAin(3)//1) & 0xFF)
		CanAIN1:setByte(6,(((getAin(3)*100)%100)//1) & 0xFF)
		CanAIN1:setByte(7,(getAin(4)//1) & 0xFF)
		CanAIN1:setByte(8,(((getAin(4)*100)%100)//1) & 0xFF)
		CanAIN2:setByte(1,(getAin(5)//1) & 0xFF)
		CanAIN2:setByte(2,(((getAin(5)*100)%100)//1) & 0xFF)
		CanAIN2:setByte(3,(getAin(6)//1) & 0xFF)
		CanAIN2:setByte(4,(((getAin(6)*100)%100)//1) & 0xFF)
		CanAIN2:setByte(5,(getAin(7)//1) & 0xFF)
		CanAIN2:setByte(6,(((getAin(7)*100)%100)//1) & 0xFF)
		CanAIN2:setByte(7,(getAin(8)//1) & 0xFF)
		CanAIN2:setByte(8,(((getAin(8)*100)%100)//1) & 0xFF)
		CanAIN3:setByte(1,(getAin(9)//1) & 0xFF)
		CanAIN3:setByte(2,(((getAin(9)*100)%100)//1) & 0xFF)
		CanAIN3:setByte(3,(getAin(10)//1) & 0xFF)
		CanAIN3:setByte(4,(((getAin(10)*100)%100)//1) & 0xFF)
		CanAIN3:setByte(5,(getAin(11)//1) & 0xFF)
		CanAIN3:setByte(6,(((getAin(11)*100)%100)//1) & 0xFF)
		CanAIN3:setByte(7,(getBat()//1) & 0xFF)
		CanAIN3:setByte(8,(((getBat()*100)%100)//1) & 0xFF)
		
		CanAIN1:process()
	    CanAIN2:process()
		CanAIN3:process()
	
		KeyBoard:process() --процесс работы с клавиатурой
				
		KeyBoard:setLedRed(1, true)
				
		Key1Counter:process(KeyBoard:getKey(1),false,false);
		KeyBoard:setLedRed( 1,  Key1Counter:get() ==1 )
		KeyBoard:setLedGreen( 1,  Key1Counter:get() ==2 )
		KeyBoard:setLedBlue( 1,  Key1Counter:get() ==3 )
		
<<<<<<< HEAD
		--setOut(1,( Key1Counter:get() ==1))
		--setOut(2,( Key1Counter:get() ==2))
		--setOut(3,( Key1Counter:get() ==3))
=======
		setOut(1, Key1Counter:get() ==1)
		setOut(2, Key1Counter:get() ==2)
		setOut(3, Key1Counter:get() ==3)
		
>>>>>>> 6834365a65e2d38d409842e9db1990f83eb299da
		
		Key2Counter:process(KeyBoard:getKey(2),false,false);
		KeyBoard:setLedRed( 2,  Key2Counter:get() ==1 )
		KeyBoard:setLedGreen( 2,  Key2Counter:get() ==2 )
		KeyBoard:setLedBlue( 2,  Key2Counter:get() ==3 )
		
<<<<<<< HEAD
		--setOut(4,( Key2Counter:get() ==3))
=======
		setOut(4, Key2Counter:get() ==1)
		
>>>>>>> 6834365a65e2d38d409842e9db1990f83eb299da
		 
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
		
<<<<<<< HEAD
		setOut(1,true)
		 setOut(2,true)
		 setOut(3,true)
		 setOut(4,true)
		 setOut(5,true)
		 setOut(6,true)
		 setOut(7,true)
		 setOut(8,true)
		 setOut(9,true)
		 setOut(10,true)
		 setOut(11,true)
		 setOut(12,true)
		 setOut(13,true)
		 setOut(14,true)
		 setOut(15,true)
		 setOut(16,true)
		 setOut(17,true)
		 setOut(18,true)
		 setOut(19,true)
		 setOut(20,true)
=======
		setOut(18, Key8Counter:get() ==1)
		setOut(19, Key8Counter:get() ==2)
		setOut(20, Key8Counter:get() ==3)
		 
		 
>>>>>>> 6834365a65e2d38d409842e9db1990f83eb299da
					
		   
	   Yield() 
	end
end