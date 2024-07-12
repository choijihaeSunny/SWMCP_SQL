CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_SALE010$GET_TAX_DET`(	
	IN A_COMP_ID VARCHAR(10),
	IN A_TAX_NUMB VARCHAR(30),
	IN A_ST_DATE TIMESTAMP,
	IN A_ED_DATE TIMESTAMP,
	IN A_CREATE_YN VARCHAR(10), -- 생성구분 생성 미생성
	IN A_SALES_KIND VARCHAR(10), -- 매출구분 내수 1 수출 2
	IN A_END_GUBUN VARCHAR(10), -- 합산마감 0 /개별마감 1
	IN A_CUST_CODE VARCHAR(300), -- 거래처
	IN A_MASETR_KEY VARCHAR(50),
	IN A_GUBUN VARCHAR(30),
	IN A_SEARCH VARCHAR(10),
	
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	
	-- 리텍의 PKG_SALE_TAX.GET_TAX_D 참조
	
	if A_CREATE_YN = 'Y' then
		select
			  '' AS GUBUN
			  ,A.COMP_ID
			  ,A.TAX_NUMB
			  ,A.TAX_SEQ
			  ,STR_TO_DATE(A.ACT_DATE, '%Y%m%d') as SET_DATE
			  ,B.CUST_CODE
			  ,B.EMP_NO
			  ,B.DEPT_CODE
			  ,A.ITEM_CODE
			  ,A.QTY
			  ,A.COST
			  ,A.SUPP_AMT as AMT
			  ,A.VAT
			  ,A.CALL_KIND
			  ,A.CALL_KEY
			  ,A.DIFF_AMT
			  ,A.RMK
		from TB_TAX_DET A
			inner join TB_TAX_MST B 
				on (A.COMP_ID = B.COMP_ID
				and A.TAX_NUMB = B.TAX_NUMB)
			inner join TC_CUST_CODE C 
				on (A.COMP_ID = C.COMP_ID
				and B.CUST_CODE = C.CUST_CODE)
			inner join TB_ITEM_CODE I
				on (A.ITEM_CODE = I.ITEM_CODE)
		where A.COMP_ID = A_COMP_ID
		  and A.TAX_NUMB = A_TAX_NUMB
		order by A.TAX_SEQ
		;
	else
		select
			  X.GUBUN
			  ,X.COMP_ID
			  ,'' AS TAX_NUMB
			  ,'' AS TAX_SEQ
			  ,X.SET_DATE
			  ,X.CUST_CODE
			  ,X.EMP_NO
			  ,X.DEPT_CODE
			  ,X.ITEM_CODE
			  ,X.QTY
			  ,X.COST
			  ,X.AMT
			  ,X.VAT
			  ,'' as CALL_KIND
			  ,X.TABLE_KEY as CALL_KEY
			  ,0 as DIFF_AMT
			  ,X.RMK
		from (
			select 
				  '출고' as GUBUN
				  ,A.COMP_ID
				  ,A.OUT_MST_KEY as TABLE_KEY
				  ,STR_TO_DATE(B.SET_DATE, '%Y%m%d') as SET_DATE
				  ,B.CUST_CODE
				  ,B.EMP_NO 
				  ,B.DEPT_CODE 
				  ,A.ITEM_CODE
				  ,A.TAX_YN
				  ,A.QTY
				  ,A.COST
				  ,TRUNCATE(A.AMT / 1.1, 4) AS AMT
				  ,(A.AMT - TRUNCATE(A.AMT / 1.1, 4)) AS VAT
				  ,A.RMK
			from TB_OUT_DET A
				inner join TB_OUT_MST B 
					on (A.COMP_ID = B.COMP_ID
					and A.OUT_MST_KEY = B.OUT_MST_KEY)
			where A.COMP_ID = A_COMP_ID
			  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
					  		     and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
			  and B.SALES_TYPE not in (select DATA_ID
					  					 from SYS_DATA
					  					where PATH = 'cfg.sale.S06'
					  					  and CODE <> '02')
			union all
			select 
				  '원자재출고' as GUBUN
				  ,A.COMP_ID
				  ,A.OUT_MST_KEY as TABLE_KEY
				  ,STR_TO_DATE(B.SET_DATE, '%Y%m%d') as SET_DATE
				  ,B.CUST_CODE
				  ,B.EMP_NO 
				  ,B.DEPT_CODE 
				  ,A.ITEM_CODE
				  ,A.TAX_YN
				  ,A.QTY
				  ,A.COST
				  ,TRUNCATE(A.AMT / 1.1, 4) AS AMT
				  ,(A.AMT - TRUNCATE(A.AMT / 1.1, 4)) AS VAT
				  ,A.RMK
			from TB_OUT_DET A
				inner join TB_OUT_MST B 
					on (A.COMP_ID = B.COMP_ID
					and A.OUT_MST_KEY = B.OUT_MST_KEY)
			where A.COMP_ID = A_COMP_ID
			  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
					  		     and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
			  and B.SALES_TYPE not in (select DATA_ID
					  					 from SYS_DATA
					  					where PATH = 'cfg.sale.S06'
					  					  and CODE = '02')
			union all
			select 
				  '출고반품' as GUBUN
				  ,A.COMP_ID
				  ,A.OUT_RETURN_MST_KEY as TABLE_KEY
				  ,STR_TO_DATE(B.SET_DATE, '%Y%m%d') as SET_DATE
				  ,B.CUST_CODE
				  ,B.EMP_NO 
				  ,B.DEPT_CODE 
				  ,A.ITEM_CODE
				  ,A.TAX_YN
				  ,A.QTY
				  ,A.COST
				  ,TRUNCATE(A.AMT / 1.1, 4) AS AMT
				  ,(A.AMT - TRUNCATE(A.AMT / 1.1, 4)) AS VAT
				  ,A.RMK
			from TB_OUT_RETURN_DET A
				inner join TB_OUT_RETURN_MST B 
					on (A.COMP_ID = B.COMP_ID
					and A.OUT_RETURN_MST_KEY = B.OUT_RETURN_MST_KEY)
			where A.COMP_ID = A_COMP_ID
			  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
					  		     and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
		) X
			inner join TC_CUST_CODE C
				on (X.COMP_ID = C.COMP_ID
				and X.CUST_CODE = C.CUST_CODE)
			inner join TB_ITEM_CODE I
				on (X.ITEM_CODE = I.ITEM_CODE)
		where X.COMP_ID = A_COMP_ID
		;
	end if;

	
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
end