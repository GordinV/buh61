-- Function: trigi_journal1_after()

-- DROP FUNCTION trigi_journal1_after();

CREATE OR REPLACE FUNCTION trigi_journal1_after()
    RETURNS trigger AS
$BODY$
declare
    lnKontoId  int4;
    lnId       int4;
    l_arv_id integer;
    v_journal  record;
    tmpJournal record;
begin
    select
        j.*,
        a.omvorm
    into v_journal
    from
        journal               j
            inner join asutus a on a.id = j.asutusid
    where
        j.id = new.parentid;
    -- kontrolin deebet
    select id into lnKontoid from library where kood = new.deebet and library = 'KONTOD';
    select
        id
    into lnId
    from
        subkonto
    where
          asutusid = v_journal.asutusid
      and kontoid = lnKontoid
      and rekvid = v_journal.rekvid;

    if not found and ifnull(lnKontoid, 0) > 0 and ifnull(v_journal.Asutusid, 0) > 0 then
        Insert Into subkonto (algsaldo, rekvid, aasta, kontoid, Asutusid)
        Values
            (0, v_journal.rekvId, year(v_journal.kpv), lnKontoId, v_journal.Asutusid);
    end if;

    -- kontrolin kreedit

    select id into lnKontoid from library where kood = new.kreedit and library = 'KONTOD';
    select
        id
    into lnId
    from
        subkonto
    where
          asutusid = v_journal.asutusid
      and kontoid = lnKontoid
      and rekvid = v_journal.rekvid;

    if not found and ifnull(lnKontoid, 0) > 0 and ifnull(v_journal.Asutusid, 0) > 0 then

        Insert Into subkonto (algsaldo, rekvid, aasta, kontoid, Asutusid)
        Values
            (0, v_journal.rekvId, year(v_journal.kpv), lnKontoId, v_journal.Asutusid);
    end if;

    perform sp_register_oper(v_journal.rekvid, new.id, TG_RELNAME::VARCHAR, TG_OP::VARCHAR,
                             sp_currentuser(CURRENT_USER::varchar, v_journal.rekvid));

   -- создание счета если это поступление из банка
/*    if new.deebet like '113%' and new.kreedit like '122%' and v_journal.muud is not null and
       len(v_journal.muud) >= 14 and v_journal.omvorm in ('E') then
           raise notice 'start generate';
           l_arv_id =  generate_invoice(v_journal.id::integer);
           perform gen_lausend_arv(l_arv_id);



    end if;
*/

    return NULL;


end;


$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;

