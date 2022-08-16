CanInput = {
}
CanInput.__index = CanInput
function CanInput:new ( addr )
  local obj = { 
    ADDR = addr, 
    data={
      [1]=0,
      [2]=0,
      [3]=0,
      [4]=0,
      [5]=0,
      [6]=0,
      [7]=0,
      [8]=
      0}
    }
  setmetatable( obj, self )
  setCanFilter(addr)
  return obj
end
function CanInput:process()
  GetCanToTable( self.ADDR,self.data)
end
function CanInput:getBit( nb, nbit)
  return ((self.data[nb] & (0x01<<(nbit-1))) >0 ) and true or false
end