CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_SALE008$UPDATE_COLL_BILL_LIST`(		
	IN A_COMP_ID varchar(10),
-- 	IN A_SET_DATE TIMESTAMP,
-- 	IN A_SET_SEQ varchar(4),
	IN A_COLL_NUMB varchar(30),
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
	IN A_UPD_EMP_NO varchar(10),
	IN A_UPD_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
   
    update TB_COLL_BILL
    	set
    		COMP_ID = A_COMP_ID
#	    	,SET_DATE = A_SET_DATE
#	    	,SET_SEQ = A_SET_SEQ
	    	,CUST_CODE = A_CUST_CODE
	    	,EMP_NO = A_EMP_NO
	    	,DEPT_CODE = A_DEPT_CODE
	    	,SALES_KIND = A_SALES_KIND
	    	,COLL_KIND = A_COLL_KIND
	    	,RACE_KIND = A_RACE_KIND
	    	,BILL_TYPE = A_BILL_TYPE
	    	,MNY_EA = A_MNY_EA
	    	,MNY_RATE = A_MNY_RATE
	    	,EXCH_GAP = A_EXCH_GAP
	    	,COMMISSION = A_COMMISSION
	    	,MANAGE_NO = A_MANAGE_NO
	    	,APP_NO = A_APP_NO
	    	,BAL_DATE = DATE_FORMAT(A_BAL_DATE, '%Y%m%d')
	    	,END_DATE = DATE_FORMAT(A_END_DATE, '%Y%m%d')
	    	,BAL_CUST_NM = A_BAL_CUST_NM
	    	,BAL_BANK_NM = A_BAL_BANK_NM
	    	,COLL_AMT = A_COLL_AMT
	    	,SLIP_NUMB = A_SLIP_NUMB
	    	,RMKS = A_RMKS
	    	,UPD_EMP_NO = A_UPD_EMP_NO
	    	,UPD_ID = A_UPD_ID
	    	,UPD_DATE = SYSDATE()
	where COMP_ID = A_COMP_ID
	  and COLL_NUMB = A_COLL_NUMB
	;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
  	END IF;  
  
end