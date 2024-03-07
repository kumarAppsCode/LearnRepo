SELECT * FROM table where EXPENSE_HEADER_ID=:expHdrId
AND APPL_REF_ID = decode(:appLnId,'undefined', APPL_REF_ID,
                                                 'Search',    APPL_REF_ID,
                                                 0,           APPL_REF_ID,
                                                  NULL,       APPL_REF_ID,
                                                              :appLnId)
