CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC118$DELETE_INPUT_DISCOUNT_LIST`(		
	IN A_COMP_ID varchar(10),
    IN A_SET_DATE varchar(8),
    IN A_DS_KEY varchar(30),
    IN A_CUST_CODE varchar(10),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	
   					  
    delete from TB_INPUT_DISCOUNT
    where COMP_ID = A_COMP_ID
      and SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d')
      and DS_KEY = A_DS_KEY
      and CUST_CODE = A_CUST_CODE
    ;
  
   
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end