

Pillow = {}
Pillow.__index = Pillow
function Pillow:new ( N , all_N, outOn, outOFF)
	local obj = {  air = 0.0, height = 0.0, number = N, total = all_N , timer = 0, mode = 3, OO =outOn, OF = outOFF,
	state = 1, SA = 0.0, SH = 0.0 , SA10 = 0.0, SH10 = 0.0,  SA5=0.0, SH10 = 0.0} 
	setmetatable( obj, self )
	return obj
end
function Pillow:setData( AirData, HData)
  self.air = AirData
  self.height = HData
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
  --[[if ( DATA < EDATA ) then
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
  end]]
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

function init() --функция иницализации
     ConfigCan(1,500);
	 setOutConfig(1,2)	
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
	 CanSend(0x615,0x2F,0x12,0x20,00,00,0x01,00,00,00)
     CanSend(0x615,0x2F,0x14,0x20,00,00,0x00,00,00,00)
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
     ConfigStorage(0,30,0x00,0x01,0x03,0x03)					
--	 CanSend(0,0x80,0x15)
end

main = function ()
  
    init()
	local KeyBoard		= KeyPad15:new(0x15)
	local MODCOUNTER    =  Counter:new(1,2,1,true)
    local CanIn         = CanInput:new(0x28)
	local CanToDash		= CanOut:new(0x29, 100)
	local Pillow1   = Pillow:new( 0 ,4 , 1,2)
	local Pillow2   = Pillow:new( 1 ,4 ,3,4)
	local Pillow3   = Pillow:new( 2 ,4,5,6)
	local Pillow4   = Pillow:new( 3 ,4 ,7,8)
	local ModeCounter  	= Counter:new(0,2,1,false)
    local CalLFlag  = false
	local CalMFlag  = false
	local CalHFlag  = false
    local automode  = false
	local P1mode = false
	local P2mode = false
    local P3mode = false
    local P4mode = false
	local data_mode = 0
	local highmode  = 1
	local v_flag = false
	while true do	
	    if getBat() < 8 then
		  if v_flag == true then
		  SetEEPROMReg(1,getBat())
		   end
		 else
		 v_flag = true
		end
	    CanIn:process()
		local p1H = CanIn:getByte(1)
		local p2H = CanIn:getByte(2)
		local p3H = CanIn:getByte(3)
		local p4H = CanIn:getByte(4)
		Pillow1:setData(getAin(1),p1H)
		Pillow2:setData(getAin(2),p2H)
		Pillow3:setData(getAin(3),p3H)
		Pillow4:setData(getAin(4),p4H)	
		KeyBoard:process()
		MODCOUNTER:process(KeyBoard:getKey(1),false,false)
		-- Ручной режим работы
		if MODCOUNTER:get() ==1  then
		  -- блок ручного управления клапанаами
		   local p1air_on =  KeyBoard:getKey(2) 
		   setOut(1, p1air_on )	
		   KeyBoard:setLedGreen( 2,  p1air_on)
		   local p2air_on =  KeyBoard:getKey(3) 
		   setOut(2, p2air_on )	
		   KeyBoard:setLedGreen( 3,  p2air_on)
		   local p3air_on =  KeyBoard:getKey(4) 
		   setOut(3, p3air_on )	
		   KeyBoard:setLedGreen( 4,  p3air_on)
		   local p4air_on =  KeyBoard:getKey(5) 
		   setOut(4, p4air_on )	
		   KeyBoard:setLedGreen( 5,  p4air_on)
		   local p1air_off =  KeyBoard:getKey(7) 
		   setOut(5, p1air_off )	
		   KeyBoard:setLedGreen( 7,  p1air_off)
		   local p2air_off =  KeyBoard:getKey(8) 
		   setOut(6, p2air_off )	
		   KeyBoard:setLedGreen( 8,  p2air_off)
		   local p3air_off =  KeyBoard:getKey(9) 
		   setOut(7, p3air_off )	
		   KeyBoard:setLedGreen( 9,  p3air_off)
		   local p4air_off =  KeyBoard:getKey(10) 
		   setOut(8, p4air_off )	
		   KeyBoard:setLedGreen( 10,  p4air_off)
		   -- конец ручного блока управления клапанами
		   -- блок калиборки 
		   CalLFlag = not CalLFlag and KeyBoard:getKey(11)
		   CalMFlag = not CalMFlag and KeyBoard:getKey(12)
		   CalHFlag = not CalHFlag and KeyBoard:getKey(13)
		   if  CalLFlag or CalMFlag or CalHFlag  then
		   
		        local offset = CalMFlag and 1 or 0
			    offset =  CalHFlag and 2 or offset
				Pillow1:Calibrate( offset )
				Pillow2:Calibrate( offset )
				Pillow3:Calibrate( offset )
				Pillow4:Calibrate( offset )	 			
			end	
			KeyBoard:setToggle(14)
			
			-- конец блока калиборвки
			highmode = 1
		else
		   -- блок выбора режима работы
		   
		   
		  
		   Pillow1:process( highmode, KeyBoard:getToggle(12))
		   Pillow2:process( highmode, KeyBoard:getToggle(12))
		   Pillow3:process( highmode, KeyBoard:getToggle(12))
		   Pillow4:process( highmode, KeyBoard:getToggle(12))
		   if  KeyBoard:getKey(11)  then highmode = 0 end
           if  KeyBoard:getKey(12)  then highmode = 1 end
	       if  KeyBoard:getKey(13)  then highmode = 2 end
		   

		end
		local mode = (MODCOUNTER:get() ~=1) 
		KeyBoard:setLedGreen( 1, not mode)
		KeyBoard:setLedRed( 1,  mode)
		KeyBoard:setLedGreen(11,  (highmode  == 0) and mode )
		KeyBoard:setLedGreen(12,( highmode == 1) and mode)
		KeyBoard:setLedGreen(13, (highmode == 2) and mode)
		KeyBoard:setLedGreen(14,KeyBoard:getToggle(14) and mode)
		KeyBoard:setLedBlue(14,not KeyBoard:getToggle(14) and mode)
		
		
		CanToDash:setWord(1, (getAin(1)*100)//1 )
		CanToDash:setWord(3, (getAin(2)*100)//1 )
		CanToDash:setWord(5, (getAin(3)*100)//1 )
		CanToDash:setWord(7, (getAin(4)*100)//1 )
		CanToDash:process()
	   Yield() 
	end
end