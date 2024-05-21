CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD005$DELETE_MOLD_OUT_LIST`(		
	IN A_COMP_ID varchar(10),
	IN A_MOLD_OUT_KEY varchar(30),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_LOT_NO varchar(30);
	declare V_QTY decimal(10, 0);
	declare V_COST decimal(16, 4);
	declare V_AMT decimal(16, 4);
	declare V_CUST_CODE varchar(10);
	declare V_MOLD_CODE varchar(20);

	declare V_IO_GUBN bigint(20);
	
	declare N_SUBUL_RETURN INT;
	declare V_SUBUL_RETURN VARCHAR(4000);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
   
    select
    	  LOT_NO, QTY, COST, AMT, CUST_CODE,
    	  MOLD_CODE
   	into
   		V_LOT_NO, V_QTY, V_COST, V_AMT, V_CUST_CODE,
    	V_MOLD_CODE
   	from TB_MOLD_OUT
   	where COMP_ID = A_COMP_ID
   	  and MOLD_OUT_KEY = A_MOLD_OUT_KEY
   	;
  
	DELETE FROM TB_MOLD_OUT
	 WHERE COMP_ID = A_COMP_ID
	   and MOLD_OUT_KEY = A_MOLD_OUT_KEY 
	 ;
	
	SET V_IO_GUBN = (select DATA_ID
					 from sys_data
					 where full_path = 'cfg.com.io.mold.out.out');
					
					
	call SP_SUBUL_MOLD_CREATE(
   		A_COMP_ID, -- A_COMP_ID
   		CONCAT('TB_MOLD_OUT-', A_MOLD_OUT_KEY), -- A_KEY_VAL
   		2, -- A_IN_OUT 
   		'01', -- A_WARE_CODE -- cfg.com.wh.kind 금형은 무조건 01로 입력.
   		V_LOT_NO, -- A_LOT_NO 
   		V_IO_GUBN, -- IO_GUBN ?? 입출고 구분
   		V_QTY, -- IO_QTY 수량
   		V_COST, -- A_IO_PRC 단가
   		V_AMT, -- A_IO_AMT
   		'TB_MOLD_OUT', -- A_TABLE_NAME 
   		A_MOLD_OUT_KEY, -- A_TABLE_KEY
   		'Y', -- A_STOCK_YN 재고반영
   		V_CUST_CODE, -- A_CUST_CODE
   		'01', -- A_WARE_POS    		
   		'Y', -- A_SUBUL_YN
   		'DELETE', -- A_SAVE_DIV
   		DATE_FORMAT(SYSDATE(), '%Y%m%d'), -- A_IO_DATE -- 수불 발생일자
   		'Y', -- A_STOCK_CHK
   		V_MOLD_CODE, -- A_MOLD_CODE
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