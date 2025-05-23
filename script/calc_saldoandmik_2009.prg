gnHandle2009 = SQLCONNECT('narvalv2009','vlad')

IF gnHandle2009 < 0 
	MESSAGEBOX('Error in conn 2009')
	return
ENDIF

gnHandle = SQLCONNECT('narvalvpg','vlad')

IF gnHandle < 0 
	MESSAGEBOX('Error in conn 2010')
	return
ENDIF

lcString = "select id, nimetus from rekv where parentid <> 9999 and id <> 3"

lnError = SQLEXEC(gnHandle2009,lcString,'qryRekv')
IF lnError < 1
	MESSAGEBOX('Viga')
	SET STEP ON 
	return
ENDIF

SELECT qryRekv
SCAN FOR id <> 3
*	FOR i = 1 TO 12
		i = 12
		WAIT WINDOW 'Arvestan..'+ALLTRIM(qryRekv.nimetus)+STR(i) nowait
		IF i < 12 
			lnPaev = DAY(DATE(2009,i+1,1)-1)
		ELSE
			lnPaev = 31
		ENDIF
			
		lcKpv = "DATE(2009,"+STR(i,2)+","+STR(lnPaev,2)+")"
*!*			lcString = " select count(id)::integer as id from saldoandmik where rekvid = "+STR(qryRekv.id)+ " and aasta = 2009 and kuu = "+STR(i)
*!*			lnError = SQLEXEC(gnHandle,lcString,'qryTMP')
*!*			IF lnError < 0 
*!*				MESSAGEBOX('Viga')
*!*				SET STEP ON 
*!*				EXIT			
*!*			ENDIF
*!*			IF RECCOUNT('qryTmp') = 0 OR  qryTmp.id =  0  	
			lcString = "select sp_saldoandmik_report("+STR(qryRekv.id,9)+","+lcKpv+",2,0)"
			lnError = SQLEXEC(gnHandle2009,lcString,'qryTMP')
			IF lnError < 0 
				MESSAGEBOX('Viga')
				SET STEP ON 
				EXIT			
			ENDIF
	        tcTimestamp = ALLTRIM(qryTMP.sp_saldoandmik_report)
	        lcString = "select LEFT(konto,6) as konto, tp, tegev, allikas, rahavoo, sum(db) as db, sum(kr) as kr, nimetus from tmp_saldoandmik where rekvid = "+STR(qryRekv.id)+" and timestamp = '"+tcTimestamp+"' group by konto, tp, tegev, allikas, rahavoo, nimetus order by konto, tp, tegev, allikas, rahavoo  "
	        leRror = sqlexec(gnHandle2009,lcString,'qrysaldoandmik')
			IF lnError < 0 
					MESSAGEBOX('Viga')
					SET STEP ON 
					EXIT			
			ENDIF			

			WAIT WINDOW 'Arvestan..'+ALLTRIM(qryRekv.nimetus)+STR(i)+'kustutan vanaandmed..' nowait
				lcString = "delete from saldoandmik where rekvid = "+STR(qryRekv.id)+;
					" and kuu = "+ STR(i,2)+" and aasta = 2009"
				lError = sqlexec(gnHandle,lcString)				
				IF lnError < 0 
						MESSAGEBOX('Viga')
						SET STEP ON 
						EXIT			
				ENDIF			

			* omatp
			
			lcString = "select fnc_getomatp("+STR(qryRekv.id,3)+",2009)"
			lnError = SQLEXEC(gnHandle2009,lcString,'qryTp')
			
			lcOmatp = ALLTRIM(qryTp.fnc_getomatp)


			SELECT qrySaldoandmik		
			* arvestame summad kontrolimiseks
			
			sum db TO lnDb
			SUM kr TO lnKr
			
			
			SCAN
				WAIT WINDOW 'Arvestan..'+ALLTRIM(qryRekv.nimetus)+STR(i)+'salvestan rea:'+ALLTRIM(STR(RECNO('qrySaldoandmik')))+'/'+ALLTRIM(STR(RECCOUNT('qrySaldoandmik'))) nowait
				lcString = "insert into saldoandmik (nimetus, db, kr, konto, tegev, tp, allikas, rahavoo, kpv, aasta, rekvid, omatp, tyyp, kuu) values ('"+;
						ALLTRIM(qrySaldoandmik.nimetus)+"',"+STR(qrySaldoandmik.db,14,2)+","+STR(qrySaldoandmik.kr,14,2)+",'"+;
						ALLTRIM(qrySaldoandmik.konto)+"','"+ALLTRIM(qrySaldoandmik.tegev)+"','"+ALLTRIM(qrySaldoandmik.tp)+"','"+;
						ALLTRIM(qrySaldoandmik.allikas)+"','"+ALLTRIM(qrySaldoandmik.rahavoo)+"',"+lcKpv+",2009,"+STR(qryRekv.id,3)+",'"+;
						lcOmaTp+"',0,"+STR(i,2)+")"

				lError = sqlexec(gnHandle,lcString)				
				IF lnError < 0 
						MESSAGEBOX('Viga')
						SET STEP ON 
						EXIT			
				ENDIF			
							
			ENDSCAN
			
			* kontollime kas summad on �ige
			WAIT WINDOW 'Arvestan..'+ALLTRIM(qryRekv.nimetus)+STR(i)+'Kontrollin summad..' nowait
			
			lcString = "select sum(db) as db, sum(kr) as kr from saldoandmik where rekvid = "+STR(qryRekv.id)+;
				" and kuu = "+ STR(i,2)+" and aasta = 2009"
				
			lnError = SQLEXEC(gnHandle,lcString,'qryKontrol')	
				IF lnError < 0 
						MESSAGEBOX('Viga')
						SET STEP ON 
						EXIT			
				ENDIF			
				WAIT WINDOW 'Arvestan..'+ALLTRIM(qryRekv.nimetus)+STR(i)+'Kontrollin summad..'+ALLTRIM(STR(qryKontrol.db,14,2))+"-"+ALLTRIM(STR(lnDb,14,2))+;
					"  "+ALLTRIM(STR(qryKontrol.kr,14,2))+"-"+alltrim(STR(lnKr,14,2)) TIMEOUT 3		
				
*		ENDIF
	

*	ENDFOR
	IF lnError < 0 
		EXIT		
	endif
	
ENDSCAN


=SQLDISCONNECT(gnHandle2009)

=SQLDISCONNECT(gnHandle)