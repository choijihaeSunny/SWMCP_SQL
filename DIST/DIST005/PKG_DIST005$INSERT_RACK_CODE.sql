CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_DIST005$INSERT_RACK_CODE`(		
	IN A_COMP_ID varchar(10),
	IN A_RACK_NAME varchar(30),
	IN A_RACK_DIV bigint(20),
	IN A_FLOOR varchar(3),
	IN A_ROOM varchar(3),
	IN A_SPEC bigint(20),
	IN A_SIZE_R decimal(10, 0),
	IN A_SIZE_V decimal(10, 0),
	IN A_SIZE_H decimal(10, 0),
	IN A_RMK  varchar(100),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_RACK_CODE varchar(20);
	declare V_RACK_DIV varchar(20);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
  	SET V_RACK_DIV = (select CODE
  					  from SYS_DATA
  					  where path = 'cfg.dist.rack.item'
  					    and DATA_ID = A_RACK_DIV);
  
    SET V_RACK_CODE := CONCAT(V_RACK_DIV, LPAD(A_FLOOR, 3, '0'), LPAD(A_ROOM, 3, '0'));
  	
    INSERT INTO TB_RACK (
    	COMP_ID
    	,RACK_CODE
    	,RACK_NAME
    	,RACK_DIV
    	,FLOOR
    	,ROOM
    	,SPEC
    	,SIZE_R
    	,SIZE_V
    	,SIZE_H
    	,RMK
    	,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
    ) values (
    	A_COMP_ID
    	,V_RACK_CODE
    	,A_RACK_NAME
    	,A_RACK_DIV
    	,A_FLOOR
    	,A_ROOM
    	,A_SPEC
    	,A_SIZE_R
    	,A_SIZE_V
    	,A_SIZE_H
    	,A_RMK
    	,A_SYS_EMP_NO
    	,A_SYS_ID
    	,SYSDATE()
    )
    ;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end