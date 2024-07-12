CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_SALE010$UPDATE_TAX_DET`(		
  	IN A_COMP_ID VARCHAR(10),
  	IN A_TAX_NUMB VARCHAR(10),
  	IN A_RMK VARCHAR(100),
  	IN A_UPD_EMP_NO varchar(10),
	IN A_UPD_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.';
  
    update TB_TAX_DET
       set RMK = A_RMK,
  	  	  UPD_EMP_NO = A_UPD_EMP_NO,
  	  	  UPD_ID = A_UPD_ID,
  	  	  UPD_DATE = SYSDATE()
  	where COMP_ID = A_COMP_ID
  	  and TAX_NUMB = A_TAX_NUMB
  	;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
  	END IF;  
  
end