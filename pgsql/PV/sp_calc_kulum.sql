-- Function: sp_calc_kulum(integer)
/*

select muud from tmp_viivis

select * from curPohivara where rekvid = 15 and kood = '15510905  '

select sp_calc_kulum(589591)

*/
-- DROP FUNCTION sp_calc_kulum(integer);

CREATE OR REPLACE FUNCTION sp_calc_kulum(integer)
  RETURNS numeric AS
$BODY$
declare 
	tnId	ALIAS FOR $1;
	lnSumma numeric(18,6);

	v_pv_kaart record;

	lnSummaParandus numeric(18,6);
	lnSummaUmberHind numeric(18,6);
	lnKpvUmberHind date;

	lnSummaKulum numeric(18,6);

	lnJaak numeric(18,6);
	v_jaak record;
	ltSelgitus text;
	ltEnter varchar;
	lcTimestamp varchar(20);

BEGIN
lnSumma := 0;
ltSelgitus = '';
ltEnter = '
';
lcTimestamp = left('PV'+LTRIM(RTRIM(str(tnId)))+ltrim(rtrim(str(dateasint(date())))),20);
select library.rekvid, pv_kaart.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_pv_kaart 
	FROM library inner join pv_kaart on library.id = pv_kaart.parentid 
	left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_kaart.id and dokliik = 18) where pv_kaart.parentId = tnId;


SELECT (Pv_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric), kpv into lnSummaUmberHind, lnKpvUmberHind 
	FROM Pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13) 
	WHERE Pv_oper.parentid = tnId AND Pv_oper.liik = 5 order by kpv desc limit 1;

if not found then
	lnKpvUmberHind := v_pv_kaart.soetkpv;
	lnSummaUmberHind := (v_pv_kaart.soetmaks*v_pv_kaart.kuurs) ;
	ltSelgitus = ltSelgitus + 'Uus hind:'+ltrim(rtrim(lnSummaUmberHind::varchar))+ltEnter;
end if;

--raise notice 'lnSummaUmberHind %',lnSummaUmberHind;
--raise notice 'lnKpvUmberHind %',lnKpvUmberHind;



SELECT sum (Pv_oper.summa *ifnull(dokvaluuta1.kuurs,1)::numeric) into lnSummaParandus 
	FROM Pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13) 
	WHERE Pv_oper.parentid = tnId 
	AND Pv_oper.liik = 3 
	and kpv >= lnKpvUmberHind;

if ifnull(lnSummaParandus,0) > 0 then
	ltSelgitus = ltSelgitus + 'parandatud hind:'+ltrim(rtrim(lnSummaParandus::varchar))+ltEnter;
end if;
SELECT sum (Pv_oper.summa *ifnull(dokvaluuta1.kuurs,1)::numeric) into lnSummaKulum 
	FROM Pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13) 
	WHERE Pv_oper.parentid = tnId  
	AND Pv_oper.liik = 2 
	and kpv >= lnKpvUmberHind;

if ifnull(lnSummaKulum,0) > 0 then
	ltSelgitus = ltSelgitus + 'kulum kokku:'+ltrim(rtrim(lnSummaKulum::varchar))+ltEnter;
end if;


--raise notice 'lnSummaParandus %',lnSummaParandus;
--raise notice 'lnSummaKulum %',lnSummaKulum;


if v_pv_kaart.Jaak > 0 then

	lnSumma := (v_pv_kaart.kulum * 0.01 * (lnSummaUmberHind + ifnull(lnSummaParandus,0)) / 12);  

	ltSelgitus = ltSelgitus + 'arvestatud summa:'+ltrim(rtrim(lnSumma::varchar))+ltEnter;

	if lnSumma > (v_pv_kaart.Jaak * v_pv_kaart.kuurs) then

		lnSumma := v_pv_kaart.Jaak * v_pv_kaart.kuurs;
		ltSelgitus = ltSelgitus + 'parandus, sest jaak oli vaiksem:'+ltrim(rtrim(lnSumma::varchar))+ltEnter;
	else
		ltSelgitus = ltSelgitus + 'Jaak = 0, siis summa = 0'+ltEnter;

	END IF;
else
		ltSelgitus = ltSelgitus + 'Jaak = 0, siis summa = 0'+ltEnter;
end if;

	-- salvestame arvetuse analuus
	insert into tmp_viivis (rekvid, dkpv, timestamp,muud) values (v_pv_kaart.rekvid,date(), lcTimestamp,ltSelgitus);


RETURN lnSumma;

end;


$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION sp_calc_kulum(integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_kulum(integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_calc_kulum(integer) TO public;
GRANT EXECUTE ON FUNCTION sp_calc_kulum(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_kulum(integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_calc_kulum(integer) TO dbadmin;
GRANT EXECUTE ON FUNCTION sp_calc_kulum(integer) TO dbvaatleja;
GRANT EXECUTE ON FUNCTION sp_calc_kulum(integer) TO taabel;
