CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC108$UPDATE_INPUT_RETURN_DET_LIST`(		
	IN A_COMP_ID varchar(10),
-- 	IN A_SET_DATE TIMESTAMP,
-- 	IN A_SET_SEQ varchar(4),
    IN A_INPUT_RETURN_MST_KEY varchar(30),
    IN A_INPUT_RETURN_KEY varchar(30),
    IN A_RETURN_DATE TIMESTAMP,
    IN A_ITEM_CODE varchar(30),
    IN A_LOT_NO varchar(30),
    IN A_QTY decimal(10, 0),
    IN A_COST decimal(16, 4),
    IN A_AMT decimal(16, 4),
    IN A_WARE_CODE bigint(20),
    IN A_DEPT_CODE varchar(10),
    IN A_RETURN_CAUSE bigint(20),
    IN A_END_AMT decimal(16, 4),
    IN A_CALL_KIND varchar(10),
    IN A_CALL_KEY varchar(30),
    IN A_RMK varchar(100),
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
  
  	update TB_INPUT_RETURN_DET
  		set COMP_ID = A_COMP_ID
#	    	,SET_DATE = A_SET_DATE
#	    	,SET_SEQ = A_SET_SEQ
#	    	,SET_NO = A_
#	    	,INPUT_RETURN_MST_KEY = A_INPUT_RETURN_MST_KEY
#	    	,INPUT_RETURN_KEY = A_INPUT_RETURN_KEY
	    	,RETURN_DATE = DATE_FORMAT(A_RETURN_DATE, '%Y%m%d')
	    	,ITEM_CODE = A_ITEM_CODE
	    	,LOT_NO = A_LOT_NO
	    	,QTY = A_QTY
	    	,COST = A_COST
	    	,AMT = A_AMT
	    	,WARE_CODE = A_WARE_CODE
	    	,DEPT_CODE = A_DEPT_CODE
	    	,RETURN_CAUSE = A_RETURN_CAUSE
	    	,END_AMT = A_END_AMT
	    	,CALL_KIND = A_CALL_KIND
	    	,CALL_KEY = A_CALL_KEY
	    	,RMK = A_RMK
	    	,UPD_EMP_NO = A_UPD_EMP_NO
	    	,UPD_ID = A_UPD_ID
	    	,UPD_DATE = SYSDATE()
    where COMP_ID = A_COMP_ID
      and INPUT_RETURN_MST_KEY = A_INPUT_RETURN_MST_KEY
      and INPUT_RETURN_KEY = A_INPUT_RETURN_KEY
    ;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
  	END IF;  
  
end