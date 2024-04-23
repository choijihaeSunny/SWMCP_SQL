CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD006$UPDATE_MOLD_MODI_LIST`(		
	IN A_COMP_ID varchar(10),
#	IN A_SET_DATE TIMESTAMP,
#	IN A_SET_SEQ varchar(4),
	IN A_MOLD_MODI_KEY varchar(30),
	IN A_MODI_DIV varchar(10),
	IN A_MOLD_CODE varchar(20),
	IN A_LOT_NO varchar(30),
	IN A_QTY decimal(10, 0),
	IN A_COST decimal(16, 4),
	IN A_AMT decimal(16, 4),
	IN A_MOLD_CODE_AFT varchar(30),
	IN A_LOT_NO_AFT varchar(30),
	IN A_DEPT_CODE varchar(10),
	IN A_IN_OUT varchar(10),
	IN A_CUST_CODE varchar(10),
	IN A_CONT varchar(100),
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
  
    update TB_MOLD_MODI
    	set
#    		COMP_ID = A_COMP_ID,
#	    	SET_DATE = A_SET_DATE,
#	    	SET_SEQ = A_SET_SEQ,
#	    	SET_NO = A_SET_NO,
#	    	MOLD_MODI_KEY = A_MOLD_MODI_KEY,
	    	MODI_DIV = A_MODI_DIV,
	    	MOLD_CODE = A_MOLD_CODE,
	    	LOT_NO = A_LOT_NO,
	    	QTY = A_QTY,
	    	COST = A_COST,
	    	AMT = A_AMT,
	    	MOLD_CODE_AFT = A_MOLD_CODE_AFT,
	    	LOT_NO_AFT = A_LOT_NO_AFT,
	    	DEPT_CODE = A_DEPT_CODE,
	    	IN_OUT = A_IN_OUT,
	    	CUST_CODE = A_CUST_CODE,
	    	CONT = A_CONT,
	    	RMK = A_RMK
	    	,UPD_EMP_NO = A_UPD_EMP_NO
	    	,UPD_ID = A_UPD_ID
	    	,UPD_DATE = A_UPD_DATE
	where COMP_ID = A_COMP_ID
	  and MOLD_MODI_KEY = A_MOLD_MODI_KEY
	  and MOLD_CODE = A_MOLD_CODE
	;
   
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end