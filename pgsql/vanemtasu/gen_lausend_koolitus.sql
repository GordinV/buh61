﻿-- Function: gen_lausend_koolitus(integer)

-- DROP FUNCTION gen_lausend_koolitus(integer);

CREATE OR REPLACE FUNCTION gen_lausend_koolitus(integer)
  RETURNS integer AS
$BODY$
	lnJournal1Id int4;	

	lcValuuta varchar(20);
	lnKuurs numeric(12,4);
begin
	select * into v_vanemtasu3 from vanemtasu3 where id = tnId;
	select * into v_dokprop from dokprop where id = v_vanemtasu3.dokpropid limit 1;
	If not Found Or v_dokprop.registr = 0 then
	If v_vanemtasu3.journalid > 0 then

	lnJournalId:= sp_salvesta_journal(0,v_vanemtasu3.rekvId, v_vanemtasu3.UserId, v_vanemtasu3.kpv, 0, 
		ltrim(rtrim(v_dokprop.selg)), '','AUTOMATSELT LAUSEND (GEN_LAUSEND_KOOLITUS)',v_vanemtasu3.id) ;

	select valuuta, kuurs into lcValuuta, lnKuurs from dokvaluuta1 where dokid in (select id from vanemtasu4 where parentid = tnId order by id limit 1) and dokliik = 16;

	lcValuuta = ifnull(lcValuuta,'EEK');
	lnKuurs = ifnull(lnKuurs,1);

/*
	
	lnJournalId:= cast(CURRVAL('public.journal_id_seq') as int4);
*/	
/*			


			if ifnull(lnKontrol,0) = 1 then
				lcViga = sp_lausendikontrol( v_aa.konto, v_korder2.konto, v_aa.tp, v_korder2.tp, v_korder2.kood1, lcAllikas, v_korder2.kood5, v_korder2.kood3);
				if left(ltrim(rtrim(lcViga)),4) = 'Viga' then
					raise exception ':%',lcViga;
				end if;
			end if;
*/
		lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_vanemtasu4.summa,''::varchar,''::text,
				v_vanemtasu4.kood1,v_vanemtasu4.kood2,v_vanemtasu4.kood3,v_vanemtasu4.kood4,v_vanemtasu4.kood5,
					v_vanemtasu3.konto,'800699',v_vanemtasu4.konto,'800699',lcvaluuta,lnkuurs,v_vanemtasu4.summa*lnkuurs,
					v_vanemtasu3.tunnus,v_vanemtasu4.proj);
	

			-- fakt

		lnJournal1Id = sp_salvesta_journal1(0,lnJournalId,v_vanemtasu4.summa,''::varchar,''::text,
				v_vanemtasu4.kood1,v_vanemtasu4.kood2,v_vanemtasu4.kood3,v_vanemtasu4.kood4,v_vanemtasu4.kood5,
					v_vanemtasu3.konto,'800699',v_vanemtasu4.konto,'800699',lcvaluuta,lnkuurs,v_vanemtasu4.summa*lnkuurs,
					v_vanemtasu3.tunnus,v_vanemtasu4.proj);
/*
			Insert Into journal1 (parentId, Summa, deebet, kreedit, lisa_d, lisa_k, kood1, kood2, 
	end if;
	End loop;


$BODY$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;
ALTER FUNCTION gen_lausend_koolitus(integer) OWNER TO vladislav;
GRANT EXECUTE ON FUNCTION gen_lausend_koolitus(integer) TO vladislav;
GRANT EXECUTE ON FUNCTION gen_lausend_koolitus(integer) TO public;
GRANT EXECUTE ON FUNCTION gen_lausend_koolitus(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_koolitus(integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION gen_lausend_koolitus(integer) TO "BS2";