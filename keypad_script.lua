--Важно Для редактировани использовать редактор, где можно ставить кодировку UTF-8. 
--При кодировке ANSI ломаются скрипты обработки

REAR_LIGTH_CH   = 6
HIGH_BEAM   	= 2
STARTER_CH	 	= 3
PREHEAT_CH2  	= 4
PREHEAT_CH1  	= 5
FUEL_PUMP_CH    = 1
IGNITION_CH     = 7
STOP_CH	    	= 9
LOW_BEAM_CH 	= 10
RIGTH_TURN_CH 	= 11
LEFT_TURN_CH 	= 12
WIPERS_CH   	= 13
WATER_CH    	= 14
UP_GEAR     	= 15
DOWN_GEAR_CH   	= 16
REAR_HORN_CH   	= 17
HORN_CH 		= 18
COOLFAN_CH    	= 19

function init() --функция иницализации
     ConfigCan(1,1000);
	 setOutConfig(FUEL_PUMP_CH,2,1,4500,60)	
	-- Функции конфинурации канала. Если не вызвать setOutConfig, то канал будет в режиме DISABLE на урвоне ядра. Т.е. физический будет принудительнов выключен, токи не будет считаться, на команды из скрипта не регаирует.
    setOutConfig(REAR_LIGTH_CH,20)   -- 1.  номер канала (1-20), 
								-- 2.  номинальный ток (пока еще не определился с верхней границей), 
								-- 3.  Необязательный агрумент - Сборс ошибки выключением - значение по умолчанию <1>  0 - сборс ошибки  только рестатром системы 1 - сборс ошибки выклчюением канала
								-- 4.  Необязательный агрумент  -время работы в перегузке в мс - значение по умолчанию  - 0, 
							    -- 5.  Необязательный аргумент, - ток перегрузки, значение по умолчанию - номинальный ток. 
							   
	
	   -- Конфигурация режима перегрузки  1. номера канала 2. Кол-во циклов перегрукзи, если 0, то будет пытаться рестартовать бесконечно, если 1, то сразу после перегрузки удейт в ошибку
						     -- если больше 1, то соотвесвенно будет патться стартануть указаное кол-во раз. 3. Таймаут перед новым запускаом при перегузке
							-- Если не вызывать OutResetConfig, по умолчанию канал после пегрузки идет в ошибку.
	-- в ядре есть алгоримт софт-старта. Пока не вытащил его в скрит. Скоро будет.
	setOutConfig(HIGH_BEAM,11)
	--OutResetConfig(2,1,1)
	setOutConfig(STARTER_CH,15,1,100,40)
	setOutConfig(STOP_CH,5)	
	
	setOutConfig(IGNITION_CH,15)	
	setOutConfig(LOW_BEAM_CH,3)	
	setOutConfig(LEFT_TURN_CH,8,0) -- для повортников влючен режим ухода в ошибку до перезапуска
	OutResetConfig(LEFT_TURN_CH,1,0) 
	setOutConfig(RIGTH_TURN_CH,8,0)
	OutResetConfig(RIGTH_TURN_CH,1,0)
	setOutConfig(WIPERS_CH,10,0,100,30)
	setOutConfig(WATER_CH,8,0,100,30)
	setOutConfig(UP_GEAR, 8)
	setOutConfig(DOWN_GEAR_CH,8)
	setOutConfig(REAR_HORN_CH,8)
	setOutConfig(PREHEAT_CH1,2)

	setOutConfig(PREHEAT_CH2,2)
	
	setOutConfig(COOLFAN_CH,8)
	setOutConfig(HORN_CH,7,1)
	OutResetConfig(HORN_CH,1,0)
	setOutConfig(20,8)
    setDINConfig(1,1)
    setDINConfig(2,1)
	setPWMGroupeFreq(0, 100)
	setPWMGroupeFreq(4, 5000)
	setOutSoftStart(HORN_CH,5000,40)
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
		
		Key2Counter:process(KeyBoard:getKey(2),false,false);
		KeyBoard:setLedRed( 2,  Key2Counter:get() ==1 )
		KeyBoard:setLedGreen( 2,  Key2Counter:get() ==2 )
		KeyBoard:setLedBlue( 2,  Key2Counter:get() ==3 )
		 
		Key3Counter:process(KeyBoard:getKey(3),false,false);
		KeyBoard:setLedRed( 3,  Key3Counter:get() ==1 )
		KeyBoard:setLedGreen( 3,  Key3Counter:get() ==2 )
		KeyBoard:setLedBlue( 3,  Key3Counter:get() ==3 )
		
		Key4Counter:process(KeyBoard:getKey(4),false,false);
		KeyBoard:setLedRed( 4,  Key4Counter:get() ==1 )
		KeyBoard:setLedGreen( 4,  Key4Counter:get() ==2 )
		KeyBoard:setLedBlue( 4,  Key4Counter:get() ==3 )
		
		Key5Counter:process(KeyBoard:getKey(5),false,false);
		KeyBoard:setLedRed( 5,  Key5Counter:get() ==1 )
		KeyBoard:setLedGreen( 5,  Key5Counter:get() ==2 )
		KeyBoard:setLedBlue( 5,  Key5Counter:get() ==3 )
		
		Key6Counter:process(KeyBoard:getKey(6),false,false);
		KeyBoard:setLedRed( 6,  Key6Counter:get() ==1 )
		KeyBoard:setLedGreen( 6,  Key6Counter:get() ==2 )
		KeyBoard:setLedBlue( 6,  Key6Counter:get() ==3 )
		
		Key7Counter:process(KeyBoard:getKey(7),false,false);
		KeyBoard:setLedRed( 7,  Key7Counter:get() ==1 )
		KeyBoard:setLedGreen( 7,  Key7Counter:get() ==2 )
		KeyBoard:setLedBlue( 7,  Key7Counter:get() ==3 )
		
		Key8Counter:process(KeyBoard:getKey(8),false,false);
		KeyBoard:setLedRed( 8,  Key8Counter:get() ==1 )
		KeyBoard:setLedGreen( 8,  Key8Counter:get() ==2 )
		KeyBoard:setLedBlue( 8,  Key8Counter:get() ==3 )
		
		 
		 
		 
					
		   
	   Yield() 
	end
end