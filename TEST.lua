Out1 = false

function SheckCanId ( addr )
	return 1
end

function GetCanMessage( addr )
	return 0x01, 0x00
end

function CanSend( addr, b1, b2, b3, b4, b5, b6, b7, b8 )
	return
end
----------------------------------------------------------------------------------------------------------------------
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
	self.counter = self.counter + system.getTimeout
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
----------------------------------------------------------------------------------------------------------------------
-- KEYPAD8 NODE
--  lua_node_keyPad8.json
-- constructor:
--  inAdr - network address of the krypad in CAN field bus
-- process:
--  none
-- getKey:
--   get key state with number n ( number )
-- getToggle:
--   get toggle key state with number n ( number )
-- resetToggle:
--   reset key toggle state with number n ( number )
-- setLedRed:
--   set red led state ( boolean ) with number n ( number )
-- setLedGreen:
--   set green led state ( boolean ) with number n ( number )
-- setLedBlue:
--   set blue led state ( boolean ) with number n ( number )
KeyPad8 = {}
KeyPad8.__index = KeyPad8
function KeyPad8:new ( inAdr )
	local obj = nil
	if ( type( inAdr ) == number ) then
		local obj = { adr         = inAdr,
									toggleState = 0,
									keyState    = 0,
									oldKeyState = 0,
									ledRed      = 0xFF,
									ledGreen    = 0xFF,
									ledBlue     = 0xFF,
									newData     = false }
		setmetatable( obj, self )
		system.setCanFilter( 0x180 + addr )
	end
	return obj
end
function KeyPad8:process()
	if ( system.canCheckId( 0x180 + self.adr ) == true ) then
		self.oldKeyState = self.keyState
		self.keyState    = system.canGetMessage( 0x180 + self.adr )
		self.toggleState = ( ~ self.oldKeyState & self.keyState ) ~ self.toggleState
	end
	if ( self.newData == true ) then
		self.newData = false
		CanSend( ( 0x215 + adr ), ledRed, ledGreen, ledBlue, 0x00, 0x00, 0x00, 0x00, 0x00 )
	end
end

function KeyPad8:getKey( n )
	return	( self.keyState    & ( 0x01 << n ) ) ~= 0
end
function KeyPad8:getToggle( n )
	return	( self.toggleState & ( 0x01 << n ) ) ~= 0
end
function KeyPad8:resetToggle ( n )
	self.toggleState = ( ~( 0x01 << n ) ) & self.toggleState
end
function KeyPad8:setLedRed ( state, n )
	if ( ( type( n ) == number ) and ( type( state ) == boolean ) ) then
		self.ledRed  = ( state ) and ( self.ledRed | ( 0x01 << n ) ) or ( self.ledRed & ( ~( 0x01 << 1 ) ) )
		self.newData = true
	end
end
function KeyPad8:setLedGreen( state, n )
	if ( ( type( n ) == number ) and ( type( state ) == boolean ) ) then
		self.ledGreen = ( state ) and ( self.ledGreen | ( 0x01 << n ) ) or ( self.ledGreen & ( ~( 0x01 << 1 ) ) )
		self.newData  = true
	end
end
function KeyPad8:setLedBlue( state, n )
	if ( ( type( n ) == number ) and ( type( state ) == boolean ) ) then
		self.ledBlue = ( state ) and ( self.ledBlue | ( 0x01 << n ) ) or ( self.ledBlue & ( ~( 0x01 << 1 ) ) )
		self.newData = true
	end
end
----------------------------------------------------------------------------------------------------------------------
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
	local obj = nil
	if ( ( type( inMin ) == number ) and 
			 ( type( inMax ) == number ) and 
			 ( type( inReload ) == boolean ) ) then
		obj = { counter = 0, min = inMin, max = inMax, reload = inReload }
		setmetatable( obj, self )
	end
	return obj
end
function Counter:process ( inc, dec, rst )
	if ( inc == true ) then
		if ( self.counter < self.max ) then
			self.counter = self.counter + 1
		elseif ( self.reload == true ) then
			self.counter = self.min
		end
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
----------------------------------------------------------------------------------------------------------------------
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