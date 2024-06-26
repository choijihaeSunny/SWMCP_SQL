CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROD035$SET_COATING_PLAN_DELETE`(	
	IN A_COMP_ID		varchar(10),
    IN A_WORK_LINE		varchar(10),
--     IN A_ORDER_KEY		varchar(30),
	IN A_SYS_ID 		decimal(10,0), 
	IN A_SYS_EMP_NO 	varchar(10),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
   
    delete FROM TB_COATING_PLAN
     where COMP_ID = A_COMP_ID
--        and ORDER_KEY = A_ORDER_KEY
       and WORK_LINE = A_WORK_LINE
    ;
							
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
END