CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD004$UPDATE_MOLD_INPUT`(	
	IN A_COMP_ID varchar(10),
#	IN A_SET_DATE TIMESTAMP,
#	IN A_SET_SEQ varchar(4),
	IN A_MOLD_INPUT_KEY varchar(30),
	IN A_CUST_CODE varchar(10),
	IN A_MOLD_CODE varchar(20),
	IN A_LOT_YN bigint(20),
#	IN A_QTY decimal(10, 0),
	IN A_COST decimal(16, 4),
	IN A_DEPT_CODE varchar(10),
	IN A_IN_QTY decimal(10, 0),
#    IN A_CALL_KIND varchar(10),
#    IN A_CALL_KEY varchar(30),
#    IN A_END_AMT decimal(16, 4),
	IN A_RMK varchar(100),
	IN A_UPD_EMP_NO varchar(10),
	IN A_UPD_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_AMT decimal(16, 4);

	declare I INT;
	declare V_LOT_NO varchar(30);
	declare V_LOT_CNT INT;

	declare V_IO_GUBN bigint(20);
	declare V_USE_YN varchar(5);

	declare N_SUBUL_RETURN INT;
	declare V_SUBUL_RETURN VARCHAR(4000);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 

  	set V_AMT = A_IN_QTY * A_COST;
  
	update TB_MOLD_INPUT
		set 
			CUST_CODE = A_CUST_CODE
			,MOLD_CODE = A_MOLD_CODE
			,LOT_YN = A_LOT_YN
			,COST = A_COST
			,AMT = V_AMT
			,DEPT_CODE = A_DEPT_CODE
			,IN_QTY = A_IN_QTY
			,RMK = A_RMK
			,UPD_EMP_NO = A_UPD_EMP_NO
	    	,UPD_ID = A_UPD_ID
	    	,UPD_DATE = SYSDATE()
	where COMP_ID = A_COMP_ID
	  and MOLD_INPUT_KEY = A_MOLD_INPUT_KEY
	  and MOLD_CODE = A_MOLD_CODE 
	;

	SET V_USE_YN = (select CODE
					from SYS_DATA
					where path = 'cfg.mold.lotyn'
					  and DATA_ID = A_LOT_YN);

	SET V_IO_GUBN = (select DATA_ID
					 from sys_data
					 where full_path = 'cfg.com.io.mold.in.in');

	if V_USE_YN = 'Y' then
	
		set V_AMT = A_COST;
	
		set I = 0;
	
		set V_LOT_CNT = (select COUNT(*)
						 from TB_MOLD_INPUT_LOT
						 where COMP_ID = A_COMP_ID
		   				   and MOLD_INPUT_KEY = A_MOLD_INPUT_KEY);
	
		WHILE I < V_LOT_CNT DO
			
			set V_LOT_NO = (select LOT_NO
							from TB_MOLD_INPUT_LOT
							where COMP_ID = A_COMP_ID
			   				  and MOLD_INPUT_KEY = A_MOLD_INPUT_KEY
			   				limit 1);
		
			call SP_SUBUL_MOLD_CREATE(
		    	A_COMP_ID, -- A_COMP_ID
		    	CONCAT('TB_MOLD_INPUT-', A_MOLD_INPUT_KEY), -- A_KEY_VAL
		    	1, -- A_IN_OUT 
		    	'01', -- A_WARE_CODE -- cfg.com.wh.kind 금형은 무조건 01로 입력.
		    	V_LOT_NO, -- A_LOT_NO -- 금형 사용하지 않는 경우 Input테이블 코드라면 사용하는 경우에는?
		    	V_IO_GUBN, -- IO_GUBN 
		    	1, -- IO_QTY 수량
		    	A_COST, -- A_IO_PRC 단가
		    	V_AMT, -- A_IO_AMT
		    	'TB_MOLD_INPUT', -- A_TABLE_NAME
		    	A_MOLD_INPUT_KEY, -- A_TABLE_KEY
		    	'Y', -- A_STOCK_YN 재고반영
		    	A_CUST_CODE, -- A_CUST_CODE
		    	'01', -- A_WARE_POS    		
		    	'Y', -- A_SUBUL_YN
		    	'UPDATE', -- A_SAVE_DIV
		    	DATE_FORMAT(SYSDATE(), '%Y%m%d'), -- A_IO_DATE -- 수불 발생일자
		    	'Y', -- A_STOCK_CHK
		    	A_MOLD_CODE, -- A_MOLD_CODE
		    	A_UPD_EMP_NO, -- A_UPD_EMP_NO
		    	A_UPD_ID, -- A_SYS_ID
		    	N_SUBUL_RETURN,
		    	V_SUBUL_RETURN
		    );
		   
		   set I = I + 1;
		end while;
		
	else
	
		
		call SP_SUBUL_MOLD_CREATE(
	    	A_COMP_ID, -- A_COMP_ID
	    	CONCAT('TB_MOLD_INPUT-', A_MOLD_INPUT_KEY), -- A_KEY_VAL
	    	1, -- A_IN_OUT 
	    	'01', -- A_WARE_CODE -- cfg.com.wh.kind 금형은 무조건 01로 입력.
	    	A_MOLD_CODE, -- A_LOT_NO -- 금형 사용하지 않는 경우 Input테이블 코드라면 사용하는 경우에는?
	    	V_IO_GUBN, -- IO_GUBN 
	    	A_IN_QTY, -- IO_QTY 수량
	    	A_COST, -- A_IO_PRC 단가
	    	V_AMT, -- A_IO_AMT
	    	'TB_MOLD_INPUT', -- A_TABLE_NAME
	    	A_MOLD_INPUT_KEY, -- A_TABLE_KEY
	    	'Y', -- A_STOCK_YN 재고반영
	    	A_CUST_CODE, -- A_CUST_CODE
	    	'01', -- A_WARE_POS    		
	    	'Y', -- A_SUBUL_YN
	    	'UPDATE', -- A_SAVE_DIV
	    	DATE_FORMAT(SYSDATE(), '%Y%m%d'), -- A_IO_DATE -- 수불 발생일자
	    	'Y', -- A_STOCK_CHK
	    	A_MOLD_CODE, -- A_MOLD_CODE
	    	A_UPD_EMP_NO, -- A_UPD_EMP_NO
	    	A_UPD_ID, -- A_SYS_ID
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