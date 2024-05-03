CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC110$UPDATE_INPUT_ETC_MST_LIST`(		
	IN A_COMP_ID varchar(10),
-- 	IN A_SET_DATE TIMESTAMP,
-- 	IN A_SET_SEQ varchar(4),
	IN A_INPUT_ETC_MST_KEY varchar(30),
-- 	IN A_INPUT_DATE TIMESTAMP,
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
   
    update TB_INPUT_ETC_MST
    	set COMP_ID = A_COMP_ID
#	    	SET_DATE = A_SET_DATE
#	    	SET_SEQ = A_SET_SEQ
#	    	,INPUT_ETC_MST_KEY = A_INPUT_ETC_MST_KEY
-- 	    	,INPUT_DATE = DATE_FORMAT(A_INPUT_DATE, '%Y%m%d')
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
	  and INPUT_ETC_MST_KEY = A_INPUT_ETC_MST_KEY
	;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
  	END IF;  
  
end