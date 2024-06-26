CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_QUAL026$UPDATE_MSUR_EQUI`(	
	IN A_COMP_ID varchar(10),
	IN A_EQUI_CODE varchar(20),
	IN A_CLASS1 bigint(20),
	IN A_CLASS2 bigint(20),
	IN A_TEMP_SEQ varchar(3),
	IN A_EQUI_NAME varchar(50),
	IN A_EQUI_SPEC varchar(200),
	IN A_EQUI_NUM varchar(20),
	IN A_MAKE_COMP varchar(50),
	IN A_MODEL_NAME varchar(50),
	IN A_BUY_AMT decimal(16, 4),
	IN A_BUY_COMP varchar(50),
	IN A_BUY_DATE timestamp,
	IN A_USE_DEPT varchar(10),
	IN A_ETC_RMK varchar(20),
	IN A_BUY_POST_NO varchar(10),
	IN A_BUY_ADDRESS varchar(100),
	IN A_BUY_PHONE varchar(20),
	IN A_RES_STATUS bigint(20),
	IN A_USE_EMP_NO varchar(20),
	IN A_BUY_EMAIL varchar(50),
	IN A_PREV_EQUI_CODE varchar(20),
	IN A_FILE_NAME varchar(100),
	IN A_REAL_FILE_NAME varchar(100),
	IN A_UPD_EMP_NO varchar(10),
	IN A_UPD_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
	UPDATE TB_MSUR_EQUI
		SET 
-- 	    	EQUI_CODE = A_EQUI_CODE
	    	CLASS1 = A_CLASS1
	    	,CLASS2 = A_CLASS2
	    	,TEMP_SEQ = A_TEMP_SEQ
	    	,EQUI_NAME = A_EQUI_NAME
	    	,EQUI_SPEC = A_EQUI_SPEC
	    	,EQUI_NUM = A_EQUI_NUM
	    	,MAKE_COMP = A_MAKE_COMP
	    	,MODEL_NAME = A_MODEL_NAME
	    	,BUY_AMT = A_BUY_AMT
	    	,BUY_COMP = A_BUY_COMP
	    	,BUY_DATE = DATE_FORMAT(A_BUY_DATE, '%Y%m%d')
	    	,USE_DEPT = A_USE_DEPT
	    	,ETC_RMK = A_ETC_RMK
	    	,BUY_POST_NO = A_BUY_POST_NO
	    	,BUY_ADDRESS = A_BUY_ADDRESS
	    	,BUY_PHONE = A_BUY_PHONE
	    	,RES_STATUS = A_RES_STATUS 
	    	,USE_EMP_NO = A_USE_EMP_NO
	    	,BUY_EMAIL = A_BUY_EMAIL
	    	,PREV_EQUI_CODE = A_PREV_EQUI_CODE
	    	,FILE_NAME = A_FILE_NAME
	    	,REAL_FILE_NAME = A_REAL_FILE_NAME
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