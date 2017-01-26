-- Function: sp_tasu_dekl2(integer, date, numeric, character varying, character varying, numeric)

-- DROP FUNCTION sp_tasu_dekl2(integer, date, numeric, character varying, character varying, numeric);

CREATE OR REPLACE FUNCTION sp_tasu_dekl2(integer, date, numeric, character varying, character varying, numeric)
  RETURNS integer AS
$BODY$

declare
	tnDeklId alias for $1;
	tdKpv alias for $2;
	tnSumma alias for $3;
	tcAlus alias for $4;	
	tcValuuta alias for $5;	
	tnKuurs alias for $6;	

	lnVolgKpv int;
	lnTasuSumma numeric;
	lnTasuJaak numeric;
	v_journal record;
	v_dekl record;
	v_tasu record;
	v_luba record;
	lnDeklStatus int;
	lnSumma numeric;
	lnid int;
	lnResult int;
	lcalus varchar;
	lnStaatus int;
	lcValuuta varchar;
	lnKuurs numeric(12,4);
	lnJournalId integer;
begin


lnResult := 0;

-- otsime luba

	select luba.*, toiming.number as t_number, toiming.id as deklid into v_luba from luba inner join toiming on luba.id = toiming.lubaid 
		where toiming.id = tnDeklId;		
	lcAlus = tcAlus;

-- kontrollime ettemaks
	select sum(summa) into lnSumma from ettemaksud where asutusid = v_luba.parentid;

	if (lnSumma - tnSumma) < 0 then
		-- puudub ettemaks
		raise exception 'Puudub ettemaks';
		return 0;
	end if;

	lnSumma = tnSumma;

	lnresult =  sp_salvesta_toiming(0::integer,v_luba.parentid::integer,v_luba.id::integer,tdkpv::date,lcAlus::character varying,
		space(1)::character varying,tdkpv::date,lnSumma::numeric,1::integer,'TASU'::character varying, 
		space(1)::text, 0::integer, 0::integer,0::integer,tcValuuta::character varying, tnkuurs::numeric );

	-- konteerimine
	lnJournalId = 0;

	if lnResult > 0 then
		lnJournalId = gen_lausend_rekltasu(lnResult);
		update toiming set journalId = lnJournalId where id = lnresult;				
		select id into lnJournalId from journal1 where parentid = lnJournalId;
	else
		lnJournalId = 0;
	end if;

	if lcAlus = 'Ettemaks' then
		-- ettemaks nullime
		insert into ettemaksud (rekvid, kpv, summa, number, asutusId, dokid, doktyyp, selg, staatus, journalId) values 
			(v_luba.rekvid, tdKpv, -1*lnSumma, 0, v_luba.parentid,  lnresult, 2, lcAlus, 1,ifnull(lnJournalId,0));		
	end if;
	

	lnTasuJaak = lnSumma * tnkuurs;

	select id, summa, kpv, tahtaeg, staatus into v_dekl from toiming where Id = tnDeklId;

	-- kui palju paevad oli tahtajatu

		lnVolgKpv := 0;

		if v_dekl.tahtaeg < tdkpv then
			lnVolgKpv = tdkpv - v_dekl.tahtaeg;
		end if;

	-- tasu summa

		insert into dekltasu (parentid, deklId, tasuId, tasuKpv, volgKpv, summa) values
			(v_luba.parentid, v_dekl.id, lnresult, tdkpv, lnVolgKpv, lnTasuJaak);

	raise notice 'status';

	-- status	
	lnDeklStatus = fncDeklStaatus(v_dekl.id);
/*
		select sum(summa) into lnSumma from dekltasu where deklId = v_dekl.id;
		if ifnull(lnSumma,0) >= v_dekl.summa then
			-- tasud
			lnDeklStatus = 3;	
		else
			-- tasud osaline
			lnDeklStatus = 2;	
		end if;

	--	update toiming set staatus = lnDeklStatus where id = v_dekl.id;
		perform sp_muuda_deklstaatus(v_dekl.Id, lnDeklStatus);
*/
		if lnTasuJaak = 0 then
			lnresult = 1;	
--			exit;
		end if;

		perform sp_recalc_rekljaak(v_luba.id);
		perform fncReklEttemaksStaatus(v_luba.parentid);
return  lnResult;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sp_tasu_dekl2(integer, date, numeric, character varying, character varying, numeric)
  OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_tasu_dekl2(integer, date, numeric, character varying, character varying, numeric) TO public;
GRANT EXECUTE ON FUNCTION sp_tasu_dekl2(integer, date, numeric, character varying, character varying, numeric) TO vlad;
GRANT EXECUTE ON FUNCTION sp_tasu_dekl2(integer, date, numeric, character varying, character varying, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_tasu_dekl2(integer, date, numeric, character varying, character varying, numeric) TO dbpeakasutaja;
