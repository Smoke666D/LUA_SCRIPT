init = function()
        setOutConfig(1,10,2000,60) 
	setOutConfig(2,10,2000,60)
	setOutConfig(3,10,2000,60) 
	setOutConfig(4,5,2000,60) 
	setOutConfig(5,5,2000,60) 
	setOutConfig(6,5,2000,60) 
	setOutConfig(7,5,2000,60) 
	setOutConfig(8,10,2000,60) 
	setOutConfig(9,8,0,10) 
	setOutConfig(10,8,0,10) 
	setOutConfig(11,8,0,10) 
	setOutConfig(12,8,0,10) 
	setOutConfig(13,8,0,10) 
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
        CAN_EXCHENGE    = CanRequest:new()
	if ( CAN_EXCHENGE:waitCAN(0x615,0x595,8000,0x2F,0x03,0x20,0x03,0x06,0x00,0x00,0x00) == true) then
		dd1,dd2,dd3,dd4,dd5,dd6,dd7,dd8 = CAN_EXCHENGE:getData()
		if dd1 == 0x60 then
		        setOut(13,true )                					
		end
	end
--	Yield()
end


main = function () 
	
	KeyPad          = KeyPad8:new(0x15) 	
        TurnSygnal      = TurnSygnals:new(500)  	
	CAN_OUT1	= CanOut:new(0x505,900,8,0,0,0,0,0,0,0,0)
	while true do 
			KeyPad:process()    	
		      	CAN_OUT1:process()	
		        --can out data
		        DIN_STATE =  igetDIN(1) | igetDIN(2)<<1 | igetDIN(3)<<2 | igetDIN(4)<<3 | igetDIN(5)<<4| igetDIN(6)<<5 | igetDIN(7)<<6 | igetDIN(8)<<7    
	 	      	DIN_STATE1 = igetDIN(9) | igetDIN(10)<<1 | igetDIN(11)<<2 
			CAN_OUT1:setFrame(DIN_STATE,DIN_STATE1) 		
	
			brigth = igetDIN( 2) << 4 
		
	                KeyPad:setBackLigthBrigth( brigth)

		
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

				
			Yield()
	end		  	 	 
end