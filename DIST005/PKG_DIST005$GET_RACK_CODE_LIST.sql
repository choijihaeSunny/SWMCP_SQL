CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_DIST005$GET_RACK_CODE_LIST`(
			IN A_RACK_DIV 		bigint(20),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select A.RACK_CODE,
		   A.RACK_NAME,
		   A.RACK_DIV,
		   A.FLOOR,
		   A.ROOM,
		   A.SPEC,
		   A.SIZE_R,
		   A.SIZE_V,
		   A.SIZE_H,
		   A.RMK
	from TB_RACK A
	where A.RACK_DIV LIKE CONCAT('%', A_RACK_DIV, '%')
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END