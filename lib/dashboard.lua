Dashboard = {}
Dashboard.__index = Dashboard
function Dashboard:new( addr, time)
      local obj = { ADDR = addr, repeat_time= time, counter = 0}
      setmetatable (obj, self)
      return obj
end
function Dashboard:init(PDMName,CH1Name,CH2Name,CH3Name,CH4Name,CH5Name,CH6Name,CH7Name,CH8Name,CH9Name,CH10Name,CH11Name,CH12Name,CH13Name,CH14Name,CH15Name,CH16Name,CH17Name,CH18Name,CH19Name,CH20Name)
	if PDMName == nil then
		PDMName = "SIDER PDM"
	end
	if CH1Name == nil then
		CH1Name = "CHANNEL 1"
	end
	if CH2Name == nil then
		CH2Name = "CHANNEL 2"
	end
	if CH3Name == nil then
		CH3Name = "CHANNEL 3"
	end
	if CH4Name == nil then
		CH4Name = "CHANNEL 4"
	end
	if CH5Name == nil then
		CH5Name = "CHANNEL 5"
	end
	if CH6Name == nil then
		CH6Name = "CHANNEL 6"
	end
	if CH7Name == nil then
		CH7Name = "CHANNEL 7"
	end
	if CH8Name == nil then
		CH8Name = "CHANNEL 8"
	end
	if CH9Name == nil then
		CH9Name = "CHANNEL 9"
	end
	if CH10Name == nil then
		CH10Name = "CHANNEL 10"
	end
	if CH11Name == nil then
		CH11Name = "CHANNEL 11"
	end
	if CH12Name == nil then
		CH12Name = "CHANNEL 12"
	end
	if CH13Name == nil then
		CH13Name = "CHANNEL 13"
	end
	if CH14Name == nil then
		CH14Name = "CHANNEL 14"
	end
	if CH15Name == nil then
		CH15Name = "CHANNEL 15"
	end
	if CH16Name == nil then
		CH16Name = "CHANNEL 16"
	end
	if CH17Name == nil then
		CH17Name = "CHANNEL 17"
	end
	if CH18Name == nil then
		CH18Name = "CHANNEL 18"
	end
	if CH19Name == nil then
		CH19Name = "CHANNEL 19"
	end
	if CH20Name == nil then
		CH20Name = "CHANNEL 20"
	end
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,5,string.byte(CH1Name,1,6))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,6,string.byte(CH1Name,7,12))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,7,string.byte(CH1Name,13),string.byte(CH1Name,14),string.byte(CH1Name,15),0x00,string.byte(CH2Name,1,2))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,8,string.byte(CH2Name,3,8))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,9,string.byte(CH2Name,9,14))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,10,string.byte(CH2Name,15),0x00,string.byte(CH3Name,1,4))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,11,string.byte(CH3Name,5,10))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,12,string.byte(CH3Name,11,16))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,13,string.byte(CH4Name,1,6))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,14,string.byte(CH4Name,7,12))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,15,string.byte(CH4Name,13),string.byte(CH4Name,14),string.byte(CH4Name,15),0x00,string.byte(CH5Name,1,2))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,16,string.byte(CH5Name,3,8))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,17,string.byte(CH5Name,9,14))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,18,string.byte(CH5Name,15),0x00,string.byte(CH6Name,1,4))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,19,string.byte(CH6Name,5,10))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,20,string.byte(CH6Name,11,16))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,21,string.byte(CH7Name,1,6))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,22,string.byte(CH7Name,7,12))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,23,string.byte(CH7Name,13),string.byte(CH7Name,14),string.byte(CH7Name,15),0x00,string.byte(CH8Name,1,2))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,24,string.byte(CH8Name,3,8))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,25,string.byte(CH8Name,9,14))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,26,string.byte(CH8Name,15),0x00,string.byte(PDMName,1,4))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,27,string.byte(PDMName,5,10))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR ,1,28,string.byte(PDMName,11,16))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,5,string.byte(CH9Name,1,6))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,6,string.byte(CH9Name,7,12))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,7,string.byte(CH9Name,13),string.byte(CH9Name,14),string.byte(CH9Name,15),0x00,string.byte(CH10Name,1,2))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,8,string.byte(CH10Name,3,8))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,9,string.byte(CH10Name,9,14))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,10,string.byte(CH10Name,15),0x00,string.byte(CH11Name,1,4))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,11,string.byte(CH11Name,5,10))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,12,string.byte(CH11Name,11,16))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,13,string.byte(CH12Name,1,6))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,14,string.byte(CH12Name,7,12))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,15,string.byte(CH12Name,13),string.byte(CH12Name,14),string.byte(CH12Name,15),0x00,string.byte(CH13Name,1,2))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,16,string.byte(CH13Name,3,8))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,17,string.byte(CH13Name,9,14))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,18,string.byte(CH13Name,15),0x00,string.byte(CH14Name,1,4))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,19,string.byte(CH14Name,5,10))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,20,string.byte(CH14Name,11,16))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,21,string.byte(CH15Name,1,6))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,22,string.byte(CH15Name,7,12))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,23,string.byte(CH15Name,13),string.byte(CH15Name,14),string.byte(CH15Name,15),0x00,string.byte(CH16Name,1,2))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,24,string.byte(CH16Name,3,8))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,25,string.byte(CH16Name,9,14))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,26,string.byte(CH16Name,15),0x00,string.byte(PDMName,1,4))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,27,string.byte(PDMName,5,10))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+1 ,1,28,string.byte(PDMName,11,16))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+2 ,1,5,string.byte(CH17Name,1,6))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+2 ,1,6,string.byte(CH17Name,7,12))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+2 ,1,7,string.byte(CH17Name,13),string.byte(CH17Name,14),string.byte(CH17Name,15),0x00,string.byte(CH18Name,1,2))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+2 ,1,8,string.byte(CH18Name,3,8))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+2 ,1,9,string.byte(CH18Name,9,14))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+2 ,1,10,string.byte(CH18Name,15),0x00,string.byte(CH19Name,1,4))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+2 ,1,11,string.byte(CH19Name,5,10))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+2 ,1,12,string.byte(CH19Name,11,16))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+2 ,1,13,string.byte(CH20Name,1,6))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+2 ,1,14,string.byte(CH20Name,7,12))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+2 ,1,15,string.byte(CH20Name,13),string.byte(CH20Name,14),string.byte(CH20Name,15),0x00,0,0)
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+2 ,1,26,0,0,string.byte(PDMName,1,4))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+2 ,1,27,string.byte(PDMName,5,10))
	CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR+2 ,1,28,string.byte(PDMName,11,16))
end
function Dashboard:process()
	self.counter = self.counter + getDelay()
	if self.counter > self.repeat_time then
		self.counter = 0
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR    ,1,0,getOutStatus(1),getOutStatus(2),getOutStatus(3),getOutStatus(4),getOutStatus(5),getOutStatus(6))
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR    ,1,1,getOutStatus(7),getOutStatus(8),getCurLSB10(1),getCurMSB10(1),getCurLSB10(2),getCurMSB10(2))
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR    ,1,2,getCurLSB10(3),getCurMSB10(3),getCurLSB10(4),getCurMSB10(4),getCurLSB10(5),getCurMSB10(5))
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR    ,1,3,getCurLSB10(6),getCurMSB10(6),getCurLSB10(7),getCurMSB10(7),getCurLSB10(8),getCurMSB10(8))
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR    ,1,4,0,0,0,0,getBatLSB10(),getBatMSB10())
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR + 1,1,0,getOutStatus(9),getOutStatus(10),getOutStatus(11),getOutStatus(12),getOutStatus(13),getOutStatus(14))
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR + 1,1,1,getOutStatus(15),getOutStatus(16),getCurMSB10(9),getCurLSB10(9),getCurLSB10(10),getCurMSB10(10))
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR + 1,1,2,getCurLSB10(11),getCurMSB10(11),getCurLSB10(12),getCurMSB10(12),getCurLSB10(13),getCurMSB10(13))
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR + 1,1,3,getCurLSB10(14),getCurMSB10(14),getCurLSB10(15),getCurMSB10(15),getCurLSB10(16),getCurMSB10(16))
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR + 1,1,4,0,0,0,0,getBatLSB10(),getBatMSB10())
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR + 2 ,1,0,getOutStatus(17),getOutStatus(18),getOutStatus(19),getOutStatus(20),0,0)
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR + 2,1,1,0,0,getCurLSB10(17),getCurMSB10(17),getCurLSB10(18),getCurMSB10(18))
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR + 2,1,3,getCurLSB10(19),getCurMSB10(20),0,0,0,0)
		CanSend(EXT_CAN_ID | 0x0F000000  | self.ADDR + 2,1,4,0,0,0,0,getBatLSB10(),getBatMSB10())
	end
end


