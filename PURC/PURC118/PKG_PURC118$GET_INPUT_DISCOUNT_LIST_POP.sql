CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PURC118$GET_INPUT_DISCOUNT_LIST_POP`(
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
		   A.CUST_CODE,
		  B.CUST_NAME,
		  A.INPUT_AMT,
		  A.DS_RATE,
		  A.DS_AMT,
		  A.DS_CAUSE,
		  STR_TO_DATE(A.DS_INPUT_FROM, '%Y%m%d') as DS_INPUT_FROM,
		  STR_TO_DATE(A.DS_INPUT_TO, '%Y%m%d') as DS_INPUT_TO,
		  A.END_AMT,
		  A.RMK
	from TB_INPUT_DISCOUNT A
		inner join tc_cust_code B
			on A.CUST_CODE = B.CUST_CODE
	where A.SET_DATE BETWEEN DATE_FORMAT(A_ST_DATE, '%Y%m%d') and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END