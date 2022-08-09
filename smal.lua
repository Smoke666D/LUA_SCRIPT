CanOut = {}
CanOut.__index = CanOut
function CanOut:new ( inp )
	local obj = { timer = inp }
	setmetatable( obj, self )
	return obj
end
Foo = {}
Foo.__index = Foo
function Foo:new ( boo )
  local obj = nil
  if ( type( boo ) == number ) then
    obj =  { param = boo, her = 2 }
  end
  setmetatable( obj, self )
  return obj
end
function Foo:process ( some )
  self.param = some
  self.her   = self.her + 1
end