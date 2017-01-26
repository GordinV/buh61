*!*	grekv = 27
*!*	gnhandle = sqlconnect ('narva','vladislav','654')
*!*	cstring = 'select * from journalid where rekvid = '+str (grekv)
*!*	Create table  idwrong free (id int, journalid int)
*!*	=sqlexec (gnhandle,cstring,'qryJournalId')
*!*	If !used ('journalid')
*!*		Use journalid in 0
*!*	Endif
*!*	If !used ('journal')
*!*		Use journal in 0
*!*	Endif
*!*	If !used ('buh50trans')
*!*		Use buh50trans in 0
*!*	Endif
*!*	Select qryjournalId
*!*	Scan
*!*		Wait window str (recno('qryjournalId'))+'/'+str (reccount ('qryjournalId')) nowait
*!*		Select buh50trans
*!*		Locate for tbl = 'JOURNALID' and iddest = qryjournalId.id
*!*		If !found ()
*!*			Set step on
*!*		Endif
*!*		Select journalid
*!*		Locate for id = buh50trans.idsource
*!*		If !found ()
*!*			Insert into idwrong (id) values (qryjournalId.id)
*!*		Endif

*!*		Select journal
*!*		Locate for id = journalid.journalid

*!*		If !found ()
*!*			Insert into idwrong (id, journalid) values (qryjournalId.journalid,qryjournalId.id)
*!*			cstring = 'delete from journalid where id = '+ str (qryjournalId.id) +' and rekvid = 27'
*!*			lerror =sqlexec (gnhandle,cstring)
*!*			If lerror < 1
*!*				Set step on
*!*			Endif
*!*		Endif
*!*	Endscan
*!*	Select idwrong
*!*	Brow
*!*	=sqldisconnect (gnhandle)


*!*	Function chkLibrary
grekv = 27
gnhandle = sqlconnect ('narva','vladislav','654')
cstring = 'select id from journal where rekvid = 27'
Create table  idwronglib free (id int, libid int)
=sqlexec (gnhandle,cstring,'qryJournal')
If !used ('Journal')
	Use journal in 0
Endif
If !used ('buh50trans')
	Use buh50trans in 0
Endif
lerror = 0
=sqlexec (gnhandle,'begin transaction')
set delete off
select journal
scan
	wait window str (recno('journal')) + '/' + str (reccount ('journal')) nowait
	if deleted('journal')	
		&& ÔÓ‚ÂˇÂÏ ÂÒÚ¸ ÎË Á‡ÔËÒ¸ ‚ Ú‡·Î Ì‡ ÒÂ‚ÂÂ. ≈ÒÎË ÂÒÚ¸ - Û‰‡ÎˇÂÏ
		select buh50trans
		locate for tbl = 'JOURNAL' and idsource = journal.id
		if found ()
			select qryJournal
			locate for id = buh50trans.iddest
			if found ()
				cString = 'delete from journal where id = ' + str (qryjournal.id)
				lerror = sqlexec (gnhandle,cstring)
				if lerror < 0
					exit
				endif
			endif 
		endif
	endif
	
endscan
set delete on


*!*		Select library
*!*	Scan
*!*		Wait window [Kontroling:]+str (recno('library'))+'/'+str (reccount ('library')) nowait
*!*		If library.library = 'DOK' or;
*!*				library.library = 'VARAGRUPP' or;
*!*				library.library = 'OSAKOND' or;
*!*				library.library = 'PALK' or;
*!*				library.library = 'TUNNUS' or;
*!*				library.library = 'POHIVARA'

*!*			Select buh50trans
*!*			Locate for tbl = 'LIBRARY' and ;
*!*				idsource = library.id
*!*			If !found ()
*!*					lnAnswer = messagebox('Kas lisada?',1+16+0,'Kontrol')
*!*				
*!*					If lnAnswer = 1
*!*					if used ('qrylastnum')
*!*						use in qrylastnum
*!*					endif	
*!*						cstring = "insert into library (rekvid, kood, nimetus, library) values (27,'"+;
*!*							library.kood+"','"+ ltrim(rtrim(library.nimetus))+"','"+ library.library+"')'"
*!*						 = sqlexec (gnhandle,cstring,'qrylastnum')
*!*						if  used ('qrylastnum') and qryLastnum.id > 0
*!*							insert into buh50trans (tbl, idsource, iddest) values ('LIBRARY',library.id, library.dest)
*!*						endif
*!*						use in qrylastnum
*!*					Endif
*!*			Else
*!*				Select qryLibrary
*!*				Locate for id = buh50trans.iddest
*!*				If qryLibrary.library <> library.library
*!*					if used ('qrylastnum')
*!*						use in qrylastnum
*!*					endif	
*!*					cstring = "insert into library (rekvid, kood, nimetus, library) values (27,'"+;
*!*						library.kood+"','"+ ltrim(rtrim(library.nimetus))+"','"+ library.library+"')"
*!*					= sqlexec (gnhandle,cstring,'qrylastnum')
*!*					If  used ('qrylastnum') and qrylastnum.tbl = 'LIBRARY'
*!*						Insert into idwronglib (id, libid, kood, library) values (buh50trans.iddest,qrylastnum.id, library.kood, library.library)

*!*						Do case
*!*							Case library.library = 'TUNNUS'
*!*	&&  Œ––≈ “»–Œ¬ ¿ Õ¿ tunnus ‚ Ú‡·Î. journal
*!*								cstring = 'update journal set tunnusId = '+	STR (qrylastnum.id) +;
*!*									' where rekvid = '+str (grekv) + ' and tunnusId = '+str (buh50trans.iddest)
*!*								lerror = sqlexec (gnhandle,cstring)
*!*							Case library.library = 'DOK'
*!*	&&  Œ––≈ “»–Œ¬ ¿ Õ¿ DOKID ‚ Ú‡·Î. lausdok
*!*								cstring = 'update lausdok set dokId = '+	STR (qrylastnum.id) +;
*!*									' where dokId = '+str (buh50trans.iddest)
*!*								lerror = sqlexec (gnhandle,cstring)
*!*						Endcase
*!*						If lerror < 1
*!*							Set step on
*!*							Exit
*!*						Else
*!*							Replace buh50trans.iddest with qrylastnum.id in buh50trans
*!*						Endif
*!*					Endif
*!*				Endif
*!*			Endif
*!*		Endif
*!*	Endscan
Set step on
If lerror < 1
	=sqlexec (gnhandle,'rollback')
Else
	=sqlexec (gnhandle,'commit')
Endif
=sqldisconnect (gnhandle)
Select idwronglib
Brow

Return
