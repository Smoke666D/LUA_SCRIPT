Out1 = false
----------------------------------------------------------------------------------------------------------------------
-- SYSTEM CLASS
System = {}
System.__index = System
function System:new ()
	local obj = {}
	setmetatable( obj, self )
	return obj
end
function System:getTimeout ()
	return 1
end
function System:canCheckId ( adr )
	return true
end
function System:canGetMessage ( adr )
	return 0x01, 0x00
end
function System:canSetFilter ( adr )
	return
end
function System:canSend ( adr, b1, b2, b3, b4, b5, b6, b7, b8 )
	return
end
----------------------------------------------------------------------------------------------------------------------
CanOut = {}
CanOut.__index = CanOut
function CanOut:new ( a, b )
	local obj = { timer = 0, addr = a, time = b }
	setmetatable( obj, self )
	return obj
end
function CanOut:process ( tic, d1, d2, d3, d4, d5, d6, d7, d8 )
	if ( tic ~=nil ) then
		self.timer = self.time + tic
		if ( self.timer >= self.time ) then
			self.timer = 0
			canSend( self.addr, 8, d1, d2, d3, d4, d5, d6, d7, d8 )
		end
	end
end
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------
main = function ( In1 )
	function stop()
		In1 = coroutine.yield( Out1 )
	end

	KeyPad      = KeyPad8:new( 21 )
	turnSygnals = TurnSygnals:new( 500 )

	while true do
		k=3
		i=0
		t=1
		KeyPad:process()
		turnSygnals:process( true, KeyPad:getToggle( 1 ), KeyPad:getToggle( 3 ), KeyPad:getToggle( 2 ) )
		KeyPad:setLedRed( 1, turnSygnals.getLeft()  )
		KeyPad:setLedRed( 2, turnSygnals.getAlarm() )
		KeyPad:setLedRed( 3, turnSygnals.getRigth() )
		i = i + timer
		if ( i > 500 ) then
			i = 0
			k = k + 1
			if ( k > 8 ) then
				k = 3
				if ( t == false ) then
					t = true
				else
					t = false
				end
			else
				KeyPad:setLedGreen( k, t )
			end
		end
		Out1 = KeyPad:getKey( 1 )
		stop()
	end
end