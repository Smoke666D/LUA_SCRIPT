-- KEYPAD8 NODE
--  lua_node_keyPad8.json
-- constructor:
--  inAdr - network address of the krypad in CAN field bus
-- process:
--  none
-- getKey:
--   get key state with number n ( number )
-- getToggle:
--   get toggle key state with number n ( number )
-- resetToggle:
--   reset key toggle state with number n ( number )
-- setLedRed:
--   set red led state ( boolean ) with number n ( number )
-- setLedGreen:
--   set green led state ( boolean ) with number n ( number )
-- setLedBlue:
--   set blue led state ( boolean ) with number n ( number )
KeyPad8 = {}
KeyPad8.__index = KeyPad8

function KeyPad8:new( addr)
      local obj = {key = 0x00, ADDR = addr, new = true,  tog= 0x00, old =0x00, ledRed=0x00,ledGreen=0x00, ledBlue =0x00, temp={0}}
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
   	CanSend(0x600 + self.ADDR,0x2F,0x03,0x20,0x01,brigth,0,0,0)
end
function KeyPad8:setBackLigthBrigth( brigth )
    	CanSend(0x600 + self.ADDR,0x2F,0x03,0x20,0x02,brigth,0,0,0)
end