gnHandle = sqlconnect('NarvalvPg')
if gnHandle < 0 
	messagebox('Viga uhendus')
	return
endif

select n4 as kood, n6 as regkood from tp where not empty(n4) and len(ltrim(rtrim(n4))) = 6 into cursor tmpTp

select tmpTp
scan
	wait window tmptp.kood+' '+str(recno('tmptp'))+'/'+str(reccount('tmpTp')) nowait
	lcString = "select id from library where kood = '"+alltrim(tmpTp.kood)+"'"+" and library = 'TP'"
	lError = sqlexec(gnhandle,lcString,'qryId')
	if lError < 0 
		set step on
	endif
	if used('qryid') and reccount('qryId') > 0 and qryid.id > 0
		wait window 'Updating ..' nowait
		lcString = "update library set tun1 = "+tmptp.regkood+" where id = "+str(qryid.id,9)
		lError = sqlexec(gnhandle,lcString,'qryId')
		if lError > 0
			wait window 'Updating ..Ok' nowait
		else
			wait window 'Updating .. viga' nowait
			set step on
		endif
			
	endif
endscan

=sqldisconnect(gnhandle)