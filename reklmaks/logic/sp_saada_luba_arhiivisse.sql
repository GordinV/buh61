-- View: "public.cursaldo"

-- DROP VIEW public.cursaldo;

CREATE OR REPLACE VIEW public.cursaldo AS 
 SELECT date(2000, 1, 1) AS kpv, kontoinf.rekvid, library.kood AS konto, 
        CASE
            WHEN kontoinf.algsaldo >= 0::numeric THEN kontoinf.algsaldo
            ELSE 0::numeric(12,4)
        END AS deebet, 
        CASE
            WHEN kontoinf.algsaldo < 0::numeric THEN -1::numeric * kontoinf.algsaldo
            ELSE 0::numeric(12,4)
        END AS kreedit, 1 AS opt, 0 AS asutusid
   FROM library
   JOIN kontoinf ON library.id = kontoinf.parentid
UNION ALL 
 SELECT date(saldo.aasta, saldo.kuu, 1) AS kpv, saldo.rekvid, saldo.konto, saldo.dbkaibed AS deebet, saldo.krkaibed AS kreedit, 3 AS opt, saldo.asutusid
   FROM saldo
UNION ALL 
 SELECT curjournal.kpv, curjournal.rekvid, curjournal.deebet AS konto, curjournal.summa AS deebet, 0::numeric(12,4) AS kreedit, 4 AS opt, curjournal.asutusid
   FROM curjournal
UNION ALL 
 SELECT curjournal.kpv, curjournal.rekvid, curjournal.kreedit AS konto, 0::numeric(12,4) AS deebet, curjournal.summa AS kreedit, 4 AS opt, curjournal.asutusid
   FROM curjournal;

GRANT ALL ON TABLE public.cursaldo TO vlad WITH GRANT OPTION;
GRANT SELECT ON TABLE public.cursaldo TO GROUP dbpeakasutaja;
GRANT SELECT ON TABLE public.cursaldo TO GROUP dbkasutaja;
GRANT SELECT ON TABLE public.cursaldo TO GROUP dbadmin;
GRANT SELECT ON TABLE public.cursaldo TO GROUP dbvaatleja;
