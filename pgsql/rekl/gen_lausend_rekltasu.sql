-- Function: gen_lausend_reklmaks(integer)

-- DROP FUNCTION gen_lausend_reklmaks(integer);

CREATE OR REPLACE FUNCTION gen_lausend_rekltasu(integer)
  RETURNS integer AS
$BODY$
declare 	tnId alias for $1;	
		lnJournalNumber int4;	
		lcDbKonto varchar(20);	
		lcKrKonto varchar(20);	
		lcDbTp varchar(20);	
		lcKrTp varchar(20);	
		lcDok varchar(20);	
		lnAsutusId int4;	
		lnJournalId int4;	
		v_luba record;	
		v_dekl record;	
		v_dokprop record;	
		lnSumma numeric;

		lnCount integer;
begin

	select luba.rekvid, luba.number, toiming.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_dekl 
		from toiming inner join luba on toiming.lubaid = luba.id
		left outer join dokvaluuta1 on (toiming.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 24)  where toiming.id = tnId;
/*
	If v_dekl.dokpropid = 0 then	
		raise notice 'ei registreeri';
		Return 0;	
	End if;
	select * into v_dokprop from dokprop where id = v_dekl.dokpropid;	
	
	If not found Or v_dokprop.registr = 0 then		
		raise notice 'puudub dokprop or ei registreeri';
		Return 0;	
	End if;	
*/
	lnJournalId = 0;
	lnSumma = 0;

	if year(v_dekl.kpv) < 2012 then
		raise notice 'Period on kinnitatud';
		return 0;
	end if;

	lnJournalId:= sp_salvesta_journal(0, v_dekl.rekvId, 0, v_dekl.kpv,v_dekl.parentId, 
				v_dekl.alus, v_dekl.number,'AUTOMATSELT LAUSEND (GEN_LAUSEND_REKLTASU)',v_dekl.id) ;
		
	select tp into lcDbTp from asutus where id = v_dekl.parentid;
	lcKrTp = lcDbTp;
	lcDbKonto := '200060';	
	lcKrKonto := '102060';			
	lnAsutusId := v_dekl.parentid;		
	lnSumma = v_dekl.summa;

	perform sp_salvesta_journal1(0,lnJournalId,lnSumma,''::varchar,''::text,
		'01112','','','','3044',lcDbKonto,lcDbTp,lcKrKonto,lcKrTp,v_dekl.valuuta,v_dekl.kuurs,lnSumma*v_dekl.kuurs,'','');


	return lnJournalId;
end; 
$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
GRANT EXECUTE ON FUNCTION gen_lausend_rekltasu(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_rekltasu(integer) TO dbpeakasutaja;
