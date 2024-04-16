CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD003$DELETE_MOLD_FORDER_LIST`(		
	IN A_COMP_ID varchar(10),
	IN A_MOLD_MORDER_REQ_KEY varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
   
  
	DELETE FROM TB_MOLD_FORDER
	 WHERE COMP_ID = A_COMP_ID
	   and MOLD_MORDER_REQ_KEY = A_MOLD_MORDER_REQ_KEY
	 ;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end