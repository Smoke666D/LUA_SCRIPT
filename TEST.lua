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

	TURNS_LIGTH = {}
		TURNS_LIGTH.__index = TURNS_LIGTH
		               function TURNS_LIGTH:NEW()
				       local obj = { in_left = false, in_rigth = false, in_alarm = false,  out_left = false, out_rigth, out_alarm =false, timer =0, clock = false}
		       	       setmetatable (obj, self)
						return obj
						end
				function TURNS_LIGTH:PROCESS( tim ,ign )
					self.timer = self.timer + tim 
					if (ign == true) then
					if (self.timer > 500) then if self.clock == true then self.clock = false else self.clock = true end self.timer=0 end
					self.out_alarm = false self.out_left = false  self.out_rigth = false				
					if (self.in_alarm == true) then  self.out_alarm = self.clock  else 
					if (self.in_rigth == true) then   self.out_rigth=self.clock  else
					if (self.in_left  == true) then   self.out_left =self.clock  end
						 end end  end
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
KEYPAD_8 = {}
KEYPAD_8.__index = KEYPAD_8
               function KEYPAD_8:NEW( addr)
		       local obj = {key = 0x00, ADDR = addr, new = false,  tog= 0x00, old =0x00, led_red=0x00,led_green=0x00, led_blue =0x00, temp={0}}
	       	       setmetatable (obj, self) SetCanFilter(0x180 +addr)
     		       return obj
     		   end
		function KEYPAD8:PROCESS()
			if (GetCanToTable(0x180 + self.ADDR,self.temp)==1) then  
				self.tog = (~ self.key & self.temp[1]) ~ self.tog	
				self.key =self.temp[1]	 
			end
			if self.new == true then
				self.new = false		
				CanSend(0x215,self.led_red,self.led_green,self.led_blue,0,0,0,0,0)
			end
		end 
		function KEYPAD_8:KEY( ind ) 
		  	  return  (self.key & ( 0x01 << (ind-1)) ) ~= 0 
					end 
		function KEYPAD_8:TOG( ind ) 
                 return  (self.tog & ( 0x01 << (ind-1)) ) ~= 0 
	        end 
		function KEYPAD_8:RES( ind ) 
		 self.tog =  (~(0x01<< ind)) & self.tog 
		end 
	        function KEYPAD_8:LED_RED( ind, data)
		 	 if (data == false) then self.led_red = self.led_red & (~(0x01<<(ind-1))) else self.led_red = self.led_red | (0x01<<(ind-1)) end
		    self.new = true
	     	end
		function KEYPAD_8:LED_GREEN( ind, data)
				 	 if (data == false) then self.led_green = self.led_green & (~(0x01<<(ind-1))) else self.led_green = self.led_green | (0x01<<(ind-1)) end
				    self.new = true
			     	end
					function KEYPAD_8:LED_BLUE( ind, data)
							 	 if (data == false) then self.led_blue = self.led_blue & (~(0x01<<(ind-1))) else self.led_blue = self.led_blue | (0x01<<(ind-1)) end
							    self.new = true
						     	end


COUNTER = { }
COUNTER.__index = COUNTER
	     function COUNTER:NEW (a, b, c)     
	       local obj = {counter = 0, min = a, max= b, mode = c}	 
       	       setmetatable (obj, self)	 	
     	       return obj
       	     end		
	     function COUNTER:PROCESS( inc, dec, res)	
		if inc  then 
		   if self.counter < self.max then self.counter = self.counter + 1 elseif self.mode == "OVER" then self.counter = self.min end 		
		end
		if dec then 
		   if self.counter > self.min then self.counter = self.counter - 1 elseif self.mode == "OVER" then  self.counter = self.max end 
		end 
		if res  then self.counter = self.min end         
         	return self.counter
             end

TIMER = { }
TIMER.__index = TIMER
	 function TIMER:NEW( a,b )
	    local lobj = { timer = 0,  high = b, low = a+b }
	    setmetatable (lobj, self)	 	
     	    return lobj       	
	 end
	 function TIMER:NEWTIC( tic, start )
	   if (tic ~= nil) then 
		if self.timer > 0 then self.timer = self.timer + tic elseif start then self.timer = 1 end 
		print (self.timer)
                if self.timer > self.low then if start then self.timer = 1 else self.timer = 0 end end
		if (self.timer > 0 ) and ( self.timer <= self.high )   then return true else return false end

	    end	
	   return flase
	 end




CAN_OUT = {}
CAN_OUT.__index = CAN_OUT
	function CAN_OUT:NEW(a,b)
 	  local cobj = { timer = 0, addr = a, time = b }
	  setmetatable (cobj, self)	 	
     	  return cobj       		
	end
	function CAN_OUT:PROCESS(tic,d1,d2,d3,d4,d5,d6,d7,d8)
	 if (tic ~=nil) then
	    self.timer = self.time + tic
	    if (self.timer >= self.time) then
		self.timer =  0
		CanSend(self.addr,8,d1,d2,d3,d4,d5,d6,d7,d8)
    	    end
	 end
	end






main = function ( In1 )

function stop()
  In1 = coroutine.yield(Out1)
end
KeyPad      = KEYPAD8:NEW(21)
al          = TURNS_LIGTH:NEW()
--i = 0
while true do
--i = i + 1
--if i==10 then
 k=3  i=0 t=1
KeyPad:PROCESS()
al:PROCESS(10,true)
al.in_left =  KeyPad:TOG(1) 
al.in_rigth = KeyPad:TOG(3) 
al.in_alarm = KeyPad:TOG(2) 
KeyPad:LED_RED(1,al.out_left) 
KeyPad:LED_RED(2,al.out_alarm) 
KeyPad:LED_RED(3,al.out_rigth)	
i = i + timer
if (i > 500) then 
i = 0  
k = k+1
 if k >8 then 
	k = 3 
	if t==false then
		 t=true 
	else 
		t=false 
	endd
 else 
	KeyPad:LED_GREEN(k,t) 
end  
end  

Out1 = KeyPad:KEY(1)

--end
stop()

end 
end