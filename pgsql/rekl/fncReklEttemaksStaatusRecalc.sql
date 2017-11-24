-- Function: empty(numeric)

-- DROP FUNCTION empty(numeric);
/*
select * from asutus where upper(nimetus) like upper('Datel%')

select  fncReklEttemaksStaatus(86)
*/

CREATE OR REPLACE FUNCTION fncReklEttemaksStaatusRecalc(integer)
  RETURNS integer AS
$BODY$

declare
	tnAsutusId alias for $1;
	lnReturn integer;
	v_ettemaks record;
	lnSumma numeric(18,6);
	
begin
lnReturn = 0;
lnSumma = 0;
update ettemaksud set staatus = 1 where asutusid = tnAsutusId;
for v_ettemaks in
	select id, summa, kpv from ettemaksud where asutusId = tnAsutusId and staatus = 1 order by id
loop
	lnSumma = lnSumma + v_ettemaks.summa;
	if lnSumma = 0 then
		-- balance, koik ettemaksud on suletatud. Vahetame nende staatus 
		update ettemaksud set staatus = 0 where asutusid = tnAsutusid and staatus = 1 and id <= v_ettemaks.id;	
	end if;
	lnReturn = lnReturn + 1;

end loop;

return lnreturn;
end;


$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION fncReklEttemaksStaatusRecalc(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION fncReklEttemaksStaatusRecalc(integer) TO dbpeakasutaja;
