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
		system.canSetFilter( 0x180 + addr )
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
		system.canSend( ( 0x215 + adr ), ledRed, ledGreen, ledBlue, 0x00, 0x00, 0x00, 0x00, 0x00 )
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