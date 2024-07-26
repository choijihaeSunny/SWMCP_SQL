CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC119$UPDATE_INPUT_END_DET`(		
	IN A_COMP_ID VARCHAR(10),
	IN A_INPUT_END_KEY VARCHAR(30),
	IN A_DET_SEQ VARCHAR(4),
	IN A_RMKS VARCHAR(100),
  	IN A_UPD_EMP_NO varchar(10),
	IN A_UPD_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	update TB_INPUT_END_DET
  	   set RMKS = A_RMKS,
  	   	   UPD_ID = A_UPD_ID,	
  	   	   UPD_EMP_NO = A_UPD_EMP_NO,
	  	   UPD_DATE = SYSDATE()
	where COMP_ID = A_COMP_ID
	  and INPUT_END_KEY = A_INPUT_END_KEY
	  and DET_SEQ = A_DET_SEQ
	;
  	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
  	END IF;  
  
end