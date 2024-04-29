CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_SALE009$GET_COLL_BILL_LIST`(
			IN A_ST_DATE 		TIMESTAMP,
			IN A_ED_DATE 		TIMESTAMP,
			IN A_CUST_CODE		varchar(10),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin

	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select
		  STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE,
		  A.SET_SEQ,
		  A.COLL_NUMB,
		  A.CUST_CODE,
		  (select CUST_NAME
		   from tc_cust_code
		   where cust_code = A.CUST_CODE) as CUST_NAME,
		  A.EMP_NO,
		  (select kor_name
		   from insa_mst 
		   where emp_no = A.EMP_NO) as EMP_NAME,
		  A.DEPT_CODE,
		  A.SALES_KIND,
		  A.COLL_KIND,
		  A.RACE_KIND,
		  A.BILL_TYPE,
		  A.MNY_EA,
		  A.MNY_RATE,
		  A.EXCH_GAP,
		  A.COMMISSION,
		  A.MANAGE_NO,
		  A.APP_NO,
		  STR_TO_DATE(A.BAL_DATE, '%Y%m%d') as BAL_DATE,
		  STR_TO_DATE(A.END_DATE, '%Y%m%d') as END_DATE,
		  A.BAL_CUST_NM,
		  A.BAL_BANK_NM,
		  A.COLL_AMT,
		  A.SLIP_NUMB,
		  A.RMKS
	from TB_COLL_BILL A
	where A.SET_DATE BETWEEN DATE_FORMAT(A_ST_DATE, '%Y%m%d')
						 AND DATE_FORMAT(A_ED_DATE, '%Y%m%d')
	  and A.CUST_CODE = A_CUST_CODE
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END