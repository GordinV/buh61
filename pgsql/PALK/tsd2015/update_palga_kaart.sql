/*
select pl.*,pk.* 
from palk_lib pl
inner join library l on l.id = pl.parentid 
inner join palk_kaart pk on pk.libid = l.id
where  pl.liik = 7
limit 10

*/

CREATE OR REPLACE FUNCTION update_palga_kaart()
  RETURNS void AS
$BODY$
declare 
	v_rec record;
begin
	update palk_config set
		minpalk = 355,
		tulubaas = 154,
		tm = 20,
		tka = 0.8,
		tki = 1.6 ;
-- tulumaks
	for v_rec in
		select pk.id 
			from palk_lib pl
			inner join library l on l.id = pl.parentid 
			inner join palk_kaart pk on pk.libid = l.id
			where pl.liik = 4
			and summa = 21
	loop
		update palk_kaart set summa = 20 where id = v_rec.id;
	end loop;
--tka
	for v_rec in
		select pk.id 
			from palk_lib pl
			inner join library l on l.id = pl.parentid 
			inner join palk_kaart pk on pk.libid = l.id
			where  pl.liik = 7
			and summa = 1
	loop
		update palk_kaart set summa = 0.8 where id = v_rec.id;
	end loop;
--tki
	for v_rec in
		select pk.id 
			from palk_lib pl
			inner join library l on l.id = pl.parentid 
			inner join palk_kaart pk on pk.libid = l.id
			where  pl.liik = 7
			and summa = 2
	loop
		update palk_kaart set summa = 1.6 where id = v_rec.id;
	end loop;

end;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;


select update_palga_kaart();

