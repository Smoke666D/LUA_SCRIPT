delayms = 0
DOut =  { 
    [1] = flase,
    [2] = true,
    [3] = flase,
    [4] = flase,
    [5] = flase,
    [6] = flase,
    [7] = flase,
    [8] = flase,
    [9] = flase,
    [10] = flase,
    [11] = flase,
    [12] = flase,
    [13] = flase,
    [14] = flase,
    [15] = flase,
    [16] = flase,
    [17] = flase,
    [18] = flase,
    [19] = flase,
    [20] = flase,
}
DInput = { 
    [1] = flase,
    [2] = false,
    [3] = flase,
    [4] = flase,
    [5] = flase,
    [6] = flase,
    [7] = flase,
    [8] = flase,
    [9] = flase,
    [10] = flase,
    [11] = flase,
}
Cur = { 
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
    [7] = 0,
    [8] = 0,
    [9] = 0,
    [10] = 0,
    [11] = 0,
    [12] = 0,
    [13] = 0,
    [14] = 0,
    [15] = 0,
    [16] = 0,
    [17] = 0,
    [18] = 0,
    [19] = 0,
    [20] = 0,

}
function Yield ()
	delayms, DInput[1], DInput[2], DInput[3], DInput[4], DInput[5], DInput[6], DInput[7], DInput[8], DInput[9], DInput[10], DInput[11], Cur[1], Cur[2], Cur[3], Cur[4], Cur[5], Cur[6], Cur[7], Cur[8], Cur[9], Cur[10], Cur[11], Cur[12], Cur[13], Cur[14], Cur[15], Cur[16], Cur[17], Cur[18], Cur[19], Cur[20] = coroutine.yield( DOut[20], DOut[19], DOut[18], DOut[17], DOut[16], DOut[15], DOut[14], DOut[13], DOut[12], DOut[11], DOut[10], DOut[9], DOut[8], DOut[7], DOut[6], DOut[5], DOut[4], DOut[3], DOut[2], DOut[1] )	
end
function getDelay()
	return delayms
end    
function setOut( ch, data)
	if ch <=20 then
		DOut[ch] = data;			
	end
end


function boltoint(data)
   return data and 1 or 0
end
function igetDIN(ch)	
	return ch < 11 and boltoint(DInput[ch]) or 0
end
KeyPad8 = {}
KeyPad8.__index = KeyPad8

function KeyPad8:new( addr)
      local obj = {key = 0x00, ADDR = addr, new = true,  tog= 0x00, old =0x00, ledRed=0x00,ledGreen=0x00, ledBlue =0x00, temp={[1]=0}, backligth = 0, led_brigth = 0}
      setmetatable (obj, self) 
      setCanFilter(0x180 +addr)
      return obj
end
function KeyPad8:process()
	if (GetCanToTable(0x180 + self.ADDR,self.temp) ==1 ) then  
		self.tog = (~ self.key & self.temp[1]) ~ self.tog	
		self.key =self.temp[1]	 
	end
	if self.new == true then
		self.new = false		
		CanSend(0x200 + self.ADDR,self.ledRed,self.ledGreen,self.ledBlue,0,0,0,0,0)
	end
end
function KeyPad8:getKey( n )
	  return  (self.key & ( 0x01 << ( n - 1 ) ) ) ~= 0 
end
function KeyPad8:getToggle( n ) 
         return  (self.tog & ( 0x01 << ( n - 1 ) ) ) ~= 0 
end
function KeyPad8:resetToggle( n , state)
	 if state == true then
		 self.tog =  (~(0x01<< ( n-1 ) )) & self.tog
	 end
end
function KeyPad8:setLedRed( n , state)
	self.old = (state ) and  self.ledRed | (0x01<<(n-1)) or self.ledRed & (~(0x01<<( n-1 ))) 
	if ( self.old ~= self.ledRed ) then
        	self.ledRed = self.old 
 	        self.new = true
	end


end
function KeyPad8:setLedGreen( n, state)
        self.old = (state ) and self.ledGreen | (0x01<<(n-1)) or self.ledGreen & (~(0x01<<( n-1 ))) 
	if ( self.old ~= self.ledGreen ) then
        	self.ledGreen = self.old 
 	        self.new = true
	end
end
function KeyPad8:setLedBlue( n , state)
        self.old = (state ) and  self.ledBlue | (0x01<<(n-1)) or self.ledBlue & (~(0x01<<( n-1 ))) 
	if ( self.old ~= self.ledBlue ) then
        	self.ledBlue = self.old 
 	        self.new = true
	end
end
function KeyPad8:setLedWhite( n , state)
	 self:setLedBlue(n, state)
	 self:setLedGreen(n, state)
	 self:setLedRed(n, state)
end

function KeyPad8:setLedBrigth( brigth )
	if (self.ledbrigth ~= brigth) then
	   self.ledbrigth = brigth
	   CanSend(0x600 + self.ADDR,0x2F,0x03,0x20,0x01,brigth,0,0,0)
	end
end
function KeyPad8:setBackLigthBrigth( brigth )
	if (self.backligth ~=brigth) then
		self.backligth =brigth		
	    	CanSend(0x600 + self.ADDR,0x2F,0x03,0x20,0x02,brigth,0,0,0)
	end
end


Delay = {}
Delay.__index = Delay
function Delay:new ( inDelay , neg )
	local obj  = { counter = 0, launched = false, output = not neg, delay = inDelay , state = neg, rst = true}
	setmetatable( obj, self )
	return obj
end
function Delay:process ( start )
	if start == true  then	
	   if self.rst == true then
		self.launched = true
	        self.counter = 0
	   end
	end
	self.rst = not start
	if (self.launched == true ) then	
		self.counter = self.counter + getDelay()
		if ( self.counter < self.delay ) then
			self.output  = self.state
		else	
			self.launched = false
		end		
	else 
		self.output   = not self.state
	end
	return
end
function Delay:get ()
	return self.output
end




init = function()
	
end
main = function () 
        Delay10s     	= Delay:new( 10000,true )  	
	KeyPad          = KeyPad8:new(0x15) 	
	while true do 

			KeyPad:process()    	
			Delay10s:process( true ) 
	   	       setOut(13,Delay10s:get())
			KeyPad:setLedWhite( 6, Delay10s:get() )		                		

		Yield()
	end		  	 	 
end