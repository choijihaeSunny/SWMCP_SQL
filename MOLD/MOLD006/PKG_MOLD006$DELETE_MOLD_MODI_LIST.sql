CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD006$DELETE_MOLD_MODI_LIST`(		
	IN A_COMP_ID varchar(10),
	IN A_MOLD_MODI_KEY varchar(30),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_LOT_STATE varchar(10);
	declare V_MODI_DIV varchar(10);
	declare V_MODI_DIV_CODE varchar(10);
	declare V_MODI_STATUS varchar(10);
	declare V_MODI_STATUS_CODE varchar(10);

	declare V_LOT_NO varchar(20);
	declare V_LOT_NO_PRE varchar(20);
	declare V_LOT_NO_AFT varchar(20);
	declare V_QTY decimal(10, 0);
	declare V_COST decimal(16, 4);
	declare V_AMT decimal(16, 4);
	declare V_QTY_PRE decimal(10, 0);
	declare V_COST_PRE decimal(16, 4);
	declare V_CUST_CODE varchar(10);
	declare V_MOLD_CODE varchar(30);
	
	declare V_IO_GUBN bigint(20);

	declare N_SUBUL_RETURN INT;
	declare V_SUBUL_RETURN VARCHAR(4000);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
   
 	
					   		
	 select LOT_NO, LOT_NO_AFT,
	 		QTY, COST, AMT,
	 		CUST_CODE, MOLD_CODE,
	 		MODI_DIV,
	 		MODI_STATUS
	 into V_LOT_NO, V_LOT_NO_AFT,
	 	  V_QTY, V_COST, V_AMT,
	 	  V_CUST_CODE, V_MOLD_CODE,
	 	  V_MODI_DIV, V_MODI_STATUS
	 from TB_MOLD_MODI
	 where MOLD_MODI_KEY = A_MOLD_MODI_KEY
	 ;
	
	set V_MODI_DIV_CODE = (select CODE
						   from SYS_DATA
						   where path = 'cfg.mold.modi'
						     and DATA_ID = V_MODI_DIV);
	 
   	 -- 수리/수정상태
   	set V_MODI_STATUS_CODE = (select CODE
	   					      from SYS_DATA
	   					      where path = 'cfg.mold.modistatus'
	   					        and DATA_ID = V_MODI_STATUS);		
  
	 DELETE FROM TB_MOLD_MODI
	 WHERE COMP_ID = A_COMP_ID
	   and MOLD_MODI_KEY = A_MOLD_MODI_KEY
	 ;
	
	 set V_LOT_STATE = (select DATA_ID
						  from SYS_DATA
					     where path = 'cfg.mold.lotstate'
						   and CODE = 'N');
							    
	if V_MODI_DIV = 'M' then
		update TB_MOLD_LOT
		   set LOT_STATE = V_LOT_STATE
		 where COMP_ID = A_COMP_ID
		   and CREATE_TABLE = 'TB_MOLD_MODI'
		   and CREATE_TABLE_KEY = A_MOLD_MODI_KEY
		;
	end if
	;
	

	if V_MODI_DIV_CODE = 'M' and V_MODI_STATUS_CODE = 'C' then
	
		SET V_IO_GUBN = (select DATA_ID
						 from SYS_DATA
						 where full_path = 'cfg.com.io.mold.out.out');
						
		-- 폐기된 LOT_NO는 출고처리한다.
		call SP_SUBUL_MOLD_CREATE( 
    		A_COMP_ID, -- A_COMP_ID
    		CONCAT('TB_MOLD_MODI-', A_MOLD_MODI_KEY), -- A_KEY_VAL
    		2, -- A_IN_OUT 
    		'01', -- A_WARE_CODE -- cfg.com.wh.kind 금형은 무조건 01로 입력.
    		V_LOT_NO, -- A_LOT_NO -
    		V_IO_GUBN, -- IO_GUBN
    		V_QTY, -- IO_QTY 수량
    		V_COST, -- A_IO_PRC 단가
    		V_AMT, -- A_IO_AMT
    		'TB_MOLD_MODI', -- A_TABLE_NAME
    		A_MOLD_MODI_KEY, -- A_TABLE_KEY
    		'Y', -- A_STOCK_YN 재고반영
    		V_CUST_CODE, -- V_CUST_CODE
    		null, -- A_WARE_POS    		
    		'Y', -- A_SUBUL_YN
    		'DELETE', -- A_SAVE_DIV
    		DATE_FORMAT(SYSDATE(), '%Y%m%d'), -- A_IO_DATE -- 수불 발생일자
    		'Y', -- A_STOCK_CHK
    		V_MOLD_CODE, -- V_MOLD_CODE
    		A_SYS_EMP_NO, -- A_SYS_EMP_NO
    		A_SYS_ID, -- A_SYS_ID
    		N_SUBUL_RETURN,
    		V_SUBUL_RETURN
    	);
    
    	
    	select 
    		  LOT_NO_PRE, QTY, IN_COST
    	into
    		V_LOT_NO_PRE, V_QTY_PRE, V_COST_PRE
    	from TB_MOLD_LOT
    	where LOT_NO = V_LOT_NO_AFT
    	;
    
    
    	call SP_SUBUL_MOLD_CREATE( 
    		A_COMP_ID, -- A_COMP_ID
    		CONCAT('TB_MOLD_MODI-', A_MOLD_MODI_KEY), -- A_KEY_VAL
    		2, -- A_IN_OUT 
    		'01', -- A_WARE_CODE -- cfg.com.wh.kind 금형은 무조건 01로 입력.
    		V_LOT_NO_PRE, -- A_LOT_NO -
    		V_IO_GUBN, -- IO_GUBN
    		V_QTY_PRE, -- IO_QTY 수량
    		V_COST_PRE, -- A_IO_PRC 단가
    		(V_QTY_PRE * V_COST_PRE), -- A_IO_AMT
    		'TB_MOLD_MODI', -- A_TABLE_NAME
    		A_MOLD_MODI_KEY, -- A_TABLE_KEY
    		'Y', -- A_STOCK_YN 재고반영
    		V_CUST_CODE, -- V_CUST_CODE
    		null, -- A_WARE_POS    		
    		'Y', -- A_SUBUL_YN
    		'DELETE', -- A_SAVE_DIV
    		DATE_FORMAT(SYSDATE(), '%Y%m%d'), -- A_IO_DATE -- 수불 발생일자
    		'Y', -- A_STOCK_CHK
    		V_MOLD_CODE, -- V_MOLD_CODE
    		A_SYS_EMP_NO, -- A_SYS_EMP_NO
    		A_SYS_ID, -- A_SYS_ID
    		N_SUBUL_RETURN,
    		V_SUBUL_RETURN
    	);
	
    	SET V_IO_GUBN = (select DATA_ID
						 from SYS_DATA
						 where full_path = 'cfg.com.io.mold.in.in');
					
    	-- 수정된 LOTNO를 입고처리한다
		call SP_SUBUL_MOLD_CREATE( 
    		A_COMP_ID, -- A_COMP_ID
    		CONCAT('TB_MOLD_MODI-', A_MOLD_MODI_KEY), -- A_KEY_VAL
    		1, -- A_IN_OUT 
    		'01', -- A_WARE_CODE -- cfg.com.wh.kind 금형은 무조건 01로 입력.
    		V_LOT_NO_AFT, -- A_LOT_NO
    		V_IO_GUBN, -- IO_GUBN 
    		V_QTY, -- IO_QTY 수량
    		V_COST, -- A_IO_PRC 단가
    		V_AMT, -- A_IO_AMT
    		'TB_MOLD_MODI', -- A_TABLE_NAME
    		A_MOLD_MODI_KEY, -- A_TABLE_KEY
    		'Y', -- A_STOCK_YN 재고반영
    		V_CUST_CODE, -- V_CUST_CODE
    		null, -- A_WARE_POS    		
    		'Y', -- A_SUBUL_YN
    		'DELETE', -- A_SAVE_DIV
    		DATE_FORMAT(SYSDATE(), '%Y%m%d'), -- A_IO_DATE -- 수불 발생일자
    		'Y', -- A_STOCK_CHK
    		V_MOLD_CODE, -- V_MOLD_CODE
    		A_SYS_EMP_NO, -- A_SYS_EMP_NO
    		A_SYS_ID, -- A_SYS_ID
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