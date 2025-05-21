-- Function: trigi_journal1_after()

-- DROP FUNCTION trigi_journal1_after();

CREATE OR REPLACE FUNCTION trigi_journal1_after_def()
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

    -- создание счета если это поступление из банка
    if new.deebet like '113%' and new.kreedit like '122%' and v_journal.muud is not null and
       len(v_journal.muud) >= 14 and v_journal.omvorm in ('E') then
        raise notice 'start generate';
        l_arv_id =  generate_invoice(v_journal.id::integer);
        perform gen_lausend_arv(l_arv_id);


    end if;


    return NULL;


end;


$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;

