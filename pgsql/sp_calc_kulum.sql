-- Function: sp_calc_kulum(integer)
/*

SELECT * FROM CURpOHIVARA WHERE kood = '155400-001-00' and rekvid = 70

select sp_calc_kulum(563119) / 15.6466
-- DROP FUNCTION sp_calc_kulum(integer);
*/


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

BEGIN
lnSumma := 0;

select pv_kaart.*, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_pv_kaart 
	FROM pv_kaart left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_kaart.id and dokliik = 18) where parentId = tnId;


SELECT (Pv_oper.summa*ifnull(dokvaluuta1.kuurs,1)::numeric), kpv into lnSummaUmberHind, lnKpvUmberHind 
	FROM Pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13) 
	WHERE Pv_oper.parentid = tnId AND Pv_oper.liik = 5 order by kpv desc limit 1;

if not found then
	lnKpvUmberHind := v_pv_kaart.soetkpv;
	lnSummaUmberHind := (v_pv_kaart.soetmaks*v_pv_kaart.kuurs) ;
end if;

raise notice 'lnSummaUmberHind %',lnSummaUmberHind;
raise notice 'lnKpvUmberHind %',lnKpvUmberHind;


SELECT sum (Pv_oper.summa *ifnull(dokvaluuta1.kuurs,1)::numeric) into lnSummaParandus 
	FROM Pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13) 
	WHERE Pv_oper.parentid = tnId 
	AND Pv_oper.liik = 3 
	and kpv >= lnKpvUmberHind;

SELECT sum (Pv_oper.summa *ifnull(dokvaluuta1.kuurs,1)::numeric) into lnSummaKulum 
	FROM Pv_oper left outer join dokvaluuta1 on (dokvaluuta1.dokid = pv_oper.id and dokvaluuta1.dokliik = 13) 
	WHERE Pv_oper.parentid = tnId  
	AND Pv_oper.liik = 2 
	and kpv >= lnKpvUmberHind;


raise notice 'lnSummaParandus %',lnSummaParandus;
raise notice 'lnSummaKulum %',lnSummaKulum;


if v_pv_kaart.Jaak > 0 then

	lnSumma := (v_pv_kaart.kulum * 0.01 * (lnSummaUmberHind + ifnull(lnSummaParandus,0)) / 12);  

	if lnSumma > (v_pv_kaart.Jaak * v_pv_kaart.kuurs) then

		lnSumma := v_pv_kaart.Jaak * v_pv_kaart.kuurs;

	END IF;

end if;

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
