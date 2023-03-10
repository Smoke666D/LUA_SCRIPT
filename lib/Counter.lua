Counter = {}
Counter.__index = Counter
function Counter:new ( inMin, inMax, inDefault, inReload )
	local obj = { 		counter =  inDefault,
						min = inMin,
						max = inMax,
						reload =  inReload,
						def = inDefault,
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
				self.counter = self.def
			end
		end
		self.old =   (rst or inc or dec ) and true or false
	end
	return
end
function Counter:get ()
	return self.counter
end