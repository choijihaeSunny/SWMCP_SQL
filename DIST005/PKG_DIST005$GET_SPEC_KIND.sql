CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_DIST005$GET_SPEC_KIND`(	
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select 'SPEC1' as CODE, '용량1' as NAME
	union all
	select 'SPEC2' as CODE, '용량2' as NAME
	union all
	select 'SPEC3' as CODE, '용량3' as NAME
	union all
	select 'SPEC4' as CODE, '용량4' as NAME
	union all
	select 'SPEC5' as CODE, '용량5' as NAME
	;
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end