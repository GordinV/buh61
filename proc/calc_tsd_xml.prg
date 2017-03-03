Local lnError, lTSD, lnTMkokku
lnError = 1

Do queries\palk\tsd2015_report2.fxp
If !Used('tsd_report')
	Select 0
	Return .F.
ENDIF

*!*	grekv = 119
*!*	=test()

cFail = 'c:\temp\buh60\EDOK\tsd_lisa1a.xml'
cFailbak = 'c:\temp\buh60\EDOK\'+Alltrim(Str(grekv))+'tsd'+Sys(2015)+'.bak'
If File (cFailbak)
	Erase (cFailbak)
Endif
If File(cFail)
	Rename (cFail) To (cFailbak)
Endif
SET NULL ON

Select DISTINCT isikukood As v1000, nimi As v1010, v1020 , v1030, v1040, v1050, v1060, ;
	v1070, v1080, v1090,v1100, v1110,	v1120, v1130, v1140,v1170, ;
	v1160_610,	v1160_620, v1160_630, v1160_640 ;
	from tsd_report ;
	ORDER BY isikukood ;
	into Cursor qryTSD


*BROWSE
* 110 - kinnipeetud tulumaks
SELECT sum(v1170) as v110_tm, sum(v1100) as v115_sm, sum(v1130 + v1140) as c116_Tk, sum(v1110) as c117_Kp ;
	FROM qryTSD INTO CURSOR tsd_kokku


SELECT DISTINCT v1020 as kood FROM tsd_report INTO CURSOR tmpTululiik
*!*	CREATE CURSOR tmpTululiik (kood c(2))
*!*	INSERT INTO tmpTululiik (kood) VALUES ('10')
*!*	INSERT INTO tmpTululiik (kood) VALUES ('22')
*!*	INSERT INTO tmpTululiik (kood) VALUES ('13')
*!*	INSERT INTO tmpTululiik (kood) VALUES ('11')
*!*	INSERT INTO tmpTululiik (kood) VALUES ('14')
*!*	INSERT INTO tmpTululiik (kood) VALUES ('21')
*!*	INSERT INTO tmpTululiik (kood) VALUES ('24')

SET TEXTMERGE ON

TEXT TO lcString ADDITIVE NOSHOW
<?xml version="1.0" encoding="UTF-8"?>
<tsd_vorm>
	<c108_Aasta><<YEAR(fltrAruanne.kpv1)>></c108_Aasta>
	<c109_Kuu><<MONTH(fltrAruanne.kpv1)>></c109_Kuu>
	<c110_Tm><<tsd_kokku.v110_tm>></c110_Tm>
	<c115_Sm><<tsd_kokku.v115_sm>></c115_Sm>
	<c116_Tk><<tsd_kokku.c116_Tk>></c116_Tk>
	<c117_Kp><<tsd_kokku.c117_Kp>></c117_Kp>
	<c118_KohustKokku><<(tsd_kokku.v110_tm + tsd_kokku.v115_sm + tsd_kokku.c116_Tk + tsd_kokku.c117_Kp)>></c118_KohustKokku>
	<laadimisViis>L</laadimisViis>	
	<regKood><<ALLTRIM(qryRekv.regkood)>></regKood>
	<vorm>TSD</vorm>
	<tsd_L1_0>
		<aIsikList>

ENDTEXT
* lisa 1
SELECT qryTSD

SELECT DISTINCT v1000, v1010 FROM qryTSD INTO CURSOR tmpIsikList
SELECT tmpIsikList
SCAN
	TEXT TO lcString NOSHOW ADDITIVE
	
		<tsd_L1_A_Isik>
			<c1000_Kood><<ALLTRIM(tmpIsikList.v1000)>></c1000_Kood>
			<c1010_Nimi><<ALLTRIM(tmpIsikList.v1010)>></c1010_Nimi>	
			<vmList>			
	ENDTEXT
	SELECT tmpTululiik
	SCAN
		lcVMKood = 	get_tululiik_kood(tmpTululiik.kood,tmpIsikList.v1000)
		IF !EMPTY(lcVMKood)
			TEXT TO lcString NOSHOW ADDITIVE
					<<lcVMKood>>
			ENDTEXT
		ENDIF
	ENDSCAN
	
	TEXT TO lcString NOSHOW ADDITIVE 
	
			</vmList>
		</tsd_L1_A_Isik>
	ENDTEXT		
endscan

USE IN tmpTululiik
USE IN tmpIsikList

TEXT TO lcString NOSHOW ADDITIVE
	</aIsikList>
</tsd_L1_0>
</tsd_vorm>
ENDTEXT

*!*	SELECT v_memo
*!*	INSERT INTO v_memo (xml) VALUES (lcString) 

*!*	MODIFY MEMO v_memo.xml


lnHandle = FCREATE(cFail)  && If not create it
If lnHandle < 0     && Check for error opening file
	Messagebox(iif(this.eesti=.t.,'Ei saa kirjutada faili','Не могу создать файл'),'Kontrol')
	Return .f.
ENDIF

=fputs(lnHandle,lcString)
=fclose(lnHandle)

SET NULL off

RETURN cFail


FUNCTION get_tululiik_kood
LPARAMETERS tcKood, tcIsikukood
LOCAL lcStr 
lcStr = ''
lcAlias = ALIAS()
SELECT distinct * from qryTSD ;
	where v1020 = tcKood ;
	AND v1000 = tcIsikukood;
	INTO CURSOR qryTSDtululiik

SELECT qryTSDtululiik
SCAN
	lc1160 = ''
*	v1160_610,	v1160_620, v1160_630, v1160_640 
	IF qryTSDtululiik.v1160_610 + qryTSDtululiik.v1160_620 +  qryTSDtululiik.v1160_630 +  qryTSDtululiik.v1160_640 > 0 
	 	TEXT TO lc1160 NOSHOW
	 	
	 				<mvtList>
		ENDTEXT
					
		IF qryTSDtululiik.v1160_610 > 0
		 	TEXT TO lc1160 NOSHOW ADDITIVE
		 	
					 	<tsd_L1_A_Mvt>
					 		<c1150_TuliKood>610</c1150_TuliKood>
					 		<c1160_Summa><<IIF(ISNULL(qryTSDtululiik.v1160_610),0,qryTSDtululiik.v1160_610)>></c1160_Summa>
					 	</tsd_L1_A_Mvt>
		 	ENDTEXT	 	
		ENDIF
		
		IF qryTSDtululiik.v1160_620 > 0
		 	TEXT TO lc1160 NOSHOW ADDITIVE
		 	 
						 	<tsd_L1_A_Mvt>
						 		<c1150_TuliKood>620</c1150_TuliKood>
						 		<c1160_Summa><<IIF(ISNULL(qryTSDtululiik.v1160_620),0,qryTSDtululiik.v1160_620)>></c1160_Summa>
						 	</tsd_L1_A_Mvt>
		 	ENDTEXT	 	
		ENDIF
		IF qryTSDtululiik.v1160_630 > 0
		 	TEXT TO lc1160 NOSHOW ADDITIVE 
		 	
						 	<tsd_L1_A_Mvt>
						 		<c1150_TuliKood>630</c1150_TuliKood>
						 		<c1160_Summa><<IIF(ISNULL(qryTSDtululiik.v1160_630),0,qryTSDtululiik.v1160_630)>></c1160_Summa>
						 	</tsd_L1_A_Mvt>
		 	ENDTEXT	 	
		ENDIF
		IF qryTSDtululiik.v1160_640 > 0
		 	TEXT TO lc1160 NOSHOW ADDITIVE 
		 	
						 	<tsd_L1_A_Mvt>
						 		<c1150_TuliKood>640</c1150_TuliKood>
						 		<c1160_Summa><<IIF(ISNULL(qryTSDtululiik.v1160_640),0,qryTSDtululiik.v1160_640)>></c1160_Summa>
						 	</tsd_L1_A_Mvt>
		 	ENDTEXT	 	
		ENDIF		
	 	TEXT TO lc1160 NOSHOW ADDITIVE
	 	
			 		</mvtList>
		ENDTEXT

	ENDIF

	TEXT TO lcStr NOSHOW
	
				<tsd_L1_A_Vm>
					<c1020_ValiKood><<ALLTRIM(qryTSDtululiik.v1020)>></c1020_ValiKood>
					<c1030_Summa><<IIF(ISNULL(qryTSDtululiik.v1030),0,qryTSDtululiik.v1030)>></c1030_Summa>
	ENDTEXT
	
	IF val(tcKood) < 13
		TEXT TO lcStr NOSHOW ADDITIVE
		
					<c1040_OtMaar><<qryTSDtululiik.v1040>></c1040_OtMaar>
		ENDTEXT
					
	ENDIF
		TEXT TO lcStr NOSHOW ADDITIVE
					
					<c1050_RiikKood><<ALLTRIM(qryTSDtululiik.v1050)>></c1050_RiikKood>
					<c1060_Smvm><<qryTSDtululiik.v1060>></c1060_Smvm>
					<c1070_TvpVah><<qryTSDtululiik.v1070>></c1070_TvpVah>
					<c1080_KuumVah><<qryTSDtululiik.v1080>></c1080_KuumVah>
					<c1090_KuumSuur><<qryTSDtululiik.v1090>></c1090_KuumSuur>
					<c1100_Sm><<qryTSDtululiik.v1100>></c1100_Sm>
					<c1110_Kp><<qryTSDtululiik.v1110>></c1110_Kp>
					<c1120_Tkvm><<qryTSDtululiik.v1120>></c1120_Tkvm>
					<c1130_Tk><<qryTSDtululiik.v1130>></c1130_Tk>
					<c1140_Ttk><<qryTSDtululiik.v1140>></c1140_Ttk>
					<c1170_Tm><<qryTSDtululiik.v1170>></c1170_Tm>
					<<lc1160>>
				</tsd_L1_A_Vm>
		ENDTEXT		
ENDSCAN
USE IN qryTSDtululiik
SELECT (lcAlias)
RETURN lcStr
ENDFUNC


FUNCTION test
IF !USED('tsd_report')
	USE tsd_report IN 0
ENDIF
CREATE CURSOR qryRekv (regkood c(20))
INSERT INTO qryRekv (regkood) VALUES ('987654321')

CREATE CURSOR fltrAruanne (kpv1 date DEFAULT DATE(2017,01,01),  kpv2 date DEFAULT DATE(2017,01,31))
APPEND blank

CREATE CURSOR v_memo (xml m)
ENDfunc	

