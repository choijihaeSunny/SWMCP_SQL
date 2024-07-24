CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_SALE010$INSERT_TAX_DET`(		
  	IN A_COMP_ID VARCHAR(10),
  	IN A_CHK VARCHAR(1),
  	IN A_TAX_NUMB VARCHAR(10),
  	IN A_ACT_DATE TIMESTAMP,
  	IN A_ITEM_CODE VARCHAR(30),
  	IN A_QTY DECIMAL(20, 4),
  	IN A_COST DECIMAL(20, 4),
  	IN A_SUPP_AMT DECIMAL(20, 4),
  	IN A_VAT DECIMAL(20, 4),
  	IN A_CALL_KIND VARCHAR(10),
  	IN A_CALL_KEY VARCHAR(30),
--   	IN A_DIFF_AMT DECIMAL(20, 4),
  	IN A_RMK VARCHAR(100),
  	IN A_SYS_EMP_NO VARCHAR(10),
	IN A_SYS_ID VARCHAR(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_TAX_SEQ VARCHAR(3);
	declare V_ACT_DATE VARCHAR(8);

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.';
  
  
  	if A_CHK = 'Y' then
  	
  		set V_ACT_DATE = DATE_FORMAT(A_ACT_DATE, '%Y%m%d');
  
	  	set V_TAX_SEQ = (select LPAD(IFNULL(MAX(TAX_SEQ), 0) + 1, 3, 0)
	  					 from TB_TAX_DET
	  					 where COMP_ID = A_COMP_ID
	  					   and ACT_DATE = V_ACT_DATE
	  					   and TAX_NUMB = A_TAX_NUMB);
	  
	  	insert into TB_TAX_DET (
	  		COMP_ID,
	  		TAX_NUMB,
	  		TAX_SEQ,
	  		ACT_DATE,
	  		ITEM_CODE,
	  		QTY,
	  		COST,
	  		SUPP_AMT,
	  		VAT,
	  		CALL_KIND,
	  		CALL_KEY,
	  		DIFF_AMT,
	  		RMK
	  		,SYS_EMP_NO
	    	,SYS_ID
	    	,SYS_DATE
	  	) values (
	  		A_COMP_ID,
	  		A_TAX_NUMB,
	  		V_TAX_SEQ,
	  		V_ACT_DATE,
	  		A_ITEM_CODE,
	  		A_QTY,
	  		A_COST,
	  		A_SUPP_AMT,
	  		A_VAT,
	  		A_CALL_KIND,
	  		A_CALL_KEY,
	  		0, -- A_DIFF_AMT
	  		A_RMK
	  		,A_SYS_EMP_NO
	    	,A_SYS_ID
	    	,SYSDATE()
	  	)
	    ;
	   
	    if A_CALL_KIND = 'REQ' then
	    
	    	update TB_OUT_DET
	    	   set TAX_YN = 'Y'
	    	where COMP_ID = A_COMP_ID
	    	  and OUT_KEY = A_CALL_KEY
	    	;
	    else -- if A_CALL_KIND = 'RTN' then
	    
	    	update TB_OUT_RETURN_DET
	    	   set TAX_YN = 'Y'
	    	where COMP_ID = A_COMP_ID
	    	  and OUT_RETURN_KEY = A_CALL_KEY
	    	;
	    end if;
		
		IF ROW_COUNT() = 0 THEN
	  	  SET N_RETURN = -1;
	      SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
	  	END IF;
  	end if;
end