-- Function: public.f_round(numeric, numeric)

-- DROP FUNCTION public.f_round(numeric, numeric);

CREATE OR REPLACE FUNCTION public.f_round(numeric, numeric)
  RETURNS numeric AS
'
declare 
	tnSumma	ALIAS FOR $1;
	tnRound alias for $2;
	lnSumma numeric(12,4);
	lnDiffer numeric (12,4);
BEGIN
--lnSumma := 0;lnSumma := round (tnSumma,2);
if tnRound = 0.01 then
--	lnSumma := round (tnSumma,2);
	return lnSumma;
end if;
if tnRound = 0.05 then
	IF ROUND(lnSumma, 1) > tnSumma AND ROUND(lnSumma, 1) <> lnSumma then
		lnDiffer := (ROUND(lnSumma, 1)- ROUND(lnSumma, 2)) * 100;
		if lnDiffer > 2 then
			lnSumma := lnSumma - (5-lnDiffer) * 0.01;
		else
                        lnSumma := lnSumma + lnDiffer * 0.01;
		end if;
		return lnSumma;
         END IF;
         IF ROUND(lnSumma, 1) < lnSumma AND ROUND(lnSumma, 1) <> lnSumma then
                     lnDiffer = (ROUND(lnSumma, 1)-ROUND(lnSumma, 2)) * 100;
			if lnDiffer < 0 then
				lnDiffer:= -1 * lnDiffer;
			end if;
                     IF lnDiffer <> 5 then
--                          lnSumma := tnSumma;
 --                    ELSE
			if lnDiffer < 3 then
				lnSumma := lnSumma-lnDiffer * 0.01;
			else
                               lnSumma := lnSumma+ (5-lnDiffer) * 0.01;
			end if;
                     END IF;
		return lnSumma;
         END IF;
         IF ROUND(tnSumma, 1) = tnSumma then
                 lnSumma := tnSumma;
		return lnSumma;
         END IF;
end if;
if tnRound = 0.10 then 
	lnSumma := ROUND(tnSumma, 1);
else
        lnSumma := ROUND(tnSumma, 0);
END if;
RETURN lnSumma;
end;

'
  LANGUAGE 'plpgsql' VOLATILE;
