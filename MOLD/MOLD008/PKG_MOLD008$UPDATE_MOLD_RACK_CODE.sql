CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD008$UPDATE_MOLD_RACK_CODE`(	
	IN A_COMP_ID varchar(10),
	IN A_RACK_CODE varchar(20),
	IN A_RACK_NAME varchar(30),
	IN A_RACK_DIV bigint(20),
	IN A_FLOOR varchar(3),
	IN A_ROOM varchar(3),
	IN A_SPEC bigint(20),
	IN A_SIZE_R decimal(10, 0),
	IN A_SIZE_V decimal(10, 0),
	IN A_SIZE_H decimal(10, 0),
	IN A_RMK  varchar(100),
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
  
	UPDATE TB_MOLD_RACK
		SET 
	    	FLOOR = A_FLOOR
	    	,ROOM = A_ROOM
	    	,SPEC = A_SPEC
	    	,SIZE_R = A_SIZE_R
	    	,SIZE_V = A_SIZE_V
	    	,SIZE_H = A_SIZE_H
	    	,RMK = A_RMK
	    	,UPD_EMP_NO = A_UPD_EMP_NO
	    	,UPD_ID = A_UPD_ID
	    	,UPD_DATE = SYSDATE()
	 WHERE COMP_ID = A_COMP_ID
	   AND RACK_CODE = A_RACK_CODE
	   AND RACK_NAME = A_RACK_NAME
	   AND RACK_DIV = A_RACK_DIv
	 ;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end