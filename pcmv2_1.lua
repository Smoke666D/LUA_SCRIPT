RFStabIn   = 1
RFStabOutBlow  = 1
RFStabOutSuck  = 2 
LFStabIn   = 2
LFSTabOutBlow  = 3
LFSTabOutSuck  = 4
RBStabIn  =  3
RBStabOutBlow  = 5
RBStabOutSuck  = 6
LBStabIn   = 4
LBStabOutBlow  = 7
LBStabOutSuck  = 8
RFMainIn   = 5
RFMainOut  = 5
LFMainIn   = 6
LFMainOut  = 6
RBMainIn   = 7
RBMainOut  = 7
LBMainIn   = 8
LBMainOut  = 8
LPullIn    = 9
LPullOut   = 9
RPullIn    = 10
RPullPut   = 10
MainIn	   = 11



function AlarmState(  )
		setOut(1,false)
		setOut(2,false)
		setOut(3,false)
		setOut(4,false)
		setOut(5,false)
		setOut(6,false)
		setOut(7,false)
		setOut(8,false)
		setOut(9,false)
		setOut(10,false)
		setOut(11,false)
		setOut(12,false)
		setOut(13,false)
		setOut(14,false)
		setOut(15,false)
		setOut(16,false)
		setOut(17,false)
		setOut(18,false)
		setOut(19,false)
		setOut(20,false)
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
     ConfigStorage(0,30,0x00,0x01,0x03,0x03)					
--	 CanSend(0,0x80,0x15)
end

main = function ()
  
    init()
	local KeyBoard		= KeyPad15:new(0x15)
    local CanIn         = CanInput:new(0x28)
	local CanToDash  	= CanOut:new(0x29, 100)
	local CanToDash1	= CanOut:new(0x30, 100)
	local CanToDash2	= CanOut:new(0x31, 100)
	local CanToDash3	= CanOut:new(0x32, 100)
	local LSF   		= Pillow:new(0, 10 , 1, 2)
	
	
	local RFSCounter   = Counter:new(1,4,2,true) 
	local LFSCounter   = Counter:new(1,4,2,true) 
  
    local FlashTimer    = Delay:new( 500, true )
  	local FlashCounter  = Counter:new(0,1,0,true)
  
	local v_flag = false
	local WORK_MODE = 0
	while true do	
	    if getBat() < 8 then
		  if v_flag == true then
		  SetEEPROMReg(1,getBat())
		   end
		 else
		 v_flag = true
		end
		--Обмен по CAN, привем пакетов
	    CanIn:process()
		local p1H = CanIn:getByte(1)
		local p2H = CanIn:getByte(2)
		local p3H = CanIn:getByte(3)
		local p4H = CanIn:getByte(4)
		--Обмен по CAN, отправка пакетов		
		CanToDash:setWord(1, (getAin(RFStabIn)*100)//1 )
		CanToDash:setWord(3, (getAin(LFStabIn)*100)//1 )
		CanToDash:setWord(5, (getAin(3)*100)//1 )
		CanToDash:setWord(7, (getAin(4)*100)//1 )
		CanToDash:process()
		CanToDash1:setWord(1, (getAin(5)*100)//1 )
		CanToDash1:setWord(3, (getAin(6)*100)//1 )
		CanToDash1:setWord(5, (getAin(7)*100)//1 )
		CanToDash1:setWord(7, (getAin(8)*100)//1 )
		CanToDash1:process()
		CanToDash2:setWord(1, (getAin(9)*100)//1 )
		CanToDash2:setWord(3, (getAin(10)*100)//1 )
		CanToDash2:setWord(5, (getAin(11)*100)//1 )
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
		--Завершение блока обмена по CAN
		Pillow1:setData(getAin(1),p1H)
		Pillow2:setData(getAin(2),p2H)
		Pillow3:setData(getAin(3),p3H)
		Pillow4:setData(getAin(4),p4H)
		KeyBoard:process()
		
		KeyBoard15:setLedGreen( 1, ( WORK_MODE == 2) )
		
		if ((WORK_MODE  == 0) or (Alarm == true)) then
			AlarmState()
			if  (getAin(MainIn) > 8) then
				WORK_MODE = not Alarm and 1 or 0
			end
			FlashTimer:process( true,  not FlashEnabel  )
			FlashCounter:process(FlashTimer:get(),false, false )
			KeyBoard15:setLedRed  ( 1, FlashCounter:get() == 1 )
			KeyBoard15:setLedBlue ( 1, false )
		else
		
		-- Калибровочный режим работы
		if WORK_MODE  == 1  then
		    if (KeyBoard:getKey(1) == false) then
				LSF.manualControl(
			 
			else
				WORK_MODE = 2
			end
		
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
		  if WORK_MODE  == 1 then 
		  --ручной режим работы
		  
		  
		  
		 
		  --конец ручного режима работы
		  else 
		  -- блок выбора режима работ
		   Pillow1:process( highmode, KeyBoard:getToggle(12))
		   Pillow2:process( highmode, KeyBoard:getToggle(12))
		   Pillow3:process( highmode, KeyBoard:getToggle(12))
		   Pillow4:process( highmode, KeyBoard:getToggle(12))
		   if  KeyBoard:getKey(11)  then highmode = 0 end
           if  KeyBoard:getKey(12)  then highmode = 1 end
	       if  KeyBoard:getKey(13)  then highmode = 2 end
		 
		  end
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