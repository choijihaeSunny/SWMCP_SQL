CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_MOLD004$GET_MOLD_INPUT_LOT_LIST`(
			IN A_MOLD_INPUT_KEY   VARCHAR(30),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select
		  A.MOLD_INPUT_KEY,
		  A.MOLD_CODE,
		  A.LOT_NO,
		  A.RMK
	from TB_MOLD_INPUT_LOT A
	where A.MOLD_INPUT_KEY = A_MOLD_INPUT_KEY
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END