CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_DIST027$GET_END_GUBUN`(	
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)

	)
begin

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 

	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 



	SELECT 0 as CODE, '미마감' as NAME

	union all

	SELECT 1 as CODE, '마감' as NAME

    ;



	SET N_RETURN = 0;

    SET V_RETURN = '조회되었습니다.';

end