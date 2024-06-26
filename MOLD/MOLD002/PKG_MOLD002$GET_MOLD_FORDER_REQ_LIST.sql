CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_MOLD002$GET_MOLD_FORDER_REQ_LIST`(
			IN A_SET_DATE 		TIMESTAMP,
			IN A_SET_SEQ		varchar(4),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare V_SET_SEQ varchar(3);
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	if trim(A_SET_SEQ) <> '' then
		set V_SET_SEQ := LPAD(A_SET_SEQ, 3, '0');
	end if;

	select
		  STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE,
		  A.SET_SEQ,
		  A.SET_NO,
		  A.MOLD_MORDER_REQ_KEY,
		  A.MOLD_CODE,
		  B.MOLD_NAME,
		  B.MOLD_SPEC,
		  A.QTY,
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
	where A.SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d')
	  and A.SET_SEQ = V_SET_SEQ
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END