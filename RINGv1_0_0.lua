COIL_POWER_CH   = 1
STARTER_CH	 	= 2
PUMP_044_CH     = 3
PUMPS_CH		= 4
WIPER_LOW_CH    = 5
WIPER_HIGH_CH   = 6
GLASS_FAN_CH 	= 7
GLASS_UP_CH 	= 8
DASH_CH    		= 9
POWER_888_CH  	= 10
JUDGE_POWER_CH	= 11
WHEEL_POWER_CH  = 12
WHEEL_PWM_CH   	= 19
LOW_BEAM_CH		= 14
HIGH_BEAM_CH 	 = 15
STOP_CH			= 16
REAR_LIGTH_CH   = 17
EBU_POWER_CH   	= 18
KEYBOARD_CH		= 13

WIPER_SW   		= 1
FLASH_SW		= 2
RAIN_SW			= 3
WHEEL_ON_SW		= 4
STOP_SW 		= 5
FUEL_PUMP_SW    = 6
ENGINE_ON_SW    = 7
EBU_PUMP        = 8
WIPER_HOME_SW   = 9

 --функция иницализации
function init()
    ConfigCan(1,500);
	setOutConfig(20,10)

	 --          имя канала       номинальный ток    1- сброс ошибки выключением       время пускового   пусковой  1- включить фильтрацию
	 --                                              0 - наглухо в защиту то ресета    тока в мс           ток     0- выключить фильтрацию
	 
	setOutConfig(COIL_POWER_CH ,       30,             1   ,                           5000,              40 ,     1 ) 
	setOutConfig(STARTER_CH	,          30,             1   ,                           5000,              40 ,     1 ) 
	setOutConfig(PUMP_044_CH,          30,             1   ,                           5000,              40 ,     1 ) 
	setOutConfig(PUMPS_CH,             30,             1   ,                           5000,              40 ,     1 ) 
	setOutConfig(WIPER_LOW_CH ,        30,             1   ,                           5000,              40 ,     1 ) 
	setOutConfig(WIPER_HIGH_CH ,       30,             1   ,                           5000,              40 ,     1 ) 
	setOutConfig(GLASS_FAN_CH ,        30,             1   ,                           5000,              40 ,     1 ) 
	setOutConfig(GLASS_UP_CH,          30,             1   ,                           5000,              40 ,     1 ) 
	setOutConfig(DASH_CH ,             15,             1   ,                           5000,              40 ,     1 ) 
	setOutConfig(POWER_888_CH,         15,             1   ,                           5000,              40 ,     1 ) 
	setOutConfig(JUDGE_POWER_CH	,      15,             1   ,                           5000,              40 ,     1 ) 
	setOutConfig(WHEEL_POWER_CH,       15,             1   ,                           5000,              40 ,     1 ) 
	setOutConfig(WHEEL_PWM_CH,         5,             1   ,                           0,              5 ,     0 ) 
	setOutConfig(LOW_BEAM_CH,          15,             1   ,                           5000,              40 ,     1 ) 
	setOutConfig(HIGH_BEAM_CH ,        15,             1   ,                           5000,              40 ,     1 ) 
	setOutConfig(STOP_CH,              15,             1   ,                           5000,              40 ,     1 ) 
    setOutConfig(REAR_LIGTH_CH,        15,             1   ,                           5000,              40 ,     1 ) 
	setOutConfig(EBU_POWER_CH ,        15,             1   ,                           5000,              40 ,     1 ) 
	setOutConfig(KEYBOARD_CH ,        15,             1   ,                           5000,              40 ,     1 )
	--                             кол-во попыток
    --                             перезаруска при
    --                             перегрузке
	--                             0 - бесконечно
	--							   1 - не одной
	--							   2 - одна попытка
    --                             3 - две
     --							    .....            время между перезапусками в мс
	--							   65535  	      
	OutResetConfig(COIL_POWER_CH,      0,                3000 )
	
	setPWMGroupeFreq(5, 100)
    setDINConfig(WIPER_SW,0,10,10)
	setDINConfig(FLASH_SW,0,10,10)
	setDINConfig(RAIN_SW,0,10,10)
    setDINConfig(WHEEL_ON_SW,0,10,10)
    setDINConfig(STOP_SW,0)
	setDINConfig(FUEL_PUMP_SW,0,10,10)
	setDINConfig(EBU_PUMP,0)
	setDINConfig(WIPER_HOME_SW,1)
    setDINConfig(ENGINE_ON_SW,0)
	Yield()
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
	local IgnCounter     	= Counter:new(0,1,0,true)
	local RainCounter   	= Counter:new(0,1,0,true)
	local LigthCounter      = Counter:new(0,2,0,true)
	local WiperCounter      = Counter:new(0,3,0,true)
	local FlashCounter      = Counter:new(0,1,0,true)
	local WHEELSCounter     = Counter:new(0,1,0,true)
	local FlashOnCounter    = Counter:new(0,6,0,false)
	local FuelPumpOnCounter    = Counter:new(0,1,0,false)
	local wipers_on_delay_l  = Delay:new(500,false)
	local wipers_on_delay_2  = Delay:new(500,false)
	local wipers_pause 	    = Delay:new(2000,false)
	local flash_pause 	    = Delay:new(2000,true)
	local start_delay       = Delay:new(200,false)
	local WIPERS_PAUSE_ON    = false
	local location           = false
	local FLASH_ON			 = false
	local state = 0
	
	KeyBoard:setBackLigthBrigth(  3 )
    OutSetPWM(WHEEL_PWM_CH,  80)
	--рабочий цикл
	while true do
	    --выключем все, если напряжение АКБ болье 16В и меньше 6
	    if (( getBat() > 16 ) or (getBat()<6) ) or (not start_delay:process(true)) then
			ALL_OFF()
		else
		--если напяжкемк ок
		    KeyBoard:process() --процесс работы с клавиатурой
			setOut(KEYBOARD_CH, true )   -- включаем keypad
			setOut(DASH_CH    , true )   -- включаем даш
			setOut(STOP_CH	,  getDIN( STOP_SW ) )  -- реагируем концевик педали тормоза

			local STARTER = KeyBoard:getKey(2)
			local OUT_ENABLE = not STARTER
			KeyBoard:setLedRed(2,STARTER)
		    setOut( STARTER_CH, STARTER  )

			-- блок реакции на кнопку RAIN
			RainCounter:process(getDIN(RAIN_SW), false, false )
			local RAIN = ( RainCounter:get() == 1)				
			if RAIN then
				LigthCounter = 1
			end 
			setOut(GLASS_FAN_CH ,  RAIN and OUT_ENABLE  ) 
			setOut(GLASS_UP_CH  ,  true  )
				
			IgnCounter:process(KeyBoard:getKey(1), false,false)
			local IGNITION =  (IgnCounter:get() == 1)
			setOut(COIL_POWER_CH , IGNITION)   

            FuelPumpOnCounter:process(getDIN(FUEL_PUMP_SW), false,false)
						
			setOut(PUMP_044_CH,   (  getDIN(EBU_PUMP) or  FuelPumpOnCounter:get()==1)   and IGNITION  )      
			setOut(PUMPS_CH,      (  getDIN(EBU_PUMP) or  FuelPumpOnCounter:get()==1)   and IGNITION  )
			setOut(POWER_888_CH,   IGNITION)        
			setOut(JUDGE_POWER_CH, IGNITION)  
			setOut(EBU_POWER_CH ,  IGNITION) 				
		    KeyBoard:setBackLigthBrigth( IGNITION and 16 or 5 )	-- подсветка клавиатуры
		
		    local ENGINE_ON = getDIN(ENGINE_ON_SW)
			
			setOut(REAR_LIGTH_CH, ENGINE_ON and OUT_ENABLE )
		 	WHEELSCounter:process( getDIN(WHEEL_ON_SW), false, false)
			setOut(WHEEL_POWER_CH, ( ENGINE_ON  or ( WHEELSCounter == 1)) and OUT_ENABLE )
			setOut(WHEEL_PWM_CH  , ( ENGINE_ON  or ( WHEELSCounter == 1)) and OUT_ENABLE  )
			OutSetPWM(WHEEL_PWM_CH, 20)
			
			--блок FLASH и света		
            LigthCounter:process( KeyBoard:getKey(3), false, not ENGINE_ON )
            local HIGH_BEAM_ON =  (LigthCounter:get() == 2)
			
			FlashCounter:process(getDIN(FLASH_SW),false,not getDIN(FLASH_SW))
			if (( FlashCounter:get(1) == 1 ) and (not FLASH_ON)) then
				FLASH_ON = true
			end
			
			FlashOnCounter:process( flash_pause:process(FLASH_ON), false, not FLASH_ON)
            local flk = FlashOnCounter:get()
			if (flk ==2 ) or (flk == 4) or ((flk ==0 ) and FLASH_ON) then
				HIGH_BEAM_ON = true
			end
			if (flk ==1 ) or (flk == 3) or (flk ==5) then
				HIGH_BEAM_ON = false
			end
			if (flk == 6) then
				FLASH_ON  = false
			end

			setOut(LOW_BEAM_CH,(LigthCounter:get() == 1)  and OUT_ENABLE )
			setOut(HIGH_BEAM_CH, HIGH_BEAM_ON             and OUT_ENABLE )
			--блок FLASH
			--Блок дворников
            WiperCounter:process( getDIN(WIPER_SW),false, not ENGINE_ON )	
			wipers_pause:process(not getDIN( WIPER_HOME_SW ),false) -- задержка для режима паузы
			--запускается в любых режимах, что бы не делать отдельный сигнал сборса
			if (WiperCounter:get() == 1) then         -- если режим паузы
				if (state ==0) then                   -- если токо включили
					WIPERS_PAUSE_ON = true            -- запускаем двроники
					if getDIN( WIPER_HOME_SW ) then   -- и ждем пока они уедут из домашнего положения
						state = 1                     -- переводи в рабочий режима паузы
					end 
				else 
					if getDIN( WIPER_HOME_SW ) then    -- елси двроники уехали из домашнего положения
					  WIPERS_PAUSE_ON = false          -- сбрасываем переменную запуска, теперь дворники автоматом
													   -- доедут до дома и выключатся
					else
					  WIPERS_PAUSE_ON = wipers_pause:get() -- если мы тут, то довники приехали домой и запустилась задержка
														-- когда продет время заржки, пусковая переменная будет включена
														-- и они сдвинуться из домашнего пложения
					end 
			   end
			else
			 state = 0
			 WIPERS_PAUSE_ON = false
			end
			local WIPER_LOW_SPEED  = (WiperCounter:get() == 2)	-- включаем низкую скорость. второе нажатие на кнопку
			local WIPER_HIGH_SPEED = (WiperCounter:get() == 3)	-- высокую скорость, третье нажатие на копку
			location  = WIPER_HIGH_SPEED or WIPERS_PAUSE_ON or  ( location and getDIN( WIPER_HOME_SW ) )  -- переменная
			-- отвечает за доезд дворников домой, если их выклчюили посередине цикла, она сброситься 
			-- как только они приедут домой. 
			-- каналы выключаются когда крутиться стартер
			-- каналы ключатся с задержкой 0.5с, это тайм аут на осоновку мотора, что бы он перестал генерить 
			-- в канал. Иначе может срабоать защитра 
			setOut( WIPER_LOW_CH,  wipers_on_delay_l:process( WIPER_LOW_SPEED , false ) and OUT_ENABLE )  
		    setOut( WIPER_HIGH_CH, wipers_on_delay_2:process( WIPER_HIGH_SPEED or WIPERS_PAUSE_ON or location, false ) and not  WIPER_LOW_SPEED and OUT_ENABLE  ) 		
			--Конец блока доврников
	    
	        end
	   Yield()
	end
	
end