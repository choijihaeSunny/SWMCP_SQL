CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC116$GET_CONFIRM_YN`(	
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	
	select '%' as CODE, '전체' as NAME
	union all
	select 'N' as CODE, '미확정' as NAME
	union all
	select 'Y' as CODE, '확정' as NAME
	;
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end