-- COUNTER NODE
--   lua_node_counter.json
-- constructor:
--   inMin    - minimum value ( number )
--   inMax    - maximum value ( number )
--   inReload - reload mode: true, stop mode: false ( boolean )
-- process:
--   inc - increment counter ( boolean )
--   dec - decriment counter ( boolean )
--   rst - reset counter ( boolean )
-- get:
--   counter value ( number )
Counter = {}
Counter.__index = Counter
function Counter:new ( inMin, inMax, inReload )
	local obj = { counter = inMin, min = inMin, max = inMax, reload = inReload , inc_old = false}
	setmetatable( obj, self )
	return obj
end
function Counter:process ( inc, dec, rst )
	if ( inc == true ) then		
		if self.inc_old == false then
			if ( self.counter < self.max ) then
				self.counter = self.counter + 1
			elseif ( self.reload == true ) then
				self.counter = self.min
			end
			self.inc_old = true
		end
	else
		self.inc_old = false
	end

	if ( dec == true ) then
		if ( self.counter > self.min ) then
			self.counter = self.counter - 1
		elseif ( self.reload == true ) then
			self.counter = self.max
		end
	end
	if ( rst == true ) then
		self.counter = self.min
	end
	return
end
function Counter:get ()
	return self.counter
end