CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC112$UPDATE_MATR_ETC_OUT_LIST`(		
	IN A_COMP_ID varchar(10),
-- 	IN A_SET_DATE TIMESTAMP,
-- 	IN A_SET_SEQ varchar(4),
	IN A_MATR_ETC_OUT_MST_KEY varchar(30),
-- 	IN A_OUT_DATE TIMESTAMP,
	IN A_CUST_CODE varchar(10),
	IN A_EMP_NO varchar(10),
	IN A_DEPT_CODE varchar(10),
	IN A_SHIP_INFO varchar(30),
	IN A_PJ_NO varchar(30),
	IN A_PJ_NAME varchar(50),
	IN A_RMKS varchar(100),
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
   
    update TB_MATR_ETC_OUT_MST
    	set COMP_ID = A_COMP_ID
#	    	SET_DATE = A_SET_DATE
#	    	SET_SEQ = A_SET_SEQ
#	    	,MATR_ETC_OUT_MST_KEY = A_MATR_ETC_OUT_MST_KEY
	    	,OUT_DATE = DATE_FORMAT(A_OUT_DATE, '%Y%m%d')
	    	,CUST_CODE = A_CUST_CODE
	    	,EMP_NO = A_EMP_NO
	    	,DEPT_CODE = A_DEPT_CODE
	    	,SHIP_INFO = A_SHIP_INFO
	    	,PJ_NO = A_PJ_NO
	    	,PJ_NAME = A_PJ_NAME
	    	,RMKS = A_RMKS
    		,UPD_EMP_NO = A_UPD_EMP_NO
	    	,UPD_ID = A_UPD_ID
	    	,UPD_DATE = SYSDATE()
	where COMP_ID = A_COMP_ID
	  and MATR_ETC_OUT_MST_KEY = A_MATR_ETC_OUT_MST_KEY
	;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
  	END IF;  
  
end