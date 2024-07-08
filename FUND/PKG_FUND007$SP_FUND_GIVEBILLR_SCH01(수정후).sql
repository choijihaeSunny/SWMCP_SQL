CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_FUND007$SP_FUND_GIVEBILLR_SCH01`(
	in A_COMP_ID varchar(10),
	in A_BAL_DATE1 date,
	in A_BAL_DATE2 date,
	in A_END_DATE1 date,
	in A_END_DATE2 date,
	in A_BILL_NO varchar(20),
	in A_CUST_NAME varchar(50),
	out N_RETURN INT,
	out V_RETURN VARCHAR(4000)
)
begin
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	
	SELECT 
			 case 
		     	when (A.BILL_KIND = '1') then '전자채권'
		     	when (A.BILL_KIND = '0') then '약속어음'
		     end as bill_kind,
--              (SELECT NAME
-- 					FROM sys_data 
-- 				  WHERE PATH = 'cfg.acnt.CC02'
--                  	and code =  A.BANK_CODE) as BANK_NAME,
		     (select cust_name from tc_cust_code  where cust_code = A.BANK_CODE) as BANK_NAME,
             A.BANK_CODE,
             A.BILL_NO,
             A.BILL_AMT,
             str_to_date(A.BAL_DATE,'%Y%m%d%H%i%s') as BAL_DATE,
             str_to_date(A.END_DATE,'%Y%m%d%H%i%s') as END_DATE,
             A.CONT,
             (select cust_name
              from tc_cust_code
              where cust_code = A.CUST_CODE) as CUST_NAME,
             A.CUST_CODE,
             B.AC_NM4,
             B.AC_NAME,
             A.AC_CODE,
             str_to_date(A.BAL_SLIP_DATE,'%Y%m%d%H%i%s') as BAL_SLIP_DATE,
             A.BAL_SLIP_NO,
             str_to_date(A.END_SLIP_DATE,'%Y%m%d%H%i%s') as END_SLIP_DATE,
             A.END_SLIP_NO
        FROM TBL_OUT_BILL_DETA A, TBL_AC_CODE B
       WHERE A.COMP_ID = A_COMP_ID
       		and A.AC_CODE = B.AC_CODE
             AND A.BAL_DATE BETWEEN DATE_FORMAT(A_BAL_DATE1, '%Y%m%d') AND DATE_FORMAT(A_BAL_DATE2, '%Y%m%d')
             AND A.END_DATE BETWEEN DATE_FORMAT(A_END_DATE1, '%Y%m%d') AND DATE_FORMAT(A_END_DATE2, '%Y%m%d')
             AND A.BILL_NO like CONCAT('%', A_BILL_NO ,'%')
             AND 
             	(select cust_name
             	 from tc_cust_code
             	 where cust_code = A.CUST_CODE) like CONCAT('%', A_CUST_NAME ,'%')
            ;
            
    SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';      
            
END