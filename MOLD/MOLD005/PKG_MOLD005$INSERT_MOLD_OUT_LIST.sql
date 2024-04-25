CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD005$INSERT_MOLD_OUT_LIST`(		
	IN A_COMP_ID varchar(10),
	IN A_SET_DATE TIMESTAMP,
	IN A_SET_SEQ varchar(4),
	IN A_CUST_CODE varchar(10),
	IN A_MOLD_CODE varchar(20),
	IN A_LOT_NO varchar(30),
	IN A_QTY decimal(10, 0),
	IN A_COST decimal(16, 4),
	IN A_AMT decimal(16, 4),
	IN A_DEPT_CODE varchar(10),
	IN A_RMK varchar(100),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_SET_NO varchar(10);
	declare A_MOLD_OUT_KEY varchar(30);
	declare V_MOLD_OUT_KEY varchar(30);

	declare N_SUBUL_RETURN INT;
	declare V_SUBUL_RETURN VARCHAR(4000);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
  	SET V_SET_NO = (select IFNULL(MAX(SET_NO), 0) + 1
    				from TB_MOLD_OUT
    				where SET_DATE = DATE_FORMAT(SET_DATE, '%Y%m%d')
    				  and SET_SEQ = SET_SEQ);
  
    SET V_MOLD_OUT_KEY := CONCAT('DS', right(DATE_FORMAT(SET_DATE, '%Y%m'), 4), LPAD(SET_SEQ, 3, '0'), LPAD(V_SET_NO, 3, '0'));
   
  	
    INSERT INTO TB_MOLD_OUT (
    	COMP_ID,
    	SET_DATE,
    	SET_SEQ,
    	SET_NO,
    	MOLD_OUT_KEY,
    	CUST_CODE,
    	MOLD_CODE,
    	LOT_NO,
    	QTY,
    	COST,
    	AMT,
    	DEPT_CODE,
    	RMK
    	,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
    ) values (
    	COMP_ID,
    	DATE_FORMAT(A_SET_DATE, '%Y%m%d'),
    	LPAD(A_SET_SEQ, 3, '0'),
    	V_SET_NO,
    	V_MOLD_OUT_KEY,
    	A_CUST_CODE,
    	A_MOLD_CODE,
    	A_LOT_NO,
    	A_QTY,
    	A_COST,
    	A_AMT,
    	A_DEPT_CODE,
    	A_RMK
    	,A_SYS_EMP_NO
    	,A_SYS_ID
    	,SYSDATE()
    )
    ;
   
   	call SP_SUBUL_MOLD_CREATE(
   		A_COMP_ID, -- A_COMP_ID
   		V_MOLD_OUT_KEY, -- A_KEY_VAL
   		2, -- A_IN_OUT 
   		'01', -- A_WARE_CODE -- cfg.com.wh.kind 금형은 무조건 01로 입력.
   		A_LOT_NO, -- A_LOT_NO 
   		2, -- IO_GUBN ?? 입출고 구분
   		A_QTY, -- IO_QTY 수량
   		A_COST, -- A_IO_PRC 단가
   		A_AMT, -- A_IO_AMT
   		null, -- A_TABLE_NAME 
   		null, -- A_TABLE_KEY
   		'Y', -- A_STOCK_YN 재고반영
   		A_CUST_CODE, -- A_CUST_CODE
   		'01', -- A_WARE_POS    		
   		'Y', -- A_SUBUL_YN
   		'INSERT', -- A_SAVE_DIV
   		DATE_FORMAT(SYSDATE(), '%Y%m%d'), -- A_IO_DATE -- 수불 발생일자
   		'Y', -- A_STOCK_CHK
   		A_MOLD_CODE, -- A_MOLD_CODE
   		A_SYS_EMP_NO, -- A_SYS_EMP_NO
   		A_SYS_ID, -- A_SYS_ID
   		N_SUBUL_RETURN,
   		V_SUBUL_RETURN
	);
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end