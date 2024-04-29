CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_SALE008$INSERT_COLL_BILL_LIST`(		
	IN A_COMP_ID varchar(10),
	IN A_SET_DATE TIMESTAMP,
	IN A_SET_SEQ varchar(4),
	IN A_CUST_CODE varchar(10),
	IN A_EMP_NO varchar(10),
	IN A_DEPT_CODE varchar(10),
	IN A_SALES_KIND bigint(20),
	IN A_COLL_KIND bigint(20),
	IN A_RACE_KIND bigint(20),
	IN A_BILL_TYPE bigint(20),
	IN A_MNY_EA bigint(20),
	IN A_MNY_RATE decimal(16, 4),
	IN A_EXCH_GAP decimal(16, 4),
	IN A_COMMISSION decimal(16, 4),
	IN A_MANAGE_NO varchar(30),
	IN A_APP_NO varchar(30),
	IN A_BAL_DATE TIMESTAMP,
	IN A_END_DATE TIMESTAMP,
	IN A_BAL_CUST_NM varchar(50),
	IN A_BAL_BANK_NM varchar(50),
	IN A_COLL_AMT decimal(16, 4),
	IN A_SLIP_NUMB varchar(30),
	IN A_RMKS varchar(100),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_COLL_NUMB varchar(30);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
    SET V_COLL_NUMB := CONCAT('CB', right(DATE_FORMAT(A_SET_DATE, '%Y%m'), 4), LPAD(A_SET_SEQ, 4, '0'));
   
  	
    INSERT INTO TB_COLL_BILL (
    	COMP_ID,
    	SET_DATE,
    	SET_SEQ,
    	COLL_NUMB,
    	CUST_CODE,
    	EMP_NO,
    	DEPT_CODE,
    	SALES_KIND,
    	COLL_KIND,
    	RACE_KIND,
    	BILL_TYPE,
    	MNY_EA,
    	MNY_RATE,
    	EXCH_GAP,
    	COMMISSION,
    	MANAGE_NO,
    	APP_NO,
    	BAL_DATE,
    	END_DATE,
    	BAL_CUST_NM,
    	BAL_BANK_NM,
    	COLL_AMT,
    	SLIP_NUMB,
    	RMKS
    	,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
    ) values (
   		A_COMP_ID,
    	DATE_FORMAT(A_SET_DATE, '%Y%m%d'),
    	LPAD(A_SET_SEQ, 3, '0'),
    	V_COLL_NUMB,
    	A_CUST_CODE,
    	A_EMP_NO,
    	A_DEPT_CODE,
    	A_SALES_KIND,
    	A_COLL_KIND,
    	A_RACE_KIND,
    	A_BILL_TYPE,
    	A_MNY_EA,
    	A_MNY_RATE,
    	A_EXCH_GAP,
    	A_COMMISSION,
    	A_MANAGE_NO,
    	A_APP_NO,
    	DATE_FORMAT(A_BAL_DATE, '%Y%m%d'),
    	DATE_FORMAT(A_END_DATE, '%Y%m%d'),
    	A_BAL_CUST_NM,
    	A_BAL_BANK_NM,
    	A_COLL_AMT,
    	A_SLIP_NUMB,
    	A_RMKS
    	,A_SYS_EMP_NO
    	,A_SYS_ID
    	,SYSDATE()
    )
    ;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
  	END IF;  
  
end