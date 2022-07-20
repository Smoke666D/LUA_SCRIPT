function CanSendTable( addr, p)
end

function getBit (data, pos )
	if  (data  &  ( 0x01<< pos-1)) then
		return  true
	else
		return false
	end
end

CanInput = {}
CanInput.__index = CanInput
function CanInput:new ( addr )
	local obj = { ADDR = addr, data={0,0,0,0,0,0,0,0}}
	setmetatable( obj, self )
	return obj
end
function CanInput:process()
     GetCanToTable( self.ADDR,self.data) 
end
function CanInput:getBit( nb, nbit)	
	return getBit(self.data[nb], nbit)
end
function CanInput:getByte( nb )
	return self.data[nb]
end
function CanInput:getWord( nb )
	return self.data[nb]<<8 | self.data[nb+1]
end

CanOut = {}
CanOut.__index = CanOut
function CanOut:new ( addr , time , size, d1, d2, d3, d4, d5, d6, d7, d8)
	local obj = { ADDR = addr, data={d1,d2,d3,d4,d5,d6,d7,d8}, delay = time, timer = 0}
	setmetatable( obj, self )
	return obj
end
function CanOut:process()
    self.timer = self.timer + getDelay() 
    if self.timer >=  self.delay then   
     CanSendTable(self.ADDR,self.data)     
     self.timer	= 0
    end
end
function CanOut:setBit( nb, nbit, state)	
	if state == true then
  	  data[nb] = data[bn] | (0x01 << (nbit-1))
	else
  	  data[nb] = data[bn] & ~(0x01 << (nbit-1))
	end

end
function CanOut:setByte( nb ,state )
	data[nb] = state  & 0xFF
end
function CanOut:setWord( nb ,state)
	self.data[nb] = (state <<8) & 0xFF
        self.data[nb+1] = state & 0xFF

end


