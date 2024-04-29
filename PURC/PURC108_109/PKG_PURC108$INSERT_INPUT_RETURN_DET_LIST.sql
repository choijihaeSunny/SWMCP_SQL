CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC108$INSERT_INPUT_RETURN_DET_LIST`(		
	IN A_COMP_ID varchar(10),
	IN A_SET_DATE TIMESTAMP,
	IN A_SET_SEQ varchar(4),
    IN A_INPUT_RETURN_MST_KEY varchar(30),
    IN A_RETURN_DATE TIMESTAMP,
    IN A_ITEM_CODE varchar(30),
    IN A_LOT_NO varchar(30),
    IN A_QTY decimal(10, 0),
    IN A_COST decimal(16, 4),
    IN A_AMT decimal(16, 4),
    IN A_WARE_CODE bigint(20),
    IN A_DEPT_CODE varchar(10),
    IN A_RETURN_CAUSE bigint(20),
    IN A_END_AMT decimal(16, 4),
    IN A_CALL_KIND varchar(10),
    IN A_CALL_KEY varchar(30),
    IN A_RMK varchar(100),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_INPUT_RETURN_KEY varchar(30);
	declare V_SET_NO varchar(4);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
  	SET V_SET_NO = (select IFNULL(MAX(SET_NO), 0) + 1
    				from TB_INPUT_RETURN_DET
    				where INPUT_RETURN_MST_KEY = A_INPUT_RETURN_MST_KEY
    				); 	
    			
    SET V_INPUT_RETURN_KEY := CONCAT(A_INPUT_RETURN_MST_KEY, LPAD(V_SET_NO, 4, '0'));

    INSERT INTO TB_INPUT_RETURN_DET (
    	COMP_ID,
    	SET_DATE,
    	SET_SEQ,
    	SET_NO,
    	INPUT_RETURN_MST_KEY,
    	INPUT_RETURN_KEY,
    	RETURN_DATE,
    	ITEM_CODE,
    	LOT_NO,
    	QTY,
    	COST,
    	AMT,
    	WARE_CODE,
    	DEPT_CODE,
    	RETURN_CAUSE,
    	END_AMT,
    	CALL_KIND,
    	CALL_KEY,
    	RMK
    	,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
    ) values (
   		A_COMP_ID,
    	DATE_FORMAT(A_SET_DATE, '%Y%m%d'),
    	LPAD(A_SET_SEQ, 4, '0'),
    	V_SET_NO,
    	A_INPUT_RETURN_MST_KEY,
    	V_INPUT_RETURN_KEY,
    	DATE_FORMAT(A_RETURN_DATE, '%Y%m%d'),
    	A_ITEM_CODE,
    	A_LOT_NO,
    	A_QTY,
    	A_COST,
    	A_AMT,
    	A_WARE_CODE,
    	A_DEPT_CODE,
    	A_RETURN_CAUSE,
    	A_END_AMT,
    	A_CALL_KIND,
    	A_CALL_KEY,
    	A_RMK
    	,A_SYS_EMP_NO
    	,A_SYS_ID
    	,SYSDATE()
    )
    ;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
  	END IF;  
  
end