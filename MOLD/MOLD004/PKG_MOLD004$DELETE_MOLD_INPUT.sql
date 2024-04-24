CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD004$DELETE_MOLD_INPUT`(		
	IN A_COMP_ID varchar(10),
	IN A_CALL_KEY varchar(30),
	IN A_MOLD_INPUT_KEY varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_IN_QTY decimal(10, 0);
	declare V_LOT_NO varchar(30);
	declare I INT;
	declare V_LOT_CNT INT;
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
   
  	set V_IN_QTY = (select IN_QTY
  					from TB_MOLD_INPUT
  					where COMP_ID = A_COMP_ID
  					  and MOLD_INPUT_KEY = A_MOLD_INPUT_KEY);
  
	DELETE FROM TB_MOLD_INPUT
	 WHERE COMP_ID = A_COMP_ID
	   and MOLD_INPUT_KEY = A_MOLD_INPUT_KEY
	 ;
	
	update TB_MOLD_FORDER
	   set IN_QTY = IN_QTY + V_IN_QTY
	where COMP_ID = A_COMP_ID
	  and MOLD_MORDER_KEY = A_CALL_KEY
	;

	set I = 0;

	set V_LOT_CNT = (select COUNT(*)
					 from TB_MOLD_INPUT_LOT
					 where COMP_ID = A_COMP_ID
	   				   and MOLD_INPUT_KEY = A_MOLD_INPUT_KEY);
	
	while I < V_LOT_CNT DO
		set V_LOT_NO = (select LOT_NO
						from TB_MOLD_INPUT_LOT
						where COMP_ID = A_COMP_ID
		   				  and MOLD_INPUT_KEY = A_MOLD_INPUT_KEY
		   				limit 1);
		
		delete from TB_MOLD_INPUT_LOT
		 where COMP_ID = A_COMP_ID
		   and MOLD_INPUT_KEY = A_MOLD_INPUT_KEY
		   and LOT_NO = V_LOT_NO
		;
	
		delete from TB_MOLD_LOT
		 where COMP_ID = A_COMP_ID
		   and LOT_NO = V_LOT_NO
		;
	
		set I = I + 1;
	end while;

	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end