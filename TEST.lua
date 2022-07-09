Out1 = false

function SheckCanId ( addr )
   return 1
end

function GetCanMessage( addr )
   return 0x01,0x00
end

function CanSend(addr,b1,b2,b3,b4,b5,b6,b7,b8)
	return
end

KEYPAD8 = {}
KEYPAD8.__index = KEYPAD8
                function KEYPAD8:NEW( addr)
		       local obj = {ADDR = addr, new_d = false, old = 0x00, key = 0x00, tog = 0x00, led_red = 0xFF,led_green=0xFF, led_blue =0xFF}	 
	       	       setmetatable (obj, self)	 	                                                   				
     		       return obj
		end
		function KEYPAD8:PROCESS()					
	                if (SheckCanId(0x180 + self.ADDR)==1) then
				self.old = self.key
	                	self.key = GetCanMessage(0x180 + self.ADDR)
          		       self.tog = (~ self.old & self.key) ~ self.tog				
 			end
			if self.new_d == true then
				self.new_d = false		
				CanSend(0x215+adr,led_red,led_green,led_blue,0x00,0x00,0x00,0x00,0x00)
			end
		end 
		function KEYPAD8:KEY( ind )
		  return  (self.key & ( 0x01 << (ind-1)) ) ~= 0 

		end
		function KEYPAD8:TOG( ind )
                  return  (self.tog & ( 0x01 << ind) ) ~= 0 
	        end
		function KEYPAD8:RES( ind )
		 self.tog =  (~(0x01<< ind)) & self.tog
		end
	        function KEYPAD8:LED_RED( ind, data)
	  	  self.led_red = (data) and (self.led_red | (0x01<<ind)) or (self.led_red & (~(0x01<<1)))
		  new_d = true
		end
	        function KEYPAD8:LED_GREEN( ind, data)
	  	  led_green = (data) and (led_red | (0x01<<ind)) or (led_red & (~(0x01<<1)))
		  new_d = true
		end
	        function KEYPAD8:LED_BLUE( ind, data)
	  	  led_blue = (data) and (led_red | (0x01<<ind)) or (led_red & (~(0x01<<1)))
		  new_d = true
		end


main = function ( In1 )

function stop()
  In1 = coroutine.yield(Out1)
end
KeyPad      = KEYPAD8:NEW(21)
--i = 0
while true do
--i = i + 1
--if i==10 then
KeyPad:PROCESS()
       KeyPad:LED_RED(1,1)
Out1 = KeyPad:KEY(1)
--end
stop()

end 
end