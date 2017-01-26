-- Function: sp_calc_avansimaksed(integer)

-- DROP FUNCTION sp_calc_avansimaksed(integer);

CREATE OR REPLACE FUNCTION sp_calc_avansimaksed(integer)
  RETURNS integer AS
$BODY$
declare 
	tnId alias for $1;
	lnLepingId int4;
	lnPalkSumma numeric;
	lnTMSumma numeric;
	lnPMSumma numeric;
	lnTKMSumma numeric;
	lnSots numeric;
	lnJournalId int4;
	lnLiik int;
	lnAsutusId int4;
	lnPalkOperId int4;
	lnSumma numeric;
	lcTunnus varchar;
	lnPM numeric;
	lnTKM numeric;
	lnTM numeric;
	v_palk_oper record;
	tmpPalkKaart record;
	v_klassiflib record;
begin

lnPalkSumma := 0;
lnTMSumma := 0;
lnPMSumma := 0;
lnTKMSumma := 0;
lcTunnus := space(1);

-- otsime palgakaart

Select palk_oper.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_palk_oper 
	From palk_oper left outer join dokvaluuta1 on (palk_oper.id = dokvaluuta1 and dokvaluuta1.dokliik = 12)
	Where Id = tnId ;

for tmpPalkKaart in
Select palk_lib.round, palk_lib.liik, palk_lib.asutusest, palk_kaart.* , ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs
	From palk_kaart 
	INNER Join palk_lib On palk_kaart.libId = palk_lib.parentid
	left outer join dokvaluuta1 on (palk_kaart.id = dokvaluuta1 and dokvaluuta1.dokliik = 20)	
	WHERE lepingId = v_palk_oper.lepingId And Status = 1 Order By liik  
loop
	lnSumma := 0;

--	if  tmpPalkKaart.liik = 1 then
	--	arvestused
	--	kas on 2%
		select  sum(Summa ) inTo lnPM From palk_kaart INNER Join palk_lib On palk_kaart.libId = palk_lib.parentid
			WHERE lepingId = v_palk_oper.lepingId And Status = 1 and liik = 8 And percent_ = 1 And tulumaks = 1 ;
		lnPm := ifnull(lnPm,0);
	--	kas on 1%
		-- muudetud 02/02/2004
		select sum(Summa) inTo lnTKM From palk_kaart INNER Join palk_lib On palk_kaart.libId = palk_lib.parentid
			WHERE lepingId = v_palk_oper.lepingId And Status = 1 and liik = 7 And asutusest = 0 And percent_ = 1 And tulumaks = 1;
		lnTKM := ifnull(lnTKM,0);
	--	kas on tulumaks%
		select sum(Summa) inTo lnTM From palk_kaart INNER Join palk_lib On palk_kaart.libId = palk_lib.parentid
			WHERE lepingId = v_palk_oper.lepingId And Status = 1 and liik = 4 And percent_ = 1 ;

		lnTM := ifnull(lnTM,0);

		select sum(Summa) inTo lnSots From palk_kaart INNER Join palk_lib On palk_kaart.libId = palk_lib.parentid
			WHERE lepingId = v_palk_oper.lepingId And Status = 1 AND liik = 5 And percent_ = 1 ;

		lnSots := ifnull(lnSots,0);

		If lnPM = 100 then
			lnPM := 2;
		End if;
		If lnTKM = 100 then
			lnTKM := 1;
		End if;
		If lnTM = 100 then
			lnTM := 24;
		End if;

		lnPalkSumma := (v_palk_oper.Summa * v_palk_oper.kuurs) / (0.01*(100 - lnPM)) / (0.01*(100-lnTKM)) / (0.01*(100 - lnTM));
		lnPMSumma := lnPalkSumma * 0.01 * lnPM;
		lnTKMSumma := lnPalkSumma * 0.01 * lnTKM;

		if tmpPalkKaart.liik = 4 then
			lnSumma := (lnPalkSumma - lnPMSumma - lnTKMSumma) * 0.01 * tmpPalkKaart.Summa;
		end if;

		if tmpPalkKaart.liik = 7 AND tmpPalkKaart.asutusest = 0 then
			lnSumma := lnPalkSumma  * 0.01 * tmpPalkKaart.Summa;
		end if;
		if tmpPalkKaart.liik = 8 then
			lnSumma := lnPalkSumma  * 0.01 * tmpPalkKaart.Summa;
		END if;
	
		lnSumma := f_round(lnSumma,tmpPalkKaart.round);
		
		-- muudetud 2/2/2005
		If lnSumma > 0 then
			Select * Into v_klassiflib From klassiflib Where libId = tmpPalkKaart.libId LIMIT 1;
			If v_klassiflib.tunnusid > 0 then
				Select kood into lcTunnus from Library where id = v_klassiflib.tunnusid;
			End if;

			lcTunnus := ifnull(lcTunnus,Space(1));

			lnpalkOperId = sp_salvesta_palk_oper(0,v_palk_oper.rekvid,tmpPalkKaart.LibId,tmpPalkKaart.lepingid,V_PALK_OPER.Kpv,lnSumma,v_palk_oper.Doklausid ,
				'AVANS', ifnull(v_klassiflib.kood1,space(1)),ifnull(v_klassiflib.kood2,space(1)),  ifnull(v_klassiflib.kood3,space(1)), 
				ifnull(v_klassiflib.kood4,space(1)), ifnull(v_klassiflib.kood5,space(1)),  ifnull(v_klassiflib.konto,space(1)),
				v_palk_oper.Tp, lcTunnus, fnc_currentvaluuta(V_PALK_OPER.Kpv), fnc_currentkuurs(V_PALK_OPER.Kpv),tcProj);
		end if;

End loop;

Return 1;

end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_avansimaksed(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_avansimaksed(integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_avansimaksed(integer) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_avansimaksed(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_avansimaksed(integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_avansimaksed(integer) TO taabel;
