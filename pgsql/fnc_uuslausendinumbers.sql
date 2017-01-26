-- Function: f_round(numeric, numeric)
/*
select fnc_uuslausendinumbers(rekv.id) from rekv where rekv.parentid <> 9999
not in (16,17,110,18,30)
select * from curJournal where rekvid = 119 and year(kpv) = 2013

select count(id), rekvid from curJournal  where year(kpv) = 2013 group by rekvid
*/
-- DROP FUNCTION f_round(numeric, numeric);

CREATE OR REPLACE FUNCTION fnc_uuslausendinumbers(integer)
  RETURNS numeric AS
$BODY$

declare 
	tnRekvId	ALIAS FOR $1;

	lnNumber integer;
	lnKiri integer;
	v_journal record;
	lnId integer;
	lcString varchar(254);
	lcNimi varchar(254);

BEGIN
	lnNumber = 1;
		select count(id) into lnKiri from curJournal where year(kpv) = 2013 and rekvid = tnRekvId;
		lnKiri = ifnull(lnKiri,0);
		if lnKiri > 0 then
			lnNumber = 1;
			for v_journal in 
				select id, number from curJournal where year(kpv) = 2013 and rekvid = tnRekvId order by id
			loop
				update journalid set number = lnNumber where journalid = v_journal.id;
				lnNumber = lnNumber + 1;
			end loop;
		end if;
		if lnNumber = 0 then 
			lnNumber = 1;
		end if;
		
		lcString = 'DROP SEQUENCE journalid_number_2013_'+ltrim(rtrim(str(tnRekvId)));
		execute lcString;

--		lcString = 'CREATE SEQUENCE journalid_number_2013_+ltrim(rtrim(str(tnRekvId)))+ ' INCREMENT 1  MINVALUE 1  MAXVALUE 9223372036854775807  START 1 CACHE 1';

	--	lisame sequence
		lcNimi := ' journalid_number_' + ltrim(rtrim(str(year(date(2013,01,01)))))+'_'+ltrim(rtrim(str(tnrekvid)));

		raise notice 'lisame seq';
		lcString := 'CREATE SEQUENCE ' +space(1) + lcNimi + ' INCREMENT 1 START ' || space(1)::char(1) + left(str(ifnull(lnNumber,0) ),9);
		raise notice 'lcString %',lcString;
		execute lcString;
		lcString := 'ALTER TABLE ' + lcNimi + ' OWNER TO vlad';
		execute lcString;
		lcString := 'GRANT SELECT, UPDATE, INSERT ON TABLE ' + lcNimi + ' TO GROUP dbpeakasutaja';
		execute lcString;
		lcString := 'GRANT SELECT, UPDATE, INSERT ON TABLE ' + lcNimi + ' TO GROUP dbkasutaja';
		execute lcString;


RETURN lnNumber;

end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION fnc_uuslausendinumbers(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fnc_uuslausendinumbers(integer) TO dbpeakasutaja;
