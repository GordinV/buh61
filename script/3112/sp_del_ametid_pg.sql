-- Function: public.sp_del_ametid(int4, int4)

-- DROP FUNCTION public.sp_del_ametid(int4, int4);

CREATE OR REPLACE FUNCTION public.sp_del_ametid(int4, int4) RETURNS INT2 AS '
declare 
	lnError := 0;
	SELECT Tooleping.id into lnCount FROM Tooleping WHERE Tooleping.ametid = tnId LIMIT 1;
	If ifnull(lnCount,0) > 0 then
		return 0;
	end if;
		Return 0;
	END IF;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;