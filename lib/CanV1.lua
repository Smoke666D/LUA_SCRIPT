--Библиотека CAN


EXT_CAN_ID = 0x80000000
-- Объекты СanIput. Cозадется с помощью метода :new( id пакета, время обновления данных , битовая маска, указывающая какие байты из фрема забирать, )
--
CanInputV1 = {}
CanInputV1.__index = CanInputV1
function CanInputV1:new ( addr )
	local obj = { ADDR = addr, eneb = 0,
		     data={[1]=0,[2]=0,[3]=0,[4]=0,[5]=0,[6]=0,[7]=0,[8]=0},		    
		    }
	setmetatable( obj, self )
    setCanFilter(addr)
	return obj
end
function CanInputV1:Reset()
   self.eneb = 0
end

function CanInputV1:process()
	if ( GetCanToTable( self.ADDR,self.data) == 1 ) then
		self.eneb = 1
	end
    return  self.eneb
end
function CanInputV1:getBit( nb, nbit)
	return ((self.data[nb] & (0x01<<(nbit-1))) >0 ) and true or false
end
function CanInputV1:getByte( nb )
	return self.data[nb]
end
function CanInputV1:getWordLSB( nb )
	return (nb < 7) and ( self.data[nb] | self.data[nb+1]<<8) or 0
end
function CanInputV1:getWordMSB( nb )
	return (nb < 7) and ( self.data[nb]<<8 | self.data[nb+1]) or 0
end

CanOut = {}
CanOut.__index = CanOut
function CanOut:new ( addr , time , size, d1, d2, d3, d4, d5, d6, d7, d8)
	local obj = { ADDR = addr,
		      data = { [1]= (d1 ~= nil) and d1 or 0,
			       [2]= (d2 ~= nil) and d2 or 0,
			       [3]= (d3 ~= nil) and d3 or 0,
			       [4]= (d4 ~= nil) and d4 or 0,
			       [5]= (d5 ~= nil) and d5 or 0,
			       [6]= (d6 ~= nil) and d6 or 0,
			       [7]= (d7 ~= nil) and d7 or 0,
			       [8]= (d8 ~= nil) and d8 or 0,
			},
			delay = ( time ~= nil ) and time or 100,
			timer = 0,
			sz = ( size ~= nil) and size or 8
			}
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
		self.data[nb] = self.data[nb] & (~(0x01 << (nbit-1)))
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