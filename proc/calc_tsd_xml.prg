Local lnError, lTSD, lnTMkokku
lnError = 1

*!*	Create Cursor fltrAruanne (kpv1 d, kpv2 d, kond Int)
*!*	Append Blank
*!*	Replace kpv1 with Date(2023,01,01), kpv2 With Date(2023,01,31), kond With 0 In fltrAruanne

*!*	gnHandle = SQLConnect('meke')
*!*	tdKPv1 = Date(2023,01,01)
*!*	tdKPv2 = Date(2023,01,31)
*!*	l_parent = 999999
*!*	gRekv = 1

*!*	SET STEP ON

Do queries\palk\tsd2015_report2.fxp
If !Used('tsd_report')
	Select 0
	Return .F.
Endif
*!*	grekv = 119
*!*	=test()

cFail = 'c:\temp\buh60\EDOK\tsd_lisa1a.xml'
cFailbak = 'c:\temp\buh60\EDOK\'+Alltrim(Str(gRekv))+'tsd'+Sys(2015)+'.bak'
If File (cFailbak)
	Erase (cFailbak)
Endif
If File(cFail)
	Rename (cFail) To (cFailbak)
Endif
Set Null On

Select Distinct isikukood As v1000, nimi As v1010, v1020 , v1030, v1040, v1050, v1060, ;
	v1070, v1080, v1090,v1100, v1110,	v1120, v1130, v1140,v1170, ;
	v1160_610,	v1160_640, v1160_650;
	from tsd_report ;
	ORDER By isikukood ;
	into Cursor qryTSD


* 110 - kinnipeetud tulumaks
Select Sum(v1170) As v110_tm, Sum(v1100) As v115_sm, Sum(v1130 + v1140) As c116_Tk, Sum(v1110) As c117_Kp ;
	FROM qryTSD Into Cursor tsd_kokku


Select Distinct v1020 As kood From tsd_report Into Cursor tmpTululiik

Set Textmerge On

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
Select qryTSD

Select Distinct v1000, v1010;
	FROM qryTSD ;
	Into Cursor tmpIsikList
Select tmpIsikList
Scan

TEXT TO lcString NOSHOW ADDITIVE

		<tsd_L1_A_Isik>
			<c1000_Kood><<ALLTRIM(tmpIsikList.v1000)>></c1000_Kood>
			<c1010_Nimi><<ALLTRIM(convert_to_utf(tmpIsikList.v1010))>></c1010_Nimi>
			<vmList>
ENDTEXT
	Select tmpTululiik
	Scan
		lcVMKood = 	get_tululiik_kood(tmpTululiik.kood,tmpIsikList.v1000)
		If !Empty(lcVMKood)
TEXT TO lcString NOSHOW ADDITIVE
					<<lcVMKood>>
ENDTEXT
		Endif
	Endscan

TEXT TO lcString NOSHOW ADDITIVE

			</vmList>
		</tsd_L1_A_Isik>
ENDTEXT
Endscan

Use In tmpTululiik
Use In tmpIsikList

TEXT TO lcString NOSHOW ADDITIVE
	</aIsikList>
</tsd_L1_0>
</tsd_vorm>
ENDTEXT

*!*	SELECT v_memo
*!*	INSERT INTO v_memo (xml) VALUES (lcString)

*!*	MODIFY MEMO v_memo.xml


lnHandle = Fcreate(cFail)  && If not create it
If lnHandle < 0     && Check for error opening file
	Messagebox(Iif(This.eesti=.T.,'Ei saa kirjutada faili','�� ���� ������� ����'),'Kontrol')
	Return .F.
Endif

=Fputs(lnHandle,lcString)
=Fclose(lnHandle)

Set Null Off

Return cFail


Function get_tululiik_kood
	Lparameters tcKood, tcIsikukood
	Local lcStr
	lcStr = ''
	lcAlias = Alias()
	Select Distinct * From qryTSD ;
		where v1020 = tcKood ;
		AND v1000 = tcIsikukood;
		INTO Cursor qryTSDtululiik

	Select qryTSDtululiik

	Scan
		lc1160 = ''
*	v1160_610,	v1160_620, v1160_65, v1160_640

		If qryTSDtululiik.v1160_610 + qryTSDtululiik.v1160_640  +  qryTSDtululiik.v1160_650  > 0
TEXT TO lc1160 NOSHOW

	 				<mvtList>
ENDTEXT

			If qryTSDtululiik.v1160_610 > 0
TEXT TO lc1160 NOSHOW ADDITIVE

					 	<tsd_L1_A_Mvt>
					 		<c1150_TuliKood>610</c1150_TuliKood>
					 		<c1160_Summa><<IIF(ISNULL(qryTSDtululiik.v1160_610),0,qryTSDtululiik.v1160_610)>></c1160_Summa>
					 	</tsd_L1_A_Mvt>
ENDTEXT
			Endif

			If qryTSDtululiik.v1160_650> 0
TEXT TO lc1160 NOSHOW ADDITIVE

						 	<tsd_L1_A_Mvt>
						 		<c1150_TuliKood>650</c1150_TuliKood>
						 		<c1160_Summa><<IIF(ISNULL(qryTSDtululiik.v1160_650),0,qryTSDtululiik.v1160_650)>></c1160_Summa>
						 	</tsd_L1_A_Mvt>
ENDTEXT
			Endif
			If qryTSDtululiik.v1160_640 > 0
TEXT TO lc1160 NOSHOW ADDITIVE

						 	<tsd_L1_A_Mvt>
						 		<c1150_TuliKood>640</c1150_TuliKood>
						 		<c1160_Summa><<IIF(ISNULL(qryTSDtululiik.v1160_640),0,qryTSDtululiik.v1160_640)>></c1160_Summa>
						 	</tsd_L1_A_Mvt>
ENDTEXT
			Endif
TEXT TO lc1160 NOSHOW ADDITIVE

			 		</mvtList>
ENDTEXT

		Endif

TEXT TO lcStr NOSHOW

				<tsd_L1_A_Vm>
					<c1020_ValiKood><<ALLTRIM(qryTSDtululiik.v1020)>></c1020_ValiKood>
					<c1030_Summa><<IIF(ISNULL(qryTSDtululiik.v1030),0,qryTSDtululiik.v1030)>></c1030_Summa>
ENDTEXT

		If Val(tcKood) < 13
TEXT TO lcStr NOSHOW ADDITIVE

					<c1040_OtMaar><<IIF(qryTSDtululiik.v1040 > 1, 1,  qryTSDtululiik.v1040)>></c1040_OtMaar>
ENDTEXT

		Endif
TEXT TO lcStr NOSHOW ADDITIVE

					<c1050_RiikKood><<ALLTRIM(qryTSDtululiik.v1050)>></c1050_RiikKood>
					<c1060_Smvm><<IIF(ISNULL(qryTSDtululiik.v1060),0,qryTSDtululiik.v1060)>></c1060_Smvm>
					<c1070_TvpVah><<IIF(ISNULL(qryTSDtululiik.v1070), 0, qryTSDtululiik.v1070)>></c1070_TvpVah>
					<c1080_KuumVah><<IIF(ISNULL(qryTSDtululiik.v1080), 0, qryTSDtululiik.v1080)>></c1080_KuumVah>
					<c1090_KuumSuur><<IIF(ISNULL(qryTSDtululiik.v1090), 0, qryTSDtululiik.v1090)>></c1090_KuumSuur>
ENDTEXT
		If qryTSDtululiik.v1020 <> '24'
TEXT TO lcStr NOSHOW ADDITIVE

					<c1100_Sm><<IIF(ISNULL(qryTSDtululiik.v1100),0,qryTSDtululiik.v1100)>></c1100_Sm>
					<c1110_Kp><<IIF(ISNULL(qryTSDtululiik.v1110),0,qryTSDtululiik.v1110)>></c1110_Kp>
					<c1130_Tk><<IIF(ISNULL(qryTSDtululiik.v1130),0,qryTSDtululiik.v1130)>></c1130_Tk>
					<c1140_Ttk><<IIF(ISNULL(qryTSDtululiik.v1140),0,qryTSDtululiik.v1140)>></c1140_Ttk>
					<c1170_Tm><<IIF(ISNULL(qryTSDtululiik.v1170),0,qryTSDtululiik.v1170)>></c1170_Tm>
ENDTEXT

		Endif

TEXT TO lcStr NOSHOW ADDITIVE

					<c1120_Tkvm><<IIF(ISNULL(qryTSDtululiik.v1120),0,qryTSDtululiik.v1120)>></c1120_Tkvm>
					<<lc1160>>
				</tsd_L1_A_Vm>
ENDTEXT

	Endscan
	Use In qryTSDtululiik
	Select (lcAlias)
	Return lcStr
Endfunc


Function test
	If !Used('tsd_report')
		Use tsd_report In 0
	Endif
	Create Cursor qryRekv (regkood c(20))
	Insert Into qryRekv (regkood) Values ('987654321')

	Create Cursor fltrAruanne (kpv1 Date Default Date(2017,01,01),  kpv2 Date Default Date(2017,01,31))
	Append Blank

	Create Cursor v_memo (XML m)
Endfunc

