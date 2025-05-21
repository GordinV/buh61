-- Function: sp_del_arved(integer, integer)

-- DROP FUNCTION sp_del_arved(integer, integer);

CREATE OR REPLACE FUNCTION sp_del_arved(
    integer,
    integer)
    RETURNS smallint AS
$BODY$
declare
    tnId alias for $1;
    lnCount int;
    v_arv record;
begin
    select id, Muud
    into v_arv
        from arv
            where id = tnId;

    if v_arv.muud is not null and len(v_arv.muud) >= 15 then
        -- generated
        delete from arvtasu where arvid = tnId;
    end if;

--    delete from arv1 where parentid = tnId;
    DELETE FROM arv WHERE id = tnid;
    -- arveldused
    select count(*) into lnCount from pg_stat_all_tables where UPPER(relname) = 'COUNTER';
    if ifnull(lnCount,0) > 0 then
        update counter set muud = null where ifnull(muud,'null') <> 'null' and muud = ltrim(rtrim(str(tnid)));

    end if;





    Return 1;





end;





$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;

GRANT EXECUTE ON FUNCTION sp_del_arved(integer, integer) TO dbkasutaja;
