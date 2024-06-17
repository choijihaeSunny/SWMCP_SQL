CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_QUAL029$UPDATE_MSUR_EQUICHECK`(		
	IN A_COMP_ID varchar(10),
	IN A_IDX int(11),
	IN A_EQUI_CODE varchar(20),
	IN A_SET_DATE TIMESTAMP,
	IN A_CHECK_ITEM varchar(10),
	IN A_CYCLE decimal(3, 0),
	IN A_FINAL_DATE TIMESTAMP,
	IN A_CHECK_DEPT varchar(10),
	IN A_CHECK_RESULT varchar(10),
	IN A_CHECK_EMP_NO varchar(10),
	IN A_VALID_TEMP decimal(10, 0),
	IN A_FILE_NAME varchar(100),
	IN A_REAL_FILE_NAME varchar(100),
	IN A_CHECK_HIS varchar(200),
	IN A_RESULT_HIS varchar(200),
	IN A_ETC_RMK varchar(200),
	IN A_UPD_EMP_NO varchar(10),
	IN A_UPD_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_NEXT_DATE timestamp;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
   UPDATE TB_MSUR_EQUICHECK_RESULT
		SET 
	    	SET_DATE = DATE_FORMAT(SYSDATE(), '%Y%m%d')
			,CHECK_ITEM = A_CHECK_ITEM
	    	,CYCLE = A_CYCLE
	    	,FINAL_DATE = DATE_FORMAT(A_FINAL_DATE, '%Y%m%d')
	    	,CHECK_DEPT = A_CHECK_DEPT
	    	,CHECK_RESULT = A_CHECK_RESULT
	    	,CHECK_EMP_NO = A_CHECK_EMP_NO
	    	,VALID_TEMP = A_VALID_TEMP
	    	,FILE_NAME = A_FILE_NAME
	    	,REAL_FILE_NAME = A_REAL_FILE_NAME
	    	,CHECK_HIS = A_CHECK_HIS
	    	,RESULT_HIS = A_RESULT_HIS
	    	,ETC_RMK = A_ETC_RMK
	    	,UPD_EMP_NO = A_UPD_EMP_NO
	    	,UPD_ID = A_UPD_ID
	    	,UPD_DATE = SYSDATE()
	 WHERE COMP_ID = A_COMP_ID
	   AND IDX = A_IDX
	   AND EQUI_CODE = A_EQUI_CODE
	 ;
	
	
	set V_NEXT_DATE = DATE_ADD(A_FINAL_DATE, interval A_CYCLE MONTH); 
	
	UPDATE TB_MSUR_EQUICHECK
		SET 
	    	FINAL_DATE = DATE_FORMAT(A_FINAL_DATE, '%Y%m%d')
	    	,NEXT_DATE = DATE_FORMAT(V_NEXT_DATE, '%Y%m%d')
	    	,UPD_EMP_NO = A_UPD_EMP_NO
	    	,UPD_ID = A_UPD_ID
	    	,UPD_DATE = SYSDATE()
	 WHERE COMP_ID = A_COMP_ID
	   AND EQUI_CODE = A_EQUI_CODE
	 ;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end