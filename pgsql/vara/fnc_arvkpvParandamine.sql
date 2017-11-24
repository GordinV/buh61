-- Function: daysinmonth(date)

-- DROP FUNCTION daysinmonth(date);

CREATE OR REPLACE FUNCTION fnc_arvkpvParandamine(integer)
  RETURNS date AS
$BODY$
DECLARE tnArvId alias for $1;
	ldKpv date;
	lnJournalId int;
	v_arv record;
begin
	select journalid, kpv into v_arv from arv where id = tnArvId;
	ldKpv = v_arv.kpv;
	if v_arv.journalId > 0 then
		select kpv into ldKpv from journal where id = v_arv.journalid;
		ldKpv = ifnull(ldKpv,v_arv.kpv);
	end if;

        return  ldKpv;

end; 

$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION fnc_arvkpvParandamine(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION fnc_arvkpvParandamine(integer) TO public;
GRANT EXECUTE ON FUNCTION fnc_arvkpvParandamine(integer) TO vlad;
