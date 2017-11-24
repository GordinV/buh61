-- Function: sp_salvesta_aa(integer, integer, character, character, numeric, integer, integer, integer, character, text, character varying)
/*select * from curJournal order by id desc limit 10
select * from journal order by id desc limit 10
select sp_koosta_ettemaks(1516, 1)
select * from ettemaksud

*/
-- DROP FUNCTION sp_salvesta_aa(integer, integer, character, character, numeric, integer, integer, integer, character, text, character varying);

CREATE OR REPLACE FUNCTION sp_koosta_ettemaks(integer, integer)
  RETURNS integer AS
$BODY$
declare
	tnid alias for $1;
	tnLiik alias for $2;
	lnId int; 
	v_journal record;
begin
lnId = 0;
if tnLiik = 1 then
-- journal
	for v_journal in 
		SELECT journal.id, journal1.id as journal1Id, journal.rekvid, journal.kpv, journal.asutusid, journal.selg, journal1.summa, journalid.number
			FROM journal
			JOIN journal1 ON journal.id = journal1.parentid
			JOIN journalid ON journal.id = journalid.journalid
			where journal.id = tnId
	loop 
-- kontrollime kas ettemaks juba koostatud
		select id into lnId from ettemaksud where journalid = v_journal.journal1Id;
		lnId = ifnull(lnId,0);
			
		lnId = sp_salvesta_ettemaksud(lnId, v_journal.rekvid, v_journal.asutusId, v_journal.id, 1, v_journal.kpv, v_journal.summa, v_journal.number, v_journal.selg, '', v_journal.journal1Id);
		if lnId > 0 then
			update journal set dokid = lnId where id = tnId;
		end if;		
	end loop;

end if;
return  lnId;

end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_koosta_ettemaks(integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_koosta_ettemaks(integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_koosta_ettemaks(integer, integer) TO dbpeakasutaja;
