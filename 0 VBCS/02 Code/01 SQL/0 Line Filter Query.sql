SELECT * FROM XXQIA_FIN_IE_TRAVEL_ASSIGN_V where APPL_HEADER_ID=:travelHdrId
AND ASSIGNMENT_LINE_ID = decode(:assignmnetLnsId,'undefined', ASSIGNMENT_LINE_ID,
                                                 'Search',    ASSIGNMENT_LINE_ID,
                                                 0,           ASSIGNMENT_LINE_ID,
                                                  NULL,       ASSIGNMENT_LINE_ID,
                                                              :assignmnetLnsId)
