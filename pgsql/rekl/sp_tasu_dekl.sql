-- Function: sp_tasu_dekl(integer)

/*
select * from curJournal where rekvid =28 and number=662 

select sp_tasu_dekl(3807487)

select sp_tasu_dekl(curjournal.id) from curjournal where not empty (dok) and  id in (
select journalid from toiming where tyyp='TASU' AND year(kpv) = 2011
)

*/

-- DROP FUNCTION sp_tasu_dekl(integer);

CREATE OR REPLACE FUNCTION sp_tasu_dekl(integer)
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
begin


-- otsime, kas see tasu juba exist

	select id into lnId from toiming where journalid = tnJournalId;
	if ifnull(lnId,0) > 0 then
		-- on, kustame
		raise notice 'kustutan %',lnId;
		perform sp_del_toiming(lnId);
	end if;


lnResult := 0;
-- otsime luba

--			JOIN kassakontod ON ltrim(rtrim(curjournal.deebet::text)) ~~ ltrim(rtrim(kassakontod.kood::text)) 

	select id, kpv, summa, asutusId, dok, rekvid, number, deebet, kreedit, valuuta, kuurs into v_journal
		from curJournal 
		where curJournal.id = tnJournalId;

	select luba.*, toiming.number as t_number, toiming.id as deklid into v_luba from luba inner join toiming on luba.id = toiming.lubaid 
			where ltrim(rtrim(luba.number))+'-'+ltrim(rtrim(toiming.number::varchar)) like ltrim(rtrim(v_journal.dok)) + '%'
		and luba.parentId = v_journal.asutusId and toiming.tyyp = 'DEKL' AND toiming.staatus > 0 order by toiming.number limit 1;

	if ifnull(v_luba.id,0) = 0 then
		-- luba puudub
		raise notice 'Luba puudub';
		return 0;
	end if;
--	lcAlus = space(1);
	lcAlus = 'Lausend nr.:' + v_journal.number::varchar;

	lnSumma = 0;

	if left(v_journal.deebet,6) = '100100' then
		lnSumma = v_journal.summa ;
	end if;
	if left(v_journal.kreedit,6) = '100100' then
		lnSumma = -1 * v_journal.summa;
	end if;


	lnresult =  sp_salvesta_toiming(0::integer,v_luba.parentid::integer,v_luba.id::integer,v_journal.kpv::date,lcAlus::character varying,
		space(1)::character varying,v_journal.kpv::date,lnSumma::numeric,1::integer,'TASU'::character varying, 
		space(1)::text, 0::integer, 0::integer,0::integer,v_journal.valuuta::character varying, v_journal.kuurs::numeric );
--sp_salvesta_toiming(integer, integer, integer, date, character varying, character varying, date, numeric, integer, character varying, text, integer, integer, integer,
-- character varying, numeric)


	if lnresult > 0 then
		-- salvestatud. Lisame journalId number
		update toiming set journalid = v_journal.id where id = lnresult;
	end if;


	lnTasuJaak = lnSumma * v_journal.kuurs;
-- kontrollime, kas on tasumata intress (luba.intress > 0)
	if v_luba.intress > 0 then

		for v_dekl in
			select id, summa, kpv, tahtaeg, staatus, ifnull(dokvaluuta1.kuurs,1)::numeric, ifnull(dokvaluuta1.valuuta,'EEK')::varchar 
				from toiming left outer join dokvaluuta1 on dokvaluuta1.dokid = toiming.id and dokvaluuta1.dokliik = 15
				where lubaId = v_luba.id
				and tyyp = 'INTRESS' 
				and staatus < 3
				order by kpv
		loop
		-- kui palju paevad oli tahtajatu

			lnVolgKpv := 0;

			if v_dekl.tahtaeg < v_journal.kpv then
				lnVolgKpv = v_journal.kpv - v_dekl.tahtaeg;
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
				(v_luba.parentid, v_dekl.id, lnresult, v_journal.kpv, lnVolgKpv, lnTasuSumma);


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

		if v_dekl.tahtaeg < v_journal.kpv then
			lnVolgKpv = v_journal.kpv - v_dekl.tahtaeg;
		end if;

	-- tasu summa


		if lnTasuJaak <= v_dekl.summa then
			lntasuSumma = v_journal.summa;
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
			(v_luba.parentid, v_dekl.id, lnresult, v_journal.kpv, lnVolgKpv, lnTasuSumma);

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
		insert into dekltasu (parentid, deklId, tasuId, tasuKpv, volgKpv, summa) values (v_luba.parentid, 0, lnresult, v_journal.kpv, 0, lnTasuJaak);
		lnresult = 2;	
	end if;
	perform sp_recalc_rekljaak(v_luba.id);

return  lnResult;
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_tasu_dekl(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_tasu_dekl(integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_tasu_dekl(integer) TO public;
GRANT EXECUTE ON FUNCTION sp_tasu_dekl(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_tasu_dekl(integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_tasu_dekl(integer) TO taabel;
