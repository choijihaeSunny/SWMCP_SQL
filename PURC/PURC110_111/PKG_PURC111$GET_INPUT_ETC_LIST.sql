CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PURC111$GET_INPUT_ETC_LIST`(
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
		  A.INPUT_ETC_MST_KEY,
		  STR_TO_DATE(A.INPUT_DATE, '%Y%m%d') as INPUT_DATE,
		  A.CUST_CODE,
		  (select CUST_NAME
		   from tc_cust_code
		   where cust_code = A.CUST_CODE) as CUST_NAME,
		  A.EMP_NO,
		  (select kor_name
		   from insa_mst 
		   where emp_no = A.EMP_NO) as EMP_NAME,
		  A.DEPT_CODE,
		  A.SHIP_INFO,
		  A.PJ_NO,
		  A.PJ_NAME,
		  A.RMKS,
		  B.INPUT_ETC_KEY,
		  STR_TO_DATE(B.INPUT_DATE, '%Y%m%d') as INPUT_DATE_2,
		  B.ITEM_CODE,
		  (select ITEM_NAME
		   from TB_ITEM_CODE
		   where ITEM_CODE = B.ITEM_CODE) as ITEM_NAME,
		  (select ITEM_SPEC
		   from TB_ITEM_CODE
		   where ITEM_CODE = B.ITEM_CODE) as ITEM_SPEC,
		  B.LOT_NO,
		  B.QTY,
		  B.COST,
		  B.AMT,
		  B.WARE_CODE,
		  B.DEPT_CODE as DEPT_CODE_2,
		  B.END_AMT,
		  B.RMK
	from TB_INPUT_ETC_MST A
		left join TB_INPUT_ETC_DET B
				  on A.INPUT_ETC_MST_KEY = B.INPUT_ETC_MST_KEY
	where A.SET_DATE BETWEEN DATE_FORMAT(A_ST_DATE, '%Y%m%d')
						 AND DATE_FORMAT(A_ED_DATE, '%Y%m%d')
	  and A.CUST_CODE = A_CUST_CODE
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END