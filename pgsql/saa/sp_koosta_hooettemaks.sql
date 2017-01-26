-- Function: sp_koosta_hooettemaks(integer, integer)

-- DROP FUNCTION sp_koosta_hooettemaks(integer, integer);

CREATE OR REPLACE FUNCTION sp_koosta_hooettemaks(integer, integer)
  RETURNS integer AS
$BODY$
declare
	tnid alias for $1;
	tnLiik alias for $2;
	lnId int; 
	lnisikId int; 
	v_journal record;
	
	lcSelg text;
begin
lnId = 0;
if tnLiik = 1 then
-- journal
	raise notice 'journal';
	for v_journal in 
		SELECT journal.id, ifnull(asutus.nimetus,'')::varchar(154) as asutus, journal1.id as journal1Id, journal.rekvid, journal.kpv, journal.dok,
			journal.asutusid, journal.selg, journal1.summa, journalid.number
			FROM journal left outer join asutus on journal.asutusid = asutus.id
			JOIN journal1 ON journal.id = journal1.parentid
			JOIN journalid ON journal.id = journalid.journalid
			where journal.id = tnId and journal1.kreedit = '203630'
	loop 
-- kontrollime kas ettemaks juba koostatud
		-- konto like 203630

		select id into lnId from hooettemaksud where dokid = v_journal.journal1Id and doktyyp = 'LAUSEND';
		lnId = ifnull(lnId,0);

		if lnId = 0 then
			-- otsime isik
			raise notice 'Otsime isik';
			raise notice 'v_journal.selg %',v_journal.selg;
			lnIsikId = fnc_LeiaIsikuKood(v_journal.selg);
			if lnIsikId = 0 then
				return 0;
			end if;
			-- koostame uus ettemaks
			lcSelg = ltrim(rtrim(v_journal.asutus))+',';
			if len(v_journal.dok) > 0 then
				lcSelg = lcSelg + ' Dok.nr.'+ltrim(rtrim(v_journal.dok));
			end if;
			lcSelg=lcSelg + ',' + v_journal.selg;
			insert into hooettemaksud (isikid, kpv, summa, dokid , doktyyp, selg , staatus)
				values (lnIsikId, v_journal.kpv, v_journal.summa, v_journal.id, 'LAUSEND', lcSelg,1);
			lnId:= cast(CURRVAL('public.hooettemaksud_id_seq') as int4);	

			if lnId > 0 then
				update journal set dokid = lnId where id = tnId;
			end if;		
		end if;
			
	end loop;

end if;
return  lnId;

end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_koosta_hooettemaks(integer, integer) OWNER TO vlad;
