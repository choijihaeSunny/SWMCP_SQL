CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC119$INSERT_INPUT_END_MST`(		
	IN A_COMP_ID VARCHAR(10),
	IN A_CHK VARCHAR(1),
	IN A_SET_DATE TIMESTAMP,
	INOUT A_INPUT_END_KEY VARCHAR(30),
	IN A_CUST_CODE VARCHAR(10),
	IN A_EMP_NO VARCHAR(10),
	IN A_DEPT_CODE VARCHAR(10),
	IN A_SUPP_AMT DECIMAL(20, 4),
	IN A_VAT DECIMAL(20, 4),
	IN A_SLIP_NUMB VARCHAR(30),
	IN A_RMKS VARCHAR(100),
  	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_SET_SEQ VARCHAR(4);
	declare V_SET_DATE VARCHAR(8);
	declare V_INPUT_END_KEY VARCHAR(30);

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.';
  
  	if A_CHK = 'Y' then
  	
  		set V_SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d');
  
	  	set V_SET_SEQ = (select LPAD(IFNULL(MAX(SET_SEQ), 0) + 1, 3, 0)
	  					 from TB_INPUT_END
	  					 where COMP_ID = A_COMP_ID
	  					   and SET_DATE = V_SET_DATE);
	  					  
	  	set V_INPUT_END_KEY = CONCAT('PX', V_SET_DATE, V_SET_SEQ);
	  
	    insert into TB_INPUT_END (
	    	COMP_ID,
	    	SET_DATE,
	    	SET_SEQ,
	    	INPUT_END_KEY,
	    	CUST_CODE,
	    	EMP_NO,
	    	DEPT_CODE,
	    	SUPP_AMT,
	    	VAT,
	    	SLIP_NUMB,
	    	RMKS
	    	,SYS_ID
	    	,SYS_EMP_NO
	    	,SYS_DATE
	    ) values (
	    	A_COMP_ID,
	    	V_SET_DATE,
	    	V_SET_SEQ,
	    	V_INPUT_END_KEY,
	    	A_CUST_CODE,
	    	A_EMP_NO,
	    	A_DEPT_CODE,
	    	A_SUPP_AMT,
	    	A_VAT,
	    	A_SLIP_NUMB,
	    	A_RMKS
	    	,A_SYS_ID
	    	,A_SYS_EMP_NO
	    	,SYSDATE()
	    )
	    ;
	   
	    set A_INPUT_END_KEY = V_INPUT_END_KEY;
		  	  
		IF ROW_COUNT() = 0 THEN
			SET N_RETURN = -1;
		    SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
		END IF;
  	end if
  	;
  	
end