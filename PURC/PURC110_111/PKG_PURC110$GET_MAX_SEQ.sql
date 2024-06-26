CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC110$GET_MAX_SEQ`(	
	IN A_COMP_ID varchar(10),
	IN A_SET_DATE DATETIME,
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 


	select LPAD(IFNULL(MAX(SET_SEQ), 0) + 1, 4, '0') as SEQ
	from TB_INPUT_ETC_MST
	where SUBSTRING(SET_DATE, 3, 4) = right(DATE_FORMAT(A_SET_DATE, '%Y%m'), 4)
	;
	

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END