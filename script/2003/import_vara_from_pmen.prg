Close Data All
grekv = 1
gVersia = 'MSSQL'
gnhandle = 1
glError = .F.
&&cData = 'c:\buh50\dbavpsoft\buhdata5.dbc'
&&cData = 'c:\dbase\buhdata5.dbc'
&&Open Data (cData)
Use menuitem In 0
Use menubar In 0
Use config In 0
gnHandle = SQLCONNECT('buhdata5zur','servis','zurauto')
IF gnhandle < 0
	MESSAGEBOX('Viga')
	return
endif
Set Classlib To classes\Classlib
oDb = Createobject('db')
With oDb
	.login = 'VLAD'
	.Pass = ''

	tnid = grekv
	Create Cursor qryAaRekv (aa m)
	Append Blank
	.Use ('v_aa')
	.Use ('v_arv','v_arv',.t.)
	INSERT INTO v_arv (rekvid, userid, liik, number, kpv,asutusId, arvId, operid ); 
		VALUES (1, 5, 1, '001',DATE(), 64, 2, 1)
	.Use ('v_arvread','v_arvread',.t.)
	.Use ('v_aa')
	Select v_aA
	Scan For kassapank = 1
		Replace aa With Left(v_aA.arve,20) + Space(1)+;
			str (v_aA.pank,3)+Space(1)+Left(v_aA.nimetus,60)+Chr(13) In qryAaRekv
	Endscan
Endwith
Create Cursor curKey (versia m)
Append Blank
Replace versia With 'RAAMA' In curKey
Create Cursor v_account (admin Int Default 1)
Set Step On
oDb.opentransaction()
llerror=import_vara_item()
IF llError = .t.
	odb.commit()
ELSE
	odb.rollback()
endif

Function import_vara_item
	Create Cursor tmpNom (nimetus c(254), kood c(20),kogus Y, Summa Y, hind Y)
	Create Cursor tmpMemo (zur m)
	Append Blank
	Append Memo zur From c:\temp\zur\Print.txt
	lnLines = Memlines(tmpMemo.zur)
	For i = 1 To lnLines
		Wait Window Str(i)+'/'+Str(lnLines) Nowait
		lcString = Mline(tmpMemo.zur,i)
		lcNimetus = Left(lcString,40)
		lcKood = Substr(lcString,41,10)
		lnKogus = Val(Alltrim(Substr(lcString,52,15)))
		lnSumma = Val(Alltrim(Substr(lcString,68,15)))
		If lnSumma <> 0 And lnKogus <> 0
			lnHind = lnSumma / lnKogus
		Else
			lnHind = 0
		Endif
		odb.use ('v_nomenklatuur','v_nomenklatuur',.t.)
		odb.use ('v_ladu_grupp','v_ladu_grupp',.t.)
		If !Empty(lcNimetus) And !Empty(lcKood) And lnSumma <> 0 And lnKogus > 0
			Insert Into tmpNom (nimetus, kood, kogus, hind, Summa);
				VALUES (lcNimetus, lcKood, lnKogus, lnHind, lnSumma)
			Insert Into v_nomenklatuur (rekvid,dok,nimetus, kood, hind, uhik,muud);
				VALUES (1,'LADU',lcNimetus, lcKood, lnHind, 'tk', SPACE(10))
		
			lerror = odb.cursorupdate('v_nomenklatuur')
			Insert Into v_ladu_grupp (parentid,nomId);
				VALUES (662, v_nomenklatuur.id)
			lerror = odb.cursorupdate('v_ladu_grupp')
			IF lError = .f.
				EXIT
				SET STEP ON 
			ENDIF
			INSERT INTO v_arvread (nomid, kogus, hind,summa );
			VALUES (v_nomenklatuur.id, lnKogus, lnHind, lnSumma)
		Endif
	ENDFOR
	Select tmpNom
	SELECT v_arvread
	SUM summa TO lnSumma
	replace v_arv.summa WITH lnSumma,; 
		kbmta WITH lnSumma 	IN v_arv
	lerror = odb.cursorupdate('v_arv')
	IF lError = .t.
		UPDATE v_arvread SET parentId = v_arv.id 
		lerror = odb.cursorupdate('v_arvread')
	ENDIF
	RETURN lError

Function uus_arve
	Return

FUNCTION remove_chr13_from_string

 PARAMETER tcString
 IF VARTYPE(tcString)='C' .AND. CHR(13)$tcString
      DO WHILE ATC(CHR(13), tcString)>0
           tcString = STUFFC(tcString, ATC(CHR(13), tcString), 2, SPACE(1))
      ENDDO
 ENDIF
 RETURN tcString
ENDFUNC
*
