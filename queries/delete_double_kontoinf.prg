open data ? 
use buhdata5!kontoinf in 0
select * from library where library = 'KONTOD' INTO CURSOR QRYLIB
scan
	select kontoinf	
	locate for parentid = qrylib.id
	if found ()
		lnId = kontoinf.id
		delete for kontoinf.parentid = qrylib.id and kontoinf.id <> lnId 
	endif
endsca