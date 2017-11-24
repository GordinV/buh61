-- Function: trigiu_journal1_before()

-- DROP FUNCTION trigiu_journal1_before();

CREATE OR REPLACE FUNCTION trigiu_journal1_before()
  RETURNS trigger AS
$BODY$
declare 
	lnKuu int;
	lnAasta int;
	lnRekvId int;
	lcTP varchar(20);
	lnKinni int;
	lcViga text;
	ldKpv date;
begin
	
	select  rekvId,kpv into lnRekvid,ldKpv from journal where id = new.parentid;

-- otsin oma TP kood
	SELECT TP INTO lcTp FROM Aa WHERE Aa.parentid = lnRekviD   AND Aa.kassa = 2 ORDER BY ID DESC LIMIT 1;
	lcTp = ifnull(lcTp,'');
/*
	select kinni into lnKinni from aasta where kuu = lnKuu and aasta = lnAasta 
			and rekvid = lnrekvId ;
		lnKinni :=ifnull(lnkinni,0);
		if lnKinni = 1 then
	 		raise exception 'Period on kinnitatud';
	        return null;	
*/

	if empty(new.deebet) then
 		raise exception 'Viga: Puudub vajalikud andmed: deebet';
	        return null;	
	end if;
	if empty (new.kreedit) then
 		raise exception 'Viga: Puudub vajalikud andmed: kreedit';
	        return null;	
        end if;		
-- lausendi kontrol

	lcViga = sp_lausendikontrol(new.deebet, new.kreedit, new.lisa_d, new.lisa_k, new.kood1, new.kood2, new.kood5, new.kood3, lcTP, ldkpv);
	if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
		raise exception ':%',lcViga;
	end if;


	return new;
	
end;
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION trigiu_journal1_before() OWNER TO vlad;
GRANT EXECUTE ON FUNCTION trigiu_journal1_before() TO vlad;
GRANT EXECUTE ON FUNCTION trigiu_journal1_before() TO public;
GRANT EXECUTE ON FUNCTION trigiu_journal1_before() TO taabel;
GRANT EXECUTE ON FUNCTION trigiu_journal1_before() TO dbvanemtasu;
GRANT EXECUTE ON FUNCTION trigiu_journal1_before() TO dbkasutaja;
GRANT EXECUTE ON FUNCTION trigiu_journal1_before() TO dbpeakasutaja;
