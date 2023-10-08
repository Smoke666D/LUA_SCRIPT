GLOW_PLUG_1_2 	= 1
GLOW_PLUG_3_4  	= 2
STARTER_CH	 	= 3
OIL_FAN_CH		= 4
CUT_VALVE		= 5
HIGH_BEAM_CH   	= 6
REAR_LIGTH_CH   = 7
FUEL_PUMP_CH    = 15
STOP_VALVE		= 9
WATER_CH    	= 10
DOWN_GEAR_CH   	= 11
KL30			= 12
HORN_CH 		= 13
UP_GEAR     	= 14
WATER_FAN_CH  	= 8
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
 --функция иницализации
function init()
    ConfigCan(1,500);	 								   
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
	OutResetConfig(OIL_FAN_CH,0,3000)
    setOutConfig(WATER_FAN_CH,20,1,3000,50)
	OutResetConfig(WATER_FAN_CH,0,3000)
	setOutConfig(HIGH_BEAM_CH,11)
	setOutConfig(STOP_CH,5,1,0,5,0)
	setOutConfig(FUEL_PUMP_CH,10)	
	setOutConfig(WIPERS_CH,8,0,100,30)
	setOutConfig(WATER_CH,8,0,500,30)
	setOutConfig(UP_GEAR, 8)
	setOutConfig(DOWN_GEAR_CH,8)
	setOutConfig(STEERING_WEEL_VALVE_CH,8)
	setOutConfig(REAR_LIGTH_CH,20)
	setOutConfig(STOP_VALVE,8)
	setOutConfig(HORN_CH,7,1,1000,15)
	setOutConfig(LOW_BEAM_CH,3)
	

setPWMGroupeFreq(5, 300)


    setDINConfig(PRESSURE_IN,0)
	setDINConfig(ING_IN,2)
	setDINConfig(STOP_SW,0)
    setDINConfig(WIPER_IN,1)
    setDINConfig(STARTER_IN,0)
	setDINConfig(PARKING_SW,1)
    setDINConfig(DOOR2_SW,0,3000,0)
	setDINConfig(DOOR1_SW,0,3000,0)
	setDINConfig(RPM_IN,2)
	RPMConfig(RPM_IN,0.04,0,4)
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
	local BeamCounter   	= Counter:new(1,3,1,true) 
	local FlashTimer    	= Delay:new( 50,  true )
	local FlashToCanTimer   = Delay:new( 200,  true )
	local OilFanTimer		= Delay:new(9000, false)
	local WaterFanTimer		= Delay:new(9000, false)
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
    local rrr =0
   local set = 0.1
	KeyBoard:setBackLigthBrigth(  3 )
	setOut(KL30, true  )
	--рабочий цикл
	while true do		
	    	   --процесс отправки данных о каналах в даш
	    if (( getBat() > 16 ) or (getBat()<6) ) then
			ALL_OFF()
		else
		   
		   
		    setOut( STOP_CH, true)  --ближний свет и стоп сигнал
			OutSetPWM(STOP_CH,20)
			--[[t_c = t_c + getDelay()
			if (t_c <1.2) then
			    setOut(KL30, false  )
			end
		    if ((t_c  >(1.2 )) and ( t_c < 2.2 )) then
			   setOut(KL30, true  )
		    end
				
			if (t_c  > 2.2) then
			    setOut(KL30, false  )
				t_c = 0
			end	]]
	   end
	   Yield()
	end
end