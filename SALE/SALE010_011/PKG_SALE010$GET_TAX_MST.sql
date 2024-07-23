CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_SALE010$GET_TAX_MST`(	
	IN A_COMP_ID VARCHAR(10),
	IN A_ST_DATE TIMESTAMP,
	IN A_ED_DATE TIMESTAMP,
	IN A_CREATE_YN VARCHAR(10), -- 생성구분 생성 미생성
	IN A_SALES_KIND VARCHAR(10), -- 매출구분 내수 1 수출 2
	IN A_END_GUBUN VARCHAR(10), -- 합산마감 0 /개별마감 1
	IN A_CUST_CODE VARCHAR(300), -- 거래처
	IN A_SEARCH VARCHAR(10),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begIN
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	

	-- 리텍의 PKG_SALE_TAX.GET_TAX_M 참조
	
	if A_CREATE_YN = 'Y' then -- 생성된 세금계산서를 호출하는 경우
		
		if A_END_GUBUN = '0' then -- 합산마감인 경우 거래처별로 조회한다.
		
			select distinct
				  'N' as CHK
-- 				  ,'' AS DIV_MST
				  ,(
				  	case 
					  	when B.CALL_KIND = 'REQ' then '출고'
					  	else '반품' -- when B.CALL_KIND = 'RTN'
					END
				  ) as DIV_MST
				  ,A.COMP_ID
				  ,A.TAX_NUMB
				  ,STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE
				  ,A.CUST_CODE
				  ,C.CUST_NAME
				  ,C.CUST_NUMB
				  ,A.EMP_NO
				  ,A.DEPT_CODE
				  ,A.RMK
				  ,A.TAX_REQ
				  ,A.SALES_KIND as SALES_TYPE
				  ,B.ITEM_CODE
				  ,I.ITEM_NAME
				  ,SUM(B.QTY) as QTY
				  ,SUM(B.COST) as COST
				  ,SUM(B.SUPP_AMT) as AMT
				  ,SUM(B.VAT) as VAT
				  ,(SUM(B.SUPP_AMT) + SUM(B.VAT)) as TOT_AMT
				  ,'' AS MASTER_KEY
				  ,B.TAX_SEQ as DET_KEY
				  ,'UPDATE' AS CUD_KEY
			from TB_TAX_MST A
				inner join TC_CUST_CODE C
					on (A.COMP_ID = C.COMP_ID
					and A.CUST_CODE = C.CUST_CODE)
				inner join TB_TAX_DET B
					on (A.COMP_ID = B.COMP_ID
					and A.TAX_NUMB = B.TAX_NUMB)
				inner join TB_ITEM_CODE I
						on (B.ITEM_CODE = I.ITEM_CODE)
			where A.COMP_ID = A_COMP_ID
			  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
			  				     and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
			  and A.SALES_KIND = A_SALES_KIND
			  and A.CUST_CODE like CONCAT('%', A_CUST_CODE, '%')
			group by A.COMP_ID, A.CUST_CODE, B.CALL_KIND
			order by A.CUST_CODE
			;
		else -- if A_END_GUBUN = '1' then -- 개별마감일 경우 거래처별 + 매출 키값 별로 조회한다.
		
			select distinct
				  'N' as CHK
-- 				  ,'' AS DIV_MST
				  ,(
				  	case 
					  	when B.CALL_KIND = 'REQ' then '출고'
					  	else '반품' -- when B.CALL_KIND = 'RTN'
					END
				  ) as DIV_MST
				  ,A.COMP_ID
				  ,A.TAX_NUMB
				  ,STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE
				  ,A.CUST_CODE
				  ,C.CUST_NAME
				  ,C.CUST_NUMB
				  ,A.EMP_NO
				  ,A.DEPT_CODE
				  ,A.RMK
				  ,A.TAX_REQ
				  ,A.SALES_KIND as SALES_TYPE
				  ,B.ITEM_CODE
				  ,I.ITEM_NAME
				  ,SUM(B.QTY) as QTY
				  ,SUM(B.COST) as COST
				  ,SUM(B.SUPP_AMT) as AMT
				  ,SUM(B.VAT) as VAT
				  ,(SUM(B.SUPP_AMT) + SUM(B.VAT)) as TOT_AMT
				  ,'' AS MASTER_KEY
				  ,B.TAX_SEQ as DET_KEY
				  ,'UPDATE' AS CUD_KEY
			from TB_TAX_MST A
				inner join TC_CUST_CODE C
					on (A.COMP_ID = C.COMP_ID
					and A.CUST_CODE = C.CUST_CODE)
				inner join TB_TAX_DET B
					on (A.COMP_ID = B.COMP_ID
					and A.TAX_NUMB = B.TAX_NUMB)
				inner join TB_ITEM_CODE I
						on (B.ITEM_CODE = I.ITEM_CODE)
			where A.COMP_ID = A_COMP_ID
			  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
			  				     and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
			  and A.SALES_KIND = A_SALES_KIND
			  and A.CUST_CODE like CONCAT('%', A_CUST_CODE, '%')
			group by A.COMP_ID, A.CUST_CODE, A.EMP_NO, A.DEPT_CODE, A.RMK,
					 A.SALES_KIND, B.ITEM_CODE, B.CALL_KIND
			order by A.CUST_CODE
			;
		end if
		;	
	else -- if A_CREATE_YN = 'N' then -- 세금계산서가 아직 생성되지 않은 내역을 호출하는 경우
		
		if A_END_GUBUN = '0' then -- 합산마감인 경우 거래처별로 조회한다.
		
			select 
				  'N' as CHK
			  	  ,X.DIV_MST
				  ,X.COMP_ID
				  ,'' AS TAX_NUMB
				  ,date_format('', '%Y%m%d') as SET_DATE
				  ,X.CUST_CODE
				  ,C.CUST_NAME
				  ,C.CUST_NUMB
				  ,X.EMP_NO
				  ,X.DEPT_CODE
				  ,X.RMK
				  ,(
				  	select DATA_ID
				    from SYS_DATA
				    where path = 'cfg.sale.S07'
				    and CODE = 'REQ'
				  ) as TAX_REQ
				  ,X.SALES_TYPE
				  ,X.ITEM_CODE
				  ,I.ITEM_NAME
				  ,SUM(X.QTY) as QTY
				  ,SUM(X.COST) as COST
				  ,SUM(X.AMT) as AMT
				  ,SUM(X.VAT) as VAT
				  ,(SUM(X.AMT) + SUM(X.VAT)) as TOT_AMT
				  ,X.MASTER_KEY
				  ,X.DET_KEY
				  ,'INSERT' as CUD_KEY
			from (
				select
					  '출고' as DIV_MST
					  ,A.COMP_ID
					  ,STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE
					  ,B.CUST_CODE
					  ,B.EMP_NO
					  ,B.DEPT_CODE
					  ,B.RMK
					  ,B.SALES_TYPE
					  ,A.ITEM_CODE
					  ,A.QTY
					  ,A.COST
					  ,A.AMT
					  ,TRUNCATE(A.AMT / 10, 4) AS VAT
					  ,A.OUT_MST_KEY as MASTER_KEY
					  ,A.OUT_KEY as DET_KEY
				from TB_OUT_DET A
					inner join TB_OUT_MST B
						on (A.COMP_ID = B.COMP_ID
						and A.OUT_MST_KEY = B.OUT_MST_KEY)
				where A.COMP_ID = A_COMP_ID
				  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
				  				     and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
				  and A.TAX_YN = 'N'
				  and B.SALES_TYPE in (select DATA_ID
						  				 from SYS_DATA
						  				where PATH = 'cfg.sale.S06'
						  				  and CODE <> '02')
				union all 
				select
					  '원자재출고' as DIV_MST
					  ,A.COMP_ID
					  ,STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE
					  ,B.CUST_CODE
					  ,B.EMP_NO
					  ,B.DEPT_CODE
					  ,B.RMK
					  ,B.SALES_TYPE
					  ,A.ITEM_CODE
					  ,A.QTY
					  ,A.COST
					  ,A.AMT
					  ,TRUNCATE(A.AMT / 10, 4) AS VAT
					  ,A.OUT_MST_KEY as MASTER_KEY
					  ,A.OUT_KEY as DET_KEY
				from TB_OUT_DET A
					inner join TB_OUT_MST B
						on (A.COMP_ID = B.COMP_ID
						and A.OUT_MST_KEY = B.OUT_MST_KEY)
				where A.COMP_ID = A_COMP_ID
				  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
				  				     and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
				  and A.TAX_YN = 'N'
				  and B.SALES_TYPE = (select DATA_ID
						  			  from SYS_DATA
						  			  where PATH = 'cfg.sale.S06'
						  			  and CODE = '02')
				union all 
				select
					  '출고반품' as DIV_MST
					  ,A.COMP_ID
					  ,STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE
					  ,B.CUST_CODE
					  ,B.EMP_NO
					  ,B.DEPT_CODE
					  ,B.RMK
					  ,B.SALES_TYPE
					  ,A.ITEM_CODE
					  ,A.QTY
					  ,A.COST
					  ,A.AMT
					  ,TRUNCATE(A.AMT / 10, 4) AS VAT
					  ,A.OUT_RETURN_MST_KEY as MASTER_KEY
					  ,A.OUT_RETURN_KEY as DET_KEY
				from TB_OUT_RETURN_DET A
					inner join TB_OUT_RETURN_MST B
						on (A.COMP_ID = B.COMP_ID
						and A.OUT_RETURN_MST_KEY = B.OUT_RETURN_MST_KEY)
				where A.COMP_ID = A_COMP_ID
				  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
				  				     and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
				  and A.TAX_YN = 'N'
			) X
				inner join TC_CUST_CODE C 
					on (X.COMP_ID = C.COMP_ID
					and X.CUST_CODE = C.CUST_CODE)
				inner join TB_ITEM_CODE I
					on (X.ITEM_CODE = I.ITEM_CODE)
			where X.COMP_ID = A_COMP_ID		
			  and X.CUST_CODE like CONCAT('%', A_CUST_CODE, '%')
			group by X.DIV_MST, X.COMP_ID, X.CUST_CODE -- 거래처별로 합산한다.
			order by X.CUST_CODE
			;
		else -- if A_END_GUBUN = '1' then -- 개별마감일 경우 거래처별 + 매출 키값 별로 조회한다.
		
			select 
				  'N' as CHK
			  	  ,X.DIV_MST
				  ,X.COMP_ID
				  ,'' AS TAX_NUMB
				  ,X.SET_DATE
				  ,X.CUST_CODE
				  ,C.CUST_NAME
				  ,C.CUST_NUMB
				  ,X.EMP_NO
				  ,X.DEPT_CODE
				  ,X.RMK
				  ,(
				  	select DATA_ID
				    from SYS_DATA
				    where path = 'cfg.sale.S07'
				    and CODE = 'REQ'
				  ) as TAX_REQ
				  ,X.SALES_TYPE
				  ,X.ITEM_CODE
				  ,I.ITEM_NAME
				  ,SUM(X.QTY) as QTY
				  ,SUM(X.COST) as COST
				  ,SUM(X.AMT) as AMT
				  ,SUM(X.VAT) as VAT
				  ,(SUM(X.AMT) + SUM(X.VAT)) as TOT_AMT
				  ,X.MASTER_KEY
				  ,X.DET_KEY
				  ,'INSERT' as CUD_KEY
			from (
				select
					  '출고' as DIV_MST
					  ,A.COMP_ID
					  ,STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE
					  ,B.CUST_CODE
					  ,B.EMP_NO
					  ,B.DEPT_CODE
					  ,B.RMK
					  ,B.SALES_TYPE
					  ,A.ITEM_CODE
					  ,A.QTY
					  ,A.COST
					  ,A.AMT
					  ,TRUNCATE(A.AMT / 10, 4) AS VAT
					  ,A.OUT_MST_KEY as MASTER_KEY
					  ,A.OUT_KEY as DET_KEY
				from TB_OUT_DET A
					inner join TB_OUT_MST B
						on (A.COMP_ID = B.COMP_ID
						and A.OUT_MST_KEY = B.OUT_MST_KEY)
				where A.COMP_ID = A_COMP_ID
				  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
				  				     and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
				  and A.TAX_YN = 'N'
				  and B.SALES_TYPE in (select DATA_ID
						  				 from SYS_DATA
						  				where PATH = 'cfg.sale.S06'
						  				  and CODE <> '02')
				union all 
				select
					  '원자재출고' as DIV_MST
					  ,A.COMP_ID
					  ,STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE
					  ,B.CUST_CODE
					  ,B.EMP_NO
					  ,B.DEPT_CODE
					  ,B.RMK
					  ,B.SALES_TYPE
					  ,A.ITEM_CODE
					  ,A.QTY
					  ,A.COST
					  ,A.AMT
					  ,TRUNCATE(A.AMT / 10, 4) AS VAT
					  ,A.OUT_MST_KEY as MASTER_KEY
					  ,A.OUT_KEY as DET_KEY
				from TB_OUT_DET A
					inner join TB_OUT_MST B
						on (A.COMP_ID = B.COMP_ID
						and A.OUT_MST_KEY = B.OUT_MST_KEY)
				where A.COMP_ID = A_COMP_ID
				  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
				  				     and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
				  and A.TAX_YN = 'N'
				  and B.SALES_TYPE = (select DATA_ID
						  			  from SYS_DATA
						  			  where PATH = 'cfg.sale.S06'
						  			  and CODE = '02')
				union all 
				select
					  '출고반품' as DIV_MST
					  ,A.COMP_ID
					  ,STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE
					  ,B.CUST_CODE
					  ,B.EMP_NO
					  ,B.DEPT_CODE
					  ,B.RMK
					  ,B.SALES_TYPE
					  ,A.ITEM_CODE
					  ,A.QTY
					  ,A.COST
					  ,A.AMT
					  ,TRUNCATE(A.AMT / 10, 4) AS VAT
					  ,A.OUT_RETURN_MST_KEY as MASTER_KEY
					  ,A.OUT_RETURN_KEY as DET_KEY
				from TB_OUT_RETURN_DET A
					inner join TB_OUT_RETURN_MST B
						on (A.COMP_ID = B.COMP_ID
						and A.OUT_RETURN_MST_KEY = B.OUT_RETURN_MST_KEY)
				where A.COMP_ID = A_COMP_ID
				  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
				  				     and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
				  and A.TAX_YN = 'N'
			) X
				inner join TC_CUST_CODE C 
					on (X.COMP_ID = C.COMP_ID
					and X.CUST_CODE = C.CUST_CODE)
				inner join TB_ITEM_CODE I
					on (X.ITEM_CODE = I.ITEM_CODE)
			where X.COMP_ID = A_COMP_ID		
			  and X.CUST_CODE like CONCAT('%', A_CUST_CODE, '%')
			group by X.DIV_MST, X.COMP_ID, /*X.SET_DATE,*/ X.CUST_CODE, X.EMP_NO, 
					 X.DEPT_CODE, X.RMK, X.SALES_TYPE, X.ITEM_CODE, X.MASTER_KEY
			order by X.CUST_CODE, X.DIV_MST, X.MASTER_KEY
			;
		end if; -- if A_END_GUBUN = '0' then end
	end if; -- if A_CREATE_YN = 'Y' then end
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
end