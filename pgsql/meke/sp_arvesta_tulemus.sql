
/*
select sp_arvesta_tulemus(1, date(2012,12,31))

select * from journal order by id desc limit 1

select deebet, kreedit, summa from curJournal where id = 208085 order by deebet

delete from journal1 where parentid = 208085
*/

CREATE OR REPLACE FUNCTION sp_arvesta_tulemus(tnRekvId integer, tdKpv date)
  RETURNS integer AS
$BODY$
DECLARE 
	lcReturn varchar;
	lcString varchar;
	lcOmaTp varchar;
	v_saldoandmik record;
	lnTulemus integer;
	lnJournal integer;
	lnJournal1 integer;
	lnKuurs numeric(20,6);
begin
-- koostan saaldoandmink
	lcreturn = sp_saldoandmik_report(tnRekvId, tdKpv, 0, 0, 0);

	lnKuurs = (select kuurs from valuuta1 v, library l where v.parentid = l.id and l.library = 'VALUUTA' AND kood = 'EUR');

		lnJournal:= sp_salvesta_journal(0, tnrekvId,  sp_currentuser(CURRENT_USER::varchar, tnrekvid), tdkpv, 0, 'Tulemus, tulud'::text,''::varchar,space(1),0, ''::varchar) ;
	
		for v_saldoandmik in
			select sum(db) as db,sum(kr) as kr,konto
			from tmp_saldoandmik
			where timestamp = lcreturn
			and left(konto,1) =  ('3') 
			group by konto
		loop
			if (v_saldoandmik.kr - v_saldoandmik.db) <> 0 then
			
			lnJournal1 = sp_salvesta_journal1(0,lnJournal,(v_saldoandmik.kr - v_saldoandmik.db)/lnKuurs,''::varchar,''::text,
					''::varchar, ''::varchar,''::varchar,''::varchar,''::varchar,v_saldoandmik.konto,'','298000','','EUR',lnKuurs,
					(v_saldoandmik.kr - v_saldoandmik.db)/lnKuurs,
					''::varchar,''::varchar);
					
			if not empty(lnJournal1) then
				raise notice 'Salvestatud : %',v_saldoandmik.konto;
			end if;	
			end if;
		end loop;
			
		lnJournal:= sp_salvesta_journal(0, tnrekvId,  sp_currentuser(CURRENT_USER::varchar, tnrekvid), tdkpv, 0, 'Tulemus, kulud'::text,''::varchar,space(1),0, ''::varchar) ;

	
		for v_saldoandmik in
			select sum(db) as db,sum(kr) as kr,konto
			from tmp_saldoandmik
			where timestamp = lcreturn
			and left(konto,1) in  ('4','5','6')
			group by konto
		loop
			if (v_saldoandmik.db - v_saldoandmik.kr) <> 0 then
			
			lnJournal1 = sp_salvesta_journal1(0,lnJournal,(v_saldoandmik.db - v_saldoandmik.kr)/lnKuurs,''::varchar,''::text,
					''::varchar, ''::varchar,''::varchar,''::varchar,''::varchar,'298000','',v_saldoandmik.konto,'','EUR',
					lnKuurs,(v_saldoandmik.db - v_saldoandmik.kr)/lnKuurs,
					''::varchar,''::varchar);
					
			if not empty(lnJournal1) then
				raise notice 'Salvestatud : %',v_saldoandmik.konto;
			end if;	
			end if;
		end loop;
RETURN lnTulemus;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION sp_arvesta_tulemus(integer, date) TO public;
