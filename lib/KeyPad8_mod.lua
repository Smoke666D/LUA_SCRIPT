
KeyPad8 = {}
KeyPad8.__index = KeyPad8
function KeyPad8:new( addr)
      local obj = { key = 0x00, ADDR = addr, new = true, alive =false, tog= 0x00, old =0x00, ledRed=0x00,ledGreen=0x00, ledBlue =0x00, temp={[1]=0,[2]=0,[3]=0,[4]=0,[5]=0,[6]=0,[7]=0,[8]=0}, backligth = 0, led_brigth = 0, color = 0,timer = 0}	  
      setmetatable (obj, self)
	  
      setCanFilter(0x180 +addr)
	  setCanFilter(0x700 +addr)
	  setCanFilter(0x580 +addr)
      return obj
end
function KeyPad8:process()
    self.timer = self.timer + getDelay()
	if (self.timer > 500) then
	 self.timer = 0
	 CanSend(0x600 + self.ADDR, 0x40,0x00,0x20,0x01,0,0,0,0)
	 end
	if (GetCanToTable(0x580 + self.ADDR,self.temp) ==1 ) then
	  if ((self.temp[1] == 0x4F) and (self.temp[2] == 0x00) and (self.temp[3] == 0x20) and (self.temp[4] == 0x01)) then
	     self.tog = (~ self.key & self.temp[5]) ~ self.tog
		self.key =self.temp[5]
	  end
	end
	if (GetCanToTable(0x180 + self.ADDR,self.temp) ==1 ) then
		self.tog = (~ self.key & self.temp[1]) ~ self.tog
		self.key =self.temp[1]
	end
	if (GetCanToTable(0x700 +self.ADDR,self.temp ) == 1 ) then
	   self.tog = 0
	   self.key = 0
	   self.old = 0
	   self.new = true
	end
	if self.new == true then
		self.new = false		
		CanSend(0x500 + self.ADDR,self.backligth,7	,0,0,0,0,0,0)
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
function KeyPad8:setToggle( n )	 
		 self.tog =  (0x01<< ( n-1 ) ) | self.tog	 
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

function KeyPad8:setBackLigthColor( color )
	self.old = color
	if (self.old ~= self.color) then
		self.color=self.old
		CanSend(0x600 + self.ADDR,0x2F,0x03,0x20,0x03,self.color,0,0,0)
	end
end

function KeyPad8:setBackLigthBrigth( brigth )
	self.old = brigth
	if (self.old ~= self.backligth) then
		self.backligth =self.old
		self.new = true
		--CanSend(0x600 + self.ADDR,0x2F,0x03,0x20,0x02,self.backligth,0,0,0)
	end
end