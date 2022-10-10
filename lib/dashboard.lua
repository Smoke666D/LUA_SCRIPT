Dashboard = {}
Dashboard.__index = Dashboard
function Dashboard:new( addr, time)
      local obj = { ADDR = addr, repeat_time= time, counter = 0}
      setmetatable (obj, self)     
      return obj
end
function Dashboard:init( PDMName, CH1Name,CH2Name,CH3Name,CH4Name,CH5Name,CH6Name,CH7Name,CH8Name,CH8Name,CH9Name,CH10Name,CH11Name,CH12Name,CH13Name,CH14Name,CH15Name,CH16Name,CH17Name,CH18Name,CH19Name,CH20Name)
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,5,string.byte(CH1Name,1,6))	
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,6,string.byte(CH1Name,7,12))	
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,7,string.byte(CH1Name,13,16),string.byte(CH2Name,1,2))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,8,string.byte(CH2Name,3,8))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,9,string.byte(CH2Name,9,14))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,10,string.byte(CH2Name,9,14))
end
function Dashboard:process()
	self.counter = self.counter + gerDalay()
	if self.counter > self.repeat_time then
		self.counter = 0
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,0,getOut(1),getOut(2),getOut(3),getOut(4),getOut(5),getOut(6))
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,1,getOut(7),getOut(8),0,0,0,0)
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,2,0,0,0,0,0,0)
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,3,0,0,0,0,0,0)
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,4,0,0,0,0,0,0)
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR + 1 ,1,0,getOut(9),getOut(10),getOut(11),getOut(12),getOut(13),getOut(14))
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR + 1 ,1,1,getOut(15),getOut(16),0,0,0,0)
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR + 2 ,1,0,getOut(17),getOut(18),getOut(19),getOut(20),0,0)
	end
end


