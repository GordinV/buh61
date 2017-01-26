-- Function: public.sp_calc_kulum(int4)

-- DROP FUNCTION public.sp_calc_kulum(int4);

CREATE OR REPLACE FUNCTION public.sp_calc_kulum(int4)
  RETURNS numeric AS
'
declare 
	tnId	ALIAS FOR $1;
	lnSumma numeric(12,4);
	v_pv_kaart record;
	lnSummaParandus numeric(12,4);
	lnSummaKulum numeric(12,4);
	lnJaak numeric(12,4);
BEGIN
lnSumma := 0;
select * into v_pv_kaart FROM pv_kaart where parentId = tnId;

SELECT sum (Pv_oper.summa) into lnSummaParandus FROM Pv_oper WHERE Pv_oper.parentid = tnId AND Pv_oper.liik = 3;
SELECT sum (Pv_oper.summa) into lnSummaKulum FROM Pv_oper WHERE Pv_oper.parentid = tnId  AND Pv_oper.liik = 2;
raise notice \'lnSummaParandus %\',lnSummaParandus;
raise notice \'lnSummaKulum %\',lnSummaKulum;

lnJaak := v_pv_kaart.soetmaks+ifnull(lnSummaParandus,0) - ifnull(lnSummaKulum,0) - v_pv_kaart.algkulum ;raise notice \'lnJaak %\',lnJaak;

if lnJaak > 0 then
	lnSumma := round(v_pv_kaart.kulum * 0.01 * (v_pv_kaart.soetmaks+ifnull(lnSummaParandus,0)) / 12,0);  
	if lnSumma > lnJaak then
		lnSumma := lnJaak;
	END IF;
end if;
RETURN lnSumma;
end;

'
  LANGUAGE 'plpgsql' VOLATILE;
