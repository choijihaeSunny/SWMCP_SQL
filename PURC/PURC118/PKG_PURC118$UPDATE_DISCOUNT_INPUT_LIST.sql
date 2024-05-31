CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC118$UPDATE_DISCOUNT_INPUT_LIST`(		
	IN A_COMP_ID varchar(10),
	IN A_DS_AMT decimal(16, 4),
	IN A_DS_KEY varchar(30),
	IN A_CUST_CODE varchar(10),
	IN A_DB_KEY varchar(30),
	IN A_DB_NAME varchar(30),
	IN A_UPD_DIV varchar(30),
	IN A_UPD_EMP_NO varchar(10),
	IN A_UPD_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_DS_AMT decimal(16, 4);
	declare V_DS_KEY varchar(30);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 

	if A_UPD_DIV = 'UPDATE' then
		set V_DS_AMT = A_DS_AMT;
		set V_DS_KEY = A_DS_KEY;
	elseif A_UPD_DIV = 'DELETE' then
		set V_DS_AMT = 0;
		set V_DS_KEY = null;
	end if;
	
	if A_DB_NAME = 'TB_INPUT_MST' then
		update TB_INPUT_MST
			set DS_AMT = V_DS_AMT,
			    DS_KEY = V_DS_KEY
			    ,UPD_EMP_NO = A_UPD_EMP_NO
		    	,UPD_ID = A_UPD_ID
		    	,UPD_DT = SYSDATE()
	    where COMP_ID = A_COMP_ID
		  and INPUT_MST_KEY = A_DB_KEY
		  and CUST_CODE = A_CUST_CODE
		;
	elseif A_DB_NAME = 'TB_INPUT_OUTSIDE' then
		update TB_INPUT_OUTSIDE
			set DS_AMT = V_DS_AMT,
			    DS_KEY = V_DS_KEY
			    ,UPD_EMP_NO = A_UPD_EMP_NO
		    	,UPD_ID = A_UPD_ID
		    	,UPD_DT = SYSDATE()
	    where COMP_ID = A_COMP_ID
		  and INPUT_OUTSIDE_KEY = A_DB_KEY
		  and CUST_CODE = A_CUST_CODE
		;
	end if;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end