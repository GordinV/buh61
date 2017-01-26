-- Function: sp_update_pv_jaak(integer)



-- DROP FUNCTION sp_update_pv_jaak(integer);
/*
select sp_update_pv_jaak(curPohivara.id) from curPohivara where year(soetkpv) = 2011

select sp_update_pv_jaak(library.id) from pv_kaart  inner join library on library.id = pv_kaart.parentid 
where pv_kaart.tunnus = 1 and pv_kaart.jaak <= 0 

select sp_update_pv_jaak(61093)

select pv_kaart.parentid from pv_kaart  inner join library on library.id = pv_kaart.parentid 
where kood = 'T155106-219' and rekvid = 6

select sum(summa) from pv_oper where parentid = 61093 and kpv > date(2011,01,01)  
and kpv < dat
order by kpv desc

select * from dokvaluuta1 where dokid = 257343
select * from curpohivara where kood = 'H155100-32'

	select sum(summa*ifnull(dokvaluuta1.kuurs,1))  
		from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
		where parentId = 582959 and liik = 1;

SELECT * FrOM PV_KAART WHERE parentid = 61093

update pv_kaart set algkulum = 1291582.00 where id = 13705

select sp_update_pv_jaak(ID) from library 
where library = 'POHIVARA' and rekvid = 6 and id in (select parentid from pv_oper where liik = 5)
and kood = 'T155106-4'

*/


CREATE OR REPLACE FUNCTION sp_update_pv_jaak(integer)
  RETURNS numeric AS
$BODY$

declare
	tnid alias for $1;
	lnpv_operId int;
	lnId int; 
	lnSumma numeric(18,6);
	v_pv_kaart record;
	lrCurRec record;
	lnPvElu numeric(6,2);
	lnKulum numeric(12,2);

	lnSoetSumma numeric (18,6);
	lnParandatudSumma numeric (18,6);
	lnUmberhindatudSumma numeric (18,6);
	
	lnDokKuurs numeric(14,4);
	lcString varchar;
	v_dokvaluuta record;
	ldKpv date;
	lnJaak numeric (18,6);

	lKasUmberHindatud integer;

begin

lKasUmberHindatud= 0;

	select soetmaks, parhind, algkulum, kulum, soetkpv, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_pv_kaart 
		from pv_kaart left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_kaart.id and dokliik = 18) 
		where pv_kaart.parentId = tnid;

	lnKulum := v_pv_kaart.kulum;
	ldKpv := v_pv_kaart.soetkpv;

	-- PARANDAME PARANDATUD SUMMA.

--	lnSumma = get_pv_summa(tnparentid);




		select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnUmberhindatudSumma 
			from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
			where pv_oper.parentId = tnid and liik = 5;

		lnUmberhindatudSumma := ifnull(lnUmberhindatudSumma,0);

		raise notice 'hind: %',lnUmberhindatudSumma;
		if lnUmberhindatudSumma > 0 then
			select kpv into ldKpv from pv_oper where liik = 5 and parentId = tnId order by kpv desc limit 1;
			lKasUmberHindatud = 1;
		else
			lnUmberhindatudSumma := lnSoetSumma;
		end if;

		raise notice 'kpv: %',ldKpv;

	if lKasUmberHindatud = 0 then
	select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnSoetSumma 
		from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
		where parentId = tnid and liik = 1;

	lnSoetSumma  = ifnull(lnSoetSumma ,v_pv_kaart.soetmaks);

	raise notice 'lnSoetSumma %',lnSoetSumma;

	else
		lnSoetSumma = lnUmberhindatudSumma;		
	end if;
	
	select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnParandatudSumma 
		from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
		where parentId = tnid and liik = 3 and kpv > ldKpv;

		raise notice 'lnParandatudSumma 1: %',lnParandatudSumma;

	lnParandatudSumma = ifnull(lnParandatudSumma,0);

	select sum(summa*ifnull(dokvaluuta1.kuurs,1)) into lnKulum 
		from pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13)
		where parentId = tnid and liik = 2 and kpv > ldKpv;

--	lnParandatudSumma := ifnull(lnParandatudSumma,0) + ifnull(lnUmberhindatudSumma,v_pv_kaart.soetmaks);
	lnKulum = ifnull(lnKulum,0);

	lnParandatudSumma := lnSoetSumma + ifnull(lnParandatudSumma,0);
		raise notice 'lnParandatudSumma 2: %',lnParandatudSumma;



	-- otsime dok.valuuta
	Select id into lnId from pv_kaart where parentid = tnId;
	
		
--	lnParandatudSumma = lnParandatudSumma;
		raise notice 'lnParandatudSumma dokvaluutas %',lnParandatudSumma;

	raise notice 'kulum  %',lnKulum;
	raise notice 'v_pv_kaart.algkulum %',v_pv_kaart.algkulum;


--	if lnUmberhindatudSumma > 0 and lnUmberhindatudSumma <> lnSoetSumma then
--		raise notice 'Umber kulum = 0 %',lnKulum;
--		raise notice 'lnSoetSumma %',lnSoetSumma;
--		raise notice 'lnUmberhindatudSumma %',lnUmberhindatudSumma;
--	end if;
-- privodim k kursu po kotoroj kupleno PO
		lnKulum = ifnull(lnKulum,0);

	lnParandatudSumma = round(lnParandatudSumma / v_pv_kaart.kuurs,2);
	lnKulum = round(lnKulum / v_pv_kaart.kuurs,2);

	if lKasUmberHindatud = 0 then
		lnJaak = lnParandatudSumma - lnKulum - ifnull(v_pv_kaart.algkulum,0);
	else
		lnJaak = lnParandatudSumma - lnKulum ;
	end if;
	raise notice 'lnJaak %',lnJaak;
	update pv_kaart set parhind = lnParandatudSumma , jaak = lnJaak where parentId = tnid;

         return  lnJaak;
end;$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_update_pv_jaak(integer) OWNER TO vlad;
