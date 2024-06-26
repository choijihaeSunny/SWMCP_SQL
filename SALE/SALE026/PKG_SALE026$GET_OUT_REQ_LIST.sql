CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_SALE026$GET_OUT_REQ_LIST`(	
	in A_COMP_ID VARCHAR(10),
	in A_ST_DATE DATETIME,
	in A_ED_DATE DATETIME,
	in A_CUST_CODE VARCHAR(100),
	in A_PJ_NO VARCHAR(100),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select distinct
		'N' as CHK,
		A.COMP_ID,
		str_to_date(A.SET_DATE,'%Y%m%d') as SET_DATE,
		A.SET_SEQ,
		A.SET_NO,
		A.OUT_REQ_MST_KEY,
		A.OUT_REQ_KEY,
		str_to_date(A.OUT_DATE,'%Y%m%d') as OUT_DATE,
		C.CUST_CODE,
		D.CUST_NAME,
		C.PJ_NO,
		E.PJ_NAME,
		E.SHIP_INFO,
		A.ITEM_CODE,
		B.ITEM_NAME,
		B.ITEM_SPEC,
		A.QTY,
		A.COST,
		A.AMT,
		A.REQ_KIND,
		str_to_date(A.DELI_DATE,'%Y%m%d') as DELI_DATE,
		A.CUST_REQ_RMK,
		A.PACK_SPEC,
		A.ASSY_YN,
		A.ASSY_YN as ASSY_LIST,
		A.CUST_ITEM_CODE,
		A.CUST_ORDER_NO,
		A.OUT_QTY,
		A.PACK_QTY,
		A.ASSY_QTY,
		A.ORDER_KEY,
		G.DEPT_CODE,
		G.WARE_CODE,
		A.RMK, 
		B.ITEM_KIND
	from TB_OUT_REQ_DET A
		inner join tb_item_code B on (A.ITEM_CODE = B.ITEM_CODE)
		inner join TB_OUT_REQ_MST C on (A.COMP_ID = C.COMP_ID and A.OUT_REQ_MST_KEY = C.OUT_REQ_MST_KEY)
		inner join tc_cust_code D on (C.COMP_ID = D.COMP_ID and C.CUST_CODE = D.CUST_CODE)
		left join tb_project E on (C.COMP_ID = E.COMP_ID and C.PJ_NO = E.PJ_CODE)
		inner join tb_order_det F on (A.COMP_ID = F.COMP_ID and A.ORDER_KEY = F.ORDER_KEY)
		inner join tb_order_mst G on (F.COMP_ID = G.COMP_ID and F.ORDER_MST_KEY = G.ORDER_MST_KEY)
		inner join tb_pack_work_det H on (A.COMP_ID = H.COMP_ID and A.OUT_REQ_KEY = H.OUT_REQ_KEY)
		left join tb_out_det Z on (A.COMP_ID = Z.COMP_ID and A.OUT_REQ_KEY = Z.OUT_REQ_KEY)
	where A.COMP_ID = A_COMP_ID 
	 	and A.OUT_DATE between date_format(A_ST_DATE, '%Y%m%d') and date_format(A_ED_DATE, '%Y%m%d')
	 	#and case when A_CUST_CODE != '' then FIND_IN_SET(C.CUST_CODE , A_CUST_CODE) else C.CUST_CODE like '%' end
	 	and C.CUST_CODE = A_CUST_CODE
	 	and C.PJ_NO = A_PJ_NO
	 	and A.ASSY_YN = 'N'
	 	and Z.OUT_KEY is null
	 union all
	 select distinct
		'N' as CHK,
		A.COMP_ID,
		str_to_date(A.SET_DATE,'%Y%m%d') as SET_DATE,
		A.SET_SEQ,
		A.SET_NO,
		A.OUT_REQ_MST_KEY,
		A.OUT_REQ_KEY,
		str_to_date(A.OUT_DATE,'%Y%m%d') as OUT_DATE,
		C.CUST_CODE,
		D.CUST_NAME,
		C.PJ_NO,
		E.PJ_NAME,
		E.SHIP_INFO,
		A.ITEM_CODE,
		B.ITEM_NAME,
		B.ITEM_SPEC,
		A.QTY,
		A.COST,
		A.AMT,
		A.REQ_KIND,
		str_to_date(A.DELI_DATE,'%Y%m%d') as DELI_DATE,
		A.CUST_REQ_RMK,
		A.PACK_SPEC,
		A.ASSY_YN,
		A.ASSY_YN as ASSY_LIST,
		A.CUST_ITEM_CODE,
		A.CUST_ORDER_NO,
		A.OUT_QTY,
		A.PACK_QTY,
		A.ASSY_QTY,
		A.ORDER_KEY,
		G.DEPT_CODE,
		G.WARE_CODE,
		A.RMK,
		B.ITEM_KIND
	from TB_OUT_REQ_DET A
		inner join tb_item_code B on (A.ITEM_CODE = B.ITEM_CODE)
		inner join TB_OUT_REQ_MST C on (A.COMP_ID = C.COMP_ID and A.OUT_REQ_MST_KEY = C.OUT_REQ_MST_KEY)
		inner join tc_cust_code D on (C.COMP_ID = D.COMP_ID and C.CUST_CODE = D.CUST_CODE)
		left join tb_project E on (C.COMP_ID = E.COMP_ID and C.PJ_NO = E.PJ_CODE)
		inner join tb_order_det F on (A.COMP_ID = F.COMP_ID and A.ORDER_KEY = F.ORDER_KEY)
		inner join tb_order_mst G on (F.COMP_ID = G.COMP_ID and F.ORDER_MST_KEY = G.ORDER_MST_KEY)
		inner join tb_assy_work_det H on (A.COMP_ID = H.COMP_ID and A.OUT_REQ_KEY = H.OUT_REQ_KEY)
		left join tb_out_det Z on (A.COMP_ID = Z.COMP_ID and A.OUT_REQ_KEY = Z.OUT_REQ_KEY)
	where A.COMP_ID = A_COMP_ID 
	 	and A.OUT_DATE between date_format(A_ST_DATE, '%Y%m%d') and date_format(A_ED_DATE, '%Y%m%d')
	 	#and case when A_CUST_CODE != '' then FIND_IN_SET(C.CUST_CODE , A_CUST_CODE) else C.CUST_CODE like '%' end
	 	and C.CUST_CODE = A_CUST_CODE
	 	and C.PJ_NO = A_PJ_NO
	 	and A.ASSY_YN = 'Y'
	 	and Z.OUT_KEY is null;
	
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end