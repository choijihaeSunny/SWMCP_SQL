CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD001$GET_MOLD_CLASS1`(	
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN);

-- 	select * from SYS_DATA
-- 	where path like 'cfg.mold%'
	-- and full_path = 'cfg.mold..class1'
-- 	;

	select 10 as CODE, '대분류1' as NAME
	union all
	select 20 as CODE, '대분류2' as NAME
	union all
	select 30 as CODE, '대분류3' as NAME
	union all
	select 40 as CODE, '대분류4' as NAME
	union all
	select 50 as CODE, '대분류5' as NAME
	;
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end