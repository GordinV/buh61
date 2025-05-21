DROP FUNCTION if exists get_tasumata_arv_number(integer, numeric, varchar(20));

CREATE OR REPLACE FUNCTION get_tasumata_arv_number(IN l_asutus_id integer, IN l_summa numeric,
                                                   IN l_korr_konto varchar(20) default '1220',
                                                   OUT arve_number varchar(20), OUT arve_id integer)
    RETURNS record AS
$BODY$
declare
    l_number text;
begin
    select
        arv.number, arv.id
    into arve_number, arve_id
    from
        arv
            left outer join dokprop d on d.id = arv.doklausid
    where
          d.konto = l_korr_konto
      and arv.asutusid = l_asutus_id
--    and arv.summa = l_summa
      and arv.jaak = l_summa
    order by kpv
    limit 1;

    return;
end;

$BODY$
    LANGUAGE 'plpgsql' VOLATILE
                       COST 100;

GRANT EXECUTE ON FUNCTION get_tasumata_arv_number(integer, numeric, varchar(20)) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION get_tasumata_arv_number(integer, numeric, varchar(20)) TO dbpeakasutaja;


/*
select * from asutus where nimetus like '%TON M%'

    select jaak, summa,
        number,*
    from arv left outer join dokprop d on d.id = arv.doklausid
    where 1=1
--        and  d.konto = '1220'
      and arv.asutusid = 6542
    and arv.summa = 173
--      and arv.jaak = 143


select  * from get_tasumata_arv_number(6542, 173.2, '1220')
*/