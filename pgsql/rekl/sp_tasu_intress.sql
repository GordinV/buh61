-- Function: sp_tasu_dekl(integer)

-- DROP FUNCTION sp_tasu_dekl(integer);

CREATE OR REPLACE FUNCTION sp_tasu_intress(integer)
  RETURNS integer AS
$BODY$

declare
	tnJournalId alias for $1;

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

	lnAsutusId int;
begin


lnResult := 0;
-- otsime luba

	select curjournal.asutusId, curjournal.kpv, sum(curJournal.summa) as summa, curJournal.kuurs, curJournal.valuuta into v_journal 
		from curJournal 
		where id = tnJournalId and left(deebet,6) = '100100' and left(kreedit,6) = '102095' 
		group by curjournal.asutusId, curjournal.kpv, curJournal.kuurs, curJournal.valuuta;

	select luba.*, toiming.number as t_number, toiming.id as deklid into v_luba from luba inner join toiming on luba.id = toiming.lubaid 
			where toiming.tyyp = 'INTRESS' and toiming.and staatus < 3 and luba.parentid = v_journal.AsutusId and luba.staatus > 0
			order by id desc limit 1;

	select journal.muud into lcAlus where id = tnJournalId;

	lcAlus = ifnull(lcAlus,'');

	lnresult =  sp_salvesta_toiming(0::integer,v_luba.parentid::integer,v_luba.id::integer,v_journal.kpv::date,lcAlus::character varying,
		space(1)::character varying,v_journal.kpv::date,v_journal.Summa::numeric,1::integer,'TASU'::character varying, 
		space(1)::text, 0::integer, 0::integer,0::integer,curJournal.Valuuta::character varying, curJournal.kuurs::numeric );

	-- konteerimine
	lnJournalId = 0;

	if lnResult > 0 then
--		lnJournalId = gen_lausend_rekltasu(lnResult);
		update toiming set journalId = tnJournalId where id = lnresult;				
--		select id into lnJournalId from journal1 where parentid = lnJournalId;
	end if;

	if lcAlus = 'Ettemaks' then
		-- ettemaks nullime
		insert into ettemaksud (rekvid, kpv, summa, number, asutusId, dokid, doktyyp, selg, staatus, journalId) values 
			(v_luba.rekvid, tdKpv, -1*lnSumma, 0, v_luba.parentid,  lnresult, 2, lcAlus, 1,lnJournalId);		
	end if;
	

	lnTasuJaak = lnSumma * tnkuurs;
-- kontrollime, kas on tasumata intress (luba.intress > 0)
	if v_luba.intress > 0 then

		for v_dekl in
			select toiming.id, toiming.summa, toiming.kpv, toiming.tahtaeg, toiming.staatus, ifnull(dokvaluuta1.kuurs,1)::numeric, ifnull(dokvaluuta1.valuuta,'EEK')::varchar 
				from toiming left outer join dokvaluuta1 on dokvaluuta1.dokid = toiming.id and dokvaluuta1.dokliik = 15
				where lubaId = v_luba.id
				and tyyp = 'INTRESS' 
				and staatus < 3
				order by kpv
		loop
		-- kui palju paevad oli tahtajatu

			lnVolgKpv := 0;

			if v_dekl.tahtaeg < tdkpv then
				lnVolgKpv = tdkpv - v_dekl.tahtaeg;
			end if;

			-- tasu summa


			if lnTasuJaak <= v_dekl.summa then
				lntasuSumma = lnSumma;
			else
				lnTasuSumma = v_dekl.summa;
			end if;

			if lnTasuSumma > lnTasuJaak then
				lntasuSumma = lnTasuJaak;
				lnTasuJaak = 0;
			else
				lntasuJaak = lnTasuJaak - lnTasuSumma;
			end if;


			insert into dekltasu (parentid, deklId, tasuId, tasuKpv, volgKpv, summa) values
				(v_luba.parentid, v_dekl.id, lnresult, tdkpv, lnVolgKpv, lnTasuSumma);


	-- status	

			select sum(summa) into lnSumma from dekltasu where deklId = v_dekl.id;
			if ifnull(lnSumma,0) >= v_dekl.summa then
				-- tasud
				lnDeklStatus = 3;	
			else
				-- tasud osaline
				lnDeklStatus = 2;	
			end if;

			perform sp_muuda_deklstaatus(v_dekl.Id, lnDeklStatus);

			if lnTasuJaak = 0 then
				lnresult = 1;	
				exit;
			end if;
		
		end loop;
	end if;

-- otsime esimine tasumata deklaratsioon
	
	lnStaatus = 3;
	if (select count(id) from toiming 
			where lubaId = v_luba.id
			and tyyp in ('DEKL', 'ALGSALDO') 
			and staatus < lnStaatus) = 0 then
		lnStaatus = 4;
	end if;


	for v_dekl in
		select id, summa, kpv, tahtaeg, staatus from toiming 
			where lubaId = v_luba.id
			and tyyp in ('DEKL', 'ALGSALDO') 
			and staatus < lnStaatus
			order by kpv

--			and not empty (saadetud) 

	loop
	-- kui palju paevad oli tahtajatu

		lnVolgKpv := 0;

		if v_dekl.tahtaeg < tdkpv then
			lnVolgKpv = tdkpv - v_dekl.tahtaeg;
		end if;

	-- tasu summa


		if lnTasuJaak <= v_dekl.summa then
			lntasuSumma = lnsumma;
		else
			lnTasuSumma = v_dekl.summa;
		end if;

		if lnTasuSumma > lnTasuJaak then
			lntasuSumma = lnTasuJaak;
			lnTasuJaak = 0;
		else
			lntasuJaak = lnTasuJaak - lnTasuSumma;
		end if;


		insert into dekltasu (parentid, deklId, tasuId, tasuKpv, volgKpv, summa) values
			(v_luba.parentid, v_dekl.id, lnresult, tdkpv, lnVolgKpv, lnTasuSumma);

	raise notice 'status';

	-- status	

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

		if lnTasuJaak = 0 then
			lnresult = 1;	
			exit;
		end if;

	end loop;

	raise notice 'avans';
	if lntasuJaak > 0 then
		-- avans
		insert into dekltasu (parentid, deklId, tasuId, tasuKpv, volgKpv, summa) values (v_luba.parentid, 0, lnresult, tdkpv, 0, lnTasuJaak);
		lnresult = 2;	
	end if;
	perform sp_recalc_rekljaak(v_luba.id);
	perform fncReklEttemaksStaatus(v_luba.parentid);
return  lnResult;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION sp_tasu_dekl1(integer, date, numeric, varchar, varchar, numeric) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_tasu_dekl1(integer, date, numeric, varchar, varchar, numeric) TO dbpeakasutaja;
