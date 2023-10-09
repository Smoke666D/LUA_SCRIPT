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
	setOutConfig(GLOW_PLUG_1_2,5) -- на пуске свечи жрут 32-35А. Поскольку в ядре номинальный ток ограничен 30а, ставлю задержку на 5с
	setOutConfig(GLOW_PLUG_3_4,5)
	setOutConfig(STARTER_CH,5)
	setOutConfig(CUT_VALVE,5)
	setOutConfig(KL30,5)
	setOutConfig(LEFT_TURN_CH,4) -- для повортников влючен режим ухода в ошибку до перезапуска. Если так не сделать, при кз будет постоянно сбрасываться ошибка
	
	setOutConfig(RIGTH_TURN_CH,4)
	
	setOutConfig(OIL_FAN_CH,5)
	setOutConfig(HIGH_BEAM_CH,5)
	setOutConfig(STOP_CH,5)
	setOutConfig(FUEL_PUMP_CH,5)	
	setOutConfig(WIPERS_CH,5)
	setOutConfig(WATER_CH,5)
	setOutConfig(UP_GEAR, 5)
	setOutConfig(DOWN_GEAR_CH,8)
	setOutConfig(STEERING_WEEL_VALVE_CH,8)
	setOutConfig(REAR_LIGTH_CH,20)
	setOutConfig(STOP_VALVE,8)
	setOutConfig(HORN_CH,7)
	setOutConfig(LOW_BEAM_CH,3)
	--setPWMGroupeFreq(5, 100)
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

    	
 local delay = 0
local counter = 0

	--KeyBoard:setBackLigthBrigth(  3 )
	--рабочий цикл
	while true do	
	    delay = delay + 1
	    
		--[[ if delay >1000 then
			SetEEPROMReg(1,getBat())
			SetEEPROMReg(2)
			counter = counter + 1
			SetEEPROMReg(3,counter)
			SetEEPROMReg(4,GetEEPROMReg(1))
			AddReccord( GetEEPROMReg(3),GetEEPROMReg(1))
			delay  = 0
         end]]

if (( getBat() > 16 ) or (getBat()<7) ) then
			ALL_OFF()
		else
	  		ALL_ON()
	    KeyBoard:process() --процесс работы с клавиатурой
		
		KeyBoard:setBackLigthBrigth( 15  )
				
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
		end
	   Yield()
	end
end