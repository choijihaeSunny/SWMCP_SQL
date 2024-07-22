CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_SALE010$INSERT_TAX_MST`(		
	IN A_COMP_ID VARCHAR(10),
  	IN A_SET_DATE TIMESTAMP,
  	INOUT A_TAX_NUMB VARCHAR(30),
  	IN A_CUST_CODE VARCHAR(10),
  	IN A_EMP_NO VARCHAR(10),
  	IN A_DEPT_CODE VARCHAR(10),
  	IN A_SUPP_AMT DECIMAL(16, 4),
  	IN A_VAT DECIMAL(20, 4),
  	IN A_TAX_REQ bigint(20),
  	IN A_SALES_KIND bigint(20),
  	IN A_SLIP_NUMB VARCHAR(30),
--   	IN A_DIFF_AMT DECIMAL(20, 4),
  	IN A_RMK VARCHAR(100),
  	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_SET_SEQ VARCHAR(4);
	declare V_SET_DATE VARCHAR(8);
	declare V_TAX_NUMB VARCHAR(30);

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
  	set V_SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d');
  
  	set V_SET_SEQ = (select LPAD(IFNULL(MAX(SET_SEQ), 0) + 1, 4, 0)
  					 from TB_TAX_MST
  					 where COMP_ID = A_COMP_ID
  					   and SUBSTR(SET_DATE, 3, 4) = SUBSTR(V_SET_DATE, 3, 4));
  					  
  	set V_TAX_NUMB = CONCAT('TX', SUBSTR(V_SET_DATE, 3, 4), V_SET_SEQ);
  	
  	insert into TB_TAX_MST (
  		COMP_ID,
  		SET_DATE,
  		SET_SEQ,
  		TAX_NUMB,
  		CUST_CODE,
  		EMP_NO,
  		DEPT_CODE,
  		SUPP_AMT,
  		VAT,
  		TAX_REQ,
  		SALES_KIND,
  		SLIP_NUMB,
  		DIFF_AMT,
  		RMK
  		,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
  	) values (
  		A_COMP_ID,
  		V_SET_DATE,
  		V_SET_SEQ,
  		V_TAX_NUMB,
  		A_CUST_CODE,
  		A_EMP_NO,
  		A_DEPT_CODE,
  		A_SUPP_AMT,
  		A_VAT,
  		A_TAX_REQ,
  		A_SALES_KIND,
  		A_SLIP_NUMB,
  		0, -- A_DIFF_AMT
  		A_RMK
  		,A_SYS_EMP_NO
    	,A_SYS_ID
    	,SYSDATE()
  	);
  
    set A_TAX_NUMB = V_TAX_NUMB;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
  	END IF;  
  
end