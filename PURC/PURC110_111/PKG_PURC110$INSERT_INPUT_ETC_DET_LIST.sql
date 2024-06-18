CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC110$INSERT_INPUT_ETC_DET_LIST`(		
	IN A_COMP_ID varchar(10),
    IN A_INPUT_ETC_MST_KEY varchar(30),
    IN A_INPUT_DATE TIMESTAMP,
    IN A_ITEM_CODE varchar(30),
    IN A_QTY decimal(10, 0),
    IN A_COST decimal(16, 4),
    IN A_AMT decimal(16, 4),
    IN A_WARE_CODE bigint(20),
    IN A_DEPT_CODE varchar(10),
    IN A_END_AMT decimal(16, 4),
    IN A_RMK varchar(100),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	declare V_INPUT_ETC_KEY varchar(30);
	declare V_SET_DATE varchar(8);
	declare V_SET_SEQ varchar(4);
	declare V_SET_NO varchar(4);
	declare V_LOT_NO varchar(30);

	declare V_IO_GUBN bigint(20);
    declare V_CUST_CODE varchar(10);
   
    declare V_ITEM_KIND bigint(20);

   	declare N_SUBUL_RETURN INT;
	declare V_SUBUL_RETURN VARCHAR(4000);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
  	select
  		  SET_DATE, SET_SEQ, CUST_CODE
  	into V_SET_DATE, V_SET_SEQ, V_CUST_CODE
  	from TB_INPUT_ETC_MST
  	where INPUT_ETC_MST_KEY = A_INPUT_ETC_MST_KEY
  	;
  
  	SET V_SET_NO = (select IFNULL(MAX(SET_NO), 0) + 1
    				from TB_INPUT_ETC_DET
    				where INPUT_ETC_MST_KEY = A_INPUT_ETC_MST_KEY
    				); 	
    			
    SET V_INPUT_ETC_KEY := CONCAT(A_INPUT_ETC_MST_KEY, LPAD(V_SET_NO, 4, '0'));

   					  
   	set V_ITEM_KIND = (select ITEM_KIND
   					   from TB_ITEM_CODE
   					   where ITEM_CODE = A_ITEM_CODE);
   	
   	-- LP(제품:LP,자재:LM,상품:LG,금형:MO) + 년월(4자리:YYMM) + 순번(5자리) + REV(2자리)
--    	set V_LOT_NO = CONCAT('LP', substring(V_SET_DATE, 3, 4), LPAD(V_SET_SEQ, 5, '0'), '00');
   
    CALL PKG_LOT$CREATE_ITEM_LOT_IUD (
    			'INSERT', -- A_SAVE_DIV
    			A_COMP_ID, -- A_COMP_ID
    			null, -- A_LOT_NO -- 새로 생성해야 하므로 null로 넣는다.
    			null, -- A_YYMM
    			null, -- A_LOT_SEQ
    			
    			str_to_date(V_SET_DATE,'%Y%m%d'), -- A_SET_DATE
    			'LP', -- A_LOT_KIND
    			'00', -- A_LOT_REV
    			A_ITEM_CODE, -- A_ITEM_CODE
    			V_CUST_CODE, -- A_IN_CUST -- 매입거래처
    			A_COST, -- A_IN_COST -- 매입단가
    			0, -- A_PROC_COST -- 가공단가
    			null, -- A_LOT_NO_ORI
    			null, -- A_LOT_NO_PRE
    			'NORMAL', -- A_LOT_STATE -- SP_GET_USE_CODE.LOT_STATE 참조. / 정상으로 지정
    			40809, -- A_LOT_STATE_DET --tb_item_lot_det LOT상태DET cfg.code.lot.status / 정상으로 지정
    			A_QTY, -- A_QTY
    			0, -- A_WET
    			'TB_INPUT_ETC_DET', -- A_CREATE_TABLE
    			V_INPUT_ETC_KEY, -- A_CREATE_TABLE_KEY
    			null, -- A_ORDER_KEY -- ???
    			100, -- A_PROG_CURR -- tb_item_lot_det PROG_CODE cfg.code.proc / 재고상태로 지정
    			0, -- A_PROG_SEQ_CURR -- tb_item_lot_det PROG_SEQ -- / 현재 공정 순서
    			167945, -- A_PROG_KIND -- tb_item_lot_det LOT생성사유(cfg.code.lot.init) / 상품입고로 지정
    			'기타재고', -- A_RMK
    			 V_ITEM_KIND, -- A_ITEM_KIND
    			'NEW', -- A_CREATE_DIV
    			 0, -- A_PROD_UNIT_WET
    			 0, -- A_MATR_UNIT_WET
    			 null, -- A_ITEM_CODE_PRE
    			 0, -- A_QTY_PRE
    			 0, -- A_WET_PRE
    			 167945, -- A_LOT_DIVI_KIND -- tb_item_lot_chase  LOT분할통합종류(cfg.code.lot.init) / 상품입고로 지정
    			 'Y', -- A_COM_YN
    			 A_SYS_ID, -- A_SYS_ID
    			 A_SYS_EMP_NO, -- A_SYS_EMP_NO
    			 V_LOT_NO, -- V_LOT_NO
    			 N_RETURN, 
    			 V_RETURN
    		);
   	   
    INSERT INTO TB_INPUT_ETC_DET (
    	COMP_ID,
    	SET_DATE,
    	SET_SEQ,
    	SET_NO,
    	INPUT_ETC_MST_KEY,
    	INPUT_ETC_KEY,
    	INPUT_DATE,
    	ITEM_CODE,
    	LOT_NO,
    	QTY,
    	COST,
    	AMT,
    	WARE_CODE,
    	DEPT_CODE,
    	END_AMT,
    	RMK
    	,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
    ) values (
   		A_COMP_ID,
    	V_SET_DATE,
    	V_SET_SEQ,
    	V_SET_NO,
    	A_INPUT_ETC_MST_KEY,
    	V_INPUT_ETC_KEY,
    	DATE_FORMAT(A_INPUT_DATE, '%Y%m%d'),
    	A_ITEM_CODE,
    	V_LOT_NO,
    	A_QTY,
    	A_COST,
    	A_AMT,
    	A_WARE_CODE,
    	A_DEPT_CODE,
    	A_END_AMT,
    	A_RMK
    	,A_SYS_EMP_NO
    	,A_SYS_ID
    	,SYSDATE()
    )
    ;
  
   
    SET V_IO_GUBN = (select DATA_ID
					 from sys_data
					 where full_path = 'cfg.com.io.mat.in.etc');
					
	SET V_ITEM_KIND = (select ITEM_KIND
					   from TB_ITEM_CODE
					   where ITEM_CODE = A_ITEM_CODE);
   
   	call SP_SUBUL_CREATE(
   		A_COMP_ID,-- A_COMP_ID VARCHAR(10),
        CONCAT('TB_INPUT_ETC_DET-', V_INPUT_ETC_KEY),-- A_KEY_VAL VARCHAR(100),
        'INSERT', -- A_SAVE_DIV VARCHAR(10),
        V_SET_DATE, -- A_IO_DATE VARCHAR(8),
        1, -- A_-- IN_OUT VARCHAR(1),
        A_WARE_CODE, -- A_WARE_CODE big--t,        
        V_ITEM_KIND, -- A_ITEM_K--D big--t, input_etc 에 ITEM_KIND 항목이 없음.
        A_ITEM_CODE, -- A_ITEM_CODE VARCHAR(30),
        V_LOT_NO, -- V_LOT_NO VARCHAR(30),
        100, -- A_PROG_CODE big--t,
        V_IO_GUBN, -- A_IO_GUBN	big--t,
        A_QTY, -- A_IO_QTY		DECIMAL,
        A_COST,-- A_IO_PRC		DECIMAL,
        A_AMT,-- A_IO_AMT		DECIMAL,
        'TB_INPUT_ETC_DET', -- V_TABLE_NAME	VARCHAR(50),
        V_INPUT_ETC_KEY, -- V_TABLE_KEY	VARCHAR(100),
        'Y', -- A_STOCK_YN	VARCHAR(1),
        1, -- A_IO_RATE	DECIMAL, -- 환율은 해외와 거래하지 않는 이상 1
        null, -- A_ITEM_CODE_UP	VARCHAR(30),
        V_CUST_CODE, -- A_CUST_CODE		VARCHAR(10),
        'Y', -- A_PRE_STOCK_YN		VARCHAR(1),
        DATE_FORMAT(A_INPUT_DATE, '%Y%m%d'), -- A_IO_DATE_AC			VARCHAR(8),
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