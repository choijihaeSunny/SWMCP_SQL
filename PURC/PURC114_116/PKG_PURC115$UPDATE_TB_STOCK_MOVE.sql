CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC115$UPDATE_TB_STOCK_MOVE`(		
	IN A_COMP_ID varchar(10),
-- 	IN A_SET_DATE TIMESTAMP,
-- 	IN A_SET_SEQ varchar(4),
	IN A_MOVE_KEY varchar(30),
	IN A_CONFIRM_YN			varchar(1),
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
 
   
    UPDATE TB_STOCK_MOVE
    	SET
	    	CONFIRM_YN = A_CONFIRM_YN,
	    	CONFIRM_EMP = A_UPD_EMP_NO,
	    	CONFIRM_DT = SYSDATE(),
	   		RMK = A_RMK
	    	,UPD_EMP_NO = A_UPD_EMP_NO
	    	,UPD_ID = A_UPD_ID
	    	,UPD_DATE = SYSDATE()
	where COMP_ID = A_COMP_ID
	  and MOVE_KEY = A_MOVE_KEY
    ;
	
    -- 수불발생
   
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
  	END IF;  
  
end