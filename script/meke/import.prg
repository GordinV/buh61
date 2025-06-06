lnSoeVesiNomId = 115
lcMotteKpv = 'date(2010,11,30)'
lCheck = 0

gnHandle = SQLCONNECT('mekearv')
IF gnHandle < 0
	messagebox('Uhnduse viga',0,'Viga',10)
	return
ENDIF

IF !USED('base')
	USE ('C:\avpsoft\files\buh61\meke\base.dbf') in 0
ENDIF

IF !USED('vodmer')
	USE ('C:\avpsoft\files\buh61\meke\vodmer.dbf') IN 0
ENDIF


SELECT 0

CREATE CURSOR tmpIsikud (ls c(20), nimi c(254))

lcFile = 'c:\avpsoft\files\buh61\meke\newbase1.xls'
*IMPORT FROM (lcFile)
APPEND FROM (lcFile) TYPE XL5

SELECT tmpIsikud
SCAN FOR ls <> 'LS'
	WAIT WINDOW 'Import (isikud)..'+STR(RECNO('tmpIsikud'))+'/'+str(RECCOUNT('tmpIsikud')) nowait
	* kontrolin kas see isik on andmebaasis
	
	lcString = "select id from asutus where regkood = '"+ALLTRIM(tmpIsikud.ls) +"'"
	lnError = SQLEXEC(gnHandle,lcString,'tmpId')
	IF lnError < 0 
		MESSAGEBOX('P�ringu viga')
		exit
	ENDIF
	IF RECCOUNT('tmpId') < 1 or EMPTY(tmpId.id) 
		* isik puudub 
		lcString = " INSERT into asutus (rekvid,regkood, nimetus) values (1,'"+ALLTRIM(tmpIsikud.ls)+"','"+;
			ALLTRIM(tmpIsikud.nimi)+"')"
		lnError = SQLEXEC(gnHandle,lcString)
		IF lnError < 0 
			MESSAGEBOX('P�ringu viga')
			SET STEP on
			EXIT
		ELSE
		lcString = "select id from asutus where regkood = '"+ALLTRIM(tmpIsikud.ls) +"'"
		lnError = SQLEXEC(gnHandle,lcString,'tmpId')
		IF lnError < 0 
			MESSAGEBOX('P�ringu viga')
			EXIT
		else
			WAIT WINDOW 'Import (isikud)..inserted'+STR(RECNO('tmpIsikud'))+'/'+str(RECCOUNT('tmpIsikud')) nowait			
		ENDIF
		
		ENDIF		
	endif
	
	* objekted
	 select base
	 SCAN FOR ALLTRIM(base.ls) = ALLTRIM(tmpIsikud.ls)

		WAIT WINDOW 'Import (objekted)..'+STR(RECNO('tmpIsikud'))+'/'+str(RECCOUNT('tmpIsikud')) nowait

	 	* kontrolin kas on objekt
	 	lcString = "select library.id from library inner join objekt on library.id = objekt.libid and objekt.asutusid = "+;
	 		STR(tmpId.id,9)+" and library.kood = '"+ALLTRIM(base.addshort)+"'"
	 	lnError = SQLEXEC(gnHandle,lcString,'tmpObjId')	
	 	IF lnError < 0
	 		MESSAGEBOX('Viga') 
	 		SET STEP ON  		
	 	endif
	  	IF RECCOUNT('tmpObjId') = 0
	  		* uus ojekt
	  		
	  		* otsime parentobjekt
		 	lcString = "select library.id from library inner join objekt on library.id = objekt.libid and objekt.asutusid = 0 and library.kood = '"+ALLTRIM(base.house)+"'"
	  		
		 	lnError = SQLEXEC(gnHandle,lcString,'tmpParObjId')	
		 	IF lnError < 0
	 			MESSAGEBOX('Viga') 
	 			SET STEP ON  		
		 	ENDIF
		 	IF reccount('tmpParObjId') = 0
		 		* dom puudub
	  		lcString = "select sp_salvesta_objekt(0,1,'"+ALLTRIM(base.house)+"','"+ALLTRIM(base.house)+"',SPACE(1),1,0,0,0,0,0,0,"+;
	  			" 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,SPACE(1))"
		
			lnError = SQLEXEC(gnHandle,lcString,'tmpParObjekt')
				IF lnError < 0
					MESSAGEBOX('Viga')
					SET STEP ON 
					EXIT				
				ENDIF
		 		lnParentObjektId = tmpParObjekt.sp_salvesta_objekt
		 	ELSE
		 		lnParentObjektId = tmpParObjId.id
		 	ENDIF

		WAIT WINDOW 'Import (parent objekt korras)..'+STR(RECNO('tmpIsikud'))+'/'+str(RECCOUNT('tmpIsikud')) nowait
		 		  		
	  		lcString = "select sp_salvesta_objekt(0,1,'"+ALLTRIM(base.addshort)+"','"+ALLTRIM(base.addslong)+"',SPACE(1),1,0,0,0,0,0,0,"+;
	  			STR(tmpId.id,9)+",0,"+STR(base.people,1)+","+STR(base.rooms,1)+",0,"+STR(lnParentObjektId,9)+","+STR(base.hotwater,1)+","+;
	  			STR(base.shot,9,2)+","+STR(base.sbath,9,2)+","+STR(base.heating,1)+",0,0,0,0,0,0,SPACE(1))"
		
			lnError = SQLEXEC(gnHandle,lcString,'tmpObjekt')
			IF lnError < 0
				MESSAGEBOX('Viga')
				SET STEP ON 
				EXIT				
			ENDIF
			
			lnObjektId = tmpObjekt.sp_salvesta_objekt
		ELSE
			lnObjektId = tmpObjId.id
		ENDIF
		WAIT WINDOW 'Import (objekt korras)..'+STR(RECNO('tmpIsikud'))+'/'+str(RECCOUNT('tmpIsikud')) nowait
				
		
		* vodmer
		SELECT vodmer
		scan FOR ALLTRIM(vodmer.ls) = ALLTRIM(tmpIsikud.ls) AND ALLTRIM(vodmer.addshort) = ALLTRIM(base.addshort)

		
			WAIT WINDOW 'Import (motte leitud)..'+STR(RECNO('tmpIsikud'))+'/'+str(RECCOUNT('tmpIsikud')) nowait
			* otsime motte
			
			lcString = "select id from library where library = 'MOTTED' and kood = '"+LEFT(ALLTRIM(vodmer.addshort)+'/'+alltrim(vodmer.nr),20)+"'"
			lnError = SQLEXEC(gnHandle,lcString,'tmpMotte')
			IF lnError < 0
				MESSAGEBOX('Viga')
				SET STEP ON 
				EXIT				
			ENDIF
			IF RECCOUNT('tmpMotte') < 1
				* motte puudub, lisame
				
				lcString = "insert into library (rekvid, kood, nimetus, library, tun1, tun2, tun3) values (1,'"+;
					LEFT(ALLTRIM(vodmer.addshort)+'/'+alltrim(vodmer.nr),20)+"','soevesi','MOTTED',1,"+STR(lnObjektId ,9)+","+STR(lnSoeVesiNomId,9)+")"

				lnError = SQLEXEC(gnHandle,lcString)
				IF lnError < 0
					MESSAGEBOX('Viga')
					SET STEP ON 
					EXIT				
				ENDIF
				lcString = "select id from library where library = 'MOTTED' and kood = '"+LEFT(ALLTRIM(vodmer.addshort)+'/'+alltrim(vodmer.nr),20)+"'"
				lnError = SQLEXEC(gnHandle,lcString,'tmpMotte')
				IF lnError < 0
					MESSAGEBOX('Viga')
					SET STEP ON 
					EXIT				
				ENDIF
				WAIT WINDOW 'Import (motte inserted)..'+STR(RECNO('tmpIsikud'))+'/'+str(RECCOUNT('tmpIsikud')) nowait

			ENDIF
								
			* sisestame andmed					
			lcString = "select id from counter where parentid = "+STR(tmpMotte.id,9)+" and kpv = "+lcMotteKpv
				lnError = SQLEXEC(gnHandle,lcString,'tmpMotteAndmed')
				IF lnError < 0
					MESSAGEBOX('Viga')
					SET STEP ON 
					EXIT				
				ENDIF
			IF RECCOUNT('tmpMotteAndmed') = 0
				*andmed puuduvad, sisestame
				lcString = "select sp_salvesta_counter(0, "+STR(tmpMotte.id,9)+","+lcMotteKpv+"," +STR(vodmer.v10,9)+","+STR(vodmer.v11,9)+",SPACE(1))"
				lnError = SQLEXEC(gnHandle,lcString)
				IF lnError < 0
					MESSAGEBOX('Viga')
					SET STEP ON 
					EXIT				
				ENDIF
		
				WAIT WINDOW 'Import (motte andmed inserted)..'+STR(RECNO('tmpIsikud'))+'/'+str(RECCOUNT('tmpIsikud')) nowait

			ENDIF				
		ENDSCAN 
		*vodmer
		
		* lepingud
		
		lcString = " select id from leping1 where number = '"+ALLTRIM(base.addshort)+"'"
		lnError = SQLEXEC(gnHandle,lcString,'tmpLep1Id')
			IF lnError < 0
				MESSAGEBOX('Viga')
				SET STEP ON 
				EXIT				
			ENDIF
		IF RECCOUNT('tmpLep1Id') < 1
			WAIT WINDOW 'Import (leping)..'+STR(RECNO('tmpIsikud'))+'/'+str(RECCOUNT('tmpIsikud')) nowait
			
			IF base.heating = 1 
				lnPakketId = 38536
			ELSE
				lnPakketId = 38522			
			endif
			
			lcString = "select sp_salvesta_leping1(0, "+STR(tmpId.id,9)+",1,0,'"+ALLTRIM(base.addshort)+"',DATE(2010,01,01),DATE(2020,12,31),'Leping',SPACE(1),"+;
				"space(1),"+STR(lnPakketId,9)+","+STR(lnObjektId,9)+")"

			lnError = SQLEXEC(gnHandle,lcString,'tmpLep1Id')
				IF lnError < 0
					MESSAGEBOX('Viga')
					SET STEP ON 
					EXIT				
				ENDIF
			lnleping1Id = tmpLep1Id.sp_salvesta_leping1					
		ELSE
			lnleping1Id = tmpLep1Id.id				
		ENDIF
		WAIT WINDOW 'Import (leping inserted)..'+STR(RECNO('tmpIsikud'))+'/'+str(RECCOUNT('tmpIsikud')) nowait
		
		
		
			
	 ENDSCAN
	 	* objekt
*!*		 IF RECno('tmpIsikud') > 100
*!*		 	exit
*!*		 endif	
	
ENDSCAN


=SQLDISCONNECT(gnHandle)


