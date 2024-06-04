CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROD035$GET_WORK_PLAN_CONFIRM`(	
	in A_COMP_ID VARCHAR(10),
	in A_CONFIRM_YN		VARCHAR(1),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select A_CONFIRM_YN as CONFIRM_YN, 'RMK' as RMK
	from   dual;

	SET N_RETURN = 0;
	SET V_RETURN = '조회했습니다.'; 

		
END