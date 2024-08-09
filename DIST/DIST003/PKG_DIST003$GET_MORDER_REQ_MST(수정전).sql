CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_DIST003$GET_MORDER_REQ_MST`(	
	in A_COMP_ID VARCHAR(10),
	in A_SET_DATE DATETIME,
	in A_SET_SEQ DECIMAL(4),
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
		A.MORDER_REQ_MST_KEY,
		A.MORDER_KIND,
		str_to_date(A.ORDER_DATE,'%Y%m%d') as ORDER_DATE,
		A.ITEM_CODE,
		B.ITEM_NAME,
		B.ITEM_SPEC,
		A.REQ_QTY,
		str_to_date(A.DELI_DATE,'%Y%m%d') as DELI_DATE,
		A.EMP_NO,
		A.DEPT_CODE,
		A.WARE_CODE,
		D.SHIP_INFO,
		A.PJ_NO,
		D.PJ_NAME,
		A.MORDER_QTY,
		A.ORDER_KEY,
		A.DET_SEQ,
		A.PRE_STOCK_KIND,
		A.END_YN,
		str_to_date(A.END_DATE,'%Y%m%d') as END_DATE,
		A.END_EMP_NO,
		A.RMK,
		A.TEMP1,
		A.TEMP2,
		A.TEMP3,
		A.TEMP4,
		A.TEMP5,
		A.SYS_ID,
		A.SYS_EMP_NO,
		A.SYS_DT,
		A.UPD_ID,
		A.UPD_EMP_NO,
		A.UPD_DT
	from tb_morder_req_mst A
		inner join tb_item_code B on (A.ITEM_CODE = B.ITEM_CODE)
		left join tb_project D on (A.PJ_NO = D.PJ_CODE)
	where A.COMP_ID = A_COMP_ID 
	 	and A.SET_DATE = date_format(A_SET_DATE, '%Y%m%d')
		and A.SET_SEQ = LPAD(A_SET_SEQ, 4, '0')
		#and A.MORDER_REQ_MST_KEY like 'PR%'
		and A.MORDER_GUBUN = '1';
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end