CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC110$DELETE_INPUT_ETC_DET_LIST`(		
	IN A_COMP_ID varchar(10),
-- 	IN A_SET_DATE TIMESTAMP,
-- 	IN A_SET_SEQ varchar(4),
    IN A_INPUT_ETC_MST_KEY varchar(30),
    IN A_INPUT_ETC_KEY varchar(30),
    IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_WARE_CODE bigint(20);
	declare V_ITEM_CODE varchar(30);
	declare V_LOT_NO varchar(30);
	declare V_AMT decimal(16, 4);
	declare V_QTY decimal(10, 0);
	declare V_COST decimal(16, 4);
	declare V_INPUT_DATE varchar(8);
	
	declare V_IO_GUBN bigint(20);
    declare V_CUST_CODE varchar(10);
	
	declare N_SUBUL_RETURN INT;
	declare V_SUBUL_RETURN VARCHAR(4000);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
  	select
		  ware_code, item_code, lot_no, amt, qty,
		  cost, input_date
	into V_WARE_CODE, V_ITEM_CODE, V_LOT_NO, V_AMT, V_QTY,
		 V_COST, V_INPUT_DATE
	from tb_input_etc_det
	where COMP_ID = A_COMP_ID
      and INPUT_ETC_MST_KEY = A_INPUT_ETC_MST_KEY
      and INPUT_ETC_KEY = A_INPUT_ETC_KEY
	;
  
  	delete from TB_INPUT_ETC_DET
    where COMP_ID = A_COMP_ID
      and INPUT_ETC_MST_KEY = A_INPUT_ETC_MST_KEY
      and INPUT_ETC_KEY = A_INPUT_ETC_KEY
    ;
   
    SET V_CUST_CODE = (select CUST_CODE
   					   from TB_INPUT_ETC_MST
   					   where INPUT_ETC_MST_KEY = A_INPUT_ETC_MST_KEY);
   					  
	SET V_IO_GUBN = (select DATA_ID
					 from sys_data
					 where full_path = 'cfg.com.io.mat.in.etc');
	
    call SP_SUBUL_CREATE(
   		A_COMP_ID,-- A_COMP_ID VARCHAR(10),
        A_INPUT_ETC_KEY,-- A_KEY_VAL VARCHAR(100),
        'DELETE', -- A_SAVE_DIV VARCHAR(10),
        DATE_FORMAT(V_SET_DATE, '%Y%m%d'), -- V_IO_DATE VARCHAR(8),
        1, -- V_-- IN_OUT VARCHAR(1),
        V_WARE_CODE, -- V_WARE_CODE big--t,        
        null, -- V_ITEM_K--D big--t,
        V_ITEM_CODE, -- V_ITEM_CODE VARCHAR(30),
        V_LOT_NO, -- V_LOT_NO VARCHAR(30),
        100, -- V_PROG_CODE big--t,
        V_IO_GUBN, -- V_IO_GUBN	big--t,
        V_QTY, -- V_IO_QTY		DECIMAL,
        V_COST,-- V_IO_PRC		DECIMAL,
        V_AMT,-- V_IO_AMT		DECIMAL,
        null, -- V_TABLE_NAME	VARCHAR(50),
        null, -- V_TABLE_KEY	VARCHAR(100),
        'Y', -- V_STOCK_YN	VARCHAR(1),
        1, -- V_IO_RATE	DECIMAL, -- 환율은 해외와 거래하지 않는 이상 1
        null, -- V_ITEM_CODE_UP	VARCHAR(30),
        V_CUST_CODE, -- A_CUST_CODE		VARCHAR(10),
        'Y', -- V_PRE_STOCK_YN		VARCHAR(1),
        V_INPUT_DATE, -- V_IO_DATE_AC			VARCHAR(8),
        null, -- V_ORDER_KEY			VARCHAR(30),
        'Y', -- V_SUBUL_ORDER_YN		VARCHAR(1),
        'Y', -- V_SUBUL_YN			VARCHAR(1),
        'Y', -- V_STOCK_CHK			VARCHAR(1),
        A_SYS_ID, -- A_SYS_ID decimal(10,0),
		A_SYS_EMP_NO, -- A_SYS_EMP_NO varchar(10),
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