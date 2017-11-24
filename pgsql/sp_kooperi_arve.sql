-- Function: sp_kooperi_pv_kaart()
/*

select * from arv where  liik = 0 order by id desc limit 1

select sp_kooperi_arve(id) from arv where id = 31762

*/
-- DROP FUNCTION sp_kooperi_pv_kaart();

CREATE OR REPLACE FUNCTION sp_kooperi_arve(in tnarvid integer)
  RETURNS integer AS
$BODY$

declare
	lnResult int; 
	lnJournalid int;

	v_arv record;
	v_arv1 record;
	v_valuuta record;

	lnrekvId integer;
	lnId integer;
	lnUserid integer;
	lcNumber varchar(20);

	
begin
	lnId = 0;
	lnUserid = 0;
	lcNumber = '';

-- USER
	SELECT id INTO lnUserid from userid WHERE kasutaja = CURRENT_USER::VARCHAR;
	
-- select arv
	select * into v_arv from arv where id = tnarvid;

	select str(val(ltrim(rtrim(number)))+1) into lcNumber from arv where liik = 0  and rekvid = v_arv.rekvid order by id desc limit 1;

	select * into v_valuuta from dokvaluuta1 where dokid = v_arv.id and dokliik = 3;
	-- uus arve
	insert into arv (rekvid, userid, doklausid, liik , operid, number, kpv, asutusid, arvid, lisa, tahtaeg, kbmta , kbm, summa , muud, objektid, objekt) values 
		(v_arv.rekvid, lnuserid, v_arv.doklausid, v_arv.liik , v_arv.operid, lcnumber, date(), v_arv.asutusid, v_arv.arvid, v_arv.lisa, 
		date()+(v_arv.tahtaeg-v_arv.kpv), v_arv.kbmta , v_arv.kbm, v_arv.summa , v_arv.muud, v_arv.objektid, v_arv.objekt);
	-- select arv1

	lnId:= cast(CURRVAL('public.arv_id_seq') as int4);

	for v_arv1 in
		select * from arv1 where parentid = tnarvid
	loop

		lnResult = sp_salvesta_arv1(0, lnId, v_arv1.nomId, v_arv1.kogus, v_arv1.hind, v_arv1.soodus,v_arv1.kbm, v_arv1.maha, v_arv1.summa, 
			v_arv1.muud, v_arv1.kood1, v_arv1.kood2, v_arv1.kood3, v_arv1.kood4, v_arv1.kood5, v_arv1.konto, v_arv1.tp, v_arv1.kbmta, 
			v_arv1.isikid, v_arv1.tunnus, v_valuuta.valuuta, v_valuuta.kuurs, v_arv1.proj);
	
	end loop;

	-- konteerimine
	lnJournalid = gen_lausend_arv(lnId);

return  lnId;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
