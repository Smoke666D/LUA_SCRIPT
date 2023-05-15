Dashboard = {}
Dashboard.__index = Dashboard
function Dashboard:new( addr, time)
      local obj = { ADDR = addr, repeat_time= time, counter = 0}
      setmetatable (obj, self)
      return obj
end

function Dashboard:process()
	self.counter = self.counter + getDelay()
	if self.counter > self.repeat_time then
		self.counter = 0
		
		
	    CanSend( self.ADDR      ,getCurLSB10(1),getCurMSB10(1),getCurLSB10(2),getCurMSB10(2),getCurLSB10(3),getCurMSB10(3),getCurLSB10(4),getCurMSB10(4))
		CanSend( self.ADDR +1   ,getCurLSB10(5),getCurMSB10(5),getCurLSB10(6),getCurMSB10(6),getCurLSB10(7),getCurMSB10(7),getCurLSB10(8),getCurMSB10(8))
		CanSend( self.ADDR +2   ,getCurLSB10(9),getCurMSB10(9),getCurLSB10(10),getCurMSB10(10),getCurLSB10(11),getCurMSB10(11),getCurLSB10(12),getCurMSB10(12))
		CanSend( self.ADDR +3   ,getCurLSB10(13),getCurMSB10(13),getCurLSB10(14),getCurMSB10(14),getCurLSB10(15),getCurMSB10(15),getCurLSB10(16),getCurMSB10(16))
	    CanSend( self.ADDR +4   ,getCurLSB10(17),getCurMSB10(17),getCurLSB10(18),getCurMSB10(18),getCurLSB10(19),getCurMSB10(19),getCurLSB10(20),getCurMSB10(20))
		CanSend( self.ADDR +5   ,getBatLSB10(),getBatMSB10(),30,0,0,0,0,0)
		CanSend( self.ADDR +6  ,
								getOutStatus(1)  | (getOutStatus(2)<<3) | ((getOutStatus(3) & 0x03)<<6) ,
							    (getOutStatus(3)>>2) | (getOutStatus(4)<<1) | (getOutStatus(5)<<4) | ((getOutStatus(6) & 0x01)<<7),
							   ((getOutStatus(6)>>1) & 0x03) | (getOutStatus(7)<<2) | (getOutStatus(8)<<5) ,
								 getOutStatus(9)  | (getOutStatus(10)<<3)   |  ((getOutStatus(11) & 0x03)<<6) ,
								 
								 
								 getOutStatus(12)  | (getOutStatus(13)<<3)   |  ((getOutStatus(14) & 0x03)<<6) ,
							    (getOutStatus(14)>>2) | (getOutStatus(15)<<1) | (getOutStatus(16)<<4) | ((RIGHT_TO_CAN & 0x01)<<7),
							 ((RIGHT_TO_CAN >>1) & 0x03) | (LEFT_TO_CAN <<2) | (getOutStatus(19)<<5) ,
								 getOutStatus(20)  | ((getOutStatus(11)>>2)<<3)
										)
										
		
	end
end


