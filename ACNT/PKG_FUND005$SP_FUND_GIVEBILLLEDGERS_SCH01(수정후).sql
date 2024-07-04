CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_FUND005$SP_FUND_GIVEBILLLEDGERS_SCH01`(
	in A_COMP_ID varchar(10),
	out N_RETURN INT,
	out V_RETURN VARCHAR(4000)
)
begin
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SELECT COMP_ID,
             str_to_date(PSS_DATE, '%Y%m%d%H%i%s') PSS_DATE,
--              (SELECT NAME
-- 					FROM sys_data 
-- 				  WHERE PATH = 'cfg.acnt.CC02'
--                  	and code =  BAL_BANK) as BAL_BANK_NM,
             (select cust_name from tc_cust_code  where cust_code = TBL_OUT_BILL.BAL_BANK) as BAL_BANK_NM,
             BAL_NO,
             CAST(FROM_NUMB as INTEGER) FROM_NUMB,
             CAST(TO_NUMB as INTEGER) TO_NUMB,
             NUMB_COUNT,
             BAL_BANK,
             str_to_date(PSS_DATE, '%Y%m%d%H%i%s') AS OLD_PSS_DATE,
             BAL_BANK AS OLD_BAL_BANK,
             BAL_NO AS OLD_BAL_NO,
             SYS_EMP_NO
        FROM TBL_OUT_BILL
       WHERE COMP_ID = A_COMP_ID;
      
    SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
END