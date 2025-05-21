alter table arv
    ADD COLUMN if not exists viitenr character varying(20) COLLATE pg_catalog."default"
        NOT NULL DEFAULT ''::character varying;

ALTER TABLE arv
    ADD COLUMN if not exists aa character varying(28) COLLATE pg_catalog."default"
        NOT NULL DEFAULT ''::character varying;

ALTER TABLE arv1
    ADD COLUMN if not exists kbm_maar character varying(20) COLLATE pg_catalog."default" NOT NULL
        DEFAULT ''::character varying;

CREATE OR REPLACE FUNCTION public.sp_salvesta_arv1(
    integer,
    integer,
    integer,
    numeric,
    numeric,
    integer,
    numeric,
    integer,
    numeric,
    text,
    character varying,
    character varying,
    character varying,
    character varying,
    character varying,
    character varying,
    character varying,
    numeric,
    integer,
    character varying,
    character varying,
    numeric,
    character varying,
    character varying)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$


declare
    tnid alias for $1;
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
    tcKbmMaar alias for $24;
    lnarv1Id int;
    lnId int;
    lrCurRec record;
    v_dokvaluuta record;
    lnRekvId int;

begin

    tcValuuta = 'EUR';
    tnKuurs = 15.6466;

    IF tcKbmMaar is null OR  EMPTY(tcKbmMaar) THEN
        if (select doklausid from nomenklatuur n where id = tnnomid limit 1) = 6 then
            tcKbmMaar = '22';
        elsif (select doklausid from nomenklatuur n where id = tnnomid limit 1) = 5 then
            tcKbmMaar = '20';
        else
            tcKbmMaar = '';
        end if;
        tcKbmMaar = coalesce(tcKbmMaar,'');
    END if;

    if tnId = 0 then
        -- uus kiri
        insert into arv1 (parentid,nomid,kogus,hind,soodus,kbm,maha,summa,muud,kood1,kood2,kood3,kood4,kood5,konto,tp,kbmta,isikid,tunnus,proj, kbm_maar)
        values (tnparentid,tnnomid,tnkogus,tnhind,tnsoodus,tnkbm,tnmaha,tnsumma,ttmuud,tckood1,tckood2,tckood3,tckood4,tckood5,tckonto,tctp,tnkbmta,tnisikid,tctunnus,tcProj, tcKbmMaar);


        GET DIAGNOSTICS lnId = ROW_COUNT;

        if lnId > 0 then
            --	raise notice 'lnId %',lnId;
            lnarv1Id:= cast(CURRVAL('public.arv1_id_seq') as int4);
            --	raise notice 'lnaastaId %',lnaastaId;
        else
            lnarv1Id = 0;
        end if;

        if lnarv1Id = 0 then
            raise exception ':%','Ei saa lisada kiri';
        end if;

        -- valuuta

        insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs)
        values (lnarv1Id,2,tcValuuta, tnKuurs);


    else
        -- muuda
        select * into lrCurRec from arv1 where id = tnId;
        if lrCurRec.parentid <> tnparentid or lrCurRec.nomid <> tnnomid or lrCurRec.kogus <> tnkogus or lrCurRec.hind <> tnhind or lrCurRec.soodus <> tnsoodus
            or lrCurRec.kbm <> tnkbm or lrCurRec.maha <> tnmaha or lrCurRec.summa <> tnsumma or ifnull(lrCurRec.muud,space(1)) <> ifnull(ttmuud,space(1))
            or lrCurRec.kood1 <> tckood1 or lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or lrCurRec.kood5 <> tckood5
            or lrCurRec.konto <> tckonto or lrCurRec.tp <> tctp or lrCurRec.kbmta <> tnkbmta
            or lrCurRec.isikid <> tnisikid or lrCurRec.tunnus <> tctunnus or lrCurRec.proj <> tcProj then
            update arv1 set
                            parentid = tnparentid,
                            nomid = tnnomid,
                            kogus = tnkogus,
                            hind = tnhind,
                            soodus = tnsoodus,
                            kbm = tnkbm,
                            maha = tnmaha,
                            summa = tnsumma,
                            muud = ttmuud,
                            kood1 = tckood1,
                            kood2 = tckood2,
                            kood3 = tckood3,
                            kood4 = tckood4,
                            kood5 = tckood5,
                            konto = tckonto,
                            tp = tctp,
                            kbmta = tnkbmta,
                            isikid = tnisikid,
                            tunnus = tctunnus,
                            proj = tcProj,
                            kbm_maar = tcKbmMaar
            where id = tnId;
        end if;
        lnarv1Id := tnId;

        -- valuuta
        if (select count(id) from dokvaluuta1 where dokliik = 2 and dokid = lnarv1Id) = 0 then

            insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs)
            values (2, lnarv1Id,tcValuuta, tnKuurs);
        else
            select * into v_dokvaluuta from dokvaluuta1 where dokliik = 2 and dokid = lnarv1Id ;

            if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

                update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;


            end if;

        end if;

    end if;

    -- kontrollin valuuta arv taabelis

    if (select count(id) from dokvaluuta1 where dokliik = 3 and dokid = tnParentId) = 0 then

        insert into dokvaluuta1 (dokid, dokliik, valuuta, kuurs)
        values (tnParentId,3,tcValuuta, tnKuurs);
    else

        update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where dokid = tnParentId and dokliik = 3;

    end if;

    perform sp_updatearvjaak(tnParentId, date());
-- Ladu

    if (select count(id) from ladu_grupp where ladu_grupp.nomId = tnnomId) > 0 then
        select rekvid into lnRekvid from arv where id = tnParentid;
        perform sp_recalc_ladujaak(lnRekvId, tnNomId, 0);
    end if;

    return  lnarv1Id;
end;
$BODY$;

CREATE OR REPLACE FUNCTION public.gen_lausend_arv(
    integer)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$

declare
    tnId alias for $1;
    lnJournalNumber int4;
    lcDbKonto       varchar(20);
    lcKrKonto       varchar(20);
    lcDbTp          varchar(20);
    lcKrTp          varchar(20);
    lcKood5         varchar(20);
    lnAsutusId      int4;
    lnJournal       int4;
    lcKbmTp         varchar(20);
    lcDbKbmTp       varchar(20);
    v_arv           arv%rowtype;
    v_dokprop       dokprop%rowtype;
    v_aa            aa%rowtype;
    v_arv1          record;
    v_asutus        asutus%rowtype;
    lnUserId        int;
    lnKontrol       int;
    lcAllikas       varchar(20);
    lcviga          varchar;
    lnJournal1      int;
    lcOmaTP         varchar(20);
    lcValuuta       varchar(20);
    lnKuurs         numeric(14, 4);
    lcSelg          varchar(254);
    v_selg          record;
    l_row_id        integer;


begin


    select * into v_arv from arv where id = tnId;
    If v_arv.doklausid = 0 then
        Return 0;
    End if;

    select recalc into lnKontrol from rekv where id = v_arv.rekvid;
    if v_arv.rekvid > 1 then
        lcAllikas = 'LE-P';
    end if;
--	raise notice 'lnKontrol: %',lnKontrol;

    select * into v_dokprop from dokprop where id = v_arv.doklausid limit 1;
    If not Found or v_dokprop.registr = 0 then
        Return 0;
    End if;

    lcSelg = ltrim(rtrim(v_dokprop.selg));

-- koostame selg rea
    if (
           select
               count(id)
           from
               rekv
           where
                parentid = 119
             or id = 119
       ) > 0 then
        lcSelg = '';
        for v_selg in
            select distinct
                nom.nimetus
            from
                arv1
                    inner join nomenklatuur nom on arv1.nomid = nom.id
            where
                arv1.parentid = v_arv.id
            loop
                if (len(ltrim(rtrim(lcSelg))) + len(ltrim(rtrim(v_selg.nimetus)))) < 254 then
                    lcSelg = lcSelg + ltrim(rtrim(v_selg.nimetus)) + ',';
                end if;
            end loop;
    end if;
    lcSelg = lcSelg + ltrim(rtrim(v_dokprop.selg));

    If v_arv.journalid > 0 then
        update arv set journalId = 0 where id = v_arv.id;
        select number into lnJournalNumber from journalId where journalId = v_arv.journalId;
        if ifnull(lnJournalNumber, 0) > 0 then
            if sp_del_journal(v_arv.journalid, 1) = 0 then
                Return 0;
            End if;
        end if;
    End if;
    select * into v_aa from aa where parentid = v_arv.rekvId limit 1;
    select id into lnUserId from userid where userid.rekvid = v_arv.rekvid and userid.kasutaja = CURRENT_USER::varchar;

    lnJournal := sp_salvesta_journal(0, v_arv.rekvId, v_arv.UserId, v_arv.kpv, v_arv.asutusId,
                                     ltrim(rtrim(lcselg)) + ' ' + ltrim(rtrim(v_arv.lisa)),
                                     'Arve nr.' + ltrim(rtrim(v_arv.number)), space(1), v_arv.id, v_arv.objekt);

--	lisatud 01/02/2005
    Select tp into lcDbKbmTp from asutus where id = v_arv.Asutusid;
    lcDbKbmTp := ifnull(lcDbKbmTp, '800599');
    lcKrTp := ifnull(lcDbKbmTp, '800599');
    for v_arv1 in
        select
            arv1.*,
            ifnull(dokvaluuta1.valuuta, 'EEK')::varchar as valuuta,
            ifnull(dokvaluuta1.kuurs, 1)::numeric       as kuurs
        from
            arv1
                left outer join dokvaluuta1 on (arv1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 2)
        where
            arv1.parentid = v_arv.Id
        loop
            --	lisatud 18/03/2005
            if not empty(v_arv1.tp) then
                lcDbKbmTp := v_arv1.tp;
            end if;
            if not empty(v_arv1.kood2) then
                lcAllikas = v_arv1.kood2;
            end if;
            lcKood5 = v_arv1.kood5;

            raise notice 'v_arv1.id %', v_arv1.id;

            If v_arv.liik = 0 then
                if left(ltrim(rtrim(v_dokprop.konto)), 6) = '103701' then
                    lcDbKbmTp := '014003';
                end if;

                l_row_id = 0;

                -- will check if exists
                select
                    id
                into l_row_id
                from
                    journal1
                where
                      parentid = lnJournal
                  and deebet = v_dokprop.konto
                  and kreedit = v_arv1.konto
                  and summa = v_arv1.kbmta
                limit 1;

                lnJournal1 = sp_salvesta_journal1(coalesce(l_row_id, 0), lnJournal, v_arv1.kbmta, ''::varchar, ''::text,
                                                  v_arv1.kood1, v_arv1.kood2, v_arv1.kood3, v_arv1.kood4,
                                                  v_arv1.kood5,
                                                  v_dokprop.konto, lcDbKbmTp, v_arv1.konto, lcDbKbmTp,
                                                  v_arv1.valuuta, v_arv1.kuurs, v_arv1.kbmta * v_arv1.kuurs,
                                                  v_arv1.tunnus, v_arv1.proj);

                -- kbm
                If v_arv1.kbm <> 0 then
                    l_row_id = 0;

                    -- will check if exists
                    select
                        id
                    into l_row_id
                    from
                        journal1
                    where
                          parentid = lnJournal
                      and deebet = v_dokprop.konto
                      and kreedit = v_dokprop.kbmkonto
                      and summa = v_arv1.kbm
                    limit 1;

                    lnJournal1 = sp_salvesta_journal1(coalesce(l_row_id, 0), lnJournal, v_arv1.kbm, ''::varchar,
                                                      ''::text,
                                                      '', '', '', '', '',
                                                      v_dokprop.konto, lcDbKbmTp, v_dokprop.kbmkonto, '',
                                                      v_arv1.valuuta, v_arv1.kuurs, v_arv1.kbm * v_arv1.kuurs,
                                                      v_arv1.tunnus, v_arv1.proj);
                END IF;
            Else
                if v_arv1.konto = '601000' or v_arv1.konto = '203000' then
                    lcDbKbmTp := '014003';
                end if;

                if left(ltrim(rtrim(v_arv1.konto)), 6) = '103701' then
                    lcDbKbmTp := '014003';
                end if;


                if lnKontrol = 1 then

                    lcViga = sp_lausendikontrol(v_arv1.konto, v_dokprop.konto, lcDbKbmTp, lcKrTp, v_arv1.kood1,
                                                lcAllikas, lckood5, v_arv1.kood3,
                                                lcOmaTP, v_arv.Kpv);
                    if left(ltrim(rtrim(lcViga)), 4) = 'Viga' then
                        raise exception ':%',lcViga;
                    end if;
                end if;

                lnJournal1 = sp_salvesta_journal1(0, lnJournal, v_arv1.kbmta, ''::varchar, ''::text,
                                                  v_arv1.kood1, lcAllikas, v_arv1.kood3, v_arv1.kood4, lckood5,
                                                  v_arv1.konto, lcDbKbmTp, v_dokprop.konto, lcKrTp, v_arv1.valuuta,
                                                  v_arv1.kuurs, v_arv1.kbmta * v_arv1.kuurs,
                                                  v_arv1.tunnus, v_arv1.proj);

                -- kbm
                If v_arv1.kbm <> 0 then
                    l_row_id = 0;

                    -- will check if exists
                    select
                        id
                    into l_row_id
                    from
                        journal1
                    where
                          parentid = lnJournal
                      and kreedit = v_dokprop.konto
                      and deebet = v_dokprop.kbmkonto
                      and summa = v_arv1.kbm
                    limit 1;

                    lnJournal1 =
                            sp_salvesta_journal1(coalesce(l_row_id, 0), lnJournal, v_arv1.kbm, ''::varchar, ''::text,
                                                 v_arv1.kood1, lcAllikas, v_arv1.kood3, v_arv1.kood4, lcKood5,
                                                 v_dokprop.kbmkonto, '014003', v_dokprop.konto, lcKrTp,
                                                 v_arv1.valuuta, v_arv1.kuurs, v_arv1.kbm * v_arv1.kuurs,
                                                 v_arv1.tunnus, v_arv1.proj);

                end if;
            End if;
        End loop;

    update arv set journalId = lnJournal where id = v_arv.id;
    If v_arv.journalid > 0 and ifnull(lnJournalNumber, 0) > 0 then
        update journalid set number = lnJournalNumber where journalid = lnJournal;
    end if;
--	commit;
    return lnJournal;
end ;
$BODY$;

ALTER FUNCTION public.gen_lausend_arv(integer)
    OWNER TO vlad;

GRANT EXECUTE ON FUNCTION public.gen_lausend_arv(integer) TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.gen_lausend_arv(integer) TO dbadmin;

GRANT EXECUTE ON FUNCTION public.gen_lausend_arv(integer) TO dbkasutaja;

GRANT EXECUTE ON FUNCTION public.gen_lausend_arv(integer) TO dbpeakasutaja;

GRANT EXECUTE ON FUNCTION public.gen_lausend_arv(integer) TO dbvaatleja;

GRANT EXECUTE ON FUNCTION public.gen_lausend_arv(integer) TO vlad;

drop view if exists public.curarved;
CREATE OR REPLACE VIEW public.curarved
AS
SELECT arv.id,
       arv.rekvid,
       arv.number,
       arv.kpv,
       arv.tahtaeg,
       arv.summa,
       arv.kbm,
       arv.kbmta,
       arv.tasud,
       arv.tasudok,
       arv.userid,
       asutus.nimetus AS asutus,
       arv.asutusid,
       arv.journalid,
       arv.liik,
       arv.operid,
       round(arv.jaak / coalesce(dokvaluuta1.kuurs, 15.6466::numeric),2)::numeric(12,2) as jaak,
       arv.objektid,
       arv.doklausid,
       coalesce(dokprop.konto::bpchar, space(20)) AS konto,
       arv.muud,
       coalesce(dokvaluuta1.valuuta::bpchar, 'EUR'::bpchar)::character varying AS valuuta,
       coalesce(dokvaluuta1.kuurs, 15.6466::numeric) AS kuurs,
       coalesce(arv.objekt::bpchar, space(20))::character varying AS objekt,
       userid.ametnik
FROM arv
         JOIN asutus asutus ON asutus.id = arv.asutusid
         JOIN userid ON arv.userid = userid.id
         LEFT JOIN dokprop ON dokprop.id = arv.doklausid
         LEFT JOIN dokvaluuta1 ON arv.id = dokvaluuta1.dokid AND dokvaluuta1.dokliik = 3;


CREATE OR REPLACE FUNCTION public.sp_salvesta_journal1(
    integer,
    integer,
    numeric,
    character,
    text,
    character varying,
    character varying,
    character varying,
    character varying,
    character varying,
    character varying,
    character varying,
    character varying,
    character varying,
    character varying,
    numeric,
    numeric,
    character varying,
    character varying)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$


declare
    tnid alias for $1;
    tnparentid alias for $2;
    tnsumma alias for $3;
    tcdokument alias for $4;
    ttmuud alias for $5;
    tckood1 alias for $6;
    tckood2 alias for $7;
    tckood3 alias for $8;
    tckood4 alias for $9;
    tckood5 alias for $10;
    tcdeebet alias for $11;
    tclisa_d alias for $12;
    tckreedit alias for $13;
    tclisa_k alias for $14;
    tcvaluuta alias for $15;
    tnkuurs alias for $16;
    tnvalsumma alias for $17;
    tctunnus alias for $18;
    tcProj alias for $19;
    lnjournal1Id  int;
    lnId          int;
    lrCurRec      record;
    tmpJournal    record;
    lnKontrol     int;
    lnrekvid      int;
    lcViga        varchar;
    lcOmaTp       varchar;
    ldKpv         date;
    v_dokvaluuta  record;
    l_arve_number varchar(20);
    l_arve_id     integer;
begin

    select rekvid, kpv into lnrekvId, ldKpv from journal where id = tnparentid;
    select recalc into lnKontrol from rekv where id = lnrekvid;

    lcOmaTp = ltrim(rtrim(fnc_getomatp(lnrekvId, year(ldKpv))));

    if ifnull(lnKontrol, 0) = 1 then
        lcViga =
                sp_lausendikontrol(tcdeebet, tcKreedit, tclisa_d, tclisa_k, tckood1, tcKood2, tckood5, tckood3, lcOmaTP,
                                   ldKpv, tcvaluuta);
        if left(ltrim(rtrim(lcViga)), 4) = 'Viga' then
            raise exception ':%',lcViga;
            return 0;
        end if;
    end if;


    if tnId = 0 then
        -- uus kiri
        insert into
            journal1 (parentid, summa, dokument, muud, kood1, kood2, kood3, kood4, kood5, deebet, lisa_d, kreedit,
                      lisa_k, valuuta, kuurs, valsumma, tunnus, proj)
        values
            (tnparentid, tnsumma, tcdokument, ttmuud, tckood1, tckood2, tckood3, tckood4, tckood5, tcdeebet, tclisa_d,
             tckreedit, tclisa_k, tcvaluuta, tnkuurs, tnvalsumma, tctunnus, tcProj);

        GET DIAGNOSTICS lnId = ROW_COUNT;

        if lnId > 0 then
            --	raise notice 'lnId %',lnId;
            lnjournal1Id := cast(CURRVAL('public.journal1_id_seq') as int4);
            --	raise notice 'lnaastaId %',lnaastaId;
        else
            lnjournal1Id = 0;
        end if;

        if lnjournal1Id = 0 then
            raise exception ':%','Ei saa lisada kiri';
        end if;

        -- valuuta

        insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs)
        values (1, lnjournal1Id, tcValuuta, tnKuurs);

    else
        -- muuda
        select * into lrCurRec from journal1 where id = tnId;
        if lrCurRec.parentid <> tnparentid or lrCurRec.summa <> tnsumma or
           ifnull(lrCurRec.dokument, space(1)) <> ifnull(tcdokument, space(1)) or
           ifnull(lrCurRec.muud, space(1)) <> ifnull(ttmuud, space(1)) or lrCurRec.kood1 <> tckood1 or
           lrCurRec.kood2 <> tckood2 or lrCurRec.kood3 <> tckood3 or lrCurRec.kood4 <> tckood4 or
           lrCurRec.kood5 <> tckood5 or lrCurRec.deebet <> tcdeebet or lrCurRec.lisa_k <> tclisa_k or
           lrCurRec.kreedit <> tckreedit or lrCurRec.lisa_d <> tclisa_d or lrCurRec.valuuta <> tcvaluuta or
           lrCurRec.kuurs <> tnkuurs or lrCurRec.valsumma <> tnvalsumma or lrCurRec.tunnus <> tctunnus or
           lrCurRec.proj <> tcProj then
            update journal1
            set
                parentid = tnparentid,
                summa    = tnsumma,
                dokument = tcdokument,
                muud     = ttmuud,
                kood1    = tckood1,
                kood2    = tckood2,
                kood3    = tckood3,
                kood4    = tckood4,
                kood5    = tckood5,
                deebet   = tcdeebet,
                lisa_k   = tclisa_k,
                kreedit  = tckreedit,
                lisa_d   = tclisa_d,
                valuuta  = tcvaluuta,
                kuurs    = tnkuurs,
                valsumma = tnvalsumma,
                tunnus   = tctunnus,
                proj     = tcproj
            where
                id = tnId;
        end if;
        lnjournal1Id := tnId;


        -- valuuta
        if (
               select count(id) from dokvaluuta1 where dokliik = 1 and dokid = lnjournal1Id
           ) = 0 then

            insert into dokvaluuta1 (dokliik, dokid, valuuta, kuurs)
            values (1, lnjournal1Id, tcValuuta, tnKuurs);
        else
            select * into v_dokvaluuta from dokvaluuta1 where dokliik = 1 and dokid = lnjournal1Id;

            if tcValuuta <> v_dokvaluuta.valuuta or tnKuurs <> v_dokvaluuta.kuurs then

                update dokvaluuta1 set valuuta = tcValuuta, kuurs = tnKuurs where id = v_dokvaluuta.id;

            end if;

        end if;


    end if;

    select id, rekvid, kpv, asutusId, dok into tmpJournal from journal where id = tnparentId;


--avans
    select
        avans1.id
    into lnId
    from
        avans1
            inner join dokprop on dokprop.id = avans1.dokpropid
    where
          ltrim(rtrim(number)) = ltrim(rtrim(tmpJournal.dok))
      and rekvid = tmpJournal.rekvid
      and avans1.asutusId = tmpJournal.asutusId
      and ltrim(rtrim(dokprop.konto)) = ltrim(rtrim(tcDeebet))
    order by avans1.kpv desc
    limit 1;

    if ifnull(lnId, 0) > 0 then
        perform fnc_avansijaak(lnId);
    end if;

    if empty(coalesce(tmpJournal.dok, ''))
        and (
                select omvorm
                from asutus a
                where id = tmpJournal.asutusId
                limit 1
            ) <> 'E'
        and tcdeebet like '113%' then

        select
            arve_number,
            arve_id
        into l_arve_number, l_arve_id
        from
            get_tasumata_arv_number(tmpJournal.asutusId, tnsumma, tckreedit);

        if l_arve_number is not null then
            -- found arve
            update journal set dok = l_arve_number where id = tmpJournal.id;

            -- tasumine
            perform sp_tasuarv(tmpJournal.id::integer, l_arve_id::integer, tmpJournal.rekvid:: integer,
                               tmpJournal.kpv:: date,
                               tnSumma:: numeric, 3::integer, 0:: integer);

        end if;

    end if;

    -- reklmaks
/*

if (select count(id) from luba where number = tmpJournal.dok and rekvid = tmpJournal.rekvid and luba.parentid = tmpJournal.asutusId) > 0 then
	perform sp_tasu_dekl(tmpJournal.id);
end if;
*/

    return lnjournal1Id;
end;
$BODY$;

ALTER FUNCTION public.sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying)
    OWNER TO vlad;

GRANT EXECUTE ON FUNCTION public.sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO dbkasutaja;

GRANT EXECUTE ON FUNCTION public.sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO dbpeakasutaja;

GRANT EXECUTE ON FUNCTION public.sp_salvesta_journal1(integer, integer, numeric, character, text, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, numeric, numeric, character varying, character varying) TO vlad;


CREATE OR REPLACE FUNCTION public.gen_lausend_arv(
    integer)
    RETURNS integer
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$

declare
    tnId alias for $1;
    lnJournalNumber int4;
    lcDbKonto       varchar(20);
    lcKrKonto       varchar(20);
    lcDbTp          varchar(20);
    lcKrTp          varchar(20);
    lcKood5         varchar(20);
    lnAsutusId      int4;
    lnJournal       int4;
    lcKbmTp         varchar(20);
    lcDbKbmTp       varchar(20);
    v_arv           arv%rowtype;
    v_dokprop       dokprop%rowtype;
    v_aa            aa%rowtype;
    v_arv1          record;
    v_asutus        asutus%rowtype;
    lnUserId        int;
    lnKontrol       int;
    lcAllikas       varchar(20);
    lcviga          varchar;
    lnJournal1      int;
    lcOmaTP         varchar(20);
    lcValuuta       varchar(20);
    lnKuurs         numeric(14, 4);
    lcSelg          varchar(254);
    v_selg          record;
    l_row_id        integer;


begin


    select * into v_arv from arv where id = tnId;
    If v_arv.doklausid = 0 then
        Return 0;
    End if;

    select recalc into lnKontrol from rekv where id = v_arv.rekvid;
    if v_arv.rekvid > 1 then
        lcAllikas = 'LE-P';
    end if;
--	raise notice 'lnKontrol: %',lnKontrol;

    select * into v_dokprop from dokprop where id = v_arv.doklausid limit 1;
    If not Found or v_dokprop.registr = 0 then
        Return 0;
    End if;

    lcSelg = ltrim(rtrim(v_dokprop.selg));

-- koostame selg rea
    if (
           select
               count(id)
           from
               rekv
           where
                parentid = 119
             or id = 119
       ) > 0 then
        lcSelg = '';
        for v_selg in
            select distinct
                nom.nimetus
            from
                arv1
                    inner join nomenklatuur nom on arv1.nomid = nom.id
            where
                arv1.parentid = v_arv.id
            loop
                if (len(ltrim(rtrim(lcSelg))) + len(ltrim(rtrim(v_selg.nimetus)))) < 254 then
                    lcSelg = lcSelg + ltrim(rtrim(v_selg.nimetus)) + ',';
                end if;
            end loop;
    end if;
    lcSelg = lcSelg + ltrim(rtrim(v_dokprop.selg));

    If v_arv.journalid > 0 then
        update arv set journalId = 0 where id = v_arv.id;
        select number into lnJournalNumber from journalId where journalId = v_arv.journalId;
        if ifnull(lnJournalNumber, 0) > 0 then
            if sp_del_journal(v_arv.journalid, 1) = 0 then
                Return 0;
            End if;
        end if;
    End if;
    select * into v_aa from aa where parentid = v_arv.rekvId limit 1;
    select id into lnUserId from userid where userid.rekvid = v_arv.rekvid and userid.kasutaja = CURRENT_USER::varchar;

    lnJournal := sp_salvesta_journal(0, v_arv.rekvId, v_arv.UserId, v_arv.kpv, v_arv.asutusId,
                                     ltrim(rtrim(lcselg)) + ' ' + ltrim(rtrim(v_arv.lisa)),
                                     'Arve nr.' + ltrim(rtrim(v_arv.number)), space(1), v_arv.id, v_arv.objekt);

--	lisatud 01/02/2005
    Select tp into lcDbKbmTp from asutus where id = v_arv.Asutusid;
    lcDbKbmTp := ifnull(lcDbKbmTp, '800599');
    lcKrTp := ifnull(lcDbKbmTp, '800599');
    for v_arv1 in
        select
            arv1.*,
            ifnull(dokvaluuta1.valuuta, 'EEK')::varchar as valuuta,
            ifnull(dokvaluuta1.kuurs, 1)::numeric       as kuurs
        from
            arv1
                left outer join dokvaluuta1 on (arv1.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 2)
        where
            arv1.parentid = v_arv.Id
        loop
            --	lisatud 18/03/2005
            if not empty(v_arv1.tp) then
                lcDbKbmTp := v_arv1.tp;
            end if;
            if not empty(v_arv1.kood2) then
                lcAllikas = v_arv1.kood2;
            end if;
            lcKood5 = v_arv1.kood5;

            raise notice 'v_arv1.id %', v_arv1.id;

            If v_arv.liik = 0 then
                if left(ltrim(rtrim(v_dokprop.konto)), 6) = '103701' then
                    lcDbKbmTp := '014003';
                end if;

                l_row_id = 0;

                -- will check if exists
                select
                    id
                into l_row_id
                from
                    journal1
                where
                      parentid = lnJournal
                  and deebet = v_dokprop.konto
                  and kreedit = v_arv1.konto
                  and summa = v_arv1.kbmta
                limit 1;

                lnJournal1 = sp_salvesta_journal1(coalesce(l_row_id, 0), lnJournal, v_arv1.kbmta, ''::varchar, ''::text,
                                                  coalesce(v_arv1.kood1,'')::varchar(20),
                                                  coalesce(v_arv1.kood2,'')::varchar(20),
                                                  coalesce(v_arv1.kood3,'')::varchar(20),
                                                  coalesce(v_arv1.kood4,'')::varchar(20),
                                                  coalesce(v_arv1.kood5,'')::varchar(20),
                                                  v_dokprop.konto,
                                                  coalesce(lcDbKbmTp,'')::varchar(20),
                                                  v_arv1.konto,
                                                  coalesce(lcDbKbmTp,'')::varchar(20),
                                                  v_arv1.valuuta, v_arv1.kuurs,
                                                  v_arv1.kbmta * v_arv1.kuurs,
                                                  v_arv1.tunnus,
                                                  coalesce(v_arv1.proj,'')::varchar(20));

                -- kbm
                If v_arv1.kbm <> 0 then
                    l_row_id = 0;

                    -- will check if exists
                    select
                        id
                    into l_row_id
                    from
                        journal1
                    where
                          parentid = lnJournal
                      and deebet = v_dokprop.konto
                      and kreedit = v_dokprop.kbmkonto
                      and summa = v_arv1.kbm
                    limit 1;

                    lnJournal1 = sp_salvesta_journal1(coalesce(l_row_id, 0), lnJournal, v_arv1.kbm, ''::varchar,
                                                      ''::text,
                                                      '', '', '', '', '',
                                                      v_dokprop.konto, lcDbKbmTp, v_dokprop.kbmkonto, '',
                                                      v_arv1.valuuta, v_arv1.kuurs, v_arv1.kbm * v_arv1.kuurs,
                                                      v_arv1.tunnus, v_arv1.proj);
                END IF;
            Else
                if v_arv1.konto = '601000' or v_arv1.konto = '203000' then
                    lcDbKbmTp := '014003';
                end if;

                if left(ltrim(rtrim(v_arv1.konto)), 6) = '103701' then
                    lcDbKbmTp := '014003';
                end if;


                if lnKontrol = 1 then

                    lcViga = sp_lausendikontrol(v_arv1.konto, v_dokprop.konto, lcDbKbmTp, lcKrTp, v_arv1.kood1,
                                                lcAllikas, lckood5, v_arv1.kood3,
                                                lcOmaTP, v_arv.Kpv);
                    if left(ltrim(rtrim(lcViga)), 4) = 'Viga' then
                        raise exception ':%',lcViga;
                    end if;
                end if;

                lnJournal1 = sp_salvesta_journal1(0, lnJournal, v_arv1.kbmta, ''::varchar, ''::text,
                                                  v_arv1.kood1,
                                                  coalesce(lcAllikas,'')::varchar,
                                                  coalesce(v_arv1.kood3,'')::varchar,
                                                  coalesce(v_arv1.kood4,'')::varchar,
                                                  coalesce(lckood5,'')::varchar,
                                                  v_arv1.konto,
                                                  coalesce(lcDbKbmTp,'')::varchar,
                                                  v_dokprop.konto,
                                                  coalesce(lcKrTp,'')::varchar,
                                                  v_arv1.valuuta,
                                                  v_arv1.kuurs, v_arv1.kbmta * v_arv1.kuurs,
                                                  v_arv1.tunnus, coalesce(v_arv1.proj,'')::varchar);

                -- kbm
                If v_arv1.kbm <> 0 then
                    l_row_id = 0;

                    -- will check if exists
                    select
                        id
                    into l_row_id
                    from
                        journal1
                    where
                          parentid = lnJournal
                      and kreedit = v_dokprop.konto
                      and deebet = v_dokprop.kbmkonto
                      and summa = v_arv1.kbm
                    limit 1;

                    lnJournal1 =
                            sp_salvesta_journal1(coalesce(l_row_id, 0), lnJournal, v_arv1.kbm, ''::varchar, ''::text,
                                                 coalesce(v_arv1.kood1,'')::varchar,
                                                 coalesce(lcAllikas,'')::varchar,
                                                 coalesce(v_arv1.kood3,'')::varchar,
                                                 coalesce(v_arv1.kood4,'')::varchar,
                                                 coalesce(lcKood5,'')::varchar,
                                                 v_dokprop.kbmkonto,
                                                 '014003',
                                                 v_dokprop.konto,
                                                 coalesce(lcKrTp,'')::varchar,
                                                 v_arv1.valuuta, v_arv1.kuurs, v_arv1.kbm * v_arv1.kuurs,
                                                 v_arv1.tunnus, v_arv1.proj);

                end if;
            End if;
        End loop;

    update arv set journalId = lnJournal where id = v_arv.id;
    If v_arv.journalid > 0 and ifnull(lnJournalNumber, 0) > 0 then
        update journalid set number = lnJournalNumber where journalid = lnJournal;
    end if;
--	commit;
    return lnJournal;
end ;
$BODY$;

ALTER FUNCTION public.gen_lausend_arv(integer)
    OWNER TO vlad;

GRANT EXECUTE ON FUNCTION public.gen_lausend_arv(integer) TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.gen_lausend_arv(integer) TO dbadmin;

GRANT EXECUTE ON FUNCTION public.gen_lausend_arv(integer) TO dbkasutaja;

GRANT EXECUTE ON FUNCTION public.gen_lausend_arv(integer) TO dbpeakasutaja;

GRANT EXECUTE ON FUNCTION public.gen_lausend_arv(integer) TO dbvaatleja;

GRANT EXECUTE ON FUNCTION public.gen_lausend_arv(integer) TO vlad;


CREATE OR REPLACE FUNCTION public.sp_update_arv_jaak(
    integer)
    RETURNS numeric
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$


declare
    tnId alias for $1;
    lnJaak numeric;
    lnSumma numeric;
    v_arv record;
    ldTasud date;
begin

    -- arv jaak

    select arv.summa * ifnull(dokvaluuta1.kuurs,1) as summa, arv.tasud, arv.jaak, ifnull(dokvaluuta1.kuurs,1) into v_arv
    from arv left outer join dokvaluuta1 on (arv.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 3)
    where arv.id = tnId;

-- tasu summa

    SELECT sum(Arvtasu.summa * ifnull(dokvaluuta1.kuurs,1)) into lnsumma
    FROM Arvtasu left outer join dokvaluuta1 on (arvtasu.id = dokvaluuta1.dokid and dokvaluuta1.dokliik = 21)
    WHERE Arvtasu.arvid = tnId;


    lnJaak := coalesce(v_arv.summa,0) - coalesce(lnSumma,0);

    if lnJaak <> coalesce(v_arv.jaak,0) then

        -- uuendame tasu info
        select kpv into ldTasud from arvtasu where arvid = tnId order by kpv desc limit 1;

        update arv set jaak = lnJaak, tasud = ldTasud where id = tnId;
    end if;



    return  lnJaak;

end;

$BODY$;

ALTER FUNCTION public.sp_update_arv_jaak(integer)
    OWNER TO vlad;

GRANT EXECUTE ON FUNCTION public.sp_update_arv_jaak(integer) TO PUBLIC;

GRANT EXECUTE ON FUNCTION public.sp_update_arv_jaak(integer) TO dbkasutaja;

GRANT EXECUTE ON FUNCTION public.sp_update_arv_jaak(integer) TO dbpeakasutaja;

GRANT EXECUTE ON FUNCTION public.sp_update_arv_jaak(integer) TO vlad;



