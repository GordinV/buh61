-- Function: sp_calc_avansimaksed(int4)

-- DROP FUNCTION sp_calc_avansimaksed(int4);
--MUUDETUD 04/01/2004

CREATE OR REPLACE FUNCTION sp_calc_avansimaksed(int4)
  RETURNS int4 AS
'
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

Select * into v_palk_oper From palk_oper Where Id = tnId ;

for tmpPalkKaart in
Select palk_lib.round, palk_lib.liik, palk_lib.asutusest, palk_kaart.* 
	From palk_kaart INNER Join palk_lib On palk_kaart.libId = palk_lib.parentid
	WHERE lepingId = v_palk_oper.lepingId And Status = 1 Order By liik  
loop
	lnSumma := 0;

--	if  tmpPalkKaart.liik = 1 then
	--	arvestused
	--	kas on 2%
		select  sum(Summa) inTo lnPM From palk_kaart INNER Join palk_lib On palk_kaart.libId = palk_lib.parentid
			WHERE lepingId = v_palk_oper.lepingId And Status = 1 and liik = 8 And percent_ = 1 And tulumaks = 1 ;
		lnPm := ifnull(lnPm,0);
	--	kas on 1%
		select sum(Summa) inTo lnTKM From palk_kaart INNER Join palk_lib On palk_kaart.libId = palk_lib.parentid
			WHERE lepingId = v_palk_oper.lepingId And Status = 1 and liik = 1 And asutusest = 0 And percent_ = 1 And tulumaks = 1;
	--	kas on tulumaks%
		select sum(Summa) inTo lnTM From palk_kaart INNER Join palk_lib On palk_kaart.libId = palk_lib.parentid
			WHERE lepingId = v_palk_oper.lepingId And Status = 1 and liik = 4 And percent_ = 1 ;

		select sum(Summa) inTo lnSots From palk_kaart INNER Join palk_lib On palk_kaart.libId = palk_lib.parentid
			WHERE lepingId = v_palk_oper.lepingId And Status = 1 AND liik = 5 And percent_ = 1 ;

		If lnPM = 100 then
			lnPM := 2;
		End if;
		If lnTKM = 100 then
			lnTKM := 1;
		End if;
		If lnTM = 100 then
			lnTM := 24;
		End if;

		lnPalkSumma := v_palk_oper.Summa / (0.01*(100 - lnPM)) / (0.01*(100-lnTKM)) / (0.01*(100 - lnTM));
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

		If lnSumma <> 0 then
			Select * Into v_klassiflib From klassiflib Where libId = tmpPalkKaart.libId LIMIT 1;
			If v_klassiflib.tunnusid > 0 then
				Select kood into lcTunnus from Library where id = v_klassiflib.tunnusid;
			End if;

			lcTunnus := ifnull(lcTunnus,Space(1));

			-- muudetud 04/01/2004

			insert into palk_oper (rekvid, libId, lepingid, kpv, summa,  kood1, kood2, kood3, kood4, kood5, konto, tp, tunnus, dokLausId, muud ) 
			VALUES (v_palk_oper.rekvid, tmpPalkKaart.LibId,tmpPalkKaart.lepingid,V_PALK_OPER.Kpv,lnSumma, ifnull(v_klassiflib.kood1,space(1)), 
			ifnull(v_klassiflib.kood2,space(1)), ifnull(v_klassiflib.kood3,space(1)), ifnull(v_klassiflib.kood4,space(1)), 
			ifnull(v_klassiflib.kood5,space(1)), ifnull(v_klassiflib.konto,space(1)), v_palk_oper.Tp,lcTunnus, v_palk_oper.Doklausid, ''AVANS'' );

	--		select id into lnpalkOperId from palk_oper where rekvid = v_palk_oper.rekvid order by id desc limit 1;

			lnpalkOperId:= cast(CURRVAL(\'public.palk_oper_id_seq\') as int4);	

			lnJournalid := GEN_LAUSEND_PALK(lnpalkoperid);
			if lnJournalid > 0 then
				update palk_oper set journalid = lnJournalId where id = lnPalkOperid;
			end if;
		end if;

End loop;

Return 1;

end;
'
  LANGUAGE 'plpgsql' VOLATILE;
GRANT EXECUTE ON FUNCTION sp_calc_avansimaksed(int4) TO GROUP dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_avansimaksed(int4) TO GROUP dbpeakasutaja;
