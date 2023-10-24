--Функции работы с CAN
EXT_CAN_ID = 0x80000000
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
--Функции счетчиков
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
--Функции задержек
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
--Функции работы с Kepad15 по протоклу CANOpen 
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
--Системные Функции и переменные
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
--функции работы с подушками
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
  self.state = 1
  local DATA  = ( control_type ) and self.air  or self.height
  local EDATA = ( control_type ) and self.SA   or self.SH
  local D10   = ( control_type ) and self.SA10 or self.SH10
  local D5    = ( control_type ) and self.SA5  or self.SA5
  if ( DATA < EDATA ) then
	local delta = EDATA -DATA
	if  delta > D10 then
		self.state = 4
	else
	    if delta > D5 then
		   self.state = 2
		end
	end
  else
	local delta = DATA - EDATA
	if  delta > D10 then
	   self.state = 3
	else
	  if delta > D5 then
	   self.state = 1
	  end
	end
  end
  local UP   = false
  local DOWN = false
  --импульсно спускаем
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
   setOut(self.OO, UP  )
   setOut(self.OF, DOWN )
end
function Pillow:process_set_air( air  )
  if self.SetAir ~= air then
   self.SA5  = self.air*0,05
   self.SA10 = self.air*0,1
   self.SetAir = air
  end 
  self.state = 1
  local DATA  =  self.air
  local EDATA =  air
  local D10   = self.SA10 
  local D5    = self.SA5  
  if ( DATA < EDATA ) then
	local delta = EDATA -DATA
	if  delta > D10 then
		self.state = 4
	else
	    if delta > D5 then
		   self.state = 2
		end
	end
  else
	local delta = DATA - EDATA
	if  delta > D10 then
	   self.state = 3
	else
	  if delta > D5 then
	   self.state = 1
	  end
	end
  end
  local UP   = false
  local DOWN = false
  --импульсно спускаем
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
   setOut(self.OO, UP  )
   setOut(self.OF, DOWN )
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
	ConfigCan(1,500)		  -- конфигурация скорости CAN				   
	setOutConfig(1,2)	      -- насройка номнальных токов для каналов управления
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
	setAINCalTable(1,		
					10,0,    
					184,10   
				    )
    setAINCalTable(2,	
					10,0,     
					184,10  
				    )
    setAINCalTable(3,		
					10,0,	     
					184,10	    
				    )
    setAINCalTable(4,			
					10,0,	     
					184,10	    
				    )
	setAINCalTable(5,			
					10,0,	     
					184,10	    
				    )
    setAINCalTable(6,			
					10,0,	     
					184,10    
				    )
    setAINCalTable(7,	
					10,0,    
					184,10  
				    )
    setAINCalTable(8,	
					10,0,    
					184,10   
				    )
	setAINCalTable(9,
					10,0,	     
					184,10    
				    )
     setAINCalTable(10,			
					10,0,	     
					184,10	    
				    )
     setAINCalTable(11,			
					10,0,	     
					184,10	    
				    )	
	--конфигурация хранилища данных
   ConfigStorage(0,62,0x00,0x01,0x03,0x03)			
	--отправка конфигурационного пакета в кавиатуру, для перевода ее в рабочий режим
   CanSend(0x00,0x01,0x15,0x00,0x00,0x00,0x00,0x00,0x00)
end

--главная функция
main = function ()

    init()
    local CanIn         = CanInput:new(0x28)
	local CanToDash  	= CanOut:new(0x29, 100)
	local CanToDash1	= CanOut:new(0x30, 100)
	local CanToDash2	= CanOut:new(0x31, 100)
	local CanToDash3	= CanOut:new(0x32, 100)
    local KeyBoard		= KeyPad15:new(0x15)--создание объекта клавиатура c адресом 0x15
	                                       --Качать/сдувать
    local LSF   		= Pillow:new(0, 10 , 1, 2)
	local LSFCounter   =  Counter:new(1,4,2,true) 
	local RSF   		= Pillow:new(1, 10 , 3, 4)
	local RSFCounter   =  Counter:new(1,4,2,true) 
	local LSB   		= Pillow:new(2, 10 , 5, 6)
	local LSBCounter   =  Counter:new(1,4,2,true) 
	local RSB   		= Pillow:new(3, 10 , 7, 8)
	local RSBCounter   =  Counter:new(1,4,2,true) 
	local LMF   		= Pillow:new(4, 10 , 9, 10)
	local LMFCounter   =  Counter:new(1,4,2,true) 
	local RMF   		= Pillow:new(5, 10 , 11, 12)
	local RMFCounter   =  Counter:new(1,4,2,true) 
	local LMB   		= Pillow:new(6, 10 , 13, 14)
	local LMBCounter   =  Counter:new(1,4,2,true) 
	local RMB   		= Pillow:new(7, 10 , 15, 16)
	local RMBCounter   =  Counter:new(1,4,2,true) 
	local LPull   		= Pillow:new(8, 10 , 17, 18)
	local LPullCounter   =  Counter:new(1,4,2,true) 
	local RPull  		= Pillow:new(9, 10 , 19, 20)
	local RPullCounter   =  Counter:new(1,4,2,true)
	local ROLLDelay		 = Delay:new( 5000, false) -- зажержка на фиксацию превышения угла крена выше 30 градусов
	local PITCHDelay    = Delay:new( 5000, false) -- зажержка на фиксацию превышения угла тангажа выше 35 градусов
	local ROLLOVER10Dealy = Delay:new( 5000, false)
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
    local ROLL =0
	local PITCH = 0
	local MODE = 1
	local CAL_SET = false
	local ROLL_WARNING = false
	local PITCH_WARNING = false
	local SPEED = 0
	local ANGLE_MODE_F = 0
	local ANGLE_MODE_B = 0
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
		
            if KeyBoard:getToggle(1)==true then  -- при нажатии клавиши 1 переходим в автомат если 
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
			
			if KeyBoard:getToggle(13)==true then     -- перехоимд в режим низкого клиренса
				KeyBoard:resetToggle(13,true)
				HIGHMODE = HIGHMODE ~= 1 and 1 or 4  
			end
			if KeyBoard:getToggle(14)==true then    -- перехоимд в режим средненго клиренса
				KeyBoard:resetToggle(14,true)
				HIGHMODE = HIGHMODE ~= 2 and 2 or 4
			end
			if KeyBoard:getToggle(15)==true then     -- перехоимд в режим высокго клиренса
				KeyBoard:resetToggle(15,true)
				HIGHMODE = HIGHMODE ~= 3 and 3 or 4
			end
			KeyBoard:setLedGreen( 13, (HIGHMODE == 1) )
			KeyBoard:setLedGreen( 14, (HIGHMODE == 2) )
			KeyBoard:setLedGreen( 15, (HIGHMODE == 3) )
			if HIGHMODE ~=4 then
				LSF:process(HIGHMODE-1,true)
				RSF:process(HIGHMODE-1,true)
				LSB:process(HIGHMODE-1,true)
				RSB:process(HIGHMODE-1,true)
				LMF:process(HIGHMODE-1,false)
				RMF:process(HIGHMODE-1,false)
				LMB:process(HIGHMODE-1,false)
				RMB:process(HIGHMODE-1,false)
				LPull:process(HIGHMODE-1,true)
				RPull:process(HIGHMODE-1,true)
			end
			if (HIGHMODE == 4) then
				LSF:manualControl(false,false)
				RSF:manualControl(false,false)
				LSB:manualControl(false,false)
				RSB:manualControl(false,false)
				LMF:manualControl(false,false)
				RMF:manualControl(false,false)
				LMB:manualControl(false,false)
				RMB:manualControl(false,false)
				LPull:manualControl(false,false)
				RPull:manualControl(false,false)
				HIGHMODE = 5
			end
		end
		if (MODE == 2) then
		    if ((not ROLLOVER10WARNING)  and (not PITCH_WARNING)) then	 -- выходим из автоматического режима в ручной если крен 
													 -- не более 10 и тангаж не более 35
				 if PITCH <= 20 then					-- если такгаж менее 20 градусов система работате в режиме
													--изменения клиренса от скорости движения
					SPEED10Dealy( SPEED <=10, (SPEED >10))
					SPEED20Dealy( ((SPEED >10) and (SPEED <20)) , (SPEED <=10) or (SPEED>=20) )
					SPEED30Dealy( SPEED >=20, (SPEED <20))
					local HIGH  =  not ( SPEED20Dealy:get() and SPEED30Dealy:get()) --верхний клиренс если скорость менее 10 
					local MID  =  not ( SPEED10Dealy:get() and SPEED30Dealy:get()) --средний если более 10 и менее 20
					local LOW  = not ( SPEED20Dealy:get() and SPEED10Dealy:get())	-- выскоий если более 20 км/ч
					if not ( not LOW and  not MID and  not HIGH) then
					
						if LOW then HIGHMODE =  1 end
						if MID then HIGHMODE =  2 end
						if HIGH then HIGHMODE = 3 end
					end
					LSF:process(HIGHMODE-1,true)
					RSF:process(HIGHMODE-1,true)
					LSB:process(HIGHMODE-1,true)
					RSB:process(HIGHMODE-1,true)
					LMF:process(HIGHMODE-1,false)
					RMF:process(HIGHMODE-1,false)
					LMB:process(HIGHMODE-1,false)
					RMB:process(HIGHMODE-1,false)
					LPull:process(HIGHMODE-1,true)
					RPull:process(HIGHMODE-1,true)
				else if ( GetEEPROMReg(1) - getPITCH() ) > 0 then
						LMB:process(2,false)				-- ползем вверх
						RMB:process(2,false)
						LSF:process(0,true)
						RSF:process(0,true)
						LSB:process(1,true)
						RSB:process(1,true)
						LMF:process(1,false)
						RMF:process(1,false)
					else
						LMB:process(1,false)				-- ползем вниз
						RMB:process(1,false)
						LSF:process(1,true)
						RSF:process(1,true)
						LSB:process(0,true)
						RSB:process(0,true)
						LMF:process(2,false)
						RMF:process(2,false)
					end	
				  LPull:process(1,true)
				  RPull:process(1,true)
			    end
			else
			  MODE = 1			--выходим в ручной режим в режиме подвески 4
			  HIGHMODE = 4		--в это режиме подвески выключаются все клапана 
								--и система переходит в режим ручного управления
			end
			
		end
		KeyBoard:setLedBlue( 1,  (MODE == 2) )
		KeyBoard:setLedGreen( 1, (MODE == 1) )
		KeyBoard:setLedRed( 1,  (MODE == 0) )
		if KeyBoard:getKey(1) and KeyBoard:getKey(2) then
		 MODE = 0
		end
	   Yield()
	end
end