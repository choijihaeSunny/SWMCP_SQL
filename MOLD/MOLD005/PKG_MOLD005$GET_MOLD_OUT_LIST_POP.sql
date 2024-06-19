CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_MOLD005$GET_MOLD_OUT_LIST_POP`(
			IN A_ST_DATE 			TIMESTAMP,
			IN A_ED_DATE			TIMESTAMP,
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select
		  STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE,
		  A.SET_SEQ,
		  A.SET_NO,
		  A.MOLD_OUT_KEY,
		  A.CUST_CODE,
		  (select CUST_NAME
		   from tc_cust_code
		   where cust_code = A.CUST_CODE) as CUST_NAME,
		  A.MOLD_CODE,
		  B.MOLD_NAME,
		  B.MOLD_SPEC,
		  A.LOT_NO,
		  A.QTY,
		  A.COST,
		  A.AMT,
		  A.DEPT_CODE,
		  A.RMK
	from TB_MOLD_OUT A
		INNER join TB_MOLD B
		 	    on A.MOLD_CODE = B.MOLD_CODE
	where A.SET_DATE BETWEEN DATE_FORMAT(A_ST_DATE, '%Y%m%d') and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
	group by A.SET_DATE, A.SET_SEQ
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END