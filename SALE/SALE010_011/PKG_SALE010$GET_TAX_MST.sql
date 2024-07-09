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
		
		select distinct
			  '%' as DIV_MST
			  ,A.COMP_ID
			  ,STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE
			  ,A.CUST_CODE
			  ,C.CUST_NAME
			  
		from TB_TAX_MST A
			inner join TC_CUST_CODE C
				on (A.COMP_ID = C.COMP_ID
				and A.CUST_CODE = C.CUST_CODE)
			inner join TB_TAX_DET B
				on (A.COMP_ID = B.COMP_ID
				and A.TAX_NUMB = B.TAX_NUMB)
		where A.COMP_ID = A_COMP_ID
		  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
		  				     and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
		  and A.SALES_KIND = A_SALES_KIND
		;
		
	else -- if A_CREATE_YN = 'N' then -- 세금계산서가 아직 생성되지 않은 내역을 호출하는 경우
		/*
		if A_END_GUBUN = '0' then -- 합산마감인 경우 거래처별로 조회한다.
		
		elseif A_END_GUBUN = '1' then -- 개별마감일 경우 거래처별 + 매출 키값 별로 조회한다.
		
		end if;
		*/
	
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
			  ,A.OUT_MST_KEY as MASTER_KEY
		from TB_OUT_DET A
			inner join TB_OUT_MST B
				on (A.COMP_ID = B.COMP_ID
				and A.OUT_MST_KEY = B.OUT_MST_KEY)
		where A.COMP_ID = A_COMP_ID
		  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
		  				     and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
		  and A.TAX_YN = 'N'
		  and B.SALES_TYPE <> '168981'
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
			  ,A.OUT_MST_KEY as MASTER_KEY
		from TB_OUT_DET A
			inner join TB_OUT_MST B
				on (A.COMP_ID = B.COMP_ID
				and A.OUT_MST_KEY = B.OUT_MST_KEY)
		where A.COMP_ID = A_COMP_ID
		  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
		  				     and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
		  and A.TAX_YN = 'N'
		  and B.SALES_TYPE = '168981'
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
			  ,A.OUT_RETURN_MST_KEY as MASTER_KEY
		from TB_OUT_RETURN_DET A
			inner join TB_OUT_RETURN_MST B
				on (A.COMP_ID = B.COMP_ID
				and A.OUT_RETURN_MST_KEY = B.OUT_RETURN_MST_KEY)
		where A.COMP_ID = A_COMP_ID
		  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
		  				     and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
		  and A.TAX_YN = 'N'
		;
	end if; -- if A_CREATE_YN = 'Y' then end
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
end