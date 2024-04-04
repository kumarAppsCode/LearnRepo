select distinct 
PRD.ROLE_COMMON_NAME
from
PER_ROLES_DN PRD

/

SELECT
PU.USERNAME
, PU.USER_ID
,PRDT.ROLE_ID 
,PRDT.ROLE_NAME
,PEA.EMAIL_ADDRESS
,PPNF.DISPLAY_NAME
,PU.PERSON_ID
,PRDT.CREATED_BY 
,PRDT.CREATION_DATE 
,PRDT.LAST_UPDATED_BY 
,PRDT.LAST_UPDATE_DATE
,PRD.ROLE_COMMON_NAME ROLE_CODE
FROM
   PER_USER_ROLES PUR,
   PER_USERS PU,
   PER_ROLES_DN_TL PRDT,
   PER_ROLES_DN PRD ,
   PER_ALL_ASSIGNMENTS_F PAAF,
   PER_EMAIL_ADDRESSES   PEA,
   PER_PERSON_NAMES_F    PPNF
WHERE
PU.USER_ID = PUR.USER_ID
AND PRDT.ROLE_ID = PUR.ROLE_ID 
AND PRDT.ROLE_ID = PRD.ROLE_ID 
AND PRDT.LANGUAGE = USERENV ('LANG') 
AND PU.ACTIVE_FLAG = 'Y'
AND PU.PERSON_ID                 = PAAF.PERSON_ID(+)
AND PAAF.ASSIGNMENT_TYPE         IN('E','C')
AND PAAF.PRIMARY_FLAG            = 'Y'
AND PAAF.ASSIGNMENT_STATUS_TYPE  = 'ACTIVE'
AND PAAF.PERSON_ID               = PEA.PERSON_ID(+)
AND PEA.EMAIL_TYPE (+)		     = 'W1'
AND PPNF.PERSON_ID				 = PAAF.PERSON_ID(+)
AND PPNF.NAME_TYPE               = 'GLOBAL'
-- AND PRDT.ROLE_NAME               ='NWS Shift Time Upload Role'
AND TRUNC(SYSDATE) BETWEEN TRUNC(PAAF.EFFECTIVE_START_DATE) AND TRUNC(PAAF.EFFECTIVE_END_DATE)
AND TRUNC(SYSDATE) BETWEEN TRUNC(PPNF.EFFECTIVE_START_DATE) AND TRUNC(PPNF.EFFECTIVE_END_DATE)
AND (PRD.ROLE_COMMON_NAME	 IN (:P_ROLE_CODE) OR 'ALL' IN (:P_ROLE_CODE || 'ALL'))
ORDER BY PU.USERNAME