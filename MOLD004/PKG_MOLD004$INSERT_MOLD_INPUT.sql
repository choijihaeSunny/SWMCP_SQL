CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD004$INSERT_MOLD_INPUT`(	
	IN A_COMP_ID varchar(10),
	IN A_SET_DATE TIMESTAMP,
	IN A_SET_SEQ varchar(4),
	INOUT A_MOLD_INPUT_KEY varchar(30),
	IN A_CUST_CODE varchar(10),
	IN A_MOLD_CODE varchar(20),
	IN A_LOT_YN bigint(20),
	IN A_QTY decimal(10, 0),
	IN A_COST decimal(16, 4),
	IN A_AMT decimal(16, 4),
	IN A_DEPT_CODE varchar(10),
	IN A_IN_QTY decimal(10, 0),
    IN A_CALL_KIND varchar(10),
    IN A_CALL_KEY varchar(30),
    IN A_END_AMT decimal(16, 4),
	IN A_RMK varchar(100),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_SET_NO varchar(10);
	declare V_MOLD_INPUT_KEY varchar(30);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET V_SET_NO = (select IFNULL(MAX(SET_NO), 0) + 1
    				from TB_MOLD_INPUT
    				where SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d')
    				  and SET_SEQ = A_SET_SEQ);
    				 
  
    SET V_MOLD_INPUT_KEY = CONCAT('DI', DATE_FORMAT(A_SET_DATE, '%Y%m'), LPAD(A_SET_SEQ, 3, '0'), LPAD(V_SET_NO, 3, '0'));
   

    INSERT INTO TB_MOLD_INPUT (
    	COMP_ID,
    	SET_DATE,
    	SET_SEQ,
    	SET_NO,
    	MOLD_INPUT_KEY,
    	CUST_CODE,
    	MOLD_CODE,
    	LOT_YN,
    	QTY,
    	COST,
    	AMT,
    	DEPT_CODE,
#    	IN_QTY,
#    	CALL_KIND,
#    	CALL_KEY,
#    	END_AMT,
    	RMK
    	,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
    ) values (
    	A_COMP_ID,
    	DATE_FORMAT(A_SET_DATE, '%Y%m%d'),
    	LPAD(A_SET_SEQ, 3, '0'),
    	V_SET_NO,
    	V_MOLD_INPUT_KEY,
    	A_CUST_CODE,
    	A_MOLD_CODE,
    	A_LOT_YN,
    	A_QTY,
    	A_COST,
    	A_AMT,
    	A_DEPT_CODE,
    	A_IN_QTY,
    	A_CALL_KIND,
    	A_CALL_KEY,
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