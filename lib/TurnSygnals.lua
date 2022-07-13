-- TURN SYGNALS NODE
--   lua_node_turnSygnals.json
-- constructor:
--   inDelay - delay for turn sygnal blinking ( number )
-- process:
--   enb   - enable sygnal from the ignition ( boolean )
--   left  - state of the left turning switch ( boolean )
--   right - state of the right turning switch ( boolean )
--   alarm - state of the alarm switch ( boolean )
-- getLeft:
--   control sygnal for the left turning light ( boolean )
-- getRight:
--   control sygnal for the right turning light ( boolean )
-- getAlarm:
--   control sygnal for the alarm light ( boolean )
TurnSygnals = {}
TurnSygnals.__index = TurnSygnals
function TurnSygnals:new ( inDelay )
	local obj = nil
	if ( type( inDelay ) == number ) then
		obj = { delay    = inDelay,
						counter  = 0,
						state    = false,
						outLeft  = false, 
						outRigth = false, 
						outAlarm = false }
		setmetatable( obj, self )
	end
	return obj
end
function TurnSygnals:process ( enb, left, right, alarm )
	self.counter = self.counter + system.getTimeout()
	if ( self.counter >= self.delay ) then
		self.state    = not state
		self.counter  = 0
		self.outLeft  = ( alarm or ( enb and left  ) ) and state
		self.outRigth = ( alarm or ( enb and right ) ) and state
		self.outAlarm = alarm and state
	end
end
function TurnSygnals:getLeft ()
	return self.outLeft
end
function TurnSygnals:getRight ()
	return self.outRight
end
function TurnSygnals:getAlarm ()
	return self.outAlarm
end