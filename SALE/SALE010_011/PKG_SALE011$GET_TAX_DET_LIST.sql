PKG_SALE011$GET_TAX_DET_LISTCREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_SALE011$GET_TAX_DET_LIST`(	
	in A_COMP_ID VARCHAR(10),
	in A_OID BIGINT(20),
	in A_CUST_CODE VARCHAR(300),
	in A_SEARCH VARCHAR(10),
	in A_GUBUN VARCHAR(10),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	SELECT 
		A.COMP_ID,
		A.OID,
		A.TAX_OID, 
		A.VBILL_NUM,
		str_to_date(A.SEND_DATE, '%Y%m%d') as SEND_DATE,
		str_to_date(E.SET_DATE, '%Y%m%d') as SET_DATE,
			E.SET_SEQ,
		A.CUST_CODE,
		B.CUST_NAME,
		A.PROD_ID,
		C.PROD_CD,
		C.PROD_NM,
		C.STAND_ID,
		C.SPEC_ID,
		C.COLOR_ID, 
		C.UNIT_ID,
		C.ETC_ID,
		FN_SYS_DATA_NAME(E.ORDER_KIND)  as ORDER_KIND,
		A.KIND,
		A.SUPP_QTY,
		A.SUPP_PRC,
		A.SUPP_AMT,
		A.SUPP_VAT,
		A.ENG_AMT,
		A.SEND_OID,
		A.MODI_KEY,
		A.INSERT_ID,
		A.INSERT_DT,
		A.UPDATE_ID,
		A.UPDATE_DT,
		Z.ORDER_NO
    FROM   tax_det A
    		inner join TC_CUST_CODE B on (A.CUST_CODE = B.CUST_CODE)
    		inner join PROD_MST C on (A.PROD_ID = C.PROD_ID)
    		inner join sale_send Z  on (A.SEND_OID = Z.OID)
	    	inner join sale_order_det D on (Z.ORDER_OID = D.OID)
    		inner join sale_order_mst E on (D.MST_OID  = E.OID) 	
    WHERE 	A.COMP_ID = A_COMP_ID
    	and A.TAX_OID = A_OID
	 	and case when A_CUST_CODE != '' then FIND_IN_SET(A.CUST_CODE  , A_CUST_CODE) else A.CUST_CODE like '%' end;
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
end