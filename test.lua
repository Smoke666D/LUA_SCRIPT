GLOW_PLUG_1_2 	= 1
GLOW_PLUG_3_4  	= 2
STARTER_CH	 	= 3
OIL_FAN_CH		= 4
CUT_VALVE		= 5
HIGH_BEAM   	= 6
REAR_LIGTH_CH   = 7
FUEL_PUMP_CH    = 8
STOP_VALVE		= 9
WATER_CH    	= 10
DOWN_GEAR_CH   	= 11
KL30			= 12
HORN_CH 		= 13
UP_GEAR     	= 14
REAR_HORN_CH   	= 15
WIPERS_CH   	= 16
LEFT_TURN_CH 	= 17
RIGTH_TURN_CH 	= 18
STOP_CH	    	= 19
LOW_BEAM_CH 	= 20
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
	setOutConfig(KL30,5)
	setOutConfig(LEFT_TURN_CH,4,0) -- для повортников влючен режим ухода в ошибку до перезапуска. Если так не сделать, при кз будет постоянно сбрасываться ошибка
	OutResetConfig(LEFT_TURN_CH,1,0)
	setOutConfig(RIGTH_TURN_CH,4,0)
	OutResetConfig(RIGTH_TURN_CH,1,0)
	setOutConfig(OIL_FAN_CH,10)
	setOutConfig(HIGH_BEAM,11)
	setOutConfig(STOP_CH,5)
	setOutConfig(FUEL_PUMP_CH,15)	
	setOutConfig(WIPERS_CH,10,0,100,30)
	setOutConfig(WATER_CH,8,0,100,30)
	setOutConfig(UP_GEAR, 8)
	setOutConfig(DOWN_GEAR_CH,8)
	setOutConfig(REAR_HORN_CH,8)
	setOutConfig(REAR_LIGTH_CH,20)
	setOutConfig(STOP_VALVE,8)
	setOutConfig(HORN_CH,7,1)
	setOutConfig(LOW_BEAM_CH,3)
	setPWMGroupeFreq(5, 100)
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
    local KeyBoard		= KeyPad8:new(0x15)--создание объекта клавиатура c адресом 0x15
	local DASH			= Dashboard:new(0x10,800)
	local CanIn         = CanInput:new(0x28) -- <адрес can>, < таймаут>	
	local Turns	        = TurnSygnals:new(800)
	local FlashCounter  = Counter:new(0,20,0,true)
	local GearCounter   = Counter:new(0,2,1,false)
	local WaterKeyDelay = Delay:new( 1200, false)
	local BeamCounter   = Counter:new(1,3,1,true) 
	local FlashTimer    = Delay:new( 20,  true )
	local FlashEnabel   = true	
	local LEFT		= false
	local RIGTH   = false
	local ALARM		= false	
    local REAR_MOVE = false
	local PREHEAT = false
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
	local dash_start = 0
    init()				   		
    DASH:init()	
	KeyBoard:setBackLigthBrigth(  3 )
	--рабочий цикл
	while true do		
		KeyBoard:process() --процесс работы с клавиатурой
		DASH:process()	   --процесс отправки данных о каналах в даш
		dash_start = CanIn:process() --процесс получение данных с входа Can. Переменная становится единицей, как только что-то получили от приборки
		local start = getDIN(ING_IN)	
	    local temp     = (dash_start == 1 ) and CanIn:getByte(1) or 0   -- получаем первый байт из фрейма, температура охлаждающей жидкости
		local OilTemp  = (dash_start == 1 ) and CanIn:getByte(2) or 0 --  CanOilTempIn:getByte(1)  -- получаем первый байт из фрейма, температура масла
		local RPM =     (dash_start == 1 ) and CanIn:getWord(4) or 0
		local speed =   (dash_start == 1 ) and CanIn:getByte(3) or 0		
		local stop_signal = getDIN(STOP_SW)
		KeyBoard:setBackLigthBrigth( start and 15 or 3 )	-- подсветка клавиатуры
		--как только приходит сигнал зажигания
        setOut(CUT_VALVE, true)
		setOut(FUEL_PUMP_CH,true)
		setOut( STARTER_CH, true)	
		setOut(KL30, true )
		setOut(HORN_CH , true )
		setOut(STOP_VALVE, true )
		setOut(OIL_FAN_CH, true)
		setOut(UP_GEAR,    true )
		setOut(DOWN_GEAR_CH,   true)		
		setOut(REAR_LIGTH_CH,  true) --задний ход
		setOut(REAR_HORN_CH,   true) --сигнал заднего хода
		--конец блока переключения передач
		--блок управления горном
      
	    setOut(LOW_BEAM_CH,  true )  -- ближний свет
		setOut(STOP_CH,  true )  --ближний свет и стоп сигнал
		--OutSetPWM(STOP_CH, stop_signal and 99 or 30)
		setOut(HIGH_BEAM, true)
		
	
		setOut(WIPERS_CH, true )
		
		setOut(WATER_CH , true )
		setOut(RIGTH_TURN_CH, true)
		setOut(LEFT_TURN_CH, true)
		setOut(GLOW_PLUG_1_2, true)
		setOut(GLOW_PLUG_3_4, true)
		--конец блока предпрогрева
	   Yield()
	end
end