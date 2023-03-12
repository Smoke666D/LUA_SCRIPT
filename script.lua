--Важно Для редактировани использовать редактор, где можно ставить кодировку UTF-8. 
--При кодировке ANSI ломаются скрипты обработки
LOW_BEAM_CH = 10
STOP_CH	    = 9
WATER_CH    = 14
WIPERS_CH   = 13
RIGTH_TURN_CH = 11
LEFT_TURN_CH = 12
REAR_LIGTH_CH  = 1
HIGH_BEAM   = 2
UP_GEAR     = 15
DOWN_GEAR_CH   = 16
REAR_HORN_CH   = 17
HORN_СH      = 18
STARTER_CH	 = 3
function init() --функция иницализации
        ConfigCan(1,1000);
	-- Функции конфинурации канала. Если не вызвать setOutConfig, то канал будет в режиме DISABLE на урвоне ядра. Т.е. физический будет принудительнов выключен, токи не будет считаться, на команды из скрипта не регаирует.
    setOutConfig(REAR_LIGTH_CH,20,0,0,60)   -- 1.  номер канала (1-20), 
								-- 2.  номинальный ток (пока еще не определился с верхней границей), 
								-- 3.  Необязательный агрумент - Сборс ошибки выключением - значение по умолчанию <1>  0 - сборс ошибки  только рестатром системы 1 - сборс ошибки выклчюением канала
								-- 4.  Необязательный агрумент  -время работы в перегузке в мс - значение по умолчанию  - 0, 
							    -- 5.  Необязательный аргумент, - ток перегрузки, значение по умолчанию - номинальный ток. 
							   
	
	--OutResetConfig(1,0,1000)    -- Конфигурация режима перегрузки  1. номера канала 2. Кол-во циклов перегрукзи, если 0, то будет пытаться рестартовать бесконечно, если 1, то сразу после перегрузки удейт в ошибку
						     -- если больше 1, то соотвесвенно будет патться стартануть указаное кол-во раз. 3. Таймаут перед новым запускаом при перегузке
							-- Если не вызывать OutResetConfig, по умолчанию канал после пегрузки идет в ошибку.
	-- в ядре есть алгоримт софт-старта. Пока не вытащил его в скрит. Скоро будет.
	setOutConfig(HIGH_BEAM,11)
	--OutResetConfig(2,1,1)
	setOutConfig(STARTER_CH,60)
	setOutConfig(STOP_CH,5)	
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
	setOutConfig(HORN_CH,8)
	setOutConfig(19,8)
	setOutConfig(20,8)
    setDINConfig(1,1)
    setDINConfig(2,1)
	setPWMGroupeFreq(0, 100)
end
----
-- немножко вкинуну херни про системные функции
--
main = function ()
    local start_enable = false
    local KeyBoard		= KeyPad8:new(0x15)--создание объекта клавиатура c адресом 0x15
	local Turns	        = TurnSygnals:new(800)
	local DASH			= Dashboard:new(0x10,800)
	local BeamCounter   = Counter:new(1,3,1,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)
	local GearCounter   = Counter:new(0,2,1,false)
	local FlashCounter  = Counter:new(0,14,0,true)
	local FlashTimer    = Delay:new( 20, true )
	local WaterKeyDelay = Delay:new( 1200, false)
	local FlashEnabel   = true
	local TURNS		= false
	local ALARM		= false
	local right_flash	= false
	local left_flash	= false
	local Ligth_Enable	= false
	local wipers_on = false
	local location = false
	local water  = false
	local water_counter = 0
	local start =  false
	local work_state = false
	local wait_flag  = false		
	local stop_signal = false
	local REAR_MOVE = false
	local HORN = false
	local speed = 0
::RESTART::
	init()
    DASH:init()
	while true do		
		KeyBoard:process() --процесс работы с клавиатурой
		DASH:process()		
		
	    start = start or getDIN(2)
		if start and not getDin(2) then
		  start = false
		  goto RESTART
		end
		--фишка lua - конструкция  <условие> and <значение если true> or <значение если false>. Но <значение если true> не должно быть false
		--при этом <значения ...> могут быть вычисляемыми, а не только числами или true/false, например ниже есть 
		--Flashing_Light_counter =  (Flashing_Light_counter < 15) and Flashing_Light_counter + 1 or 0  - фактический это перзагружаемый счетчик вверх до 14
		--очень удобная штука как по мне, и с точки зрения LUA виртуальной машины рабоатет быстро
		KeyBoard:setBackLigthBrigth( start and 15 or 3 )	-- подсветка клавиатуры
		
        START_ENABLE = KeyBoard:getKey(1) and start 
		setOut( STARTER_CH, START_ENABLE)
		KeyBoard:setLedRed( 1, START_ENABLE  )
		-- блок переключением передач и заденего хода
		GearCounter:process(KeyBoard:getKey(4),KeyBoard:getKey(8), KeyBoard:getKey(1) or (not start) )												
		KeyBoard:setLedGreen(4, (GearCounter:get() == 2)   )		
		setOut(UP_GEAR,   (GearCounter:get() == 2) )
		--ниже сделал отдельную переменную для что бы не вствлять одну и туже конструкцию, работать будет быстрее
		REAR_MOVE = (GearCounter:get() == 0) 
		KeyBoard:setLedGreen(8, REAR_MOVE)
		setOut(DOWN_GEAR_CH,  REAR_MOVE)
		setOut(REAR_LIGTH_CH, REAR_MOVE) --задний ход
		setOut(REAR_HORN_CH,  REAR_MOVE) --сигнал заднего хода
		--конец блока переключения передач
		
		HORN = KeyBoard:getKey(7) and start
		setOut(HORN_CH, HORN)
		KeyBoard:setLedGreen(7,HORN )		
		
		--Блок управления дальним и билжним светом и стоп сигналом
		BeamCounter:process(KeyBoard:getKey(2),false, not start)  -- cчетчик process( инкримент, дикремент, сборс)
		Ligth_Enable = (BeamCounter:get() ~= 1 )  -- если счетчик не равен 1  то true
		setOut(LOW_BEAM_CH, Ligth_Enable )  -- ближний свет
		setOut(STOP_CH, Ligth_Enable or (stop_signal and start) )  --ближний свет и стоп сигнал
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
			KeyBoard:setLedGreen(3, wipers_on and (not water) )
			KeyBoard:setLedBlue(3, water)				
			if (KeyBoard:getKey(3) and (wipers_on == false)) then		-- если все выключено, запускаем алгоримт	
				wipers_on  = true
				work_state = false
				wait_flag  = true			
			end
			if wipers_on then			
				if wait_flag then							-- смотрим, сколько удерживается кнопка
				    water = WaterKeyDelay:process(true, not KeyBoard:getKey(3))
					if not KeyBoard:getKey(3) then			       -- если кнопка отпущена
						if not (work_state and water )then		-- условие, которео позволяет не реагировать на отпускание кнопки после самого первого нажатия	
							work_state = not work_state	
						end
						wait_flag = false				 
					end			
				else
					wait_flag = work_state and KeyBoard:getKey(3)	-- если нажали кнопку в дворники рабоатают
					wipers_on = not ( ( not work_state ) and (  not KeyBoard:getKey(3) ) ) 	-- выклчюаем, если было нажатие на конопку меньше 1200 мс.								
				end				
			end		
			location = location and getDIN(1)
			if wipers_on then
				location = true
			end
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
				TURNS = KeyBoard:getToggle(6) or KeyBoard:getToggle(5)
				KeyBoard:resetToggle(5,KeyBoard:getKey(6) or (not start) )
				KeyBoard:resetToggle(6,KeyBoard:getKey(5) or (not start) )
				ALARM = KeyBoard:getKey(5) and KeyBoard:getKey(6)
			end
			Turns:process( start, LEFT, RIGTH, ALARM)
			--упавление светодиодами 5 и 6-й конопо и выходами повортников
			KeyBoard:setLedGreen(5, Turns:getLeft()  or Turns:getAlarm())
			KeyBoard:setLedGreen(6, Turns:getRight() or Turns:getAlarm())
			
		    --Блок управление вспышками на повортниках
		    FlashEnabel =   (not TURNS) and (not ALARM) and Ligth_Enable  
			FlashTimer:process( true, not FlashEnabel )
			FlashCounter:process(FlashTimer:get(),false, not FlashEnabel )
			right_flash = ( FlashCounter:get() == 1 ) or ( FlashCounter:get() == 4 )
			left_flash  = ( FlashCounter:get() == 7 ) or ( FlashCounter:get() == 11 )
			
			setOut(RIGTH_TURN_CH, right_flash or Turns:getAlarm() or Turns:getRight())
			setOut(LEFT_TURN_CH,  left_flash  or Turns:getAlarm() or Turns:getLeft())
		
	   Yield() 
	end
end