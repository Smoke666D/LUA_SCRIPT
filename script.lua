                	


main = function () 
--	OutConfig(1,10,2000,60) 
--	OutConfig(2,10,2000,60)
--	OutConfig(3,10,2000,60) 
--	OutConfig(4,5,2000,60) 
--	OutConfig(5,5,2000,60) 
--	OutConfig(6,5,2000,60) 
--	OutConfig(7,5,2000,60) 
--	OutConfig(8,10,2000,60) 
--	OutConfig(9,8,0,10) 
--	OutConfig(10,8,0,10) 
--	OutConfig(11,8,0,10) 
--	OutConfig(12,8,0,10) 
	OutConfig(13,8,0,10) 
--	OutConfig(14,8,0,10) 
--	OutConfig(15,8,0,10) 
--	OutConfig(16,8,0,10) 
--	OutConfig(17,8,0,10) 
--	OutConfig(18,8,0,10) 
--	OutConfig(19,8,0,10) 
--	OutConfig(20,8,0,10) 
        SetDINConfig(1,1)
        SetDINConfig(2,1)
        SetDINConfig(3,1)
        SetDINConfig(4,1)
        SetDINConfig(5,1)
        SetDINConfig(6,1)
        SetDINConfig(7,1)
        SetDINConfig(8,1)
        SetDINConfig(9,1)
        SetDINConfig(10,1)
        SetDINConfig(11,1)
        SetDINConfig(12,1)


	KeyPad          = KeyPad8:new(0x15) 	
        TurnSygnal      = TurnSygnals:new(500)  
        Delay10s     	= Delay:new( 10000,true )  	
        Delay8s      	= Delay:new( 8000,true )  
        Delay4s     	= Delay:new( 4000,true )  
        Delay3s     	= Delay:new( 3000,true )  
        Delay2s     	= Delay:new( 2000,true )  
        Delay1s     	= Delay:new( 1000,true )  
	LigthCounter    = Counter:new ( 1, 4, 1, true ) 
	WiperCounter    = Counter:new ( 1, 3, 1, true ) 
	
	CAN_OUT1	= CanOut:new(0x505,900,8,0,0,0,0,0,0,0,0)
	CAN_OUT2	= CanOut:new(0x506,900,8,0,0,0,0,0,0,0,0)
	CAN_OUT3	= CanOut:new(0x507,900,8,0,0,0,0,0,0,0,0)
	CAN_OUT4	= CanOut:new(0x508,900,8,0,0,0,0,0,0,0,0)
	CAN_OUT5	= CanOut:new(0x509,900,8,0,0,0,0,0,0,0,0)
	CAN_OUT6	= CanOut:new(0x510,900,8,0,0,0,0,0,0,0,0)
	CAN_TEMP        = CanInput:new(0x028)
	CAN_CH1 	= CanInput:new(0x020)
	CAN_CH2		= CanInput:new(0x509)
	CAN_CH3         = CanInput:new(0x5F2)
	CAN_ALARM 	= CanInput:new(0x034)
	Wiper 	        = Wipers:new(2000,3)
	wiperstart      = false
	wiperpause      = false
	lowbeam = false
	highbeam = false
	t=true
	temp = false	
	starter	= false	
	ignition = false	 
        pre_heat_on = false
	while true do 

		KeyPad:process()    	
		Delay8s:process( ignition )
		Delay4s:process( ignition )
		Delay3s:process( ignition )
		Delay2s:process( ignition )
		Delay1s:process( ignition )
		CAN_CH1:process()
		CAN_CH2:process()
		CAN_CH3:process()
		starter  = CAN_CH3:getBit(1,4)
		ignition = --CAN_CH3:getBit(1,1)
CAN_CH3:getByte(1) > 0 and true or false --  
		CAN_ALARM:process()
	        CAN_OUT1:process()
	        CAN_OUT2:process()
	        CAN_OUT3:process()		
	        CAN_OUT4:process()		
		CAN_OUT5:process()		
		CAN_OUT6:process()		
		CAN_TEMP:process()

		
		can_temp = CAN_TEMP:getByte(1)  --Get fist byte from CAN. In LUA all numeration from 1. 
	        --can out data
	        DIN_STATE =  igetDIN(1) | igetDIN(2)<<1 | igetDIN(3)<<2 | igetDIN(4)<<3 | igetDIN(5)<<4| igetDIN(6)<<5 | igetDIN(7)<<6 | igetDIN(8)<<7    
	        DIN_STATE1 = igetDIN(9) | igetDIN(10)<<1 | igetDIN(11)<<2 
		CAN_OUT1:setFrame(DIN_STATE,DIN_STATE1) 		
	
		CAN_OUT2:setFrame(getCurFB(1),getCurSB(1),getCurFB(2),getCurSB(2),getCurFB(3),getCurSB(3),getCurFB(4),getCurSB(4))
          	CAN_OUT3:setFrame(getCurFB(5),getCurSB(5),getCurFB(6),getCurSB(6),getCurFB(7),getCurSB(7),getCurFB(8),getCurSB(8))
		CAN_OUT4:setFrame(getCurFB(9),getCurSB(9),getCurFB(10),getCurSB(10),getCurFB(11),getCurSB(11),getCurFB(12),getCurSB(12))
		CAN_OUT5:setFrame(getCurFB(13),getCurSB(13),getCurFB(14),getCurSB(14),getCurFB(15),getCurSB(15),getCurFB(16),getCurSB(16))
		CAN_OUT6:setFrame(getCurFB(17),getCurSB(17),getCurFB(18),getCurSB(18),getCurFB(19),getCurSB(19),getCurFB(20),getCurSB(20))


		brigth = igetDIN( 2) << 4 
		
                KeyPad:setBackLigthBrigth( brigth)

		--PREHEAT
				
		pre_heat_on = --( 
				Delay8s:get() --and ( can_temp<40) ) or 
			      --( Delay4s:get() and ( can_temp<50) ) or 
			      --( Delay3s:get() and ( can_temp<60) ) or 
			      --( Delay2s:get() and ( can_temp<70) ) or 
			      --( Delay1s:get() and ( can_temp<100) )
--		setOut(12,pre_heat_on)                		
		setOut(13,pre_heat_on)
		-- HORN
	        setOut(1, KeyPad:getKey( 1 ) )			-- HORN out set
		KeyPad:setLedGreen(1,KeyPad:getKey( 1 ))        -- HORN LED on

		--LIGTH switch
					--inc             dec   res
		LigthCounter:process(KeyPad:getKey( 2 ), false, false)		
		lowbeam  = ( LigthCounter:get() == 2) 
		highbeam = ( LigthCounter:get() == 4) 
	        setOut(8, lowbeam)			-- lowbeam out set
		setOut(6, highbeam)			-- highbeam out set
		KeyPad:setLedGreen(2,lowbeam)           -- lowbeam LED on
		KeyPad:setLedBlue(2,highbeam)           -- highbeam LED on

		--WASH
  		WiperCounter:process(KeyPad:getKey( 8 ), false, false)		
		wiperstart = ( WiperCounter:get() == 2 )  		   
		wiperpause = ( WiperCounter:get()  == 3) 

		setOut(2, KeyPad:getKey( 8 ) and getDIN(2) )
		KeyPad:setLedGreen(8, wiperstart ) 		
		KeyPad:setLedBlue(8, wiperpause  ) 	
		setOut(5, wiperstart or  wiperpause )	
		
		--Turn signal
		TurnSygnal:process( true , KeyPad:getToggle( 5 ), KeyPad:getToggle( 6 ),  KeyPad:getToggle( 7 ))  				
   	        KeyPad:resetToggle( 5, KeyPad:getToggle( 7 ) or KeyPad:getKey( 6 ) ) 
		KeyPad:resetToggle( 6, KeyPad:getToggle( 7 ) or KeyPad:getKey( 5 ) ) 
		KeyPad:setLedWhite( 5, TurnSygnal:getLeft() ) 
		KeyPad:setLedWhite( 6, TurnSygnal:getRight() )		
		KeyPad:setLedRed( 7, TurnSygnal:getAlarm() ) 
		KeyPad:setLedGreen( 7, TurnSygnal:getAlarm() ) 
	        setOut( 3 , TurnSygnal:getLeft()  or TurnSygnal:getAlarm() )
	        setOut( 7 , TurnSygnal:getRight() or TurnSygnal:getAlarm() )

--	        setOut(13, TurnSygnal:getAlarm() or TurnSygnal:getLeft() or TurnSygnal:getRight())


		KeyPad:setLedGreen( 3, KeyPad:getToggle( 3 ) ) 
		KeyPad:setLedGreen( 4, KeyPad:getToggle( 4 ) ) 
		
		Yield()
  	
 	end 
end