GLOW_PLUG_1_2 	= 1
GLOW_PLUG_3_4  	= 2
STARTER_CH	 	= 3
OIL_FAN_CH		= 4
CUT_VALVE		= 5
HIGH_BEAM_CH   	= 6
REAR_LIGTH_CH   = 7
FUEL_PUMP_CH    = 8
STOP_VALVE		= 9
WATER_CH    	= 10
DOWN_GEAR_CH   	= 11
KL30			= 12
HORN_CH 		= 13
UP_GEAR     	= 14
STEERING_WEEL_VALVE_CH   	= 15
WIPERS_CH   	= 16
LEFT_TURN_CH 	= 18
RIGTH_TURN_CH 	= 17
STOP_CH	    	= 19
LOW_BEAM_CH 	= 20
PRESSURE_IN 	= 1
STARTER_IN		= 2
DOOR2_SW		= 3
STOP_SW			= 4
DOOR1_SW		= 5
ING_IN			= 6
PARKING_SW		= 7
WIPER_IN		= 8
TEMP_OFFSET		= 40
 --функция иницализации
function init()
    ConfigCan(1,1000);	 								   
	setOutConfig(GLOW_PLUG_1_2,30,1,5000,40) -- на пуске свечи жрут 32-35А. Поскольку в ядре номинальный ток ограничен 30а, ставлю задержку на 5с
	setOutConfig(GLOW_PLUG_3_4,30,1,5000,40)
	setOutConfig(STARTER_CH,15,1,100,40)
	setOutConfig(CUT_VALVE,4,1,4500,60)
	setOutConfig(KL30,8,1,3000,20)
	setOutConfig(LEFT_TURN_CH,4,1,0,4,0) -- для повортников влючен режим ухода в ошибку до перезапуска. Если так не сделать, при кз будет постоянно сбрасываться ошибка
	OutResetConfig(LEFT_TURN_CH,1,0)
	setOutConfig(RIGTH_TURN_CH,4,1,0,4,0)
	OutResetConfig(RIGTH_TURN_CH,1,0)
	setOutConfig(OIL_FAN_CH,20,1,3000,50)
	
	setOutConfig(HIGH_BEAM_CH,11)
	setOutConfig(STOP_CH,5,1,0,5,0)
	setOutConfig(FUEL_PUMP_CH,15)	
	setOutConfig(WIPERS_CH,10,0,100,30)
	setOutConfig(WATER_CH,8,0,100,30)
	setOutConfig(UP_GEAR, 8)
	setOutConfig(DOWN_GEAR_CH,8)
	setOutConfig(STEERING_WEEL_VALVE_CH,8)
	setOutConfig(REAR_LIGTH_CH,20)
	setOutConfig(STOP_VALVE,8)
	setOutConfig(HORN_CH,7,1,1000,15)
	setOutConfig(LOW_BEAM_CH,3)
	setPWMGroupeFreq(5, 100)
    setDINConfig(PRESSURE_IN,0)
	setDINConfig(ING_IN,0)
	setDINConfig(STOP_SW,0)
    setDINConfig(WIPER_IN,1)
    setDINConfig(STARTER_IN,0)
	setDINConfig(PARKING_SW,1)
    setDINConfig(DOOR2_SW,0)
	setDINConfig(DOOR1_SW,0)
end

function ALL_OFF()
	setOut(1, false)
	setOut(2, false)
	setOut(3, false)
	setOut(4, false)
	setOut(5, false)
	setOut(6, false)
	setOut(7, false)
	setOut(8, false)
	setOut(9, false)
	setOut(10, false)
	setOut(11, false)
	setOut(12, false)
	setOut(13, false)
	setOut(14, false)
	setOut(15, false)
	setOut(16, false)
	setOut(17, false)
	setOut(18, false)
	setOut(19, false)
	setOut(20, false)
end
--главная функция
main = function ()
    init()	
    local KeyBoard			= KeyPad8:new(0x15)--создание объекта клавиатура c адресом 0x15
	local DASH				= Dashboard:new(0x30,200)
	local CanIn         	= CanInput:new(0x28) -- <адрес can>, < таймаут>	
	local CanToDash			= CanOut:new(0x29, 100)
	local Turns	        	= TurnSygnals:new(800)
	local FlashCounter  	= Counter:new(0,20,0,true)
	local GearCounter   	= Counter:new(0,2,1,false)
	local WaterKeyDelay 	= Delay:new( 800, false)
	local DoorLDelay 		= Delay:new( 3000, false)
	local DoorRDelay 		= Delay:new( 3000, false)
	local BeamCounter   	= Counter:new(1,3,1,true) 
	local FlashTimer    	= Delay:new( 50,  true )
	local FlashToCanTimer   = Delay:new( 200,  true )
	local OilFanTimer		= Delay:new(3000, false)
	local LEFT				= false
	local LEFT_DOOR_EN		= false
	
	local RIGHT_DOOR_EN		= false
	local RIGTH   			= false
	local ALARM				= false	
	local PREHEAT 			= false
	local wipers_on 		= false
	local location 			= false
	local water  			= false
	local work_state 		= false
	local wait_flag  		= false	
    local PreheatTimer 		= 0
	local dash_start 		= false
	local oil_fan_enable 	= false
	local parking_on		= false
	
local t_c = 0

	KeyBoard:setBackLigthBrigth(  3 )
	--рабочий цикл
	while true do		
	    	   --процесс отправки данных о каналах в даш
	    if (( getBat() > 16 ) or (getBat()<7) ) then
			ALL_OFF()
		else
			setOut(KL30, true )
			DASH:process()
			KeyBoard:process() --процесс работы с клавиатурой
			DASH:process()	   --процесс отправки данных о каналах в даш
			dash_start 		= (CanIn:process()==1) --процесс получение данных с входа Can. Переменная становится единицей, как только что-то получили от приборки
			local start 	= getDIN(ING_IN) 	
			local temp     	= ( dash_start ) and ( CanIn:getByte(5) ) or 0   -- получаем первый байт из фрейма, температура охлаждающей жидкости
			local OilTemp  	= ( dash_start ) and ( CanIn:getByte(6)  ) or 40 --  CanOilTempIn:getByte(1)  -- получаем первый байт из фрейма, температура масла
			local RPM 	  	= ( dash_start ) and CanIn:getWordLSB(1) or 0
			local speed     = ( dash_start ) and CanIn:getWordLSB(3) or 0		
				
			--GOD = GOD_TIMER	(KeyBoard:getKey(2) and KeyBoard:getKey(6), not (start or  KeyBoard:getKey(2) or KeyBoard:getKey(6)))
				
			KeyBoard:setBackLigthBrigth( start and 15 or 3 )	-- подсветка клавиатуры
			--как только приходит сигнал зажигания
			setOut(CUT_VALVE, start )		
			setOut(FUEL_PUMP_CH, start)
			local START_ENABLE = KeyBoard:getKey(1) and start --and (RPM < 700)
			local stop_signal = getDIN(STOP_SW) 
			 
			setOut( STARTER_CH, START_ENABLE and stop_signal )
			KeyBoard:setLedGreen( 1, START_ENABLE  )		
			
			--задержка на срабатывания концевиков
			DoorLDelay:process_delay( getDIN(DOOR2_SW))
			DoorRDelay:process_delay( getDIN(DOOR1_SW))
			
		
			local DOOR_BREAK =  DoorLDelay:get() or DoorRDelay:get()
			--включение концевиков
			parking_on =  getDIN(PARKING_SW) or DOOR_BREAK
			setOut(STOP_VALVE, not parking_on )
			
			--блок управления вентилятром охлаждения масла
			if  ( ( OilTemp >= (50+ TEMP_OFFSET)) or ( OilTemp == 0) ) then
				oil_fan_enable = true
			end
			if  ( ( OilTemp < (40+ TEMP_OFFSET)) ) then
				oil_fan_enable = false
			end
			local oilfan_start = oil_fan_enable and (not START_ENABLE) and start 
			OilFanTimer:process( oilfan_start )
			setOut(OIL_FAN_CH, OilFanTimer:get() )
			--конец блока управления вентилятром охлаждения масла
	
			-- блок переключением передач и заденего хода
			local gear_enable =  stop_signal --and (speed == 0) --and ( RPM < 1000 )
			GearCounter:process(KeyBoard:getKey(4) and gear_enable,KeyBoard:getKey(8) and gear_enable,  (not start) or parking_on  )
			local UP_MOVE	 = (GearCounter:get() == 2)	
			KeyBoard:setLedGreen(4, UP_MOVE)		
			setOut(UP_GEAR ,  UP_MOVE )
			
			local REAR_MOVE = (GearCounter:get() == 0) 
			KeyBoard:setLedGreen(8, REAR_MOVE)
			setOut(DOWN_GEAR_CH,  REAR_MOVE)
			setOut(REAR_LIGTH_CH, REAR_MOVE) --задний ход
			--конец блока переключения передач
			
			--блок управления горном
			local HORN = KeyBoard:getKey(7) and start
			setOut(HORN_CH, HORN )
			KeyBoard:setLedGreen(7,HORN )
			--конец блока упрвления горонм
					
			--Блок управления дальним и билжним светом и стоп сигналом
			BeamCounter:process( KeyBoard:getKey(2), false, not start)  -- cчетчик process( инкримент, дикремент, сборс)
			local Ligth_Enable = ( BeamCounter:get() ~= 1 ) and (not START_ENABLE) -- если счетчик не равен 1  то true
			setOut( LOW_BEAM_CH, Ligth_Enable  )  -- ближний свет
			setOut( STOP_CH,  Ligth_Enable or (stop_signal and start))  --ближний свет и стоп сигнал
			OutSetPWM(STOP_CH, stop_signal and 99 or 20)
			local HIGH_BEAM = ( BeamCounter:get() == 3 )
			local LOW_BEAM =  ( BeamCounter:get() == 2 ) 
			setOut(HIGH_BEAM_CH, HIGH_BEAM and (not START_ENABLE) )
			KeyBoard:setLedGreen( 2, LOW_BEAM  ) -- если 2 (билжний счет, то зажигаем светодиод)
			KeyBoard:setLedBlue( 2,  HIGH_BEAM ) -- если 3 ( дальний свет, то зажигаем синий свет)
			
			
			--Блок управления дврониками и омывателем		
			KeyBoard:setLedGreen(3, wipers_on and (not water)  )
			KeyBoard:setLedBlue(3, water)
			if (KeyBoard:getKey(3) and (wipers_on == false)) then		-- если все выключено, запускаем алгоримт
				wipers_on  = true
				work_state = false
				wait_flag  = true
			end
			if wipers_on then
				if wait_flag then-- смотрим, сколько удерживается кнопка		    				    
				    local water_enable = water
				    water = WaterKeyDelay:process( true, not KeyBoard:getKey(3) )
					if not KeyBoard:getKey(3) then			       -- если кнопка отпущена
						if not (work_state and water_enable )then		-- условие, которео позволяет не реагировать на отпускание кнопки после самого первого нажатия
							work_state = not work_state
						end
						wait_flag = false		 
					end
				else
					wait_flag = work_state and KeyBoard:getKey(3)	-- если нажали кнопку в дворники рабоатают
					wipers_on = not ( ( not work_state ) and (  not KeyBoard:getKey(3) ) )  	-- выклчюаем, если было нажатие на конопку меньше 1200 мс
				end
			end
			location = location and getDIN(WIPER_IN)
			if wipers_on then
				location = true
			end
			wipers_on = wipers_on and start
			water = water and start
			setOut(WIPERS_CH, wipers_on or location )
			setOut(WATER_CH , water )
			-- конец блока дворников
			
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
			KeyBoard:setLedRed(5,  Turns:getAlarm() )
			KeyBoard:setLedRed(6,  Turns:getAlarm() )
			--Блок управление вспышками на повортниках
			local FlashEnabel =   (not (RIGTH or LEFT)) and (not ALARM) and start--Ligth_Enable--start
			FlashTimer:process( true,  not FlashEnabel  )
			FlashCounter:process(FlashTimer:get(),false, not FlashEnabel )
			local right_flash = ( FlashCounter:get() == 1 ) or ( FlashCounter:get() == 4 )
			local left_flash  = ( FlashCounter:get() == 7 ) or ( FlashCounter:get() == 11 )
			local RIGTH_ENABLE = ( Turns:getAlarm() or Turns:getRight() ) and (not START_ENABLE) 
			local LEFT_ENABLE  = ( Turns:getAlarm() or Turns:getLeft() ) and (not START_ENABLE)  
			setOut(RIGTH_TURN_CH, (right_flash or RIGTH_ENABLE) and start )
			setOut(LEFT_TURN_CH,  (left_flash  or LEFT_ENABLE) and start )
			
			--блока предпрогрева.
			if start then
				if START_ENABLE then
					PreheatTimer = 11000
					PREHEAT 	 = false
				end 
				if PreheatTimer < 11000 then	
					PreheatTimer = PreheatTimer + getDelay()
					if temp < (40 +TEMP_OFFSET) then
						PREHEAT = (PreheatTimer < 10000 )
					elseif temp < (50+TEMP_OFFSET) then
						PREHEAT = (PreheatTimer < 4000 )
					elseif temp < (60+TEMP_OFFSET) then
						PREHEAT = (PreheatTimer < 3000 )
					elseif temp < (70+TEMP_OFFSET) then
						PREHEAT = (PreheatTimer < 2000 )
					elseif temp < (100+TEMP_OFFSET) then
						PREHEAT = (PreheatTimer < 1000 )
					elseif temp>= (100+TEMP_OFFSET) then
						PREHEAT = false
					end
				end
			else
				PreheatTimer = 0					--сбрасываем таймер, если зажигание выключено
			end
			PREHEAT = PREHEAT and start
			setOut(GLOW_PLUG_1_2, PREHEAT )
			setOut(GLOW_PLUG_3_4, PREHEAT )
			KeyBoard:setLedRed( 1,  PREHEAT  )	
			--конец блока предпрогрева
			CanToDash:setBit(3, 3, getDIN(DOOR1_SW) )
			CanToDash:setBit(3, 2, getDIN(DOOR2_SW) )
			CanToDash:setBit(3, 1, HIGH_BEAM )
			CanToDash:setBit(2, 8, Ligth_Enable)
			CanToDash:setBit(2, 7, Turns:getAlarm())
			CanToDash:setBit(2, 6, RIGTH_ENABLE )
			CanToDash:setBit(2, 5, LEFT_ENABLE)
			CanToDash:setBit(2, 4, PREHEAT)
			CanToDash:setBit(2, 3, UP_MOVE)
			CanToDash:setBit(2, 2, REAR_MOVE)
			CanToDash:setBit(2, 1, not ( REAR_MOVE or UP_MOVE or parking_on ) )
			CanToDash:setBit(1, 4, parking_on )
			CanToDash:process()
			
			--блок для передачи сигналов поворотников в дашборд, что бы было видно их работу в сервисном режиме
			FlashToCanTimer:process(true, not FlashEnabel)
		    if ( not FlashEnabel) then
			 LEFT_TO_CAN  = getOutStatus(LEFT_TURN_CH)
			 RIGHT_TO_CAN = getOutStatus(RIGTH_TURN_CH)
			else
			    if (FlashToCanTimer:get()==true) then
				  t_c = (t_c ==0) and 0x1 or 0
				end
				 LEFT_TO_CAN = (t_c ==0) and 0x01 or 0x00
				 RIGHT_TO_CAN = (t_c == 0x01) and 0x01 or 0x00
			end			
	   end
	   Yield()
	end
end