
delayms = 0
DOut =  { [1] = false,[2] = false,[3] = false,[4] = false,[5] = false,[6] = false,[7] =false,[8] =false,[9] =false,[10] =false,[11] = false,[12] =false,[13]=false,[14] =false,[15] =false,[16]=false,[17]=false,[18]= false,[19]=false,[20]=false}
DInput = { [1]=false,[2]=false,[3]=false,[4]=false,[5]=false,[6]=false,[7]=false,[8]=false,[9]=false,[10]=false,[11]=false}
Cur = {[1]= 0, [2]=0, [3]=0,[4]= 0,[5]= 0, [6]=0, [7]=0, [8]=0, [9]=0, [10]=0, [11]=0,[12]= 0,[13]= 0, [14]=0, [15]=0, [16]=0,[17]= 0,[18]= 0, [19]=0,[20]= 0 }
function Yield ()
	delayms,DInput[1],DInput[2],DInput[3],DInput[4],DInput[5],DInput[6],DInput[7],DInput[8],DInput[9],DInput[10],DInput[11],Cur[1],Cur[2],Cur[3],Cur[4],Cur[5],Cur[6],Cur[7],Cur[8],
Cur[9],Cur[10],Cur[11],Cur[12],Cur[13],Cur[14],Cur[15],Cur[16],Cur[17],Cur[18],Cur[19],Cur[20] = coroutine.yield(DOut[20],DOut[19],DOut[18],DOut[17],DOut[16],
DOut[15],DOut[14],DOut[13],DOut[12],DOut[11],DOut[10],DOut[9],DOut[8],DOut[7],DOut[6],DOut[5],DOut[4],DOut[3],DOut[2],DOut[1])
delayms = delayms/100
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
	local del = 0
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
end