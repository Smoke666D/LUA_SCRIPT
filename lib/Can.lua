EXT_CAN_ID = 0x80000000
CanInput = {}
CanInput.__index = CanInput
function CanInput:new ( addr , timeout, mask,  d1,d2,d3,d4,d5,d6,d7,d8 )
	local obj = { ADDR = addr,
		     data={[1]=0,[2]=0,[3]=0,[4]=0,[5]=0,[6]=0,[7]=0,[8]=0},
		     TimeOut = ( timeout ~= nil ) and timeout or 0,
		     MASK    = ( mask ~= nil ) and mask or 0,
		     DefData = {[1] = ( d1 ~= nil ) and d1 or 0,
				[2] = ( d2 ~= nil ) and d2 or 0,
				[3] = ( d3 ~= nil ) and d3 or 0,
				[4] = ( d4 ~= nil ) and d4 or 0,
				[5] = ( d5 ~= nil ) and d5 or 0,
				[6] = ( d6 ~= nil ) and d6 or 0,
				[7] = ( d7 ~= nil ) and d7 or 0,
				[8] = ( d8 ~= nil ) and d8 or 0,
				},
			timer= 0
		    }
	setmetatable( obj, self )
        setCanFilter(addr)
	return obj
end
function CanInput:process()
   self.timer = self.timer + getDelay()
   if  GetCanToTable( self.ADDR,self.data) == 0 then
	if ((self.TimeOut ~= 0) and (self.timer > self.TimeOut)) then
	   if  (self.MASK & 0x01) then  self.data[1] = self.DefData[1] end
	   if  (self.MASK & 0x02) then  self.data[2] = self.DefData[2] end
	   if  (self.MASK & 0x04) then  self.data[3] = self.DefData[3] end
	   if  (self.MASK & 0x08) then  self.data[4] = self.DefData[4] end
	   if  (self.MASK & 0x10) then  self.data[5] = self.DefData[5] end
	   if  (self.MASK & 0x20) then  self.data[6] = self.DefData[6] end
	   if  (self.MASK & 0x40) then  self.data[7] = self.DefData[7] end
	   if  (self.MASK & 0x80) then  self.data[8] = self.DefData[8] end
           self.timer = 0
	end	
   else
       self.timer = 0
   end

end
function CanInput:getBit( nb, nbit)
	return ((self.data[nb] & (0x01<<(nbit-1))) >0 ) and true or false
end
function CanInput:getByte( nb )
	return self.data[nb]
end
function CanInput:getWord( nb )
	return (nb < 7) and ( self.data[nb]<<8 | self.data[nb+1]) or 0
end
CanOut = {}
CanOut.__index = CanOut
function CanOut:new ( addr , time , size, d1, d2, d3, d4, d5, d6, d7, d8)
	local obj = { ADDR = addr, data={[1]=d1,[2]=d2,[3]=d3,[4]=d4,[5]=d5,[6]=d6,[7]=d7,[8]=d8}, delay = time, timer = 0, sz =size}
	setmetatable( obj, self )
	return obj
end
function CanOut:process()
    self.timer = self.timer + getDelay()
    if self.timer >=  self.delay then
	  CanTable(self.ADDR,self.sz,self.data)
          self.timer	= 0
    end
end
function CanOut:setFrame(...)
	local arg =  table.pack(...)
	if (arg.n < 9) then
		for i=1, arg.n do
			self.data[i] = arg[i]
		end
		self.sz = arg.n
	end
end
function CanOut:setBit( nb, nbit, state)
	if state == true then
		self.data[nb] = self.data[nb] | (0x01 << (nbit-1))
	else
		self.data[nb] = self.data[nb] & ~(0x01 << (nbit-1))
	end
end
function CanOut:setByte( nb ,state )
	self.data[nb] = state  & 0xFF
end
function CanOut:setWord( nb ,state)
	self.data[nb] = (state <<8) & 0xFF
        self.data[nb+1] = state & 0xFF
end
CanRequest = {}
CanRequest.__index = CanRequest
function CanRequest:new()
	local obj = { del = 0, timeout =0, data = {[1]=0,[2]=0,[3]=0,[4]=0,[5]=0,[6]=0,[7]=0,[8]=0}}
	setmetatable( obj, self )
	return obj
end
function CanRequest:waitCAN( add, getadd, timeout, d1,d2,d3,d4,d5,d6,d7,d8)
	self.del = 0
        sendCandRequest(add,getadd,d1,d2,d3,d4,d5,d6,d7,d8)
	while true do
		Yield()
		if CheckAnswer() == 1 then
			self.data[1],self.data[2],self.data[3],self.data[4],self.data[5],self.data[6],self.data[7],self.data[8] = GetRequest()
			return true
		end
		self.del = self.del + delayms
		if (self.timeout > 0) then
			if (self.del > timeout) then
				return false
			end
		end
	end
end
function CanRequest:getData()
	return self.data[1],self.data[2],self.data[3],self.data[4],self.data[5],self.data[6],self.data[7],self.data[8]
end