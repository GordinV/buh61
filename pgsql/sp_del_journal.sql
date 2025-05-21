-- Function: sp_del_journal(integer, integer)

-- DROP FUNCTION sp_del_journal(integer, integer);

CREATE OR REPLACE FUNCTION sp_del_journal(
    integer,
    integer)
    RETURNS smallint AS
$BODY$
declare
    tnId alias for $1;
    tnOpt alias for $2;
    lnCount int4;
    lntasuId int4;
begin
    If tnOpt = 0 then
        select count(id) into lnCount from (Select Id From korder1 Where journalid = tnid
                                            UNION
                                            SELECT parentId As Id From mk1 Where journalid = tnid
                                            UNION
                                            SELECT Id From palk_oper Where journalid = tnid
                                            UNION
                                            SELECT Id From pv_oper Where journalid = tnid
                                            UNION
                                            SELECT Id From arv Where journalid = tnid) a;
        if ifnull(lnCount,0) > 0 then
            return 0;
        end if;
    End if;
    Delete From journal Where Id = tnid;
    Delete From journal1 Where parentId = tnid;
    Delete From journalid Where journalid = tnid;
    select id into lntasuId from arvtasu where pankkassa = 3 and sorderid = tnid;
    if ifnull(lntasuId,0) > 0 then
        perform sp_del_tasud (lntasuId,1);
    end if;



    Return 1;



end;


$BODY$
    LANGUAGE plpgsql VOLATILE
                     COST 100;

GRANT EXECUTE ON FUNCTION sp_del_journal(integer, integer) TO dbkasutaja;
