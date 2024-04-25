CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_MOLD005$GET_MOLD_LOT_LIST_POP`(
			IN A_ST_DATE 			TIMESTAMP,
			IN A_ED_DATE			TIMESTAMP,
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select
		  A.LOT_NO,
		  A.MOLD_CODE,
		  STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE,
		  A.IN_CUST,
		  (select CUST_NAME
		   from tc_cust_code
		   where cust_code = A.IN_CUST) as CUST_NAME,
		  A.IN_COST,
		  A.LOT_NO_ORI,
		  A.LOT_NO_PRE,
		  A.LOT_STATE,
		  A.QTY,
		  A.WET,
		  A.CREATE_TABLE,
		  A.CREATE_TABLE_KEY,
		  A.HIT_CNT,
		  A.RMK
	from TB_MOLD_LOT A
	where A.SET_DATE BETWEEN DATE_FORMAT(A_ST_DATE, '%Y%m%d') and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END