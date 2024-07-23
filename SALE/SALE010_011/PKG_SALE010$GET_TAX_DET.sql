CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_SALE010$GET_TAX_DET`(	
	IN A_COMP_ID VARCHAR(10),
	IN A_TAX_NUMB VARCHAR(30),
	IN A_ST_DATE TIMESTAMP,
	IN A_ED_DATE TIMESTAMP,
	IN A_CREATE_YN VARCHAR(10), -- 생성구분 생성 미생성
	IN A_SALES_KIND VARCHAR(10), -- 매출구분 cfg.sale.S02 내수 01 수출 02
	IN A_END_GUBUN VARCHAR(10), -- 합산마감 0 /개별마감 1
	IN A_CUST_CODE VARCHAR(300), -- 거래처
	IN A_MASETR_KEY VARCHAR(50),
	IN A_GUBUN VARCHAR(30),
	IN A_SEARCH VARCHAR(50),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	
	-- 리텍의 PKG_SALE_TAX.GET_TAX_D 참조
	
	if A_CREATE_YN = 'Y' then
	
		if A_END_GUBUN = '0' then -- 합산마감인 경우 거래처별로 조회한다.
		
			select
				  'N' as CHK
				  ,(
					case 
						when A.CALL_KIND = 'REQ' then '출고'
						else '출고반품' -- when A.CALL_KIND = 'RTN'
					END
				  ) AS GUBUN
				  ,A.COMP_ID
				  ,A.TAX_NUMB
				  ,A.TAX_SEQ
				  ,STR_TO_DATE(A.ACT_DATE, '%Y%m%d') as SET_DATE
				  ,B.CUST_CODE
				  ,C.CUST_NAME
				  ,B.EMP_NO
				  ,B.DEPT_CODE
				  ,A.ITEM_CODE
				  ,I.ITEM_NAME
				  ,A.QTY
				  ,A.COST
				  ,A.SUPP_AMT as AMT
				  ,A.VAT
				  ,(A.SUPP_AMT + A.VAT) as TOT_AMT
				  ,A.CALL_KIND
				  ,A.CALL_KEY
				  ,'' as DET_KEY
				  ,A.DIFF_AMT
				  ,A.RMK
				  ,'UPDATE' AS CUD_KEY
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
		else -- if A_END_GUBUN = '1' then -- 개별마감일 경우 거래처별 + 매출 키값 별로 조회한다.
		
			select 
				  'N' as CHK
				  ,(
					case 
						when A.CALL_KIND = 'REQ' then '출고'
						else '출고반품' -- when A.CALL_KIND = 'RTN'
					END
				  ) AS GUBUN
				  ,A.COMP_ID
				  ,A.TAX_NUMB
				  ,A.TAX_SEQ
				  ,STR_TO_DATE(A.ACT_DATE, '%Y%m%d') as SET_DATE
				  ,B.CUST_CODE
				  ,C.CUST_NAME
				  ,B.EMP_NO
				  ,B.DEPT_CODE
				  ,A.ITEM_CODE
				  ,I.ITEM_NAME
				  ,A.QTY
				  ,A.COST
				  ,A.SUPP_AMT as AMT
				  ,A.VAT
				  ,(A.SUPP_AMT + A.VAT) as TOT_AMT
				  ,A.CALL_KIND
				  ,A.CALL_KEY
				  ,'' as DET_KEY
				  ,A.DIFF_AMT
				  ,A.RMK
				  ,'UPDATE' AS CUD_KEY
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
			  and A.TAX_SEQ = A_SEARCH
			order by A.TAX_SEQ
			;
		end if;
		
	else -- if A_CREATE_YN = 'N' then
	
		if A_END_GUBUN = '0' then -- 합산마감인 경우 거래처별로 조회한다.
			select
				  'N' as CHK
				  ,X.GUBUN
				  ,X.COMP_ID
				  ,'' AS TAX_NUMB
				  ,'' AS TAX_SEQ
				  ,X.SET_DATE
				  ,X.CUST_CODE
				  ,C.CUST_NAME
				  ,X.EMP_NO
				  ,X.DEPT_CODE
				  ,X.ITEM_CODE
				  ,I.ITEM_NAME
				  ,X.QTY
				  ,X.COST
				  ,X.AMT
				  ,X.VAT
				  ,(X.AMT + X.VAT) as TOT_AMT
				  ,X.TABLE_KIND as CALL_KIND
				  ,X.TABLE_KEY as CALL_KEY
				  ,X.DET_KEY
				  ,0 as DIFF_AMT
				  ,X.RMK
				  ,'INSERT' as CUD_KEY
			from (
				select 
					  '출고' as GUBUN
					  ,A.COMP_ID
					  ,'REQ' as TABLE_KIND
					  ,A.OUT_MST_KEY as TABLE_KEY
					  ,A.OUT_KEY as DET_KEY
					  ,STR_TO_DATE(B.SET_DATE, '%Y%m%d') as SET_DATE
					  ,B.CUST_CODE
					  ,B.EMP_NO 
					  ,B.DEPT_CODE 
					  ,A.ITEM_CODE
					  ,A.TAX_YN
					  ,A.QTY
					  ,A.COST
					  ,A.AMT
					  ,TRUNCATE(A.AMT / 10, 4) AS VAT
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
					  ,'REQ' as TABLE_KIND
					  ,A.OUT_MST_KEY as TABLE_KEY
					  ,A.OUT_KEY as DET_KEY
					  ,STR_TO_DATE(B.SET_DATE, '%Y%m%d') as SET_DATE
					  ,B.CUST_CODE
					  ,B.EMP_NO 
					  ,B.DEPT_CODE 
					  ,A.ITEM_CODE
					  ,A.TAX_YN
					  ,A.QTY
					  ,A.COST
					  ,A.AMT
					  ,TRUNCATE(A.AMT / 10, 4) AS VAT
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
					  ,'RTN' as TABLE_KIND
					  ,A.OUT_RETURN_MST_KEY as TABLE_KEY
					  ,A.OUT_RETURN_KEY as DET_KEY
					  ,STR_TO_DATE(B.SET_DATE, '%Y%m%d') as SET_DATE
					  ,B.CUST_CODE
					  ,B.EMP_NO 
					  ,B.DEPT_CODE 
					  ,A.ITEM_CODE
					  ,A.TAX_YN
					  ,A.QTY
					  ,A.COST
					  ,A.AMT
					  ,TRUNCATE(A.AMT / 10, 4) AS VAT
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
			  and X.TAX_YN = 'N'
			  and X.CUST_CODE = A_CUST_CODE
			order by X.GUBUN, X.TABLE_KEY, X.ITEM_CODE
			;
		else -- if A_END_GUBUN = '1' then
			select
				  'N' as CHK
				  ,X.GUBUN
				  ,X.COMP_ID
				  ,'' AS TAX_NUMB
				  ,'' AS TAX_SEQ
				  ,X.SET_DATE
				  ,X.CUST_CODE
				  ,C.CUST_NAME
				  ,X.EMP_NO
				  ,X.DEPT_CODE
				  ,X.ITEM_CODE
				  ,I.ITEM_NAME
				  ,X.QTY
				  ,X.COST
				  ,X.AMT
				  ,X.VAT
				  ,(X.AMT + X.VAT) as TOT_AMT
				  ,X.TABLE_KIND as CALL_KIND
				  ,X.TABLE_KEY as CALL_KEY
				  ,X.DET_KEY
				  ,0 as DIFF_AMT
				  ,X.RMK
				  ,'INSERT' as CUD_KEY
			from (
				select 
					  '출고' as GUBUN
					  ,A.COMP_ID
					  ,'REQ' as TABLE_KIND
					  ,A.OUT_MST_KEY as TABLE_KEY
					  ,A.OUT_KEY as DET_KEY
					  ,STR_TO_DATE(B.SET_DATE, '%Y%m%d') as SET_DATE
					  ,B.CUST_CODE
					  ,B.EMP_NO 
					  ,B.DEPT_CODE 
					  ,A.ITEM_CODE
					  ,A.TAX_YN
					  ,A.QTY
					  ,A.COST
					  ,A.AMT
					  ,TRUNCATE(A.AMT / 10, 4) AS VAT
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
					  ,'REQ' as TABLE_KIND
					  ,A.OUT_MST_KEY as TABLE_KEY
					  ,A.OUT_KEY as DET_KEY
					  ,STR_TO_DATE(B.SET_DATE, '%Y%m%d') as SET_DATE
					  ,B.CUST_CODE
					  ,B.EMP_NO 
					  ,B.DEPT_CODE 
					  ,A.ITEM_CODE
					  ,A.TAX_YN
					  ,A.QTY
					  ,A.COST
					  ,A.AMT
					  ,TRUNCATE(A.AMT / 10, 4) AS VAT
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
					  ,'RTN' as TABLE_KIND
					  ,A.OUT_RETURN_MST_KEY as TABLE_KEY
					  ,A.OUT_RETURN_KEY as DET_KEY
					  ,STR_TO_DATE(B.SET_DATE, '%Y%m%d') as SET_DATE
					  ,B.CUST_CODE
					  ,B.EMP_NO 
					  ,B.DEPT_CODE 
					  ,A.ITEM_CODE
					  ,A.TAX_YN
					  ,A.QTY
					  ,A.COST
					  ,A.AMT
					  ,TRUNCATE(A.AMT / 10, 4) AS VAT
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
			  and X.TAX_YN = 'N'
			  and X.CUST_CODE = A_CUST_CODE
			  and X.TABLE_KEY = A_MASETR_KEY
			  and X.DET_KEY = A_SEARCH
			order by X.GUBUN, X.TABLE_KEY, X.ITEM_CODE
			;
		end if -- if A_END_GUBUN = '0' then end
		;
	
		
	end if -- if A_CREATE_YN = 'Y' then end
	; 

	
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
end