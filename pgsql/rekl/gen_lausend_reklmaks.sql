
DROP FUNCTION if exists gen_lausend_reklmaks(integer);

CREATE OR REPLACE FUNCTION gen_lausend_reklmaks(integer)
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
		v_nom record;
		lnSumma numeric;
		lnLausendiSumma numeric;
		lcTunnus varchar(20);

		lnCount integer;
begin

	select toiming.*, ifnull(dokvaluuta1.valuuta,'EEK')::varchar as valuuta, ifnull(dokvaluuta1.kuurs,1)::numeric as kuurs into v_dekl 
		from toiming left outer join dokvaluuta1 on (toiming.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 24)  where toiming.id = tnId;
	If v_dekl.dokpropid = 0 then	
		raise notice 'ei registreeri';
		Return 0;	
	End if;
	select * into v_dokprop from dokprop where id = v_dekl.dokpropid;	
	
	If not found Or v_dokprop.registr = 0 then		
		raise notice 'puudub dokprop or ei registreeri';
		Return 0;	
	End if;	

	lnJournalId = 0;
	lcTunnus = space(1);

	select luba.id, luba.rekvid, luba.parentid, luba.number into v_luba 
			from luba where luba.id = v_dekl.lubaId ;	
	if empty (lcDok) then
			lcDok:= v_luba.number;
	end if;
	If v_dekl.journalid > 0 then			
		Select number into lnJournalNumber from journalid where journalid = v_dekl.journalId;			

		update toiming set journalId = 0 where id = v_dekl.id;
		v_dekl.journalId := sp_del_journal(v_dekl.journalid,1);		
	End if;	
	lnJournalId:= sp_salvesta_journal(0, v_luba.rekvId, 0, v_dekl.saadetud,v_luba.parentId, 
				v_dokprop.selg, lcDok,'AUTOMATSELT LAUSEND (GEN_LAUSEND_REKLMAKS)',v_dekl.id) ;

		
	select tp into lcDbTp from asutus where id = v_luba.parentid;
	lcKrTp = lcDbTp;
	lcDbKonto := '102060';	
	lcKrKonto := '304400';			

	update toiming set journalId = lnJournalId where id = v_dekl.id;		

	lnAsutusId := v_luba.parentid;		

	perform sp_salvesta_journal1(0,lnJournalId,v_dekl.Summa,''::varchar,''::text,
				'01112','','','','3044',
				lcDbKonto,lcDbTp,lcKrKonto,lcKrTp,v_dekl.valuuta,v_dekl.kuurs,v_dekl.Summa*v_dekl.kuurs,
				lctunnus,'');

 
		if v_dekl.journalid > 0 then		
			update journalid set number = lnJournalNumber where journalid = lnJournalId;		
		end if;
	return lnJournalId;
end; 
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;
