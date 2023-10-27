--Библиотека CAN
EXT_CAN_ID = 0x80000000
-- Объекты СanIput. Cозадется с помощью метода :new( id пакета, время обновления данных , битовая маска, указывающая какие байты из фрема забирать, )
--
CanInput = {}
CanInput.__index = CanInput
function CanInput:new ( addr )
	local obj = { ADDR = addr, eneb = 0,
		     data={[1]=0,[2]=0,[3]=0,[4]=0,[5]=0,[6]=0,[7]=0,[8]=0},		    
		    }
	setmetatable( obj, self )
    setCanFilter(addr)
	return obj
end
function CanInput:process()
	if ( GetCanToTable( self.ADDR,self.data) == 1 ) then
		self.eneb = 1
	end
    return  self.eneb
end
function CanInput:getBit( nb, nbit)
	return ((self.data[nb] & (0x01<<(nbit-1))) >0 ) and true or false
end
function CanInput:getByte( nb )
	return self.data[nb]
end
function CanInput:getWordLSB( nb )
	return (nb < 7) and ( self.data[nb] | self.data[nb+1]<<8) or 0
end
function CanInput:getWordMSB( nb )
	return (nb < 7) and ( self.data[nb]<<8 | self.data[nb+1]) or 0
end
CanOut = {}
CanOut.__index = CanOut
function CanOut:new ( addr , time , size, d1, d2, d3, d4, d5, d6, d7, d8)
	local obj = { ADDR = addr,
		      data = { [1]= (d1 ~= nil) and d1 or 0,
			       [2]= (d2 ~= nil) and d2 or 0,
			       [3]= (d3 ~= nil) and d3 or 0,
			       [4]= (d4 ~= nil) and d4 or 0,
			       [5]= (d5 ~= nil) and d5 or 0,
			       [6]= (d6 ~= nil) and d6 or 0,
			       [7]= (d7 ~= nil) and d7 or 0,
			       [8]= (d8 ~= nil) and d8 or 0,
			},
			delay = ( time ~= nil ) and time or 100,
			timer = 0,
			sz = ( size ~= nil) and size or 8
			}
	setmetatable( obj, self )
	return obj
end
function CanOut:process()
    self.timer = self.timer + getDelay()
    if self.timer >=  self.delay then
	  CanTable(self.ADDR,self.sz,self.data)
          self.timer	= 0
    end
end
function CanOut:setFrame(...)
	local arg =  table.pack(...)
	if (arg.n < 9) then
		for i=1, arg.n do
			self.data[i] = arg[i]
		end
		self.sz = arg.n
	end
end
function CanOut:setBit( nb, nbit, state)
	if state == true then
		self.data[nb] = self.data[nb] | (0x01 << (nbit-1))
	else
		self.data[nb] = self.data[nb] & ~(0x01 << (nbit-1))
	end
end
function CanOut:setByte( nb ,state )
	self.data[nb] = state  & 0xFF
end
function CanOut:setWord( nb ,state)
	self.data[nb] = (state <<8) & 0xFF
        self.data[nb+1] = state & 0xFF
end
CanRequest = {}
CanRequest.__index = CanRequest
function CanRequest:new()
	local obj = { del = 0, timeout =0, data = {[1]=0,[2]=0,[3]=0,[4]=0,[5]=0,[6]=0,[7]=0,[8]=0}}
	setmetatable( obj, self )
	return obj
end
function CanRequest:waitCAN( add, getadd, timeout, d1,d2,d3,d4,d5,d6,d7,d8)
	self.del = 0
        sendCandRequest(add,getadd,d1,d2,d3,d4,d5,d6,d7,d8)
	while true do
		Yield()
		if CheckAnswer() == 1 then
			self.data[1],self.data[2],self.data[3],self.data[4],self.data[5],self.data[6],self.data[7],self.data[8] = GetRequest()
			return true
		end
		self.del = self.del + delayms
		if (self.timeout > 0) then
			if (self.del > timeout) then
				return false
			end
		end
	end
end
function CanRequest:getData()
	return self.data[1],self.data[2],self.data[3],self.data[4],self.data[5],self.data[6],self.data[7],self.data[8]
end
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
Dashboard = {}
Dashboard.__index = Dashboard
function Dashboard:new( addr, time)
      local obj = { ADDR = addr, repeat_time= time, counter = 0}
      setmetatable (obj, self)
      return obj
end

function Dashboard:process()
	self.counter = self.counter + getDelay()
	if self.counter > self.repeat_time then
		self.counter = 0
		
		
	    CanSend( self.ADDR      ,getCurLSB10(1),getCurMSB10(1),getCurLSB10(2),getCurMSB10(2),getCurLSB10(3),getCurMSB10(3),getCurLSB10(4),getCurMSB10(4))
		CanSend( self.ADDR +1   ,getCurLSB10(5),getCurMSB10(5),getCurLSB10(6),getCurMSB10(6),getCurLSB10(7),getCurMSB10(7),getCurLSB10(8),getCurMSB10(8))
		CanSend( self.ADDR +2   ,getCurLSB10(9),getCurMSB10(9),getCurLSB10(10),getCurMSB10(10),getCurLSB10(11),getCurMSB10(11),getCurLSB10(12),getCurMSB10(12))
		CanSend( self.ADDR +3   ,getCurLSB10(13),getCurMSB10(13),getCurLSB10(14),getCurMSB10(14),getCurLSB10(15),getCurMSB10(15),getCurLSB10(16),getCurMSB10(16))
	    CanSend( self.ADDR +4   ,getCurLSB10(17),getCurMSB10(17),getCurLSB10(18),getCurMSB10(18),getCurLSB10(19),getCurMSB10(19),getCurLSB10(20),getCurMSB10(20))
		CanSend( self.ADDR +5   ,getBatLSB10(),getBatMSB10(),getTemp(),0,0,0,0,0)
		CanSend( self.ADDR +6  ,
								getOutStatus(1)  | (getOutStatus(2)<<3) | ((getOutStatus(3) & 0x03)<<6) ,
							    (getOutStatus(3)>>2) | (getOutStatus(4)<<1) | (getOutStatus(5)<<4) | ((getOutStatus(6) & 0x01)<<7),
							   ((getOutStatus(6)>>1) & 0x03) | (getOutStatus(7)<<2) | (getOutStatus(8)<<5) ,
								 getOutStatus(9)  | (getOutStatus(10)<<3)   |  ((getOutStatus(11) & 0x03)<<6) ,
								 
								 
								 getOutStatus(12)  | (getOutStatus(13)<<3)   |  ((getOutStatus(14) & 0x03)<<6) ,
							    (getOutStatus(14)>>2) | (getOutStatus(15)<<1) | (getOutStatus(16)<<4) | ((RIGHT_TO_CAN & 0x01)<<7),
							 ((RIGHT_TO_CAN >>1) & 0x03) | (LEFT_TO_CAN <<2) | (getOutStatus(19)<<5) ,
								 getOutStatus(20)  | ((getOutStatus(11)>>2)<<3)
										)
										
		
	end
end



Delay = {}
Delay.__index = Delay
function Delay:new ( inDelay , pulse)
	local obj  = { counter = 0, launched = false, output = false, delay = inDelay ,  mode = pulse, satate = false}
	setmetatable( obj, self )
	return obj
end
function Delay:process ( start, disable )
    
	if start then
	  if self.launched == false then
		self.launched = true
		self.counter = 0
	  end
	  if self.launched == true then
	    self.counter = self.counter + getDelay()
		if self.counter > self.delay then		 			
		  self.state = true
		  if self.mode == true then
		   self.counter = 0
		  end		  
		else
		 self.state = false
		end				
	  end		
	else
	   self.launched = false
	end
	self.launched = self.launched and (not disable)
	self.output = self.state and start and (not disable)
	return self.output
end
function Delay:process_delay( start )
	if start then
	    self.counter = self.counter + getDelay()
		if self.counter > self.delay then		 			
		  self.output = true		  
		else
		 self.output = false
		end				
    else
	  self.counter = 0
	  self.output = false
	end
end
function Delay:get ()
	return self.output
end

KeyPad15 = {}
KeyPad15.__index = KeyPad15
function KeyPad15:new( addr)
      local obj = {key = 0x00, ADDR = addr, new = true, alive =false, tog= 0x00, old =0x00, ledRed=0x00,ledGreen=0x00, ledBlue =0x00, temp={[1]=0,[2]=0}, backligth = 0, led_brigth = 0, back_color = 0x07}	  
      setmetatable (obj, self)
	  
      setCanFilter(0x180 +addr)
	  setCanFilter(0x700 +addr)
      return obj
end
function KeyPad15:process()
	if (GetCanToTable(0x180 + self.ADDR,self.temp) ==1 ) then
	    local t =  self.temp[2]<<8 | self.temp[1]
		self.tog = (~ self.key & t) ~ self.tog
		self.key = t
	end
	if (GetCanToTable(0x700 +self.ADDR,self.temp ) == 1 ) then
	   if ( self.temp[0]~= 0x05 ) then
	    CanSend( 0x00, 0x01, self.ADDR,0,0,0,0,0,0)
	   end
	   self.new = true
	end
	if self.new == true then
		self.new = false		
		CanSend(0x500 + self.ADDR,self.backligth,self.back_color,0,0,0,0,0,0)
		CanSend(0x200 + self.ADDR,self.ledRed & 0xFF, self.ledRed>>8, self.ledGreen & 0xFF,self.ledGreen>>8,self.ledBlue & 0xFF ,self.ledBlue >>8,0,0)
	end
end
function KeyPad15:getKey( n )
	  return  (self.key & ( 0x01 << ( n - 1 ) ) ) ~= 0
end
function KeyPad15:getToggle( n )

         return  (self.tog & ( 0x01 << ( n - 1 ) ) ) ~= 0
end
function KeyPad15:resetToggle( n , state)
	 if state == true then
		 self.tog =  (~(0x01<< ( n-1 ) )) & self.tog
	 end
end
function KeyPad15:setToggle( n )	 
		 self.tog =  (0x01<< ( n-1 ) ) | self.tog	 
end
function KeyPad15:setLedRed( n , state)
	self.old = (state ) and  self.ledRed | (0x01<<(n-1)) or self.ledRed & (~(0x01<<( n-1 )))
	if ( self.old ~= self.ledRed ) then
		self.ledRed = self.old
		self.new = true
	end
end
function KeyPad15:setLedGreen( n, state)
	self.old = (state ) and self.ledGreen | (0x01<<(n-1)) or self.ledGreen & (~(0x01<<( n-1 )))
	if ( self.old ~= self.ledGreen ) then
		self.ledGreen = self.old
		self.new = true
	end
end
function KeyPad15:setLedBlue( n , state)
	self.old = (state ) and  self.ledBlue | (0x01<<(n-1)) or self.ledBlue & (~(0x01<<( n-1 )))
	if ( self.old ~= self.ledBlue ) then
		self.ledBlue = self.old
		self.new = true
	end
end
function KeyPad15:setLedWhite( n , state)
	self:setLedBlue(n, state)
	self:setLedGreen(n, state)
	self:setLedRed(n, state)
end
function KeyPad15:setLedBrigth( brigth )
	if (self.ledbrigth ~= brigth) then
		self.ledbrigth = brigth
		CanSend(0x400 + self.ADDR,brigth,0,0,0,0,0,0,0)
	end 
end
function KeyPad15:setBackLigthBrigth( brigth )
	self.old = brigth
	if (self.old ~= self.backlight) then
		self.backligth =self.old
		self.new = true
		--CanSend(0x600 + self.ADDR,0x2F,0x03,0x20,0x02,self.backligth,0,0,0)
	end
end


delayms = 0
ROLL = 0
PITCH = 0
YAW = 0
TEMP_SENSOR = 0
DOut =  { [1] = false,[2] = false,[3] = false,[4] = false,[5] = false,[6] = false,[7] =false,[8] =false,[9] =false,[10] =false,[11] = false,[12] =false,[13]=false,[14] =false,[15] =false,[16]=false,[17]=false,[18]= false,[19]=false,[20]=false}
DInput = { [1]=false,[2]=false,[3]=false,[4]=false,[5]=false,[6]=false,[7]=false,[8]=false,[9]=false,[10]=false,[11]=false}
DOUTSTATUS = { [1]=0,[2]=0}
LEFT_TO_CAN = 0
RIGHT_TO_CAN = 0
DIN = 0
RPM = { [1] = 0,[2] =0 }
Cur = {[1]= 0, [2]=0, [3]=0,[4]= 0,[5]= 0, [6]=0, [7]=0, [8]=0, [9]=0, [10]=0, [11]=0,[12]= 0,[13]= 0, [14]=0, [15]=0, [16]=0,[17]= 0,[18]= 0, [19]=0,[20]= 0 }
AIN = {[1]= 0, [2]=0, [3]=0, [4] =0,[5] =0, [6] = 0,[7] =0, [8]= 0, [9] = 0, [10] = 0, [11] = 0, [12] = 0, [13] = 0}
function Yield ()

	delayms,DOUTSTATUS[1],DOUTSTATUS[2],DIN ,Cur[1],Cur[2],Cur[3],Cur[4],Cur[5],Cur[6],Cur[7],Cur[8],
Cur[9],Cur[10],Cur[11],Cur[12],Cur[13],Cur[14],Cur[15],Cur[16],Cur[17],Cur[18],Cur[19],Cur[20],RPM[1],RPM[2], AIN[1], AIN[2],AIN[3],AIN[4],
AIN[5],AIN[6],AIN[7],AIN[8],AIN[9],AIN[10],AIN[11],AIN[12],
 ROLL, PITCH, YAW, TEMP_SENSOR = coroutine.yield(DOut[20],DOut[19],DOut[18],DOut[17],DOut[16],
DOut[15],DOut[14],DOut[13],DOut[12],DOut[11],DOut[10],DOut[9],DOut[8],DOut[7],DOut[6],DOut[5],DOut[4],DOut[3],DOut[2],DOut[1])
delayms = delayms/100
end
function getROLL()
 return ROLL
end
function getPITCH()
 return PITCH
end
function getYAW()
 return YAW
end
function getBat()
 return AIN[12]
end
function getAin(ch)
 return ( ch<12 ) and AIN[ch] or 0
end
function getRPM( ch)
  return (ch==1) and RPM[1] or RPM[2]
end

function getTemp()
 return (TEMP_SENSOR//1)
end


function getOutStatus( ch )
   if ch <11 then
	return (DOUTSTATUS[1] >> (ch-1)*3) & 0x07
   elseif ch <=20 then
	return (DOUTSTATUS[2] >> (ch-11)*3) & 0x07
   end
--     return DOut[ch] == true and 0x01 or 0x00
end
function boltoint( data)
   return (data) and 1 or 0
end
function getDelay()
	return delayms
end
function getDIN( ch )
	if (ch <= 11 ) then
	   return ( ( ( DIN >> (ch-1) ) & 0x01) == 1 ) or true and false
	else
	  return false
	end
--	return (ch<11) and DInput[ch] or false
end
function igetDIN( ch)
	if ch <= 11 then
	   return ((DIN >> (ch-1)) & 0x1)
	else
	  return 0
	end
--	return (ch<11) and boltoint(DInput[ch]) or 0
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
function getCurLSB10( ch )
	return (((Cur[ch]*10)//1) & 0xFF )
end
function getCurMSB10( ch )
	return  (( Cur[ch]*10//1 ) >>8 )
end
function getBatLSB10(  )
	return (((AIN[12]*10)//1) & 0xFF )
end
function getBatMSB10(  )
	return  (( AIN[12]*10//1 ) >>8 )
end
function setOut( ch, data)
	if ch <=20 then
		DOut[ch] = data;
	end
end
function getOut( ch )
	return DOut[ch]
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
Pillow = {}
Pillow.__index = Pillow
function Pillow:new ( N , all_N, outOn, outOFF)
	local obj = {  air = 0.0, height = 0.0, number = N, total = all_N , timer = 0, mode = 3, OO =outOn, OF = outOFF,
	state = 1, SA = 0.0, SH = 0.0 , SA10 = 0.0, SH10 = 0.0,  SA5=0.0, SH10 = 0.0, SetAir = 0} 
	setmetatable( obj, self )
	return obj
end
function Pillow:setData( AirData, HData)
	self.air = AirData
	self.height = HData
end
function Pillow:manualControl( On , Off )
   setOut(self.OO, On  )
   setOut(self.OF, Off )  
end
function Pillow:Calibrate( mode )
	SetEEPROMReg(1 + 2 * self.number + self.total * 2 * mode ,self.height)
	SetEEPROMReg(2 + 2 * self.number + self.total * 2 * mode, self.air)
   --slef.mode = 3
end
function Pillow:process( mode, control_type )
  if self.mode ~= mode then
     self.mode = mode
	 self.timer = 0
	 self.SH =  GetEEPROMReg(1+ 2 * self.number + self.total * 2 * mode )
	 self.SA =  GetEEPROMReg(2+ 2 * self.number + self.total * 2 * mode )
	 self.SA5  = self.SA*0,05
	 self.SH5  = self.SH*0,05
	 self.SA10 = self.SA*0,1
     self.SH10 = self.SH*0,1
  end
  self.state = 0
  local DATA  = ( control_type ) and self.air  or self.height
  local EDATA = ( control_type ) and self.SA   or self.SH
  local D10   = ( control_type ) and self.SA10 or self.SH10
  local D5    = ( control_type ) and self.SA5  or self.SH5
  local res = 0
  local UP   = false
  local DOWN = false
  local dir = 0
  local delta = DATA - EDATA
  local absdelta = math.abs( delta )
  if (delta < 0 ) then
	dir = 1
  end
  if (absdelta > D10)  then  
	self.state = ( dir == 1 ) and 4 or 3
  else
	if ( absdelta > D5 ) then 
		self.state = ( dir == 1) and 2 or 1 
	end
  end
  if self.state == 0 then 
	res = 1
  else
	if ( (self.state == 1) or (self.state == 2) )then
	  self.timer = self.timer + getDelay()
	  if self.timer > 500 then
		if self.timer < 700 then
		    UP   =  (self.state == 2 ) and true or false
			DOWN =  ( self.state == 1 ) and true or false
		else
			self.timer = 0
	    end 
	  end
	else
	  DOWN = (self.state == 3) and true or false  --спускаем
	  UP   = (self.state == 4) and true or false  --надуваем
	end
   end
   setOut(self.OO, UP  )
   setOut(self.OF, DOWN )
   return res
end
function Pillow:getEEPROMAir( mode )
	return GetEEPROMReg(2+ 2 * self.number + self.total * 2 * mode )

end

function Pillow:process_set_air( air  )
  if self.SetAir ~= air then
   self.SA5  = self.air*0,05
   self.SA10 = self.air*0,1
   self.SetAir = air
   self.timer = 0
  end 
  self.state = 0
  local UP   = false
  local DOWN = false
  local res = 0
  local dir = 0
  local delta = self.air - air
  local absdelta = math.abs(delta)
  if delta < 0 then
	dir = 1
  end
  if (absdelta > self.SA10)  then  
	self.state = ( dir == 1 ) and 4 or 3
  else
	if ( absdelta > self.SA5 ) then 
		self.state = ( dir == 1) and 2 or 1 
	end
  end
  if self.state == 0 then 
	res = 1
  else
	if ( (self.state == 1) or (self.state == 2) )then
		self.timer = self.timer + getDelay()
		if self.timer > 500 then
			if self.timer < 700 then
				UP   =  (self.state == 2 ) and true or false
				DOWN = ( self.state == 1 ) and true or false
			else
				self.timer = 0
			end 
		end
	else
	  DOWN = (self.state == 3) and true or false  --спускаем
	  UP   = (self.state == 4) and true or false  --надуваем
	end
   end
   setOut(self.OO, UP  )
   setOut(self.OF, DOWN )
   return res
end

LSFAir = 1
RSFAir = 2
LSBAir = 3
RSBAir = 4
LMFAir = 5
RMFAir = 6
LMBAir = 7
RMBAir = 8
LPullAir = 9
RPullAir = 10
MainAir = 11
--сервисная функция инициализации
function init()
	ConfigCan(1,500)  -- конфигурация скорости CAN
	setOutConfig(1,2) -- насройка номнальных токов для каналов управления
	setOutConfig(2,2)
	setOutConfig(3,2)
	setOutConfig(4,2)
	setOutConfig(5,2)
	setOutConfig(6,2)
	setOutConfig(7,2)
    setOutConfig(8,2)
    setOutConfig(9,2)
    setOutConfig(10,2)
	setOutConfig(11,2)
	setOutConfig(12,2)
    setOutConfig(13,2)
    setOutConfig(14,2)
	setOutConfig(15,2)
	setOutConfig(16,2)
	setOutConfig(17,2)
	setOutConfig(18,2)
	setOutConfig(19,2)
	setOutConfig(20,2)
    -- установка калиборвочных значений для датчиков давления на аналоговые входа
	setAINCalTable(1,10,0,184,10)
    setAINCalTable(2,10,0,184,10)
    setAINCalTable(3,10,0,184,10)
    setAINCalTable(4,10,0,184,10)
	setAINCalTable(5,10,0,184,10)
    setAINCalTable(6,10,0,184,10)
    setAINCalTable(7,10,0,184,10)
    setAINCalTable(8,10,0,184,10)
	setAINCalTable(9,10,0,184,10)
    setAINCalTable(10,10,0,184,10)
    setAINCalTable(11,10,0,184,10)
	--конфигурация хранилища данных
   ConfigStorage(0,62,0x00,0x01,0x03,0x03)
	--отправка конфигурационного пакета в кавиатуру, для перевода ее в рабочий режим
   CanSend(0x00,0x01,0x15,0x00,0x00,0x00,0x00,0x00,0x00)
end

--главная функция
LSF   		= Pillow:new(0, 10 , 1, 2)
RSF   		= Pillow:new(1, 10 , 3, 4)
LSB   		= Pillow:new(2, 10 , 5, 6)
RSB   		= Pillow:new(3, 10 , 7, 8)
LMF   		= Pillow:new(4, 10 , 9, 10)
RMF   		= Pillow:new(5, 10 , 11, 12)
LMB   		= Pillow:new(6, 10 , 13, 14)
RMB   		= Pillow:new(7, 10 , 15, 16)
LPull   	= Pillow:new(8, 10 , 17, 18)
RPull  		= Pillow:new(9, 10 , 19, 20)
LSState = 0 --переменная текущего состояния падушек левой стороны
RSState = 0
LSBDir = 0
LSFDir = 0
lsTimer = 0
rsTimer = 0
function LeftVlaveOff()
	LSF:manualControl(false,false)
	LSB:manualControl(false,false)
	LMF:manualControl(false,false)
	LMB:manualControl(false,false)
	LPull:manualControl(false,false)

end
function RightValveOff()
	RSF:manualControl(false,false)
	RSB:manualControl(false,false)
	RMF:manualControl(false,false)
	RMB:manualControl(false,false)
	RPull:manualControl(false,false)

end


function ValveOff()  --фуеция выключения всех клапанов
	LeftVlaveOff()
	RightValveOff()
end

function BeginLeftSide()
 LSState = 0
end
function BeginRightSide()
 RSState = 0
end

function LeftSideIDLE( mode_front, mode_back, control_type )
	LSF:process(2,true)
	LSB:process(2,true)	
	LMF:process(mode_front,control_type)		
	LMB:process(mode_back,control_type)		
	LPull:process(2,true)
end
function RigthSideIDLE( mode_front, mode_back, control_type )
	RSF:process(2,true)
	RSB:process(2,true)
	RMF:process(mode_front,control_type)
	RMB:process(mode_back,control_type)
	RPull:process(2,true)

end


function LeftSide( mode_front, mode_back, control_type )
    local res = 0
	if LSState == 0 then  --входим в переходный процес
	    LeftVlaveOff()		  --выключаем клапана и определяем куда нужно качать переднюю и зандюю главные подушки
		if control_type == true  then  -- если управление по давлению
			if  ( LMF:getAir() < LMF:getEEPROMAir(mode_front) ) then LSFDir = 1 end  -- определяем в какую стоону качать
			if  ( LMB:getAir() < LMB:getEEPROMAir(mode_back) )  then LSBDir = 1 end
		else						   -- если управление по высоте
			if  ( LMF:getHeight()< LMF:getEEPROMHeight(mode_front) ) then LSFDir = 1 end
			if  ( LMB:getHeight()< LMB:getEEPROMHeight(mode_back) )  then LSBDir = 1 end
		end
	    LSState = 1
	elseif LSState == 1 then --убеждаемся что стабилизаторы в максимальном давлении	
		if (( LSF:process( 2, true ) == 1) and ( LSB:process( 2, true ) == 1)) then --убеждаемся что стабилизаторы в макс высоте
			LSState = 2
		end
	
	elseif LSState == 2 then
		 if ((LSFDir == 1) or (LSBDir == 1)) then         -- если нужно качать какую то из главных подушек
			if ( LPull:process_set_air( LPull:getEEPROMAir(2) * 0,7 ) == 1) then
				LSState = 3
			end
		 end
	elseif LSState == 3 then
	      local ready = true
		  if ( LSFDir == 1 ) then ready = ready and (LMF:process(mode,control_type)==1) end
		  if ( LSBDir == 1 ) then ready = ready and (LMB:process(mode,control_type)==1) end     
		  if ( ready == true ) then
			LSState = 4
		  end
	elseif LSState == 4 then
		lsTimer = lsTimer + getDelay()
		if lsTimer > 5000 then
			LSSatate = 5
			LPull:manualControl(false,false)
		else
			LPull:manualControl(true,false)
		end
	elseif LSState == 5 then
		if (( LSFDir == 0 ) or ( LSBDir == 0 )) then 
		   LPull:manualControl(true,false)
		   LSState = 6
		else 
		   LSState = 8
		end
	elseif LSState == 6 then
		  local ready = true
		  if ( LSFDir == 0 ) then ready = ready and (LMF:process(mode,control_type)==1) end
		  if ( LSBDir == 0 ) then ready = ready and (LMB:process(mode,control_type)==1) end     
		  if ( ready == true ) then
			LSState =7
		  end
	elseif LSSatate ==7 then
	    if (LSFDir== 0) or (LSBDir == 0) then 
			lsTimer = lsTimer + getDelay()
			if lsTimer > 5000 then
				LSSatate = 8
				LPull:manualControl(false,false)
			else
				LPull:manualControl(true,false)
			end
		else
			LSSatate = 8
		end
	elseif LSState == 8 then
		res = 1
	end
	return res
end



function RigthSide( mode_front, mode_back, control_type)
    local res = 0
	if RSState == 0 then  --входим в переходный процес
	    RightValveOff()		  --выключаем клапана и определяем куда нужно качать переднюю и зандюю главные подушки
		if control_type == true  then  -- если управление по давлению
			if  ( RMF:getAir() < RMF:getEEPROMAir(mode_front) ) then RSFDir = 1 end  -- определяем в какую стоону качать
			if  ( RMB:getAir() < RMB:getEEPROMAir(mode_back) )  then RSBDir = 1 end
		else						   -- если управление по высоте
			if  ( RMF:getHeight()< RMF:getEEPROMHeight(mode_front) ) then RSFDir = 1 end
			if  ( RMB:getHeight()< RMB:getEEPROMHeight(mode_back) )  then RSBDir = 1 end
		end
	    RSState = 1
	elseif RSState == 1 then --убеждаемся что стабилизаторы в максимальном давлении	
		if (( RSF:process( 2, true ) == 1) and ( RSB:process( 2, true ) == 1)) then --убеждаемся что стабилизаторы в макс высоте
			RSState = 2
		end
	
	elseif RSState == 2 then
		 if ((RSFDir == 1) or (RSBDir == 1)) then         -- если нужно качать какую то из главных подушек
			if ( RPull:process_set_air( RPull:getEEPROMAir(2) * 0,7 ) == 1) then
				RSState = 3
			end
		 end
	elseif RSState == 3 then
	      local ready = true
		  if ( RSFDir == 1 ) then ready = ready and (RMF:process(mode,control_type)==1) end
		  if ( RSBDir == 1 ) then ready = ready and (RMB:process(mode,control_type)==1) end     
		  if ( ready == true ) then
			RSState = 4
		  end
	elseif RSState == 4 then
		rsTimer = rsTimer + getDelay()
		if rsTimer > 5000 then
			RSSatate = 5
			RPull:manualControl(false,false)
		else
			RPull:manualControl(true,false)
		end
	elseif RSState == 5 then
		if (( RSFDir == 0 ) or ( RSBDir == 0 )) then 
		   RPull:manualControl(true,false)
		   RSState = 6
		else 
		   RSState = 8
		end
	elseif RSState == 6 then
		  local ready = true
		  if ( RSFDir == 0 ) then ready = ready and (RMF:process(mode,control_type)==1) end
		  if ( RSBDir == 0 ) then ready = ready and (RMB:process(mode,control_type)==1) end     
		  if ( ready == true ) then
			RSState =7
		  end
	elseif RSSatate ==7 then
	    if (RSFDir == 0) or (RSBDir == 0) then 
			rsTimer = rsTimer + getDelay()
			if rsTimer > 5000 then
				RSSatate = 8
				RPull:manualControl(false,false)
			else
				RPull:manualControl(true,false)
			end
		else
			RSSatate = 8
		end
	elseif RSState == 8 then
		res = 1
	end
	return res
end


main = function ()
    init()
    local CanIn         = CanInput:new(0x28)
	local CanToDash  	= CanOut:new(0x29, 100)
	local CanToDash1	= CanOut:new(0x30, 100)
	local CanToDash2	= CanOut:new(0x31, 100)
	local CanToDash3	= CanOut:new(0x32, 100)
    local KeyBoard		= KeyPad15:new(0x15)--создание объекта клавиатура c адресом 0x15 
	local LSFCounter   =  Counter:new(1,4,2,true)
	local RSFCounter   =  Counter:new(1,4,2,true)
	local LSBCounter   =  Counter:new(1,4,2,true)
	local RSBCounter   =  Counter:new(1,4,2,true)
	local LMFCounter   =  Counter:new(1,4,2,true)
	local RMFCounter   =  Counter:new(1,4,2,true)
	local LMBCounter   =  Counter:new(1,4,2,true)
	local RMBCounter   =  Counter:new(1,4,2,true)	
	local LPullCounter   =  Counter:new(1,4,2,true)
	local RPullCounter   =  Counter:new(1,4,2,true)
	local ROLLDelay		 = Delay:new( 5000, false) -- зажержка на фиксацию превышения угла крена выше 30 градусов
	local PITCHDelay    = Delay:new( 5000, false) -- зажержка на фиксацию превышения угла тангажа выше 35 градусов
	local ROLLOVER10Dealy = Delay:new( 5000, false)
	local ROLLOVER20Dealy = Delay:new( 5000, false)
	local PITCHOVER20Delay = Delay:new( 5000, false)
	local PITCHOVER25Delay = Delay:new( 5000, false)
	local SPEEDCounter  = Counter:new(1,3,1,true) 
	local SPEED10Dealy  = Delay:new(5000,false)
	local SPEED20Dealy  = Delay:new(5000,false)
	local SPEED30Dealy  = Delay:new(5000,false)
	local AUTO = false
	local HIGHMODE = 4
	local HIGHMODECAL= false
	local MIDMODECAL = false
	local LOWMODECAL = false
	local calmode = 4
	local ROLLOVER10WARNING = false
	local ROLLOVER20WARNING = false
	local PITCHOVER20WARNING = false
	local PITCHOVER25WARNING = false
    local ROLL =0
	local PITCH = 0
	local MODE = 1
	local CAL_SET = false
	local ROLL_WARNING = false
	local PITCH_WARNING = false
	local SPEED = 0
	local TRANSITION = false
	local LEFT_SIDE_REAR = 0
	local LEFT_SIDE_FRONT = 0
	local RIGTH_SIDE_REAR = 0
	local RIGTH_SIDE_FRONT = 0
	local AUTOMODE = 0
	local UPSTATE = 0
	
	 CanSend(0x00,0x80,0x15,0x00,0x00,0x00,0x00,0x00,0x00)
	--рабочий цикл
	while true do	
		   
		--блок анализа крена и тангажа
	    ROLL = math.abs( GetEEPROMReg(0) - getROLL()   )
		ROLLDelay:process( ( ROLL >= 30 ), ( ROLL < 30 ))
		if ROLLDelay:get() then  -- Если крен выше 30 грдусов в течении времени ROLLDelay
			if (ROLL_WARNING == false)  then 		
				ROLL_WARNING = true					-- выставляем флаг крена, чтобы не повторять запись
													-- по не система не вернется в нормальное положение
				AddReccord( 0x01) 				    -- пишет запись в журнал
			end
		end
		if ( ROLL <= 25 )  then 					--гистерезис 5 градусов для крена
			ROLL_WARNING = false				    --сбрасываем флаг крена, система переходит в нормальное функционирование
		end
		ROLLOVER10Dealy :process( (ROLL>10),( ROLL <=10))  -- если крен привышает 10 градусов в течении ROLLOVER10Dealy 
		if ROLLOVER10Dealy:get() then
			ROLLOVER10WARNING = true
		end
		if ( ROLL <=5 ) then
			ROLLOVER10WARNING = false
		end
		ROLLOVER20Dealy :process( (ROLL>20),( ROLL <=20))  -- если крен привышает 10 градусов в течении ROLLOVER10Dealy 
		if ROLLOVER20Dealy:get() then
			ROLLOVER20WARNING = true
		end
		if ( ROLL <=15 ) then
			ROLLOVER20WARNING = false
		end
	
		PITCH = math.abs (  GetEEPROMReg(1) - getPITCH())
		PITCHDelay:process((PITCH  >= 35 ), (PITCH  < 35 ))
		if PITCHDelay:get() then  -- Если тангаж выше 35 грдусов в течении времени PITCHDelay
			if (PITCH_WARNING == false) then 		
				PITCH_WARNING = true					-- выставляем флаг тангажа
				AddReccord( 0x01) 				    -- пишет запись в журнал
			end
		end
		if ( PITCH  <= 30 )  then --гистерезис 5 градусов для крена
			PITCH_WARNING = false				    -- сбрасываем флаг тангажа
		end
		PITCHOVER20Delay:process((PITCH  >= 20 ), (PITCH  < 20 ))
		if PITCHOVER20Delay:get() then
			if (PITCHOVER20WARNING == false) then 		
				PITCHOVER20WARNING = true					-- выставляем флаг тангажа
			end
		end 
		if ( PITCH  <= 15 )  then --гистерезис 5 градусов для крена
			PITCHOVER20WARNING = false				    -- сбрасываем флаг тангажа
		end	
		PITCHOVER25Delay:process((PITCH  >= 25 ), (PITCH  < 25 ))
		if (PITCHOVER25Delay:get()) then
			if (PITCHOVER25WARNING == false) then 		
				PITCHOVER25WARNING = true					-- выставляем флаг тангажа
			end
		end 
		if ( PITCH  <= 20)  then --гистерезис 5 градусов для крена
			PITCHOVER25WARNING = false				    -- сбрасываем флаг тангажа
		end	
		----конец блок анализа крена и тангажа 
		-- блок обмена данными по CAN
	    CanIn:process()
		local LMFH = CanIn:getWordMSB(1)    -- получение данных о датчиках высоты
		local RMFH = CanIn:getWordMSB(3)
		local LMBH = CanIn:getWordMSB(5)
		local RMBH = CanIn:getWordMSB(7)
		--отправка данных о датчиках давления и стостояии выходных каналов по СAN
		CanToDash:setWord(1, (getAin(LSFAir)*100)//1 )
		CanToDash:setWord(3, (getAin(RSFAir)*100)//1 )
		CanToDash:setWord(5, (getAin(LSBAir)*100)//1 )
		CanToDash:setWord(7, (getAin(RSBAir)*100)//1 )
		CanToDash:process()
		CanToDash1:setWord(1, (getAin(LMFAir)*100)//1 )
		CanToDash1:setWord(3, (getAin(RMFAir)*100)//1 )
		CanToDash1:setWord(5, (getAin(LMBAir)*100)//1 )
		CanToDash1:setWord(7, (getAin(RMBAir)*100)//1 )
		CanToDash1:process()
		CanToDash2:setWord(1, (getAin(LPullAir)*100)//1 )
		CanToDash2:setWord(3, (getAin(RPullAir)*100)//1 )
		CanToDash2:setWord(5, (getAin(MainAir)*100)//1 )
	    CanToDash2:setByte(7, getROLL()//1)
		CanToDash2:setByte(8, getPITCH()//1)
		CanToDash2:process()
		CanToDash3:setBit( 1, 1, getOut(1) )
		CanToDash3:setBit( 1, 2, getOut(2) )
		CanToDash3:setBit( 1, 3, getOut(3) )
		CanToDash3:setBit( 1, 4, getOut(4) )
		CanToDash3:setBit( 1, 5, getOut(5) )
		CanToDash3:setBit( 1, 6, getOut(6) )
		CanToDash3:setBit( 1, 7, getOut(7) )
		CanToDash3:setBit( 1, 8, getOut(8) )
		CanToDash3:setBit( 2, 1, getOut(9) )
		CanToDash3:setBit( 2, 2, getOut(10) )
		CanToDash3:setBit( 2, 3, getOut(11) )
		CanToDash3:setBit( 2, 4, getOut(12) )
	    CanToDash3:setBit( 2, 5, getOut(13) )
		CanToDash3:setBit( 2, 6, getOut(14) )
		CanToDash3:setBit( 2, 7, getOut(15) )
		CanToDash3:setBit( 2, 8, getOut(16) )
		CanToDash3:setBit( 3, 1, getOut(17) )
		CanToDash3:setBit( 3, 2, getOut(18) )
		CanToDash3:setBit( 3, 3, getOut(19) )
		CanToDash3:setBit( 3, 4, getOut(20) )
		CanToDash3:process()
	    KeyBoard:process() --процесс работы с клавиатурой
		-- блок обмена данными по CAN
		LSF:setData( getAin(LSFAir), 1)
		RSF:setData( getAin(RSFAir), 2)
		LSB:setData( getAin(LSBAir), 3)
		RSB:setData( getAin(RSBAir), 4)
		LMF:setData( getAin(LMFAir), LMFH )
		RMF:setData( getAin(RMFAir), RMFH )
		LMB:setData( getAin(LMBAir), LMBH )
		RMB:setData( getAin(RMBAir), RMBH )
		LPull:setData( getAin(LPullAir), 9 )
		RPull:setData( getAin(RPullAir), 10)
		
		KeyBoard:setBackLigthBrigth( 15  )
		if MODE == 0 then
			if KeyBoard:getToggle(2)==true then  
			  KeyBoard:resetToggle(2,true)
			  SetEEPROMReg(0,getROLL())    --КРЕН
			  SetEEPROMReg(1,getPITCH())   --TАНГАЖ
			  CAL_SET = true
			end
			if KeyBoard:getToggle(13)==true then
				KeyBoard:resetToggle(13,true)
				LOWMODECAL = true
				calmode = 0
			end
			if KeyBoard:getToggle(14)==true then
				KeyBoard:resetToggle(14,true)
				MIDMODECAL = true
				calmode = 1
			end
			if KeyBoard:getToggle(15)==true then
				KeyBoard:resetToggle(15,true)
				HIGHMODECAL = true
				calmode = 2
			end 
			if calmode ~=4 then
			  LSF:Calibrate(calmode)
			  RSF:Calibrate(calmode)
			  LSB:Calibrate(calmode)
			  RSB:Calibrate(calmode)
			  LMF:Calibrate(calmode)
			  RMF:Calibrate(calmode)
			  LMB:Calibrate(calmode)
			  RMB:Calibrate(calmode)
			  LPull:Calibrate(calmode)
			  RPull:Calibrate(calmode)
			  calmode = 4
			end
			LOWMODECAL =  LOWMODECAL  and not AUTO
			MIDMODECAL =  MIDMODECAL  and not AUTO
			HIGHMODECAL = HIGHMODECAL and not AUTO
			KeyBoard:setLedGreen( 13, LOWMODECAL )
			KeyBoard:setLedGreen( 14, MIDMODECAL )
			KeyBoard:setLedGreen( 15, HIGHMODECAL )			
			CAL_SET = CAL_SET and not AUTO
			KeyBoard:setLedGreen( 2, CAL_SET )
		end
		--блок управления клапанами в ручном и калибровочном режиме
		if ((MODE == 1) or ( MODE==0 ) ) then
		
			if (KeyBoard:getToggle(1) == true) then -- при нажатии клавиши 1 переходим в автомат если 
			  KeyBoard:resetToggle(1,true)        -- в ручном и в ручной если в калибровочном
			  MODE =  (MODE == 0 ) and 2 or 1
			end
			AUTO = ((MODE~=1) and (MODE~=0) and (HIGHMODE~=5)) and true or false -- тригер для выключенмя всех клапанов и светодиодов
			LSFCounter:process(KeyBoard:getKey(4),false,AUTO) -- счетчик состония канал управления подушкой LSF
			local UP = (LSFCounter:get() ==3) 				  -- если счетчик 3, то включаем накачку
			local DOWN =(LSFCounter:get() ==1)				  -- если счетчик 1, то вылкючаем клапан сброса
			KeyBoard:setLedRed( 4, DOWN)					  -- светодиды в соотвесвии со значением переменной
			KeyBoard:setLedGreen( 4,  UP or DOWN )			 
			LSF:manualControl( UP, DOWN)					  --непосредственно переаем состояния выходных каналов управления клапанами
			RSFCounter:process(KeyBoard:getKey(3),false,AUTO)
			UP = (RSFCounter:get() ==3) 
			DOWN =(RSFCounter:get() ==1) 
			KeyBoard:setLedRed( 3, DOWN)
			KeyBoard:setLedGreen( 3,  UP or DOWN )
			RSF:manualControl( UP, DOWN)
			LSBCounter:process(KeyBoard:getKey(5),false,AUTO)
			UP = (LSBCounter:get() ==3) 
			DOWN =(LSBCounter:get() ==1) 	
			KeyBoard:setLedRed( 5, DOWN)
			KeyBoard:setLedGreen( 5,  UP or DOWN )
			LSB:manualControl( UP, DOWN)
			RSBCounter:process(KeyBoard:getKey(6),false,AUTO)
			UP = (RSBCounter:get() ==3) 
			DOWN =(RSBCounter:get() ==1) 	
			KeyBoard:setLedRed( 6, DOWN)
			KeyBoard:setLedGreen( 6,  UP or DOWN )
			RSB:manualControl( UP, DOWN)
			RMFCounter:process(KeyBoard:getKey(7),false,AUTO)
			UP = (RMFCounter:get() ==3) and not AUTO
			DOWN =(RMFCounter:get() ==1) and not AUTO	
			KeyBoard:setLedRed( 7, DOWN)
			KeyBoard:setLedGreen( 7,  UP or DOWN )
			RMF:manualControl( UP, DOWN)
			LMFCounter:process(KeyBoard:getKey(8),false,AUTO)
			UP = (LMFCounter:get() ==3) 
			DOWN =(LMFCounter:get() ==1) 	
			KeyBoard:setLedRed( 8, DOWN)
			KeyBoard:setLedGreen( 8,  UP or DOWN )
			LMF:manualControl( UP, DOWN)
			LMBCounter:process(KeyBoard:getKey(9),false,AUTO)
			UP = (LMBCounter:get() ==3)
			DOWN =(LMBCounter:get() ==1)
			KeyBoard:setLedRed( 9, DOWN)
			KeyBoard:setLedGreen( 9,  UP or DOWN )
			LMB:manualControl( UP, DOWN)
			RMBCounter:process(KeyBoard:getKey(10),false,AUTO)
			UP = (RMBCounter:get() ==3)
			DOWN =(RMBCounter:get() ==1)
			KeyBoard:setLedRed( 10, DOWN)
			KeyBoard:setLedGreen( 10,  UP or DOWN )
			RMB:manualControl( UP, DOWN)
			LPullCounter:process(KeyBoard:getKey(11),false,AUTO)
			UP = (LPullCounter:get() ==3)
			DOWN =(LPullCounter:get() ==1)
			KeyBoard:setLedRed( 11, DOWN)
			KeyBoard:setLedGreen( 11,  UP or DOWN )
			LPull:manualControl( UP, DOWN)
			RPullCounter:process(KeyBoard:getKey(12),false,AUTO)
			UP = (RPullCounter:get() ==3) 
			DOWN =(RPullCounter:get() ==1) 
			KeyBoard:setLedRed( 12, DOWN)
			KeyBoard:setLedGreen( 12,  UP or DOWN )
			RPull:manualControl( UP, DOWN)
		end	
		-- режим автомтического выставления высоты подески в ручном режиме работы
		if (MODE == 1) then
			if ( ( not TRANSITION ) and ( HIGHMODE~=4 ) ) then  -- если не в переходном режиме
				if KeyBoard:getKey(1) and KeyBoard:getKey(2) then
					MODE = 0
				else 
					if KeyBoard:getToggle(13)==true then     -- перехоимд в режим низкого клиренса
						KeyBoard:resetToggle(13,true)
						HIGHMODE = HIGHMODE ~= 1 and 1 or 4  
						TRANSITION = true
					end
					if KeyBoard:getToggle(14)==true then    -- перехоимд в режим средненго клиренса
						KeyBoard:resetToggle(14,true)
						HIGHMODE = HIGHMODE ~= 2 and 2 or 4
						TRANSITION = true
					end
					if KeyBoard:getToggle(15)==true then     -- перехоимд в режим высокго клиренса
						KeyBoard:resetToggle(15,true)
						HIGHMODE = HIGHMODE ~= 3 and 3 or 4
						TRANSITION = true
					end
				end
				if TRANSITION then --если изменился режим
				 BeginLeftSide()
				 BeginRightSide()
				end
			end 
			KeyBoard:setLedGreen( 13, (HIGHMODE == 1) )
			KeyBoard:setLedGreen( 14, (HIGHMODE == 2) )
			KeyBoard:setLedGreen( 15, (HIGHMODE == 3) )
			if (HIGHMODE == 4) then  -- если выключили автоматический клиренс
					ValveOff()
					HIGHMODE = 5
					TRANSITION = false
			else  
				if TRANSITION then  -- если переходный режим
					TRANSITION = ( RightSide(HIGHMODE-1,HIGHMODE-1,false )== 1) and ( LeftSide(HIGHMODE-1,HIGHMODE-1,false )== 1)
					--выйдем из переходного режима, как только завершаться процессы в правой и левой гусенице
				else  -- иначе подерживаем заданую высоту в подушках
					LeftSideIDLE(HIGHMODE-1,HIGHMODE-1,false)
					RigthSideIDLE(HIGHMODE-1,HIGHMODE-1,false)
				end
			end
		end
		if (MODE == 2) then  -- автоматический режим
			if (ROLL_WARNING or PITCH_WARNING) and (not TRANSITION) then -- не в перхеодном состонии и критические углы
				MODE = 1				-- в ручной режим
				HIGHMODE = 4			-- флаг выключения клапанов в ручном режиме
				UPSTATE = 0				-- обнуляем состония подвески
				AUTOMODE =0					--обнкляем переменную режима
			elseif AUTOMODE == 0 then
				ValveOff()
				speed_low = true
				if KeyBoard:getToggle(2)==true then     -- переходим в режим подъема
					KeyBoard:resetToggle(2,true)
					AUTOMODE = 1  
				elseif KeyBoard:getToggle(3)==true then     -- перехоимд в режим спуска
					KeyBoard:resetToggle(3,true)
					AUTOMODE = 2  
				elseif KeyBoard:getToggle(4)==true then     -- перехоимд в режим высоты подвески по скорости
					KeyBoard:resetToggle(4,true)
					AUTOMODE = 3  
				elseif KeyBoard:getToggle(5)==true then     -- перехоимд в режим отработки неровностей
					KeyBoard:resetToggle(5,true)
					AUTOMODE = 4  
				end					
			elseif AUTOMODE == 1 then   --режим работы на подъем
			    SPEED20Dealy( (SPEED >10) , (SPEED <=10)  )  -- конртолируем привышение скорости боле 10 км/ч в течении 5 сек
				if not TRANSITION then	--если не в переходном состоянии
					if not ROLLOVER10WARNING and (not SPEED20Dealy:get()) then   -- проверяем крен 10 крадусов и скорость меньше 10
						if KeyBoard:getToggle(2)==true then  --если кнопка выхода перехоимд в автомат с выключенными клапанами
							KeyBoard:resetToggle(2,true)
							AUTOMODE =  0  
							UPSTATE = 0
						else
							if ( (PITCH <= 20 ) and ( UPSTATE ~= 1 ) ) then  -- если крен меньше 20, то средний клиренс
								LEFT_SIDE_REAR = 1
								LEFT_SIDE_FRONT = 1
								RIGTH_SIDE_REAR = 1
								RIGTH_SIDE_FRONT =1
								UPSTATE = 1
								TRANSITION =true
							end
							if ( ( PITCH > 20 ) and ( UPSTATE ~= 2 ) ) then -- если крен больше 20, то зал вверх, перед вниз
								LEFT_SIDE_REAR = 2
								LEFT_SIDE_FRONT = 0
								RIGTH_SIDE_REAR = 2
								RIGTH_SIDE_FRONT = 0
								UPSTATE = 2
								TRANSITION =true
							end
							if (not TRANSITION)  then  -- если не в перехоном состоянии
								-- и не переходим в ручной режим, то подерживаем подвеску в заданном состоянии
								LeftSideIDLE(LEFT_SIDE_FRONT,LEFT_SIDE_REAR,false)
								RigthSideIDLE(RIGTH_SIDE_FRONT,RIGTH_SIDE_REAR,false)
							end
						end
					else
						AUTOMODE =0  -- переходим в ручной режим с выключенными клапанами
						MODE = 1
						HIGHMODE = 4
						UPSTATE = 0
					end
				else
					-- переменная станет false и мы выйдем из переходного состояния токо когда обе гусеницы закочат переход 
					-- в новое состояние подвески
					TRANSITION = not ( ( RightSide(RIGTH_SIDE_FRONT,RIGTH_SIDE_REAR,false )== 1)
						and ( LeftSide(LEFT_SIDE_FRONT,LEFT_SIDE_REAR,false )== 1))
				end
			elseif AUTOMODE == 2 then -- режим работы на спуск
			    SPEED20Dealy( (SPEED >10) , (SPEED <=10)  )  -- конртолируем привышение скорости боле 10 км/ч в течении 5 сек
			    if not TRANSITION then --если не в переходном состоянии
				    if (not ROLLOVER10WARNING) and (not SPEED20Dealy:get()) then -- проверяем крен 10 градусов скорость меньше 10
						if ( KeyBoard:getToggle(3) == true ) then  --если кнопка выхода перехоимд в автомат с выключенными клапанами
							KeyBoard:resetToggle(3,true)
							AUTOMODE =  0
						    UPSTATE = 0							
						else
							if ((PITCH <= -20) and (UPSTATE ~= 1)) then -- если крен меньше -20, то средний клиренс
								LEFT_SIDE_REAR = 1
								LEFT_SIDE_FRONT = 1
								RIGTH_SIDE_REAR = 1
								RIGTH_SIDE_FRONT =1
								UPSTATE = 1
								TRANSITION =true
							end
							if ((PITCH > -20) and (UPSTATE ~= 2 )) then -- если крен больше -20, то зад вниз, перед вверх
								LEFT_SIDE_REAR = 0
								LEFT_SIDE_FRONT = 2
								RIGTH_SIDE_REAR = 0
								RIGTH_SIDE_FRONT = 2
								UPSTATE = 2
								TRANSITION =true
							end
							if (not TRANSITION)  then  -- если не в перехоном состоянии
								-- и не переходим в ручной режим, то подерживаем подвеску в заданном состоянии
								LeftSideIDLE(LEFT_SIDE_FRONT,LEFT_SIDE_REAR,false)
								RigthSideIDLE(RIGTH_SIDE_FRONT,RIGTH_SIDE_REAR,false)
							end
						end
					else
						AUTOMODE =0 -- переходим в ручной режим с выключенными клапанами
						MODE = 1
						HIGHMODE = 4
						UPSTATE = 0
					end
				else
					-- переменная станет false и мы выйдем из переходного состояния токо когда обе гусеницы закочат переход 
					-- в новое состояние подвески
					TRANSITION = not ( ( RightSide(RIGTH_SIDE_FRONT,RIGTH_SIDE_REAR,false )== 1)
						and ( LeftSide(LEFT_SIDE_FRONT,LEFT_SIDE_REAR,false )== 1))
				end
			elseif AUTOMODE == 3 then --режим высоты подвески по скорости
				if not TRANSITION then --если не в переходном состоянии
				   if (not ROLLOVER10WARNING)  and (not PITCHOVER20WARNING)  then
				        if (KeyBoard:getToggle(4)==true) then  --если кнопка выхода перехоимд в автомат с выключенными клапанами
							KeyBoard:resetToggle(4,true)
							AUTOMODE =  0
						    UPSTATE = 0	
						else
							SPEED10Dealy( SPEED <=10, (SPEED >10))   -- таймер 5 сек, если скорсть меньше 10
							SPEED20Dealy( ((SPEED >10) and (SPEED <20)) , (SPEED <=10) or (SPEED>=20) ) -- таймер 5 сек, если скорсть от 10 до 20
							SPEED30Dealy( SPEED >=20, (SPEED <20)) -- таймер 5 сек, если скорсть больше 20
							--переменные принимают значение true если скорсть была в заданном диапазоне более 5 секунд ( или иное время заданное таймерами)
							local HIGH  =  not ( SPEED20Dealy:get() and SPEED30Dealy:get()) --высокий если скорость не меньше 10 и не от 10 до 20
							local MID  =  not ( SPEED10Dealy:get() and SPEED30Dealy:get()) --средний если скорость не меньше 10 и не больше 20
							local LOW  = not ( SPEED20Dealy:get() and SPEED10Dealy:get()) --верхний клиренс не от 10 до 20 и не больше 20
							--если все переменные false, значит система в переходоном режиме по скорости, скорость где-то на границе режимов
							-- и ничего не делаем, пока она не будет в диапазоне время заданное таймером
							if not ( not LOW and  not MID and  not HIGH) then
								if LOW and UPSTATE~=1 then  --если нужен низкий клиренс и мы еще не внем
									UPSTATE = 1
									LEFT_SIDE_REAR = 0
									LEFT_SIDE_FRONT = 0
									RIGTH_SIDE_REAR = 0
									RIGTH_SIDE_FRONT =0
									TRANSITION = true
								end 
								if MID and UPSTATE~=2 then --если нужен средний клиренс и мы еще не внем
									UPSTATE = 2
									LEFT_SIDE_REAR = 1
									LEFT_SIDE_FRONT = 1
									RIGTH_SIDE_REAR = 1
									RIGTH_SIDE_FRONT =1
									TRANSITION = true
								end 
								if HIGH and UPSTATE~=3 then --если нужен высокий клиренс и мы еще не внем
									UPSTATE = 3
									LEFT_SIDE_REAR = 2
									LEFT_SIDE_FRONT = 2
									RIGTH_SIDE_REAR = 2
									RIGTH_SIDE_FRONT =2
									TRANSITION = true
								end  
							end
							if (not TRANSITION)  then  -- если не в перехоном состоянии
								-- и не переходим в ручной режим, то подерживаем подвеску в заданном состоянии
								LeftSideIDLE(LEFT_SIDE_FRONT,LEFT_SIDE_REAR,false)
								RigthSideIDLE(RIGTH_SIDE_FRONT,RIGTH_SIDE_REAR,false)
							end
						end
				   else
					 AUTOMODE =0
					 MODE = 1
					 HIGHMODE = 4
					 UPSTATE = 0
				   end
				else
					-- переменная станет false и мы выйдем из переходного состояния токо когда обе гусеницы закочат переход 
					-- в новое состояние подвески
					TRANSITION = not ( ( RightSide(RIGTH_SIDE_FRONT,RIGTH_SIDE_REAR,false )== 1)
						and ( LeftSide(LEFT_SIDE_FRONT,LEFT_SIDE_REAR,false )== 1))
				end

			elseif AUTOMODE == 4 then  -- режим работы по неровной вовернхости
				SPEED20Dealy( (SPEED >10) , (SPEED <=10)  )  -- конртолируем привышение скорости боле 10 км/ч в течении 5 сек
				if ( not TRANSITION ) then   -- если не в переходном процессе 
				   if  (not SPEED20Dealy:get()) and (not PITCHOVER25WARNING)  and (not ROLLOVER20WARNING)  then
						-- проеверяем что скорость меньше 10 км/ч дифферент не выше 25 и крен не больше 20 
						-- в ручной режим
						if (KeyBoard:getToggle(5)==true) then  --если кнопка выхода перехоимд в автомат с выключенными клапанами
							KeyBoard:resetToggle(5,true)
							AUTOMODE =  0
						    UPSTATE = 0	
						else
							if UPSATE == 0 then   --инициализационное состояние
								LEFT_SIDE_REAR =  1  -- все подушки в середниие
								LEFT_SIDE_FRONT = 1
								RIGTH_SIDE_REAR = 1
								RIGTH_SIDE_FRONT =1
								TRANSITION = true   -- запускаем переходный процес 
								UPSATE = 1 			--после него пойдем в базовое состояние среднего клиренса 
							elseif UPSATE == 1 then  -- если мы тут завешился пеходный процесс и мы в среднем клиренсе
								if (ROLL > 10 ) then   -- если крен больше 10 переходим в состояние левая сторана вниз паравая вверх
									TRANSITION = true
									UPSTATE = 5
									LEFT_SIDE_REAR = 0
									LEFT_SIDE_FRONT = 0
									RIGTH_SIDE_REAR = 2
									RIGTH_SIDE_FRONT = 2
								elseif ROLL > -10 then -- если крен больше -10 переходим в состояние левая сторана вверх паравая вниз
									TRANSITION = true
									UPSTATE = 4
									LEFT_SIDE_REAR = 2
									LEFT_SIDE_FRONT = 2
									RIGTH_SIDE_REAR = 0
									RIGTH_SIDE_FRONT = 0
								elseif PITCH > 10 then -- если диффирент больше 10 переходим в состояние зад вверх перед вниз
									TRANSITION = true
									UPSTATE = 3
									LEFT_SIDE_REAR = 0
									LEFT_SIDE_FRONT = 2
									RIGTH_SIDE_REAR = 0
									RIGTH_SIDE_FRONT = 2
								elseif PITCH > -10 then -- если диффирент больше 10 переходим в состояние зад вниз перед вверх
									TRANSITION = true
									UPSTATE = 2
									LEFT_SIDE_REAR = 2
									LEFT_SIDE_FRONT = 0
									RIGTH_SIDE_REAR = 2
									RIGTH_SIDE_FRONT = 0
								end				
							elseif (UPSTATE == 2) or  (UPSTATE == 3) then--  состояние обработки дифферента
								if (ROLLOVER10WARNING)  then
								-- если крен больше 10  то переходим в ручной режим, с выключением клапанов
									AUTOMODE =0
									MODE = 1
									HIGHMODE = 4
									UPSTATE = 0
								else
									if ( not PITCHOVER10WARNING)  then 
									-- иначе смотрим что дифферент все еще больше 10, если меньше, то выходим в базовое состояние
										TRANSITION = true
										UPSTATE = 1
										LEFT_SIDE_REAR = 1
										LEFT_SIDE_FRONT = 1
										RIGTH_SIDE_REAR = 1
										RIGTH_SIDE_FRONT =1
									end
								end
							elseif (UPSTATE == 4) or (UPSATE == 5) then -- состояние обработки крена
								if (PITCHOVER10WARNING)  then 
								-- если диффернт больше 10  то в ручной режим, с выключением клапанов 
									AUTOMODE =0
									MODE = 1
									HIGHMODE = 4
									UPSTATE = 0
								else
								-- иначе смотрим что крен все еще больше 10, если меньше, то выходим в базовое состояние  
									if ( not ROLLOVER10WARNING) then
									TRANSITION = true
									UPSTATE = 1
									LEFT_SIDE_REAR = 1
									LEFT_SIDE_FRONT = 1
									RIGTH_SIDE_REAR = 1
									RIGTH_SIDE_FRONT =1
								end						 
							end
							if (not TRANSITION) and (AUTOMODE~=0) then  -- если не в перехоном состоянии
								-- и не переходим в ручной режим, то подерживаем подвеску в заданном состоянии
								LeftSideIDLE(LEFT_SIDE_FRONT,LEFT_SIDE_REAR,false)
								RigthSideIDLE(RIGTH_SIDE_FRONT,RIGTH_SIDE_REAR,false)
							end
						 end
						end
				   else  -- сюдя вываливаемся елси
				     --  скорость более 10 км/ч или дифферент  выше 25 или крен нбольше 20 или нажата кнопка выхода 
						-- в ручной режим
					 AUTOMODE =0
					 MODE = 1
					 HIGHMODE = 4
					 UPSTATE = 0
				   end
				  
				else
				    -- переменная станет false и мы выйдем из переходного состояния токо когда обе гусеницы закочат переход 
					-- в новое состояние подвески
					TRANSITION = not ( ( RightSide (RIGTH_SIDE_FRONT,RIGTH_SIDE_REAR,false ) == 1)
						and ( LeftSide(LEFT_SIDE_FRONT,LEFT_SIDE_REAR,false ) == 1) )
				end				
			end
					
		end
		KeyBoard:setLedBlue( 2,  (AUTOMODE == 1) )
		KeyBoard:setLedBlue( 3,  (AUTOMODE == 2) )
		KeyBoard:setLedBlue( 4,  (AUTOMODE == 3) )
		KeyBoard:setLedBlue( 5,  (AUTOMODE == 4) )
		KeyBoard:setLedBlue( 1,  (MODE == 2) )
		KeyBoard:setLedGreen( 1, (MODE == 1) )
		KeyBoard:setLedRed( 1,  (MODE == 0) )
	   Yield()
	end
end