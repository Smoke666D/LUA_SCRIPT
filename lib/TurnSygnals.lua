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

	local obj = {                           delay    = inDelay,
						counter  = 0,
						state    = true,
						outLeft  = false, 
						outRight = false, 
						outAlarm = false }
	
	setmetatable( obj, self )
	return obj
end
function TurnSygnals:process ( enb, left, right, alarm )
		self.counter = self.counter + getDelay()		
		if ( self.counter > self.delay )  then
			self.state    = not self.state
			self.counter  = 0
			self.outLeft  = left  and self.state and enb and (not alarm)
			self.outRight = right and self.state and enb and (not alarm)
			self.outAlarm = alarm and self.state and enb 
		end				
end
function TurnSygnals:getRight()
	return self.outRight
end
function TurnSygnals:getLeft()
	return self.outLeft
end
function TurnSygnals:getAlarm ()
	return self.outAlarm
end

