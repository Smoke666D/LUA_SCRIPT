                	


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
        Delay500ms      = Delay:new( 500 )  
	LigthCounter    = Counter:new ( 1, 4, 1, true ) 
	WiperCounter    = Counter:new ( 1, 3, 1, true ) 
	
	CAN_OUT1	= CanOut:new(0x505,900,8,0,0,0,0,0,0,0,0)
	CAN_OUT2	= CanOut:new(0x506,900,8,0,0,0,0,0,0,0,0)
	CAN_OUT3	= CanOut:new(0x507,900,8,0,0,0,0,0,0,0,0)
	CAN_CH1 	= CanInput:new(0x020)
	CAN_CH2		= CanInput:new(0x509)
	CAN_ALARM 	= CanInput:new(0x034)
	Wiper 	        = Wipers:new(2000,3)
	wiperstart      = false
	wiperpause      = false
	lowbeam = false
	highbeam = false
	t=true
	temp = false	





	while true do 

		KeyPad:process()    	
		Delay500ms:process( true )
		CAN_CH1:process()
		CAN_CH2:process()
		CAN_ALARM:process()
	        CAN_OUT1:process()
	        CAN_OUT2:process()
	        CAN_OUT3:process()		


--		CAN_OUT1:setByte(1,getCurrent(1)//1)
		CAN_OUT1:setFrame(1,2,3,4)
	        --can out data
--		CAN_OUT1:setFrame(getCurrent(1)/10,(getCurrent(1)*10)%10,getCurrent(2)/10,(getCurrent(2)*10)%10,getCurrent(3)/10,(getCurrent(3)*10)%10,getCurrent(4)/10,(getCurrent(4)*10)%10)
--		CAN_OUT1:setWord(0,getCurrent(1)) CAN_OUT1:setWord(2,getCurrent(2)) CAN_OUT1:setWord(4,getCurrent(3)) CAN_OUT1:setWord(6,getCurrent(4))
--               CAN_OUT2:setWord(0,getCurrent(5)) CAN_OUT1:setWord(2,getCurrent(6)) CAN_OUT1:setWord(4,getCurrent(7)) CAN_OUT1:setWord(6,getCurrent(8))
--                CAN_OUT3:setWord(0,getDins()) 

		-- HORN
	        setOut(1, KeyPad:getKey( 1 ))			-- HORN out set
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
--		setOut(5, wiperstart or  wiperpause )	
		
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

	        setOut(13, TurnSygnal:getAlarm() or TurnSygnal:getLeft() or TurnSygnal:getRight())
		
		KeyPad:setLedGreen( 3, KeyPad:getToggle( 3 ) ) 
		KeyPad:setLedGreen( 4, KeyPad:getToggle( 4 ) ) 
		
		Yield()
  	
 	end 
end