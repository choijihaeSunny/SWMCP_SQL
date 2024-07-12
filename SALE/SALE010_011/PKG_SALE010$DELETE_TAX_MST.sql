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
	

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
  	delete FROM TB_TAX_MST
  	where COMP_ID = A_COMP_ID
  	  and TAX_NUMB = A_TAX_NUMB
  	;
  
    delete from TB_TAX_DET
	where COMP_ID = A_COMP_ID
  	  and TAX_NUMB = A_TAX_NUMB
  	;
  
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
  	END IF;  
  
end