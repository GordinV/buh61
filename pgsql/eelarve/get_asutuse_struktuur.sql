drop type if exists get_asutuste_struktuur_type cascade;
CREATE TYPE get_asutuste_struktuur_type AS (rekv_id integer, parentid integer);

create function get_asutuse_struktuur(integer)
  returns SETOF get_asutuste_struktuur_type

language sql
as $$
select p.id, p.parentid
	from rekv r,
	(select id, parentid from rekv) p	
	where (r.id = p.parentid)
	and (r.id = $1 or r.parentid = $1)
union all
select	r.id, r.parentid 
from rekv r
where r.id = $1
$$;

select * from get_asutuse_struktuur(28)