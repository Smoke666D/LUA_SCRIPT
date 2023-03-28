--Важно Для редактировани использовать редактор, где можно ставить кодировку UTF-8. 
--При кодировке ANSI ломаются скрипты обработки


GLOW_PLUG_1_2 	= 1
GLOW_PLUG_3_4  	= 2
STARTER_CH	 	= 3
OIL_FAN_CH		= 4
CUT_VALVE		= 5
HIGH_BEAM   	= 6
REAR_LIGTH_CH   = 7
FUEL_PUMP_CH    = 8
STOP_VALVE		= 9
WATER_CH    	= 10
DOWN_GEAR_CH   	= 11
KL30			= 12
HORN_CH 		= 13
UP_GEAR     	= 14
REAR_HORN_CH   	= 15
WIPERS_CH   	= 16
LEFT_TURN_CH 	= 17
RIGTH_TURN_CH 	= 18
STOP_CH	    	= 19
LOW_BEAM_CH 	= 20


STARTER_IN		= 2
DOOR2_SW		= 3
STOP_SW			= 4
DOOR1_SW		= 5
ING_IN			= 6
PARKING_SW		= 7
WIPER_IN		= 8



function init() --функция иницализации
     ConfigCan(1,1000);
	-- setOutConfig(CUT_VALVE,2,1,4500,60)	
	-- Функции конфинурации канала. Если не вызвать setOutConfig, то канал будет в режиме DISABLE на урвоне ядра. Т.е. физический будет принудительнов выключен, токи не будет считаться, на команды из скрипта не регаирует.
    -- setOutConfig(REAR_LIGTH_CH,20)   -- 1.  номер канала (1-20), 
								-- 2.  номинальный ток (пока еще не определился с верхней границей), 
								-- 3.  Необязательный агрумент - Сборс ошибки выключением - значение по умолчанию <1>  0 - сборс ошибки  только рестатром системы 1 - сборс ошибки выклчюением канала
								-- 4.  Необязательный агрумент  -время работы в перегузке в мс - значение по умолчанию  - 0, 
							    -- 5.  Необязательный аргумент, - ток перегрузки, значение по умолчанию - номинальный ток. 
							   
	
	   
	--setOutConfig(GLOW_PLUG_1_2,30,1,5000,40) -- на пуске свечи жрут 32-35А. Поскольку в ядре номинальный ток ограничен 30а, ставлю задержку на 5с
	--setOutConfig(GLOW_PLUG_3_4,30,1,5000,40)
	--setOutConfig(STARTER_CH,15,1,100,40)
	setOutConfig(KL30,5)
	--setOutConfig(LEFT_TURN_CH,2,0) -- для повортников влючен режим ухода в ошибку до перезапуска
	--OutResetConfig(LEFT_TURN_CH,1,0) 
	--setOutConfig(RIGTH_TURN_CH,2,0)
	--OutResetConfig(RIGTH_TURN_CH,1,0)
	--setOutConfig(OIL_FAN_CH,10)		
	--setOutConfig(HIGH_BEAM,11)
	--setOutConfig(STOP_CH,5)	
	--setOutConfig(FUEL_PUMP_CH,15)		
	--setOutConfig(WIPERS_CH,10,0,100,30)
	--setOutConfig(WATER_CH,8,0,100,30)
	--setOutConfig(UP_GEAR, 8)
	--setOutConfig(DOWN_GEAR_CH,8)
	--setOutConfig(REAR_HORN_CH,8)	
	--setOutConfig(REAR_LIGTH_CH,8)	
	setOutConfig(STOP_VALVE,8)	
	--setOutConfig(COOLFAN_CH,8)
	--setOutConfig(HORN_CH,7,1)	
	--setOutConfig(LOW_BEAM_CH,3)		
	
    --setDINConfig(ING_IN,0)	
	setDINConfig(STOP_SW,1)
--    setDINConfig(WIPER_IN,1)
 --   setDINConfig(STARTER_IN,0)
	--setDINConfig(PARKING_SW,0)	
   -- setDINConfig(DOOR2_SW,0)
	--setDINConfig(DOOR1_SW,0)
	--setPWMGroupeFreq(5, 100)
	
end


-- немножко вкинуну херни про системные функции
--
main = function () 
	local start_enable = false
--	local CanTempIn     = CanInput:new(0x28,9000,0x01,30) -- <адрес can>, < таймаут>
	--local CanOilTempIn  = CanInput:new(0x29,100,0x01,30) -- <адрес can>, < таймаут>
	--local CanRPMTempIn  = CanInput:new(0x30,100,0x01,00) -- <адрес can>, < таймаут>
    local KeyBoard		= KeyPad8:new(0x15)--создание объекта клавиатура c адресом 0x15
	local Turns	        = TurnSygnals:new(800)
	local DASH			= Dashboard:new(0x10,800)
	local BeamCounter   = Counter:new(1,3,1,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)
	local GearCounter   = Counter:new(0,2,1,false)
	local FlashCounter  = Counter:new(0,20,0,true)
	local FlashTimer    = Delay:new( 20,  true )
	local WaterKeyDelay = Delay:new( 1200, false)
	local FlashEnabel   = true
	local LEFT		= false
	local RIGTH   = false
	local ALARM		= false
	local right_flash	= false
	local left_flash	= false
	local Ligth_Enable	= false
	local wipers_on = false
	local location = false
	local water  = false
	local water_enable = false
	local start =  false
	local work_state = false
	local wait_flag  = false		
	local stop_signal = false
	local REAR_MOVE = false
	local HORN = false
    local PREHEAT = false	
	local speed = 0
	local temp = 30
    local INGNITION = false
    local OilTemp = 30
    local PreheatTimer = 0
    init()				
    DASH:init()	
	while true do		
		KeyBoard:process() --процесс работы с клавиатурой
		DASH:process()		
	--	CanTempIn:process()
		--CanOilTempIn:process()
	--    temp = CanTempIn:getByte(1)   -- получаем первый байт из фрейма, температура охлаждающей жидкости
		--OilTemp = CanOilTempIn:getByte(1)  -- получаем первый байт из фрейма, температура масла
		
		
	
	
		setOut(KL30, true )
		setOut(STOP_VALVE, true  and  getDIN(STOP_SW) )


		
		
	--[[	INGNITION = getDIN(ING_IN)	
		start = start and INGNITION
		
		--if start and not INGNITION then		 
		--  SYSTEM_RESTASRT()  -- системный вызов перезапуска. !!!Важно, перезапуск будет выполнен после вызова Yield, весь код от вывзова перезапуска до Yield быдут выполнен
							 -- если надо вы
		--end
		
		
		setOut(FUEL_PUMP_CH, start )
		setOut(IGNITION_CH, INGNITION)
		
		
		KeyBoard:setBackLigthBrigth( (start == true) and 15 or 3 )	-- подсветка клавиатуры

		KeyBoard:setLedRed( 1,  PREHEAT  )
		 
        START_ENABLE = KeyBoard:getKey(1) and start and (not PREHEAT)
		setOut( STARTER_CH, START_ENABLE)
		KeyBoard:setLedGreen( 1, START_ENABLE  )
	
	
	
		
	
		
		--Блок управления дальним и билжним светом и стоп сигналом
		stop_signal = getDIN(STOP_SW)
		BeamCounter:process(KeyBoard:getKey(2),false, not start)  -- cчетчик process( инкримент, дикремент, сборс)
		Ligth_Enable = (BeamCounter:get() ~= 1 )  -- если счетчик не равен 1  то true
		setOut(LOW_BEAM_CH, Ligth_Enable )  -- ближний свет
		setOut(STOP_CH, Ligth_Enable or (stop_signal and start) )  --ближний свет и стоп сигнал
		--stop_signal = KeyBoard:getKey(7)
		OutSetPWM(STOP_CH, stop_signal and 99 or 40)		
		setOut(HIGH_BEAM,(BeamCounter:get() == 3 ) )
		KeyBoard:setLedGreen( 2, (BeamCounter:get() == 2 )  ) -- если 2 (билжний счет, то зажигаем светодиод)
		KeyBoard:setLedBlue( 2, (BeamCounter:get() == 3 ) 	) -- если 3 ( дальний свет, то зажигаем синий свет)
		
		
		
		--конец блока управления
			--Блок управления дврониками и омывателем
			--Поскольку мотор останавливается с задержкой и переезжает датчик
			--то сделан триггер loacation
			--При нажатии на кнопку 3 ключаются дворники и загарается зеленый светодид
			--При потроном нажатии дворники выключаются, как толко доедут до базы
			--При удержании кнопки более 1,2 секунд загарается синий светодиод и влючается мотор омывайки
			--Если дворники выключены, то включаются, как буто просто нажата кнопка, если включены, то просто качает мторчик, 
			--после отпускания они остаются в преженем положении
			KeyBoard:setLedGreen(3, wipers_on and (not water)  )
			KeyBoard:setLedBlue(3, water)				
			if (KeyBoard:getKey(3) and (wipers_on == false)) then		-- если все выключено, запускаем алгоримт	
				wipers_on  = true
				work_state = false
				wait_flag  = true			
			end
			if wipers_on then						    
				if wait_flag then-- смотрим, сколько удерживается кнопка				    				    
				    water_enable = water
				    water = WaterKeyDelay:process(true, not KeyBoard:getKey(3)  )
					
					if not KeyBoard:getKey(3) then			       -- если кнопка отпущена
						if not (work_state and water_enable )then		-- условие, которео позволяет не реагировать на отпускание кнопки после самого первого нажатия	
							work_state = not work_state								    
						end
						wait_flag = false				 
					end	
					
				else
					wait_flag = work_state and KeyBoard:getKey(3)	-- если нажали кнопку в дворники рабоатают
					wipers_on = not ( ( not work_state ) and (  not KeyBoard:getKey(3) ) )  	-- выклчюаем, если было нажатие на конопку меньше 1200 мс.								
				end				
			end		
			location = location and getDIN(1)
			if wipers_on then
				location = true
			end		
			wipers_on = wipers_on and start
			water = water and start			
			setOut(WIPERS_CH, wipers_on or location )
			setOut(WATER_CH , water )
			-- конец блока дворников
			--			
			--аогоритм управления с 2-х клавиш повортниками и если 2 вместе, то аварийка
			if  ALARM then
				ALARM = (not ( KeyBoard:getToggle(5) or KeyBoard:getToggle(6))) 
				KeyBoard:resetToggle(5,not ALARM )
				KeyBoard:resetToggle(6,not ALARM )
			else  
			    RIGTH = KeyBoard:getToggle(6)
				LEFT =  KeyBoard:getToggle(5)
				KeyBoard:resetToggle(5,KeyBoard:getKey(6) or (not start) )
				KeyBoard:resetToggle(6,KeyBoard:getKey(5) or (not start) )
				ALARM = KeyBoard:getKey(5) and KeyBoard:getKey(6)
			end
			Turns:process( true, LEFT, RIGTH, ALARM)
			--упавление светодиодами 5 и 6-й конопо и выходами повортников
			KeyBoard:setLedGreen(5, Turns:getLeft()  or Turns:getAlarm())
			KeyBoard:setLedGreen(6, Turns:getRight() or Turns:getAlarm())
			
		    --Блок управление вспышками на повортниках
		    FlashEnabel =   (not (RIGTH or LEFT)) and (not ALARM) and Ligth_Enable  
			FlashTimer:process( true,  not FlashEnabel  )
			FlashCounter:process(FlashTimer:get(),false, not FlashEnabel )
			right_flash = ( FlashCounter:get() == 1 ) or ( FlashCounter:get() == 4 )
			left_flash  = ( FlashCounter:get() == 7 ) or ( FlashCounter:get() == 11 )
			
			setOut(RIGTH_TURN_CH, right_flash or Turns:getAlarm() or Turns:getRight())
			setOut(LEFT_TURN_CH,  left_flash  or Turns:getAlarm() or Turns:getLeft())
		    
			--блока предпрогрева. 
			if start then				
				PreheatTimer = PreheatTimer + getDelay()
			     if temp < 40 then
				   PREHEAT = (PreheatTimer < 8000 ) 
				elseif temp < 50 then
					PREHEAT = (PreheatTimer < 4000 ) 
			    elseif temp < 60 then
					PREHEAT = (PreheatTimer < 3000 ) 
				elseif temp < 70 then
					PREHEAT = (PreheatTimer < 2000 ) 
				elseif temp < 100 then
					PREHEAT = (PreheatTimer < 1000 ) 
				elseif temp>= 100 then
					PREHEAT = false
				end					
			else
				PreheatTimer = 0					--сбрасываем таймер, если зажигание выключено
			end
			setOut(GLOW_PLUG_1_2, PREHEAT and start)
			setOut(GLOW_PLUG_3_4, PREHEAT and start)				  										
		   ]]--
	   Yield() 
	end
end