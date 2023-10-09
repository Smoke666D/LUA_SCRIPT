Pillow = {}
Pillow.__index = Pillow
function Pillow:new ( N , all_N, outOn, outOFF)
	local obj = {  air = 0.0, height = 0.0, number = N, total = all_N , timer = 0, mode = 3, OO =outOn, OF = outOFF,
	state = 1, SA = 0.0, SH = 0.0 , SA10 = 0.0, SH10 = 0.0,  SA5=0.0, SH10 = 0.0} 
	setmetatable( obj, self )
	return obj
end
function Pillow:setData( AirData, HData)
	self.air = AirData
	self.height = HData
end
function Pillow:manualControl( On , Off )
   setOut(self.OO, On  )
   setOut(self.OF, Off )  
end
function Pillow:Calibrate( mode )
	SetEEPROMReg(2 + 2 * self.number + self.total * 2 * mode ,self.height)
	SetEEPROMReg(3 + 2 * self.number + self.total * 2 * mode, self.air)
   --slef.mode = 3
end
function Pillow:process( mode, control_type )
  if self.mode ~= mode then
     self.mode = mode
	 self.timer = 0
	 self.SH =  GetEEPROMReg(1+ 2 * self.number + self.total * 2 * mode )
	 self.SA =  GetEEPROMReg(2+ 2 * self.number + self.total * 2 * mode )
	 self.SA5  = self.SA*0,05
	 self.SH5  = self.SH*0,05
	 self.SA10 = self.SA*0,1
     self.SH10 = self.SH*0,1
  end
  self.state = 1
  local DATA  = ( control_type ) and self.air  or self.height
  local EDATA = ( control_type ) and self.SA   or self.SH
  local D10   = ( control_type ) and self.SA10 or self.SH10
  local D5    = ( control_type ) and self.SA5  or self.SA5
  if ( DATA < EDATA ) then
	local delta = EDATA -DATA
	if  delta > D10 then
		self.state = 4
	else
	    if delta > D5 then
		   self.state = 2
		end
	end
  else
	local delta = DATA - EDATA
	if  delta > D10 then
	   self.state = 3
	else
	  if delta > D5 then
	   self.state = 1
	  end
	end
  end
  local UP   = false
  local DOWN = false
  --импульсно спускаем
  if ( (self.state == 1) or (self.state == 2) )then
	  self.timer = self.timer + getDelay()
	  if self.timer > 500 then
		if self.timer < 700 then
		    UP   =  (self.state == 2 ) and true or false
			DOWN = ( self.state == 1 ) and true or false
		else
			self.timer = 0
	    end 
	  end
   else
	  DOWN = (self.state == 3) and true or false  --спускаем
	  UP   = (self.state == 4) and true or false  --надуваем
   end
   setOut(self.OO, UP  )
   setOut(self.OF, DOWN )
end


