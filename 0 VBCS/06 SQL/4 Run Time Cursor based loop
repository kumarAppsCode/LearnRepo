Cursor based loop
set SERVEROUTPUT ON;
DECLARE
    CURSOR getamount IS
    SELECT
        pa.value,
        round(pl.base_price, 2),
        round((pa.value * pl.base_price), 2) AS totalsaleamt,
        pa.unit_id,
        pl.PLL_ID
    FROM
        xxpm_pl_lines        pl,
        xxpm_property_area   pa
    WHERE
        pl.unit_id = pa.unit_id
        AND pl.pl_amount IS NULL;
--        AND pl.unit_id = 10055;

BEGIN FOR c_totalamt IN getamount 
LOOP 
    update xxpm_pl_lines
    set PL_AMOUNT=c_totalamt.totalSaleAmt
where
	PL_AMOUNT is null 
	and UNIT_ID=c_totalamt.unit_id
    and PLL_ID=c_totalamt.PLL_ID;
    commit;
    dbms_output.put_line(c_totalamt.totalsaleamt || ': Unit-->' || c_totalamt.unit_id);
    end loop;
END;



update xxpm_pl_lines
set BASE_PRICE=round(BASE_PRICE,2),
MIN_PRICE=round(MIN_PRICE,2)
