CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PURC113$GET_MATR_ETC_OUT_LIST`(
			IN A_ST_DATE 		TIMESTAMP,
			IN A_ED_DATE 		TIMESTAMP,
			IN A_CUST_CODE		varchar(10),
			IN A_CUST_NAME		varchar(100),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select
		  STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE,
		  A.SET_SEQ,
		  A.MATR_ETC_OUT_MST_KEY,
		  STR_TO_DATE(A.OUT_DATE, '%Y%m%d') as OUT_DATE,
		  A.CUST_CODE,
		  C.CUST_NAME,
		  A.EMP_NO,
		  A.DEPT_CODE,
		  A.SHIP_INFO,
		  A.PJ_NO,
		  A.PJ_NAME,
		  A.RMKS,
		  B.MATR_ETC_OUT_KEY,
		  STR_TO_DATE(B.OUT_DATE, '%Y%m%d') as OUT_DATE_2,
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
		  B.RMK
	from TB_MATR_ETC_OUT A
		left join TB_MATR_ETC_OUT_DET B
				  on A.MATR_ETC_OUT_MST_KEY = B.MATR_ETC_OUT_MST_KEY
		inner join tc_cust_code C on (A.COMP_ID = C.COMP_ID 
								  and A.CUST_CODE = C.CUST_CODE)
	where A.SET_DATE BETWEEN DATE_FORMAT(A_ST_DATE, '%Y%m%d')
						 AND DATE_FORMAT(A_ED_DATE, '%Y%m%d')
	  and A.CUST_CODE like CONCAT('%', A_CUST_CODE, '%')
	  and C.CUST_NAME like CONCAT('%', A_CUST_NAME, '%')
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END