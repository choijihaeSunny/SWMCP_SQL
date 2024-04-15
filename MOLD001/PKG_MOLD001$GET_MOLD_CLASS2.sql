CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD001$GET_MOLD_CLASS2`(	
	IN A_CLASS1 bigint(20),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 


-- 	select * from SYS_DATA
-- 	where path like 'cfg.mold%'
	-- and full_path = 'cfg.mold..class2'
-- 	;

	select
	  CODE
	  ,NAME
	from 
	(
		select 10 as CLASS1, 11 as CODE, '중분류1_1' as NAME
		union all
		select 10 as CLASS1, 12 as CODE, '중분류1_2' as NAME
		union all
		select 10 as CLASS1, 13 as CODE, '중분류1_3' as NAME
		union all
		select 10 as CLASS1, 14 as CODE, '중분류1_4' as NAME
		union all
		select 10 as CLASS1, 15 as CODE, '중분류1_5' as NAME
		union all
		select 20 as CLASS1, 21 as CODE, '중분류2_1' as NAME
		union all
		select 20 as CLASS1, 23 as CODE, '중분류2_2' as NAME
		union all
		select 20 as CLASS1, 25 as CODE, '중분류2_3' as NAME
		union all
		select 20 as CLASS1, 27 as CODE, '중분류2_4' as NAME
		union all
		select 20 as CLASS1, 29 as CODE, '중분류2_5' as NAME
		union all
		select 30 as CLASS1, 32 as CODE, '증분류3_1' as NAME
		union all
		select 30 as CLASS1, 34 as CODE, '증분류3_2' as NAME
		union all
		select 30 as CLASS1, 36 as CODE, '증분류3_3' as NAME
		union all
		select 30 as CLASS1, 38 as CODE, '증분류3_4' as NAME
		union all
		select 30 as CLASS1, 30 as CODE, '증분류3_5' as NAME
		union all
		select 40 as CLASS1, 46 as CODE, '중분류4_1' as NAME
		union all
		select 40 as CLASS1, 47 as CODE, '중분류4_2' as NAME
		union all
		select 40 as CLASS1, 48 as CODE, '중분류4_3' as NAME
		union all
		select 40 as CLASS1, 49 as CODE, '중분류4_4' as NAME
		union all
		select 40 as CLASS1, 40 as CODE, '중분류4_5' as NAME
		union all
		select 50 as CLASS1, 51 as CODE, '중분류_0' as NAME	
	) A
	where A.CLASS1 = A_CLASS1
	;
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end