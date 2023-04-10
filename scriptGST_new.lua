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
LEFT_TURN_CH 	= 17
RIGTH_TURN_CH 	= 18
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

 --функция иницализации
function init()
    ConfigCan(1,1000);	 								   
	setOutConfig(GLOW_PLUG_1_2,30,1,5000,40) -- на пуске свечи жрут 32-35А. Поскольку в ядре номинальный ток ограничен 30а, ставлю задержку на 5с
	setOutConfig(GLOW_PLUG_3_4,30,1,5000,40)
	setOutConfig(STARTER_CH,15,1,100,40)
	setOutConfig(CUT_VALVE,4,1,4500,60)
	setOutConfig(KL30,8,1,3000,20)
	setOutConfig(LEFT_TURN_CH,4,0) -- для повортников влючен режим ухода в ошибку до перезапуска. Если так не сделать, при кз будет постоянно сбрасываться ошибка
	OutResetConfig(LEFT_TURN_CH,1,0)
	setOutConfig(RIGTH_TURN_CH,4,0)
	OutResetConfig(RIGTH_TURN_CH,1,0)
	setOutConfig(OIL_FAN_CH,10,1,3000,50)
	setOutConfig(HIGH_BEAM_CH,11)
	setOutConfig(STOP_CH,5)
	setOutConfig(FUEL_PUMP_CH,15)	
	setOutConfig(WIPERS_CH,10,0,100,30)
	setOutConfig(WATER_CH,8,0,100,30)
	setOutConfig(UP_GEAR, 8)
	setOutConfig(DOWN_GEAR_CH,8)
	setOutConfig(STEERING_WEEL_VALVE_CH,8)
	setOutConfig(REAR_LIGTH_CH,20)
	setOutConfig(STOP_VALVE,8)
	setOutConfig(HORN_CH,7,1)
	setOutConfig(LOW_BEAM_CH,3)
	setPWMGroupeFreq(5, 100)
    setDINConfig(PRESSURE_IN,0)
	setDINConfig(ING_IN,0)
	setDINConfig(STOP_SW,0)
    setDINConfig(WIPER_IN,1)
    setDINConfig(STARTER_IN,0)
	setDINConfig(PARKING_SW,0)
    setDINConfig(DOOR2_SW,0)
	setDINConfig(DOOR1_SW,0)
end
--главная функция
main = function ()

    init()	
    local KeyBoard		= KeyPad8:new(0x15)--создание объекта клавиатура c адресом 0x15
	local DASH			= Dashboard:new(0x505,800)
	local CanIn         = CanInput:new(0x28) -- <адрес can>, < таймаут>	
	local CanToDash		= CanOut:new(0x29, 100)
	local Turns	        = TurnSygnals:new(800)
	local FlashCounter  = Counter:new(0,20,0,true)
	local GearCounter   = Counter:new(0,2,1,false)
	local WaterKeyDelay = Delay:new( 800, false)
	local BeamCounter   = Counter:new(1,3,1,true) 
	local FlashTimer    = Delay:new( 20,  true )
	local PumpTimer		= Delay:new( 6000,  false )
	local FlashEnabel   = true	
	local LEFT		= false
	local RIGTH   = false
	local ALARM		= false	
    local REAR_MOVE = false
	local UP_MOVE   = false
	local RIGTH_ENABLE = false
	local LEFT_ENABLE = false
	local N_MOVE 	= false
	local PREHEAT = false
	local HIGH_BEAM = false
	local LOW_BEAM = false
	local rear_ligth =  false	
	local Ligth_Enable	= false
	local wipers_on = false
	local location = false
	local water  = false
	local water_enable = false
	local work_state = false
	local wait_flag  = false	
    local PreheatTimer = 0
	local gear_enable = false
	local dash_start = false
	local wheel_start = false		   		
    DASH:init()	
	KeyBoard:setBackLigthBrigth(  3 )
	--рабочий цикл
	while true do		
		KeyBoard:process() --процесс работы с клавиатурой
		DASH:process()	   --процесс отправки данных о каналах в даш
		
		dash_start = (CanIn:process()==1) --процесс получение данных с входа Can. Переменная становится единицей, как только что-то получили от приборки
		local start = getDIN(ING_IN)	
	    local temp     =( dash_start ) and CanIn:getByte(1) or 0   -- получаем первый байт из фрейма, температура охлаждающей жидкости
		local OilTemp  =( dash_start ) and CanIn:getByte(2) or 0 --  CanOilTempIn:getByte(1)  -- получаем первый байт из фрейма, температура масла
		local RPM 	   =( dash_start ) and CanIn:getWord(4) or 0
		local speed    =( dash_start ) and CanIn:getByte(3) or 0		
		local stop_signal = getDIN(STOP_SW)
		KeyBoard:setBackLigthBrigth( start and 15 or 3 )	-- подсветка клавиатуры
		--как только приходит сигнал зажигания
        setOut(CUT_VALVE, start )
		-- управление топливным насосм
		--setOut(FUEL_PUMP_CH, (not PumpTimer:get()) and start)
	    setOut(FUEL_PUMP_CH, start)
        KeyBoard:setLedRed( 1,  PREHEAT  )		
        local START_ENABLE = KeyBoard:getKey(1) and start --and (not PREHEAT)
		setOut( STARTER_CH, START_ENABLE)
		KeyBoard:setLedGreen( 1, START_ENABLE  )		
		setOut(KL30, true )
		
		--setOut(STEERING_WEEL_VALVE_CH,  KeyBoard:getToggle(3)  )	
		setOut(STOP_VALVE, not PARKING_SW)
		--KeyBoard:setLedRed( 3,  KeyBoard:getToggle(3) )
		--KeyBoard:setLedRed( 7,  KeyBoard:getToggle(7)  )
		
		setOut(OIL_FAN_CH, (temp>30) and true or false)
		
		-- блок переключением передач и заденего хода
		wheel_start  = (wheel_start or START_ENABLE) and start
      --  PumpTimer:process(wheel_start,false)		
		--setOut(STEERING_WEEL_VALVE_CH,  PumpTimer:get() )		
		
		rear_ligth = REAR_MOVE and ( not start)   -- зажигаем задний фонраь и подсвечиваем кнопку R синими, если жмем на нее без зажигания
		--KeyBoard:setLedBlue(8, rear_ligth)
	    gear_enable = true--stop_signal -- and (speed == 0) and ( RPM < 1000 )
		GearCounter:process(KeyBoard:getKey(4) and gear_enable,KeyBoard:getKey(8) and gear_enable, KeyBoard:getKey(1) or (not start) )
		UP_MOVE	 = (GearCounter:get() == 2)	and true or false
		KeyBoard:setLedGreen(4, UP_MOVE)		
		setOut(UP_GEAR ,  UP_MOVE )
		--ниже сделал отдельную переменную для что бы не вствлять одну и туже конструкцию, работать будет быстрее
		REAR_MOVE = (GearCounter:get() == 0) 
		KeyBoard:setLedGreen(8, REAR_MOVE)
        setOut(DOWN_GEAR_CH,  REAR_MOVE)
		setOut(REAR_LIGTH_CH, REAR_MOVE or rear_ligth) --задний ход
		N_MOVE = not ( REAR_MOVE and UP_MOVE )
		--конец блока переключения передач
		--блок управления горном
        local HORN = KeyBoard:getKey(7) and start
		setOut(HORN_CH, HORN )
		KeyBoard:setLedGreen(7,HORN )
		--конец блока упрвления горонм
	    --Блок управления дальним и билжним светом и стоп сигналом
		BeamCounter:process(KeyBoard:getKey(2),false, not start)  -- cчетчик process( инкримент, дикремент, сборс)
		Ligth_Enable = (BeamCounter:get() ~= 1 )  -- если счетчик не равен 1  то true
	    setOut(LOW_BEAM_CH, Ligth_Enable and (not START_ENABLE) )  -- ближний свет
		setOut(STOP_CH, ( Ligth_Enable or (stop_signal and start) ) and (not START_ENABLE) )  --ближний свет и стоп сигнал
		OutSetPWM(STOP_CH, stop_signal and 99 or 20)
		HIGH_BEAM = (BeamCounter:get() == 3 ) and true or false
		LOW_BEAM = (BeamCounter:get() == 2 ) and true or false
		setOut(HIGH_BEAM_CH,HIGH_BEAM and (not START_ENABLE) )
		KeyBoard:setLedGreen( 2, LOW_BEAM  ) -- если 2 (билжний счет, то зажигаем светодиод)
		KeyBoard:setLedBlue( 2,  HIGH_BEAM ) -- если 3 ( дальний свет, то зажигаем синий свет)
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
		FlashEnabel =   (not (RIGTH or LEFT)) and (not ALARM) and Ligth_Enable--start
		FlashTimer:process( true,  not FlashEnabel  )
		FlashCounter:process(FlashTimer:get(),false, not FlashEnabel )
		local right_flash = ( FlashCounter:get() == 1 ) or ( FlashCounter:get() == 4 )
		local left_flash  = ( FlashCounter:get() == 7 ) or ( FlashCounter:get() == 11 )
	    RIGTH_ENABLE = ( Turns:getAlarm() or Turns:getRight() ) and (not START_ENABLE)
		LEFT_ENABLE  = ( Turns:getAlarm() or Turns:getLeft() ) and (not START_ENABLE)
		setOut(RIGTH_TURN_CH, right_flash or RIGTH_ENABLE )
		setOut(LEFT_TURN_CH,  left_flash  or LEFT_ENABLE)
		--блока предпрогрева.
		if start then
			if START_ENABLE then
				PreheatTimer = 11000
			end 
			if PreheatTimer < 11000 then	
				PreheatTimer = PreheatTimer + getDelay()
				if temp < 40 then
					PREHEAT = (PreheatTimer < 10000 )
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
				PREHEAT = false
			end
		else
			PreheatTimer = 0					--сбрасываем таймер, если зажигание выключено
		end
		PREHEAT = PREHEAT and start
		setOut(GLOW_PLUG_1_2, PREHEAT )
		setOut(GLOW_PLUG_3_4, PREHEAT )
		--конец блока предпрогрева
		
		
		CanToDash:setBit(1, 8, HIGH_BEAM )
		CanToDash:setBit(1, 7, Ligth_Enable)
		CanToDash:setBit(1, 6, Turns:getAlarm())
		CanToDash:setBit(1, 5, RIGTH_ENABLE )
		CanToDash:setBit(1, 4, LEFT_ENABLE)
		CanToDash:setBit(1, 3, PREHEAT)
		CanToDash:setBit(2, 1, REAR_MOVE)
		CanToDash:setBit(1, 2, UP_MOVE)
		CanToDash:setBit(1, 8, N_MOVE )
		CanToDash:setBit(1, 3, not PARKING_SW )
		CanToDash:process()
	   Yield()
	end
end