set point to '.'
gnHandle = sqlconnect('buhdata5','sa','159')
if gnHandle < 1
	messagebox('Connection')
	return
endif
	lResult = sqlexec(gnHandle,'begin transaction')
	if lResult < 1
		return
	endif
select distinc month, year , ltrim(rtrim(bill))+ltrim(rtrim(sub_bill)) as konto,;
	st_debet - st_credit as saldo from as_saldo where empty(contr); 
	and alltrim(month) = '1';
	order by konto ;
	into cursor algsld
select algsld
scan
	cKood = alltrim(algsld.konto)
	cKood = cKood +iif(len(cKood) = 3,'0','')
	cString = "select id from library where kood = '"+cKood +"'"
	lResult = sqlexec(gnHandle,cString,'query1')
	if lResult < 1
		=viga()
		return
	endif
	cParent = str(query1.id)
	cString = " update kontoinf set algsaldo = "+str(algsld.saldo,12,2)+;
		" where parentId = "+cParent +;
		" and aasta = 2002 "  
	lResult = sqlexec(gnHandle,cString,'query1')
	if lResult < 1
		=viga()
		return
	endif
endscan
lResult = sqlexec(gnHandle,'commit transaction')
=sqldisconnect(gnHandle)	

Function viga
	if vartype(cString) = 'C'
		_cliptext = cString
	endif
		messagebox('Viga')
		set step on
		lResult = sqlexec(gnHandle,'rollback transaction')
return