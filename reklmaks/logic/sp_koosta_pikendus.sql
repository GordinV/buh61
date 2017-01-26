-- Function: public.trigd_palk_oper_after()

-- DROP FUNCTION public.trigd_palk_oper_after();

CREATE OR REPLACE FUNCTION public.trigd_palk_oper_after()
  RETURNS trigger AS
'
declare 
	curDokId record;	
	lnLiik int;
begin
IF old.Journalid > 0 then
	perform sp_del_journal(old.Journalid::int4,1::int4);
end if;
perform recalc_palk_saldo(old.lepingId::int4,month(old.kpv)::int2);
select liik into lnLiik from palk_lib where parentid = old.libid;
If lnliik = 6 then
	select * into curDokId from (
		select id as dokid, tyyp as doktyyp, dokid as parentid, doktyyp as parenttyyp 
		from korder1 where dokid >= old.Id 
		union 
		select id as dokid, 3 as doktyyp, dokid as parentid, doktyyp as parenttyyp 
		from MK  where dokid >= old.Id ) a;

	If found then 
		IF curdokid.doktyyp = 3 then
			perform sp_del_mk1(curdokid.dokid,1);
		ELSE
			perform sp_del_korderid(curdokid.dokid,1);
		END IF;		
	END IF;
END IF;
return null;

end; 
'
  LANGUAGE 'plpgsql' VOLATILE;
