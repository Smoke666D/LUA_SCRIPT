Counter = {}
Counter.__index = Counter
function Counter:new ( inMin, inMax, inDefault, inReload )
	local obj = { 		counter =  inDefault,
						min     = inMin,
						max     = inMax,
						reload 	=  inReload,
						def    	= inDefault,
						old    	= false,
						oldrst 	= false
		   }
	setmetatable( obj, self )
	return obj
end
function Counter:process ( inc, dec, rst )
		if ( inc == true ) then
			if (  self.old  == false )  then
				if ( self.counter < self.max ) then
					self.counter = self.counter + 1
				elseif ( self.reload == true ) then
					self.counter = self.min
				end
			end
		end
		if ( dec == true ) then
			if (  self.old  == false )  then
				if ( self.counter > self.min ) then
					self.counter = self.counter - 1
				elseif ( self.reload == true ) then
					self.counter = self.max
				end
			end
		end
		if ( rst == true ) then
			if (  self.oldrst  == false )  then
				self.counter = self.def
			end
		end
		self.old    =  ( inc or dec ) and true or false
		self.oldrst =   rst and true or false
	
	return
end
function Counter:set( state )
	if ( state >=self.min ) and ( state <=self.max ) then
		self.counter = state
	end
end
function Counter:get ()
	return self.counter
end