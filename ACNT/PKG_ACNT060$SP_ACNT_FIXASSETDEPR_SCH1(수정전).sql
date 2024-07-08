CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_ACNT060$SP_ACNT_FIXASSETDEPR_SCH1`(
	in A_COMP_ID varchar(10),
	in A_FR_DATE date,
	in A_TO_DATE date,
	out N_RETURN INT,
    out V_RETURN VARCHAR(4000)
)
begin
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	
   
  create temporary table if not exists temp_g_ac_equi_list
   (     `EQUI_KIND` varchar(20) DEFAULT NULL,
  `EQUI_KIND_NAME` varchar(20) DEFAULT NULL,
  `APPL_POST` varchar(20) DEFAULT NULL,
  `JUN_AMT` decimal(10,0) DEFAULT NULL,
  `DANG_AMT` decimal(10,0) DEFAULT NULL,
  `PRE_AMT` decimal(10,0) DEFAULT NULL,
  `MI_MINUS_AMT` decimal(10,0) DEFAULT NULL,
  `END_MINUS_AMT` decimal(10,0) DEFAULT NULL,
  `TOT_END_MINUS_AMT` decimal(10,0) DEFAULT NULL,
  `MAGAK_JAN_AMT` decimal(10,0) DEFAULT NULL,
  `END_CONF_AMT` decimal(10,0) DEFAULT NULL );
 
	delete from temp_g_ac_equi_list;
	INSERT INTO temp_g_ac_equi_list
        SELECT EQUI_KIND,
               EQUI_KIND_NAME,
               APPL_POST,
               SUM (JUN_AMT) AS JUN_AMT,
               SUM (DANG_AMT) AS DANG_AMT,
               SUM (PRE_AMT) AS PRE_AMT,
               SUM (MI_MINUS_AMT) AS MI_MINUS_AMT,
               SUM (END_MINUS_AMT) AS END_MINUS_AMT,
               SUM (PRE_AMT) + SUM (END_MINUS_AMT) AS TOT_END_MINUS_AMT,
               SUM (MAGAK_JAN_AMT) AS MAGAK_JAN_AMT,
               SUM (END_CONF_AMT) AS END_CONF_AMT
        FROM ( SELECT EQUI_KIND,
                      EQUI_KIND_NAME,
                      APPL_POST,
                      SUM (JUN_AMT) AS JUN_AMT,
                      SUM (DANG_AMT) AS DANG_AMT,
                      0 AS PRE_AMT,
                      0 AS MI_MINUS_AMT,
                      0 AS END_MINUS_AMT,
                      0 AS END_SUM_AMT,
                      0 AS END_CONF_AMT,
                      SUM (MAGAK_JAN_AMT) AS MAGAK_JAN_AMT
               FROM ( SELECT A.EQUI_KIND,
                    		 (select inter_Name
                    		  from tc_use_code 
                    		  where comp_id = A.COMP_ID
		                      	and code = 'AP16'
		                      	and inter_code = A.EQUI_KIND) AS EQUI_KIND_NAME,
                              A.APPL_POST,
                              SUM (A.AMT) AS JUN_AMT,
                              0 AS DANG_AMT,
                              0 AS MAGAK_JAN_AMT
                              FROM TBL_AC_EQUI A
                      WHERE A.COMP_ID = A_COMP_ID
	                      AND A.ACHI_DATE < DATE_FORMAT(A_FR_DATE, '%Y%m%d')
	                      AND A.EQUI_CODE NOT IN (SELECT EQUI_CODE
                                             	  FROM TBL_AC_EQUI_END
                                            	  WHERE COMP_ID = A_COMP_ID
                                                  	AND END_DATE < DATE_FORMAT(A_FR_DATE, '%Y%m%d')
                                                  )
                      GROUP BY A.EQUI_KIND,
                               A.APPL_POST
                      UNION ALL
                      SELECT A.EQUI_KIND,
                             (select inter_Name
                    		  from tc_use_code 
                    		  where comp_id = A.COMP_ID
	                    	  	and code = 'AP16'
	                    	  	and inter_code = A.EQUI_KIND) AS EQUI_KIND_NAME,
                             A.APPL_POST,
                             0 AS JUN_AMT,
                             SUM(A.AMT) AS DANG_AMT,
                             0 AS MAGAK_JAN_AMT
                       FROM TBL_AC_EQUI A
                      WHERE A.COMP_ID = A_COMP_ID
                      	AND A.ACHI_DATE between concat(date_format(A_FR_DATE, '%Y%m'), '01')
                                   			and concat(date_format(A_TO_DATE, '%Y%m'), '31')
                        AND A.EQUI_CODE NOT IN (SELECT EQUI_CODE
                                                FROM TBL_AC_EQUI_END
                                            	WHERE COMP_ID = A_COMP_ID
                                                	AND END_DATE < DATE_FORMAT(A_FR_DATE, '%Y%m%d')
                                                )
                       GROUP BY A.EQUI_KIND,
                                A.APPL_POST
                       UNION ALL
                       SELECT A.EQUI_KIND,
                                      (select inter_Name
                    				   from tc_use_code 
                    				   where comp_id = A.COMP_ID
                    				  	and code = 'AP16'
                    				  	and inter_code = A.EQUI_KIND) AS EQUI_KIND_NAME,
                                   A.APPL_POST,
                                   0 AS JUN_AMT,
                                   0 AS DANG_AMT,
                                   SUM (B.END_CONF_AMT) AS MAGAK_JAN_AMT
                       FROM TBL_AC_EQUI A, TBL_AC_EQUI_COM B
                       WHERE A.COMP_ID = A_COMP_ID
                       	AND A.EQUI_CODE IN (SELECT EQUI_CODE
                                            FROM TBL_AC_EQUI_END
                                            WHERE COMP_ID = A_COMP_ID
                                            	and END_DATE between concat(date_format(A_FR_DATE, '%Y%m'), '01')
                                   						   	     and concat(date_format(A_TO_DATE, '%Y%m'), '31')                            
                                           )
                        AND A.EQUI_CODE = B.EQUI_CODE
                        AND B.COMP_ID = A_COMP_ID
                        AND B.EQUI_YYMM = (SELECT MAX (EQUI_YYMM)
                                           FROM TBL_AC_EQUI_COM
                                           WHERE EQUI_CODE = A.EQUI_CODE
                                           	and EQUI_YYMM between concat(date_format(A_FR_DATE, '%Y%m'), '01')
                                   					   		  and concat(date_format(A_TO_DATE, '%Y%m'), '31')      
                                           )
                       GROUP BY A.EQUI_KIND,
                                A.APPL_POST
                    ) AA
               GROUP BY EQUI_KIND,
                        EQUI_KIND_NAME,
                        APPL_POST
                         
               UNION ALL
               SELECT EQUI_KIND,
                      EQUI_KIND_NAME,
                      APPL_POST,
                      0 AS JUN_AMT,
                      0 AS DANG_AMT,
                      SUM (PRE_AMT) AS PRE_AMT,
                      SUM (MI_MINUS_AMT) AS MI_MINUS_AMT,
                      SUM (END_MINUS_AMT) AS END_MINUS_AMT,
                      SUM (END_SUM_AMT) AS END_SUM_AMT,
                      SUM (END_CONF_AMT) AS END_CONF_AMT,
                      0 AS MAGAK_JAN_AMT         
               FROM ( SELECT A.EQUI_KIND,
                             (select inter_Name
                    		  from tc_use_code 
                    		  where comp_id = A.COMP_ID
                    		  	and code = 'AP16'
                    		  	and inter_code = A.EQUI_KIND) AS EQUI_KIND_NAME,
                              A.ACHI_POST AS APPL_POST,
                                   SUM (
                                   		 if(
                                   		 	A.EQUI_YYMM = DATE_FORMAT(A_FR_DATE, '%Y%m'),
                                   		 	A.PRE_AMT,
                                   		 	0
                                   		 )
                                       )
                                      AS PRE_AMT,
                                   SUM (
                                   		if(
                                   		 	A.EQUI_YYMM = DATE_FORMAT(A_FR_DATE, '%Y%m'),
                                   		 	A.END_AMT,
                                   		 	0
                                   		 )
                                      	)
                                      AS MI_MINUS_AMT,
                                   SUM (A.END_MINUS_AMT) AS END_MINUS_AMT,
                                   SUM (
                                   		 if(
                                   		 	A.EQUI_YYMM = DATE_FORMAT(A_TO_DATE, '%Y%m'),
                                   		 	A.END_SUM_AMT,
                                   		 	0
                                   		 )
                                      	)
                                      AS END_SUM_AMT,
                                   SUM (
                                      	if(
                                      		A.EQUI_YYMM = DATE_FORMAT(A_TO_DATE, '%Y%m'),
                                      		A.END_CONF_AMT,
                                      		0
                                      	)
                                      )
                                      AS END_CONF_AMT,
                                   SUM (
                                      	if(
                                      		A.EQUI_YYMM = DATE_FORMAT(A_TO_DATE, '%Y%m'),
                                      		A.END_MINUS_AMT,
                                      		0
                                      	)
                                      )
                                      AS PRE_REMAIN_AMT
                       FROM TBL_AC_EQUI_COM A, TBL_AC_EQUI B
                       WHERE A.COMP_ID = A_COMP_ID
                       	AND A.EQUI_YYMM BETWEEN DATE_FORMAT(A_FR_DATE, '%Y%m') AND DATE_FORMAT(A_TO_DATE, '%Y%m')
                       	AND B.COMP_ID = A_COMP_ID
                       	AND A.EQUI_CODE = B.EQUI_CODE
                       GROUP BY A.EQUI_KIND,
                                A.ACHI_POST
                    ) AA
               GROUP BY EQUI_KIND,
                        EQUI_KIND_NAME,
                        APPL_POST
             ) A
         GROUP BY EQUI_KIND, 
        	      EQUI_KIND_NAME, 
        	      APPL_POST;
	
	select *
	from temp_g_ac_equi_list
	order by equi_kind;
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
END