CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD007$DELETE_MOLD_SCRAP_LIST`(		
	IN A_COMP_ID varchar(10),
	IN A_MOLD_SCRAP_KEY varchar(30),
	IN A_LOT_NO varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_LOT_STATE varchar(10);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
   
  
	DELETE FROM TB_MOLD_SCRAP
	 WHERE COMP_ID = A_COMP_ID
	   and MOLD_SCRAP_KEY = A_MOLD_SCRAP_KEY
	 ;
	
	set V_LOT_STATE = (select DATA_ID
					   from SYS_DATA
					   where path = 'cfg.mold.lotstate'
						 and CODE = 'M');
	
	update TB_MOLD_LOT
	   set LOT_STATE = V_LOT_STATE
	where LOT_NO = A_LOT_NO
	;
	 
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end