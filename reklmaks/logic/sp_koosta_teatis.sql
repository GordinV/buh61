-- Function: public.sp_workdays(int4, int4, int4, int4, int4)

-- DROP FUNCTION public.sp_workdays(int4, int4, int4, int4, int4);

CREATE OR REPLACE FUNCTION public.sp_workdays(int4, int4, int4, int4, int4)
  RETURNS numeric AS
'
declare 
	lnPaev	ALIAS FOR $1;
	lnKuu alias for $2;
	lnAasta alias for $3;
	lnLopppaev alias for $4;
	tnLepingid alias for $5;
	lnreturn numeric;
	lnMaxdays int;
	lnHoliday int;
	lddate date;
	qrytoograf record;
	v_tooleping record;
	qryHoliday record;
	i int;
	lnCount int;
	lnDow int;
	lnrekv int;
BEGIN
lnHoliday := 0;

select l.rekvId into lnrekv from library l, tooleping t 
where l.id = t.ametId
and t.id = tnLepingId;

lnrekv := ifnull(lnrekv,0);

if not empty (tnlepingiD) then 
	SELECT * into qrytoograf FROM Toograf WHERE lepingid = tnLepingId AND kuu = LnKuu AND aasta = LnAasta;
	IF qrYtoograf.tuNd > 0 then
		select * into v_tooleping from tooleping where id = tnLepingId;
		IF v_tooleping.toOpaev > 0 then
			lnReturn := qrYtoograf.tuNd::numeric / v_tooleping.toOpaev::numeric;
			raise notice ''	qrYtoograf.tuNd %'',qrYtoograf.tuNd;
			raise notice ''	v_tooleping.toOpaev %'',v_tooleping.toOpaev;
			RETURN lnReturn;
		END IF;
	END IF;
end if;
ldDate := DATE(lnAasta, lnKuu, lnPaev);
lnMaxdays := DAY(GOMONTH(DATE(lnAasta, lnKuu, 1), 1)-1);
IF lnMaxdays > lnLopppaev then
        lnMaxdays := lnLopppaev;
END IF;

FOR i in lnPaev..lnMaxdays
loop
	lnDow:=DOW(ldDate);
	IF lnDOW = 6 OR lnDOW = 7 or lnDow = 0 then
		lnHoliday := lnHoliday+1;
        ELSE
		SELECT count(id) into lnCount from holidays where rekvid = lnrekv and paEv=DAY(ldDate) AND kuU=MONTH(ldDate) group by kuu, paev;
		if lnCount > 0 then
                          lnHoliday := lnHoliday+1;
                END IF;
        END IF;
        ldDate := ldDate+1;
END loop;
lnReturn := lnMaxdays-lnHoliday-lnPaev+1;
lnReturn := ifnull(lnReturn, 0);

RETURN lnReturn;
end;

'
  LANGUAGE 'plpgsql' VOLATILE;
