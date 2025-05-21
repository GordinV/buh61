DROP FUNCTION if exists generate_invoice(integer);

CREATE OR REPLACE FUNCTION generate_invoice(doc_id integer)
    RETURNS integer AS
$BODY$
declare
    l_new_id      integer;
    l_row_id      integer;
    v_tasu        record;
    v_tehing      record;
    l_doklaus_id  integer;
    l_number      text;
    v_nom         record;
    KBM           numeric = 1.22;
    KBM_MAAR      TEXT    = '22%';
    KREEDIT_KONTO TEXT    = '122%';
    TULU_KONTO    TEXT    = '3201';
    BANK_KONTO    TEXT    = '113%';
    l_error boolean = true;
begin

    raise notice 'doc_id id: %',doc_id;
    -- проверим корректность переданного платежа
/*    "2025021801699139";"1131";"1220"
        "2025021801478847";"1131";"1220"
*/

    select
        j.muud,
        j1.deebet,
        j1.kreedit
    into v_tasu
    from
        journal                 j
            inner join journal1 j1 on j.id = j1.parentid
    where
          j.id = doc_id
      and deebet like BANK_KONTO
      and kreedit like KREEDIT_KONTO
    limit 1;

    if v_tasu is null then
        raise notice 'Puudub tasulise dokument';
        return 0;
    end if;

    -- ищем уже созданный счет
    if exists
    (
        select
            id
        from
            arvtasu
        where
            sorderid = doc_id
    ) then
        raise notice 'оплата уже использована';
        return 0;
    end if;

    -- create dok
    for v_tehing in (
                        select
                            j.asutusid,
                            j.userid,
                            j1.summa,
                            j1.kuurs,
                            j1.valuuta,
                            j1.deebet,
                            j1.kreedit,
                            j.muud,
                            j.kpv,
                            j.rekvid,
                            j.selg,
                            a.omvorm
                        from
                            journal                 j
                                inner join journal1 j1 on j.id = j1.parentid
                        inner join asutus a on a.id = j.asutusid
                        where
                              j.id = doc_id
                          and deebet like BANK_KONTO
                          and kreedit like KREEDIT_KONTO
                    )
        loop
            if v_tehing.deebet like '113%' and v_tehing.kreedit like '122%' and v_tehing.muud is not null and
               len(v_tehing.muud) >= 11 and v_tehing.omvorm in ('E') then
                l_number = ltrim(rtrim(substring(v_tehing.muud from 1 for 14)));
                l_error = false;
            end if;

            if l_error then
                raise notice 'vale konto voi vale asutus';
                return 0;
            end if;

        -- шапка
        -- ищем doklausid
            l_doklaus_id = (
                               select
                                   d.id
                               from
                                   dokprop                d
                                       inner join library l on d.parentid = l.id
                               where
                                     l.kood = 'ARV'
                                 and d.konto like KREEDIT_KONTO
                               order by id desc
                               limit 1
                           );

            -- ищем услугу
            with
                noms as (
                            select *
                            from
                                (
                                    select
                                        a1.nomid,
                                        a1.hind
                                    from
                                        arv                 a
                                            inner join arv1 a1 on a.id = a1.parentid
                                    where
                                        a.asutusid = 6040
                                    order by a.kpv desc
                                    limit 1
                                ) qry
                            union all
                            select
                                l2.nomid,
                                l2.hind
                            from
                                leping1                     l
                                    left outer join leping2 l2 on l2.parentid = l.id
                            where
                                l.asutusid = 6040
                            limit 1
                )
            select *
            into v_nom
            from
                noms
            limit 1;

            if v_nom is null then
                raise notice 'Puudub leping voi arved';
                select
                    v_tehing.summa as hind,
                    id             as nomid
                into v_nom
                from
                    nomenklatuur n
                where
                    n.kood = 'S5310'
                limit 1;
--                return 0;
            end if;

            l_number = (val(sp_get_number(v_tehing.rekvid, 'ARV'::varchar, year(v_tehing.kpv), null)) + 1)::varchar(20);

            if l_new_id is null then
                l_new_id = sp_salvesta_arv(
                        0::integer, --id
                        v_tehing.rekvid:: integer,
                        v_tehing.userid:: integer,
                        1::integer, --user_id
                        l_doklaus_id::integer,
                        0::integer, --liik
                        0::integer, -- operid
                        l_number::varchar(20), --number
                        date(year(v_tehing.kpv), month(v_tehing.kpv), 1):: date, -- kpv
                        v_tehing.asutusid:: integer,
                        0::integer, -- arv_id
                        left('Internet ' || ltrim(rtrim(v_tehing.selg)), 120):: varchar(120), -- lisa
                        v_tehing.kpv:: date, -- tahtaeg
                        v_tehing.summa:: numeric, --tnkbmta
                        0::numeric, -- tnkbm
                        v_tehing.summa:: numeric, -- tnsumma
                        v_tehing.kpv::date, -- tasud
                        '':: character, -- tasudok
                        v_tehing.muud:: text, -- muud
                        0::numeric, --jaak
                        0::integer);


            end if;

            if coalesce(l_new_id, 0) = 0 then
                -- error
                raise notice 'Arve koostamise viga';
                return 0;
            end if;


            l_row_id = sp_salvesta_arv1(
                    0::integer, --id
                    l_new_id:: integer, -- parentid
                    v_nom.nomid::integer, -- nomid
                    1::numeric, -- kogus
                    round(v_nom.hind / KBM, 2), --hind
                    0:: integer, --soodustus
                    (v_tehing.summa - round(v_tehing.summa / KBM, 2)):: numeric, -- summa kbm
                    0::integer, --maha
                    v_tehing.summa::numeric, -- summa
                    v_tehing.muud:: text,
                    '':: character varying, --kood1
                    '':: character varying, --kood2
                    '':: character varying, --kood3
                    '':: character varying, --kood4
                    '':: character varying, --kood5
                    TULU_KONTO:: character varying,
                    '':: character varying,
                    round(v_tehing.summa / KBM, 2):: numeric, -- KMBTA
                    0::integer,
                    '':: character varying, -- tunnus
                    v_tehing.valuuta:: character varying, --kuurs
                    v_tehing.kuurs:: numeric, -- valuuta
                    '':: character varying,
                    KBM_MAAR:: character varying);

            -- сохраним номер счета в проводке
                update journal set dok = l_number where id = doc_id;

            /*    tnid alias for $1;
            tnparentid alias for $2;
            tnnomid alias for $3;
            tnkogus alias for $4;
            tnhind alias for $5;
            tnsoodus alias for $6;
            tnkbm alias for $7;
            tnmaha alias for $8;
            tnsumma alias for $9;
            ttmuud alias for $10;
            tckood1 alias for $11;
            tckood2 alias for $12;
            tckood3 alias for $13;
            tckood4 alias for $14;
            tckood5 alias for $15;
            tckonto alias for $16;
            tctp alias for $17;
            tnkbmta alias for $18;
            tnisikid alias for $19;
            tctunnus alias for $20;
            tcValuuta alias for $21;
            tnKuurs alias for $22;
            tcProj alias for $23;
            tcKbmMaar alias for $24
            */
/*  tnid alias for $1;
rekvid alias for $2;
tnuserid alias for $3;
tnjournalid alias for $4;
tndoklausid alias for $5;
tnliik alias for $6;
tnoperid alias for $7;
tcnumber alias for $8;
tdkpv alias for $9;
tnasutusid alias for $10;
tnarvid alias for $11;
tclisa alias for $12;
tdtahtaeg alias for $13;
tnkbmta alias for $14;
tnkbm alias for $15;
tnsumma alias for $16;
tdtasud alias for $17;
tctasudok alias for $18;
ttmuud alias for $19;
tnjaak alias for $20;
tnobjektid alias for $21;
*/

        end loop;

    -- оплата счета
    perform sp_tasuarv(doc_id::integer, l_new_id::integer, v_tehing.rekvid:: integer, v_tehing.kpv:: date,
                       v_tehing.summa:: numeric, 3::integer, 0:: integer);

    -- lausend
    perform gen_lausend_arv(l_new_id);

    return l_new_id;
--return sp_updateArvJaak(tnArvId, tdKpv);


end;

$BODY$
    LANGUAGE 'plpgsql' VOLATILE
                       COST 100;

GRANT EXECUTE ON FUNCTION generate_invoice(integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION generate_invoice(integer) TO dbpeakasutaja;


/*select generate_invoice(0::integer)*/