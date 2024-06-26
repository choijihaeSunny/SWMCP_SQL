CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_SALE026$DELETE_OUT_MST`(	
	IN A_COMP_ID varchar(10),
	IN A_OUT_MST_KEY varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
  
	SET N_RETURN = 0;
  	SET V_RETURN = '삭제되었습니다.'; 
  	
  	delete FROM tb_out_mst
    	where COMP_ID = A_COMP_ID
    		and OUT_MST_KEY = A_OUT_MST_KEY;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '삭제에 실패하였습니다.'; 
  	END IF;  
  
end