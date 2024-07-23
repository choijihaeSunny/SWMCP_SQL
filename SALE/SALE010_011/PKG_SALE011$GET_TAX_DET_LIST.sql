CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_SALE011$GET_TAX_DET_LIST`(	
	in A_COMP_ID VARCHAR(10),
	IN A_TAX_NUMB VARCHAR(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 


	select 
		  (
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
	
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
end