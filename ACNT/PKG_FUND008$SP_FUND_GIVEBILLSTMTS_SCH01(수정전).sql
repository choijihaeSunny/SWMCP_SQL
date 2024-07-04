CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_FUND008$SP_FUND_GIVEBILLSTMTS_SCH01`(
	in A_COMP_ID varchar(10),
	in A_DATE1 date,
	in A_DATE2 date,
	in A_CREATE_YN varchar(1),
	in A_BAL_END varchar(1),
	out N_RETURN INT,
	out V_RETURN VARCHAR(4000)
)
begin
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	
	if A_CREATE_YN = '0' then
		if A_BAL_END = '1' then
			SELECT 0 AS CHK_SLIP,
                   P.BILL_KIND,
                   case
	                   when (P.BILL_KIND = '0') then '약속어음'
	                   when (P.BILL_KIND = '1') then '전자채권'
	               end as BILL_KIND_NAME,
                   str_to_date(P.BAL_DATE, '%Y%m%d') as BAL_DATE,
                   P.BANK_CODE,
                    (SELECT NAME
						FROM sys_data 
					  WHERE PATH = 'cfg.acnt.CC02'
	                 	and code =  P.BANK_CODE) as BANK_NAME,
                   P.BILL_NO,
                   P.BILL_AMT,
                   str_to_date(P.END_DATE, '%Y%m%d') as END_DATE,
                   P.CONT,
                   (select cust_name
                    from tc_cust_code
                    where cust_code = P.CUST_CODE) as CUST_NAME,
                   P.CUST_CODE,
                   P.AC_CODE,
                   (select IFNULL(AC_NAME, IFNULL(AC_NM4, IFNULL(AC_NM3, AC_NM2)))
                    from tbl_ac_code
                    where ac_code = P.AC_CODE ) as AC_NAME,
                   str_to_date(P.BAL_SLIP_DATE, '%Y%m%d') as BAL_SLIP_DATE,
                   str_to_date(P.END_SLIP_DATE, '%Y%m%d') as END_SLIP_DATE,
                   P.BAL_SLIP_NO,
                   P.END_SLIP_NO,
                   D.BAL_NO,
                   P.BAL_SLIP_NUMB,
                   P.END_SLIP_NUMB
            FROM TBL_OUT_BILL_DETA P 
                 left outer join TBL_OUT_BILL_DESC D
                 	on P.COMP_ID = D.COMP_ID
                 	and  P.BILL_NO = D.BILL_NUMB
            WHERE P.COMP_ID = A_COMP_ID
              AND P.BAL_DATE BETWEEN DATE_FORMAT(A_DATE1, '%Y%m%d') AND DATE_FORMAT(A_DATE2, '%Y%m%d')
              AND P.BAL_SLIP_NUMB IS NULL
              group by P.BAL_DATE, P.END_DATE                 
             ;
		else
			SELECT 0 AS CHK_SLIP,
                   P.BILL_KIND,
                   case
	                   when (P.BILL_KIND = '0') then '약속어음'
	                   when (P.BILL_KIND = '1') then '전자채권'
	               end as BILL_KIND_NAME,
                   str_to_date(P.BAL_DATE, '%Y%m%d') as BAL_DATE,
                   P.BANK_CODE,
                   (SELECT NAME
					FROM sys_data 
				  WHERE PATH = 'cfg.acnt.CC02'
                 	and code =  P.BANK_CODE) as BANK_NAME,
                   P.BILL_NO,
                   P.BILL_AMT,
                   str_to_date(P.END_DATE, '%Y%m%d') as END_DATE,
                   P.CONT,
                   (select cust_name
                    from tc_cust_code
                    where cust_code = P.CUST_CODE) as CUST_NAME,
                   P.CUST_CODE,
                   P.AC_CODE,
                   (select IFNULL(AC_NAME, IFNULL(AC_NM4, IFNULL(AC_NM3, AC_NM2)))
                    from tbl_ac_code
                    where ac_code = P.AC_CODE ) as AC_NAME,
                   str_to_date(P.BAL_SLIP_DATE, '%Y%m%d') as BAL_SLIP_DATE,
                   str_to_date(P.END_SLIP_DATE, '%Y%m%d') as END_SLIP_DATE,
                   P.BAL_SLIP_NO,
                   P.END_SLIP_NO,
                   D.BAL_NO,
                   P.BAL_SLIP_NUMB,
                   P.END_SLIP_NUMB
            FROM TBL_OUT_BILL_DETA P 
                 left outer join TBL_OUT_BILL_DESC D
                 	on P.COMP_ID = D.COMP_ID
                 	and  P.BILL_NO = D.BILL_NUMB
            WHERE P.COMP_ID = A_COMP_ID
              AND P.END_DATE BETWEEN DATE_FORMAT(A_DATE1, '%Y%m%d') AND DATE_FORMAT(A_DATE2, '%Y%m%d')
              AND P.END_SLIP_NUMB IS NULL
              group by P.BAL_DATE, P.END_DATE                 
             ;
		end if;
	else
		if A_BAL_END = '1' then
			SELECT 1 AS CHK_SLIP,
                   P.BILL_KIND,
                   case
	                   when (P.BILL_KIND = '0') then '약속어음'
	                   when (P.BILL_KIND = '1') then '전자채권'
	               end as BILL_KIND_NAME,
                   str_to_date(P.BAL_DATE, '%Y%m%d') as BAL_DATE,
                   P.BANK_CODE,
                   (SELECT NAME
					FROM sys_data 
				  WHERE PATH = 'cfg.acnt.CC02'
                 	and code =  P.BANK_CODE) as BANK_NAME,
                   P.BILL_NO,
                   P.BILL_AMT,
                   str_to_date(P.END_DATE, '%Y%m%d') as END_DATE,
                   P.CONT,
                   (select cust_name
                    from tc_cust_code
                    where cust_code = P.CUST_CODE) as CUST_NAME,
                   P.CUST_CODE,
                   P.AC_CODE,
                   (select IFNULL(AC_NAME, IFNULL(AC_NM4, IFNULL(AC_NM3, AC_NM2)))
                    from tbl_ac_code
                    where ac_code = P.AC_CODE ) as AC_NAME,
                   str_to_date(P.BAL_SLIP_DATE, '%Y%m%d') as BAL_SLIP_DATE,
                   str_to_date(P.END_SLIP_DATE, '%Y%m%d') as END_SLIP_DATE,
                   P.BAL_SLIP_NO,
                   P.END_SLIP_NO,
                   D.BAL_NO,
                   P.BAL_SLIP_NUMB,
                   P.END_SLIP_NUMB
            FROM TBL_OUT_BILL_DETA P 
                 left outer join TBL_OUT_BILL_DESC D
                 	on P.COMP_ID = D.COMP_ID
                 	and  P.BILL_NO = D.BILL_NUMB
            WHERE P.COMP_ID = A_COMP_ID
              AND P.BAL_DATE BETWEEN DATE_FORMAT(A_DATE1, '%Y%m%d') AND DATE_FORMAT(A_DATE2, '%Y%m%d')
              AND P.BAL_SLIP_NUMB IS NOT NULL
              group by P.BAL_DATE, P.END_DATE                 
             ;
		else
			SELECT 1 AS CHK_SLIP,
                   P.BILL_KIND,
                   case
	                   when (P.BILL_KIND = '0') then '약속어음'
	                   when (P.BILL_KIND = '1') then '전자채권'
	               end as BILL_KIND_NAME,
                   str_to_date(P.BAL_DATE, '%Y%m%d') as BAL_DATE,
                   P.BANK_CODE,
                   (SELECT NAME
					FROM sys_data 
				  WHERE PATH = 'cfg.acnt.CC02'
                 	and code =  P.BANK_CODE) as BANK_NAME,
                   P.BILL_NO,
                   P.BILL_AMT,
                   str_to_date(P.END_DATE, '%Y%m%d') as END_DATE,
                   P.CONT,
                   (select cust_name
                    from tc_cust_code
                    where cust_code = P.CUST_CODE) as CUST_NAME,
                   P.CUST_CODE,
                   P.AC_CODE,
                   (select IFNULL(AC_NAME, IFNULL(AC_NM4, IFNULL(AC_NM3, AC_NM2)))
                    from tbl_ac_code
                    where ac_code = P.AC_CODE ) as AC_NAME,
                   str_to_date(P.BAL_SLIP_DATE, '%Y%m%d') as BAL_SLIP_DATE,
                   str_to_date(P.END_SLIP_DATE, '%Y%m%d') as END_SLIP_DATE,
                   P.BAL_SLIP_NO,
                   P.END_SLIP_NO,
                   D.BAL_NO,
                   P.BAL_SLIP_NUMB,
                   P.END_SLIP_NUMB
            FROM TBL_OUT_BILL_DETA P 
                 left outer join TBL_OUT_BILL_DESC D
                 	on P.COMP_ID = D.COMP_ID
                 	and  P.BILL_NO = D.BILL_NUMB
            WHERE P.COMP_ID = A_COMP_ID
              AND P.END_DATE BETWEEN DATE_FORMAT(A_DATE1, '%Y%m%d') AND DATE_FORMAT(A_DATE2, '%Y%m%d')
              AND P.END_SLIP_NUMB IS NOT NULL
              group by P.BAL_DATE, P.END_DATE                 
             ;
		end if;
	end if;
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';     
END