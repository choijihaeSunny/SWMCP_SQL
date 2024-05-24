CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC117$UPDATE_TB_MORDER_END`(		
	IN A_COMP_ID varchar(10),
	IN A_MORDER_MST_KEY varchar(30),
	IN A_RMK varchar(100),
	IN A_UPD_EMP_NO varchar(10),
	IN A_UPD_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_END_YN VARCHAR(1);	

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
 	
  	set V_END_YN = (select
  						  if (END_YN = 'N', 'Y', 'N')
  					from TB_MORDER
  					where COMP_ID = A_COMP_ID
	  				and MORDER_MST_KEY = A_MORDER_MST_KEY);
   
    UPDATE TB_MORDER
    	SET
	    	END_YN = V_END_YN,
	    	END_EMP = A_UPD_EMP_NO,
	    	END_DT = SYSDATE(),
	   		RMK = A_RMK
	    	,UPD_EMP_NO = A_UPD_EMP_NO
	    	,UPD_ID = A_UPD_ID
	    	,UPD_DATE = SYSDATE()
	where COMP_ID = A_COMP_ID
	  and MORDER_MST_KEY = A_MORDER_MST_KEY
    ;
   
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
  	END IF;  
  
end