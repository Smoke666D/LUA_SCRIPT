Wipers = {}
Wipers.__index = Wipers
function Wipers:new (  pause, count)
	local obj = {  p = pause, c = count , out = false, timer =0, p_work = false, p_count = 0,  fsm = 0}
	setmetatable( obj, self )
	return obj
end
function Wipers:process( ign, start,  pause, location)
	if ign == true then
	  
	 -- self.out = start or self.p_work 
	--	if self.fsm == 0 then
	--		if location then
	--			self.p_work = true
	--			self.fsm = 1
	--		end
	--	elseif  self.fsm == 1 then
	--		if (not location) then
	--			self.fsm = 2
	--		end
	--		elseif self.fsm == 2 then
	--		if location then
	--			self.p_count = self.p_count + 1
	--			if self.p_count >= self.c then
	--			self.fsm = 3
	--		     self.p_work = false
	--		   else
	---		     self.fsm = 2
	--	           end
	--		end
	--	elseif	self.fsm == 3 then
	--		self.timer = self.timer + getDelay()
	--		if (self.timer > self.p) then
	--		   self.timer = 0
	--		   self.fsm = 0
	--		end
	--	end
	 --   else
	--	self.fsm = 0
	--	self.timer = 0
	--	self.p_count = 0
	--	self.p_work = false
	    
	    
	else
	  self.out = start or  location
	end
	
end
function Wipers:getOut( )
	return self.out 
end