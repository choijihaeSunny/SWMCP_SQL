CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_SALE010$DELETE_TAX_MST`(		
	IN A_COMP_ID VARCHAR(10),
  	IN A_TAX_NUMB VARCHAR(30),
  	IN A_RMK VARCHAR(100),
  	IN A_UPD_EMP_NO varchar(10),
	IN A_UPD_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare I INT;
	declare TAX_CNT INT;
	declare V_TAX_SEQ VARCHAR(3);
	declare V_CALL_KIND VARCHAR(10);
	declare V_CALL_KEY VARCHAR(30);

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
  	
 
  	set TAX_CNT = (select COUNT(*)
  				   from TB_TAX_DET
  				   where TAX_NUMB = A_TAX_NUMB);
  
  				  
  	WHILE I < TAX_CNT DO
  		
  		select
  			  TAX_SEQ, CALL_KIND, CALL_KEY
  		into
  			V_TAX_SEQ, V_CALL_KIND, V_CALL_KEY
  		from TB_TAX_DET
  		where COMP_ID = A_COMP_ID
	  	  and TAX_NUMB = A_TAX_NUMB
	  	order by TAX_SEQ
  		limit 1
  		;

  		if V_CALL_KIND = 'REQ' then
    
	    	update TB_OUT_DET
	    	   set TAX_YN = 'N'
	    	where COMP_ID = A_COMP_ID
	    	  and OUT_MST_KEY = V_CALL_KEY
	    	;
	    else -- if V_CALL_KIND = 'RTN' then
	    
	    	update TB_OUT_RETURN_DET
	    	   set TAX_YN = 'N'
	    	where COMP_ID = A_COMP_ID
	    	  and OUT_RETURN_MST_KEY = V_CALL_KEY
	    	;
	    end if;
  	
	   
	  	delete from TB_TAX_DET
		where COMP_ID = A_COMP_ID
	  	  and TAX_NUMB = A_TAX_NUMB
	  	  and TAX_SEQ = A_TAX_SEQ
	  	  and CALL_KIND = V_CALL_KIND
	  	  and CALL_KEY = V_CALL_KEY
	  	;
  	
  		set I = I + 1;
  	end while;
  
	delete FROM TB_TAX_MST
  	where COMP_ID = A_COMP_ID
  	  and TAX_NUMB = A_TAX_NUMB
  	;
  
  	-- 
  
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
  	END IF;  
  
end