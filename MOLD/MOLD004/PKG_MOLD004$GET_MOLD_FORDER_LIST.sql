CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_MOLD004$GET_MOLD_FORDER_LIST`(
			IN A_COMP_ID varchar(10),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select
		  'N' as CHK,
		  STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE,
		  A.SET_SEQ,
		  A.SET_NO,
		  A.MOLD_MORDER_KEY,
		  A.MOLD_CODE,
		  B.MOLD_NAME,
		  B.MOLD_SPEC,
		  A.CUST_CODE,
		  (select CUST_NAME
		   from tc_cust_code
		   where cust_code = A.CUST_CODE) as CUST_NAME,
		  A.QTY,
		  A.IN_QTY,
		  STR_TO_DATE(A.DELI_DATE, '%Y%m%d') as DELI_DATE,
		  A.COST,
		  A.AMT,
		  A.EMP_NO,
		  (select kor_name
		   from insa_mst 
		   where emp_no = A.EMP_NO) as EMP_NAME,
		  A.DEPT_CODE,
		  B.LOT_YN,
		  A.RMK
	from TB_MOLD_FORDER A
		left join TB_MOLD B
		 	    on A.MOLD_CODE = B.MOLD_CODE
	where A.COMP_ID = A_COMP_ID
	  and A.IN_QTY > 0
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END