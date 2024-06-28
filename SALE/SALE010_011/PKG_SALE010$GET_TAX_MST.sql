CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_SALE010$GET_TAX_MST`(	
	in A_COMP_ID VARCHAR(10),
	in A_ST_DATE DATE,
	in A_ED_DATE DATE,
	in A_CUST_CODE VARCHAR(300),
	in A_SEARCH VARCHAR(10),
	in A_GUBUN VARCHAR(10),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	if A_SEARCH = 'N' then
		
		 
		select 
			'N' IS_CHK,
			'INSERT' CUD_KEY,
			A.OID,
			sysdate() as SET_DATE,
			'' as SET_SEQ,
			'' as VBILL_NUM,
			sysdate() as VBILL_DATE,
			A.CUST_CODE,
			B.CUST_NAME,
			A.END_AMT as TAX_AMT,
			A.END_AMT * 0.1 as TAX_VAT,
			A.END_AMT * 1.1 as TOT_AMT,
			
			'' as SEND_DIV,
			'1' as VBILL_DIV,
			A.END_AMT * 1.1 as T_ENG_AMT,
			E.CURR_UNIT as CURN_UNIT,
			E.EX_RATE as CURN_RATE,
			'' as RMK,
			'' as SLIP_NUMB,
			A.MODI_KEY,
			A.INSERT_ID,
			A.INSERT_DT,
			A.UPDATE_ID,
			A.UPDATE_DT
		from sale_send_end A 
			 inner join TC_CUST_CODE B on (A.CUST_CODE = B.CUST_CODE)
			 left join TC_CUST_CODE C on (A.SALE_CUST_CODE = C.CUST_CODE)
			 inner join sale_send D on (A.OID = D.END_OID and D.DELETE_YN = 'N')
			 inner join sale_order_det F on (D.ORDER_OID = F.OID)
    		 inner join sale_order_mst E on (F.MST_OID  = E.OID) 	
			 left join tax_det Z on (D.OID = Z.SEND_OID)
		where A.COMP_ID = A_COMP_ID
			and A.END_DATE between date_format(A_ST_DATE, '%Y%m%d') and date_format(A_ED_DATE, '%Y%m%d')
		 	and case when A_CUST_CODE != '' then FIND_IN_SET(A.CUST_CODE  , A_CUST_CODE) else A.CUST_CODE like '%' end
		 	and Z.OID is null
			and A.DELETE_YN = 'N'
		group by A.OID;
	
	else 
		SELECT 
			'N' IS_CHK,
			'UPDATE' CUD_KEY,
			A.COMP_ID,
			A.OID,
			str_to_date(A.SET_DATE, '%Y%m%d') as SET_DATE,
			A.SET_SEQ,
			A.VBILL_NUM,
			str_to_date(A.VBILL_DATE, '%Y%m%d') as VBILL_DATE,
			A.CUST_CODE,
			B.CUST_NAME,
			A.TAX_AMT,
			A.TAX_VAT,
			A.TAX_AMT + A.TAX_VAT as TOT_AMT,
			A.SEND_DIV,
			A.VBILL_DIV,
			A.T_ENG_AMT,
			A.CURN_UNIT,
			A.CURN_RATE,
			A.RMK,
			A.SLIP_NUMB,
			A.MODI_KEY,
			A.INSERT_ID,
			A.INSERT_DT,
			A.UPDATE_ID,
			A.UPDATE_DT
	    FROM   tax_mst A
	    		inner join TC_CUST_CODE B on (A.CUST_CODE = B.CUST_CODE)
	    WHERE 	A.COMP_ID = A_COMP_ID
	    	and A.VBILL_DATE BETWEEN date_format(A_ST_DATE, '%Y%m%d') and date_format(A_ED_DATE, '%Y%m%d')
		 	and case when A_CUST_CODE != '' then FIND_IN_SET(A.CUST_CODE  , A_CUST_CODE) else A.CUST_CODE like '%' end;
	
	end if;
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
end