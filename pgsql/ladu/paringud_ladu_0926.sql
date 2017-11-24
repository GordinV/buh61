select * from ladu_jaak where rekvid = 28 and nomid = 24087 
and dokitemid = 251820

select * from nomenklatuur where kood = 'suv1'

select * from arv where number = '2' and rekvid = 28 and year(kpv) = 2011

select sp_recalc_ladujaak(28, 24087,0)

select * from dokprop where id = 2148


select * from arv1 where parentid in (156805, 156804)

select * from arv1 where nomid = 24087


delete from ladu_jaak where nomid = 24087 and rekvid = 28