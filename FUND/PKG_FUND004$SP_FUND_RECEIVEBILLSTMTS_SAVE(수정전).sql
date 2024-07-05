CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_FUND004$SP_FUND_RECEIVEBILLSTMTS_SAVE`(
	in A_COMP_ID varchar(10),
	in A_SLIP_DATE date,
	in A_SLIP_EMP_NO varchar(10),
	in A_SLIP_POST varchar(5),
	in A_SYS_EMP_NO varchar(10),
	in A_SLIP_NUMB varchar(19),
	in A_BILL_NO varchar(30),
	in A_SLIP_CONT varchar(50),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
)
begin
	
	declare OLD_SLIP_NO varchar(100);
	declare NEW_SLIP_NO varchar(100);
	declare IS_SLIP_NUMB varchar(100);
	declare IS_SLIP_CHK varchar(2);
	declare IS_SLIP_CHK2 varchar(2);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SELECT MAX(SLIP_NO) 
    INTO OLD_SLIP_NO 
    FROM TBL_SLIP_MST 
    WHERE COMP_ID=A_COMP_ID
      AND SLIP_DATE = DATE_FORMAT(A_SLIP_DATE,'%Y%m%d')
      AND SLIP_EMP_NO = A_SLIP_EMP_NO;
     
    IF OLD_SLIP_NO IS NULL OR old_slip_no = '' THEN
        set NEW_SLIP_NO = '0001';
    ELSE 
        set NEW_SLIP_NO = LPAD(old_slip_no + 1, 4, '0');
    END IF;   
   
    set IS_SLIP_NUMB = concat(DATE_FORMAT(A_SLIP_DATE,'%Y%m%d'), A_SLIP_EMP_NO, NEW_SLIP_NO);
   
	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
	if A_SLIP_NUMB != '' then
		
		SELECT SLIP_YN, END_YN
        INTO IS_SLIP_CHK, IS_SLIP_CHK2
        FROM TBL_SLIP_MST
        WHERE COMP_ID = A_COMP_ID
          AND SLIP_NUMB = A_SLIP_NUMB;
         
        if IS_SLIP_CHK = '2' then
        	signal sqlstate '20001' set message_text = '이미 승인한 건 입니다.#';
        elseif IS_SLIP_CHK2 = 'Y' then
        	signal sqlstate '20001' set message_text = '이미 마감된 건 입니다.#';
        else
        	UPDATE TBL_BILLS_RECEIVABLE 
	        SET SLIP_NUMB = '', 
	            UPD_EMP_NO = A_SYS_EMP_NO, 
	            UPD_DATE = now() 
	        WHERE COMP_ID = A_COMP_ID 
	          AND BILL_NO = A_BILL_NO;
	    
	        DELETE FROM TBL_SLIP_MST 
	        WHERE COMP_ID = A_COMP_ID 
	        AND SLIP_NUMB = A_SLIP_NUMB;
	       
        end if;
	
	else
	
		UPDATE TBL_BILLS_RECEIVABLE 
        SET SLIP_NUMB = IS_SLIP_NUMB, 
            UPD_EMP_NO = A_SYS_EMP_NO, 
            UPD_DATE = now() 
        WHERE COMP_ID = A_COMP_ID 
          AND BILL_NO = A_BILL_NO;
            
        INSERT INTO TBL_SLIP_MST(
            COMP_ID, 
            SLIP_NUMB, 
            SLIP_DATE, 
            SLIP_EMP_NO, 
            SLIP_NO, 
            SLIP_POST, 
            SLIP_KIND, 
            SLIP_YN, 
            END_YN, 
            SYS_EMP_NO, 
            SYS_DATE
        )VALUES(
           A_COMP_ID, 
           IS_SLIP_NUMB, 
           DATE_FORMAT(A_SLIP_DATE,'%Y%m%d'), 
           A_SLIP_EMP_NO, 
           NEW_SLIP_NO, 
           A_SLIP_POST, 
           '2' , 
           '1' , 
           'N' , 
           A_SYS_EMP_NO, 
           now()
        );    
       
       
        INSERT INTO TBL_SLIP_DETA 
        (
                   COMP_ID, 
                   SLIP_NUMB, 
                   SLIP_SEQ, 
                   AC_CODE, 
                   POST_APPL, 
                   DR_AMT, 
                   CR_AMT, 
                   CUST_CODE, 
                   CUST_NAME, 
                   AC_NO, 
                   SLIP_CONT, 
                   ST_DATE, 
                   END_DATE, 
                   SYS_EMP_NO, 
                   SYS_DATE, 
                   ETAX_CREATE_YN
        ) 
            SELECT COMP_ID, 
            	   SLIP_NUMB, 
            	   '1', 
            	   '1110502', 
            	   A_SLIP_POST, 
            	   0, 
            	   BILL_AMT, 
            	   CUST_CODE, 
            	   (select CUST_NAME
            	    from tc_cust_code
            	    where CUST_CODE = TBL_BILLS_RECEIVABLE.CUST_CODE) as CUST_CODE,
            	   BILL_NO, 
            	   A_SLIP_CONT, 
            	   BAL_DATE, 
            	   END_DATE, 
            	   A_SYS_EMP_NO, 
            	   now(), 
            	   'Y'
            FROM TBL_BILLS_RECEIVABLE
            WHERE COMP_ID = A_COMP_ID
              AND BILL_NO = A_BILL_NO
              AND SLIP_NUMB = IS_SLIP_NUMB
              
            UNION ALL
             
            SELECT COMP_ID, 
            	   SLIP_NUMB, 
            	   '2', 
            	   '1110103', 
            	   A_SLIP_POST, 
            	   BILL_AMT, 
            	   0, 
            	   TRUST_BANK, 
            	   (select CUST_NAME
            	    from tc_cust_code
            	    where CUST_CODE = TBL_BILLS_RECEIVABLE.TRUST_BANK) as CUST_CODE,
            	   AC_NO, 
            	   A_SLIP_CONT, 
            	   NULL, 
            	   NULL,
            	   A_SYS_EMP_NO, 
            	   now(), 
            	   'Y'
            FROM TBL_BILLS_RECEIVABLE
            WHERE COMP_ID = A_COMP_ID
              AND BILL_NO = A_BILL_NO
              AND SLIP_NUMB = IS_SLIP_NUMB
           ;         
          
          
	end if;
    
  	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF; 
END