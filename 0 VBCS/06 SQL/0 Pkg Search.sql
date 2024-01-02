create or replace PROCEDURE xx_getrecord(p_bu_id        IN     NUMBER
                                        ,p_contract_num IN     VARCHAR2
                                        ,p_contract_status IN  VARCHAR2
                                        ,p_vendor_id    IN     NUMBER
                                        ,p_approval_status_id IN NUMBER
                                        ,p_from_contract_date IN DATE
                                        ,p_to_contract_date IN DATE
                                        ,p_output          OUT SYS_REFCURSOR
                                        ,p_sql             OUT VARCHAR2)
IS
   l_sql          VARCHAR2(4000);
   l_where        VARCHAR2(4000) := 'WHERE 1=1';
BEGIN
   IF p_bu_id IS NOT NULL THEN
      l_where     := l_where || ' AND BU_ID=' || p_bu_id;
   END IF;

   IF p_contract_num IS NOT NULL THEN
      l_where     := l_where || ' AND UPPER(CONTRACT_NUM) LIKE ''%' || UPPER(p_contract_num) || '%''';
   END IF;

   IF p_contract_status IS NOT NULL THEN
      l_where     := l_where || ' AND UPPER(CONTRACT_STATUS) LIKE ''%' || UPPER(p_contract_status) || '%''';
   END IF;

   IF p_vendor_id IS NOT NULL THEN
      l_where     := l_where || ' AND VENDOR_ID=' || p_vendor_id;
   END IF;

   IF p_approval_status_id IS NOT NULL THEN
      l_where     := l_where || ' AND APPROVAL_STATUS_ID=' || p_approval_status_id;
   END IF;

   IF p_from_contract_date IS NOT NULL THEN
      l_where     := l_where || ' AND CONTRACT_DATE>=''' || p_from_contract_date || '''';
   END IF;

   IF p_to_contract_date IS NOT NULL THEN
      l_where     := l_where || ' AND CONTRACT_DATE<=''' || p_to_contract_date || '''';
   END IF;

   l_sql       := 'SELECT * FROM SC_CONTRACT_HEADERS_V ' || l_where;
   p_sql       := l_sql;

   OPEN p_output FOR l_sql;
END xx_getrecord;
