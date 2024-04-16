CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD001$UPDATE_MOLD`(		
	IN A_CLASS1 bigint(20),
	IN A_CLASS2 bigint(20),
	IN A_CLASS_SEQ varchar(4),
	IN A_MOLD_NAME varchar(50),
	IN A_MOLD_SPEC varchar(50),
	IN A_LOT_YN varchar(1),
	IN A_STOCK_SAFE decimal(10, 0),
	IN A_CUST_CODE varchar(10),
	IN A_ITEM_UNIT decimal(10, 0),
	IN A_USE_YN varchar(1),
	IN A_RMK varchar(100),
	IN A_CODE_PRE varchar(30),
	IN A_WARE_POS varchar(10),
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

    UPDATE TB_MOLD
		SET 
	    	CLASS1 = A_CLASS1
	    	,CLASS2 = A_CLASS2
	    	,CLASS_SEQ = A_CLASS_SEQ
	    	,MOLD_NAME = A_MOLD_NAME
	    	,MOLD_SPEC = A_MOLD_SPEC
	    	,LOT_YN = A_LOT_YN
	    	,STOCK_SAFE = A_STOCK_SAFE
	    	,CUST_CODE = A_CUST_CODE
	    	,ITEM_UNIT = A_ITEM_UNIT
	    	,USE_YN = A_USE_YN
	    	,RMK = A_RMK
	    	,CODE_PRE = A_CODE_PRE
	    	,WARE_POS = A_WARE_POS
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