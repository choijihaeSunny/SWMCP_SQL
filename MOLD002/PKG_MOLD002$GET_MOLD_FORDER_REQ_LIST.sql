CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_MOLD002$GET_MOLD_FORDER_REQ_LIST`(
			IN A_SET_DATE 		TIMESTAMP,
			IN A_SET_SEQ		varchar(4),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	DECLARE V_RACK_DIV VARCHAR(20);
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select
		  STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE,
		  A.SET_SEQ,
		  A.SET_NO,
		  A.MOLD_MORDER_REQ_KEY,
		  A.MOLD_CODE,
		  A.QTY,
		  STR_TO_DATE(A.DELI_DATE, '%Y%m%d') as DELI_DATE,
		  A.STOCK_QTY,
		  A.CUST_CODE,
		  A.EMP_NO,
		  A.DEPT_CODE,
		  A.BAL_QTY,
		  A.RMK
	from TB_MOLD_FORDER_REQ A
	where A.SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d')
	  and A.SET_SEQ = A_SET_SEQ
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END