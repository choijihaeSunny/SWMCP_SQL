CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PURC120$GET_OUTSIDE_END_DET`(	
	IN A_COMP_ID VARCHAR(10),
	IN A_CUST_CODE VARCHAR(10),
	IN A_CALL_KEY VARCHAR(30),
	IN A_ST_DATE TIMESTAMP,
	IN A_ED_DATE TIMESTAMP,
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	-- TB_INPUT_OUTSIDE (외주가공입고)
	-- TB_OUTSIDE_RETURN (외주가공재고반품등록)
	-- TB_OUTSIDE_RETURN_INPUT (외주가공재고반품입고)

	select 
		  'N' as CHK
		  ,X.DIV_MST
		  ,X.COMP_ID
		  ,X.SET_DATE
		  ,X.CUST_CODE
		  ,C.CUST_NAME
		  ,X.ITEM_CODE
		  ,I.ITEM_NAME
		  ,I.ITEM_SPEC
		  ,I.ITEM_KIND
		  ,X.QTY
		  ,X.COST
		  ,X.AMT
		  ,X.VAT
		  ,X.CALL_KIND
		  ,X.CALL_KEY
		  ,'' as RMKS
	from (
		select 
			  '외주가공입고' as DIV_MST
			  ,A.COMP_ID
			  ,STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE
			  ,A.CUST_CODE
	-- 	  	  ,A.DEPT_CODE
			  ,A.ITEM_CODE
			  ,A.QTY
			  ,A.COST
			  ,A.AMT
			  ,TRUNCATE(A.AMT / 10, 4) AS VAT
			  ,'INP' as CALL_KIND
			  ,A.INPUT_OUTSIDE_KEY as CALL_KEY
		from TB_INPUT_OUTSIDE A
		where A.COMP_ID = A_COMP_ID
		  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
						  	 	 and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
		union all 
		select 
			  '외주가공재고반품' as DIV_MST
			  ,A.COMP_ID
			  ,STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE
			  ,A.CUST_CODE
	-- 	  	  ,A.DEPT_CODE
			  ,A.ITEM_CODE
			  ,A.QTY
			  ,A.COST
			  ,A.AMT
			  ,TRUNCATE(A.AMT / 10, 4) AS VAT
			  ,'RTN' as CALL_KIND
			  ,A.OUT_RETURN_KEY as CALL_KEY
		from TB_OUTSIDE_RETURN A
		where A.COMP_ID = A_COMP_ID
		  and A.SET_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d')
						  	 	 and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
		union all 
		select 
			  '외주가공재고반품입고' as DIV_MST
			  ,A.COMP_ID
			  ,STR_TO_DATE(A.SET_DATE, '%Y%m%d') as SET_DATE
			  ,A.CUST_CODE
	-- 	  	  ,A.DEPT_CODE
			  ,A.ITEM_CODE
			  ,A.QTY
			  ,A.COST
			  ,A.AMT
			  ,TRUNCATE(A.AMT / 10, 4) AS VAT
			  ,'RIN' as CALL_KIND
			  ,A.OUT_RETURN_INPUT_KEY as CALL_KEY
		from TB_OUTSIDE_RETURN_INPUT A
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
	and X.CUST_CODE = A_CUST_CODE
	and X.CALL_KEY = A_CALL_KEY
	order by X.DIV_MST, X.CALL_KEY, X.ITEM_CODE
	;

	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
end