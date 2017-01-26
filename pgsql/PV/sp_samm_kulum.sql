-- Function: sp_samm_kulum(integer, integer, integer, date)

-- DROP FUNCTION sp_samm_kulum(integer, integer, integer, date);

CREATE OR REPLACE FUNCTION sp_samm_kulum(integer, integer, integer, date)
  RETURNS numeric AS
$BODY$
declare 
	tnId	ALIAS FOR $1;

	tnNomId alias for $2;

	tnDokLausId alias for $3;

	tdKpv alias for $4;
	
	v_klassiflib record;

	v_library record;

	lcTunnus varchar(20);

	lcTp varchar(20);

	v_pv_kaart record;

	lnPvOPerId int;

	lnSumma numeric(12,4);

	lnJournalid int;
	
	lcValuuta  varchar(20);
	lnKuurs numeric(12,4);
	lcSelg text;
	lcTimestamp varchar(20);

BEGIN
lcValuuta = 'EEK';
lnKuurs =    1;

lcTimestamp = left('PV'+LTRIM(RTRIM(str(tnId)))+ltrim(rtrim(str(dateasint(date())))),20);


if tdKpv > date(2010,12,31) then 
	lcValuuta = 'EUR';
	lnKuurs =    15.6466;
end if;

lcTp := space(20);

lcTunnus := space(20);
raise notice 'tnId %',tnId;
lnSumma := sp_calc_kulum(tnid);
raise notice 'lnSumma %',lnSumma;

IF lnSumma > 0 then
	raise notice 'Salvestamine ';

	select library.rekvid, pv_kaart.* into v_pv_kaart from library inner join pv_kaart on library.id = pv_kaart.parentid where pv_kaart.parentId = tnId;

	perform sp_del_pvoper_twin(tnId, tnNomId, tdKpv);

	select * into v_klassiflib from klassiflib where nomId = tnNomId and tyyp = 1;

	IF v_klassiflib.tunnusid > 0 then

		SELECT kood into lcTunnus from library where id = v_klassiflib.tunnusid;

	END IF;



	IF v_pv_kaart.vastIsikId > 0 then

		SELECT tp into lcTp from asutus where id = v_pv_kaart.vastIsikId;

	END IF;

-- selgitus
	select muud into lcSelg from tmp_viivis where timestamp = lcTimestamp and rekvid = v_pv_kaart.rekvid;
	if empty(lcSelg) then
		lcSelg = 'AUTOMATSELT ARVESTUS';
	end if;

	lnPvOperId = sp_salvesta_pv_oper(0, tnId, tnNomId, tnDokLausId, 2, tdkpv, round(lnsumma /lnKuurs,2), lcSelg, ifnull(v_klassiflib.kood1,''), ifnull(v_klassiflib.kood2,''), 
		ifnull(v_klassiflib.kood3,''), ifnull(v_klassiflib.kood4,''), ifnull(v_klassiflib.kood5,''), ifnull(v_klassiflib.konto,'611000'), 
		lcTp, 0, lcTunnus, '', lcValuuta, lnKuurs);

	lnJournalId := GEN_LAUSEND_KULUM (lnPvOperId);

	IF lnJournalid > 0 then

		update pv_oper set journalid = lnJournalid where id = lnPvOperId;

	END IF;
	raise notice 'Salvestatud,  %',lnJournalId;

end if;

RETURN lnSumma;

end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_samm_kulum(integer, integer, integer, date) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_samm_kulum(integer, integer, integer, date) TO vlad;
GRANT EXECUTE ON FUNCTION sp_samm_kulum(integer, integer, integer, date) TO public;
GRANT EXECUTE ON FUNCTION sp_samm_kulum(integer, integer, integer, date) TO dbkasutaja;
