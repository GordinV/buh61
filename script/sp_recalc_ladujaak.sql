-- Function: sp_recalc_ladujaak(integer, integer, integer)

-- DROP FUNCTION sp_recalc_ladujaak(integer, integer, integer);

CREATE OR REPLACE FUNCTION sp_recalc_ladujaak(integer, integer, integer)
  RETURNS smallint AS
$BODY$

declare 

	tnrekvId	ALIAS FOR $1;
	tnNomid	ALIAS FOR $2;
	tnArveId	ALIAS FOR $3;	
	cur_ladusisearved record;
	cur_v_arved record;
	v_ladu_config record;
	cur_ladujaak record;
	recArv	record;
	recArv1	record;
	lnCount int;
	ldKpv date;

begin



raise notice ' alg  ';



select * into v_ladu_config from ladu_config where rekvid = tnrekvId;



if tnNomId > 0 then

delete from ladu_jaak 

	where rekvid = tnRekvId  

	and ladu_jaak.nomid >= tnNomId 

	and ladu_jaak.nomid <= tnNomId ;



	insert into ladu_jaak (rekvid, dokItemId, nomId, userid,kpv, hind,kogus, maha, jaak  )

		SELECT arv.rekvid, arv1.Id, arv1.nomId, arv.userId, arv.kpv, arv1.hind, arv1.kogus, 0, arv1.kogus

		from arv inner join arv1 on arv.id = arv1.parentid 

		where arv.rekvid = tnRekvid

		and arv.liik = 1 and arv.operId > 0

 		and arv1.nomid >= tnNomId 

		and arv1.nomid <= tnNomId ;

		

	update arv1 set maha = 0 where parentid in (select id from arv where arv.rekvid = tnRekvid

		and arv.liik = 1 and arv.operId > 0 )

 		and arv1.nomid >= tnNomId 

		and arv1.nomid <= tnNomId ;



else

	if tnArveId = 0 then

		delete from ladu_jaak 

		where rekvid = tnRekvId  ;



		insert into ladu_jaak (rekvid, dokItemId, nomId, userid,kpv, hind,kogus, maha, jaak  )

		SELECT arv.rekvid, arv1.Id, arv1.nomId, arv.userId, arv.kpv, arv1.hind, arv1.kogus, 0, arv1.kogus

		from arv inner join arv1 on arv.id = arv1.parentid 

		where arv.rekvid = tnRekvid

		and arv.liik = 1 and arv.operId > 0;

		

		update arv1 set maha = 0 where parentid in (select id from arv where arv.rekvid = tnRekvid

			and arv.liik = 1 and arv.operId > 0 );

	end if;



end if;	



if tnArveId > 0 then

	delete from ladu_jaak 

	where rekvid = tnRekvId and dokItemId in (select id from arv1 where parentid = tnArveId) ;



	insert into ladu_jaak (rekvid, dokItemId, nomId, userid,kpv, hind,kogus, maha, jaak  )

		SELECT arv.rekvid, arv1.Id, arv1.nomId, arv.userId, arv.kpv, arv1.hind, arv1.kogus, 0, arv1.kogus

		from arv inner join arv1 on arv.id = arv1.parentid 

		where arv.rekvid = tnRekvid

		and arv.id = tnArveId

		and arv.liik = 1 and arv.operId > 0;

		

	update arv1 set maha = 0 where parentid in (select id from arv where arv.rekvid = tnRekvid

		and arv.liik = 1 and arv.operId > 0 and arv.id = tnArveId );



end if;







--vara valjaminek



 



for  cur_v_arved in  

	select   arv.id, arv1.id as arv1id, arv1.nomid, arv1.kogus, arv.operId, arv.liik, arv.kpv, arv1.hind

	from arv inner join arv1 on arv.id = arv1.parentid 

	where rekvid = tnrekvId  and arv.liik = 0 and arv.operId > 0 

	and arv1.nomid >= CASE WHEN tnNomId = 0 THEN 0 else tnNomId end

	and arv1.nomid <= CASE WHEN tnNomId = 0 THEN 999999999 else tnNomId  end

	and arv.id >= CASE WHEN tnArveId = 0 THEN 0 else tnArveId  end

	and arv.id <= CASE WHEN tnArveId = 0 THEN 999999999 else tnArveId  end

	order by kpv



loop



	if ifnull(v_ladu_config.liik,1) = 1 then

		for cur_ladujaak  in 

			select   id, jaak, maha, kpv, dokItemId   

				from ladu_jaak

				where rekvid = tnrekvId

				and jaak > 0

				and nomid = cur_V_arved.nomId

				and kpv <= cur_V_arved.kpv

				order by kpv



		loop



			if cur_ladujaak.Jaak >= cur_V_arved.kogus and cur_V_arved.Kogus > 0 then

				update arv1 set maha = 1 where id = cur_ladujaak.dokItemId;

				update ladu_jaak set jaak = cur_ladujaak.jaak - cur_v_arved.kogus, 

					maha = cur_ladujaak.maha + cur_V_arved.kogus where id = cur_ladujaak.id;

				cur_V_arved.kogus := 0;

			end if;	

			if cur_ladujaak.Jaak < cur_V_arved.kogus and cur_V_arved.kogus >= 0 then	



				update arv1 set maha = 1 where id = cur_ladujaak.dokItemId;



				update ladu_jaak set jaak = 0, maha = maha + (cur_V_arved.kogus - cur_ladujaak.jaak) 

					where id = cur_ladujaak.id;



				cur_V_arved.kogus := cur_V_arved.kogus - cur_ladujaak.jaak;				



			end if;



			delete from ladu_jaak where jaak = 0;

		end loop;



	else

		for cur_ladujaak  in 

			select   id, jaak, maha, kpv, dokItemId   

				from ladu_jaak

				where rekvid = tnrekvId

				and jaak > 0

				and nomid = cur_v_arved.nomId

				and kpv <= cur_v_arved.kpv

				order by kpv desc

		loop



			if cur_ladujaak.Jaak >= cur_v_arved.kogus and cur_v_arved.Kogus > 0 then



				update arv1 set maha = 1 where id = cur_ladujaak.dokItemId;



				update ladu_jaak set jaak = cur_ladujaak.jaak - cur_v_arved.kogus, 

					maha = cur_ladujaak.maha + cur_v_arved.kogus where id = cur_ladujaak.id;

				cur_v_arved.kogus := 0;



			end if;	



			if cur_ladujaak.Jaak < cur_v_arved.kogus and cur_v_arved.kogus >= 0 then	

				update arv1 set maha = 1 where id = cur_ladujaak.dokItemId;



				update ladu_jaak set jaak = 0, 

					maha = maha + (cur_v_arved.kogus - cur_ladujaak.jaak) 

					where id = cur_ladujaak.id;



				cur_v_arved.kogus := cur_v_arved.kogus - cur_ladujaak.jaak;				

			end if;



			delete from ladu_jaak where jaak = 0;

		end loop;

	end if;

end loop;



return 1;



end;

$BODY$
  LANGUAGE 'plpgsql' VOLATILE;
ALTER FUNCTION sp_recalc_ladujaak(integer, integer, integer) OWNER TO vlad;
GRANT EXECUTE ON FUNCTION sp_recalc_ladujaak(integer, integer, integer) TO vlad;
GRANT EXECUTE ON FUNCTION sp_recalc_ladujaak(integer, integer, integer) TO public;
GRANT EXECUTE ON FUNCTION sp_recalc_ladujaak(integer, integer, integer) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION sp_recalc_ladujaak(integer, integer, integer) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION sp_recalc_ladujaak(integer, integer, integer) TO taabel;
