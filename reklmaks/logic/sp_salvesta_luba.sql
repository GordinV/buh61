-- Function: trigi_journa_after()

-- DROP FUNCTION trigi_journa_after();

CREATE OR REPLACE FUNCTION trigi_journa_after()
  RETURNS "trigger" AS
'
declare
       lcAsutus varchar;
       lnNumber int;
begin
  /* New function body */
			lcAsutus := ltrim (rtrim(cast(new.rekvId as bpchar)))+\'ASUTUS\'+LTRIM(RTRIM(year(new.kpv)));
			select lastnum into lnNumber from dbase where alias = lcAsutus;			
			if not found then
				lnNumber := 0;
				insert into dbase (lastnum, alias) values (1, lcAsutus);
			else
				update dbase set lastnum = lnNumber+1 where alias =  lcAsutus;		
			end if;
			insert into journalid (rekvid, number, journalid, aasta) values
			(new.RekvId,lnNumber+1,new.id,year(new.kpv));

  return null;
end;
'
  LANGUAGE 'plpgsql' IMMUTABLE;
GRANT EXECUTE ON FUNCTION trigi_journa_after() TO GROUP dbkasutaja;
GRANT EXECUTE ON FUNCTION trigi_journa_after() TO GROUP dbpeakasutaja;
