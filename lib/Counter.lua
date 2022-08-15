Counter = {}
Counter.__index = Counter
function Counter:new ( inMin, inMax, inDefault, inReload )
	local obj = { 				counter = (type(inDefault) == "number") and inDefault or 0,
						min = (type(inMin) == "number") and inMin or 0,
						max = (type(inMax) == "number") and inMax or 0xFFFF,
						reload = (type(inReload) == "boolean") and inReload or true,
						old = false
		   }
	setmetatable( obj, self )
	return obj
end
function Counter:process ( inc, dec, rst )
	if (type(inc) == "boolean") and (type(dec) == "boolean") and (type(rst) == "boolean") then
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
			if (  self.old  == false )  then
				self.counter = self.min
			end
		end
		self.old =   (rst or inc or dec ) and true or false
	end
	return
end
function Counter:get ()
	return self.counter
end