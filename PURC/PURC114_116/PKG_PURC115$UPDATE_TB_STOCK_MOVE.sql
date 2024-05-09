CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC115$UPDATE_TB_STOCK_MOVE`(		
	IN A_COMP_ID varchar(10),
-- 	IN A_SET_DATE TIMESTAMP,
-- 	IN A_SET_SEQ varchar(4),
	IN A_MOVE_KEY varchar(30),
	IN A_CONFIRM_YN			varchar(1),
   	IN A_RMK varchar(100),
	IN A_UPD_EMP_NO varchar(10),
	IN A_UPD_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_SET_DATE VARCHAR(8);
	declare V_WARE_CODE bigint(20);
	declare V_WARE_CODE_PRE bigint(20);
	declare V_ITEM_KIND varchar(10);
	declare V_ITEM_CODE varchar(20);
	declare V_LOT_NO VARCHAR(30);
	declare V_QTY decimal(10, 0);
	declare V_COST decimal(16, 4);
	declare V_AMT decimal(16, 4);
	declare V_MOVE_DATE varchar(8);
	
	declare V_IO_GUBN bigint(20);
	declare V_CUST_CODE varchar(10);
	
	declare N_SUBUL_RETURN INT;
	declare V_SUBUL_RETURN VARCHAR(4000);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
 
   
    UPDATE TB_STOCK_MOVE
    	SET
	    	CONFIRM_YN = A_CONFIRM_YN,
	    	CONFIRM_EMP = A_UPD_EMP_NO,
	    	CONFIRM_DT = SYSDATE(),
	   		RMK = A_RMK
	    	,UPD_EMP_NO = A_UPD_EMP_NO
	    	,UPD_ID = A_UPD_ID
	    	,UPD_DATE = SYSDATE()
	where COMP_ID = A_COMP_ID
	  and MOVE_KEY = A_MOVE_KEY
    ;
   
   	select
   		  SET_DATE, WARE_CODE, WARE_CODE_PRE, ITEM_KIND, ITEM_CODE, 
   		  LOT_NO, QTY, COST, AMT, MOVE_DATE
   	into 
   		V_SET_DATE, V_WARE_CODE, V_WARE_CODE_PRE, V_ITEM_KIND, V_ITEM_CODE, 
   		V_LOT_NO, V_QTY, V_COST, V_AMT, V_MOVE_DATE
   	from TB_STOCK_MOVE
   	where COMP_ID = A_COMP_ID
	  and MOVE_KEY = A_MOVE_KEY
    ; 
   
    SET V_IO_GUBN = (select DATA_ID
					 from sys_data
					 where full_path = 'cfg.com.io.mat.in.mov');
	
	-- 창고이동 등록 후 확정 시 수불이 확정된다.
	-- 이동확정처리시 수불은 2번 발생한다.
	-- (1) 이동전창고(WARE_CODE_PRE) 에서 출고처리 수불이 발생(INSERT)한다.
	-- (2) 이동후창고(WARE_CODE) 에서 입고처리 수불이 발생(INSERT) 한다.
	-- 이동확정 취소시 DELETE 쿼리가 두 번 발생한다.
					
					
	if A_CONFIRM_YN = 'Y' then
		call SP_SUBUL_CREATE(
	   		A_COMP_ID,-- A_COMP_ID VARCHAR(10),
	        CONCAT('TB_STOCK_MOVE-', A_MOVE_KEY, '-OUT'),-- A_KEY_VAL VARCHAR(100),
	        'INSERT', -- A_SAVE_DIV VARCHAR(10),
	        V_SET_DATE, -- A_IO_DATE VARCHAR(8),
	        2, -- A_-- IN_OUT VARCHAR(1),
	        V_WARE_CODE_PRE, -- A_WARE_CODE big--t, -- 이동전창고에서 출고처리 수불이 발생한다.       
	        V_ITEM_KIND, -- A_ITEM_K--D big--t, input_etc 에 ITEM_KIND 항목이 없음.
	        V_ITEM_CODE, -- A_ITEM_CODE VARCHAR(30),
	        V_LOT_NO, -- A_LOT_NO VARCHAR(30),
	        100, -- A_PROG_CODE big--t,
	        V_IO_GUBN, -- A_IO_GUBN	big--t,
	        V_QTY, -- A_IO_QTY		DECIMAL,
	        V_COST,-- A_IO_PRC		DECIMAL,
	        V_AMT,-- A_IO_AMT		DECIMAL,
	        'TB_STOCK_MOVE', -- A_TABLE_NAME	VARCHAR(50),
	        A_MOVE_KEY, -- A_TABLE_KEY	VARCHAR(100),
	        'Y', -- A_STOCK_YN	VARCHAR(1),
	        1, -- A_IO_RATE	DECIMAL, -- 환율은 해외와 거래하지 않는 이상 1
	        null, -- A_ITEM_CODE_UP	VARCHAR(30),
	        V_CUST_CODE, -- A_CUST_CODE		VARCHAR(10),
	        'Y', -- A_PRE_STOCK_YN		VARCHAR(1),
	        V_MOVE_DATE, -- A_IO_DATE_AC			VARCHAR(8),
	        null, -- A_ORDER_KEY			VARCHAR(30),
	        'Y', -- A_SUBUL_ORDER_YN		VARCHAR(1),
	        'Y', -- A_SUBUL_YN			VARCHAR(1),
	        'Y', -- A_STOCK_CHK			VARCHAR(1),
	        A_UPD_ID, -- A_SYS_ID decimal(10,0),
			A_UPD_EMP_NO, -- A_SYS_EMP_NO varchar(10),
			N_SUBUL_RETURN,
	    	V_SUBUL_RETURN
	   	);
	   
	   call SP_SUBUL_CREATE(
	   		A_COMP_ID,-- A_COMP_ID VARCHAR(10),
	        CONCAT('TB_STOCK_MOVE-', A_MOVE_KEY, '-IN'),-- A_KEY_VAL VARCHAR(100),
	        'INSERT', -- A_SAVE_DIV VARCHAR(10),
	        V_SET_DATE, -- A_IO_DATE VARCHAR(8),
	        1, -- A_-- IN_OUT VARCHAR(1),
	        V_WARE_CODE, -- A_WARE_CODE big--t, -- 이동후창고에서 입고처리 수불이 발생한다.       
	        V_ITEM_KIND, -- A_ITEM_K--D big--t, input_etc 에 ITEM_KIND 항목이 없음.
	        V_ITEM_CODE, -- A_ITEM_CODE VARCHAR(30),
	        V_LOT_NO, -- A_LOT_NO VARCHAR(30),
	        100, -- A_PROG_CODE big--t,
	        V_IO_GUBN, -- A_IO_GUBN	big--t,
	        V_QTY, -- A_IO_QTY		DECIMAL,
	        V_COST,-- A_IO_PRC		DECIMAL,
	        V_AMT,-- A_IO_AMT		DECIMAL,
	        'TB_STOCK_MOVE', -- A_TABLE_NAME	VARCHAR(50),
	        A_MOVE_KEY, -- A_TABLE_KEY	VARCHAR(100),
	        'Y', -- A_STOCK_YN	VARCHAR(1),
	        1, -- A_IO_RATE	DECIMAL, -- 환율은 해외와 거래하지 않는 이상 1
	        null, -- A_ITEM_CODE_UP	VARCHAR(30),
	        V_CUST_CODE, -- A_CUST_CODE		VARCHAR(10),
	        'Y', -- A_PRE_STOCK_YN		VARCHAR(1),
	        V_MOVE_DATE, -- A_IO_DATE_AC			VARCHAR(8),
	        null, -- A_ORDER_KEY			VARCHAR(30),
	        'Y', -- A_SUBUL_ORDER_YN		VARCHAR(1),
	        'Y', -- A_SUBUL_YN			VARCHAR(1),
	        'Y', -- A_STOCK_CHK			VARCHAR(1),
	        A_UPD_ID, -- A_SYS_ID decimal(10,0),
			A_UPD_EMP_NO, -- A_SYS_EMP_NO varchar(10),
			N_SUBUL_RETURN,
	    	V_SUBUL_RETURN
	   	);
	else
		call SP_SUBUL_CREATE(
	   		A_COMP_ID,-- A_COMP_ID VARCHAR(10),
	        CONCAT('TB_STOCK_MOVE-', A_MOVE_KEY, '-OUT'),-- A_KEY_VAL VARCHAR(100),
	        'DELETE', -- A_SAVE_DIV VARCHAR(10),
	        V_SET_DATE, -- A_IO_DATE VARCHAR(8),
	        2, -- A_-- IN_OUT VARCHAR(1),
	        V_WARE_CODE_PRE, -- A_WARE_CODE big--t, -- 이동전창고에서 출고처리 수불이 삭제한다.       
	        V_ITEM_KIND, -- A_ITEM_K--D big--t, input_etc 에 ITEM_KIND 항목이 없음.
	        V_ITEM_CODE, -- A_ITEM_CODE VARCHAR(30),
	        V_LOT_NO, -- A_LOT_NO VARCHAR(30),
	        100, -- A_PROG_CODE big--t,
	        V_IO_GUBN, -- A_IO_GUBN	big--t,
	        V_QTY, -- A_IO_QTY		DECIMAL,
	        V_COST,-- A_IO_PRC		DECIMAL,
	        V_AMT,-- A_IO_AMT		DECIMAL,
	        'TB_STOCK_MOVE', -- A_TABLE_NAME	VARCHAR(50),
	        A_MOVE_KEY, -- A_TABLE_KEY	VARCHAR(100),
	        'Y', -- A_STOCK_YN	VARCHAR(1),
	        1, -- A_IO_RATE	DECIMAL, -- 환율은 해외와 거래하지 않는 이상 1
	        null, -- A_ITEM_CODE_UP	VARCHAR(30),
	        V_CUST_CODE, -- A_CUST_CODE		VARCHAR(10),
	        'Y', -- A_PRE_STOCK_YN		VARCHAR(1),
	        V_MOVE_DATE, -- A_IO_DATE_AC			VARCHAR(8),
	        null, -- A_ORDER_KEY			VARCHAR(30),
	        'Y', -- A_SUBUL_ORDER_YN		VARCHAR(1),
	        'Y', -- A_SUBUL_YN			VARCHAR(1),
	        'Y', -- A_STOCK_CHK			VARCHAR(1),
	        A_UPD_ID, -- A_SYS_ID decimal(10,0),
			A_UPD_EMP_NO, -- A_SYS_EMP_NO varchar(10),
			N_SUBUL_RETURN,
	    	V_SUBUL_RETURN
	   	);
	   
	   call SP_SUBUL_CREATE(
	   		A_COMP_ID,-- A_COMP_ID VARCHAR(10),
	        CONCAT('TB_STOCK_MOVE-', A_MOVE_KEY, '-IN'),-- A_KEY_VAL VARCHAR(100),
	        'DELETE', -- A_SAVE_DIV VARCHAR(10),
	        V_SET_DATE, -- A_IO_DATE VARCHAR(8),
	        1, -- A_-- IN_OUT VARCHAR(1),
	        V_WARE_CODE, -- A_WARE_CODE big--t, -- 이동후창고에서 입고처리 수불이 삭제한다.       
	        V_ITEM_KIND, -- A_ITEM_K--D big--t, input_etc 에 ITEM_KIND 항목이 없음.
	        V_ITEM_CODE, -- A_ITEM_CODE VARCHAR(30),
	        V_LOT_NO, -- A_LOT_NO VARCHAR(30),
	        100, -- A_PROG_CODE big--t,
	        V_IO_GUBN, -- A_IO_GUBN	big--t,
	        V_QTY, -- A_IO_QTY		DECIMAL,
	        V_COST,-- A_IO_PRC		DECIMAL,
	        V_AMT,-- A_IO_AMT		DECIMAL,
	        'TB_STOCK_MOVE', -- A_TABLE_NAME	VARCHAR(50),
	        A_MOVE_KEY, -- A_TABLE_KEY	VARCHAR(100),
	        'Y', -- A_STOCK_YN	VARCHAR(1),
	        1, -- A_IO_RATE	DECIMAL, -- 환율은 해외와 거래하지 않는 이상 1
	        null, -- A_ITEM_CODE_UP	VARCHAR(30),
	        V_CUST_CODE, -- A_CUST_CODE		VARCHAR(10),
	        'Y', -- A_PRE_STOCK_YN		VARCHAR(1),
	        V_MOVE_DATE, -- A_IO_DATE_AC			VARCHAR(8),
	        null, -- A_ORDER_KEY			VARCHAR(30),
	        'Y', -- A_SUBUL_ORDER_YN		VARCHAR(1),
	        'Y', -- A_SUBUL_YN			VARCHAR(1),
	        'Y', -- A_STOCK_CHK			VARCHAR(1),
	        A_UPD_ID, -- A_SYS_ID decimal(10,0),
			A_UPD_EMP_NO, -- A_SYS_EMP_NO varchar(10),
			N_SUBUL_RETURN,
	    	V_SUBUL_RETURN
	   	);
	end if;
    
   
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