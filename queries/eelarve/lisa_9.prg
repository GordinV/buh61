Parameter cWhere
* Eelarve kulude tegevusalade ja majanduliku sisu järgi

l_kpv1 = DTOC(fltrAruanne.kpv1,1) 
l_kpv2 = DTOC(fltrAruanne.kpv2,1) 
l_summa = fltrAruanne.summa
TEXT TO l_string TEXTMERGE noshow
	SELECT * from lisa_9
		where kpv >= '<<l_kpv1>>'::date
		and kpv <= '<<l_kpv2>>'::date
		and summa >= <<l_summa >>
		and rekv_id in (SELECT id FROM rekv where fnc_get_asutuse_staatus(rekv.id, <<gRekv>>) > case when <<fltrAruanne.kond>> > 0 then 3 else 9 end  
		or rekv_id= <<gRekv>>)

ENDTEXT



Wait Window 'Serveri poolt funktsioon ...' Nowait
lError = oDb.Execsql(l_string,'eelarve_report1')

IF lError AND USED('eelarve_report1')
	SELECT eelarve_report1
	RETURN .t.
ELSE
	SET STEP on
	SELECT 0
	RETURN .f.
ENDIF
