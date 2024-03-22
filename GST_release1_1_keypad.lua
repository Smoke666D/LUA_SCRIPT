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
    ConfigCan(1,500);	 								   
	setOutConfig(1,20) -- на пуске свечи жрут 32-35А. Поскольку в ядре номинальный ток ограничен 30а, ставлю задержку на 5с
	setOutConfig(2,20)
	setOutConfig(3,20)
	setOutConfig(4,20)
	setOutConfig(5,20)
	setOutConfig(6,20)
	setOutConfig(7,20)
	setOutConfig(8,20)
	
	setOutConfig(9,15)
	setOutConfig(10,15)
	setOutConfig(11,15)
	setOutConfig(12,15)
	setOutConfig(13,15)
	setOutConfig(14,15)
	
	
	setOutConfig(15,15)
	setOutConfig(16,15)
	setOutConfig(17,15)
	setOutConfig(18,15)
	setOutConfig(19,15)
	setOutConfig(20,15)
	
    setDINConfig(1,0)
	setDINConfig(2,0)
	setDINConfig(3,0)
	setDINConfig(4,0)
	setDINConfig(5,0)
    setDINConfig(6,0)
	setDINConfig(7,0)
	setDINConfig(8,0)
	setDINConfig(9,0)
	setDINConfig(10,0)
	setDINConfig(11,0)
    setDINConfig(12,0)

end

function ALL_ON()
	setOut(1, true)
	setOut(2, true)
	setOut(3, true)
	setOut(4, true)
	setOut(5, true)
	setOut(6, true)
	setOut(7, true)
	setOut(8, true)
	setOut(9, true)
	setOut(10, true)
	setOut(11, true)
	setOut(12, true)
	setOut(13, true)
	setOut(14, true)
	setOut(15, true)
	setOut(16, true)
	setOut(17, true)
	setOut(18, true)
	setOut(19, true)
	setOut(20, true)
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
    local KeyBoard		= KeyPad8:new(0x15)--создание объекта клавиатура c адресом 0x15
	local Key1Counter   = Counter:new(0,3,0,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)
	local Key2Counter   = Counter:new(0,3,0,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)
	local Key3Counter   = Counter:new(0,3,0,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)
	local Key4Counter   = Counter:new(0,3,0,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)
	local Key5Counter   = Counter:new(0,3,0,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)local Key1Counter   = Counter:new(0,3,0,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)
	local Key6Counter   = Counter:new(0,3,0,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)	
	local Key7Counter   = Counter:new(0,3,0,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)
	local Key8Counter   = Counter:new(0,3,0,true) -- счетчи, :new( минмальное значение, максимальное значение, по умолчанию, перегруза)
    local start = false
	local FSM = 0
    local bright = 0
    local delay = 0
    local counter = 0
    local del = 0
    local err = 0
 ConfigStorage(0,62,0x00,0x01,0x03,0x03)
	--KeyBoard:setBackLigthBrigth(  3 )
	--рабочий цикл
	while true do	
	   
	 

        if (( getBat() > 16 ) or (getBat()<7) ) then
			ALL_OFF()
		else
			KeyBoard:process() --процесс работы с клавиатурой
			KeyBoard:setBackLigthBrigth( 15 )	
			Key1Counter:process(KeyBoard:getKey(1),false,false);
			
			if KeyBoard:getToggle(2) then
			   KeyBoard:resetToggle(2,true) 
			   counter = counter +1
			end
			start = (Key1Counter:get() ==1)
	
		
			if start then
				if counter == 0  then
				   SetEEPROMReg(1 ,0x55)
				   SetEEPROMReg(3 ,0x78)
				   if (getDIN(1) == true ) and (getDIN(3) == true ) and (getDIN(5) == true ) and (getDIN(7) == true ) 
				   
				   and (getDIN(9) == true ) and (getDIN(11) == true ) then
				     counter = 1
				     setOut(1, true )
					 setOut(11, true )					-- setOut(14, true )
				   else
				     err = 1
				   end
			    end 
				if ((counter == 2) and (del>280)) then
				    if (getCurrent(1) > 5) and (getCurrent(11) > 5)  then  --and (getCurrent(14) > 5) then
					   
					   setOut(20, true )					   
					   counter = 3
					   setOut(1, false )
					   setOut(11, false )
					   setOut(12, true )
					--   setOut(14, false )
					else
					  
					 err = 2
					end
				end
				if ((counter == 4) and (del>280)) then
					 if (getDIN(2) == true ) and (getCurrent(12) > 5) and (GetEEPROMReg(1) ==0x55) and (GetEEPROMReg(3)==0x78)  then
					   setOut(2, true )
					   setOut(12, false )
					   counter = 5
					else
				       err = 3
					end
				end
				if ((counter == 6) and (del>280)) then
				
				   if (getCurrent(2) > 5) and (getAin(1)>3.0) and (getAin(1)<4.0) and (getAin(2)>1.8) and (getAin(2)<2.6) and (getAin(3)>0.8) and (getAin(3)<1.8) then
					   setOut(2, false )
					   setOut(20, false )
					   setOut(13,  true )
					   setOut(3,  true )
					   counter = 7
					else
					  err = 4
					end
				end
				if ((counter == 8) and (del>280)) then
				
			        if (getDIN(3) == true ) and  (getCurrent(3) > 5) and   (getCurrent(13) > 5)  then
					   setOut(3,  false )
					   setOut(13,  false )
					   
					   setOut(19, true )
					   counter = 9
					else
					  err = 5
					end
				end
				if ((counter == 10) and (del>280)) then
				
			        if (getDIN(4) == true ) then
					   setOut(4,  true )
					   counter = 11
					else
					  err = 6
					end
				end
				if ((counter == 12) and (del>280)) then
			        if (getCurrent(4) > 5)  then
					   setOut(4,  false )
					   setOut(19, false )
					   setOut(6,  true )
					   counter = 13
					else
					  err = 7
					end
				end
			    if ((counter == 14) and (del>280)) then
			        if (getCurrent(6) > 5)  then
					   setOut(6,  false )
					   setOut(18,  true )
					 --  setOut(19,  true )
					  -- setOut(14,  true )
					   counter = 15
					else
					  err = 8
					end
				end
				
				if ((counter == 16) and (del>280)) then
			        if (getDIN(6) == true ) then --and (getCurrent(14) > 5) then
					 
					   setOut(5,  true )
					 --  setOut(19,  false )
					--   setOut(14,  false)
					   counter = 17
					else
					  err = 9
					end
				end
				if ((counter == 18) and (del>280)) then
			         if (getCurrent(5) > 5)  then
					   setOut(18,  false )
					   setOut(5,  false)
					   setOut(7,  true)
					   counter = 19
					else
					  err = 10
					end
				end
				 if ((counter == 20) and (del>280)) then
			        if (getCurrent(7) > 5)  then
					   setOut(7,  false )
					   setOut(17,  true )
					   counter = 21
					else
					  err = 11
					end
				end
					 if ((counter == 22) and (del>280)) then
			        if (getDIN(8) == true ) then
					   setOut(8,true )
					   counter = 23
					else
					  err = 12
					end
				end if ((counter == 24) and (del>280)) then
			        if (getCurrent(8) > 5)  then
					   setOut(8,  false )
					   setOut(10,  true )
					   setOut(17,  false )
					   setOut(16,  true )
					   counter = 25
					else
					  err = 13
					end
				end  if ((counter == 26) and (del>280)) then
			        if (getDIN(10) == true ) and (getCurrent(10) > 5) then
					   setOut(16,  false )
					   setOut(15,  true )
					   setOut(9,  true )
					   setOut(10,  false )
					  setOut(14,  true)
					   counter = 27
					else
					  err = 14
					end
				end
					if ((counter == 28) and (del>280)) then
			        if (getDIN(11) == false ) and (getCurrent(9) > 5) and (getCurrent(14) > 5) then
					   setOut(9,  false )
					   setOut(15,  false )
					  setOut(14,  false )
					   counter = 29
					else
					  err = 15
					end
				end
				
			    del = del + 1
			    if del > 300 then
			       del =0
				   if (err == 0) then
		              counter = counter + 1

		          end
				end
			else
			err = 0
			 counter = 0
			 ALL_OFF()
		    end
		
		end
		KeyBoard:setLedGreen( 1,   start  )
		KeyBoard:setLedRed( 5,   (err & 0x01)== 0x01 )
		KeyBoard:setLedRed( 6,   (err & 0x02)== 0x02 )
		KeyBoard:setLedRed( 7,   (err & 0x04)== 0x04 )
		KeyBoard:setLedRed( 8,   (err & 0x08)== 0x08 )
		
		
		KeyBoard:setLedGreen( 5,   counter >29)
		KeyBoard:setLedGreen( 6,   counter >29  )
		KeyBoard:setLedGreen( 7,   counter >29 )
		KeyBoard:setLedGreen( 8,   counter >29 )
	   Yield()
	end
end