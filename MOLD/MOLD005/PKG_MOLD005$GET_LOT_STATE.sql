CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD005$GET_LOT_STATE`(	
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 


	select 'N' as CODE, '정상' as NAME
	union all
	select 'P' as CODE, '폐기' as NAME
	union all
	select 'M' as CODE, '수리' as NAME
	;

	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end