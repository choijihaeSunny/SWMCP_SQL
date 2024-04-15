CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD001$GET_USE_YN`(	
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

-- 	select * from SYS_DATA
-- 	where path like 'cfg.mold%'
	-- and full_path = 'cfg.qual.equi.state'
-- 	;

	select 1 as CODE, '사용' as NAME
	union all
	select 0 as CODE, '중지' as NAME
	;
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end