
Out1 = true 
Out2 = false 
Out3 = false 
Out4 = false 
Out5 = false 
Out6 = false 
Out7 = false 
Out8 = false 
Out9 = false 
Out10 = false
Out11 = false 
Out12 = false 
Out13 = true 
Out14 = false 
Out15 = false 
Out16 = false 
Out17 = false 
Out18 = false 
Out19 = false 
Out20 = false 
timer = 0

KEYPAD8 = {}
KEYPAD8.__index = KEYPAD8

function KEYPAD8:NEW( addr)
      local obj = {key = 0x00, ADDR = addr, new = false,  tog= 0x00, old =0x00, led_red=0x00,led_green=0x00, led_blue =0x00, temp={0}}
      setmetatable (obj, self) 
      SetCanFilter(0x180 +addr)
      return obj
end
function KEYPAD8:PROCESS()
	if (GetCanToTable(0x180 + self.ADDR,self.temp) ==1 ) then  
		self.tog = (~ self.key & self.temp[1]) ~ self.tog	
		self.key =self.temp[1]	 
	end
	if self.new == true then
		self.new = false		
		CanSend(0x215,self.led_red,self.led_green,self.led_blue,0,0,0,0,0)
	end
end
function KEYPAD8:KEY( ind )
	  return  (self.key & ( 0x01 << (ind-1)) ) ~= 0 
end
function KEYPAD8:TOG( ind ) 
         return  (self.tog & ( 0x01 << (ind-1)) ) ~= 0 
end
function KEYPAD8:RES( ind )
	 self.tog =  (~(0x01<< (ind-1))) & self.tog
end
function KEYPAD8:LED_RED( ind, data)
	 if (data == false) then 
		self.led_red = self.led_red & (~(0x01<<(ind-1))) 
	 else 
		self.led_red = self.led_red | (0x01<<(ind-1)) 
	 end
	 self.new = true
end
function KEYPAD8:LED_GREEN( ind, data)
 	 if (data == false) then 
		self.led_green = self.led_green & (~(0x01<<(ind-1))) 
	 else 
		self.led_green = self.led_green | (0x01<<(ind-1)) 
	 end    
         self.new = true
end
function KEYPAD8:LED_BLUE( ind, data)
	 if (data == false) then 
		self.led_blue = self.led_blue & (~(0x01<<(ind-1))) 
	 else 
		self.led_blue = self.led_blue | (0x01<<(ind-1)) 
	 end
	 self.new = true        	
end

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


function stop() timer = coroutine.yield(Out20,Out19,Out18,Out17,Out16,Out15,Out14,Out13,Out12,Out11,Out10,Out9,Out8,Out7,Out6,Out5,Out4,Out3,Out2,Out1) end
main = function () 
	OutConfig(10,10,1000,60) 
	KeyPad =  KEYPAD8:NEW(0x15) 
	al     = TURNS_LIGTH:NEW()  
	k=3  
	i=0 
	t=false
	while true do 
		OutSetPWM(13,k) 
		KeyPad:PROCESS()
		al:PROCESS(timer,true)  		
		if  KeyPad:TOG(2) == true then
		    KeyPad:RES(1)
		    KeyPad:RES(3)		    
		end
		if KeyPad:KEY(1) then  KeyPad:RES(3) end
		if KeyPad:KEY(3) then  KeyPad:RES(1) end
                al:setALARM(KeyPad:TOG(2))
		al:setLEFT(KeyPad:TOG(1)) 
		al:setRIGTH(KeyPad:TOG(3)) 
		KeyPad:LED_RED(1,al:getLEFT()) 
		KeyPad:LED_RED(2,al:getALARM()) 
		KeyPad:LED_RED(3,al:getRIGTH())		
	        i = i + timer  
		if (i > 500) then 
			i = 0 
		        k = k+1
		        if k >8 then 
				k = 3 
				t = not t
			else 
				KeyPad:LED_GREEN(k,t) 
			end  
		end  
		stop()
 	end 
end