Dashboard = {}
Dashboard.__index = Dashboard
function Dashboard:new( addr)
      local obj = {key = 0x00, ADDR = addr, new = true,  tog= 0x00, old =0x00, ledRed=0x00,ledGreen=0x00, ledBlue =0x00, temp={[1]=0}, backligth = 0, led_brigth = 0}
      setmetatable (obj, self)
      setCanFilter(0x180 +addr)
      return obj
end
function Dashboard:process()
	if (GetCanToTable(0x180 + self.ADDR,self.temp) ==1 ) then
		self.tog = (~ self.key & self.temp[1]) ~ self.tog
		self.key =self.temp[1]
	end
	if self.new == true then
		self.new = false
		CanSend(0x200 + self.ADDR,self.ledRed,self.ledGreen,self.ledBlue,0,0,0,0,0)
	end
end


