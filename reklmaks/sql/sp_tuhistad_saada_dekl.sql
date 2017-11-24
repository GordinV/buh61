-- Function: sp_tuhistad_saada_dekl(integer)

-- DROP FUNCTION sp_tuhistad_saada_dekl(integer);

CREATE OR REPLACE FUNCTION sp_tuhistad_saada_dekl(integer)
  RETURNS integer AS
$BODY$

declare
	tnid alias for $1;

	lnResult int; 
	lnJournalid int;
	v_toiming record;
	
begin
	lnresult = 1;
--	raise notice 'status: %',tnStaatus;
	select * into v_toiming from toiming where id = tnId;
	lnJournalId = ifnull(v_toiming.JournalId,0);
	if (select count(id) from dekltasu where deklid = tnId) > 0 then
		raise exception 'Viga, deklaratsioon tasunud';
	else
		update toiming set saadetud = null, journalid = 0 where id = tnid;
		perform sp_recalc_rekljaak(tnid);
		perform sp_muuda_deklstaatus(tnId, 1);
		if lnJournalId > 0 then
			lnJournalId = sp_del_journal(lnJournalId, 1);
		end if;
	end if;

return  lnResult;
end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
ALTER FUNCTION sp_tuhistad_saada_dekl(integer)
  OWNER TO vlad;
