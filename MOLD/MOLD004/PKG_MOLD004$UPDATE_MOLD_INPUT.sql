CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD004$UPDATE_MOLD_INPUT`(	
	IN A_COMP_ID varchar(10),
#	IN A_SET_DATE TIMESTAMP,
#	IN A_SET_SEQ varchar(4),
	IN A_MOLD_INPUT_KEY varchar(30),
#	IN A_CUST_CODE varchar(10),
	IN A_MOLD_CODE varchar(20),
#	IN A_LOT_YN bigint(20),
#	IN A_QTY decimal(10, 0),
#	IN A_COST decimal(16, 4),
#	IN A_AMT decimal(16, 4),
	IN A_DEPT_CODE varchar(10),
#	IN A_IN_QTY decimal(10, 0),
#    IN A_CALL_KIND varchar(10),
#    IN A_CALL_KEY varchar(30),
#    IN A_END_AMT decimal(16, 4),
	IN A_RMK varchar(100),
	IN A_UPD_EMP_NO varchar(10),
	IN A_UPD_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_SET_NO varchar(10);
	declare V_MOLD_INPUT_KEY varchar(30);
	declare V_IN_QTY decimal(10, 0);

	declare I INT;
	declare V_LOT_NO varchar(30);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 

	update TB_MOLD_INPUT
		set 
#			COST = A_COST
#			,AMT = A_AMT
			DEPT_CODE = A_DEPT_CODE
			,RMK = A_RMK
			,UPD_EMP_NO = A_UPD_EMP_NO
	    	,UPD_ID = A_UPD_ID
	    	,UPD_DATE = SYSDATE()
	where COMP_ID = A_COMP_ID
	  and MOLD_INPUT_KEY = A_MOLD_INPUT_KEY
	  and MOLD_CODE = A_MOLD_CODE 
	;
   
    IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF; 
  
end