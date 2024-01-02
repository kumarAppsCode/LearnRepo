create or replace PROCEDURE RH_LOGGING_SEARCH(
                                        p_integration_name      in varchar2,
                                        p_from_run_date         in varchar2,
                                        p_to_run_date           in varchar2,
                                        p_user_name             in varchar2,
                                        p_log_type              in varchar2,
                                        p_channel_type          in varchar2,       
                                        p_output          		out sys_refcursor,
                                        p_sql             		out varchar2
                                        )
IS
   l_sql          VARCHAR2(4000);
   l_where        VARCHAR2(4000) := 'WHERE 1=1';
BEGIN

--   IF p_integration_name IS NOT NULL THEN
--      l_where     := l_where || ' AND UPPER(integration_name) LIKE ''%' || UPPER(p_integration_name) || '%''';
--   END IF;
--
   IF p_from_run_date IS NOT NULL THEN
      l_where     := l_where || ' AND trunc(RUN_DATE)>=' ||'to_date('''||p_from_run_date || ''',''YYYY-MM-DD'')' ;  
   END IF;

   IF p_to_run_date IS NOT NULL THEN
         l_where     := l_where || ' AND trunc(RUN_DATE)<=' ||'to_date('''||p_to_run_date || ''',''YYYY-MM-DD'')' ;  
        
   END IF;

--   IF p_from_run_date IS NOT NULL THEN
--      l_where     := l_where || ' AND UPPER(CONTRACT_NUM) LIKE ''%' || UPPER(p_contract_num) || '%''';
--   END IF;

--   IF p_user_name IS NOT NULL THEN
--      l_where     := l_where || ' AND UPPER(user_name) LIKE ''%' || UPPER(p_user_name) || '%''';
--   END IF;
--
--   IF p_log_type IS NOT NULL THEN
--      l_where     := l_where || ' AND UPPER(log_type) LIKE ''%' || UPPER(p_log_type) || '%''';
--   END IF;
--
--   IF p_channel_type IS NOT NULL THEN
--      l_where     := l_where || ' AND UPPER(channel_type) LIKE ''%' || UPPER(p_channel_type) || '%''';
--   END IF;



   l_sql       := 'SELECT * FROM Rh_common_logging ' || l_where;
   p_sql       := l_sql;
----

   OPEN p_output FOR l_sql;
END RH_LOGGING_SEARCH;
