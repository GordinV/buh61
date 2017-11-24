gnhandle = SQLConnect ('pg60')
If gnhandle < 0
	Messagebox('Viga connection','Kontrol')
	Set Step On
	Return
Endif
grekv = 1
gversia = 'PG'
SET STEP ON 
lError = chk_grupps()
IF lError = .t.
	lError = pg_grant_views()
ENDIF
IF lError = .t.
	lError = pg_grant_tables()
ENDIF
IF lError = .t.
	lError = pg_grant_proc()
ENDIF

=SQLDISCONNECT(gnhandle)


FUNCTION chk_grupps
	Wait Window 'Groups kontrolimine ' Nowait
	If !CHECK_obj_pg('GROUP','DbPeakasutaja')
		lcString = " CREATE GROUP DbPeakasutaja "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If !CHECK_obj_pg('GROUP','DbKasutaja')
		lcString = " CREATE GROUP DbKasutaja "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If !CHECK_obj_pg('GROUP','DbAdmin')
		lcString = " CREATE GROUP DbAdmin"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If !CHECK_obj_pg('GROUP','DbVaatleja')
		lcString = " CREATE GROUP DbVaatleja "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

ENDFUNC




Function CHECK_obj_pg
	Parameters tcObjType, tcObjekt
	Do Case
		Case Upper(tcObjType) = 'TABLE'
			cString = "select relid from pg_stat_all_tables where UPPER(relname) = '"+;
				UPPER(tcObjekt)+"'"
		Case Upper(tcObjType) = 'GROUP'
			cString = "select groName from pg_group where UPPER(groName) = '"+;
				UPPER(tcObjekt)+"'"
		Case Upper(tcObjType) = 'VIEW'
			cString = "select viewname from pg_views where UPPER(viewname) = '"+;
				UPPER(tcObjekt)+"'"
	Endcase
	lError = sqlexec (gnhandle,cString,'qryHelp')
	If Reccount('qryhelp') < 1
		Return .F.
	Else
		Return .T.
	Endif
Endfunc


Function check_field_pg
	Parameters tcTable, tcObjekt
	Local lnFields, lnElement
	If Empty(tcTable) Or Empty(tcObjekt)
		Return .T.
	Endif
	cString = "select * from "+tcTable+" order by id limit 1"
	lError = sqlexec (gnhandle,cString,'qryFld')
	If lError < 1
		Return .F.
	Endif
	Select qryFld
	lnFields = Afields(atbl)
	lnElement = Ascan(atbl,Upper(tcObjekt))
	Use In qryFld
	If lnElement > 0
		lnCol = Asubscript(atbl, lnElement,2)
		If lnCol <> 1
			Return .F.
		Endif
		lnRaw = Asubscript(atbl, lnElement,1)
		Return atbl(lnRaw,2)
	Else
		Return .F.
	Endif
Endfunc

FUNCTION pg_grant_proc
 LOCAL lcString
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv1_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv1_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv1_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv1_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_dbase_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_dbase_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_dbase_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_dbase_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_config_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_config_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_config_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_config_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_saldo2_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_saldo2_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_saldo2_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_saldo2_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_vastisik_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_vastisik_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_vastisik_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_vastisik_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION left(character, integer) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION left(character, integer) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION left(character, integer) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION left(character, integer) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION str(integer) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION str(integer) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION str(integer) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION str(integer) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION alltrim(character) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION alltrim(character) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION alltrim(character) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION alltrim(character) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION datepart(character, date) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION datepart(character, date) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION datepart(character, date) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION datepart(character, date) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION sp_backup() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION sp_backup() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION sp_backup() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION sp_backup() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION check_raamat_aeg() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION check_raamat_aeg() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION check_raamat_aeg() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION check_raamat_aeg() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_rekv_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_rekv_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_rekv_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_rekv_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_aasta_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_aasta_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_aasta_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_aasta_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv1_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv1_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv1_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv1_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv3_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv3_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv3_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arv3_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arvtasu_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arvtasu_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arvtasu_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_arvtasu_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_asutus_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_asutus_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_asutus_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_asutus_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_asutusaa_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_asutusaa_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_asutusaa_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_asutusaa_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_autod_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_autod_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_autod_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_autod_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_config__after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_config__after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_config__after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_config__after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_doklausend_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_doklausend_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_doklausend_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_doklausend_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_dokprop_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_dokprop_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_dokprop_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_dokprop_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_eel_config_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_eel_config_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_eel_config_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_eel_config_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_eelarve_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_eelarve_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_eelarve_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_eelarve_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_gruppomandus_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_gruppomandus_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_gruppomandus_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_gruppomandus_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_holidays_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_holidays_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_holidays_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_holidays_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_journal_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_journal_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_journal_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_journal_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_journal1_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_journal1_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_journal1_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_journal1_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_journalid_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_journalid_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_journalid_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_journalid_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_klassiflib_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_klassiflib_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_klassiflib_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_klassiflib_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_kontoinf_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_kontoinf_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_kontoinf_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_kontoinf_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_config_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_config_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_config_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_config_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_grupp_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_grupp_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_grupp_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_grupp_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_jaak_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_jaak_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_jaak_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_jaak_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_oper_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_oper_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_oper_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_oper_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_ulehind_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_ulehind_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_ulehind_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_ladu_ulehind_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_lausdok_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_lausdok_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_lausdok_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_lausdok_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_lausend_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_lausend_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_lausend_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_lausend_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_leping1_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_leping1_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_leping1_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_leping1_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_leping2_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_leping2_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_leping2_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_leping2_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_leping3_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_leping3_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_leping3_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_leping3_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_library_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_library_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_library_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_library_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_markused_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_markused_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_markused_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_markused_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_menuisik_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_menuisik_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_menuisik_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_menuisik_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_menumodul_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_menumodul_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_menumodul_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_menumodul_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_menupohi_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_menupohi_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_menupohi_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_menupohi_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_mk_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_mk_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_mk_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_mk_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_mk1_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_mk1_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_mk1_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_mk1_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_nomenklatuur_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_nomenklatuur_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_nomenklatuur_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_nomenklatuur_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_asutus_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_asutus_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_asutus_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_asutus_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_config_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_config_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_config_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_config_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_jaak_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_jaak_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_jaak_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_jaak_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_kaart_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_kaart_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_kaart_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_kaart_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_lib_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_lib_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_lib_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_lib_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_taabel1_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_taabel1_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_taabel1_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_taabel1_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_taabel2_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_taabel2_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_taabel2_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_taabel2_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_puudumine_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_puudumine_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_puudumine_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_puudumine_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_pv_kaart_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_pv_kaart_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_pv_kaart_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_pv_kaart_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_raamat_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_raamat_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_raamat_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_raamat_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_saldo_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_saldo_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_saldo_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_saldo_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_saldo1_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_saldo1_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_saldo1_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_saldo1_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_sorder1_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_sorder1_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_sorder1_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_sorder1_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_sorder2_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_sorder2_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_sorder2_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_sorder2_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_subkonto_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_subkonto_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_subkonto_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_subkonto_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_teenused_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_teenused_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_teenused_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_teenused_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_tellimus_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_tellimus_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_tellimus_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_tellimus_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_toograf_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_toograf_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_toograf_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_toograf_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_tooleping_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_tooleping_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_tooleping_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_tooleping_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_tuludkulud_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_tuludkulud_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_tuludkulud_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_tuludkulud_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_userid_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_userid_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_userid_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_userid_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_vastisikud_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_vastisikud_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_vastisikud_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_vastisikud_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_vorder1_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_vorder1_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_vorder1_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_vorder1_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_vorder2_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_vorder2_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_vorder2_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_vorder2_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION ifnull(integer, integer) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION ifnull(integer, integer) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION ifnull(integer, integer) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION ifnull(integer, integer) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION ifnull(date, date) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION ifnull(date, date) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION ifnull(date, date) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION ifnull(date, date) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trig_i_journal_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trig_i_journal_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trig_i_journal_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trig_i_journal_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trig_i_arv_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trig_i_arv_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trig_i_arv_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trig_i_arv_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trig_i_arv1_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trig_i_arv1_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trig_i_arv1_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trig_i_arv1_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trig_d_journal_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trig_d_journal_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trig_d_journal_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trig_d_journal_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION empty(character varying) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION empty(character varying) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION empty(character varying) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION empty(character varying) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION empty(integer) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION empty(integer) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION empty(integer) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION empty(integer) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION empty(date) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION empty(date) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION empty(date) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION empty(date) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION empty(numeric) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION empty(numeric) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION empty(numeric) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION empty(numeric) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gen_lausend_mk(integer) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gen_lausend_mk(integer) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gen_lausend_mk(integer) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gen_lausend_mk(integer) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gen_lausend_palk(integer) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gen_lausend_palk(integer) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gen_lausend_palk(integer) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gen_lausend_palk(integer) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_korder1_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_korder1_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_korder1_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_korder1_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_korder2_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_korder2_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_korder2_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_korder2_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_journal_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_journal_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_journal_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_journal_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gen_lausend_kulum(integer) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gen_lausend_kulum(integer) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gen_lausend_kulum(integer) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gen_lausend_kulum(integer) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION len(character varying) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION len(character varying) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION len(character varying) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION len(character varying) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION sp_check_tasu(integer) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION sp_check_tasu(integer) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION sp_check_tasu(integer) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION sp_check_tasu(integer) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION sp_del_library(integer) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION sp_del_library(integer) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION sp_del_library(integer) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION sp_del_library(integer) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gen_lausend_arv(integer) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gen_lausend_arv(integer) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gen_lausend_arv(integer) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gen_lausend_arv(integer) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_asutus_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_asutus_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_asutus_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_asutus_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_gruppid_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_gruppid_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_gruppid_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_gruppid_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_journal_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_journal_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_journal_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_journal_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_library_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_library_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_library_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_library_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_pv_oper_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_pv_oper_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_pv_oper_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_pv_oper_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_korderid_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_korderid_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_korderid_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_korderid_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_korderid_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_korderid_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_korderid_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_korderid_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_eelarve_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_eelarve_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_eelarve_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_eelarve_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_leping1_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_leping1_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_leping1_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_leping1_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_leping2_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_leping2_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_leping2_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_leping2_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_arved_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_arved_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_arved_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_arved_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_arved_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_arved_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_arved_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_arved_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_autod_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_autod_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_autod_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_autod_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_arvtasu_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_arvtasu_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_arvtasu_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_arvtasu_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_ladu_grupp_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_ladu_grupp_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_ladu_grupp_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_ladu_grupp_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_palk_oper_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_palk_oper_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_palk_oper_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_palk_oper_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION date() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION date() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION date() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION date() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION day(date) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION day(date) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION day(date) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION day(date) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gomonth(date, integer) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gomonth(date, integer) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gomonth(date, integer) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION gomonth(date, integer) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION str(integer, integer) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION str(integer, integer) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION str(integer, integer) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION str(integer, integer) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_mk_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_mk_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_mk_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_mk_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_mk1_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_mk1_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_mk1_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_mk1_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_rekv_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_rekv_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_rekv_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_rekv_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_library_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_library_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_library_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigd_library_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION val(character varying) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION val(character varying) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION val(character varying) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION val(character varying) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION ifnull(numeric, numeric) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION ifnull(numeric, numeric) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION ifnull(numeric, numeric) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION ifnull(numeric, numeric) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_oper_before() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_oper_before() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_oper_before() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_oper_before() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_oper_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_oper_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_oper_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_palk_oper_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION month() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION month() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION month() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION month() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_pv_oper_after() TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_pv_oper_after() TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_pv_oper_after() TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION trigi_pv_oper_after() TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION sp_calc_kulum(integer) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION sp_calc_kulum(integer) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION sp_calc_kulum(integer) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION sp_calc_kulum(integer) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION f_round(numeric, numeric) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION f_round(numeric, numeric) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION f_round(numeric, numeric) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION f_round(numeric, numeric) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION dow(date) TO GROUP dbkasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION dow(date) TO GROUP dbpeakasutaja '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION dow(date) TO GROUP dbadmin '
If execute_sql(lcString) < 0
	return .f.
endif
 lcString = 'GRANT  EXECUTE  ON FUNCTION dow(date) TO GROUP dbvaatleja '
If execute_sql(lcString) < 0
	return .f.
endif

ENDFUNC


Function pg_grant_views
	lcString = 'GRANT SELECT ON TABLE curSaldo TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curSaldo TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curSaldo TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curSaldo TO GROUP DbVaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif

	lcString = 'GRANT SELECT ON TABLE kontodematrix TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE kontodematrix TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE kontodematrix TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE kontodematrix TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif

	lcString = 'GRANT SELECT ON TABLE comautod TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE comautod TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE comautod TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE comautod TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE comtooleping TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE comtooleping TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE comtooleping TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE comtooleping TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE comvastisik TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE comvastisik TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE comvastisik TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE comvastisik TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curametid TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curametid TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curametid TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curametid TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curautod TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curautod TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curautod TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curautod TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curkulum TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curkulum TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curkulum TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curkulum TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curlepingud TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curlepingud TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curlepingud TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curlepingud TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curnomjaak TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curnomjaak TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curnomjaak TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curnomjaak TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curpalkjaak TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curpalkjaak TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curpalkjaak TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curpalkjaak TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curpalkoper TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curpalkoper TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curpalkoper TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curpalkoper TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curpohivara TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curpohivara TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curpohivara TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curpohivara TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curpuudumine TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curpuudumine TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curpuudumine TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curpuudumine TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtaabel1 TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtaabel1 TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtaabel1 TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtaabel1 TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curteenused TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curteenused TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curteenused TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curteenused TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtellimus TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtellimus TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtellimus TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtellimus TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtoograafik TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtoograafik TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtoograafik TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtoograafik TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curvara TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curvara TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curvara TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curvara TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curvastisikud TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curvastisikud TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curvastisikud TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curvastisikud TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curladuarved TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curladuarved TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curladuarved TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curladuarved TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtasud TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtasud TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtasud TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtasud TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtood TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtood TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtood TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtood TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtsd TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtsd TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtsd TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curtsd TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curvaravendor TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curvaravendor TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curvaravendor TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curvaravendor TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE qryperiods TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE qryperiods TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE qryperiods TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE qryperiods TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE subkontodematrix TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE subkontodematrix TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE subkontodematrix TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE subkontodematrix TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE wizlepingud TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE wizlepingud TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE wizlepingud TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE wizlepingud TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE cureelarvekulud TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE cureelarvekulud TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE cureelarvekulud TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE cureelarvekulud TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE kassatulud TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE kassatulud TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE kassatulud TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE kassatulud TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE kassakulud TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE kassakulud TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE kassakulud TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE kassakulud TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE kassakontod TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE kassakontod TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE kassakontod TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE kassakontod TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curkassatuludetaitmine TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curkassatuludetaitmine TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curkassatuludetaitmine TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curkassatuludetaitmine TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curkassakuludetaitmine TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curkassakuludetaitmine TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curkassakuludetaitmine TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curkassakuludetaitmine TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE cureelarve TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE cureelarve TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE cureelarve TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE cureelarve TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curjournal TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curjournal TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curjournal TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE curjournal TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE v_check_tasu TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE v_check_tasu TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE v_check_tasu TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE v_check_tasu TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif

	Return


Function pg_grant_tables
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE library TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE library TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE library TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE library TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE mk TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE mk TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE mk TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE mk TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE pv_oper TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE pv_oper TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE pv_oper TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE pv_oper TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE korder2 TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE korder2 TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE korder2 TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE korder2 TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_oper TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_oper TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_oper TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE palk_oper TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE tooleping TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE tooleping TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE tooleping TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE tooleping TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE menupohi TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE menupohi TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE menupohi TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE menupohi TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE puudumine TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE puudumine TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE puudumine TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE puudumine TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE arv TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE arv TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE arv TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE arv TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_lib TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_lib TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_lib TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE palk_lib TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_taabel2 TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_taabel2 TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_taabel2 TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE palk_taabel2 TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE pv_kaart TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE pv_kaart TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE pv_kaart TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE pv_kaart TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE arvtasu TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE arvtasu TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE arvtasu TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE arvtasu TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE kontoinf TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE kontoinf TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE kontoinf TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE kontoinf TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE markused TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE markused TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE markused TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE markused TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE journalid TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE journalid TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE journalid TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE journalid TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE ladu_oper TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE ladu_oper TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE ladu_oper TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE ladu_oper TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE menuisik TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE menuisik TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE menuisik TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE menuisik TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,DELETE ON TABLE raamat TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,DELETE ON TABLE raamat TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,DELETE ON TABLE raamat TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT,INSERT,DELETE ON TABLE raamat TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE journal TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE journal TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE journal TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE journal TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE korder1 TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE korder1 TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE korder1 TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE korder1 TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE aasta TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE aasta TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE aasta TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE aasta TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE config_ TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE config_ TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE config_ TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE config_ TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_asutus TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_asutus TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_asutus TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE palk_asutus TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE mk1 TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE mk1 TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE mk1 TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE mk1 TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE ladu_grupp TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE ladu_grupp TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE ladu_grupp TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE ladu_grupp TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_jaak TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_jaak TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_jaak TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE palk_jaak TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE menumodul TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE menumodul TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE menumodul TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE menumodul TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_kaart TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_kaart TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_kaart TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE palk_kaart TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE subkonto TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE subkonto TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE subkonto TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE subkonto TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE arv1 TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE arv1 TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE arv1 TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE arv1 TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE asutusaa TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE asutusaa TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE asutusaa TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE asutusaa TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE autod TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE autod TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE autod TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE autod TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE doklausheader TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE doklausheader TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE doklausheader TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE doklausheader TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE userid TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE userid TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE userid TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE userid TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE asutus TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE asutus TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE asutus TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE asutus TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE eel_config TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE eel_config TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE eel_config TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE eel_config TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE leping3 TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE leping3 TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE leping3 TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE leping3 TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_taabel1 TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_taabel1 TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_taabel1 TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE palk_taabel1 TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE tellimus TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE tellimus TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE tellimus TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE tellimus TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE journal1 TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE journal1 TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE journal1 TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE journal1 TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE saldo TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE saldo TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE saldo TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE saldo TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE teenused TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE teenused TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE teenused TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE teenused TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE holidays TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE holidays TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE holidays TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE holidays TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_config TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_config TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_config TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE palk_config TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE dokprop TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE dokprop TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE dokprop TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE dokprop TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE leping1 TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE leping1 TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE leping1 TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE leping1 TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE doklausend TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE doklausend TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE doklausend TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE doklausend TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE rekv TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE rekv TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE rekv TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE rekv TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE ladu_config TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE ladu_config TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE ladu_config TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE ladu_config TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE klassiflib TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE klassiflib TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE klassiflib TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE klassiflib TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE nomenklatuur TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE nomenklatuur TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE nomenklatuur TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE nomenklatuur TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE ladu_jaak TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE ladu_jaak TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE ladu_jaak TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE ladu_jaak TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE leping2 TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE leping2 TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE leping2 TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE leping2 TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE toograf TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE toograf TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE toograf TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE toograf TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE dbase TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE dbase TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE dbase TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE dbase TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE eelarve TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE eelarve TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE eelarve TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE eelarve TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE aa TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE aa TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE aa TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE aa TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE vastisikud TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE vastisikud TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE vastisikud TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE vastisikud TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE gruppomandus TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE gruppomandus TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE gruppomandus TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE gruppomandus TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_tmpl TO GROUP dbpeakasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_tmpl TO GROUP dbkasutaja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE palk_tmpl TO GROUP dbadmin '
	If execute_sql(lcString) < 0
		Return .F.
	Endif
	lcString = 'GRANT SELECT ON TABLE palk_tmpl TO GROUP dbvaatleja '
	If execute_sql(lcString) < 0
		Return .F.
	Endif

Endfunc


Function execute_sql
	Parameters tcString, tcCursor
	If !Used('qryLog')
		Create Cursor qryLog (Log m)
		Append Blank
	Endif

	If Empty(tcCursor)
		lError = sqlexec(gnhandle,tcString)
	Else
		lError = sqlexec(gnhandle,tcString, tcCursor)
	Endif
	lcError = ' OK'
	If lError < 1
		lnErr = Aerror(err)
		If lnErr > 0
			lcError = err(1,3)
		Endif
	Endif
	Replace qryLog.Log With tcString +lcError+Chr(13) Additive In qryLog
	Return lError




