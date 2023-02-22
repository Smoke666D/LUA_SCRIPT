--Библиотека повортников
--Для начала работы необходмо создать объект типа TurnSygnals при помощи метода :new( <ппериод мигания> ) Имеется ввиду полуприод мигания, т.е. если поставить в
--качестве парамерта 500, то период работы будет 1с, 500 мс горит, 500 не горит.
--После этого в основной цикл надо вставить метод :process( <разрешение работы>, <левый поворот>, <правый поворт>, <аварийка>)  
--АPI для работы с библиотекой
--getRight() возврашает true или false. Сосояние сигнала правого повортника. При установленном в true cсигнале метода process на выходе функции миающей с периодом установленном в :new
--сигнал. При этом сигнал левого повортника не блокируется и работает независимо
--getLeft()возврашает true или false. Сосояние сигнала левого повортника. При установленном в true cсигнале метода process на выходе функции миающей с периодом установленном в :new
--сигнал. При этом сигнал правого повортника не блокируется и работает независимо
--getAlarm () возврашает true или false. Сосояние сигнала аварийки. При установленном в true cсигнале метода process на выходе функции миающей с периодом установленном в :new
--сигнал. При этом сигнлы првого и левого повортинка будут false
TurnSygnals = {}
TurnSygnals.__index = TurnSygnals
function TurnSygnals:new ( inDelay )
	local obj = {                           delay    = (type(inDelay) =="number") and inDelay or 100,
						counter  = 0,
						state    = true,
						outLeft  = false,
						outRight = false,
						outAlarm = false }
	setmetatable( obj, self )
	return obj
end
function TurnSygnals:process ( enb, left, right, alarm )
		if (type(enb)=="boolean") and (type(left)=="boolean") and (type(right)=="boolean") and (type(alarm)=="boolean") then
			if left or right or alarm then
				self.counter = self.counter + getDelay()
				if ( self.counter > self.delay )  then
					self.state    = not self.state
					self.counter  = 0
				end
			else
				self.state    = true
				self.counter  = 0
			end
			self.outLeft  = left  and self.state and enb and (not alarm)
			self.outRight = right and self.state and enb and (not alarm)
			self.outAlarm = alarm and self.state and enb
		end
end
function TurnSygnals:getRight()
	return self.outRight
end
function TurnSygnals:getLeft()
	return self.outLeft
end
function TurnSygnals:getAlarm ()
	return self.outAlarm
end
