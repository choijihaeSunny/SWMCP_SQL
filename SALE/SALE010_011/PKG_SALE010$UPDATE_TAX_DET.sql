CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_SALE010$UPDATE_TAX_DET`(		
  	IN A_COMP_ID VARCHAR(10),
  	IN A_TAX_NUMB VARCHAR(10),
  	IN A_RMK VARCHAR(100),
  	IN A_CUD_KEY VARCHAR(10),
  	IN A_TAX_SEQ VARCHAR(3),
  	IN A_CALL_KIND VARCHAR(10),
  	IN A_CALL_KEY VARCHAR(30),
  	IN A_UPD_EMP_NO varchar(10),
	IN A_UPD_ID varchar(30),
	OUT N_RETURN INT,
	OUT A_RETURN VARCHAR(4000)
	)
begin
	
	SET N_RETURN = 0;
  	SET A_RETURN = '저장되었습니다.';

  	if A_CUD_KEY = 'UPDATE' then
  	
  		update TB_TAX_DET
	       set RMK = A_RMK,
	  	  	  UPD_EMP_NO = A_UPD_EMP_NO,
	  	  	  UPD_ID = A_UPD_ID,
	  	  	  UPD_DATE = SYSDATE()
	  	where COMP_ID = A_COMP_ID
	  	  and TAX_NUMB = A_TAX_NUMB
	  	;
  	else -- if A_CUD_KEY = 'DELETE' then
  	
	
	  	if A_CALL_KIND = 'REQ' then
	    
		    update TB_OUT_DET
		       set TAX_YN = 'N'
		     where COMP_ID = A_COMP_ID
		       and OUT_MST_KEY = A_CALL_KEY
		    ;
		else -- if A_CALL_KIND = 'RTN' then
		    
		    update TB_OUT_RETURN_DET
		       set TAX_YN = 'N'
		     where COMP_ID = A_COMP_ID
		       and OUT_RETURN_MST_KEY = A_CALL_KEY
		    ;
		end if;
	  	
		   
		delete from TB_TAX_DET
		where COMP_ID = A_COMP_ID
		  and TAX_NUMB = A_TAX_NUMB
		  and TAX_SEQ = A_TAX_SEQ
		  and CALL_KIND = A_CALL_KIND
		  and CALL_KEY = A_CALL_KEY
		 ;
  	end if
    ;
  
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET A_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
  	END IF;  
  
end