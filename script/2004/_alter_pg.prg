	Local lnObj, lnElement
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

	Wait Window 'Tbl. saldo struktuuri uuendamine ' Nowait
	If !Empty(check_field_pg('sALDO','saldo'))
		lcString = "alter table saldo drop column saldo cascade"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	If !Empty(check_field_pg('SALDO','period'))
		lcString = "alter table saldo drop column period cascade"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('SALDO','kuu'))
		lcString = "alter table saldo add column kuu int "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table saldo alter column kuu set default 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table saldo alter column kuu set not null"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

	Endif
	If Empty(check_field_pg('SALDO','aasta'))
		lcString = "alter table saldo add column aasta int "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table saldo alter column aasta set default 0 "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table saldo alter column aasta set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('SALDO','asutusId'))
		lcString = "alter table saldo add column asutusId int "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table saldo alter column asutusId set default 0 "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table saldo alter column asutusId set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif

	Endif

	Wait Window 'Tbl. MENUPOHI struktuuri uuendamine ' Nowait
	If !Empty(check_field_pg('MENUPOHI','menu'))
		lcString = "alter table menupohi drop column menu "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('MENUPOHI','PAD'))
		lcString = "alter table menupohi add column pad varchar(60) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table menupohi alter column pad set default SPACE(60) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table menupohi alter column pad set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('MENUPOHI','BAR'))
		lcString = "alter table menupohi add column bar varchar(60) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table menupohi alter column bar set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table menupohi alter column bar set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('MENUPOHI','IDX'))
		lcString = "alter table menupohi add column idx int "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table menupohi alter column idx set default 0 "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table menupohi alter column idx set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Tbl. PALK_LIB struktuuri uuendamine ' Nowait
	If Empty(check_field_pg('PALK_LIB','konto'))
		lcString = "alter table palk_lib add column konto varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_lib alter column konto set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update palk_lib set konto = SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_lib alter column konto set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Tbl. aa struktuuri uuendamine ' Nowait
	If Empty(check_field_pg('AA','tp'))
		lcString = "alter table aa add column tp varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table aa alter column tp set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_lib alter column konto set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Tbl. gruppomandus struktuuri uuendamine ' Nowait
	If check_field_pg('GRUPPOMANDUS','kood1') = 'I'
		lcString = "alter table gruppomandus drop column kood1 "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table gruppomandus add column kood1 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update gruppomandus set kood1 = SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table gruppomandus alter column kood1 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table gruppomandus  alter column kood1 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If check_field_pg('GRUPPOMANDUS','kood2') = 'I'
		lcString = "alter table gruppomandus drop column kood2 "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table gruppomandus add column kood2 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update gruppomandus set kood2 = SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update gruppomandus set kood2 = SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table gruppomandus alter column kood2 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table gruppomandus  alter column kood2 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If check_field_pg('GRUPPOMANDUS','kood3') = 'I'
		lcString = "alter table gruppomandus drop column kood3 "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table gruppomandus add column kood3 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update gruppomandus set kood3 = SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table gruppomandus alter column kood3 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table gruppomandus  alter column kood3 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If check_field_pg('GRUPPOMANDUS','kood4') = 'I'
		lcString = "alter table gruppomandus drop column kood4 "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table gruppomandus add column kood4 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update gruppomandus set kood4 = SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table gruppomandus alter column kood4 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table gruppomandus  alter column kood4 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If check_field_pg('GRUPPOMANDUS','kood5')='I'
		lcString = "alter table gruppomandus drop column kood5 "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table gruppomandus add column kood5 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update gruppomandus set kood5 = SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table gruppomandus alter column kood5 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table gruppomandus  alter column kood5 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('GRUPPOMANDUS','KONTO'))
		lcString = "alter table gruppomandus add column konto varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update gruppomandus set konto = SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "alter table gruppomandus alter column konto set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table gruppomandus  alter column konto set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Tbl. pv_oper struktuuri uuendamine ' Nowait
	If Empty(check_field_pg('PV_OPER','kood1'))
		lcString = "alter table pv_oper add column kood1 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table pv_oper alter column kood1 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table pv_oper  alter column kood1 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif

	Endif
	If Empty(check_field_pg('PV_OPER','kood2'))
		lcString = "alter table pv_oper add column kood2 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table pv_oper alter column kood2 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table pv_oper  alter column kood2 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('PV_OPER','kood3'))
		lcString = "alter table pv_oper add column kood3 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table pv_oper alter column kood3 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table pv_oper  alter column kood3 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('PV_OPER','kood4'))
		lcString = "alter table pv_oper add column kood4 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table pv_oper alter column kood4 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table pv_oper  alter column kood4 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('PV_OPER','kood5'))
		lcString = "alter table pv_oper add column kood5 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table pv_oper alter column kood5 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table pv_oper  alter column kood5 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('PV_OPER','tunnus'))
		lcString = "alter table pv_oper add column tunnus varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table pv_oper alter column tunnus set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table pv_oper  alter column tunnus set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('PV_OPER','KONTO'))
		lcString = "alter table pv_oper add column konto varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table pv_oper alter column konto set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table pv_oper  alter column konto set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('PV_OPER','TP'))
		lcString = "alter table pv_oper add column tp varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table pv_oper alter column tp set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table pv_oper  alter column tp set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('PV_OPER','AsutusId'))
		lcString = "alter table pv_oper add column asutusId int"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table pv_oper alter column asutusId set default 0 "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table pv_oper  alter column asutusId set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Tbl. palk_oper struktuuri uuendamine ' Nowait
	If Empty(check_field_pg('PALK_OPER','kood1'))
		lcString = "alter table palk_oper add column kood1 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_oper alter column kood1 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_oper  alter column kood1 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('PALK_OPER','kood2'))
		lcString = "alter table palk_oper add column kood2 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_oper alter column kood2 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_oper  alter column kood2 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('PALK_OPER','kood3'))
		lcString = "alter table palk_oper add column kood3 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_oper alter column kood3 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_oper  alter column kood3 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('PALK_OPER','kood4'))
		lcString = "alter table palk_oper add column kood4 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_oper alter column kood4 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_oper  alter column kood4 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('PALK_OPER','kood5'))
		lcString = "alter table palk_oper add column kood5 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_oper alter column kood5 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_oper  alter column kood5 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('PALK_OPER','tunnus'))
		lcString = "alter table palk_oper add column tunnus varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_oper alter column tunnus set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_oper  alter column tunnus set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('PALK_OPER','KONTO'))
		lcString = "alter table palk_oper add column konto varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_oper alter column konto set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_oper  alter column konto set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('PALK_OPER','TP'))
		lcString = "alter table palk_oper add column tp varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_oper alter column tp set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_oper  alter column tp set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('PALK_OPER','TUNNUS'))
		lcString = "alter table palk_oper add column tunnus varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_oper alter column tunnus set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table palk_oper  alter column tunnus set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Tbl. mk1 struktuuri uuendamine ' Nowait
	If Empty(check_field_pg('MK1','kood1'))
		lcString = "alter table mk1 add column kood1 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table mk1 alter column kood1 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table mk1 alter column kood1 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('MK1','kood2'))
		lcString = "alter table mk1 add column kood2 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table mk1 alter column kood2 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table mk1 alter column kood2 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('MK1','kood3'))
		lcString = "alter table mk1 add column kood3 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table mk1 alter column kood3 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table mk1 alter column kood3 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('MK1','kood4'))
		lcString = "alter table mk1 add column kood4 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table mk1 alter column kood4 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table mk1 alter column kood4 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('MK1','kood5'))
		lcString = "alter table mk1 add column kood5 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table mk1 alter column kood5 set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table mk1 alter column kood5 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('MK1','tunnus'))
		lcString = "alter table mk1 add column tunnus varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table mk1 alter column tunnus set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table mk1 alter column tunnus set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('MK1','KONTO'))
		lcString = "alter table mk1 add column konto varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table mk1 alter column konto set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table mk1 alter column konto set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('MK1','TP'))
		lcString = "alter table mk1 add column tp varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table mk1 alter column tp set default SPACE(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table mk1 alter column tp set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Tbl. arv struktuuri uuendamine ' Nowait
	If Empty(check_field_pg('ARV','objektId'))
		lcString = "alter table arv add column objektId int "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update arv set ObjektId = 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv alter column ObjektId set default 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv alter column ObjektId set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Tbl. arv1 struktuuri uuendamine ' Nowait
	If check_field_pg('ARV1','kood1') = 'I'
		lcString = "alter table arv1 drop column kood1 "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 add column kood1 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update arv1 set kood1 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column kood1 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column kood1 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If check_field_pg('ARV1','kood2') = 'I'
		lcString = "alter table arv1 drop column kood2 "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 add column kood2 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update arv1 set kood2 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column kood2 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column kood2 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If check_field_pg('ARV1','kood3') = 'I'
		lcString = "alter table arv1 drop column kood3 "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 add column kood3 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update arv1 set kood3 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column kood3 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column kood3 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If check_field_pg('ARV1','kood4') = 'I'
		lcString = "alter table arv1 drop column kood4 "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 add column kood4 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update arv1 set kood4 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column kood4 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column kood4 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('ARV1','kood5'))
		lcString = "alter table arv1 add column kood5 varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update arv1 set kood5 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column kood5 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column kood5 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('ARV1','KONTO'))
		lcString = "alter table arv1 add column konto varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update arv1 set konto = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column konto set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column konto set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('ARV1','TP'))
		lcString = "alter table arv1 add column tp varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update arv1 set tp = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column tp set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column tp set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('ARV1','TUNNUS'))
		lcString = "alter table arv1 add column tunnus varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update arv1 set tunnus = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column tunnus set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column tunnus set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('ARV1','KBMTA'))
		lcString = "alter table arv1 add column kbmta numeric(12,4)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update arv1 set kbmta = 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcString = "alter table arv1 alter column kbmta set default 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column kbmta set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('ARV1','ISIKID'))
		lcString = "alter table arv1 add column isikid INT"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update arv1 set isikId = 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column IsikId set default 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table arv1 alter column IsikId set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	If Empty(CHECK_obj_pg('TABLE','PALK_TMPL'))
&& ������� ����� �������
		lcString = " CREATE TABLE palk_tmpl ( "+;
			" id serial NOT NULL, "+;
			" parentid integer NOT NULL, "+;
			" libid integer NOT NULL, "+;
			" percent_ Integer Default 0 Not Null, "+;
			" summa numeric(12,4) Default 0 Not Null, "+;
			" tulumaar Integer Default 26 Not Null, "+;
			" tulumaks Integer Default 0 Not Null, "+;
			" tunnusId Integer Default 0 Not Null )"

		If execute_sql(lcString) < 0
			Return .F.
		Endif
	endif

	If Empty(CHECK_obj_pg('TABLE','KORDER1'))
&& ������� ����� �������
		lcString = " CREATE TABLE korder1 ( "+;
			" id serial NOT NULL, "+;
			" rekvid integer NOT NULL, "+;
			" userid integer NOT NULL, "+;
			" journalid Integer Default 0 Not Null, "+;
			" kassaid Integer Default 0 Not Null, "+;
			" tyyp Integer Default 1 Not Null, "+;
			" doklausid Integer Default 0 Not Null, "+;
			" Number Character(20) Default Space(1) Not Null, "+;
			" kpv Date Default ('now'::Text)::Date Not Null, "+;
			" asutusid integer DEFAULT 0 NOT NULL, "+;
			" nimi text DEFAULT space(1) NOT NULL, "+;
			" aadress text DEFAULT space(1) NOT NULL, "+;
			" dokument text DEFAULT space(1) NOT NULL, "+;
			" alus text DEFAULT space(1) NOT NULL, "+;
			" summa numeric(12,4) DEFAULT 0 NOT NULL, "+;
			" muud text, "+;
			" arvid integer DEFAULT 0 NOT NULL, "+;
			" doktyyp integer DEFAULT 0 NOT NULL, "+;
			" dokid integer DEFAULT 0 NOT NULL) "

		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	If Empty(CHECK_obj_pg('TABLE','KORDER2'))

*!*	&& ������� ����� �������
*!*			lcString = " CREATE TABLE korder2 ( "+;
*!*				" id serial NOT NULL, "+;
*!*				" parentid integer NOT NULL, "+;
*!*				" nomid integer DEFAULT 0 NOT NULL, "+;
*!*				" nimetus character(120) DEFAULT space(1) NOT NULL, "+;
*!*				" summa numeric(12,4) DEFAULT 0 NOT NULL, "+;
*!*				" konto varchar(20) DEFAULT SPACE(20) NOT NULL, "+;
*!*				" kood1 varchar(20) DEFAULT SPACE(20) NOT NULL, "+;
*!*				" kood2 varchar(20) DEFAULT SPACE(20) NOT NULL, "+;
*!*				" kood3 varchar(20) DEFAULT SPACE(20) NOT NULL, "+;
*!*				" kood4 varchar(20) DEFAULT SPACE(20) NOT NULL, "+;
*!*				" kood5 varchar(20) DEFAULT SPACE(20) NOT NULL, "+;
*!*				" tunnus varchar(20) DEFAULT SPACE(20) NOT NULL, "+;
*!*				" tp varchar(20) DEFAULT SPACE(20) NOT NULL ) "

*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif

*!*			lcString = " GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE korder2 TO GROUP dbkasutaja "
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif
*!*			lcString = "GRANT INSERT,SELECT,UPDATE,DELETE ON TABLE korder2 TO GROUP dbpeakasutaja"
*!*			If execute_sql(lcString) < 0
*!*				Return .F.
*!*			Endif
		Endif
	If Empty(check_field_pg('KORDER2','tunnus'))
		lcString = "alter table korder2 aDD column tunnus varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update korder2 set tunnus = SPACE(1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table korder2 alter column tunnus set default SPACE(1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table korder2 alter column tunnus set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif


	Wait Window 'Tbl. dokprop struktuuri uuendamine ' Nowait
	If Empty(check_field_pg('DOKPROP','asutusId'))
		lcString = "alter table dokprop aDD column asutusid int "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update dokprop set AsutusId = 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table dokprop alter column AsutusId set default 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table dokprop alter column AsutusId set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	If Empty(check_field_pg('DOKPROP','konto'))
		lcString = "alter table dokprop aDD column konto varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update dokprop set konto = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table dokprop alter column konto set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table dokprop alter column konto set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('DOKPROP','kood1'))
		lcString = "alter table dokprop aDD column kood1 varchar(20)  "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update dokprop set kood1 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table dokprop alter column kood1 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table dokprop alter column kood1 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('DOKPROP','kood2'))
		lcString = "alter table dokprop aDD column kood2 varchar(20)  "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update dokprop set kood2 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table dokprop alter column kood2 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table dokprop alter column kood2 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('DOKPROP','kood3'))
		lcString = "alter table dokprop aDD column kood3 varchar(20)  "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update dokprop set kood3 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table dokprop alter column kood3 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table dokprop alter column kood3 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('DOKPROP','kood4'))
		lcString = "alter table dokprop aDD column kood4 varchar(20)  "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update dokprop set kood4 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table dokprop alter column kood4 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table dokprop alter column kood4 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('DOKPROP','kood5'))
		lcString = "alter table dokprop aDD column kood5 varchar(20)  "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update dokprop set kood5 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table dokprop alter column kood5 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table dokprop alter column kood5 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('DOKPROP','kbmkonto'))
		lcString = "alter table dokprop aDD column kbmkonto varchar(20)  "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update dokprop set kbmkonto = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table dokprop alter column kbmkonto set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table dokprop alter column kbmkonto set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('DOKPROP','tyyp'))
		lcString = "alter table dokprop aDD column tyyp int"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update dokprop set tyyp = 1"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table dokprop alter column tyyp set default 1"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table dokprop alter column tyyp set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If !Empty(check_field_pg('DOKPROP','kbmlausendId'))
		lcString = "alter table dokprop drop column kbmlausendId "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If !Empty(check_field_pg('DOKPROP','kbmumard'))
		lcString = "alter table dokprop drop column kbmumard "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If !Empty(check_field_pg('DOKPROP','summaumard'))
		lcString = "alter table dokprop drop column summaumard "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Tbl. nomenklatuur struktuuri uuendamine ' Nowait
	If Empty(check_field_pg('NOMENKLATUUR','ulehind'))
		lcString = "alter table nomenklatuur aDD column ulehind numeric(12,4) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update nomenklatuur set ulehind = 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table nomenklatuur alter column ulehind set default 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table nomenklatuur alter column ulehind set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('NOMENKLATUUR','kogus'))
		lcString = "alter table nomenklatuur aDD column kogus numeric(12,3) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update nomenklatuur set kogus = 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table nomenklatuur alter column kogus set default 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table nomenklatuur alter column kogus set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	If Empty(check_field_pg('NOMENKLATUUR','formula'))
		lcString = "alter table nomenklatuur aDD column formula text "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update nomenklatuur set formula = SPACE(1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table nomenklatuur alter column formula set default SPACE(1)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table nomenklatuur alter column formula set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Tbl. asutus struktuuri uuendamine ' Nowait
	If Empty(check_field_pg('ASUTUS','Tp'))
		lcString = "alter table asutus add column Tp varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update asutus set tp = space(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table asutus alter column tp set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table asutus alter column tp set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Tbl. library struktuuri uuendamine ' Nowait
	If Empty(check_field_pg('LIBRARY','tun1'))
		lcString = "alter table library add column tun1 int"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update library set tun1 = 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table library alter column tun1 set default 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table library alter column tun1 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('LIBRARY','tun2'))
		lcString = "alter table library add column tun2 int"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update library set tun2 = 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table library alter column tun2 set default 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table library alter column tun2 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('LIBRARY','tun3'))
		lcString = "alter table library add column tun3 int"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update library set tun3 = 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table library alter column tun3 set default 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table library alter column tun3 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('LIBRARY','tun4'))
		lcString = "alter table library add column tun4 int "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update library set tun4 = 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table library alter column tun4 set default 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table library alter column tun4 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('LIBRARY','tun5'))
		lcString = "alter table library add column tun5 int"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update library set tun5 = 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table library alter column tun5 set default 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table library alter column tun5 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
*!*		IF FILE ('scriptLib.prn')
*!*			CREATE CURSOR runSCRIPT(script m)
*!*			SET MEMOWIDTH TO 8000
*!*			APPEND BLANK
*!*			APPEND MEMO runSCRIPT.script from scriptLib.prn as 1252
*!*			lnRows = MEMLINES(runScript.script)
*!*			IF lnRows > 0
*!*				FOR i = 1 to lnRows
*!*					Wait Window 'Tbl. library importeerimine '+STR(i)+'/'+STR(lnRows) Nowait
*!*					lcString = MLINE(runScript.script,i)
*!*					IF !EMPTY(lcString) AND (LEFT(LTRIM(lcString),1) <> '*' OR LEFT(LTRIM(lcString),1)<> '&')
*!*						&lcString
*!*					endif
*!*				endfor
*!*			endif
*!*				ERASE scriptLib.prn recycle
*!*		endif

	Wait Window 'Tbl. klassiflib struktuuri uuendamine ' Nowait
	lcReturn = check_field_pg('KLASSIFLIB','kood1')
	If !Empty(lcReturn) And lcReturn = 'I'
		lcString = "alter table klassiflib drop column kood1 "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcReturn = .F.
	Endif
	If Empty(lcReturn)
		lcString = "alter table klassiflib aDD column kood1 varchar(20)  "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update klassiflib set kood1 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table klassiflib alter column kood1 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table klassiflib alter column kood1 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	lcReturn = check_field_pg('KLASSIFLIB','kood2')
	If !Empty(lcReturn) And lcReturn = 'I'
		lcString = "alter table klassiflib drop column kood2 "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcReturn = .F.
	Endif
	If Empty(lcReturn)
		lcString = "alter table klassiflib add column kood2 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update klassiflib set kood2 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table klassiflib alter column kood2 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table klassiflib alter column kood2 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	lcReturn =  check_field_pg('KLASSIFLIB','kood3')
	If !Empty(lcReturn) And lcReturn = 'I'
		lcString = "alter table klassiflib drop column kood3 "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcReturn = .F.
	Endif
	If Empty(lcReturn)
		lcString = "alter table klassiflib add column kood3 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update klassiflib set kood3 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table klassiflib alter column kood3 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table klassiflib alter column kood3 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	lcReturn =  check_field_pg('KLASSIFLIB','kood4')
	If !Empty(lcReturn) And lcReturn = 'I'
		lcString = "alter table klassiflib drop column kood4 "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcReturn = .F.
	Endif
	If Empty(lcReturn)
		lcString = "alter table klassiflib add column kood4 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update klassiflib set kood4 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table klassiflib alter column kood4 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table klassiflib alter column kood4 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	lcReturn =  check_field_pg('KLASSIFLIB','kood5')
	If !Empty(lcReturn) And lcReturn = 'I'
		lcString = "alter table klassiflib drop column kood5 "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcReturn = .F.
	Endif
	If Empty(lcReturn)
		lcString = "alter table klassiflib add column kood5 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update klassiflib set kood5 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table klassiflib alter column kood5 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table klassiflib alter column kood5 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If !Empty(check_field_pg('KLASSIFLIB','lausendId'))
		lcString = "alter table klassiflib drop column lausendId "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('KLASSIFLIB','KONTO'))
		lcString = "alter table klassiflib add column konto varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update klassiflib set konto = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table klassiflib alter column konto set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table klassiflib alter column konto set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Tbl. doklausend struktuuri uuendamine ' Nowait
	If check_field_pg('DOKLAUSEND','kood1') = 'I'
		lcString = "alter table doklausend drop column kood1 CASCADE "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend add column kood1 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update doklausend set kood1 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend alter column kood1 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend alter column kood1 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If check_field_pg('DOKLAUSEND','kood2') = 'I'
		lcString = "alter table doklausend drop column kood2 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend add column kood2 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update doklausend set kood2 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend alter column kood2 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend alter column kood2 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If check_field_pg('DOKLAUSEND','kood3') = 'I'
		lcString = "alter table doklausend drop column kood3 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend add column kood3 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update doklausend set kood3 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend alter column kood3 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend alter column kood3 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If check_field_pg('DOKLAUSEND','kood4') = 'I'
		lcString = "alter table doklausend drop column kood4 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend add column kood4 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update doklausend set kood4 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend alter column kood4 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend alter column kood4 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If check_field_pg('DOKLAUSEND','kood5') = 'I'
		lcString = "alter table doklausend drop column kood5 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend add column kood5 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update doklausend set kood5 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend alter column kood5 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend alter column kood5 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If !Empty(check_field_pg('DOKLAUSEND','lausendId'))
		lcString = "alter table doklausend drop column lausendId CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If !Empty(check_field_pg('DOKLAUSEND','percent_'))
		lcString = "alter table doklausend drop column percent_ "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If !Empty(check_field_pg('DOKLAUSEND','kbm'))
		lcString = "alter table doklausend drop column kbm"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('DOKLAUSEND','deebet'))
		lcString = "alter table doklausend add column deebet varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update doklausend set deebet = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend alter column deebet set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend alter column deebet set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif

	Endif
	If Empty(check_field_pg('DOKLAUSEND','kreedit'))
		lcString = "alter table doklausend add column kreedit varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update doklausend set kreedit = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend alter column kreedit set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend alter column kreedit set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('DOKLAUSEND','lisa_d'))
		lcString = "alter table doklausend add column lisa_d varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update doklausend set lisa_d = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend alter column lisa_d set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend alter column lisa_d set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif

	Endif
	If Empty(check_field_pg('DOKLAUSEND','lisa_k'))
		lcString = "alter table doklausend add column lisa_k varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update doklausend set lisa_k = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend alter column lisa_k set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table doklausend alter column lisa_k set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Tbl. eelarve struktuuri uuendamine ' Nowait
	If check_field_pg('EELARVE','kood1') = 'I'
		lcString = "alter table eelarve drop column kood1 CASCADE "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table eelarve add column kood1 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update eelarve set kood1 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table eelarve alter column kood1 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table eelarve alter column kood1 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If check_field_pg('EELARVE','kood2') = 'I'
		lcString = "alter table eelarve drop column kood2 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table eelarve add column kood2 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update eelarve set kood2 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table eelarve alter column kood2 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table eelarve alter column kood2 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If check_field_pg('EELARVE','kood3') = 'I'
		lcString = "alter table eelarve drop column kood3 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table eelarve add column kood3 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update eelarve set kood3 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table eelarve alter column kood3 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table eelarve alter column kood3 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If check_field_pg('EELARVE','kood4') = 'I'
		lcString = "alter table eelarve drop column kood4 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table eelarve add column kood4 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update eelarve set kood4 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table eelarve alter column kood4 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table eelarve alter column kood4 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	lcResult = check_field_pg('EELARVE','kood5')
	If !Empty(lcResult) And lcResult = 'I'
		lcString = "alter table eelarve drop column kood5 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

		lcResult = .F.
	Endif
	If Empty(lcResult)
		lcString = "alter table eelarve add column kood5 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update eelarve set kood5 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table eelarve alter column kood5 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table eelarve alter column kood5 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Tbl. Journal struktuuri uuendamine ' Nowait
	lcResult =  check_field_pg('JOURNAL','TunnusId')
	If !Empty(lcResult) And lcResult ='I'
		lcString = "alter table journal drop column TunnusId CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Tbl. Journal1 struktuuri uuendamine ' Nowait
	lcResult =  check_field_pg('JOURNAL1','lausendId')
	If !Empty(lcResult) And lcResult ='I'
		lcString = "alter table journal1 drop column lausendId CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	lcResult =  check_field_pg('JOURNAL1','DOKUMENT')
	If !Empty(lcResult) And lcResult ='I'
		lcString = "alter table journal1 drop column dokument CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	lcResult =  check_field_pg('JOURNAL1','kood1')
	If !Empty(lcResult) And lcResult = 'I'
		lcString = "alter table journal1 drop column kood1 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcResult = .F.
	Endif
	If Empty(lcResult)
		lcString = "alter table journal1 add column kood1 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update journal1 set kood1 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column kood1 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column kood1 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	lcResult =  check_field_pg('JOURNAL1','kood2')
	If !Empty(lcResult) And lcResult = 'I'
		lcString = "alter table journal1 drop column kood2 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcResult = .F.
	Endif
	If Empty(lcResult)
		lcString = "alter table journal1 add column kood2 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update journal1 set kood2 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column kood2 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column kood2 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	lcResult = check_field_pg('JOURNAL1','kood3')
	If !Empty(lcResult) And lcResult = 'I'
		lcString = "alter table journal1 drop column kood3 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcResult = .F.
	Endif
	If Empty(lcResult)
		lcString = "alter table journal1 add column kood3 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update journal1 set kood3 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column kood3 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column kood3 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	lcResult =  check_field_pg('JOURNAL1','kood4')
	If !Empty(lcResult ) And lcResult = 'I'
		lcString = "alter table journal1 drop column kood4 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcResult = .F.
	Endif
	If Empty(lcResult)
		lcString = "alter table journal1 add column kood4 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update journal1 set kood4 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column kood4 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column kood4 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	lcResult = check_field_pg('JOURNAL1','kood5')
	If !Empty(lcResult) And lcResult = 'I'
		lcString = "alter table journal1 drop column kood5 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcResult = .F.
	Endif
	If Empty(lcResult)
		lcString = "alter table journal1 add column kood5 varchar(20) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update journal1 set kood5 = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column kood5 set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column kood5 set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('JOURNAL1','TUNNUS'))
		lcString = "alter table journal1 add column tunnus varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update journal1 set tunnus = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column tunnus set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column tunnus set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	If Empty(check_field_pg('JOURNAL1','DEEBET'))
		lcString = "alter table journal1 add column deebet varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update journal1 set deebet = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column deebet set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column deebet set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	If Empty(check_field_pg('JOURNAL1','KREEDIT'))
		lcString = "alter table journal1 add column kreedit varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update journal1 set kreedit = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column kreedit set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column kreedit set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	If Empty(check_field_pg('JOURNAL1','LISA_D'))
		lcString = "alter table journal1 add column lisa_d varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update journal1 set lisa_d = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column lisa_d set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column lisa_d set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('JOURNAL1','LISA_K'))
		lcString = "alter table journal1 add column lisa_k varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update journal1 set lisa_k = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column lisa_k set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column lisa_k set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('JOURNAL1','VALUUTA'))
		lcString = "alter table journal1 add column valuuta varchar(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update journal1 set valuuta = SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column valuuta set default SPACE(20)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column valuuta set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('JOURNAL1','KUURS'))
		lcString = "alter table journal1 add column kuurs numeric(12,6)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update journal1 set kuurs = 1"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column kuurs set default 1"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column kuurs set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If Empty(check_field_pg('JOURNAL1','VALSUMMA'))
		lcString = "alter table journal1 add column valsumma numeric(12,4)"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "update journal1 set valsumma = 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column valsumma set default 0"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
		lcString = "alter table journal1 alter column valsumma set not null "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Kustutamine tabelit' Nowait

	If CHECK_obj_pg('TABLE','JOURNAL1TMP')
		lcString = "Drop Table journal1tmp  CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If CHECK_obj_pg('TABLE','LAUSEND')
		lcString = "Drop Table lausend CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If CHECK_obj_pg('TABLE','LADU_ULEHIND')
		lcString = " Drop Table ladu_ulehind CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif

	Endif
	If CHECK_obj_pg('TABLE','LADU_MINKOGUS')
		lcString = "Drop Table ladu_minkogus CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If CHECK_obj_pg('TABLE','LAUSDOK')
		lcString = "Drop Table lausdok CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If CHECK_obj_pg('TABLE','SORDER1')
		lcString = "Drop Table sorder1 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If CHECK_obj_pg('TABLE','SORDER2')
		lcString = "Drop Table SORDER2 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If CHECK_obj_pg('TABLE','VORDER1')
		lcString = "Drop Table vorder1 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If CHECK_obj_pg('TABLE','VORDER2')
		lcString = "Drop Table vorder2 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If CHECK_obj_pg('TABLE','ARV3')
		lcString = "Drop Table arv3 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If CHECK_obj_pg('TABLE','SALDO1')
		lcString = "Drop Table saldo1 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If CHECK_obj_pg('TABLE','SALDO2')
		lcString = "Drop Table saldo2 CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	If CHECK_obj_pg('TABLE','TULUDKULUD')
		lcString = "Drop Table tuludkulud CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif


&&Views
	Wait Window 'View curSaldo' Nowait
	If Empty(CHECK_obj_pg('VIEW','cursaldo'))
		lcString = " create view cursaldo as Select date(2000,01,01) as kpv, kontoinf.rekvid, Library.kood As konto,"+;
			" case when kontoinf.algsaldo >= 0 then kontoinf.algsaldo else 0::numeric(12,4) end As deebet,"+;
			" case when kontoinf.algsaldo < 0 then -1 * kontoinf.algsaldo else 0::numeric(12,4) end As kreedit, 1 AS OPT, 0::int4 as asutusid "+;
			" from Library INNER Join kontoinf On Library.Id = kontoinf.parentId "+;
			" union all "+;
			" Select date(2000,01,01) as kpv, subkonto.rekvid, Library.kood As konto,"+;
			" CASE WHEN  subkonto.algsaldo >= 0 then subkonto.algsaldo else 0::numeric(12,4) end As deebet, "+;
			" case when subkonto.algsaldo < 0 then -1 * subkonto.algsaldo else 0::numeric(12,4) end As kreedit, "+;
			" 2 as opt, subkonto.asutusid "+;
			" from Library INNER Join subkonto On Library.Id = subkonto.KontoId "+;
			" union all	"+;
			" Select date(aasta, kuu,1) as kpv, rekvid, konto,dbkaibed  As deebet, krkaibed As kreedit, 3 as opt, asutusId "+;
			" from saldo "+;
			" union all "+;
			" SELECT kpv, rekvid, deebet as konto, summa as deebet,  0::numeric(12,4) as kreedit, 4 as opt, asutusId "+;
			" from curJournal "+;
			" union all "+;
			" SELECT kpv, rekvid, kreedit as konto, 0::numeric(12,4) as deebet,  summa  as kreedit, 4 as opt, asutusId "+;
			" from curJournal "

		If execute_sql(lcString) < 0
			Return .F.
		Endif
	ENDIF
	
	Wait Window 'View cur_doklausend' Nowait
	If !Empty(CHECK_obj_pg('VIEW','cur_doklausend'))
		lcString = "Drop View cur_doklausend  CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'View curEelarveKulud' Nowait
	If !Empty(CHECK_obj_pg('VIEW','curEelarveKulud'))
		lcString = "Drop View curEelarveKulud  CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	lcString = "Create View curEelarveKulud AS "+;
		" SELECT  eelarve.Id, eelarve.rekvid, eelarve.aasta, eelarve.allikasId, eelarve.Summa, eelarve.kood1, eelarve.kood2, "+;
		" eelarve.kood3, eelarve.kood4, eelarve.kood5, eelarve.tunnus, rekv.nimetus As asutus, rekv.regkood, rekv.parentid, "+;
		" Ifnull(Parent.nimetus,Space(254)) As parasutus, "+;
		" Ifnull(Parent.regkood,Space(20)) As parregkood "+;
		" FROM   eelarve INNER Join  rekv On eelarve.rekvid = rekv.Id "+;
		" left Outer Join rekv Parent On Parent.Id = rekv.parentid "
	If execute_sql(lcString) < 0
		Return .F.
	Endif

	Wait Window 'View kassatulud' Nowait
	If !Empty(CHECK_obj_pg('VIEW','kassatulud'))
		lcString = "Drop View kassatulud  CASCADE "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	lcString = " Create View kassatulud as "+;
		" select Distinct Left(Ltrim(Rtrim(kood))+'%',20) As kood From Library Where Library = 'KASSATULUD' "
	If execute_sql(lcString) < 0
		Return .F.
	Endif

	Wait Window 'View kassakulud' Nowait
	If !Empty(CHECK_obj_pg('VIEW','kassakulud'))
		lcString = "Drop View kassakulud  CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	lcString = "Create View kassakulud as "+;
		" select Distinct Left(Ltrim(Rtrim(kood))+'%',20) As kood From Library Where Library = 'KASSAKULUD'"
	If execute_sql(lcString) < 0
		Return .F.
	Endif

	Wait Window 'View kassakontod' Nowait
	If !Empty(CHECK_obj_pg('VIEW','kassakontod'))
		lcString = "Drop View kassakontod  CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	lcString = " create view kassakontod as "+;
		" select distinct left(ltrim(rtrim(kood))+'%',20) as kood from library where library = 'KASSAKULUD'"
	If execute_sql(lcString) < 0
		Return .F.
	Endif

	Wait Window 'View curJournal' Nowait
	If !Empty(CHECK_obj_pg('VIEW','curJournal'))
		lcString = "Drop View curJournal  CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	lcString = "Create  View curJournal AS "+;
		" SELECT journal.Id, journal.rekvid, journal.kpv, journal.asutusid, Month (journal.kpv) As kuu, Year (journal.kpv) As aasta,"+;
		" journal.selg::varchar(254) As selg, journal.dok, journal1.Summa, journal1.valsumma, journal1.valuuta,journal1.kuurs,"+;
		" journal1.kood1,journal1.kood2, journal1.kood3, journal1.kood4,journal1.kood5,"+;
		" journal1.deebet, journal1.kreedit,journal1.lisa_d, journal1.lisa_k, "+;
		" Ifnull(Left(Rtrim(asutus.nimetus)+Space(1)+Rtrim(asutus.omvorm),120),Space(120)) As asutus, "+;
		" journal1.tunnus, journalid.Number "+;
		" FROM journal INNER Join journal1 On journal.Id = journal1.parentid "+;
		" INNER Join journalid On journal.Id = journalid "+;
		" left Outer Join asutus On journal.asutusid = asutus.Id "

	If execute_sql(lcString) < 0
		Return .F.
	Endif

	Wait Window 'View kassakulud' Nowait
	If !Empty(CHECK_obj_pg('VIEW','curKassaTuludeTaitmine'))
		lcString = "Drop View curKassaTuludeTaitmine  CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	lcString = "Create View curKassaTuludeTaitmine as "+;
		" select kuu, aasta, curJournal.rekvid, curJournal.tunnus As tun, Sum(Summa) As Summa, "+;
		" LEFT(kreedit,4) As kood, curJournal.kood5 As eelarve, curJournal.kood1 As tegev "+;
		" from curJournal "+;
		" INNER Join kassatulud On Ltrim(Rtrim(curJournal.kreedit)) Like Ltrim(Rtrim(kassatulud.kood)) "+;
		" INNER Join kassakontod On Ltrim(Rtrim(curJournal.deebet)) Like Ltrim(Rtrim(kassakontod.kood)) "+;
		" where Left(kreedit,1) = '3' "+;
		" group By aasta, kuu , curJournal.rekvid, curJournal.kreedit,curJournal.kood1, curJournal.kood5, curJournal.tunnus "+;
		" order By aasta, kuu , curJournal.rekvid, curJournal.kreedit,curJournal.kood1, curJournal.kood5, curJournal.tunnus "

	If execute_sql(lcString) < 0
		Return .F.
	Endif

	Wait Window 'View curKassaKuludeTaitmine' Nowait
	If !Empty(CHECK_obj_pg('VIEW','curKassaKuludeTaitmine'))
		lcString = "Drop View curKassaKuludeTaitmine  CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	lcString = " Create View curKassaKuludeTaitmine as "+;
		" select kuu, aasta, curJournal.rekvid, Sum(Summa) As Summa,"+;
		" LEFT(deebet,4) As kood , curJournal.kood5 As eelarve,curJournal.kood1 As tegev, "+;
		" curJournal.tunnus As tun "+;
		" from curJournal "+;
		" INNER Join kassakulud On curJournal.deebet Like kassakulud.kood "+;
		" INNER Join kassakontod On curJournal.kreedit Like kassakontod.kood "+;
		" where (Left(deebet,1) In ('3','4','5') Or Left(deebet,2) = '15') "+;
		" group By aasta, kuu , curJournal.rekvid, curJournal.deebet, curJournal.kood1, curJournal.tunnus, curJournal.kood5 "+;
		" order By aasta, kuu , curJournal.rekvid, curJournal.deebet, curJournal.kood1, curJournal.tunnus, curJournal.kood5 "

	If execute_sql(lcString) < 0
		Return .F.
	Endif

	Wait Window 'View curEelarve' Nowait
	If !Empty(CHECK_obj_pg('VIEW','curEelarve'))
		lcString = "Drop View curEelarve  CASCADE"
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	lcString = " Create View curEelarve AS "+;
		" SELECT eelarve.Id, eelarve.rekvid, eelarve.aasta, eelarve.Summa, "+;
		" eelarve.kood1, eelarve.kood2, eelarve.kood3, eelarve.kood4, eelarve.kood5, eelarve.tunnus As tun,"+;
		" rekv.nimetus, rekv.nimetus As asutus, rekv.regkood,rekv.parentid, "+;
		" Ifnull(tunnus.kood,Space(20)) As tunnus,"+;
		" Ifnull(Parent.nimetus,Space(254)) As parasutus,"+;
		" Ifnull(Parent.regkood,Space(20)) As parregkood "+;
		" From  eelarve INNER Join rekv On eelarve.rekvid = rekv.Id "+;
		" left Outer Join rekv Parent On Parent.Id = rekv.parentid "+;
		" left Outer Join Library tunnus On eelarve.Tunnusid = tunnus.Id "

	If execute_sql(lcString) < 0
		Return .F.
	Endif

	If Empty(CHECK_obj_pg('VIEW','v_saldoaruanne'))

		lcString = " create view v_saldoaruanne as "+;
			" SELECT konto, tp, tegev, allikas, rahavoo, sum(deebet) as db, sum (kreedit) as kr "+;
			" from (SELECT deebet as konto, lisa_d as tp, kood1 as tegev, kood2 as allikas, kood3 as rahavoo,"+;
			" summa::numeric(12,4) as deebet, 0::numeric(12,4) as kreedit "+;
			" FROM curJournal "+;
			" UNION all "+;
			" SELECT kreedit as konto, lisa_d as tp, kood1 as tegev, kood2 as allikas, kood3 as rahavoo, "+;
			" (0)::numeric(12,4)  as deebet,  summa::numeric(12,4) as kreedit "+;
			" FROM curJournal ) qrySaldoAruanne "+;
			" group BY konto, tp, tegev, allikas, rahavoo "+;
			" ORDER BY konto, tp, tegev, allikas, rahavoo "

		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	If Empty(CHECK_obj_pg('VIEW','v_check_tasu'))
		lcString = " CREATE OR REPLACE view v_check_tasu as "+;
			" Select journal.Id, journal.kpv, journal.rekvid, journal.Asutusid,  journal.DOK ,"+;
			" journal1.Summa, arv.Id As arvid,  nomenklatuur.Id As nomid, arv.Number "+;
			" from journal INNER Join journal1 On journal.Id = journal1.parentId "+;
			" INNER JOIN KLASSIFLIB ON (klassiflib.konto = journal1.deebet or klassiflib.konto = journal1.kreedit) "+;
			" inner join nomenklatuur on nomenklatuur.id = klassiflib.nomid "+;
			" INNER Join arv On arv.Number = journal.DOK "+;
			" where nomenklatuur.DOK = 'TASU' "+;
			" and Len(Ltrim(Rtrim(journal.DOK))::varchar) > 0 "+;
			" and journal.Id Not In (Select journalid From arvtasu) "
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif


&& Stored Procedures
	Wait Window 'Stored procedure: sp_del_pv_oper' Nowait
	lcFile = 'script/3112/sp_del_pv_oper_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: sp_del_puudumised' Nowait
	lcFile = 'script/3112/sp_del_puudumised_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: sp_del_taabel1' Nowait
	lcFile = 'script/3112/sp_del_taabel1_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: sp_del_vastisikud' Nowait
	lcFile = 'script/3112/sp_del_vastisikud_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	Wait Window 'Stored procedure: sp_del_tood' Nowait
	lcFile = 'script/3112/sp_del_tood_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: sp_del_toograafik' Nowait
	lcFile = 'script/3112/sp_del_toograafik_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: sp_del_pvgruppId' Nowait
	lcFile = 'script/3112/sp_del_pvgruppid_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: sp_del_osakonnad' Nowait
	lcFile = 'script/3112/sp_del_osakonnad_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: sp_del_validok' Nowait
	lcFile = 'script/3112/sp_del_validok_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: sp_del_tunnus' Nowait
	lcFile = 'script/3112/sp_del_tunnus_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif


	Wait Window 'Stored procedure: sp_del_palklib' Nowait
	lcFile = 'script/3112/sp_del_palklib_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: sp_del_kontod' Nowait
	lcFile = 'script/3112/sp_del_kontod_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif


	Wait Window 'Stored procedure: sp_del_holiday' Nowait
	lcFile = 'script/3112/sp_del_holiday_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: sp_del_dok' Nowait
	lcFile = 'script/3112/sp_del_dok_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: sp_del_doklausend' Nowait
	lcFile = 'script/3112/sp_del_doklausend_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif


	Wait Window 'Stored procedure: sp_del_nomenklatuur' Nowait
	lcFile = 'script/3112/sp_del_nomenklatuur_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: sp_del_arved' Nowait
	lcFile = 'script/3112/sp_del_arved_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: sp_del_ametid' Nowait
	lcFile = 'script/3112/sp_del_ametid_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif


	Wait Window 'Stored procedure: sp_del_library' Nowait
	lcFile = 'script/3112/sp_del_allikad_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: sp_del_library' Nowait
	lcFile = 'script/3112/sp_del_library_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif


	Wait Window 'Stored procedure: sp_tasuarv' Nowait
	lcFile = 'script/3112/sp_tasuarv_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: sp_saldoaruanne' Nowait
	lcFile = 'script/3112/sp_saldoaruanne_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: gen_lausend_mahakandmine' Nowait
	lcFile = 'script/3112/gen_lausend_mahakandmine_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: gen_lausend_mk' Nowait
	lcFile = 'script/3112/gen_lausend_mk_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: gen_lausend_parandus' Nowait
	lcFile = 'script/3112/gen_lausend_parandus_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: gen_lausend_kulum' Nowait
	lcFile = 'script/3112/gen_lausend_kulum_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: gen_lausend_paigutus' Nowait
	lcFile = 'script/3112/gen_lausend_paigutus_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: gen_lausend_palk' Nowait
	lcFile = 'script/3112/gen_lausend_palk_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Wait Window 'Stored procedure: gen_lausend_arv' Nowait
	lcFile = 'script/3112/gen_lausend_arv_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif
	Wait Window 'Stored procedure: gen_lausend_korder' Nowait
	lcFile = 'script/3112/gen_lausend_korder_pg.sql'
	If File(lcFile)
		Create Cursor pg_proc (Proc m)
		Append Blank
		Append Memo pg_proc.Proc From (lcFile) Overwrite As 1251
		lcString = pg_proc.Proc
		If execute_sql(lcString) < 0
			Return .F.
		Endif
	Endif

	Return


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



