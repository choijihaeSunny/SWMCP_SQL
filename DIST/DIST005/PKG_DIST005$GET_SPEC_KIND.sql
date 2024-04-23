CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_DIST005$GET_SPEC_KIND`(	
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select 
		  A.CODE,
		  A.NAME
	from sys_data A 
	where path like 'cfg.dist.rack%'
	;
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end