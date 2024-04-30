CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PURC108$GET_INPUT_LIST_POP`(
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
		  A.ITEM_CODE,
		  A.QTY,
		  B.RETURN_QTY,
		  A.COST,
		  A.AMT,
		  A.CUST_CODE,
		  C.CUST_NAME,
		  A.EMP_NO,
		  A.SHIP_INFO,
		  A.PJ_NO,
		  A.PJ_NAME,
		  A.ITEM_KIND
	from TB_INPUT_MST A
		 left outer join ( -- 반품등록된 내역이 있을 경우 반품된 수량을 표시해야 한다.
					 	select
							  STR_TO_DATE(AA.SET_DATE, '%Y%m%d') as SET_DATE,
							  AA.SET_SEQ,
							  AA.INPUT_RETURN_MST_KEY,
							  STR_TO_DATE(AA.RETURN_DATE, '%Y%m%d') as RETURN_DATE,
							  AA.CUST_CODE,
							  AA.EMP_NO,
							  AA.DEPT_CODE,
							  AA.SHIP_INFO,
							  AA.ITEM_KIND,
							  AA.PJ_NO,
							  AA.PJ_NAME,
							  AA.RMKS,
							  SUM(BB.QTY) as RETURN_QTY
						from TB_INPUT_RETURN_MST AA
							right outer join TB_INPUT_RETURN_DET BB
								on AA.COMP_ID = BB.COMP_ID 
								and AA.INPUT_RETURN_MST_KEY = BB.INPUT_RETURN_MST_KEY
						group by AA.INPUT_RETURN_MST_KEY	
					 ) AS B
		   on A.CUST_CODE = B.CUST_CODE
		  and A.EMP_NO = B.EMP_NO
		  and A.SHIP_INFO = B.SHIP_INFO
		  and A.PJ_NO = B.PJ_NO
		  and A.ITEM_KIND = B.ITEM_KIND
		 inner join tc_cust_code C on (A.COMP_ID = C.COMP_ID and A.CUST_CODE = C.CUST_CODE)
    where A.SET_DATE BETWEEN DATE_FORMAT(A_ST_DATE, '%Y%m%d') 
					     AND DATE_FORMAT(A_ED_DATE, '%Y%m%d')
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END