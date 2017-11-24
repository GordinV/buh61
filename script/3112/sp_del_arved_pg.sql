CREATE OR REPLACE FUNCTION public.sp_del_arved(int4, int4)
  RETURNS int2 AS
'
declare 
	tnId alias for $1;
	lnCount int4;
	lnError int2;
	vArv record;
begin
	SELECT ID into lnCount FROM Arvtasu WHERE arvid = tnId limit 1;
     IF ifnull(lnCount,0) > 0 then
	return 0;		
     END IF;
	SELECT * into vArv from arv WHERE id = tnId; 
	DELETE FROM arv1 WHERE parentid = tnid;
	DELETE FROM arv WHERE id = tnid;
	select sp_recalc_ladujaak(vArv.RekvId,0,tnId) into lnError;

      IF vArv.JournalId > 0 then
          select sp_del_journal(vArv.journalId,1);
      end if;
	Return 1;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
