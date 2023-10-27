LSFAir = 1
RSFAir = 2
LSBAir = 3
RSBAir = 4
LMFAir = 5
RMFAir = 6
LMBAir = 7
RMBAir = 8
LPullAir = 9
RPullAir = 10
MainAir = 11
--сервисная функция инициализации
function init()
	ConfigCan(1,500)  -- конфигурация скорости CAN
	setOutConfig(1,2) -- насройка номнальных токов для каналов управления
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
    -- установка калиборвочных значений для датчиков давления на аналоговые входа
	setAINCalTable(1,10,0,184,10)
    setAINCalTable(2,10,0,184,10)
    setAINCalTable(3,10,0,184,10)
    setAINCalTable(4,10,0,184,10)
	setAINCalTable(5,10,0,184,10)
    setAINCalTable(6,10,0,184,10)
    setAINCalTable(7,10,0,184,10)
    setAINCalTable(8,10,0,184,10)
	setAINCalTable(9,10,0,184,10)
    setAINCalTable(10,10,0,184,10)
    setAINCalTable(11,10,0,184,10)
	--конфигурация хранилища данных
   ConfigStorage(0,62,0x00,0x01,0x03,0x03)
	--отправка конфигурационного пакета в кавиатуру, для перевода ее в рабочий режим
   CanSend(0x00,0x01,0x15,0x00,0x00,0x00,0x00,0x00,0x00)
end

--главная функция
LSF   		= Pillow:new(0, 10 , 1, 2)
RSF   		= Pillow:new(1, 10 , 3, 4)
LSB   		= Pillow:new(2, 10 , 5, 6)
RSB   		= Pillow:new(3, 10 , 7, 8)
LMF   		= Pillow:new(4, 10 , 9, 10)
RMF   		= Pillow:new(5, 10 , 11, 12)
LMB   		= Pillow:new(6, 10 , 13, 14)
RMB   		= Pillow:new(7, 10 , 15, 16)
LPull   	= Pillow:new(8, 10 , 17, 18)
RPull  		= Pillow:new(9, 10 , 19, 20)
LSState = 0 --переменная текущего состояния падушек левой стороны
RSState = 0
LSBDir = 0
LSFDir = 0
lsTimer = 0
rsTimer = 0
function LeftVlaveOff()
	LSF:manualControl(false,false)
	LSB:manualControl(false,false)
	LMF:manualControl(false,false)
	LMB:manualControl(false,false)
	LPull:manualControl(false,false)

end
function RightValveOff()
	RSF:manualControl(false,false)
	RSB:manualControl(false,false)
	RMF:manualControl(false,false)
	RMB:manualControl(false,false)
	RPull:manualControl(false,false)

end


function ValveOff()  --фуеция выключения всех клапанов
	LeftVlaveOff()
	RightValveOff()
end

function BeginLeftSide()
 LSState = 0
end
function BeginRightSide()
 RSState = 0
end

function LeftSideIDLE( mode_front, mode_back, control_type )
	LSF:process(2,true)
	LSB:process(2,true)	
	LMF:process(mode_front,control_type)		
	LMB:process(mode_back,control_type)		
	LPull:process(2,true)
end
function RigthSideIDLE( mode_front, mode_back, control_type )
	RSF:process(2,true)
	RSB:process(2,true)
	RMF:process(mode_front,control_type)
	RMB:process(mode_back,control_type)
	RPull:process(2,true)

end


function LeftSide( mode_front, mode_back, control_type )
    local res = 0
	if LSState == 0 then  --входим в переходный процес
	    LeftVlaveOff()		  --выключаем клапана и определяем куда нужно качать переднюю и зандюю главные подушки
		if control_type == true  then  -- если управление по давлению
			if  ( LMF:getAir() < LMF:getEEPROMAir(mode_front) ) then LSFDir = 1 end  -- определяем в какую стоону качать
			if  ( LMB:getAir() < LMB:getEEPROMAir(mode_back) )  then LSBDir = 1 end
		else						   -- если управление по высоте
			if  ( LMF:getHeight()< LMF:getEEPROMHeight(mode_front) ) then LSFDir = 1 end
			if  ( LMB:getHeight()< LMB:getEEPROMHeight(mode_back) )  then LSBDir = 1 end
		end
	    LSState = 1
	elseif LSState == 1 then --убеждаемся что стабилизаторы в максимальном давлении	
		if (( LSF:process( 2, true ) == 1) and ( LSB:process( 2, true ) == 1)) then --убеждаемся что стабилизаторы в макс высоте
			LSState = 2
		end
	
	elseif LSState == 2 then
		 if ((LSFDir == 1) or (LSBDir == 1)) then         -- если нужно качать какую то из главных подушек
			if ( LPull:process_set_air( LPull:getEEPROMAir(2) * 0,7 ) == 1) then
				LSState = 3
			end
		 end
	elseif LSState == 3 then
	      local ready = true
		  if ( LSFDir == 1 ) then ready = ready and (LMF:process(mode,control_type)==1) end
		  if ( LSBDir == 1 ) then ready = ready and (LMB:process(mode,control_type)==1) end     
		  if ( ready == true ) then
			LSState = 4
		  end
	elseif LSState == 4 then
		lsTimer = lsTimer + getDelay()
		if lsTimer > 5000 then
			LSSatate = 5
			LPull:manualControl(false,false)
		else
			LPull:manualControl(true,false)
		end
	elseif LSState == 5 then
		if (( LSFDir == 0 ) or ( LSBDir == 0 )) then 
		   LPull:manualControl(true,false)
		   LSState = 6
		else 
		   LSState = 8
		end
	elseif LSState == 6 then
		  local ready = true
		  if ( LSFDir == 0 ) then ready = ready and (LMF:process(mode,control_type)==1) end
		  if ( LSBDir == 0 ) then ready = ready and (LMB:process(mode,control_type)==1) end     
		  if ( ready == true ) then
			LSState =7
		  end
	elseif LSSatate ==7 then
	    if (LSFDir== 0) or (LSBDir == 0) then 
			lsTimer = lsTimer + getDelay()
			if lsTimer > 5000 then
				LSSatate = 8
				LPull:manualControl(false,false)
			else
				LPull:manualControl(true,false)
			end
		else
			LSSatate = 8
		end
	elseif LSState == 8 then
		res = 1
	end
	return res
end



function RigthSide( mode_front, mode_back, control_type)
    local res = 0
	if RSState == 0 then  --входим в переходный процес
	    RightValveOff()		  --выключаем клапана и определяем куда нужно качать переднюю и зандюю главные подушки
		if control_type == true  then  -- если управление по давлению
			if  ( RMF:getAir() < RMF:getEEPROMAir(mode_front) ) then RSFDir = 1 end  -- определяем в какую стоону качать
			if  ( RMB:getAir() < RMB:getEEPROMAir(mode_back) )  then RSBDir = 1 end
		else						   -- если управление по высоте
			if  ( RMF:getHeight()< RMF:getEEPROMHeight(mode_front) ) then RSFDir = 1 end
			if  ( RMB:getHeight()< RMB:getEEPROMHeight(mode_back) )  then RSBDir = 1 end
		end
	    RSState = 1
	elseif RSState == 1 then --убеждаемся что стабилизаторы в максимальном давлении	
		if (( RSF:process( 2, true ) == 1) and ( RSB:process( 2, true ) == 1)) then --убеждаемся что стабилизаторы в макс высоте
			RSState = 2
		end
	
	elseif RSState == 2 then
		 if ((RSFDir == 1) or (RSBDir == 1)) then         -- если нужно качать какую то из главных подушек
			if ( RPull:process_set_air( RPull:getEEPROMAir(2) * 0,7 ) == 1) then
				RSState = 3
			end
		 end
	elseif RSState == 3 then
	      local ready = true
		  if ( RSFDir == 1 ) then ready = ready and (RMF:process(mode,control_type)==1) end
		  if ( RSBDir == 1 ) then ready = ready and (RMB:process(mode,control_type)==1) end     
		  if ( ready == true ) then
			RSState = 4
		  end
	elseif RSState == 4 then
		rsTimer = rsTimer + getDelay()
		if rsTimer > 5000 then
			RSSatate = 5
			RPull:manualControl(false,false)
		else
			RPull:manualControl(true,false)
		end
	elseif RSState == 5 then
		if (( RSFDir == 0 ) or ( RSBDir == 0 )) then 
		   RPull:manualControl(true,false)
		   RSState = 6
		else 
		   RSState = 8
		end
	elseif RSState == 6 then
		  local ready = true
		  if ( RSFDir == 0 ) then ready = ready and (RMF:process(mode,control_type)==1) end
		  if ( RSBDir == 0 ) then ready = ready and (RMB:process(mode,control_type)==1) end     
		  if ( ready == true ) then
			RSState =7
		  end
	elseif RSSatate ==7 then
	    if (RSFDir == 0) or (RSBDir == 0) then 
			rsTimer = rsTimer + getDelay()
			if rsTimer > 5000 then
				RSSatate = 8
				RPull:manualControl(false,false)
			else
				RPull:manualControl(true,false)
			end
		else
			RSSatate = 8
		end
	elseif RSState == 8 then
		res = 1
	end
	return res
end


main = function ()
    init()
    local CanIn         = CanInput:new(0x28)
	local CanToDash  	= CanOut:new(0x29, 100)
	local CanToDash1	= CanOut:new(0x30, 100)
	local CanToDash2	= CanOut:new(0x31, 100)
	local CanToDash3	= CanOut:new(0x32, 100)
    local KeyBoard		= KeyPad15:new(0x15)--создание объекта клавиатура c адресом 0x15 
	local LSFCounter   =  Counter:new(1,4,2,true)
	local RSFCounter   =  Counter:new(1,4,2,true)
	local LSBCounter   =  Counter:new(1,4,2,true)
	local RSBCounter   =  Counter:new(1,4,2,true)
	local LMFCounter   =  Counter:new(1,4,2,true)
	local RMFCounter   =  Counter:new(1,4,2,true)
	local LMBCounter   =  Counter:new(1,4,2,true)
	local RMBCounter   =  Counter:new(1,4,2,true)	
	local LPullCounter   =  Counter:new(1,4,2,true)
	local RPullCounter   =  Counter:new(1,4,2,true)
	local ROLLDelay		 = Delay:new( 5000, false) -- зажержка на фиксацию превышения угла крена выше 30 градусов
	local PITCHDelay    = Delay:new( 5000, false) -- зажержка на фиксацию превышения угла тангажа выше 35 градусов
	local ROLLOVER10Dealy = Delay:new( 5000, false)
	local ROLLOVER20Dealy = Delay:new( 5000, false)
	local PITCHOVER20Delay = Delay:new( 5000, false)
	local PITCHOVER25Delay = Delay:new( 5000, false)
	local SPEEDCounter  = Counter:new(1,3,1,true) 
	local SPEED10Dealy  = Delay:new(5000,false)
	local SPEED20Dealy  = Delay:new(5000,false)
	local SPEED30Dealy  = Delay:new(5000,false)
	local AUTO = false
	local HIGHMODE = 4
	local HIGHMODECAL= false
	local MIDMODECAL = false
	local LOWMODECAL = false
	local calmode = 4
	local ROLLOVER10WARNING = false
	local ROLLOVER20WARNING = false
	local PITCHOVER20WARNING = false
	local PITCHOVER25WARNING = false
    local ROLL =0
	local PITCH = 0
	local MODE = 1
	local CAL_SET = false
	local ROLL_WARNING = false
	local PITCH_WARNING = false
	local SPEED = 0
	local TRANSITION = false
	local LEFT_SIDE_REAR = 0
	local LEFT_SIDE_FRONT = 0
	local RIGTH_SIDE_REAR = 0
	local RIGTH_SIDE_FRONT = 0
	local AUTOMODE = 0
	local UPSTATE = 0
	
	 CanSend(0x00,0x80,0x15,0x00,0x00,0x00,0x00,0x00,0x00)
	--рабочий цикл
	while true do	
		   
		--блок анализа крена и тангажа
	    ROLL = math.abs( GetEEPROMReg(0) - getROLL()   )
		ROLLDelay:process( ( ROLL >= 30 ), ( ROLL < 30 ))
		if ROLLDelay:get() then  -- Если крен выше 30 грдусов в течении времени ROLLDelay
			if (ROLL_WARNING == false)  then 		
				ROLL_WARNING = true					-- выставляем флаг крена, чтобы не повторять запись
													-- по не система не вернется в нормальное положение
				AddReccord( 0x01) 				    -- пишет запись в журнал
			end
		end
		if ( ROLL <= 25 )  then 					--гистерезис 5 градусов для крена
			ROLL_WARNING = false				    --сбрасываем флаг крена, система переходит в нормальное функционирование
		end
		ROLLOVER10Dealy :process( (ROLL>10),( ROLL <=10))  -- если крен привышает 10 градусов в течении ROLLOVER10Dealy 
		if ROLLOVER10Dealy:get() then
			ROLLOVER10WARNING = true
		end
		if ( ROLL <=5 ) then
			ROLLOVER10WARNING = false
		end
		ROLLOVER20Dealy :process( (ROLL>20),( ROLL <=20))  -- если крен привышает 10 градусов в течении ROLLOVER10Dealy 
		if ROLLOVER20Dealy:get() then
			ROLLOVER20WARNING = true
		end
		if ( ROLL <=15 ) then
			ROLLOVER20WARNING = false
		end
	
		PITCH = math.abs (  GetEEPROMReg(1) - getPITCH())
		PITCHDelay:process((PITCH  >= 35 ), (PITCH  < 35 ))
		if PITCHDelay:get() then  -- Если тангаж выше 35 грдусов в течении времени PITCHDelay
			if (PITCH_WARNING == false) then 		
				PITCH_WARNING = true					-- выставляем флаг тангажа
				AddReccord( 0x01) 				    -- пишет запись в журнал
			end
		end
		if ( PITCH  <= 30 )  then --гистерезис 5 градусов для крена
			PITCH_WARNING = false				    -- сбрасываем флаг тангажа
		end
		PITCHOVER20Delay:process((PITCH  >= 20 ), (PITCH  < 20 ))
		if PITCHOVER20Delay:get() then
			if (PITCHOVER20WARNING == false) then 		
				PITCHOVER20WARNING = true					-- выставляем флаг тангажа
			end
		end 
		if ( PITCH  <= 15 )  then --гистерезис 5 градусов для крена
			PITCHOVER20WARNING = false				    -- сбрасываем флаг тангажа
		end	
		PITCHOVER25Delay:process((PITCH  >= 25 ), (PITCH  < 25 ))
		if (PITCHOVER25Delay:get()) then
			if (PITCHOVER25WARNING == false) then 		
				PITCHOVER25WARNING = true					-- выставляем флаг тангажа
			end
		end 
		if ( PITCH  <= 20)  then --гистерезис 5 градусов для крена
			PITCHOVER25WARNING = false				    -- сбрасываем флаг тангажа
		end	
		----конец блок анализа крена и тангажа 
		-- блок обмена данными по CAN
	    CanIn:process()
		local LMFH = CanIn:getWordMSB(1)    -- получение данных о датчиках высоты
		local RMFH = CanIn:getWordMSB(3)
		local LMBH = CanIn:getWordMSB(5)
		local RMBH = CanIn:getWordMSB(7)
		--отправка данных о датчиках давления и стостояии выходных каналов по СAN
		CanToDash:setWord(1, (getAin(LSFAir)*100)//1 )
		CanToDash:setWord(3, (getAin(RSFAir)*100)//1 )
		CanToDash:setWord(5, (getAin(LSBAir)*100)//1 )
		CanToDash:setWord(7, (getAin(RSBAir)*100)//1 )
		CanToDash:process()
		CanToDash1:setWord(1, (getAin(LMFAir)*100)//1 )
		CanToDash1:setWord(3, (getAin(RMFAir)*100)//1 )
		CanToDash1:setWord(5, (getAin(LMBAir)*100)//1 )
		CanToDash1:setWord(7, (getAin(RMBAir)*100)//1 )
		CanToDash1:process()
		CanToDash2:setWord(1, (getAin(LPullAir)*100)//1 )
		CanToDash2:setWord(3, (getAin(RPullAir)*100)//1 )
		CanToDash2:setWord(5, (getAin(MainAir)*100)//1 )
	    CanToDash2:setByte(7, getROLL()//1)
		CanToDash2:setByte(8, getPITCH()//1)
		CanToDash2:process()
		CanToDash3:setBit( 1, 1, getOut(1) )
		CanToDash3:setBit( 1, 2, getOut(2) )
		CanToDash3:setBit( 1, 3, getOut(3) )
		CanToDash3:setBit( 1, 4, getOut(4) )
		CanToDash3:setBit( 1, 5, getOut(5) )
		CanToDash3:setBit( 1, 6, getOut(6) )
		CanToDash3:setBit( 1, 7, getOut(7) )
		CanToDash3:setBit( 1, 8, getOut(8) )
		CanToDash3:setBit( 2, 1, getOut(9) )
		CanToDash3:setBit( 2, 2, getOut(10) )
		CanToDash3:setBit( 2, 3, getOut(11) )
		CanToDash3:setBit( 2, 4, getOut(12) )
	    CanToDash3:setBit( 2, 5, getOut(13) )
		CanToDash3:setBit( 2, 6, getOut(14) )
		CanToDash3:setBit( 2, 7, getOut(15) )
		CanToDash3:setBit( 2, 8, getOut(16) )
		CanToDash3:setBit( 3, 1, getOut(17) )
		CanToDash3:setBit( 3, 2, getOut(18) )
		CanToDash3:setBit( 3, 3, getOut(19) )
		CanToDash3:setBit( 3, 4, getOut(20) )
		CanToDash3:process()
	    KeyBoard:process() --процесс работы с клавиатурой
		-- блок обмена данными по CAN
		LSF:setData( getAin(LSFAir), 1)
		RSF:setData( getAin(RSFAir), 2)
		LSB:setData( getAin(LSBAir), 3)
		RSB:setData( getAin(RSBAir), 4)
		LMF:setData( getAin(LMFAir), LMFH )
		RMF:setData( getAin(RMFAir), RMFH )
		LMB:setData( getAin(LMBAir), LMBH )
		RMB:setData( getAin(RMBAir), RMBH )
		LPull:setData( getAin(LPullAir), 9 )
		RPull:setData( getAin(RPullAir), 10)
		
		KeyBoard:setBackLigthBrigth( 15  )
		
		--блок управления клапанами в ручном и калибровочном режиме
		if (MODE == 1)  then

			if (KeyBoard:getToggle(1) == true) then -- при нажатии клавиши 1 переходим в автомат если 
			  KeyBoard:resetToggle(1,true)        -- в ручном и в ручной если в калибровочном
			  MODE =   2 
			end
			if (HIGHMODE == 4) then  -- если выключили автоматический клиренс
				ValveOff()
				HIGHMODE = 5
				TRANSITION = false
			end
		end
		if (MODE == 2) then  -- режим подъема в горку 
			if (ROLL_WARNING or PITCH_WARNING) and (not TRANSITION) then -- не в перхеодном состонии и критические углы
				MODE = 1				-- в ручной режим
				HIGHMODE = 4			-- флаг выключения клапанов в ручном режиме
				UPSTATE = 0				-- обнуляем состония подвески
				AUTOMODE =0					--обнкляем переменную режима
			elseif AUTOMODE == 0 then
				ValveOff()	
				if  KeyBoard:getToggle(3)==true then     -- перехоимд в режим спуска
					KeyBoard:resetToggle(3,true)
					AUTOMODE = 2    
				end						
			elseif AUTOMODE == 2 then -- режим работы на спуск
			    SPEED20Dealy( (SPEED >10) , (SPEED <=10)  )  -- конртолируем привышение скорости боле 10 км/ч в течении 5 сек
			    if not TRANSITION then --если не в переходном состоянии
				    if (not ROLLOVER10WARNING) and (not SPEED20Dealy:get()) then -- проверяем крен 10 градусов скорость меньше 10
						if ( KeyBoard:getToggle(3) == true ) then  --если кнопка выхода перехоимд в автомат с выключенными клапанами
							KeyBoard:resetToggle(3,true)
							AUTOMODE =  0
						    UPSTATE = 0							
						else
							if ((PITCH <= -20) and (UPSTATE ~= 1)) then -- если крен меньше -20, то средний клиренс
								LEFT_SIDE_REAR = 1
								LEFT_SIDE_FRONT = 1
								RIGTH_SIDE_REAR = 1
								RIGTH_SIDE_FRONT =1
								UPSTATE = 1
								TRANSITION =true
							end
							if ((PITCH > -20) and (UPSTATE ~= 2 )) then -- если крен больше -20, то зад вниз, перед вверх
								LEFT_SIDE_REAR = 0
								LEFT_SIDE_FRONT = 2
								RIGTH_SIDE_REAR = 0
								RIGTH_SIDE_FRONT = 2
								UPSTATE = 2
								TRANSITION =true
							end
							if (not TRANSITION)  then  -- если не в перехоном состоянии
								-- и не переходим в ручной режим, то подерживаем подвеску в заданном состоянии
								LeftSideIDLE(LEFT_SIDE_FRONT,LEFT_SIDE_REAR,false)
								RigthSideIDLE(RIGTH_SIDE_FRONT,RIGTH_SIDE_REAR,false)
							end
						end
					else
						AUTOMODE =0 -- переходим в ручной режим с выключенными клапанами
						MODE = 1
						HIGHMODE = 4
						UPSTATE = 0
					end
				else
					-- переменная станет false и мы выйдем из переходного состояния токо когда обе гусеницы закочат переход 
					-- в новое состояние подвески
					TRANSITION = not ( ( RightSide(RIGTH_SIDE_FRONT,RIGTH_SIDE_REAR,false )== 1)
						and ( LeftSide(LEFT_SIDE_FRONT,LEFT_SIDE_REAR,false )== 1))
				end
			end
					
		end
		KeyBoard:setLedBlue( 3,  (AUTOMODE == 2) )
		KeyBoard:setLedBlue( 1,  (MODE == 2) )
		KeyBoard:setLedGreen( 1, (MODE == 1) )
	   Yield()
	end
end