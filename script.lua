
main = function () 
	OutConfig(10,10,1000,60) 
	KeyPad =  KeyPad8:new(0x15) 
	al     = TurnSygnals:new(500)  	
	k=3  
	i=0 
	t=false
	while true do 
		OutSetPWM(13,k) 

		KeyPad:process()
		al:process( true , KeyPad:getToggle( 1 ), KeyPad:getToggle( 3 ),  KeyPad:getToggle( 2 ))  		

   	        KeyPad:resetToggle(1, KeyPad:getToggle( 2 ) or KeyPad:getKey( 3 ) )
		KeyPad:resetToggle(3, KeyPad:getToggle( 2 ) or KeyPad:getKey( 1 ) )

		KeyPad:setLedRed(1,al:getLeft()) 
		KeyPad:setLedRed(2,al:getAlarm()) 
		KeyPad:setLedRed(3,al:getRight())		

	        i = i + getDelay()  
		if (i > 500) then 
			i = 0 
		        k = k+1
		        if k >8 then 
				k = 3 
				t = not t
			else 
				KeyPad:setLedGreen(k,t) 
			end  
		end  
		Yield()
  	
 	end 
end