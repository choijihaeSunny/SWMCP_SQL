CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_QUAL026$GET_MSUR_EQUI_LIST`(
			IN A_CLASS1 		bigint(20),
			IN A_EQUI_NAME		VARCHAR(50),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	DECLARE V_RACK_DIV VARCHAR(20);
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select
		  A.EQUI_CODE,
		  A.CLASS1,
		  A.CLASS2,
		  A.TEMP_SEQ,
		  A.EQUI_NAME,
		  A.EQUI_SPEC,
		  A.EQUI_NUM,
		  A.MAKE_COMP,
		  A.MODEL_NAME,
		  A.BUY_AMT,
		  A.BUY_COMP,
		  A.BUY_DATE,
		  A.USE_DEPT,
		  A.ETC_RMK,
		  A.BUY_POST_NO,
		  A.BUY_ADDRESS,
		  A.BUY_PHONE,
		  A.RES_STATUS,
		  A.USE_EMP,
		  A.BUY_EMAIL,
		  A.PREV_EQUI_CODE,
		  A.FILE_NAME,
		  A.REAL_FILE_NAME
	from TB_MSUR_EQUI A
	where A.CLASS1 LIKE CONCAT('%', A_CLASS1, '%')
	  and A.EQUI_NAME like CONCAT('%', A_EQUI_NAME, '%')
	;
	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END