SELECT faah.appr_level 
              ,faah.appr_category_code
              ,LISTAGG(faah.response_user_id
                            ,',')
                        approver_user_id
                    ,LISTAGG(faah.response_email_address
                            ,',')
                        approver_email_address
                INTO l_approver_level
                    ,l_approver_category_code
                    ,l_approver_user_id
                    ,l_approver_email_address
                FROM *****ry_v faah 
               WHERE faah.action_id = rec_action.action_id
                 AND faah.appr_level = (SELECT MIN(appr_level)
                                          FROM *****y_t
                                         WHERE action_id = rec_action.action_id
                                           AND ACTION_TYPE_ID=l_pending_action_id
                                           AND appr_level > rec_action.approver_level)
             group by faah.appr_level, faah.appr_category_code;
			 

