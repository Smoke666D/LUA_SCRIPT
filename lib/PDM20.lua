
delayms = 0
DOut =  { flase,true,flase,flase,flase,flase,flase,flase,flase,flase,flase,flase,flase,flase,flase,flase,flase,flase,flase,flase}
DInput = { flase,true,flase,flase,flase,flase,flase,flase,flase,flase,flase}

Cur = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }



function Yield ()
	delayms,DInput[1],DInput[2],DInput[3],DInput[4],DInput[5],DInput[6],DInput[7],DInput[8],DInput[9],DInput[10],DInput[11],Cur[1],Cur[2],Cur[3],Cur[4],Cur[5],Cur[6],Cur[7],Cur[8],
Cur[9],Cur[10],Cur[11],Cur[12],Cur[13],Cur[14],Cur[15],Cur[16],Cur[17],Cur[18],Cur[19],Cur[20] = coroutine.yield(DOut[20],DOut[19],DOut[18],DOut[17],DOut[16],
DOut[15],DOut[14],DOut[13],DOut[12],DOut[11],DOut[10],DOut[9],DOut[8],DOut[7],DOut[6],DOut[5],DOut[4],DOut[3],DOut[2],DOut[1])	
end
function boltoint( data)
   return (data) and 1 or 0
end


function getDelay()
	return delayms
end     
function getDIN( ch)
	return (ch<11) and DInput[ch] or false 
end

function igetDIN( ch)	
	return (ch<11) and boltoint(DInput[ch]) or 0
end

function getCurrent( ch )
	return Cur[ch] 
end

function getCurFB( ch )
	return (Cur[ch]//1)
end
function getCurSB( ch )
  return (Cur[ch]*100)%100//1
end
function setOut( ch, data)
	if ch <=20 then
		DOut[ch] = data;			
	end
end

function waitDIN( ch, data, timeout)
	del = 0
   	while true do		
		 Yield()
		 if getDIN(ch) == data then
			return true
		 end
		 del = del + delayms
		 if (timeout > 0) then
		    if (del > timeout) then
			return false
		    end
 		 end 
	end
	return false
end

