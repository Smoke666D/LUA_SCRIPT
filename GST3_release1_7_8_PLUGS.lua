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
WATER_FAN_CH  	= 15
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
RPM_IN			= 9
TEMP_OFFSET		= 40
CARS            = 1
V1				= 1
V2				= 7
V3				= 7
 --функция иницализации
function init()
    ConfigCan(1,500);	 								   
	setOutConfig(GLOW_PLUG_1_2,30,1,5000,40) -- на пуске свечи жрут 32-35А. Поскольку в ядре номинальный ток ограничен 30а, ставлю задержку на 5с
	setOutConfig(GLOW_PLUG_3_4,30,1,5000,40)
	setOutConfig(STARTER_CH,20,1,5000,40)
	setOutConfig(CUT_VALVE,4,1,5000,60)
	setOutConfig(KL30,8,1,3000,20)
	setOutConfig(LEFT_TURN_CH,4,1,0,4,0) -- для повортников влючен режим ухода в ошибку до перезапуска. Если так не сделать, при кз будет постоянно сбрасываться ошибка
	OutResetConfig(LEFT_TURN_CH,1,0)
	setOutConfig(RIGTH_TURN_CH,4,1,0,4,0)
	OutResetConfig(RIGTH_TURN_CH,1,0)
	setOutConfig(OIL_FAN_CH,20,1,7000,70)
	OutResetConfig(OIL_FAN_CH,0,3000)
    setOutConfig(WATER_FAN_CH,25,1,7000,100)
	OutResetConfig(WATER_FAN_CH,0,3000)
	setOutConfig(HIGH_BEAM_CH,11)
	setOutConfig(STOP_CH,5,1,0,5,0)
	setOutConfig(FUEL_PUMP_CH,10,1,60000,15)
    setOutConfig(WIPERS_CH,8,0,5000,30)
	setOutConfig(WATER_CH,8,1,5000,30)
	setOutConfig(UP_GEAR, 8)
	setOutConfig(DOWN_GEAR_CH,8)
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
    setDINConfig(DOOR2_SW,0,3000,0)
	setDINConfig(DOOR1_SW,0,3000,0)

	setAINCalTable(1,	
					4.89,-40,
					4.81,-30,
					4.69,-20,
					4.50,-10,
					4.27,0,	     
					3.95,10,
					3.57,20,
					3.15,30,
					2.70,40,
					2.27,50,
					1.86,60,
					1.51,70,
					1.22,80,
					0.97,90,
					0.78,100,
					0.63,110,
					0.57,120
				    )
				setAINCalTable(2,	
					4.89,-40,
					4.81,-30,
					4.69,-20,	 
					4.50,-10,	 
					4.27,0,	     
					3.95,10,
					3.57,20,
					3.15,30,
					2.70,40,
					2.27,50,
					1.86,60,
					1.51,70,
					1.22,80,
					0.97,90,
					0.78,100,
					0.63,110,
					0.57,120
				    )
				 setAINCalTable(3,
				 	4.89,-40,
					4.81,-30,
				    4.69,-20,
					4.50,-10,				 
					4.27,0,	     
					3.95,10,
					3.57,20,
					3.15,30,
					2.70,40,
					2.27,50,
					1.86,60,
					1.51,70,
					1.22,80,
					0.97,90,
					0.78,100,
					0.63,110,
					0.57,120
				    )
end

function ChannelCheck( number, nominal)

 return  (  (( getCurrent( number) < nominal ) and (getOutStatus(number)== 1)) or (getOutStatus(number) > 1 ) )
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
	local CanIn1         	= CanInput:new(0x38)
	local CanIn         	= CanInput:new(0x28) -- <адрес can>, < таймаут>	
	local CanToDash			= CanOut:new(0x29, 100,8)
	local CanVersion		= CanOut:new(0x700, 1000,8)
	local Turns	        	= TurnSygnals:new(800)
	local FlashCounter  	= Counter:new(0,20,0,true)
	local GearCounter   	= Counter:new(0,2,1,false)
	local WaterKeyDelay 	= Delay:new( 800, false)
	local LigthKeyDelay     = Delay:new (1500, false)
	local BeamCounter   	= Counter:new(2,3,3,true) 
	local FlashTimer    	= Delay:new( 50,  true )
	local FlashToCanTimer   = Delay:new( 200,  true )
	local OilFanTimer		= Delay:new(9000, false)
	local WaterFanTimer		= Delay:new(9000, false)
	local GeneratorTimer	= Delay:new(1000, false)
	local StopSignalErrorTimer	= Delay:new(100, false)
	local wipers_on_delay   = Delay:new(500,false)
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
	local water_fan_enable 	= false
	local parking_on		= false
	local POWER_OFF_ALARM   = false
    local t_c = 0
	local light_on  		= false
	local light_off			= false
	local light_work 		= false
	local self_check 		= false
	local self_check_enable = true
	local scFSM	= 0
	local STOP_VALVE_ERROR   = false
	local REAR_VALVE_ERROR   = false
	local FORWAR_VALVE_ERROR = false
	local OIL_FAN_ERROR      = false
	local CUT_VALVE_ERROR    = false
	local LOW_BEAM_ERROR     = false
	local STOP_SIGNAL_ERROR  = false
	local HIGH_BEAM_ERROR	 = false
	local REAR_LIGHT_ERROR   = false
	local FUEL_PUMP_ERROR	 = false
	local WATER_ERROR		 = false
	local WIPERS_ERROR		 = false
	local STARTER_ERROR		 = false
	local RIGTH_TURN_ERROR	 = false
	local LEFT_TURN_ERROR    = false
	local HORN_ERROR		 = false
    local wip_en = false
	local GLOW_PLUG_ERROR    = false
	local GENERATOR_ERROR	 = false
	local oil_level			= false
	local oil_presure		= false
	
	KeyBoard:setBackLigthBrigth(  3 )
	
	
	CanVersion:setByte(1,CARS)
    CanVersion:setByte(2,V1)
    CanVersion:setByte(3,V2)
    CanVersion:setByte(4,V3)
	--рабочий цикл
	while true do		
	    	   --процесс отправки данных о каналах в даш
	    if (( getBat() > 16 ) or (getBat()<6) ) then
			ALL_OFF()
			PreheatTimer = 0
		else
			setOut(KL30, true )
			KeyBoard:process() --процесс работы с клавиатурой
			DASH:process()	   --процесс отправки данных о каналах в даш
			dash_start 		=  (CanIn:process()==1) --процесс получение данных с входа Can. Переменная становится единицей, как только что-то получили от приборки
			CanIn1:process()
			local start 	= getDIN(ING_IN) 
			
            if (not self_check  ) and start then
				self_check = true
			end
			if not start then
				self_check = false
				scFSM = 0
			end
       			
		    if ( (self_check  ) and ( scFSM <=20 ) ) then
				scFSM = scFSM + 1
				if scFSM == 1 then
					setOut(STOP_VALVE, true)
					setOut(DOWN_GEAR_CH, true)
				 	setOut(UP_GEAR, true)
					OutSetPWM(STOP_CH, 99)
					setOut( STOP_CH, true)
				elseif scFSM == 20 then
				   STOP_VALVE_ERROR   = ChannelCheck( STOP_VALVE, 1)
				   REAR_VALVE_ERROR   = ChannelCheck( DOWN_GEAR_CH, 2)
				   FORWAR_VALVE_ERROR = ChannelCheck( UP_GEAR, 2)
				   STOP_SIGNAL_ERROR  = ChannelCheck( STOP_CH, 0.7)
				end
			else
				local temp     	= ( dash_start ) and ( CanIn:getByte(5) ) or 0   -- получаем первый байт из фрейма, температура охлаждающей жидкости
				local OilTemp  	= ( dash_start ) and ( CanIn:getByte(6)  ) or 0 --  CanOilTempIn:getByte(1)  -- получаем первый байт из фрейма, температура масла
				local RPM 	  	= ( dash_start ) and CanIn:getWordLSB(1) or 0
				local speed     = ( dash_start ) and CanIn:getWordLSB(3) or 0
                local dd        =	 CanIn1:getByte(1) 			
                KeyBoard:setLedBlue(1, (dd  & 0x01) == 0x01 )
KeyBoard:setLedBlue(2, (dd  & 0x02 ) ==0x02  )
KeyBoard:setLedBlue(3, (dd  & 0x04 ) ==0x04)
KeyBoard:setLedBlue(4, (dd  & 0x08)  ==0x08)
KeyBoard:setLedBlue(5, (dd  & 0x10)  ==0x10)
KeyBoard:setLedBlue(6, (dd  & 0x20)  ==0x20)
KeyBoard:setLedBlue(7, (dd  & 0x40)  ==0x40 )
KeyBoard:setLedBlue(8, (dd  & 0x80)  ==0x80)
				
				--local oil_signal = --[[( dash_start ) and]] ( CanIn:getByte(7) == 0x40)  --or false		
				KeyBoard:setBackLigthBrigth( start and 15 or 3 )	-- подсветка клавиатуры
				--как только приходит сигнал зажигания
				setOut(CUT_VALVE, start )		
				setOut(FUEL_PUMP_CH, start)
				local START_ENABLE = KeyBoard:getKey(1) and start --and (RPM < 700)
				local stop_signal = getDIN(STOP_SW) 
			 
				setOut( STARTER_CH, START_ENABLE and stop_signal )
				KeyBoard:setLedGreen( 1, START_ENABLE  )		
			
				--включение концевиков
				parking_on =  getDIN(PARKING_SW) or getDIN(DOOR1_SW) or getDIN(DOOR2_SW)
				setOut(STOP_VALVE, (not parking_on )  and start )
				--блок управления вентилятром охлаждения масла
				if  ( ( OilTemp >= (50+ TEMP_OFFSET)) or ( OilTemp == 0) ) then
					oil_fan_enable = true
				else
					if  ( ( OilTemp < (40+ TEMP_OFFSET)) ) then
						oil_fan_enable = false
					end
				end
				local oilfan_start = oil_fan_enable and (not START_ENABLE) and start 
				OilFanTimer:process( oilfan_start )
				setOut(OIL_FAN_CH, OilFanTimer:get())
				--конец блока управления вентилятром охлаждения масла
				--блок управления вентелятором охдаждения
				if  ( ( temp >= (87+ TEMP_OFFSET)) or ( temp == 0) ) then
					water_fan_enable = true
				else
					if  ( ( temp < (83+ TEMP_OFFSET)) ) then
					water_fan_enable = false
					end
				end
				local water_fan_start = water_fan_enable and (not START_ENABLE) and start 
				WaterFanTimer:process( water_fan_start )
				setOut(WATER_FAN_CH, WaterFanTimer:get())
				--setOut(WATER_FAN_CH, true)
				--конец блока управления вентелятором охдаждения
				-- блок переключением передач и заденего хода
				local gear_enable =  stop_signal and not parking_on --and (speed == 0) --and ( RPM < 1000 )
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
				--если все выключено, то запускаем алгоритм по нажатию клавиши
				
				if ( KeyBoard:getKey(2) and (light_on == false) and start ) then
					light_on  = true 
					light_work = false	
				end
				light_off =  LigthKeyDelay:process( true, not KeyBoard:getKey(2) ) or not start
				if light_on then
				    if not start or light_off  then
					   light_on = false
					   light_work = false
					end
					if light_work then					
					    BeamCounter:process( not KeyBoard:getKey(2)  , false,  false )
					else
						BeamCounter:process( false,  false, true  )
					end
					if  not KeyBoard:getKey(2) and not light_work then 
							light_work =  true
					end	
				end
				
				local Ligth_Enable = light_on  and (not START_ENABLE) and start and light_work 
				OutSetPWM(STOP_CH, stop_signal and 99 or 20)
				local HIGH_BEAM = ( BeamCounter:get() == 3 ) and Ligth_Enable 
				local LOW_BEAM =  ( BeamCounter:get() == 2 ) and Ligth_Enable
				setOut( HIGH_BEAM_CH, HIGH_BEAM  )  -- дальний свет
				setOut( LOW_BEAM_CH, Ligth_Enable   )  -- ближний свет
				setOut( STOP_CH,  Ligth_Enable or (stop_signal and start))  --ближний свет и стоп сигнал
				KeyBoard:setLedGreen( 2, LOW_BEAM) -- если 2 (билжний счет, то зажигаем светодиод)
			--	KeyBoard:setLedBlue(  2, HIGH_BEAM ) -- если 3 ( дальний свет, то зажигаем синий свет)
				--конец блока управления светом

				--Блок управления дврониками и омывателем		
				KeyBoard:setLedGreen(3, wipers_on and (not water)  )
			--	KeyBoard:setLedBlue(3, water)
				if (KeyBoard:getKey(3) and (wipers_on == false) and start) then		-- если все выключено, запускаем алгоримт
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
				
				location  = wipers_on or  ( location and getDIN( WIPER_IN ) )
	
				wipers_on = wipers_on and start
			--	wip_en = wipers_on_delay:process( wipers_on  or location )		
		
				setOut(WIPERS_CH, wipers_on_delay:process( wipers_on  or location ))
				setOut(WATER_CH , water and start )
				-- конец блока дворников
			
				--аогоритм управления с 2-х клавиш повортниками и если 2 вместе, то аварийка
				if not start then
					ALARM = true
					POWER_OFF_ALARM = true
				else
					if POWER_OFF_ALARM then
						POWER_OFF_ALARM = false
						KeyBoard:resetToggle(5, true )
						KeyBoard:resetToggle(6, true )
						ALARM = false
					end
					if  ALARM then
						ALARM = (not ( KeyBoard:getToggle(5) or KeyBoard:getToggle(6) ) ) 
						KeyBoard:resetToggle(5,not ALARM )
						KeyBoard:resetToggle(6,not ALARM )
					else
						RIGTH = KeyBoard:getToggle(6)
						LEFT =  KeyBoard:getToggle(5)
						KeyBoard:resetToggle(5,KeyBoard:getKey(6) or (not start) )
						KeyBoard:resetToggle(6,KeyBoard:getKey(5) or (not start) )
						ALARM = KeyBoard:getKey(5) and KeyBoard:getKey(6)
						ALARM = ALARM or not start
					end
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
				setOut(RIGTH_TURN_CH, (right_flash or RIGTH_ENABLE)  )
				setOut(LEFT_TURN_CH,  (left_flash  or LEFT_ENABLE)  )
			
			    oil_level   = oil_signal-- and PREHEAT
			    oil_presure = oil_signal-- and (not PREHEAT)
			
					--блока предпрогрева.
				if start then
					if START_ENABLE then
						PreheatTimer = 31000
						PREHEAT 	 = false
					else
						
						if PreheatTimer < 30000 then	
							PreheatTimer = PreheatTimer + getDelay()
							if temp < (5 +TEMP_OFFSET) then
								PREHEAT = (PreheatTimer < 30000 )	
							elseif temp < (40+TEMP_OFFSET) then
								PREHEAT = (PreheatTimer < 15000 )
							else
								PREHEAT = (PreheatTimer < 5000 )
							end
						end
					end
				
				else
					PreheatTimer = 0					--сбрасываем таймер, если зажигание выключено
				end
				PREHEAT = PREHEAT and start 
				--setOut(GLOW_PLUG_1_2, PREHEAT )
				--setOut(GLOW_PLUG_3_4, PREHEAT )
				KeyBoard:setLedRed( 1, PREHEAT  )	
				--конец блока предпрогрева
				
				
						
				CanToDash:setBit(3, 5, oil_presure )
				CanToDash:setBit(3, 4, oil_level )
				CanToDash:setBit(3, 3, getDIN(DOOR1_SW) )
				CanToDash:setBit(3, 2, getDIN(DOOR2_SW) )
				CanToDash:setBit(3, 1, HIGH_BEAM )
				CanToDash:setBit(2, 8, Ligth_Enable)
				CanToDash:setBit(2, 7, Turns:getAlarm())
				CanToDash:setBit(2, 6, RIGTH_ENABLE )
				CanToDash:setBit(2, 5, LEFT_ENABLE)
				CanToDash:setBit(2, 4,  PREHEAT )
				CanToDash:setBit(2, 3, UP_MOVE)
				CanToDash:setBit(2, 2, REAR_MOVE)
				CanToDash:setBit(2, 1, not ( REAR_MOVE or UP_MOVE or parking_on ) )
				CanToDash:setBit(1, 4, parking_on )
				CanToDash:process()
				--конец
			 
			   CanVersion:process()
			
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
	   end
	   Yield()
	end
	
end