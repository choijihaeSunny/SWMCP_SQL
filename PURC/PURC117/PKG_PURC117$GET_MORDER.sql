CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC117$GET_MORDER`(	
	in A_COMP_ID VARCHAR(10),
	in A_ST_DATE DATETIME,
	in A_ED_DATE DATETIME,
	in A_CUST_CODE VARCHAR(10),
	in A_END_YN VARCHAR(1),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select 
		A.COMP_ID,
		str_to_date(A.SET_DATE,'%Y%m%d') as SET_DATE,
		A.SET_SEQ,
		A.SET_NO,
		A.MORDER_MST_KEY,
		str_to_date(A.MORDER_DATE,'%Y%m%d') as MORDER_DATE,
		A.CUST_CODE,
		C.CUST_NAME,
		A.ITEM_CODE,
		B.ITEM_NAME,
		B.ITEM_SPEC,
		A.QTY,
		A.QTY as OLD_QTY,
		A.PRE_STOCK_QTY,
		A.COST,
		A.AMT,
		A.EMP_NO,
		A.DEPT_CODE,
		D.SHIP_INFO,
		A.CURR_UNIT,
		A.EX_RATE,
		A.ORDER_KEY,
		A.MORDER_REQ_MST_KEY,
		A.PRE_STOCK_KIND,
		A.PJ_NO,
		D.PJ_NAME,
		str_to_date(A.DELI_DATE,'%Y%m%d') as DELI_DATE,
		A.MORDER_KIND,
		A.CUST_ITEM_CODE,
		A.ITEM_KIND,
		A.OUTSIDE_ITEM,
		A.RMK,
		A.OUTSIDE_CONFIRM_YN,
		str_to_date(A.OUTSIDE_CONFIRM_DATE,'%Y%m%d') as OUTSIDE_CONFIRM_DATE,
		A.OUTSIDE_OUT_QTY,
		A.END_YN,
		A.IN_QTY,
		A.OUTSIDE_PROG_OUT_QTY,
		A.SYS_ID,
		A.SYS_EMP_NO,
		A.SYS_DT,
		A.UPD_ID,
		A.UPD_EMP_NO,
		A.UPD_DT
	from tb_morder A
		inner join tb_item_code B on (A.ITEM_CODE = B.ITEM_CODE)
		inner join tc_cust_code C on (A.COMP_ID = C.COMP_ID 
								 and A.CUST_CODE = C.CUST_CODE)
		left join tb_project D on (A.PJ_NO = D.PJ_CODE)
	where A.COMP_ID = A_COMP_ID 
	 	and A.SET_DATE between date_format(A_ST_DATE, '%Y%m%d') 
	 					   and date_format(A_ED_DATE, '%Y%m%d')
	 	and A.CUST_CODE like CONCAT('%', A_CUST_CODE, '%') 
	 	and A.END_YN = A_END_YN
	;
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end