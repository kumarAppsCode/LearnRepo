select m.*, 
       case 
         when col = 'MRK1' then coalesce(val, 'DEF1')
         when col = 'MRK2' then coalesce(val, 'DEF2')
         else 'ETC'
       end vals_with_defs
from   marker 
unpivot include nulls ( 
  val for col in (mrk1, mrk2, mrk3, mrk4, mrk5, mrk6) 
) m
where  case 
         when col = 'MRK1' then coalesce(val, 'DEF1')
         when col = 'MRK2' then coalesce(val, 'DEF2')
         else 'ETC'
       end is not null;
--*****************************************************


set SERVEROUTPUT ON;
DECLARE
CURSOR getdata IS
SELECT 
rownum as DISTANCE_ID,
replace(upper(WILAIYAT), ' ', '_') as FROM_NAME, 
replace(upper(m.COL), ' ', '_') as TO_NAME,
m.VAL as WILAYAT_DISTANCE
--m.* 
FROM tablename
unpivot include nulls ( 
  val for col in (
    column name
 ) 
) m;

BEGIN FOR c0 IN getdata 
LOOP 
-- ===
    commit;
end loop;
END;
