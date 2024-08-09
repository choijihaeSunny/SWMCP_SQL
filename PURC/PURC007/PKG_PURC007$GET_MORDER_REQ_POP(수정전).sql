CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC007$GET_MORDER_REQ_POP`(	
	in A_COMP_ID VARCHAR(10),
	in A_ST_DATE DATETIME,
	in A_ED_DATE DATETIME,
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select 
		'N' as IS_CHECK,
		A.COMP_ID,
		str_to_date(A.SET_DATE,'%Y%m%d') as SET_DATE,
		A.SET_SEQ,
		A.SET_NO,
		A.MORDER_REQ_MST_KEY,
		A.MORDER_KIND,
		FN_SYS_DATA_NAME(A.MORDER_KIND) as MORDER_KIND_NM,
		str_to_date(A.ORDER_DATE,'%Y%m%d') as ORDER_DATE,
		A.ITEM_CODE,
		B.ITEM_KIND,
		B.ITEM_NAME,
		B.ITEM_SPEC,
		B.CUST_CODE_IN as CUST_CODE,
		F.CUST_NAME as CUST_NAME,
		A.REQ_QTY as QTY,
		Nvl(G.COST, 0) as COST,
		A.REQ_QTY * Nvl(G.COST, 0) as AMT,
		str_to_date(A.DELI_DATE,'%Y%m%d') as DELI_DATE,
		A.EMP_NO,
		C.KOR_NAME as EMP_NAME,
		A.DEPT_CODE,
		D.DEPT_NAME,
		A.WARE_CODE,
		E.SHIP_INFO,
		A.PJ_NO,
		E.PJ_NAME,
		A.ORDER_KEY,
		A.PRE_STOCK_KIND,
		FN_SYS_DATA_NAME(A.PRE_STOCK_KIND) as PRE_STOCK_KIND_NM,
		A.RMK
	from tb_morder_req_mst A
		inner join tb_item_code B on (A.ITEM_CODE = B.ITEM_CODE)
		left join insa_mst C on (A.COMP_ID = C.COMP_ID and A.EMP_NO = C.EMP_NO)
		left join dept_code D on (A.DEPT_CODE = D.DEPT_CODE)
		left join tb_project E on (A.PJ_NO = E.PJ_CODE)
		left join tc_cust_code F on (B.CUST_CODE_IN = F.CUST_CODE)
		left join item_price G on (A.ITEM_CODE = G.ITEM_CODE and B.CUST_CODE_IN = G.CUST_CODE and G.CUST_KIND = '1' and date_format(A_ED_DATE, '%Y%m%d') between G.APP_DATE and G.END_DATE) # 매입
	where A.COMP_ID = A_COMP_ID 
	 	and A.ORDER_DATE BETWEEN date_format(A_ST_DATE, '%Y%m%d') and date_format(A_ED_DATE, '%Y%m%d')
	 	and A.REQ_QTY > A.MORDER_QTY
	 	and A.MORDER_GUBUN = '1'
	 	and A.END_YN = 'N';
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end