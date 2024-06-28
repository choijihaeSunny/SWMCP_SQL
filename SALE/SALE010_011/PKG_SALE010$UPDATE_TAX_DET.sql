CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_SALE010$UPDATE_TAX_DET`(	
	IN A_IS_CHK varchar(3),
	IN A_CUD_KEY varchar(10),
	IN A_COMP_ID varchar(10),
	IN A_OID bigint(20),
	IN A_TAX_OID bigint(20),
	IN A_VBILL_NUM varchar(20),
	IN A_SEND_DATE date,
	IN A_CUST_CODE varchar(10),
	IN A_PROD_ID bigint(20),
	IN A_KIND varchar(10),
	IN A_SUPP_QTY decimal(20,4),
	IN A_SUPP_PRC decimal(20,4),
	IN A_SUPP_AMT decimal(20,4),
	IN A_SUPP_VAT decimal(20,4),
	IN A_ENG_AMT decimal(20,4),
	IN A_SEND_OID varchar(20),
	IN A_INSERT_ID decimal(10,0),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	if A_IS_CHK = 'Y' then
		
		if A_CUD_KEY = 'DELETE' then
		
			SET N_RETURN = 0;
		  	SET V_RETURN = '삭제되었습니다.'; 
		  	
		  	
		  	
		  	delete from tax_det
				where OID = A_OID
					and COMP_ID = A_COMP_ID;
					
			
			IF ROW_COUNT() = 0 THEN
		  	  SET N_RETURN = -1;
		      SET V_RETURN = '삭제가 실패하였습니다.'; 
		  	END IF;  
		  
		else
		
			SET N_RETURN = 0;
		  	SET V_RETURN = '저장되었습니다.'; 
		  
		  	INSERT INTO tax_det
			  		(COMP_ID,
					OID,
					TAX_OID,
					VBILL_NUM,
					SEND_DATE,
					CUST_CODE,
					PROD_ID,
					KIND,
					SUPP_QTY,
					SUPP_PRC,
					SUPP_AMT,
					SUPP_VAT,
					ENG_AMT,
					SEND_OID,
					INSERT_ID,
					INSERT_DT,
					UPDATE_ID,
					UPDATE_DT,
					MODI_KEY)
				values
					(A_COMP_ID,
					NEXTVAL(sq_com),
					A_TAX_OID,
					A_VBILL_NUM,
					date_format(A_SEND_DATE, '%Y%m%d'),
					A_CUST_CODE,
					A_PROD_ID,
					A_KIND,
					A_SUPP_QTY,
					A_SUPP_PRC,
					A_SUPP_AMT,
					A_SUPP_VAT,
					A_ENG_AMT,
					A_SEND_OID,
					A_INSERT_ID,
					NOW(),
					A_INSERT_ID,
					NOW(),
					0);
			
			IF ROW_COUNT() = 0 THEN
		  	  SET N_RETURN = -1;
		      SET V_RETURN = '저장이 실패하였습니다.'; 
		  	END IF;  
		
		end if;
		
	end if;
  
end