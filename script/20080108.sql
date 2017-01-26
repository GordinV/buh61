update palk_config set tulubaas = 2250 where tulubaas = 2000;



update palk_kaart set summa = 21 where libid in 
(
select parentid from palk_lib where liik = 4
)
and summa = 22 and percent_ = 1 and status = 1;


