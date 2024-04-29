CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC110$INSERT_INPUT_ETC_MST_LIST`(		
	IN A_COMP_ID varchar(10),
	IN A_SET_DATE TIMESTAMP,
	IN A_SET_SEQ varchar(4),
	INOUT A_INPUT_ETC_MST_KEY varchar(30),
	IN A_INPUT_DATE TIMESTAMP,
	IN A_CUST_CODE varchar(10),
	IN A_EMP_NO varchar(10),
	IN A_DEPT_CODE varchar(10),
	IN A_SHIP_INFO varchar(30),
	IN A_PJ_NO varchar(30),
	IN A_PJ_NAME varchar(50),
	IN A_RMKS varchar(100),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_INPUT_ETC_MST_KEY varchar(30);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
    SET V_INPUT_ETC_MST_KEY := CONCAT('PE', right(DATE_FORMAT(A_SET_DATE, '%Y%m'), 4), LPAD(A_SET_SEQ, 4, '0'));
    SET A_INPUT_ETC_MST_KEY = V_INPUT_ETC_MST_KEY;
  	
    INSERT INTO TB_INPUT_ETC_MST (
    	COMP_ID,
    	SET_DATE,
    	SET_SEQ,
    	INPUT_ETC_MST_KEY,
    	INPUT_DATE,
    	CUST_CODE,
    	EMP_NO,
    	DEPT_CODE,
    	SHIP_INFO,
    	PJ_NO,
    	PJ_NAME,
    	RMKS
    	,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
    ) values (
   		A_COMP_ID,
    	DATE_FORMAT(A_SET_DATE, '%Y%m%d'),
    	LPAD(A_SET_SEQ, 4, '0'),
    	V_INPUT_ETC_MST_KEY,
    	DATE_FORMAT(A_INPUT_DATE, '%Y%m%d'),
    	A_CUST_CODE,
    	A_EMP_NO,
    	A_DEPT_CODE,
    	A_SHIP_INFO,
    	A_PJ_NO,
    	A_PJ_NAME,
    	A_RMKS
    	,A_SYS_EMP_NO
    	,A_SYS_ID
    	,SYSDATE()
    )
    ;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
  	END IF;  
  
end