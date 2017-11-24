-- Function: public.sp_del_ametid(int4, int4)

-- DROP FUNCTION public.sp_del_ametid(int4, int4);

CREATE OR REPLACE FUNCTION public.sp_del_ametid(int4, int4) RETURNS INT2 AS '
declare 	tnId alias for $1;	lnCount int4;	lnError int4;begin
	lnError := 0;
	SELECT Tooleping.id into lnCount FROM Tooleping WHERE Tooleping.ametid = tnId LIMIT 1;
	If ifnull(lnCount,0) > 0 then
		return 0;
	end if;	lnError := sp_del_library(tnid);	IF lnError > 0 then		DELETE FROM PALK_TMPL WHERE PARENTID = TNID;		Return 1;	else
		Return 0;
	END IF;
end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
