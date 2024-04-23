CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_QUAL026$INSERT_MSUR_EQUICHECK`(		
	IN A_COMP_ID varchar(10),
	IN A_EQUI_CODE varchar(20),
	IN A_CHECK_ITEM varchar(10),
	IN A_CYCLE decimal(3, 0),
	IN A_FINAL_DATE timestamp,
	IN A_NEXT_DATE timestamp,
	IN A_CHECK_DEPT varchar(10),
	IN A_ETC_RMK varchar(200),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
    INSERT INTO TB_MSUR_EQUICHECK (
    	COMP_ID,
    	EQUI_CODE,
    	CHECK_ITEM,
    	CYCLE,
    	FINAL_DATE,
    	NEXT_DATE,
    	CHECK_DEPT,
    	ETC_RMK
    	,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
    ) values (
    	A_COMP_ID,
    	A_EQUI_CODE,
    	A_CHECK_ITEM,
    	A_CYCLE,
    	DATE_FORMAT(A_FINAL_DATE, '%Y%m%d'),
    	DATE_FORMAT(A_NEXT_DATE, '%Y%m%d'),
    	A_CHECK_DEPT,
    	A_ETC_RMK
    	,A_SYS_EMP_NO
    	,A_SYS_ID
    	,SYSDATE()
    )
    ;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end