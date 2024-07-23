CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_SALE011$GET_TAX_MST_LIST`(	
	in A_COMP_ID VARCHAR(10),
	in A_ST_DATE TIMESTAMP,
	in A_ED_DATE TIMESTAMP,
	in A_CUST_CODE VARCHAR(300),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 


    select distinct
    	  (
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
--       and A.SALES_KIND = A_SALES_KIND
      and A.CUST_CODE like CONCAT('%', A_CUST_CODE, '%')
    group by A.COMP_ID, A.CUST_CODE, A.EMP_NO, A.DEPT_CODE, A.RMK,
    		 A.SALES_KIND, B.ITEM_CODE, B.CALL_KIND
    order by A.CUST_CODE
    ;

	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
end