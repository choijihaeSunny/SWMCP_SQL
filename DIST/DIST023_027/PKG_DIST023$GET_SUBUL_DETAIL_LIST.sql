CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_DIST023$GET_SUBUL_DETAIL_LIST`(	
	in A_COMP_ID VARCHAR(10),
	IN A_ST_DATE TIMESTAMP,
	IN A_ED_DATE TIMESTAMP,
	in A_ITEM_CODE VARCHAR(30),
	in A_ITEM_NAME VARCHAR(100),
	in A_ITEM_KIND BIGINT(20),
	in A_WARE_CODE bigint(20),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end