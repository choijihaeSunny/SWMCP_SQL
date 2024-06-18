CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PURC110$GET_INPUT_ETC_LIST_POP`(
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
		  A.INPUT_ETC_MST_KEY,
		  STR_TO_DATE(A.INPUT_DATE, '%Y%m%d') as INPUT_DATE,
		  A.CUST_CODE,
		  C.CUST_NAME,
		  B.ITEM_CODE,
		  D.ITEM_NAME,
		  D.ITEM_SPEC,
		  B.QTY,
		  B.COST,
		  B.AMT,
		  A.EMP_NO,
		  E.KOR_NAME as EMP_NAME,
		  A.DEPT_CODE,
		  A.SHIP_INFO,
		  A.PJ_NO,
		  A.PJ_NAME,
		  A.RMKS
	from TB_INPUT_ETC_MST A
		inner join TB_INPUT_ETC_DET B
			on (A.COMP_ID = B.COMP_ID
			and A.INPUT_ETC_MST_KEY = B.INPUT_ETC_MST_KEY)
		inner join TC_CUST_CODE C
			on A.COMP_ID = C.COMP_ID
			and A.CUST_CODE = C.CUST_CODE
		LEFT join TB_ITEM_CODE D
			on B.ITEM_CODE = D.ITEM_CODE
		LEFT join INSA_MST E
			on A.COMP_ID = E.COMP_ID
			and A.EMP_NO = E.KOR_NAME
	where A.SET_DATE BETWEEN DATE_FORMAT(A_ST_DATE, '%Y%m%d') and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END