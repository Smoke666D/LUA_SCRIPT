delayms = 0
DOut =  { 
	flase,
	true,
	flase,
	flase,
	flase,
	flase,
	flase,
	flase,
	flase,
	flase,
	flase,
	flase,
	flase,
	flase,
	flase,
	flase,
	flase,
	flase,
	flase,
	flase
}
DInput = { 
	flase,
	true,
	flase,
	flase,
	flase,
	flase,
	flase,
	flase,
	flase,
	flase,
	flase
}
Cur = { 
	0, 
	0, 
	0, 
	0, 
	0, 
	0, 
	0, 
	0, 
	0, 
	0, 
	0, 
	0, 
	0, 
	0, 
	0, 
	0, 
	0, 
	0, 
	0, 
	0 
}
function Yield ()
	delayms, DInput[1], DInput[2], DInput[3], DInput[4], DInput[5], DInput[6], DInput[7], DInput[8], DInput[9], DInput[10], DInput[11], Cur[1], Cur[2], Cur[3], Cur[4], Cur[5], Cur[6], Cur[7], Cur[8], Cur[9], Cur[10], Cur[11], Cur[12], Cur[13], Cur[14], Cur[15], Cur[16], Cur[17], Cur[18], Cur[19], Cur[20] = coroutine.yield( DOut[20], DOut[19], DOut[18], DOut[17], DOut[16], DOut[15], DOut[14], DOut[13], DOut[12], DOut[11], DOut[10], DOut[9], DOut[8], DOut[7], DOut[6], DOut[5], DOut[4], DOut[3], DOut[2], DOut[1] )	
end
function getDelay()
	return delayms
end    
function boltoint(data)
   return data and 1 or 0
end
function igetDIN(ch)	
	return ch < 11 and boltoint(DInput[ch]) or 0
end
Delay = {
}
Delay.__index = Delay
function Delay:new (inDelay, neg)
	local obj  = { 
		counter = 0, 
		launched = false, 
		output = not neg, 
		delay = inDelay , 
		state = neg, 
		rst = true
	}
	setmetatable(obj,self)
	return obj
end
function Delay:process(start)
	if start == true then	
	  if self.rst == true then
			self.launched = true
	    self.counter = 0
	  end
	end
	self.rst = not start
	if self.launched == true then	
		self.counter = self.counter + getDelay()
		if self.counter < self.delay then
			self.output = self.state
		else
			self.launched = false
		end		
	else 
		self.output = not self.state
	end
	return
end
function Delay:get()
	return self.output
end
CanInput = {
}
CanInput.__index = CanInput
function CanInput:new(addr)
	local obj = { 
		ADDR = addr, 
		data = {
			0,
			0,
			0,
			0,
			0,
			0,
			0,
			0
		}
	}
	setmetatable(obj,self)
    setCanFilter(addr)
	return obj
end
function CanInput:process()
  GetCanToTable(self.ADDR, self.data) 
end
function CanInput:getBit(nb,nbit)	
	return self.data[nb] & 1 << nbit - 1 > 0 and true or false
end
init = function()
	setOutConfig(13, 8, 0, 10) 
end
main = function () 
	Delay10s = Delay:new(10000, true)  	
	CAN_TEMP = CanInput:new(0x028)
	while true do 
		Delay10s:process(true) 
		CAN_TEMP:process()		
		 setOut(13, Delay10s:get() or CAN_TEMP:getBit(1, 1))
		brigth = igetDIN(2) << 4 
		CanSend(0x615, 0x2F, 0x03, 0x20, 0x02, brigth, 0, 0, 0)				
		Yield()
	end		  	 	 
end