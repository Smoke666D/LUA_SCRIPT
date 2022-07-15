


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

	KeyPad          = KeyPad8:new(0x15) 	
        TurnSygnal      = TurnSygnals:new(500)  	
        Delay500ms      = Delay:new( 500 )  
	LigthCounter    = Counter:new ( 1, 4, true ) 
	WiperCounter    = Counter:new ( 1, 3, true ) 

	CAN_CH1 	= CanInput:new(0x020)
	CAN_CH2		= CanInput:new(0x509)
	CAN_ALARM 	= CanInput:new(0x034)
	Wiper 	        = Wipers:new(2000,3)

	ws      = false
	wp      = false
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
	


		-- HORN
	        setOut(1, KeyPad:getKey( 1 ))			-- HORN out set
		KeyPad:setLedGreen(1,KeyPad:getKey( 1 ))        -- HORN LED on

		--LIGTH switch

		LigthCounter:process(KeyPad:getKey( 2 ), false, false)		
		if ( LigthCounter:get() == 2) then
			lowbeam = true
			highbeam = false
		elseif ( LigthCounter:get() == 4) then 
			lowbeam = false
			highbeam = true
		else
			lowbeam = false
			highbeam = false		
		end		

	        setOut(8, lowbeam)			-- lowbeam out set
		setOut(6, highbeam)			-- highbeam out set
		KeyPad:setLedGreen(2,lowbeam)           -- lowbeam LED on
		KeyPad:setLedBlue(2,highbeam)           -- highbeam LED on

		--WASH
  		WiperCounter:process(KeyPad:getKey( 8 ), false, false)		
		if ( WiperCounter:get() == 2 )	then  		   
			ws  = true
                       	wp  = false
		elseif (WiperCounter:get() == 3) then
			ws  = false
                       	wp  = true
		else
                	ws  = false
                      	wp  = false
		end
--                Wiper:process(getDIN(2), wiperstart or KeyPad:getKey( 8 ), wiperpause, KeyPad:getKey( 4 ) )
		Wash_Permit = KeyPad:getKey( 8 ) and getDIN(2)
		setOut(2, Wash_Permit )  -- setOut(2, KeyPad:getKey( 8 ) and getDIN(2)	) 
		KeyPad:setLedGreen(8, ws ) 		
		KeyPad:setLedBlue(8, wp  ) 		
		
		--Turn signal
		TurnSygnal:process( true , KeyPad:getToggle( 5 ), KeyPad:getToggle( 6 ),  KeyPad:getToggle( 7 ))  				
   	        KeyPad:resetToggle( 5, KeyPad:getToggle( 7 ) or KeyPad:getKey( 6 ) ) 
		KeyPad:resetToggle( 6, KeyPad:getToggle( 7 ) or KeyPad:getKey( 5 ) ) 
		KeyPad:setLedRed( 5, TurnSygnal:getLeft() ) 
		KeyPad:setLedRed( 6, TurnSygnal:getRight() )		
		KeyPad:setLedRed( 7, TurnSygnal:getAlarm() ) 
	        setOut( 3 , TurnSygnal:getLeft()  or TurnSygnal:getAlarm() )
	        setOut( 7 , TurnSygnal:getRight() or TurnSygnal:getAlarm() )

	        setOut(13, TurnSygnal:getAlarm() or TurnSygnal:getLeft() or TurnSygnal:getRight())
		
		Yield()
  	
 	end 
end