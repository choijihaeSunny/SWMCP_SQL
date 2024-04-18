CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD003$INSERT_MOLD_FORDER_LIST`(		
	IN A_COMP_ID varchar(10),
	IN A_SET_DATE TIMESTAMP,
	IN A_SET_SEQ varchar(4),
	IN A_MOLD_MORDER_KEY varchar(30),
	IN A_MOLD_CODE varchar(20),
	IN A_CUST_CODE varchar(10),
	IN A_QTY decimal(10, 0),
	IN A_DELI_DATE TIMESTAMP,
	IN A_COST decimal(16, 4),
	IN A_AMT decimal(16, 4),
	IN A_EMP_NO varchar(10),
	IN A_DEPT_CODE varchar(10),
	IN A_RMK varchar(100),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_SET_NO varchar(10);
	declare A_MOLD_MORDER_KEY varchar(30);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
  	SET V_SET_NO = (select IFNULL(MAX(SET_NO), 0) + 1
    				from TB_MOLD_FORDER
    				where SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d')
    				  and SET_SEQ = A_SET_SEQ);
  
    SET A_MOLD_MORDER_KEY := CONCAT('DO', DATE_FORMAT(A_SET_DATE, '%Y%m'), LPAD(A_SET_SEQ, 3, '0'), LPAD(V_SET_NO, 3, '0'));
   
  	
    INSERT INTO TB_MOLD_FORDER (
    	COMP_ID,
    	SET_DATE,
    	SET_SEQ,
    	SET_NO,
    	MOLD_MORDER_KEY,
    	MOLD_CODE,
    	CUST_CODE,
    	QTY,
    	DELI_DATE,
    	COST,
    	AMT,
    	EMP_NO,
    	DEPT_CODE,
    	RMK
    	,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
    ) values (
    	A_COMP_ID,
    	DATE_FORMAT(A_SET_DATE, '%Y%m%d'),
    	LPAD(A_SET_SEQ, 3, '0'),
    	V_SET_NO,
    	A_MOLD_MORDER_KEY,
    	A_MOLD_CODE,
    	A_CUST_CODE,
    	A_QTY,
    	DATE_FORMAT(A_DELI_DATE, '%Y%m%d'),
    	A_COST,
    	A_AMT,
    	A_EMP_NO,
    	A_DEPT_CODE,
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