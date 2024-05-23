CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_MOLD008$GET_MOLD_RACK_CODE_LIST`(
			IN A_RACK_DIV 		bigint(20),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select 
		   'N' as CHK,
		   A.RACK_CODE,
		   A.RACK_NAME,
		   A.RACK_DIV,
		   A.FLOOR,
		   A.ROOM,
		   A.SPEC,
		   A.SIZE_R,
		   A.SIZE_V,
		   A.SIZE_H,
		   A.RMK
	from TB_MOLD_RACK A
	where case 
			  when A_RACK_DIV != 0
			  then FIND_IN_SET(A.RACK_DIV, A_RACK_DIV)
			  else A.RACK_DIV like '%'
		  end 
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END