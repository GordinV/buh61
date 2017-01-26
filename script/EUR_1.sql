select round(db/15.6466,2), round(kr/15.6466,2),* from saldoandmik where rekvid = 63 and konto = '100100' and kuu = 3 and aasta = 2013


update saldoandmik set db = round(db/15.6466,2), kr = round(kr/15.6466)


select * from aastakassakulud where valuuta = 'EUR' order by id desc limit 10

update aastakassakulud set summa = round(summa/15.6466), valuuta = 'EUR' 


update eeltaitmine set summa = round(summa/15.6466)

SELECT * FROM eeltaitmine ORDER BY ID desc limit 10