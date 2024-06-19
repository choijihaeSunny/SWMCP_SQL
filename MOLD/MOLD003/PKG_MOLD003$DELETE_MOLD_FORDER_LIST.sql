CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD003$DELETE_MOLD_FORDER_LIST`(		
	IN A_COMP_ID varchar(10),
	IN A_MOLD_MORDER_KEY varchar(30),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin

	declare V_MOLD_CODE VARCHAR(20);
	declare V_QTY decimal(10, 0);
	declare V_COST decimal(16, 4);
	declare V_AMT decimal(16, 4);
	declare V_CUST_CODE VARCHAR(10);

	declare V_IO_GUBN bigint(20);
	
	declare N_SUBUL_RETURN INT;
	declare V_SUBUL_RETURN VARCHAR(4000);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
   
  
  	select
  		  MOLD_CODE, QTY, COST, AMT, CUST_CODE
  	into V_MOLD_CODE, V_QTY, V_COST, V_AMT, V_CUST_CODE
  	FROM TB_MOLD_FORDER
	WHERE COMP_ID = A_COMP_ID
	  and MOLD_MORDER_KEY = A_MOLD_MORDER_KEY 
    ;
   
     SET V_IO_GUBN = (select DATA_ID
					 from SYS_DATA
					 where full_path = 'cfg.com.io.mold.in.in');
   
	DELETE FROM TB_MOLD_FORDER
	 WHERE COMP_ID = A_COMP_ID
	   and MOLD_MORDER_KEY = A_MOLD_MORDER_KEY
	 ;

	call SP_SUBUL_MOLD_CREATE(
    		A_COMP_ID, -- A_COMP_ID
    		CONCAT('TB_MOLD_FORDER-', A_MOLD_MORDER_KEY), -- V_KEY_VAL
    		1, -- V_IN_OUT 
    		'01', -- V_WARE_CODE -- cfg.com.wh.kind 금형은 무조건 01로 입력.
    		V_MOLD_CODE, -- V_LOT_NO --  금형 LOT관리 안 하는 내역 LOT NO는 금형코드로 관리.
    		V_IO_GUBN, -- IO_GUBN ?? 입출고 구분
    		V_QTY, -- IO_QTY 수량
    		V_COST, -- V_IO_PRC 단가
    		V_AMT, -- V_IO_AMT
    		'TB_MOLD_FORDER', -- V_TABLE_NAME
    		A_MOLD_MORDER_KEY, -- V_TABLE_KEY
    		'Y', -- V_STOCK_YN 재고반영
    		V_CUST_CODE, -- V_CUST_CODE
    		'01', -- V_WARE_POS    		
    		'Y', -- V_SUBUL_YN
    		'INSERT', -- V_SAVE_DIV
    		DATE_FORMAT(SYSDATE(), '%Y%m%d'), -- V_IO_DATE -- 수불 발생일자
    		'Y', -- V_STOCK_CHK
    		V_MOLD_CODE, -- V_MOLD_CODE
    		A_SYS_EMP_NO, -- A_SYS_EMP_NO
    		A_SYS_ID, -- A_SYS_ID
    		N_SUBUL_RETURN,
    		V_SUBUL_RETURN
    	);
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '삭제실패@'; -- '저장이 실패하였습니다.'; 
    ELSE
    
    	-- 수불처리 실패한 경우
    	if N_SUBUL_RETURN <> 0 then
    		SET N_RETURN = -1;
      		SET V_RETURN = V_SUBUL_RETURN; 
    	end if;
  	END IF;  
  
end