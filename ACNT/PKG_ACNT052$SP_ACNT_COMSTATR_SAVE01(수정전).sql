CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_ACNT052$SP_ACNT_COMSTATR_SAVE01`(	
	in A_COMP_ID varchar(10),
	in A_YYYYMM date,
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
)
begin
	declare AA_YYYYMM varchar(6);	
	
	declare A_FROM_DATE varchar(8); 
	declare A_TO_DATE varchar(8); 
	declare A_END_YEAR varchar(4); 
	declare A_FY_TO varchar(8); 
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
   
    create temporary table if not exists TEMP_G_FIN_STAT_SAVE_TMP01
  (    `COMP_ID` varchar(50) DEFAULT NULL,
  `AC_KIND` varchar(50) DEFAULT NULL,
  `YYMM` varchar(50) DEFAULT NULL,
  `AC_CODE` varchar(50) DEFAULT NULL,
  `SLIP_AMT` decimal(16,4) DEFAULT NULL ); 
   
    create temporary table if not exists TEMP_G_FIN_STAT_SAVE_TMP02
  (   `COMP_ID` varchar(50) DEFAULT NULL,
  `AC_KIND` varchar(50) DEFAULT NULL,
  `YYMM` varchar(50) DEFAULT NULL,
  `AC_CODE` varchar(50) DEFAULT NULL,
  `SLIP_AMT` decimal(16,4) DEFAULT NULL,
  `AC_NAME` varchar(100) DEFAULT NULL,
  `AC_COM` varchar(50) DEFAULT NULL); 
	set AA_YYYYMM = date_format(A_YYYYMM, '%Y%m');
	
	set A_FROM_DATE = CONCAT(AA_YYYYMM,'01');
	set A_TO_DATE = CONCAT(AA_YYYYMM,'31');
	call FN_ACNT_AC_END_DATE_PRIOR(A_COMP_ID, date_format(A_FROM_DATE, '%Y%m%d'), @v_pFY, @v_pFROM_DATE, @v_pTO_DATE);
	select @v_pFY, @v_pTO_DATE 
	into A_END_YEAR, A_FY_TO;
	DELETE FROM TEMP_G_FIN_STAT_SAVE_TMP01;  
	DELETE FROM TEMP_G_FIN_STAT_SAVE_TMP02;
	set N_RETURN = 0;
    set V_RETURN = '저장 되었습니다.';
   
    INSERT INTO TEMP_G_FIN_STAT_SAVE_TMP01
	   SELECT A_COMP_ID AS COMP_ID,
	          '3' AS AC_KIND,
	          AA_YYYYMM AS YYMM,
	          A.AC_CODE,
	          sum(
	          	case
		          	when (A.AC_CHK = '1') then if(A.AC_COM = '+', (B.DR_AMT-B.CR_AMT), -(B.DR_AMT-B.CR_AMT))
		          	when (A.AC_CHK = '2') then case
			          							when (B.APPL_DATE >= A_FROM_DATE AND A.AC_COM = '+') then B.DR_AMT
			          							when (B.APPL_DATE >= A_FROM_DATE) then -B.DR_AMT
			          							else 0
			          						 end
		          	when (A.AC_CHK = '3') then case
			          							when (B.APPL_DATE >= A_FROM_DATE AND A.AC_COM = '+') then B.CR_AMT
			          							when (B.APPL_DATE >= A_FROM_DATE) then -B.CR_AMT
			          							else 0
			          						 end
		          	when (A.AC_CHK = '4') then case
			          							when (B.APPL_DATE < A_FROM_DATE AND A.AC_COM = '+') then B.DR_AMT - B.CR_AMT
			          							when (B.APPL_DATE < A_FROM_DATE) then -(B.DR_AMT - B.CR_AMT)
			          							else 0
			          						 end
		          	else 0
		        end
	          ) as SLIP_AMT
	    FROM TBL_END_DETA A INNER JOIN VEW_SLIP_ALL B
	                               ON A.COMP_ID = B.COMP_ID
	                              AND A.AC_CD4 = B.AC_CODE
	    WHERE   A.AC_KIND = '3'
	        AND B.APPL_DATE > A_FY_TO AND B.APPL_DATE <= A_TO_DATE
	    GROUP BY A.AC_CODE
	    ORDER BY A.AC_CODE;
	
	
	
	INSERT INTO TEMP_G_FIN_STAT_SAVE_TMP02
		SELECT  A.COMP_ID, 
				A.AC_KIND, 
				A.YYMM, 
				A.AC_CODE, 
				A.SLIP_AMT, 
		        B.AC_NAME, 
		        B.AC_COM
		FROM    TEMP_G_FIN_STAT_SAVE_TMP01 A,
		        TBL_END_MST B
		WHERE   A.COMP_ID = B.COMP_ID
		    AND A.AC_KIND = B.AC_KIND
		    AND A.AC_CODE = B.AC_CODE
		    AND B.GROUP_YN = 'N'
		ORDER BY A.AC_CODE;
	
	INSERT INTO TEMP_G_FIN_STAT_SAVE_TMP02
	    SELECT A.COMP_ID,
	           A.AC_KIND,
	           AA_YYYYMM,
	           A.AC_CODE,
	
	           sum(if(B.AC_COM = '+', B.SLIP_AMT, ifnull(-B.SLIP_AMT, 0))),
	           A.AC_NAME,
	           A.AC_COM
	    FROM TBL_END_MST A LEFT OUTER JOIN (
	                                        SELECT * 
	                                        FROM TEMP_G_FIN_STAT_SAVE_TMP02 
	                                        WHERE AC_COM IN ('+','-')
	                                       ) B
	                                    ON A.COMP_ID = B.COMP_ID
	                                   AND A.AC_KIND = B.AC_KIND
	                                   AND B.AC_CODE LIKE concat(REPLACE(A.AC_CODE,'0',''), '%')
    WHERE   A.GROUP_YN = 'Y'
        AND A.COMP_ID = A_COMP_ID
        AND A.AC_KIND = '3'
        AND A.AC_CODE NOT IN ('40000','60000','90000') 
    GROUP BY A.COMP_ID, A.AC_KIND, A.AC_CODE, A.AC_NAME, A.AC_COM;
   
   
	INSERT INTO TEMP_G_FIN_STAT_SAVE_TMP02
	    SELECT COMP_ID, 
	    	   AC_KIND, 
	    	   YYMM, 
	    	   '40000', 
	    	   SUM(SLIP_AMT), 
	    	   'IV.당기총제조비용', 
	    	   NULL
	    FROM TEMP_G_FIN_STAT_SAVE_TMP02
	    WHERE AC_CODE IN ('10000','20000','30000')
	    GROUP BY COMP_ID, AC_KIND, YYMM;
	
	
	INSERT INTO TEMP_G_FIN_STAT_SAVE_TMP02
	    SELECT COMP_ID, 
	    	   AC_KIND, 
	    	   YYMM, 
	    	   '60000', 
	    	   SUM(SLIP_AMT), 
	    	   'VI.합계', 
	    	   NULL
	    FROM TEMP_G_FIN_STAT_SAVE_TMP02
	    WHERE AC_CODE IN ('40000','50000')
	    GROUP BY COMP_ID, AC_KIND, YYMM;
	    
	
	INSERT INTO TEMP_G_FIN_STAT_SAVE_TMP02
	    SELECT COMP_ID, 
	    	   AC_KIND, 
	    	   YYMM, 
	    	   '90000', 
	    	   sum(if(AC_CODE = '60000', SLIP_AMT, -SLIP_AMT)),
	    	   'VIII.당기제품제조원가', 
	    	   NULL
	    FROM TEMP_G_FIN_STAT_SAVE_TMP02
	    WHERE AC_CODE IN ('60000','70000','80000')
	    GROUP BY COMP_ID, AC_KIND, YYMM;
	
	
	
	DELETE FROM TBL_END_END
	WHERE   COMP_ID = A_COMP_ID 
	    AND AC_KIND = '3' 
	    AND YYMM = AA_YYYYMM;
	
	INSERT INTO TBL_END_END
	    SELECT YYMM,  
	    	   AC_KIND, 
	    	   AC_CODE, 
	    	   SLIP_AMT,
	    	   '',
	    	   now(),
	    	   '',
	    	   null,
	    	   COMP_ID
	    FROM TEMP_G_FIN_STAT_SAVE_TMP02;   
	   
	
	   
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF; 
END