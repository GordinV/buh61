DROP FUNCTION IF EXISTS eelarve_andmik(DATE, INTEGER, INTEGER );


drop type if exists eelarve_andmik_type ;
CREATE TYPE eelarve_andmik_type AS (idx varchar(20), is_e integer, rekvid integer, tegev varchar(20), allikas varchar(20), artikkel varchar(20), nimetus varchar(254), eelarve numeric(14,2), tegelik numeric(14,2), kassa numeric(14,2), saldoandmik numeric(14,2));


CREATE OR REPLACE FUNCTION eelarve_andmik(in l_kpv DATE,
                                                 in l_rekvid INTEGER,
                                                 in l_kond   INTEGER)
                                                 returns setof eelarve_andmik_type
as $$
declare 
	is_kond boolean = not empty(l_kond);
	l_kuu integer = month(l_kpv);
	l_aasta integer = year(l_kpv);
	la_kontod text[] = array['100','1000','1001','15','1501','1502','1511','1512','1531','1532','2580','2581','2585','2586','3000','3030',
				'3034','3041','3044','3045','3047','32','3500','3502','352','35200','35201','381','3818','382','38250','38251',
				'38252','38254','3880','3882','3888','40','413','4500','4502','452','50','55','60','650','655','9100','9101'];
begin

-- will fill temp table with row data
perform eelarve_andmik_query(l_kpv, l_rekvid , l_kond);

-- data analise 
return query	
	select idx::varchar(20) , 
		case when is_e = 0 and array[ltrim(rtrim(artikkel))::text] <@ la_kontod then 1 else is_e end:: integer as is_e ,
		rekvid::integer,
		tegev::varchar(20),
		allikas::varchar(20),
		artikkel::varchar(20),
		nimetus::varchar(254),
		eelarve::numeric,
		tegelik::numeric,
		kassa::numeric,
		saldoandmik::numeric 
		from (
	select '2.1'::varchar(20) as idx,
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'32'::varchar(20) as artikkel,
		'Tulud kaupade ja teenuste müügist'::varchar(254) as nimetus,
		coalesce(sum(eelarve),0)::numeric(12,2) as eelarve,
		coalesce(coalesce(sum(tegelik),0),0)::numeric(12,2) as tegelik,
		coalesce(coalesce(sum(kassa),0),0)::numeric(12,2) as kassa,
		get_saldo('KD','32', null, null)::numeric(12,2) as saldoandmik
	from tmp_andmik q
	where artikkel like '32%'
	and tyyp = 1
	union all		
	select '2.1'::varchar(20), 
		0 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'352'::varchar(20) as artikkel,
		'Mittesihtotstarbelised toetused' as nimetus,
		coalesce(sum(eelarve),0) as eelarve,
		coalesce(sum(tegelik),0) as tegelik,
		coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','352', null, null) - 
		get_saldo('KD','352000', null, null) - 
		get_saldo('KD','352010', null, null)  as saldoandmik
-- KD352-KD352000-KD352010
	from tmp_andmik q
	where artikkel like '352%'
	and tyyp = 1
	union all		
	select '2.1'::varchar(20), 
		0 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'35200'::varchar(20) as artikkel,
		'Tasandusfond' as nimetus,
		coalesce(sum(eelarve),0) as eelarve,
		coalesce(sum(tegelik),0) as tegelik,
		coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','352000', null, null)  as saldoandmik
-- KD352000
	from tmp_andmik q
	where artikkel like '35200%'
	and tyyp = 1
	union all		
	select '2.1'::varchar(20),
		0 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'35201'::varchar(20) as artikkel,
		'Toetusfond ' as nimetus,
		coalesce(sum(eelarve),0) as eelarve,
		coalesce(sum(tegelik),0) as tegelik,
		coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','3520010', null, null)  as saldoandmik
-- KD352010
	from tmp_andmik q
	where artikkel like '35201%'
	and tyyp = 1

	union all		
	select '2.1'::varchar(20), 
		0 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'382'::varchar(20) as artikkel,
		'Muud tulud varadelt' as nimetus,
		coalesce(sum(eelarve),0) as eelarve,
		coalesce(sum(tegelik),0) as tegelik,
		coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','382', null, null) + 
		get_saldo('KD','382520', null, null) + 
		get_saldo('KD','382560', null, null) as saldoandmik
-- KD382+KD382520+KD382550+KD382560

	from tmp_andmik q
	where artikkel like '382%'
	and tyyp = 1
	union all		
	select '2.1'::varchar(20), 
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'40'::varchar(20) as artikkel,
		'Subsiidiumid ettevõtlusega tegelevatele isikutele' as nimetus,
		coalesce(sum(eelarve),0) as eelarve,
		coalesce(sum(tegelik),0) as tegelik,
		coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','40', null, null)   as saldoandmik
-- KD40
	from tmp_andmik q
	where artikkel like '40%'
	and tyyp = 1
	union all		
	select '2.1'::varchar(20),
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'413'::varchar(20) as artikkel,
		'Sotsiaalabitoetused ja muud toetused füüsilistele isikutele' as nimetus,
		-1 * coalesce(sum(eelarve),0) as eelarve,
		-1 * coalesce(sum(tegelik),0) as tegelik,
		-1 * coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','413', null, null)   as saldoandmik
-- KD413
	from tmp_andmik q
	where artikkel like '413%'
	and tyyp = 1
	union all		
	select '2.1'::varchar(20),
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'4500'::varchar(20) as artikkel,
		'Sihtotstarbelised toetused tegevuskuludeks' as nimetus,
		-1 * coalesce(sum(eelarve),0) as eelarve,
		-1 * coalesce(sum(tegelik),0) as tegelik,
		-1 * coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','4500', null, null)   as saldoandmik
-- KD4500
	from tmp_andmik q
	where artikkel like '4500%'
	and tyyp = 1
	union all
	select '2.1'::varchar(20),
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'452'::varchar(20) as artikkel,
		'Mittesihtotstarbelised toetused' as nimetus,
		-1 * coalesce(sum(eelarve),0) as eelarve,
		-1 * coalesce(sum(tegelik),0) as tegelik,
		-1 * coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','452', null, null)   as saldoandmik
-- KD452
	from tmp_andmik q
	where artikkel like '452%'
	and tyyp = 1

	
	union all		
	select '2.1'::varchar(20),
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'50'::varchar(20) as artikkel,
		'Tööjõukulud' as nimetus,
		-1 * coalesce(sum(eelarve),0) as eelarve,
		-1 * coalesce(sum(tegelik),0) as tegelik,
		-1 * coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','50', null, null)   as saldoandmik
-- KD382+KD382520+KD382550+KD382560

	from tmp_andmik q
	where artikkel like '50%'
	and tyyp = 1
	union all		
	select '2.1',
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'55'::varchar(20) as artikkel,
		'Majandamiskulud' as nimetus,
		-1 * coalesce(sum(eelarve),0) as eelarve,
		-1 * coalesce(sum(tegelik),0) as tegelik,
		-1 * coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','55', null, null)   as saldoandmik
-- KD382+KD382520+KD382550+KD382560

	from tmp_andmik q
	where artikkel like '55%'
	and tyyp = 1
	union all		
	select '2.1'::varchar(20),
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'60'::varchar(20) as artikkel,
		'Muud kulud' as nimetus,
		-1 * coalesce(sum(eelarve),0) as eelarve,
		-1 * coalesce(sum(tegelik),0) as tegelik,
		-1 * coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','60', null, null) - get_saldo('KD','601002', null, null)  as saldoandmik
-- KD382+KD382520+KD382550+KD382560

	from tmp_andmik q
	where artikkel like '60%'
	and tyyp = 1
	union all
	select '2.4'::varchar(20),
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'381'::varchar(20) as artikkel,
		'Põhivara müük (+)' as nimetus,
		coalesce(sum(eelarve),0) as eelarve,
		coalesce(sum(tegelik),0) as tegelik,
		coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','381', null, null) -
		get_saldo('KD','3818', null, null) -  
		get_saldo('KD','154', '02', null) - 
		get_saldo('KD','155', '02', null) - 
		get_saldo('KD','156', '02', null) - 
		get_saldo('KD','157', '02', null) - 
		get_saldo('KD','109', '02', null) as saldoandmik
-- KD381-KD3818-KD154RV02-KD155RV02-KD156RV02-KD157RV02-KD109RV02

	from tmp_andmik q
	where artikkel like '381%'
	and tyyp = 1
	union all
	select '2.4.1'::varchar(20),
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'15'::varchar(20) as artikkel,
		'Põhivara soetus (-)' as nimetus,
		0 as eelarve,
		0 as tegelik,
		0 as kassa,
		coalesce(get_saldo('KD','154', '01', null) +
		get_saldo('KD','155', '01', null) +  
		get_saldo('KD','156', '01', null) +
		get_saldo('KD','157', '01', null) + 
		get_saldo('KD','601002', null, null),0) as saldoandmik
-- KD154RV01+KD155RV01+KD156RV01+KD157RV01+601002KD
	union all
	select '2.4.1'::varchar(20),
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'3502'::varchar(20) as artikkel,
		'Põhivara soetuseks saadav sihtfinantseerimine(+)' as nimetus,
		coalesce(sum(eelarve),0) as eelarve,
		coalesce(sum(tegelik),0) as tegelik,
		coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','3502', '01', null) +
		get_saldo('KD','3502', '05', null)  as saldoandmik
-- KD3502RV01+KD3502RV05

	from tmp_andmik q
	where artikkel like '3502%'
	and tyyp = 1
	union all
	select '2.4.1'::varchar(20),
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'4502'::varchar(20) as artikkel,
		'Põhivara soetuseks antav sihtfinantseerimine(-)' as nimetus,
		-1 * coalesce(sum(eelarve),0) as eelarve,
		-1 * coalesce(sum(tegelik),0) as tegelik,
		-1 * coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','4502', null, null) +
		get_saldo('KD','1', '24', null)  as saldoandmik
-- KD4502+KD1RV24

	from tmp_andmik q
	where artikkel like '4502%'
	and tyyp = 1
	union all
	select '2.4.2'::varchar(20),
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'1502'::varchar(20) as artikkel,
		'Osaluste müük (+)' as nimetus,
		coalesce(sum(eelarve),0) as eelarve,
		coalesce(sum(tegelik),0) as tegelik,
		coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','150', '02', null)  as saldoandmik
-- KD150RV02

	from tmp_andmik q
	where artikkel like '1502%'
	and tyyp = 1
	union all
	select '2.4.3',
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'1501'::varchar(20) as artikkel,
		'Osaluste soetus (-)' as nimetus,
		coalesce(sum(eelarve),0) as eelarve,
		coalesce(sum(tegelik),0) as tegelik,
		coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','150', '01', null)  as saldoandmik
-- KD150RV01
	from tmp_andmik q
	where artikkel like '1501%'
	and tyyp = 1
	union all
	select '2.4.3',
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'1512'::varchar(20) as artikkel,
		'Muude aktsiate ja osade müük (+)' as nimetus,
		coalesce(sum(eelarve),0) as eelarve,
		coalesce(sum(tegelik),0) as tegelik,
		coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','151910', '02', null) + get_saldo('KD','101900', '02', null) as saldoandmik
-- KD151910RV02+KD101900RV02
	from tmp_andmik q
	where artikkel like '1512%'
	and tyyp = 1
	union all
	select '2.4.4',
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'1511'::varchar(20) as artikkel,
		'Muude aktsiate ja osade soetus (-)' as nimetus,
		coalesce(sum(eelarve),0) as eelarve,
		coalesce(sum(tegelik),0) as tegelik,
		coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','151910', '01', null) + get_saldo('KD','101900', '01', null) as saldoandmik
-- KD151910RV01+KD101900RV01
	from tmp_andmik q
	where artikkel like '1511%'
	and tyyp = 1
	union all
	select '2.4.4',
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'1532'::varchar(20) as artikkel,
		'Tagasilaekuvad laenud (+)' as nimetus,
		coalesce(sum(eelarve),0) as eelarve,
		coalesce(sum(tegelik),0) as tegelik,
		coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','1032', '02', null) + get_saldo('KD','1532', '02', null) as saldoandmik
-- KD1032RV02+KD1532RV02
	from tmp_andmik q
	where left(artikkel,4) in ('1032','1532')
	and tyyp = 1
	union all
	select '2.4.5',
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'1531'::varchar(20) as artikkel,
		'Antavad laenud (-)' as nimetus,
		coalesce(sum(eelarve),0) as eelarve,
		coalesce(sum(tegelik),0) as tegelik,
		coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','1032', '01', null) + get_saldo('KD','1532', '01', null) as saldoandmik
-- KD1032RV01+KD1532RV01
	from tmp_andmik q
	where artikkel like '1531%'
	and tyyp = 1
	union all
	select '2.4.5',		
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'655'::varchar(20) as artikkel,
		'Finantstulud (+)' as nimetus,
		coalesce(sum(eelarve),0) as eelarve,
		coalesce(sum(tegelik),0) as tegelik,
		coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','652', null, null) + 
		get_saldo('KD','655', null, null) + 
		get_saldo('KD','658', null, null) - 
		get_saldo('KD','658950', null, null) as saldoandmik
-- KD652+KD655+KD658-KD658950

	from tmp_andmik q
	where artikkel like '655%'
	and tyyp = 1
	union all
	select '2.4.5',
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'650'::varchar(20) as artikkel,
		'Finantstkulud (-)' as nimetus,
		-1 * coalesce(sum(eelarve),0) as eelarve,
		-1 * coalesce(sum(tegelik),0) as tegelik,
		-1 * coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','650', null, null) + get_saldo('KD','658950', null, null) as saldoandmik
-- KD650+KD658950
	from tmp_andmik q
	where artikkel like '650%'
	and tyyp = 1
	union all
	select '2.4.6',
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'2585'::varchar(20) as artikkel,
		'Kohustuste võtmine (+)' as nimetus,
		coalesce(sum(eelarve),0) as eelarve,
		coalesce(sum(tegelik),0) as tegelik,
		coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','208', '05', null) + get_saldo('KD','258', '05', null) as saldoandmik
-- KD208RV05+KD258RV05
	from tmp_andmik q
	where (left(artikkel,3)  =  '255' or left(artikkel,4)  =  '2585')
	and tyyp = 1
	union all
	select '2.4.6',
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'2586'::varchar(20) as artikkel,
		'Kohustuste tasumine (-)' as nimetus,
		-1 * coalesce(sum(eelarve),0) as eelarve,
		-1 * coalesce(sum(tegelik),0) as tegelik,
		-1 * coalesce(sum(kassa),0) as kassa,
		get_saldo('KD','208', '06', null) + get_saldo('KD','258', '06', null) as saldoandmik
-- KD208RV06+KD258RV06

	from tmp_andmik q
	where (left(artikkel,3)  =  '206' or left(artikkel,4)  =  '2586')
	and tyyp = 1
	union all
	select '2.4.7',
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'100'::varchar(20) as artikkel,
		'LIKVIIDSETE VARADE MUUTUS (+ suurenemine, - vähenemine)' as nimetus,
		-1 *  coalesce(sum(eelarve),0) as eelarve,
		-1 *  coalesce(sum(tegelik),0) as tegelik,
		-1 *  coalesce(sum(kassa),0) as kassa,
		get_saldo('DK','100', null, null) - get_saldo('MDK','100', null, null) + 
		get_saldo('DK','101', null, null) - get_saldo('MDK','101', null, null) - 
		get_saldo('DK','1019', null, null) - get_saldo('MDK','1019', null, null) + 
		get_saldo('DK','151', null, null) - get_saldo('MDK','151', null, null) + 
		get_saldo('DK','1519', null, null) - get_saldo('MDK','1519', null, null) 

		as saldoandmik
-- DK100-MDK100+DK101-MDK101-DK1019+MDK1019+DK151-MDK151-DK1519+MDK1519
-- @TODO oodan selesused

	from tmp_andmik q
	where artikkel like '100%'
	and tyyp = 1
	union all
	select '8.1',
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'2580'::varchar(20) as artikkel,
		'Võlakohustused' as nimetus,
		0 as eelarve,
		0 as tegelik,
		0 as kassa,
		get_saldo('MDK','208', null, null) + get_saldo('MKD','258', null, null) as saldoandmik
-- MKD208+MKD258
	union all
	select '8.1',
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'9100'::varchar(20) as artikkel,
		'sh sildfinantseering' as nimetus,
		0 as eelarve,
		0 as tegelik,
		0 as kassa,
		get_saldo('MKD','910090', null, null)  as saldoandmik
-- MKD910090
	union all
	select '8.1',
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'1000'::varchar(20) as artikkel,
		'Likviidsed varad' as nimetus,
		0 as eelarve,
		0 as tegelik,
		0 as kassa,
		get_saldo('MDK','100', null, null) + 
		get_saldo('MDK','101', null, null) -  
		get_saldo('MDK','1019', null, null) + 
		get_saldo('MDK','151', null, null) -  
		get_saldo('MDK','1519', null, null)   
		  as saldoandmik
-- MDK100+MDK101-MDK1019+MDK151-MDK1519
	union all
	select '8.2',
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'2581'::varchar(20) as artikkel,
		'Võlakohustused' as nimetus,
		0 as eelarve,
		0 as tegelik,
		0 as kassa,
		get_saldo('KD','208', null, null) + get_saldo('KD','258', null, null) as saldoandmik
-- KD208+KD258
	union all
	select '8.2',
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'9101'::varchar(20) as artikkel,
		'sh sildfinantseering' as nimetus,
		0 as eelarve,
		0 as tegelik,
		0 as kassa,
		get_saldo('KD','910090', null, null) as saldoandmik
-- KD910090
	union all
	select '8.2',
		1 as is_e,
		$2 as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		'1001'::varchar(20) as artikkel,
		'Likviidsed varad' as nimetus,
		0 as eelarve,
		0 as tegelik,
		0 as kassa,
		get_saldo('DK','100', null, null) + 
		get_saldo('DK','101', null, null) - 
		get_saldo('DK','1019', null, null) +
		get_saldo('DK','151', null, null) - 
		get_saldo('DK','1519', null, null) as saldoandmik
-- DK100+DK101-DK1019+DK151-DK1519

-- pohi osa
	union all	
	select idx,
		case when artikkel in ('3880','3818','3888') then 0 else 1 end as is_e,
		l_rekvid as rekvid,
		''::varchar(20) as tegev,
		''::varchar(20) as allikas,
		artikkel,
		nimetus,
		coalesce(sum(eelarve),0) as eelarve,
		coalesce(sum(tegelik),0) as tegelik,
		coalesce(sum(kassa),0) as kassa,
		get_saldo('KD',artikkel, null, null) as saldoandmik
	from tmp_andmik q
	where left(artikkel,2) not in ('32','15','40','50','55','60') 
	and left(artikkel,4) not in ('3502','3823','2585','2586', '1001','4500', '4502')
	and left(artikkel,3) not in ('655', '650','352','381','413','452')
	and tyyp = 1
	group by q.idx, artikkel, nimetus
	union all
	select 
		'3.1'::varchar(20) as idx,
		0 as is_e,
		l_rekvid as rekvid,
		qry.tegev,		
		''::varchar(20) as allikas,
		''::varchar(20) as artikkel,
		l.nimetus,
		coalesce(sum(eelarve),0) as eelarve,
		coalesce(sum(tegelik),0) as tegelik,
		coalesce(sum(kassa),0) as kassa,
		get_saldo('DK','4',null,qry.tegev) + 
		get_saldo('DK','5',null,qry.tegev) + 
		get_saldo('DK','6',null,qry.tegev) + 
		get_saldo('DK','15',null,qry.tegev)  as saldoandmik
	from tmp_andmik qry
	left outer join library l on l.kood = qry.tegev and l.library = 'TEGEV'
	where tyyp = 1
	and qry.tegev not in ('03600','07210','07220','07230','07240','07310','07320','07340')
	group by tegev, l.nimetus
	) qry;
	end;
$$
  LANGUAGE 'plpgsql' VOLATILE
  COST 100;


GRANT EXECUTE ON FUNCTION eelarve_andmik(DATE, INTEGER, INTEGER ) TO dbkasutaja;
GRANT EXECUTE ON FUNCTION eelarve_andmik(DATE, INTEGER, INTEGER ) TO dbpeakasutaja;
GRANT EXECUTE ON FUNCTION eelarve_andmik(DATE, INTEGER, INTEGER ) TO eelaktsepterja;
GRANT EXECUTE ON FUNCTION eelarve_andmik(DATE, INTEGER, INTEGER ) TO dbvaatleja;


SELECT *
FROM eelarve_andmik(DATE(2018,12,31), 63, 1)
where (not empty(tegev) or not empty(artikkel))

/*

CREATE TYPE eelarve_andmik_type AS (idx varchar(20), is_e integer, rekvid integer, tegev varchar(20), allikas varchar(20), artikkel varchar(20), nimetus varchar(254), eelarve numeric(14,2), tegelik numeric(14,2), kassa numeric(14,2), saldoandmik numeric(14,2));


--and tegev = '03600'
order by tegev, artikkel
*/
--select * from tmp_andmik where artikkel like '2585%'
--select get_saldo('DK','100', null, null), get_saldo('MDK','100', null, null)
