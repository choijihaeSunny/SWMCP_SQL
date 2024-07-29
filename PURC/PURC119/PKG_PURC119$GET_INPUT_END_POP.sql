CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PURC119$GET_INPUT_END_POP`(	
	IN A_COMP_ID VARCHAR(10),
	IN A_ST_DATE TIMESTAMP,
	IN A_ED_DATE TIMESTAMP,
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select 
		  A.COMP_ID,
		  STR_TO_DATE(B.SET_DATE, '%Y%m%d') as SET_DATE,
		  B.CUST_CODE,
		  C.CUST_NAME,
		  B.EMP_NO,
		  B.DEPT_CODE,
		  A.ITEM_CODE,
		  I.ITEM_NAME,
		  A.QTY,
		  A.COST,
		  A.SUPP_AMT,
		  A.VAT,
		  A.CALL_KIND,
		  A.CALL_KEY,
		  A.ITEM_KIND,
		  A.RMKS,
		  (case
			   when CALL_KIND = 'INP' then '구매입고'
			   when CALL_KIND = 'RTN' then '입고반품'
			   when CALL_KIND = 'ETC' then '기타매입'
			   else '구매할인' -- when CALL_KIND = 'DIS'
		   end)
	from TB_INPUT_END_DET A
		inner join TB_INPUT_END B
			on (B.COMP_ID = A.COMP_ID
			and B.INPUT_END_KEY = A.INPUT_END_KEY)
		inner join TC_CUST_CODE C
			on (A.COMP_ID = C.COMP_ID
			and B.CUST_CODE = C.CUST_CODE)
		inner join TB_ITEM_CODE I
			on (A.ITEM_CODE = I.ITEM_CODE)
	;

	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
end