CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_FUND006$SP_FUND_GIVEBILLS_SCH01`(
	in A_COMP_ID varchar(10),
	in A_BAL_DATE date,
	out N_RETURN INT,
	out V_RETURN VARCHAR(4000)
)
begin
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	
	SELECT A.COMP_ID,
             A.BILL_KIND,
             A.BANK_CODE,
--              (SELECT NAME
-- 					FROM sys_data 
-- 				  WHERE PATH = 'cfg.acnt.CC02'
--                  	and code =  A.BANK_CODE) as BANK_NAME,
             (select cust_name from tc_cust_code  where cust_code = A.BANK_CODE) as BANK_NAME,
             A.BILL_NO,
             A.BILL_AMT,
             str_to_date(A.END_DATE, '%Y%m%d%H%i%s') as END_DATE,
             A.CONT,
             A.CUST_CODE,
             (select cust_name
              from tc_cust_code
              where cust_code = A.CUST_CODE) as CUST_NAME,
             B.AC_NM4,
             B.AC_NAME,
             A.AC_CODE,
             str_to_date(A.BAL_SLIP_DATE,'%Y%m%d%H%i%s') as BAL_SLIP_DATE,
             A.BAL_SLIP_NO,
             str_to_date(A.END_SLIP_DATE,'%Y%m%d%H%i%s') as END_SLIP_DATE,
             A.END_SLIP_NO,
             A.BILL_NO AS OLD_BILL_NO,
             A.BAL_SLIP_NUMB,
             A.SYS_EMP_NO
       FROM TBL_OUT_BILL_DETA A, TBL_AC_CODE B
       WHERE     A.COMP_ID = A_COMP_ID
             AND A.BAL_DATE = date_format(A_BAL_DATE, '%Y%m%d')
             AND A.AC_CODE = B.AC_CODE;
            
    SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';       
END