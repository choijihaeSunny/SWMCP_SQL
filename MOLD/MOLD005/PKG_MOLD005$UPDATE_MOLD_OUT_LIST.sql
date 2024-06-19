CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD005$UPDATE_MOLD_OUT_LIST`(		
	IN A_COMP_ID varchar(10),
#	IN A_SET_DATE TIMESTAMP,
#	IN A_SET_SEQ varchar(4),
	IN A_MOLD_OUT_KEY varchar(30),
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

	declare V_IO_GUBN bigint(20);

	declare N_SUBUL_RETURN INT;
	declare V_SUBUL_RETURN VARCHAR(4000);	

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
   
    UPDATE TB_MOLD_OUT
    	SET 
#			COMP_ID = A_COMP_ID,
#	    	SET_DATE = A_SET_DATE,
#	    	SET_SEQ = A_SET_SEQ,
#	    	SET_NO = A_SET_NO,
#	    	MOLD_OUT_KEY = A_MOLD_OUT_KEY,
	    	CUST_CODE = A_CUST_CODE,
	    	MOLD_CODE = A_MOLD_CODE,
	    	LOT_NO = A_LOT_NO,
	    	QTY = A_QTY,
	    	COST = A_COST,
	    	AMT = A_AMT,
	    	DEPT_CODE = A_DEPT_CODE,
	    	RMK = A_RMK
	    	,UPD_EMP_NO = A_SYS_EMP_NO
	    	,UPD_ID = A_SYS_ID
	    	,UPD_DATE = SYSDATE()
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
   		A_LOT_NO, -- A_LOT_NO 
   		V_IO_GUBN, -- IO_GUBN ?? 입출고 구분
   		A_QTY, -- IO_QTY 수량
   		A_COST, -- A_IO_PRC 단가
   		A_AMT, -- A_IO_AMT
   		'TB_MOLD_OUT', -- A_TABLE_NAME 
   		A_MOLD_OUT_KEY, -- A_TABLE_KEY
   		'Y', -- A_STOCK_YN 재고반영
   		A_CUST_CODE, -- A_CUST_CODE
   		null, -- A_WARE_POS    		
   		'Y', -- A_SUBUL_YN
   		'UPDATE', -- A_SAVE_DIV
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