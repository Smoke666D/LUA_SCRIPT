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
delayms = 0
DInput = { flase,true,flase,flase,flase,flase,flase,flase,flase,flase,flase,flase}



function Yield ()
	delayms = coroutine.yield(Out20,Out19,Out18,Out17,Out16,Out15,Out14,Out13,Out12,Out11,Out10,Out9,Out8,Out7,Out6,Out5,Out4,Out3,Out2,Out1)	
end
function getDelay()
	return delayms
end     
function getDIN( ch)
	return DInput[ch]	
end


function setOut( channel, state)
	if channel == 1 then
	Out1 = state;	
	elseif channel == 2 then
	Out2 = state;	
	elseif channel == 3 then
	Out3 = state;
	elseif channel == 4 then
	Out4 = state;
	elseif channel == 5 then
	Out5 = state;
	elseif channel == 6 then
	Out6 = state;
	elseif channel == 7 then
	Out7 = state;
	elseif channel == 8 then
	Out8 = state;
	elseif channel == 9 then
	Out9 = state;
	elseif channel == 10 then
	Out10 = state;
	elseif channel == 11 then
	Out11 = state;
	elseif channel == 12 then
	Out12 = state;
	elseif channel == 13 then
	Out13 = state;
	elseif channel == 14 then
	Out14 = state;
	elseif channel == 15 then
	Out15 = state;
	elseif channel == 16 then
	Out16 = state;
	elseif channel == 17 then
	Out17 = state;
	elseif channel == 18 then
	Out18 = state;
	elseif channel == 19 then
	Out19 = state;
	elseif channel == 20 then
	Out20 = state;
	end
end
