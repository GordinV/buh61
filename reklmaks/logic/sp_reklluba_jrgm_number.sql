-- View: "public.cursaldo"

-- DROP VIEW public.cursaldo;

CREATE OR REPLACE VIEW public.cursaldoAsutus AS 
 SELECT date(2000, 1, 1) AS kpv, subkonto.rekvid, library.kood AS konto, 
        CASE
            WHEN subkonto.algsaldo >= 0::numeric THEN subkonto.algsaldo
            ELSE 0::numeric(12,4)
        END AS deebet, 
        CASE
            WHEN subkonto.algsaldo < 0::numeric THEN -1::numeric * subkonto.algsaldo
            ELSE 0::numeric(12,4)
        END AS kreedit, 2 AS opt, subkonto.asutusid
   FROM library
   JOIN subkonto ON library.id = subkonto.kontoid
UNION ALL 
 SELECT date(saldo.aasta, saldo.kuu, 1) AS kpv, saldo.rekvid, saldo.konto, saldo.dbkaibed AS deebet, saldo.krkaibed AS kreedit, 3 AS opt, saldo.asutusid
   FROM saldo where asutusId > 0
UNION ALL 
 SELECT curjournal.kpv, curjournal.rekvid, curjournal.deebet AS konto, curjournal.summa AS deebet, 0::numeric(12,4) AS kreedit, 4 AS opt, curjournal.asutusid
   FROM curjournal
UNION ALL 
 SELECT curjournal.kpv, curjournal.rekvid, curjournal.kreedit AS konto, 0::numeric(12,4) AS deebet, curjournal.summa AS kreedit, 4 AS opt, curjournal.asutusid
   FROM curjournal;

GRANT ALL ON TABLE public.cursaldoasutus TO vlad WITH GRANT OPTION;
GRANT SELECT ON TABLE public.cursaldoasutus TO GROUP dbpeakasutaja;
GRANT SELECT ON TABLE public.cursaldoasutus TO GROUP dbkasutaja;
GRANT SELECT ON TABLE public.cursaldoasutus TO GROUP dbadmin;
GRANT SELECT ON TABLE public.cursaldoasutus TO GROUP dbvaatleja;
