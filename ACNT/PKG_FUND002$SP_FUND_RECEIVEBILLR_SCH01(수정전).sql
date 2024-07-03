CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_FUND002$SP_FUND_RECEIVEBILLR_SCH01`(
	in A_COMP_ID varchar(10),
	in A_KIND varchar(1),
	in A_FROM_DATE date,
	in A_TO_DATE date,
	in A_BILL_NO varchar(20),
	out N_RETURN INT,
	out V_RETURN VARCHAR(4000)
)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	
	set N_RETURN = 0;
    set V_RETURN = '저장 되었습니다.';
	if A_KIND = '%' then
		SELECT BILL_NO,
	           COLL_NUMB,
	           BILL_TYPE,
	
	           ( SELECT NAME 
                   FROM sys_data 
                  WHERE PATH = 'cfg.acnt.B08'
	                and CODE = BILL_TYPE ) as BILL_TYPE_NM, 
	           str_to_date(BAL_DATE,'%Y%m%d%H%i%s') BAL_DATE,
	           BILL_AMT,
	           BAL_CUST_NM,
	           BAL_BANK,
	
	           (SELECT NAME
					FROM sys_data 
				  WHERE PATH = 'cfg.acnt.CC02'
                 	and code =  BAL_BANK) as BAL_BANK_NM,
	           str_to_date(END_DATE,'%Y%m%d%H%i%s') END_DATE,
	           ENDOR_CONT,
	           str_to_date(BUDO_DATE, '%Y%m%d%H%i%s') BUDO_DATE,
	           BUDO_DETAIL,
	           str_to_date(DISC_DATE,'%Y%m%d%H%i%s') DISC_DATE,
	           DISC_BANK,
	
	           (SELECT NAME
					FROM sys_data 
				  WHERE PATH = 'cfg.acnt.CC02'
                 	and code =  DISC_BANK) as DISC_BANK_NM,
	           str_to_date(ENDOR_DATE, '%Y%m%d%H%i%s') ENDOR_DATE,
	           ENDOR_PLACE,
	           TRUST_BANK,
	
	           (SELECT NAME
					FROM sys_data 
				  WHERE PATH = 'cfg.acnt.CC02'
                 	and code =  TRUST_BANK) as TRUST_BANK_NM,
	           AC_NO,
	           CUST_CODE,
	
	           (select cust_name
	            from tc_cust_code
	            where cust_code = TBL_BILLS_RECEIVABLE.CUST_CODE) as CUST_NAME
	    FROM TBL_BILLS_RECEIVABLE
	    WHERE COMP_ID = A_COMP_ID 
	    AND BILL_NO LIKE CONCAT('%', A_BILL_NO, '%')
	    ;
	elseif A_KIND = '1' then
		SELECT BILL_NO,
	           COLL_NUMB,
	           BILL_TYPE,
	
	           (SELECT NAME 
                   FROM sys_data 
                  WHERE PATH = 'cfg.acnt.B08'
	                and CODE = BILL_TYPE ) as BILL_TYPE_NM, 
	           str_to_date(BAL_DATE,'%Y%m%d%H%i%s') BAL_DATE,
	           BILL_AMT,
	           BAL_CUST_NM,
	           BAL_BANK,
	
	           (SELECT NAME
					FROM sys_data 
				  WHERE PATH = 'cfg.acnt.CC02'
                 	and code =  BAL_BANK) as BAL_BANK_NM,
	           str_to_date(END_DATE,'%Y%m%d%H%i%s') END_DATE,
	           ENDOR_CONT,
	           str_to_date(BUDO_DATE, '%Y%m%d%H%i%s') BUDO_DATE,
	           BUDO_DETAIL,
	           str_to_date(DISC_DATE,'%Y%m%d%H%i%s') DISC_DATE,
	           DISC_BANK,
	
	           (SELECT NAME
					FROM sys_data 
				  WHERE PATH = 'cfg.acnt.CC02'
                 	and code =  BAL_BANK) as BAL_BANK_NM,
	           str_to_date(ENDOR_DATE, '%Y%m%d%H%i%s') ENDOR_DATE,
	           ENDOR_PLACE,
	           TRUST_BANK,
	
	           (SELECT NAME
					FROM sys_data 
				  WHERE PATH = 'cfg.acnt.CC02'
                 	and code =  TRUST_BANK) as TRUST_BANK_NM,
	           AC_NO,
	           CUST_CODE,
	
	           (select cust_name
	            from tc_cust_code
	            where cust_code = TBL_BILLS_RECEIVABLE.CUST_CODE) as CUST_NAME
	    FROM TBL_BILLS_RECEIVABLE
	    WHERE COMP_ID = A_COMP_ID 
	    AND BILL_NO LIKE CONCAT('%', A_BILL_NO, '%')
	    AND BAL_DATE BETWEEN date_format(A_FROM_DATE, '%Y%m%d') AND date_format(A_TO_DATE, '%Y%m%d')
	    ;
	elseif A_KIND = '2' then
		SELECT BILL_NO,
	           COLL_NUMB,
	           BILL_TYPE,
	
	           (SELECT NAME 
                   FROM sys_data 
                  WHERE PATH = 'cfg.acnt.B08'
	                and CODE = BILL_TYPE ) as BILL_TYPE_NM, 
	           str_to_date(BAL_DATE,'%Y%m%d%H%i%s') BAL_DATE,
	           BILL_AMT,
	           BAL_CUST_NM,
	           BAL_BANK,
	
	           (SELECT NAME
					FROM sys_data 
				  WHERE PATH = 'cfg.acnt.CC02'
                 	and code =  BAL_BANK) as BAL_BANK_NM,
	           str_to_date(END_DATE,'%Y%m%d%H%i%s') END_DATE,
	           ENDOR_CONT,
	           str_to_date(BUDO_DATE, '%Y%m%d%H%i%s') BUDO_DATE,
	           BUDO_DETAIL,
	           str_to_date(DISC_DATE,'%Y%m%d%H%i%s') DISC_DATE,
	           DISC_BANK,
	
	           (SELECT NAME
					FROM sys_data 
				  WHERE PATH = 'cfg.acnt.CC02'
                 	and code =  BAL_BANK) as BAL_BANK_NM,
	           str_to_date(ENDOR_DATE, '%Y%m%d%H%i%s') ENDOR_DATE,
	           ENDOR_PLACE,
	           TRUST_BANK,
	
	           (SELECT NAME
					FROM sys_data 
				  WHERE PATH = 'cfg.acnt.CC02'
                 	and code =  TRUST_BANK) as TRUST_BANK_NM,
	           AC_NO,
	           CUST_CODE,
	
	           (select cust_name
	            from tc_cust_code
	            where cust_code = TBL_BILLS_RECEIVABLE.CUST_CODE) as CUST_NAME
	    FROM TBL_BILLS_RECEIVABLE
	    WHERE COMP_ID = A_COMP_ID 
	    AND BILL_NO LIKE CONCAT('%', A_BILL_NO, '%')
	    AND END_DATE BETWEEN date_format(A_FROM_DATE, '%Y%m%d') AND date_format(A_TO_DATE, '%Y%m%d')
	    ;
	elseif A_KIND = '3' then
		SELECT BILL_NO,
	           COLL_NUMB,
	           BILL_TYPE,
	
	           (SELECT NAME 
                   FROM sys_data 
                  WHERE PATH = 'cfg.acnt.B08'
	                and CODE = BILL_TYPE ) as BILL_TYPE_NM, 
	           str_to_date(BAL_DATE,'%Y%m%d%H%i%s') BAL_DATE,
	           BILL_AMT,
	           BAL_CUST_NM,
	           BAL_BANK,
	
	           (SELECT NAME
					FROM sys_data 
				  WHERE PATH = 'cfg.acnt.CC02'
                 	and code =  BAL_BANK) as BAL_BANK_NM,
	           str_to_date(END_DATE,'%Y%m%d%H%i%s') END_DATE,
	           ENDOR_CONT,
	           str_to_date(BUDO_DATE, '%Y%m%d%H%i%s') BUDO_DATE,
	           BUDO_DETAIL,
	           str_to_date(DISC_DATE,'%Y%m%d%H%i%s') DISC_DATE,
	           DISC_BANK,
	
	           (SELECT NAME
					FROM sys_data 
				  WHERE PATH = 'cfg.acnt.CC02'
                 	and code =  BAL_BANK) as BAL_BANK_NM,
	           str_to_date(ENDOR_DATE, '%Y%m%d%H%i%s') ENDOR_DATE,
	           ENDOR_PLACE,
	           TRUST_BANK,
	
	           (SELECT NAME
					FROM sys_data 
				  WHERE PATH = 'cfg.acnt.CC02'
                 	and code =  TRUST_BANK) as TRUST_BANK_NM,
	           AC_NO,
	           CUST_CODE,
	
	           (select cust_name
	            from tc_cust_code
	            where cust_code = TBL_BILLS_RECEIVABLE.CUST_CODE) as CUST_NAME
	    FROM TBL_BILLS_RECEIVABLE
	    WHERE COMP_ID = A_COMP_ID 
	    AND BILL_NO LIKE CONCAT('%', A_BILL_NO, '%')
	    AND DISC_DATE BETWEEN date_format(A_FROM_DATE, '%Y%m%d') AND date_format(A_TO_DATE, '%Y%m%d')
	    ;
	elseif A_KIND = '4' then
		SELECT BILL_NO,
	           COLL_NUMB,
	           BILL_TYPE,
	
	           (SELECT NAME 
                   FROM sys_data 
                  WHERE PATH = 'cfg.acnt.B08'
	                and CODE = BILL_TYPE ) as BILL_TYPE_NM, 
	           str_to_date(BAL_DATE,'%Y%m%d%H%i%s') BAL_DATE,
	           BILL_AMT,
	           BAL_CUST_NM,
	           BAL_BANK,
	
	           (SELECT NAME
					FROM sys_data 
				  WHERE PATH = 'cfg.acnt.CC02'
                 	and code =  BAL_BANK) as BAL_BANK_NM,
	           str_to_date(END_DATE,'%Y%m%d%H%i%s') END_DATE,
	           ENDOR_CONT,
	           str_to_date(BUDO_DATE, '%Y%m%d%H%i%s') BUDO_DATE,
	           BUDO_DETAIL,
	           str_to_date(DISC_DATE,'%Y%m%d%H%i%s') DISC_DATE,
	           DISC_BANK,
	
	           (SELECT NAME
					FROM sys_data 
				  WHERE PATH = 'cfg.acnt.CC02'
                 	and code =  BAL_BANK) as BAL_BANK_NM,
	           str_to_date(ENDOR_DATE, '%Y%m%d%H%i%s') ENDOR_DATE,
	           ENDOR_PLACE,
	           TRUST_BANK,
	
	           (SELECT NAME
					FROM sys_data 
				  WHERE PATH = 'cfg.acnt.CC02'
                 	and code =  TRUST_BANK) as TRUST_BANK_NM,
	           AC_NO,
	           CUST_CODE,
	
	           (select cust_name
	            from tc_cust_code
	            where cust_code = TBL_BILLS_RECEIVABLE.CUST_CODE) as CUST_NAME
	    FROM TBL_BILLS_RECEIVABLE
	    WHERE COMP_ID = A_COMP_ID 
	    AND BILL_NO LIKE CONCAT('%', A_BILL_NO, '%')
	    AND ENDOR_DATE BETWEEN date_format(A_FROM_DATE, '%Y%m%d') AND date_format(A_TO_DATE, '%Y%m%d')
	    ;
	   
	end if;
    
   
   SET N_RETURN = 0;
   SET V_RETURN = '조회되었습니다.';
END