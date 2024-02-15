--- Сумма остаточного долга (ИТОГО ОДНОЙ СУММОЙ)

SELECT
	  ipeopleid
	, fio
	, adr
	, vidz
	, array_to_string(array_accum(distinct cast(number as text)), ', ') as z
	, date_part('year',dtstart) as god
	, SUM(dolg1) as dolg

FROM

 (
  SELECT
	  p.ipeopleid
	, p.dtbirthday as dtr
	, d.vcnumber as number
	, (case when d.istpdemid=186 then 'kaprem' when d.istpdemid = 11 then 'subs' else 'lgoty' end) as vidz
	,  de.idebtid
	, de.dtstart
	, de.vcname
	, de.idemandid
	, de.decsum
	, de.vccomment
	, de.vcnumber
	, de.sumuder
	, de.sumpogas
	, dolg1
	, p.vcsurname||' '||p.vcname||' '||p.vcfathername as fio
	, f_getaddressidtoaddress2(d.iaddressid) as adr

  FROM demand as d
	JOIN people as p ON d.ipeopleid = p.ipeopleid
	JOIN
	(      -- признак учета из заявления
	 SELECT d3.idemandid
	 FROM demval d3
	) AS d4 ON d4.idemandid = d.idemandid
	JOIN 
        (      -- непогашенные долги 
         SELECT
		  de.idebtid
		, de.dtstart
		, de.vcname
		, de.idemandid
		, de.decsum
		, de.vccomment
		, de.vcnumber
		, ud.sumuder
		, po.sumpogas
		, de.decsum-(case when (ud.sumuder IS NULL) then 0.00 else ud.sumuder end)-(case when (po.sumpogas IS NULL) then 0.00 else po.sumpogas end) as dolg1
        FROM debt de
		LEFT JOIN 
		(
		 SELECT idebtid, SUM(decsum) as sumuder
		 FROM lkdebtfix
		 GROUP BY idebtid
		) AS ud ON ud.idebtid = de.idebtid
		LEFT JOIN 
		(
		 SELECT idebtid, SUM(cast(decsum  as numeric(10,2))) as sumpogas
		 FROM payingoff
		 GROUP BY idebtid
		) AS po ON po.idebtid = de.idebtid
   
        WHERE 
         (decsum <> 0)
       ) AS de ON de.idemandid = d.idemandid
  WHERE ((d.istpdemid IN (186,159,160,190,191,193,194,195,196,197,198,199,200,201,202,203,204,205,206,207,210,211,212,220,11) AND (d.dtstart >= '01.11.2011')) )  -- 220 - проезд рег.льгот
       --or d.istpdemid IN (24,25,26))
       AND  p.ipeopleid = '610038001000071169'   -- ВЫБРАТЬ ЛЬГОТНИКА!!!!!!
  ORDER BY fio
	  , adr
	  , vidz
 ) 
AS dlg
WHERE dolg1<>0
GROUP BY  ipeopleid
	, fio
	, adr
	, vidz
	, god
ORDER by  fio
	, god
	, z
