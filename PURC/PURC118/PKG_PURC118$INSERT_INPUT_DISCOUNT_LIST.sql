CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC118$INSERT_INPUT_DISCOUNT_LIST`(		
	IN A_COMP_ID varchar(10),
    IN A_SET_DATE TIMESTAMP,
    INOUT A_DS_KEY varchar(30),
    IN A_CUST_CODE varchar(10),
    IN A_INPUT_AMT decimal(16, 4),
    IN A_DS_RATE decimal(16, 4),
    IN A_DS_AMT decimal(16, 4),
    IN A_DS_CAUSE varchar(50),
    IN A_DS_INPUT_FROM TIMESTAMP,
    IN A_DS_INPUT_TO TIMESTAMP,
    IN A_END_AMT decimal(16, 4),
    IN A_RMK varchar(100),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_DS_KEY varchar(30);
	declare V_SET_NO varchar(5);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 

	set V_SET_NO = (select LPAD(SUBSTR(DS_KEY, 11, 3) + 1, 3, '0')
					from TB_INPUT_DISCOUNT 
					where SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d'));

	set V_DS_KEY = CONCAT('DM', DATE_FORMAT(A_SET_DATE, '%Y%m%d'), V_SET_NO);

	set A_DS_KEY = V_DS_KEY;

    INSERT INTO TB_INPUT_DISCOUNT (
    	COMP_ID,
    	SET_DATE,
    	DS_KEY,
    	CUST_CODE,
    	INPUT_AMT,
    	DS_RATE,
    	DS_AMT,
    	DS_CAUSE,
    	DS_INPUT_FROM,
    	DS_INPUT_TO,
    	END_AMT,
    	RMK
    	,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
    ) values (
   		A_COMP_ID,
    	DATE_FORMAT(A_SET_DATE, '%Y%m%d'),
    	V_DS_KEY,
    	A_CUST_CODE,
    	A_INPUT_AMT,
    	A_DS_RATE,
    	A_DS_AMT,
    	A_DS_CAUSE,
    	DATE_FORMAT(A_DS_INPUT_FROM, '%Y%m%d'),
    	DATE_FORMAT(A_DS_INPUT_TO, '%Y%m%d'),
    	A_END_AMT,
    	A_RMK
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