
  sys.dbms_session.sleep(5);

SET SERVEROUTPUT ON ;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Start ' || to_char(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
    APEX_UTIL.PAUSE(5);
    DBMS_OUTPUT.PUT_LINE('End   ' || to_char(SYSDATE, 'YYYY-MM-DD HH24:MI:SS'));
END;
