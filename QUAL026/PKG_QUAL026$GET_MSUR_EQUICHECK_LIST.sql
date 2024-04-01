CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_QUAL026$GET_MSUR_EQUICHECK_LIST`(
			IN A_EQUI_CODE 		varchar(20),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	DECLARE V_RACK_DIV VARCHAR(20);
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select
		  A.CHECK_ITEM,
		  A.CYCLE,
		  A.FINAL_DATE,
		  A.NEXT_DATE,
		  A.CHECK_DEPT,
		  A.ETC_RMK
	from TB_MSUR_EQUICHECK A
	where A.EQUI_CODE LIKE CONCAT('%', A_EQUI_CODE, '%')
	;
	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END