CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_QUAL031$GET_STATUS_DIV`(	
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN);


	select 10 as CODE, '상태1' as NAME
	union all
	select 20 as CODE, '상태2' as NAME
	union all
	select 30 as CODE, '상태3' as NAME
	;
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end