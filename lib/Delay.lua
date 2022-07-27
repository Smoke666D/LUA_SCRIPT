-- DELAY NODE
--  lua_node_delay.json
-- constructor:
--   inDelay - delay value in ms ( number )
-- process:
--   start - start delay counting. To reset timer
--           switch start to false after the delay ( boolean )
-- get:
--   finish of the delay ( boolean )
Delay = {}
Delay.__index = Delay
function Delay:new ( inDelay , neg )
	local obj  = { counter = 0, launched = false, output = not neg, delay = inDelay , state = neg, str = false}
	setmetatable( obj, self )
	return obj
end
function Delay:process ( start )
	if start == true  then	
	   if self.str == false then
	     self.str = true
	     self.counter = 0
	   end
	else
	  self.str = false		
	end
	
	if (self.str == true) and (self.launched ==false) then
	  self.launched = true
	  self.str = false	  
	end
	if (self.launched == true ) then	
		self.counter = self.counter + getDelay()
		if ( self.counter < self.delay ) then
			self.output  = self.state
		else	
			self.launched = false
		end		
	else 
		self.output   = not self.state
	end
	return
end
function Delay:get ()
	return self.output
end

