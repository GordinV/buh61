select * from palk_kaart where libid in (

select library.id from library inner join palk_lib on library.id = palk_lib.parentid where liik = 7
)
and summa = 1.4

update palk_kaart set summa = 2.0 where libid in (

select library.id from library inner join palk_lib on library.id = palk_lib.parentid where liik = 7
)
and summa = 2.8

update palk_kaart set summa = 1.0 where libid in (

select library.id from library inner join palk_lib on library.id = palk_lib.parentid where liik = 7
)
and summa = 1.4
