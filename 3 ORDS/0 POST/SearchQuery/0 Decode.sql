SELECT * 
FROM xxzlr_log_msgs_tbl
WHERE 1 = 1
  AND instance_id = decode(:instId,      'undefined', instance_id,
                                         'Search',    instance_id,
                                          NULL,       instance_id,
                                                      :instId)
  AND interface_id = decode(:infId,      'undefined', interface_id,
                                         'Search',    interface_id,
                                          NULL,       interface_id,
                                                      :infId)
  AND interface_name = decode(:infName,  'undefined', interface_name,
                                         'Search',    interface_name,
                                          NULL,       interface_name,
                                                      :infName)
  AND integration_type = decode(:intType,  'undefined', integration_type,
                                           'Search',    integration_type,
                                            NULL,       integration_type,
                                                        :intType)
  AND log_level = decode(:logLevel,  'undefined', log_level,
                                      'Search',   log_level,
                                       NULL,      log_level,
                                                  :logLevel)
  AND TO_CHAR(run_date,'YYYY-MM-DD')  BETWEEN decode(:lrun_date,   'undefined',  TO_CHAR(run_date,'YYYY-MM-DD'),
                                                                   'Search',     TO_CHAR(run_date,'YYYY-MM-DD'),
                                                                    NULL,        '1951-01-01',
                                                                                 TO_CHAR(:lrun_date, 'YYYY-MM-DD')) 
                                          AND decode(:lrun_dateto,   'undefined',  TO_CHAR(run_date,'YYYY-MM-DD'),
                                                                   'Search',     TO_CHAR(run_date,'YYYY-MM-DD'),
                                                                    NULL,        '4712-12-31',
                                                                                 TO_CHAR(:lrun_dateto, 'YYYY-MM-DD')) 
  
