Delay = {}
Delay.__index = Delay
function Delay:new ( inDelay , pulse)
	local obj  = { counter = 0, launched = false, output = false, delay = inDelay ,  mode = pulse, satate = false}
	setmetatable( obj, self )
	return obj
end
function Delay:process ( start, disable )
    
	if start then
	  if self.launched == false then
		self.launched = true
		self.counter = 0
	  end
	  if self.launched == true then
	    self.counter = self.counter + getDelay()
		if self.counter > self.delay then		 			
		  self.state = true
		  if self.mode == true then
		   self.counter = 0
		  end		  
		else
		 self.state = false
		end				
	  end		
	else
	   self.launched = false
	end
	self.launched = self.launched and (not disable)
	self.output = self.state and start and (not disable)
	return self.output
end
function Delay:process_delay( start)
	if start then
	    self.counter = self.counter + getDelay()
		if self.counter > self.delay then		 			
		  self.output = true		  
		else
		 self.output = false
		end				
    else
	  self.counter = 0
	  self.output = false
	end
end
function Delay:get ()
	return self.output
end
