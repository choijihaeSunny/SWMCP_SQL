CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_ACNT053$SP_ACNT_PROFLOSSSTATR_SAVE01`(	
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
   
    create temporary table if not exists TMP_G_FIN_STAT_SAVE_TMP01
  (   `COMP_ID` varchar(50) DEFAULT NULL,
  `AC_KIND` varchar(50) DEFAULT NULL,
  `YYMM` varchar(50) DEFAULT NULL,
  `AC_CODE` varchar(50) DEFAULT NULL,
  `SLIP_AMT` decimal(16,4) DEFAULT null ); 
   
    create temporary table if not exists TMP_G_FIN_STAT_SAVE_TMP02
  (  `COMP_ID` varchar(50) DEFAULT NULL,
  `AC_KIND` varchar(50) DEFAULT NULL,
  `YYMM` varchar(50) DEFAULT NULL,
  `AC_CODE` varchar(50) DEFAULT NULL,
  `SLIP_AMT` decimal(16,4) DEFAULT NULL,
  `AC_NAME` varchar(100) DEFAULT NULL,
  `AC_COM` varchar(50) DEFAULT null ); 
	set AA_YYYYMM = date_format(A_YYYYMM, '%Y%m');
	set A_FROM_DATE = concat(AA_YYYYMM, '01');
	set A_TO_DATE = concat(AA_YYYYMM, '31');
	call FN_ACNT_AC_END_DATE_PRIOR(A_COMP_ID, date_format(A_FROM_DATE, '%Y%m%d'), @v_pFY, @v_pFROM_DATE, @v_pTO_DATE);
	select @v_pFY, @v_pTO_DATE 
	into A_END_YEAR, A_FY_TO;
	DELETE FROM TMP_G_FIN_STAT_SAVE_TMP01;  
	DELETE FROM TMP_G_FIN_STAT_SAVE_TMP02;
	set N_RETURN = 0;
    set V_RETURN = '저장 되었습니다.';
   
	INSERT INTO TMP_G_FIN_STAT_SAVE_TMP01
	   SELECT A_COMP_ID AS COMP_ID,
	          '2' AS AC_KIND,
	          AA_YYYYMM AS YYMM,
	          A.AC_CODE,
	          sum(
	          	case
		          	when (AC_CHK = '1') then if(A.AC_COM = '+', (DR_AMT-CR_AMT), -(DR_AMT-CR_AMT))
		          	when (AC_CHK = '2') then case
			          							when (B.APPL_DATE >= A_FROM_DATE AND A.AC_COM = '+') then DR_AMT
			          							when (B.APPL_DATE >= A_FROM_DATE) then -DR_AMT
			          							else 0
			          						 end
		          	when (AC_CHK = '3') then case
			          							when (B.APPL_DATE >= A_FROM_DATE AND A.AC_COM = '+') then CR_AMT
			          							when (B.APPL_DATE >= A_FROM_DATE) then -CR_AMT
			          							else 0
			          						 end
		          	when (AC_CHK = '4') then case 
			          							when (B.APPL_DATE < A_FROM_DATE AND A.AC_COM = '+') then (DR_AMT - CR_AMT)
			          							when (B.APPL_DATE < A_FROM_DATE) then -(DR_AMT - CR_AMT)
			          							else 0
			          						 end
		          	else 0
		        end
	          ) as SLIP_AMT
	    FROM TBL_END_DETA A INNER JOIN VEW_SLIP_ALL B
	                               ON A.COMP_ID = B.COMP_ID
	                              AND A.AC_CD4 = B.AC_CODE
	    WHERE   A.AC_KIND = '2'
	        AND B.APPL_DATE > A_FY_TO AND B.APPL_DATE <= A_TO_DATE
	    GROUP BY A.AC_CODE
	    ORDER BY A.AC_CODE;
	
	INSERT INTO TMP_G_FIN_STAT_SAVE_TMP02
		SELECT  A.COMP_ID, 
				A.AC_KIND, 
				A.YYMM, 
				A.AC_CODE, 
				A.SLIP_AMT, 
		        B.AC_NAME, 
		        B.AC_COM
		FROM    TMP_G_FIN_STAT_SAVE_TMP01 A,
		        TBL_END_MST B
		WHERE    A.COMP_ID = B.COMP_ID
		    AND A.AC_KIND = B.AC_KIND
		    AND A.AC_CODE = B.AC_CODE
		    AND B.GROUP_YN = 'N'
		ORDER BY A.AC_CODE;
	
	
	INSERT INTO TMP_G_FIN_STAT_SAVE_TMP02
	    SELECT A.COMP_ID,
	           A.AC_KIND,
	           AA_YYYYMM,
	           A.AC_CODE,
	           sum(if(B.AC_COM = '+', B.SLIP_AMT, ifnull(-B.SLIP_AMT, 0))),
	           A.AC_NAME,
	           A.AC_COM
	    FROM TBL_END_MST A LEFT OUTER JOIN (
	                                        SELECT * 
	                                        FROM TMP_G_FIN_STAT_SAVE_TMP02 
	                                        WHERE AC_COM IN ('+','-')
	                                       ) B
	                                    ON A.COMP_ID = B.COMP_ID
	                                   AND A.AC_KIND = B.AC_KIND
	                                   AND B.AC_CODE LIKE concat(REPLACE(A.AC_CODE,'0',''), '%')
	    WHERE   A.GROUP_YN = 'Y'
	        AND A.COMP_ID = A_COMP_ID
	        AND A.AC_KIND = '2'
	        AND A.AC_CODE NOT IN ('22120','30000','51000','71000','73000','74000') 
	    GROUP BY A.COMP_ID, A.AC_KIND, A.AC_CODE, A.AC_NAME, A.AC_COM;
	   
	   
	
	INSERT INTO TMP_G_FIN_STAT_SAVE_TMP02
	    SELECT COMP_ID, 
	    	   AC_KIND, 
	    	   YYMM, 
	    	   '30000', 
	    	   sum(if(AC_CODE = '10000', SLIP_AMT, -SLIP_AMT)),
	    	   'III.매출총이익', 
	    	   NULL
	    FROM TMP_G_FIN_STAT_SAVE_TMP02
	    WHERE AC_CODE IN ('10000','20000')
	    GROUP BY COMP_ID, AC_KIND, YYMM;
	
	
	INSERT INTO TMP_G_FIN_STAT_SAVE_TMP02
	    SELECT COMP_ID, 
	    	   AC_KIND, 
	    	   YYMM, 
	    	   '51000', 
	    	   sum(if(AC_CODE = '30000', SLIP_AMT, -SLIP_AMT)),
	    	   'IV.판매비와일반관리비', 
	    	   NULL
	    FROM TMP_G_FIN_STAT_SAVE_TMP02
	    WHERE AC_CODE IN ('30000','40000')
	    GROUP BY COMP_ID, AC_KIND, YYMM;
	    
	
	INSERT INTO TMP_G_FIN_STAT_SAVE_TMP02
	    SELECT COMP_ID, 
	    	   AC_KIND, 
	    	   YYMM, 
	    	   '71000', 
	    	   sum(if(AC_CODE IN ('51000','52000'), SLIP_AMT, -SLIP_AMT)),
	    	   'VIII.경상이익', 
	    	   NULL
	    FROM TMP_G_FIN_STAT_SAVE_TMP02
	    WHERE AC_CODE IN ('51000','52000','61000')
	    GROUP BY COMP_ID, AC_KIND, YYMM;
	    
	  
	INSERT INTO TMP_G_FIN_STAT_SAVE_TMP02
	    SELECT COMP_ID, 
	    	   AC_KIND, 
	    	   YYMM, 
	    	   '74000', 
	    	   sum(if(AC_CODE IN ('71000','72000'), SLIP_AMT, -SLIP_AMT)),
	    	   'XI.법인세차감전순이익', 
	    	   NULL
	    FROM TMP_G_FIN_STAT_SAVE_TMP02
	    WHERE AC_CODE IN ('71000','72000','73000')
	    GROUP BY COMP_ID, AC_KIND, YYMM;
	
	 
	INSERT INTO TMP_G_FIN_STAT_SAVE_TMP02
	    SELECT COMP_ID, 
	    	   AC_KIND, 
	    	   YYMM, 
	    	   '73000', 
			   sum(if(AC_CODE = '71000', SLIP_AMT, -SLIP_AMT)),
	    	   'XI.당기순이익', 
	    	   NULL
	    FROM TMP_G_FIN_STAT_SAVE_TMP02
	    WHERE AC_CODE IN ('71000','72100')
	    GROUP BY COMP_ID, AC_KIND, YYMM;
	   
	DELETE FROM TBL_END_END
	WHERE   COMP_ID = A_COMP_ID 
	    AND AC_KIND = '2' 
	    AND YYMM = AA_YYYYMM;
	
	/*
*   * 2024년 7월 4일 cjh
 * Column count doesn't match value count at row 1 오류 발생하여
 * MST_OID 값이 자동으로 들어가는 식으로 처리되지 않아 발생한 것으로 추정되어 수정. 
	INSERT INTO TBL_END_END
	    SELECT YYMM, AC_KIND, AC_CODE, SLIP_AMT,'',now(),'',null,COMP_ID
	    FROM TMP_G_FIN_STAT_SAVE_TMP02;
	*/

	INSERT INTO TBL_END_END
	    SELECT YYMM, AC_KIND, 1, AC_CODE, SLIP_AMT,'',now(),'',null,COMP_ID
	    FROM TMP_G_FIN_STAT_SAVE_TMP02;
	   
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF; 
END