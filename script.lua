--Важно Для редактировани использовать редактор, где можно ставить кодировку UTF-8. 
--При кодировке ANSI ломаются скрипты обработки
function init() --функция иницализации
        ConfigCan(1,1000);
	-- Функции конфинурации канала. Если не вызвать setOutConfig, то канал будет в режиме DISABLE на урвоне ядра. Т.е. физический будет принудительнов выключен, токи не будет считаться, на команды из скрипта не регаирует.
    setOutConfig(1,20,0,0,60)   -- 1.  номер канала (1-20), 
								-- 2.  номинальный ток (пока еще не определился с верхней границей), 
								-- 3.  Необязательный агрумент - Сборс ошибки выключением - значение по умолчанию <1>  0 - сборс ошибки  только рестатром системы 1 - сборс ошибки выклчюением канала
								-- 4.  Необязательный агрумент  -время работы в перегузке в мс - значение по умолчанию  - 0, 
							    -- 5.  Необязательный аргумент, - ток перегрузки, значение по умолчанию - номинальный ток. 
							   
	
	--OutResetConfig(1,0,1000)    -- Конфигурация режима перегрузки  1. номера канала 2. Кол-во циклов перегрукзи, если 0, то будет пытаться рестартовать бесконечно, если 1, то сразу после перегрузки удейт в ошибку
						     -- если больше 1, то соотвесвенно будет патться стартануть указаное кол-во раз. 3. Таймаут перед новым запускаом при перегузке
							-- Если не вызывать OutResetConfig, по умолчанию канал после пегрузки идет в ошибку.
	-- в ядре есть алгоримт софт-старта. Пока не вытащил его в скрит. Скоро будет.
	setOutConfig(2,11)	
	--OutResetConfig(2,1,1)
	setOutConfig(3,60)
	--OutResetConfig(3,1,1)
	setOutConfig(4,10,1,1000,50)
	OutResetConfig(4,0,1000)	
	setOutConfig(5,20)
	setOutConfig(6,20)
	setOutConfig(7,20)
	setOutConfig(8,20)
	setOutConfig(9,5)
	--OutResetConfig(9,1,0)	
	setOutConfig(10,8,0)	
	--OutResetConfig(10,1,0)	
	setOutConfig(11,8,0)
	OutResetConfig(11,1,0)
	setOutConfig(12,8,0)
	OutResetConfig(12,1,0)
	setOutConfig(13,25)
	--OutResetConfig(13,0,10)
	setOutConfig(14,8)
	OutResetConfig(14,0,1000)
	setOutConfig(15,8)
	setOutConfig(16,8)
	setOutConfig(17,8)
	setOutConfig(18,8)
	setOutConfig(19,8)
	setOutConfig(20,8)
    setDINConfig(1,1)
    setDINConfig(2,1)
    setDINConfig(3,1)
    setDINConfig(4,1)
    setDINConfig(5,1)
    setDINConfig(6,1)
    setDINConfig(7,1)
    setDINConfig(8,1)
    setDINConfig(9,1)
    setDINConfig(10,1)
    setDINConfig(11,1)
	setPWMGroupeFreq(0, 100)
end
----
-- немножко вкинуну херни про системные функции
--



main = function ()
    local KeyBoard		=  KeyPad8:new(0x15)
	local Turns	        =  TurnSygnals:new(800)
	local DASH			= Dashboard:new(0x10,800)
	local wipers	    = Wipers:new(100, 3)
	local BeamCounter   = Counter:new(1,3,1,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)
	local Flashing_Light_Timer = 0	
    local Flashing_Light_counter = 0
	local temp_out		= true	
	local temp_out1		= true	
	local counter		= 0
	local LEFT		= false
	local RIGTH		= false
	local ALARM		= false	
	local right_turn	= false
	local left_turn	= false
	local Ligth_Enable	= false
	local High_beam = false
	local Low_beam = false		
	
	init()
	KeyBoard:setBackLigthBrigth(15)
    DASH:init()	
	while true do 
	
		--процесс работы с клавиатурой
		KeyBoard:process()			   		
		DASH:process()
		
	
		--управление дальним и билжним светом
		BeamCounter:process(KeyBoard:getKey(2),false,false)  -- cчетчик process( инкримент, дикремент, сборс)
		Ligth_Enable = (BeamCounter:get() ~= 1 ) and true or false -- если счетчик не равен 1  то true
		
		
		
		setOut(10, Ligth_Enable )  -- ближний свет				
		setOut(9, Ligth_Enable or KeyBoard:getToggle(8) )  --ближний свет и стоп сигнал
	    OutSetPWM(9,KeyBoard:getToggle(3) and 99 or 40)  	
		
		setOut(1, KeyBoard:getToggle(4)) --задний ход
		
		setOut(2,(BeamCounter:get() == 3 ) and true or false)
		
		
		wipers:process( false, KeyBoard:getKey(3), false, getDIN(1))
		setOut(13, wipers:getOut())
		KeyBoard:setLedGreen( 3, KeyBoard:getKey(3) )
		
		
		
		--setOut(9, (BeamCounter:get() == 3 ) and true or false) -- если счетчи равен 3, то вклчюаем дальний
		KeyBoard:setLedGreen( 2, (BeamCounter:get() == 2 ) and true or false ) -- если 2 (билжний счет, то зажигаем светодиод)
		KeyBoard:setLedBlue( 2, (BeamCounter:get() == 3 ) and true or false	) -- если 3 ( дальний свет, то зажигаем синий свет)
		
		--аогоритм управления с 2-х клавиш повортниками и если 2 вместе, то аварийка
		if  ALARM then	
			ALARM = (not ( KeyBoard:getToggle(5) or KeyBoard:getToggle(6))) and true or false									
			KeyBoard:resetToggle(5,not ALARM )		
			KeyBoard:resetToggle(6,not ALARM )																
		else				
			LEFT = KeyBoard:getToggle(5)
			RIGTH =KeyBoard:getToggle(6)
			KeyBoard:resetToggle(5,KeyBoard:getKey(6) )		
			KeyBoard:resetToggle(6,KeyBoard:getKey(5) )
			ALARM = KeyBoard:getKey(5) and KeyBoard:getKey(6)  														
		end
		
		
		
        Turns:process( true, LEFT, RIGTH, ALARM)
		
		--это просто цикл мигания светодиодом клавиатуре, что бы видиеть что система живет.
		counter = counter + 1		
		if counter > 1000 then
			counter = 0
			temp_out = not temp_out	      
			KeyBoard:setLedGreen(4,temp_out)
		end														
	
		if  (not LEFT) and (not RIGTH) and (not ALARM) and Ligth_Enable then
			Flashing_Light_Timer = Flashing_Light_Timer +getDelay()
			if Flashing_Light_Timer > 20 then		  
				Flashing_Light_Timer = 0	     					
				Flashing_Light_counter =  (Flashing_Light_counter < 15) and Flashing_Light_counter + 1 or 0 		 
				right_turn = (( Flashing_Light_counter == 1 ) or ( Flashing_Light_counter == 4 )) and true or false
				left_turn  = (( Flashing_Light_counter == 7 ) or ( Flashing_Light_counter == 11 )) and true or false							
			end		
			    		
		else

			right_turn =  false
			left_turn  =  false
			
		end
		
		
	
		
		--упавление светодиодами 5 и 6-й конопо и выходами повортников
		KeyBoard:setLedGreen(5, Turns:getLeft() or Turns:getAlarm()	)
		KeyBoard:setLedGreen(6, Turns:getRight() or Turns:getAlarm())		
		setOut(11, right_turn  or Turns:getAlarm() or Turns:getRight())
		setOut(12, left_turn   or Turns:getAlarm() or Turns:getLeft())
    
		
		Yield() -- ключевая функция рабочего цикла. Она 1. Загоняте в ядро новые значения выходов, которые устнавливаются в setOut()
		-- 2. Приостанавливает работу скрипта, что бы ядро могло выполнить сервисные процессы
		-- 3. Загржает новые данные (токи, аины, дискреты)
		-- 4. Продлжает работу скрипта с этого же места.
		-- Исходя из этого, если меняешь значения выхода несколько раз за цикл, реально на выход пойдет последние значение, которе установлено перед тек как вызван Yield
		-- Значения токов и всего остального актуализруется после вызова Yield. Пока это бесполезная инфромация, поскльку я пока не придумал скрипта
		-- перегрузившего систему больше чем на 2 мс. Но чисто в теории, если написать прям какой-то очень тяжелый скрипт, например посчитать какую-то 
		-- лютую формулу, а псоклько в lua все числа хранятсья по факту в float32, при желании изобразить скрипт на 30 мс вполне можно наверное. То
		-- если в процессе расчета этой самой формулы канал уйдет в перегрузку, то ядро отрабоатет по уставкам, но актуальный ток и состояние канала в скритпе будет видно
		--только после вызова Yield()
		-- При этом CAN вызовы работают асинхроно от Yield. Если дать комнду на отправку пакета, то он сразу удйте в ядро. И на прием ядро тоже будет принимать фреймы 
		-- и при чтении пакета с нужным ID будет выдан последний принятый пакет. 
		
	end
end
