Select 
current_timestamp at time zone 'Asia/Muscat', 
substr(current_timestamp at time zone 'Asia/Muscat' , 0,17),
TO_TIMESTAMP(substr(current_timestamp at time zone 'Asia/Muscat' , 0,17))
from dual
