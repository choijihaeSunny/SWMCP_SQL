CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC110$UPDATE_INPUT_ETC_DET_LIST`(		
	IN A_COMP_ID varchar(10),
-- 	IN A_SET_DATE TIMESTAMP,
-- 	IN A_SET_SEQ varchar(4),
    IN A_INPUT_ETC_MST_KEY varchar(30),
    IN A_INPUT_ETC_KEY varchar(30),
    IN A_INPUT_DATE TIMESTAMP,
    IN A_ITEM_CODE varchar(30),
    IN A_LOT_NO varchar(30),
    IN A_QTY decimal(10, 0),
    IN A_COST decimal(16, 4),
    IN A_AMT decimal(16, 4),
    IN A_WARE_CODE bigint(20),
    IN A_DEPT_CODE varchar(10),
    IN A_END_AMT decimal(16, 4),
    IN A_RMK varchar(100),
	IN A_UPD_EMP_NO varchar(10),
	IN A_UPD_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_AMT decimal(16, 4);
	declare V_IO_GUBN bigint(20);
	declare V_WARE_CODE bigint(20);
    declare V_CUST_CODE varchar(10);
	
	declare N_SUBUL_RETURN INT;
	declare V_SUBUL_RETURN VARCHAR(4000);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
  	set V_AMT = A_QTY * A_COST; -- 단가 * 갯수 = 금액
   	
   	set V_WARE_CODE = (select WARE_CODE
   					   from DEPT_CODE
   					   where DEPT_CODE = A_DEPT_CODE);
  
  	update TB_INPUT_ETC_DET
  		set COMP_ID = A_COMP_ID
#	    	,SET_DATE = A_SET_DATE
#	    	,SET_SEQ = A_SET_SEQ
#	    	,SET_NO = A_
#	    	,INPUT_ETC_MST_KEY = A_INPUT_ETC_MST_KEY
#	    	,INPUT_ETC_KEY = A_INPUT_ETC_KEY
	    	,INPUT_DATE = DATE_FORMAT(A_INPUT_DATE, '%Y%m%d')
	    	,ITEM_CODE = A_ITEM_CODE
	    	,LOT_NO = A_LOT_NO
	    	,QTY = A_QTY
	    	,COST = A_COST
	    	,AMT = A_AMT
	    	,WARE_CODE = A_WARE_CODE
	    	,DEPT_CODE = A_DEPT_CODE
	    	,END_AMT = A_END_AMT
	    	,RMK = A_RMK
	    	,UPD_EMP_NO = A_UPD_EMP_NO
	    	,UPD_ID = A_UPD_ID
	    	,UPD_DATE = SYSDATE()
    where COMP_ID = A_COMP_ID
      and INPUT_ETC_MST_KEY = A_INPUT_ETC_MST_KEY
      and INPUT_ETC_KEY = A_INPUT_ETC_KEY
    ;
   
    SET V_CUST_CODE = (select CUST_CODE
   					   from TB_INPUT_ETC_MST
   					   where INPUT_ETC_MST_KEY = A_INPUT_ETC_MST_KEY);
   
    SET V_IO_GUBN = (select DATA_ID
					 from sys_data
					 where path = 'cfg.com.io.mat.in.etc');
   
   	call SP_SUBUL_CREATE(
   		A_COMP_ID,-- A_COMP_ID VARCHAR(10),
        V_INPUT_ETC_KEY,-- A_KEY_VAL VARCHAR(100),
        'UPDATE', -- A_SAVE_DIV VARCHAR(10),
        DATE_FORMAT(A_SET_DATE, '%Y%m%d'), -- A_IO_DATE VARCHAR(8),
        1, -- A_-- IN_OUT VARCHAR(1),
        V_WARE_CODE, -- A_WARE_CODE big--t,        
        null, -- A_ITEM_K--D big--t, input_etc 에 ITEM_KIND 항목이 없음.
        A_ITEM_CODE, -- A_ITEM_CODE VARCHAR(30),
        A_LOT_NO, -- A_LOT_NO VARCHAR(30),
        100, -- A_PROG_CODE big--t,
        V_IO_GUBN, -- A_IO_GUBN	big--t,
        A_QTY, -- A_IO_QTY		DECIMAL,
        A_COST,-- A_IO_PRC		DECIMAL,
        V_AMT,-- A_IO_AMT		DECIMAL,
        null, -- A_TABLE_NAME	VARCHAR(50),
        null, -- A_TABLE_KEY	VARCHAR(100),
        'Y', -- A_STOCK_YN	VARCHAR(1),
        1, -- A_IO_RATE	DECIMAL, -- 환율은 해외와 거래하지 않는 이상 1
        null, -- A_ITEM_CODE_UP	VARCHAR(30),
        V_CUST_CODE, -- A_CUST_CODE		VARCHAR(10),
        'Y', -- A_PRE_STOCK_YN		VARCHAR(1),
        DATE_FORMAT(A_RETURN_DATE, '%Y%m%d'), -- A_IO_DATE_AC			VARCHAR(8),
        null, -- A_ORDER_KEY			VARCHAR(30),
        'Y', -- A_SUBUL_ORDER_YN		VARCHAR(1),
        'Y', -- A_SUBUL_YN			VARCHAR(1),
        'Y', -- A_STOCK_CHK			VARCHAR(1),
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