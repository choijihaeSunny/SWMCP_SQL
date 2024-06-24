CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PURC108$GET_INPUT_LIST_POP`(
			in A_COMP_ID			VARCHAR(10),
			IN A_ST_DATE 			TIMESTAMP,
			IN A_ED_DATE			TIMESTAMP,
			IN A_CUST_CODE		 	VARCHAR(10),
			IN A_PJ_NO				VARCHAR(30),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select 
		  STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE,
		  A.ITEM_CODE,
		  A.ITEM_KIND,
		  D.ITEM_NAME,
		  D.ITEM_SPEC,
		  A.QTY - A.IN_BAD_QTY - A.RETURN_QTY as QTY,
		  A.RETURN_QTY,
		  A.COST,
		  ROUND((A.QTY - A.IN_BAD_QTY - A.RETURN_QTY) * A.COST, 0) as AMT,
		  A.CUST_CODE,
		  C.CUST_NAME,
		  A.EMP_NO,
		  A.SHIP_INFO,
		  A.PJ_NO,
		  A.PJ_NAME,
		  A.LOT_NO,
		  A.DEPT_CODE,
		  A.WARE_CODE,
		  A.INPUT_MST_KEY
	from TB_INPUT_MST A inner join TC_CUST_CODE C  on (A.COMP_ID = C.COMP_ID 
												 	and A.CUST_CODE = C.CUST_CODE)
			 inner join TB_ITEM_CODE D on (A.ITEM_CODE = D.ITEM_CODE )
    where A.SET_DATE BETWEEN DATE_FORMAT(A_ST_DATE, '%Y%m%d') 
					     AND DATE_FORMAT(A_ED_DATE, '%Y%m%d')
	  and A.CUST_CODE like CONCAT('%', A_CUST_CODE, '%')
	  and A.PJ_NO like CONCAT('%', A_PJ_NO, '%')
	  and A.IN_CONFIRM_YN = 'Y'
	  and (A.QTY - A.IN_BAD_QTY) > A.RETURN_QTY ;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END