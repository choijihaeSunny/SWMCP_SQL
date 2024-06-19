CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD003$INSERT_MOLD_FORDER_LIST`(		
	IN A_COMP_ID varchar(10),
	IN A_SET_DATE TIMESTAMP,
	IN A_SET_SEQ varchar(4),
	IN A_MOLD_CODE varchar(20),
	IN A_CUST_CODE varchar(10),
	IN A_QTY decimal(10, 0),
	IN A_DELI_DATE TIMESTAMP,
	IN A_COST decimal(16, 4),
	IN A_AMT decimal(16, 4),
	IN A_EMP_NO varchar(10),
	IN A_DEPT_CODE varchar(10),
	IN A_CALL_KEY varchar(30),
	IN A_RMK varchar(100),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_SET_NO varchar(10);
	declare V_MOLD_MORDER_KEY varchar(30);

	declare V_DUP_CNT INT;

	declare V_IO_GUBN bigint(20);

	declare N_SUBUL_RETURN INT;
	declare V_SUBUL_RETURN VARCHAR(4000);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
  	SET V_SET_NO = (select IFNULL(MAX(SET_NO), 0) + 1
    				from TB_MOLD_FORDER
    				where SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d')
    				  and SET_SEQ = A_SET_SEQ);
  
    SET V_MOLD_MORDER_KEY = CONCAT('DO', right(DATE_FORMAT(A_SET_DATE, '%Y%m'), 4), LPAD(A_SET_SEQ, 3, '0'), LPAD(V_SET_NO, 3, '0'));
   
    SET V_DUP_CNT = (select COUNT(*)
    				 from TB_MOLD_FORDER
   					 where MOLD_MORDER_KEY = V_MOLD_MORDER_KEY
    				);
    if V_DUP_CNT <> 0 then
    	set V_SET_NO = V_SET_NO + 1;
    	SET V_MOLD_MORDER_KEY = CONCAT('DO', right(DATE_FORMAT(A_SET_DATE, '%Y%m'), 4), LPAD(A_SET_SEQ, 3, '0'), LPAD(V_SET_NO, 3, '0'));
    end if;
   
  	
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
    	IN_QTY,
    	CALL_KEY,
    	RMK
    	,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
    ) values (
    	A_COMP_ID,
    	DATE_FORMAT(A_SET_DATE, '%Y%m%d'),
    	LPAD(A_SET_SEQ, 3, '0'),
    	V_SET_NO,
    	V_MOLD_MORDER_KEY,
    	A_MOLD_CODE,
    	A_CUST_CODE,
    	A_QTY,
    	DATE_FORMAT(A_DELI_DATE, '%Y%m%d'),
    	A_COST,
    	A_AMT,
    	A_EMP_NO,
    	A_DEPT_CODE,
    	A_QTY,
    	A_CALL_KEY,
    	A_RMK
    	,A_SYS_EMP_NO
    	,A_SYS_ID
    	,SYSDATE()
    )
    ;
   
   	SET V_IO_GUBN = (select DATA_ID
					 from SYS_DATA
					 where path = 'cfg.com.io.mold.in.in');
   
   	call SP_SUBUL_MOLD_CREATE(
    		A_COMP_ID, -- A_COMP_ID
    		CONCAT('TB_MOLD_FORDER-', V_MOLD_MORDER_KEY), -- A_KEY_VAL
    		1, -- A_IN_OUT 
    		'01', -- A_WARE_CODE -- cfg.com.wh.kind 금형은 무조건 01로 입력.
    		A_MOLD_CODE, -- A_LOT_NO --  금형 LOT관리 안 하는 내역 LOT NO는 금형코드로 관리.
    		V_IO_GUBN, -- IO_GUBN ?? 입출고 구분
    		A_QTY, -- IO_QTY 수량
    		A_COST, -- A_IO_PRC 단가
    		A_AMT, -- A_IO_AMT
    		'TB_MOLD_FORDER', -- A_TABLE_NAME
    		V_MOLD_MORDER_KEY, -- A_TABLE_KEY
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
      SET V_RETURN = V_SUBUL_RETURN; -- '저장이 실패하였습니다.'; 
    ELSE
    
    	-- 수불처리 실패한 경우
    	if N_SUBUL_RETURN <> 0 then
    		SET N_RETURN = -1;
      		SET V_RETURN = V_SUBUL_RETURN; 
    	end if;
  	END IF;  
  
end