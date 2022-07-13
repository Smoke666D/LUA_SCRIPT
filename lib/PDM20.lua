Out1 = true 
Out2 = false 
Out3 = false 
Out4 = false 
Out5 = false 
Out6 = false 
Out7 = false 
Out8 = false 
Out9 = false 
Out10 = false
Out11 = false 
Out12 = false 
Out13 = true 
Out14 = false 
Out15 = false 
Out16 = false 
Out17 = false 
Out18 = false 
Out19 = false 
Out20 = false 
delay = 0



function Yield ()
	delay = coroutine.yield(Out20,Out19,Out18,Out17,Out16,Out15,Out14,Out13,Out12,Out11,Out10,Out9,Out8,Out7,Out6,Out5,Out4,Out3,Out2,Out1)	
end
function getDelay()
	return delay
end     