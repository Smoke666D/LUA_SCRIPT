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
function Delay:new ( inDelay )
	local obj  = { counter = 0, launched = false, output = false, delay = inDelay }
	setmetatable( obj, self )
	return obj
end
function Delay:process ( start )
	if ( start == true ) then	
		if  (self.counter == 0) then
			self.output   = false		
		end
		self.counter = self.counter + getDelay()
		if ( self.counter >= self.delay ) then
			self.output   = true
			self.counter = 0
		end
	end

	return
end
function Delay:get ()
	return self.output
end