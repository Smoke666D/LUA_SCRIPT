init = function()
        ConfigCan(1,1000);
        setOutConfig(1,45,0,60)
	OutResetConfig(1,1,0)
	setOutConfig(2,20,0,60)
	setOutConfig(3,20,0,60)
	setOutConfig(4,20,0,60)
	setOutConfig(5,20,0,60)
	setOutConfig(6,20,0,60)
	setOutConfig(7,20,0,60)
	setOutConfig(8,20,0,60)
	setOutConfig(9,8,0,10)
	setOutConfig(10,8,0,10)
	setOutConfig(11,8,0,10)
	setOutConfig(12,8,0,10)
	setOutConfig(13,10,0,30)
	OutResetConfig(13,1,0)

	setOutConfig(14,8,0,10)
	setOutConfig(15,8,0,10)
	setOutConfig(16,8,0,10)
	setOutConfig(17,8,0,10)
	setOutConfig(18,8,0,10)
	setOutConfig(19,8,0,10)
	setOutConfig(20,8,0,10)
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
--        SetEEPROM(0x01,0x6743)
--        CAN_EXCHENGE    = CanRequest:new()
--	if ( CAN_EXCHENGE:waitCAN(0x615,0x595,8000,0x2F,0x03,0x20,0x03,0x06,0x00,0x00,0x00) == true) then
--		local dd1,dd2,dd3,dd4,dd5,dd6,dd7,dd8 = CAN_EXCHENGE:getData()
--		if dd1 == 0x60 then
--		        setOut(13,true )
--		end
--	end
end
----
main = function ()
	local KeyPad          = KeyPad8:new(0x15)
        local TurnSygnal      = TurnSygnals:new(500)
        local Delay10s     	= Delay:new( 10000,true )
        local Delay8s      	= Delay:new( 8000,true )
        local Delay4s     	= Delay:new( 4000,true )
        local Delay3s     	= Delay:new( 3000,true )
        local Delay2s     	= Delay:new( 2000,true )
        local Delay1s     	= Delay:new( 1000,true )
	local LigthCounter      = Counter:new ( 1, 4, 1, true )
	local WiperCounter	= Counter:new ( 1, 3, 1, true )
	local CAN_OUT1		= CanOut:new(0x505,900,8,0,0,0,0,0,0,0,0)
	local CAN_OUT2		= CanOut:new(0x506,900,8,0,0,0,0,0,0,0,0)
	local CAN_OUT3		= CanOut:new(0x507,900,8,0,0,0,0,0,0,0,0)
	local CAN_OUT4		= CanOut:new(0x508,900,8,0,0,0,0,0,0,0,0)
	local CAN_OUT5		= CanOut:new(0x509,900,8,0,0,0,0,0,0,0,0)
	local CAN_OUT6		= CanOut:new(0x510,900,8,0,0,0,0,0,0,0,0)
	local CAN_OUT_TEST	= CanOut:new(0x530,900,8,0,0,0,0,0,0,0,0)
	local CAN_TEMP        	= CanInput:new(0x028)
	local CAN_RPM 		= CanInput:new(0x032)
	local CAN_CH2		= CanInput:new(0x511)
	local CAN_CH3         	= CanInput:new(0x5F2)
	local CAN_ALARM 	= CanInput:new(0x034)
	local DASH		= Dashboard:new(0x00,500)
	

	DASH:init("PDM20","HORN","WASHER","LEFT TURN","REAR GEAR LIGHT","WIPERS","HIGHBEAM","RIGHTTURN","LOWBEAM","N/A","N/A","FUELPUMP","PREHEAT","PREHEAT","COOLFAN","STARTER","IGNITION")

	local temp_out		= true	
	local temp_out1		= true
	local counter		= 0
	local counter1		= 0
	local Wiper 	        = Wipers:new(2000,3)
	setOut(1,false)
	setOut(2,true)
	setOut(4,false)
	setOut(7,false)
	while true do
			DASH:process()
			counter = counter + 1
			counter1 = counter1 + 1

			if counter > 500 then
				counter = 0
				temp_out = not temp_out
                                setOut(13, temp_out )
--		                OutSetPWM(1, temp_out and 30 or 60)
			--	setOut(7,temp_out)
			--	setOut(4,temp_out)
			end
			if counter1 > 50 then
				counter1 = 0
				temp_out1 = not temp_out1
			        OutSetPWM(2, temp_out1 and 30 or 90)
--                                setOut(2, temp_out1 )
			end
		--	if counter2 > 1000 then
		--		counter2 = 0
		--		temp_out2 = not temp_out2
                --               setOut(1, temp_out2 )
		--	end

			KeyPad:process()
			CAN_CH2:process()
			CAN_RPM:process()
			CAN_CH3:process()
		   
			local starter  = CAN_CH3:getBit(1,4)
			local ignition = CAN_CH3:getBit(1,1)
			CAN_ALARM:process()
			CAN_OUT1:process()
--		        CAN_OUT2:process()
--		        CAN_OUT3:process()
--		        CAN_OUT4:process()
--			CAN_OUT5:process()
--			CAN_OUT6:process()
                        CAN_OUT_TEST:setFrame(GetEEPROM(0x01)>>8,GetEEPROM(0x01) & 0xFF)
			CAN_OUT_TEST:process()

--			CAN_TEMP:process()
			local can_temp = CAN_TEMP:getByte(1)
			local DIN_STATE =  igetDIN(1) | igetDIN(2)<<1 | igetDIN(3)<<2 | igetDIN(4)<<3 | igetDIN(5)<<4| igetDIN(6)<<5 | igetDIN(7)<<6 | igetDIN(8)<<7
			local DIN_STATE1 = igetDIN(9) | igetDIN(10)<<1 | igetDIN(11)<<2
			CAN_OUT1:setFrame(DIN_STATE,DIN_STATE1)
			CAN_OUT2:setFrame(getCurFB(1),getCurSB(1),getCurFB(2),getCurSB(2),getCurFB(3),getCurSB(3),getCurFB(4),getCurSB(4))
			CAN_OUT3:setFrame(getCurFB(5),getCurSB(5),getCurFB(6),getCurSB(6),getCurFB(7),getCurSB(7),getCurFB(8),getCurSB(8))
			CAN_OUT4:setFrame(getCurFB(9),getCurSB(9),getCurFB(10),getCurSB(10),getCurFB(11),getCurSB(11),getCurFB(12),getCurSB(12))
			CAN_OUT5:setFrame(getCurFB(13),getCurSB(13),getCurFB(14),getCurSB(14),getCurFB(15),getCurSB(15),getCurFB(16),getCurSB(16))
			CAN_OUT6:setFrame(getCurFB(17),getCurSB(17),getCurFB(18),getCurSB(18),getCurFB(19),getCurSB(19),getCurFB(20),getCurSB(20))
			local brigth = igetDIN( 2) << 4
	                KeyPad:setBackLigthBrigth( brigth)
			Delay8s:process( ignition )
			Delay4s:process( ignition )
			Delay3s:process( ignition )
			Delay2s:process( ignition )
			Delay1s:process( ignition )
			local pre_heat_on = ( Delay8s:get() and ( can_temp<40) ) or
			      ( Delay4s:get() and ( can_temp<50) ) or
			      ( Delay3s:get() and ( can_temp<60) ) or
			      ( Delay2s:get() and ( can_temp<70) ) or
			      ( Delay1s:get() and ( can_temp<100) )
--			setOut(12,pre_heat_on)
			local fan_on  =  KeyPad:getToggle( 4 )  or (ignition and (can_temp == 0 ))  or (can_temp > 125)
			KeyPad:setLedGreen( 4, KeyPad:getToggle( 4 ) )
--			setOut(14, fan_on  )
			Delay10s:process(starter)
			local starter_on = Delay10s:get() and ignition and (CAN_RPM:getWord(1) < 500)
--			setOut(15, starter_on  )
--			setOut(11, ignition )
--			setOut(16, ignition )
--		        setOut(1, KeyPad:getKey( 1 ) )
			KeyPad:setLedGreen(1,KeyPad:getKey( 1 ))
			LigthCounter:process(KeyPad:getKey( 2 ), false, false)
			local lowbeam  = ( LigthCounter:get() == 2)
			local highbeam = ( LigthCounter:get() == 4)
--		        setOut(8, lowbeam)
--			setOut(6, highbeam)
			KeyPad:setLedGreen(2,lowbeam)
			KeyPad:setLedBlue(2,highbeam)
			WiperCounter:process(KeyPad:getKey( 8 ), false, false)
			local wiperstart = ( WiperCounter:get() == 2 )
			local wiperpause = ( WiperCounter:get()  == 3)
--			setOut(2, KeyPad:getKey( 8 ) and getDIN(2) )
			KeyPad:setLedGreen(8, wiperstart )
			KeyPad:setLedBlue(8, wiperpause  )
--			setOut(5, wiperstart or  wiperpause )
			TurnSygnal:process( true , KeyPad:getToggle( 5 ), KeyPad:getToggle( 6 ),  KeyPad:getToggle( 7 ) )
			KeyPad:resetToggle( 5, KeyPad:getToggle( 7 ) or KeyPad:getKey( 6 ) )
			KeyPad:resetToggle( 6, KeyPad:getToggle( 7 ) or KeyPad:getKey( 5 ) )
			KeyPad:setLedWhite( 5, TurnSygnal:getLeft() )
			KeyPad:setLedWhite( 6, TurnSygnal:getRight() )
			KeyPad:setLedRed( 7, TurnSygnal:getAlarm() )
			KeyPad:setLedGreen( 7, TurnSygnal:getAlarm() )
--		        setOut( 3 , TurnSygnal:getLeft()  or TurnSygnal:getAlarm() )
---		        setOut( 7 , TurnSygnal:getRight() or TurnSygnal:getAlarm() )
			KeyPad:setLedGreen( 3, KeyPad:getToggle( 3 ) )
			--
		Yield()
	end
end
