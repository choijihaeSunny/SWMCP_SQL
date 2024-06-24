CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_MOLD003$GET_MOLD_FORDER_REQ_LIST_POP`(
			IN A_ST_DATE 			TIMESTAMP,
			IN A_ED_DATE			TIMESTAMP,
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select
		  'N' as IS_CHECK,
		  STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE,
		  A.SET_SEQ,
		  A.SET_NO,
		  A.MOLD_MORDER_REQ_KEY,
		  A.MOLD_CODE,
		  B.MOLD_NAME,
		  B.MOLD_SPEC,
		  A.QTY,
		  A.QTY - SUM(IFNULL(C.QTY, 0)) as FORDER_QTY,
		  STR_TO_DATE(A.DELI_DATE, '%Y%m%d') as DELI_DATE,
		  A.STOCK_QTY,
		  A.CUST_CODE,
		  (select CUST_NAME
		   from tc_cust_code
		   where cust_code = A.CUST_CODE) as CUST_NAME,
		  A.EMP_NO,
		  (select kor_name
		   from insa_mst 
		   where emp_no = A.EMP_NO) as EMP_NAME,
		  A.DEPT_CODE,
		  A.RMK
	from TB_MOLD_FORDER_REQ A
		INNER join TB_MOLD B
		 	    on A.MOLD_CODE = B.MOLD_CODE
		LEFT join TB_MOLD_FORDER C
				on A.MOLD_MORDER_REQ_KEY = C.CALL_KEY
	where A.SET_DATE BETWEEN DATE_FORMAT(A_ST_DATE, '%Y%m%d') 
						 and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
	group by A.MOLD_MORDER_REQ_KEY, A.QTY
	having A.QTY - SUM(IFNULL(C.QTY, 0)) > 0
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END