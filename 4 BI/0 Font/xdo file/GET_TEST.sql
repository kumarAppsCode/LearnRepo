create or replace FUNCTION GET_TEST (
    pNAME1  IN varchar2,
    pNAME2  IN varchar2
) RETURN CLOB AS

--Variable DEFAULT
l_query_ref SYS_REFCURSOR; 
l_handle    dbms_xmlgen.ctxhandle; 
l_data_xml  CLOB; 

--start
BEGIN
--Variable DEFAULT
OPEN l_query_ref FOR 
-- real query
    select 
    pNAME1|| '-'||pNAME2
    from dual;
--Final Default
      l_handle := dbms_xmlgen.Newcontext (l_query_ref); 
      dbms_xmlgen.Setrowsettag (l_handle, 'PC'); 
      dbms_xmlgen.Setrowtag (l_handle, 'G_TA_EMP_HEADER'); 
      dbms_xmlgen.Setnullhandling (l_handle, dbms_xmlgen.empty_tag); 
      l_data_xml := dbms_xmlgen.Getxml (l_handle); 

    RETURN l_data_xml;
END GET_TEST;