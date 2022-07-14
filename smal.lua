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