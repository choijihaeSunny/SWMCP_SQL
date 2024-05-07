CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC114$DELETE_TB_STOCK_MOVE`(		
	IN A_COMP_ID varchar(10),
-- 	IN A_SET_DATE TIMESTAMP,
-- 	IN A_SET_SEQ varchar(4),
	IN A_MOVE_KEY varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
 
   
    delete FROM TB_STOCK_MOVE
	where COMP_ID = A_COMP_ID
	  and MOVE_KEY = A_MOVE_KEY
    ;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
  	END IF;  
  
end