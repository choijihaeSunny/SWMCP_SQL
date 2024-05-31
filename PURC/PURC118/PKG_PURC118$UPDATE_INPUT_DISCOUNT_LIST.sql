CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC118$UPDATE_INPUT_DISCOUNT_LIST`(		
	IN A_COMP_ID varchar(10),
    IN A_SET_DATE varchar(8),
    IN A_DS_KEY varchar(30),
    IN A_CUST_CODE varchar(10),
    IN A_INPUT_AMT decimal(16, 4),
    IN A_DS_RATE decimal(16, 4),
    IN A_DS_AMT decimal(16, 4),
    IN A_DS_CAUSE varchar(50),
    IN A_DS_INPUT_FROM varchar(8),
    IN A_DS_INPUT_TO varchar(8),
    IN A_END_AMT decimal(16, 4),
    IN A_RMK varchar(100),
	IN A_UPD_EMP_NO varchar(10),
	IN A_UPD_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	
   					  
    UPDATE TB_INPUT_DISCOUNT
    	SET
#	    	COMP_ID = A_COMP_ID,
#	    	SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d'),
#	    	CUST_CODE = A_CUST_CODE,
	    	INPUT_AMT = A_INPUT_AMT,
	    	DS_RATE = A_DS_RATE,
	    	DS_AMT = A_DS_AMT,
	    	DS_CAUSE = A_DS_CAUSE,
	    	DS_INPUT_FROM = DATE_FORMAT(A_DS_INPUT_FROM, '%Y%m%d'),
	    	DS_INPUT_TO = DATE_FORMAT(A_DS_INPUT_TO, '%Y%m%d'),
	    	END_AMT = A_END_AMT,
	    	RMK = A_RMK
	    	,UPD_EMP_NO = A_UPD_EMP_NO
	    	,UPD_ID = A_UPD_ID
	    	,UPD_DATE = SYSDATE()
    where COMP_ID = A_COMP_ID
      and SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d')
      and DS_KEY = A_DS_KEY
      and CUST_CODE = A_CUST_CODE
    ;
  
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end