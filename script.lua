
main = function () 
	OutConfig(1,10,2000,60) 
	OutConfig(2,10,2000,60) 
	OutConfig(3,10,2000,60) 
	OutConfig(4,5,2000,60) 
	OutConfig(5,5,2000,60) 
	OutConfig(6,5,2000,60) 
	OutConfig(7,5,2000,60) 
	OutConfig(8,10,2000,60) 
	OutConfig(9,8,0,10) 
	OutConfig(10,8,0,10) 
	OutConfig(11,8,0,10) 
	OutConfig(12,8,0,10) 
	OutConfig(13,8,0,10) 
	OutConfig(14,8,0,10) 
	OutConfig(15,8,0,10) 
	OutConfig(16,8,0,10) 
	OutConfig(17,8,0,10) 
	OutConfig(18,8,0,10) 
	OutConfig(19,8,0,10) 
	OutConfig(20,8,0,10) 

	KeyPad =  KeyPad8:new(0x15) 	
        TurnSygnal = TurnSygnals:new(500)  	
        Delay500ms   = Delay:new( 500 )  
	Counter1     = Counter:new ( 4, 8, true ) 

	t=true
	while true do 


		KeyPad:process()    	
		Delay500ms:process( true )

		Counter1:process( Delay500ms:get() , false, false )

		TurnSygnal:process( true , KeyPad:getToggle( 1 ), KeyPad:getToggle( 3 ),  KeyPad:getToggle( 2 ))  		

   	        KeyPad:resetToggle(1, KeyPad:getToggle( 2 ) or KeyPad:getKey( 3 ) ) 

		KeyPad:resetToggle(3, KeyPad:getToggle( 2 ) or KeyPad:getKey( 1 ) ) 

		KeyPad:setLedRed(1,TurnSygnal:getLeft()) 

		KeyPad:setLedRed(2,TurnSygnal:getAlarm()) 

		KeyPad:setLedRed(3,TurnSygnal:getRight())		


		KeyPad:setLedGreen( Counter1:get(),t) 		
		if ( Counter1:get()==4) and Delay500ms:get()  then
			t = not t
		end 
	        setOut(13, TurnSygnal:getAlarm())
		
		Yield()
  	
 	end 
end