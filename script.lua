


TURNS_LIGTH = {}
TURNS_LIGTH.__index = TURNS_LIGTH
function TURNS_LIGTH:NEW()
		       local obj = { i_l = false, i_r = false, i_a = false,  o_l = false, o_r, o_a =false, t =0, clk = false}
		       	       setmetatable (obj, self)
						return obj
						end
				function TURNS_LIGTH:PROCESS( tim ,ign )
					self.t = self.t + tim 
					if (ign == true) then
						if (self.t > 500) then 
							 self.clk = not self.clk 
							 self.t=0 
						end
						self.o_a = self.clk and self.i_a		
						self.o_r = self.clk and self.i_r
						self.o_l = self.clk and self.i_l														
					end
				end
				function  TURNS_LIGTH:setALARM( data)
 					self.i_a = data 
				end
				function  TURNS_LIGTH:setRIGTH( data)
					self.i_r =  data
				end
				function  TURNS_LIGTH:setLEFT( data)
					self.i_l  = data
				end
				function  TURNS_LIGTH:getALARM( )
 					return self.o_a 
				end
				function  TURNS_LIGTH:getRIGTH( )
					return self.o_r 
				end
				function  TURNS_LIGTH:getLEFT( )
					 return self.o_l 
				end






main = function () 
	OutConfig(10,10,1000,60) 
	KeyPad =  KeyPad8:new(0x15) 
	al     = TURNS_LIGTH:NEW()  	
	k=3  
	i=0 
	t=false
	while true do 
		OutSetPWM(13,k) 
		KeyPad:process()
		al:PROCESS(getDelay(),true)  		

   	        KeyPad:resetToggle(1, KeyPad:getToggle( 2 ) or KeyPad:getKey( 3 ) )
		KeyPad:resetToggle(3, KeyPad:getToggle( 2 ) or KeyPad:getKey( 1 ) )

                al:setALARM( KeyPad:getToggle( 2 ) )
		al:setLEFT( KeyPad:getToggle( 1 ) ) 
		al:setRIGTH( KeyPad:getToggle( 3 ) ) 

		KeyPad:setLedRed(1,al:getLEFT()) 
		KeyPad:setLedRed(2,al:getALARM()) 
		KeyPad:setLedRed(3,al:getRIGTH())		
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