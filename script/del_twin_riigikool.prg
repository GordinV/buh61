SELECT id, kpv, summa, asutusId, deebet, kreedit from curjournal_ order BY kpv, summa, asutusId, dok WHERE YEAR(kpv) = 2006 AND LEFT(deebet,3) = '611' AND LEFT(kreedit,2) = '15' INTO CURSOR qryCursor

SELECT qryCursor
SCAN
	WAIT WINDOW 'Kontrol:' + STR(RECno('qryCursor')) + STR(RECCOUNT('qryCursor')) nowait
	
	SELECT count(*) as count FROM pv_oper WHERE journalid = qryCursor.id INTO CURSOR tmpCount
	
	IF tmpCount.count > 0
			* corr lausend
		* check for doubl
		SELECT id FROM curJournal_ ;
			where deebet = qryCursor.deebet ;
			and kreedit = qryCursor.kreedit ;
			AND kpv = qryCursor.kpv ;
			AND summa = qryCursor.summa ;
			AND asutusId = qryCursor.asutusId;
			AND id <> qryCursor.id ;
			AND id NOT in (select journalid FROM pv_oper);
			INTO CURSOR tmpDel
			
		* delete rec
		WAIT WINDOW 'delete:' + STR(RECno('qryCursor')) + STR(RECCOUNT('qryCursor')) nowait
		
			SELECT tmpDel
			SCAN
				DELETE FROM journal1 WHERE parentid = tmpDel.id
				DELETE FROM journal WHERE id = tmpDel.id				
			endscan
			
		USE IN tmpDel
	ENDIF
	USE IN tmpCount
endscan



