CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD006$DELETE_MOLD_MODI_LIST`(		
	IN A_COMP_ID varchar(10),
	IN A_MOLD_MODI_KEY varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_LOT_STATE varchar(10);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
   
  
	DELETE FROM TB_MOLD_MODI
	 WHERE COMP_ID = A_COMP_ID
	   and MOLD_MODI_KEY = A_MOLD_MODI_KEY
	 ;
	
	 set V_LOT_STATE = (select DATA_ID
						  from SYS_DATA
					     where path = 'cfg.mold.lotstate'
						   and CODE = 'N');
							    
	update TB_MOLD_LOT
	   set LOT_STATE = V_LOT_STATE
	 where COMP_ID = A_COMP_ID
	   and CREATE_TABLE = 'TB_MOLD_MODI'
	   and CREATE_TABLE_KEY = A_MOLD_MODI_KEY
	;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end