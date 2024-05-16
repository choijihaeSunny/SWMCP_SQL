CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD003$UPDATE_MOLD_FORDER_LIST`(		
	IN A_COMP_ID varchar(10),
#	IN A_SET_SEQ varchar(4),
#	IN A_SET_NO varchar(4),
	IN A_MOLD_MORDER_KEY varchar(30),
	IN A_MOLD_CODE varchar(20),
	IN A_CUST_CODE varchar(10),
	IN A_QTY decimal(10, 0),
	IN A_DELI_DATE TIMESTAMP,
	IN A_COST decimal(16, 4),
	IN A_EMP_NO varchar(10),
	IN A_DEPT_CODE varchar(10),
	IN A_RMK varchar(100),
	IN A_UPD_EMP_NO varchar(10),
	IN A_UPD_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_AMT decimal(16, 4);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
   
    set V_AMT = A_QTY * A_COST; -- 단가 * 갯수 = 금액
  
    UPDATE TB_MOLD_FORDER
    	SET 
#    		COMP_ID = A_COMP_ID
#	    	,SET_DATE = A_SET_DATE
#	    	,SET_SEQ = A_SET_SEQ
#	    	,SET_NO = A_SET_NO
#	    	,MOLD_MORDER_REQ_KEY = A_MOLD_MORDER_REQ_KEY
	    	MOLD_CODE = A_MOLD_CODE
	    	,CUST_CODE = A_CUST_CODE
	    	,QTY = A_QTY
	    	,DELI_DATE = A_DELI_DATE
	    	,COST = A_COST
	    	,AMT = V_AMT
	    	,EMP_NO = A_EMP_NO
	    	,DEPT_CODE = A_DEPT_CODE
	    	,RMK = A_RMK
	    	,UPD_EMP_NO = A_UPD_EMP_NO
	    	,UPD_ID = A_UPD_ID
	    	,UPD_DATE = SYSDATE()
	WHERE COMP_ID = A_COMP_ID
	   and MOLD_MORDER_KEY = A_MOLD_MORDER_KEY
	;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end