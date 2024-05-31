CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC118$GET_DISCOUNT_INPUT_LIST`(
	IN A_CUST_CODE		VARCHAR(10),
	IN A_ST_DATE		TIMESTAMP,
	IN A_ED_DATE		TIMESTAMP,
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
)
PROC:begin
	
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	
	select 
		  STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE,
		  A.CUST_CODE,
		  A.ITEM_CODE,
		  C.ITEM_NAME,
		  C.ITEM_SPEC,
		  A.QTY,
		  A.COST,
		  A.AMT,
		  A.DS_AMT,
		  'TB_INPUT_MST' as DB_NAME
	from TB_INPUT_MST A
		inner join TC_CUST_CODE B on (A.COMP_ID = B.COMP_ID
								  and A.CUST_CODE = B.CUST_CODE)
		inner join TB_ITEM_CODE C on (A.ITEM_CODE = C.ITEM_CODE)
	where A.CUST_CODE = A_CUST_CODE
	  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
					     and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
	union all 
	select 
		  STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE,
		  A.CUST_CODE,
		  A.ITEM_CODE,
		  C.ITEM_NAME,
		  C.ITEM_SPEC,
		  A.QTY,
		  A.COST,
		  A.AMT,
		  A.DS_AMT,
		  'TB_INPUT_OUTSIDE' as DB_NAME
	from TB_INPUT_OUTSIDE A
		inner join TC_CUST_CODE B on (A.COMP_ID = B.COMP_ID
								  and A.CUST_CODE = B.CUST_CODE)
		inner join TB_ITEM_CODE C on (A.ITEM_CODE = C.ITEM_CODE)
	where A.CUST_CODE = A_CUST_CODE
	  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
					     and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
	;
	
	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
end