CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_FUND004$SP_FUND_RECEIVEBILLSTMTS_SCH01`(
	in A_COMP_ID varchar(10),
	in A_FROM_DATE date,
	in A_TO_DATE date,
	in A_BILL_NO varchar(30),
	in A_BANK_NAME varchar(30),
	in A_CREATE_KIND varchar(1),
	out N_RETURN INT,
	out V_RETURN VARCHAR(4000)
)
begin
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	
	if A_CREATE_KIND = '0' then
	
		SELECT '1' AS CHK_SLIP,                                  
                A.BILL_NO,
                (SELECT NAME 
                   FROM sys_data 
                  WHERE PATH = 'cfg.acnt.B08'
	                and CODE = A.BILL_TYPE ) as BILL_TYPE_NM, 
                str_to_date(A.BAL_DATE, '%Y%m%d%H%i%s') BAL_DATE,
                str_to_date(A.END_DATE, '%Y%m%d%H%i%s') END_DATE,
                A.BILL_AMT,
                A.BAL_BANK,
--                 (SELECT NAME
-- 					FROM sys_data 
-- 				  WHERE PATH = 'cfg.acnt.CC02'
--                  	and code = A.BAL_BANK) as BAL_BANK_NM,
--                 (SELECT NAME
-- 					FROM sys_data 
-- 				  WHERE PATH = 'cfg.acnt.CC02'
--                  	and code = A.TRUST_BANK) as TRUST_BANK_NM,
                 (select cust_name from tc_cust_code  where cust_code = A.BAL_BANK) as BAL_BANK_NM,
                 (select cust_name from tc_cust_code  where cust_code = A.TRUST_BANK) as TRUST_BANK_NM,
                '' AS SLIP_DATE,
                '' AS SLIP_NO,
                A.SLIP_NUMB,
                A.CUST_CODE,
                (select cust_name
	             from tc_cust_code
	             where cust_code = A.CUST_CODE limit 1) as CUST_NAME,
                A.TRUST_BANK,
                A.ENDOR_CONT,
                A.AC_NO,
                CONCAT(A.BILL_NO, '만기(', str_to_date(A.END_DATE,'%Y%m%d%H%i%s'), ')') as SLIP_CONT
          FROM TBL_BILLS_RECEIVABLE A
          WHERE     A.COMP_ID = A_COMP_ID
                AND A.END_DATE BETWEEN date_format(A_FROM_DATE, '%Y%m%d') AND date_format(A_TO_DATE, '%Y%m%d')
                AND A.BILL_NO LIKE CONCAT('%', A_BILL_NO, '%')
                AND A.SLIP_NUMB != ''
               ;
               
	else
	
		SELECT '0' AS CHK_SLIP,                                  
                 A.BILL_NO,
                (SELECT NAME 
                   FROM sys_data 
                  WHERE PATH = 'cfg.acnt.B08'
	                and CODE =  A.BILL_TYPE ) as BILL_TYPE_NM, 
                str_to_date(A.BAL_DATE, '%Y%m%d%H%i%s') BAL_DATE,
                str_to_date(A.END_DATE, '%Y%m%d%H%i%s') END_DATE,
                A.BILL_AMT,
                A.BAL_BANK,
--                 (SELECT NAME
-- 					FROM sys_data 
-- 				  WHERE PATH = 'cfg.acnt.CC02'
--                  	and code = A.BAL_BANK) as BAL_BANK_NM,
--                 (SELECT NAME
-- 					FROM sys_data 
-- 				  WHERE PATH = 'cfg.acnt.CC02'
--                  	and code = A.TRUST_BANK) as TRUST_BANK_NM,
                 (select cust_name from tc_cust_code  where cust_code = A.BAL_BANK) as BAL_BANK_NM,
                 (select cust_name from tc_cust_code  where cust_code = A.TRUST_BANK) as TRUST_BANK_NM,
                '' AS SLIP_DATE,
                '' AS SLIP_NO,
                A.SLIP_NUMB,
                A.CUST_CODE,
                (select cust_name
	             from tc_cust_code
	             where cust_code = A.CUST_CODE limit 1) as CUST_NAME,
                A.TRUST_BANK,
                A.ENDOR_CONT,
                A.AC_NO,
                CONCAT(A.BILL_NO, '만기(', str_to_date(A.END_DATE,'%Y%m%d%H%i%s'), ')') as SLIP_CONT
           FROM TBL_BILLS_RECEIVABLE A
          WHERE     A.COMP_ID = A_COMP_ID
                AND A.END_DATE BETWEEN date_format(A_FROM_DATE, '%Y%m%d') AND date_format(A_TO_DATE, '%Y%m%d')
                AND A.BILL_NO LIKE CONCAT('%', A_BILL_NO, '%')
                AND A.SLIP_NUMB = ''
               ;
               
	end if;
   SET N_RETURN = 0;
   SET V_RETURN = '조회되었습니다.';
END