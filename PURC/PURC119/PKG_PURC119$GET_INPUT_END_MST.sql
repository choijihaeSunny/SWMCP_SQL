CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PURC119$GET_INPUT_END_MST`(	
	IN A_COMP_ID VARCHAR(10),
	IN A_SAVED_YN VARCHAR(1),
	IN A_ST_DATE TIMESTAMP,
	IN A_ED_DATE TIMESTAMP,
	IN A_SET_DATE TIMESTAMP,
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	-- TB_INPUT_MST (구매입고)
	-- TB_INPUT_RETURN_MST (구매반품)
	-- 		TB_INPUT_RETURN_DET
	-- TB_INPUT_ETC_MST (구매기타)
	-- 		TB_INPUT_ETC_DET
	-- TB_INPUT_DISCOUNT (구매할인)

	if A_SAVED_YN = 'Y' then
	
		select distinct 
			'N' as CHK
			,(
			  case 
				  when B.CALL_KIND = 'INP' then '구매입고'
				  when B.CALL_KIND = 'RTN' then '입고반품'
				  when B.CALL_KIND = 'ETC' then '기타매입'
				  else '구매할인' -- when B.CALL_KIND = 'DIS'
			  END
			) as DIV_MST
			,A.COMP_ID
			,STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE
			,A.CUST_CODE
			,C.CUST_NAME
			,A.EMP_NO
			,A.DEPT_CODE
			,B.ITEM_CODE
			,SUM(B.QTY) as QTY
			,SUM(B.COST) as COST
			,SUM(B.SUPP_AMT) as AMT
			,SUM(B.VAT) as VAT
			,(SUM(B.SUPP_AMT) + SUM(B.VAT)) as TOT_AMT
			,B.CALL_KEY
			,'' as MST_KEY
			,A.RMKS
			,A.INPUT_END_KEY
		from TB_INPUT_END A
			inner join TB_INPUT_END_DET B
				on (A.COMP_ID = B.COMP_ID
				and A.INPUT_END_KEY = B.INPUT_END_KEY)
			inner join TC_CUST_CODE C
				on (A.COMP_ID = B.COMP_ID
				and A.CUST_CODE = C.CUST_CODE)
		where A.COMP_ID = A_COMP_ID
		  and A.SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d')
		;
	else -- if A_SAVED_YN = 'N' THEN
		
		select 
			  'N' as CHK
			  ,X.DIV_MST
			  ,X.COMP_ID
			  ,X.SET_DATE
			  ,X.CUST_CODE
			  ,C.CUST_NAME
			  ,X.EMP_NO
			  ,X.DEPT_CODE
			  ,X.ITEM_CODE
			  ,SUM(X.QTY) as QTY
			  ,SUM(X.COST) as COST
			  ,SUM(X.AMT) as AMT
			  ,SUM(X.VAT) as VAT
			  ,(SUM(X.AMT) + SUM(X.VAT)) as TOT_AMT
			  ,X.CALL_KEY
			  ,X.MST_KEY
			  ,'' as RMKS
			  ,'' as INPUT_END_KEY
		from (
			select 
				  '구매입고' as DIV_MST
				  ,A.COMP_ID
				  ,STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE
				  ,A.CUST_CODE
				  ,A.EMP_NO
				  ,A.DEPT_CODE
				  ,A.ITEM_CODE
				  ,A.QTY
				  ,A.COST
				  ,A.AMT
				  ,TRUNCATE(A.AMT / 10, 4) AS VAT
				  ,A.INPUT_MST_KEY as CALL_KEY
				  ,A.INPUT_MST_KEY as MST_KEY
			from TB_INPUT_MST A
			where A.COMP_ID = A_COMP_ID
			  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
						  	 	 and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
			  and A.END_AMT = 0
			union all 
			select
				  '입고반품' as DIV_MST
				  ,A.COMP_ID
				  ,STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE
				  ,B.CUST_CODE
				  ,B.EMP_NO
				  ,B.DEPT_CODE
				  ,A.ITEM_CODE
				  ,A.QTY
				  ,A.COST
				  ,A.AMT
				  ,TRUNCATE(A.AMT / 10, 4) AS VAT
				  ,A.INPUT_RETURN_KEY as CALL_KEY
				  ,A.INPUT_RETURN_MST_KEY as MST_KEY
			from TB_INPUT_RETURN_DET A
				inner join TB_INPUT_RETURN_MST B
					on (A.COMP_ID = B.COMP_ID
					and A.INPUT_RETURN_MST_KEY = B.INPUT_RETURN_MST_KEY)
			where A.COMP_ID = A_COMP_ID
			  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
						  	 	 and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
			  and A.END_AMT = 0
			union all 
			select
				  '기타매입' as DIV_MST
				  ,A.COMP_ID
				  ,STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE
				  ,B.CUST_CODE
				  ,B.EMP_NO
				  ,B.DEPT_CODE
				  ,A.ITEM_CODE
				  ,A.QTY
				  ,A.COST
				  ,A.AMT
				  ,TRUNCATE(A.AMT / 10, 4) AS VAT
				  ,A.INPUT_ETC_KEY as CALL_KEY
				  ,A.INPUT_ETC_MST_KEY as MST_KEY
			from TB_INPUT_ETC_DET A
				inner join TB_INPUT_ETC_MST B
					on (A.COMP_ID = B.COMP_ID
					and A.INPUT_ETC_MST_KEY = B.INPUT_ETC_MST_KEY)
			where A.COMP_ID = A_COMP_ID
			  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
						  	 	 and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
			  and A.END_AMT = 0
			/*union all 
			select 
				  '구매할인' as DIV_MST
				  ,A.COMP_ID
				  ,STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE
				  ,A.CUST_CODE
				  ,A.EMP_NO
				  ,A.DEPT_CODE
				  ,A.ITEM_CODE
				  ,A.QTY
				  ,A.COST
				  ,A.AMT
				  ,TRUNCATE(A.AMT / 10, 4) AS VAT
				  ,A.DS_KEY as CALL_KEY
				  ,A.DS_KEY as MST_KEY
			from TB_INPUT_DISCOUNT A
			where A.COMP_ID = A_COMP_ID
			  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
						  	 	 and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
			  and A.END_AMT = 0*/
		) X
			inner join TC_CUST_CODE C
				on (X.COMP_ID = C.COMP_ID
				and X.CUST_CODE = C.CUST_CODE)
		where X.COMP_ID = A_COMP_ID
		group by X.COMP_ID, X.CUST_CODE, X.MST_KEY
		order by X.CUST_CODE
		;
	end if;
	
	


	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
end