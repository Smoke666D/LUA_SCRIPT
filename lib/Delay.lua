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
	local obj = nil
	if ( type( inDelay ) == number ) then
		obj = { counter = 0, launched = false, output = false, delay = inDelay }
		setmetatable( obj, self )
	end
	return obj
end
function Delay:process ( start )
	if ( self.launched == true ) then
		self.counter = self.counter + system.getTimeout()
		if ( self.counter >= self.delay ) then
			self.output   = true
			self.launched = false
		end
	elseif ( ( self.output == false ) and ( start == true ) ) then
		self.launched = true
	elseif ( ( self.output == true ) and ( start == false ) ) then
		self.output  = false
		self.counter = 0
	end
	return
end
function Delay:get ()
	return self.output
end