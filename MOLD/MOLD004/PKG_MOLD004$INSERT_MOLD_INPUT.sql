CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD004$DELETE_MOLD_INPUT`(		
	IN A_COMP_ID varchar(10),
	IN A_CALL_KEY varchar(30),
	IN A_MOLD_INPUT_KEY varchar(30),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	-- 수불용 변수
	declare V_IN_QTY decimal(10, 0);
	declare V_COST decimal(16, 4);
	declare V_AMT decimal(16, 4);
	declare V_CUST_CODE varchar(10);
	declare V_MOLD_CODE varchar(20);
	declare V_MOLD_INPUT_KEY varchar(30);
	declare V_LOT_YN bigint(20);
	declare V_USE_YN varchar(5);

	-- INPUT 외의 테이블 삭제용 변수
	declare V_LOT_NO varchar(30);
	declare I INT;
	declare V_LOT_CNT INT;

	declare V_SAVE_DIV varchar(10);
	declare N_SUBUL_RETURN INT;
	declare V_SUBUL_RETURN VARCHAR(4000);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
   
  	select 
		  IN_QTY, COST, AMT, CUST_CODE, MOLD_CODE,
		  MOLD_INPUT_KEY, LOT_YN
	into 
		 V_IN_QTY, V_COST, V_AMT, V_CUST_CODE, V_MOLD_CODE,
		 V_MOLD_INPUT_KEY, V_LOT_YN
	from TB_MOLD_INPUT
	where COMP_ID = A_COMP_ID
	  and MOLD_INPUT_KEY = A_MOLD_INPUT_KEY
	;



	DELETE FROM TB_MOLD_INPUT
	 WHERE COMP_ID = A_COMP_ID
	   and MOLD_INPUT_KEY = A_MOLD_INPUT_KEY
	 ;
	
	update TB_MOLD_FORDER
	   set IN_QTY = IN_QTY + V_IN_QTY
	where COMP_ID = A_COMP_ID
	  and MOLD_MORDER_KEY = A_CALL_KEY
	;

	SET V_USE_YN = (select CODE
					from sys_data
					where path = 'cfg.mold.lotyn'
					  and DATA_ID = V_LOT_YN);
  

	if V_USE_YN = 'Y' then
		set I = 0;
	
		set V_LOT_CNT = (select COUNT(*)
						 from TB_MOLD_INPUT_LOT
						 where COMP_ID = A_COMP_ID
		   				   and MOLD_INPUT_KEY = A_MOLD_INPUT_KEY);
		
		while I < V_LOT_CNT DO
			set V_LOT_NO = (select LOT_NO
							from TB_MOLD_INPUT_LOT
							where COMP_ID = A_COMP_ID
			   				  and MOLD_INPUT_KEY = A_MOLD_INPUT_KEY
			   				limit 1);
			
			delete from TB_MOLD_INPUT_LOT
			 where COMP_ID = A_COMP_ID
			   and MOLD_INPUT_KEY = A_MOLD_INPUT_KEY
			   and LOT_NO = V_LOT_NO
			;
		
			delete from TB_MOLD_LOT
			 where COMP_ID = A_COMP_ID
			   and LOT_NO = V_LOT_NO
			;
		
			call SP_SUBUL_MOLD_CREATE(
	    		A_COMP_ID, -- A_COMP_ID
	    		V_MOLD_INPUT_KEY, -- A_KEY_VAL
	    		1, -- A_IN_OUT 
	    		'01', -- A_WARE_CODE -- cfg.com.wh.kind 금형은 무조건 01로 입력.
	    		V_LOT_NO, -- A_LOT_NO -- 금형 사용하지 않는 경우 Input테이블 코드라면 사용하는 경우에는?
	    		1, -- IO_GUBN ?? 입출고 구분일텐데 1로 넣어도 괜찮을듯?.
	    		1, -- IO_QTY 수량
	    		V_COST, -- A_IO_PRC 단가
	    		V_AMT, -- A_IO_AMT
	    		null, -- A_TABLE_NAME 모르겠으니 일단 NULL로 처리.
	    		null, -- A_TABLE_KEY
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
	    		N_RETURN,
	    		V_RETURN
	    	);
		
			set I = I + 1;
		end while;
	
	else
	
		set V_LOT_CNT = (select COUNT(*)
						 from TB_MOLD_LOT
						 where LOT_NO = V_MOLD_CODE);
		
		if V_LOT_CNT = 1 then
			set V_SAVE_DIV = 'DELETE';
		
			delete from TB_MOLD_LOT
			 where COMP_ID = A_COMP_ID
			   and LOT_NO = V_MOLD_CODE  --  금형 LOT관리 안 하는 내역 LOT NO는 금형코드로 관리.
			;
		else
			set V_SAVE_DIV = 'UPDATE';
		
			update TB_MOLD_LOT
				set QTY = QTY - V_IN_QTY
					,UPD_EMP_NO = A_SYS_EMP_NO
				    ,UPD_ID = A_SYS_ID
				    ,UPD_DATE = SYSDATE()
			where LOT_NO = V_MOLD_CODE
			;
		end if;

	
		call SP_SUBUL_MOLD_CREATE(
    		A_COMP_ID, -- A_COMP_ID
    		V_MOLD_INPUT_KEY, -- A_KEY_VAL
    		1, -- A_IN_OUT 
    		'01', -- A_WARE_CODE -- cfg.com.wh.kind 금형은 무조건 01로 입력.
    		V_LOT_NO, -- A_LOT_NO -- 금형 사용하지 않는 경우 Input테이블 코드라면 사용하는 경우에는?
    		1, -- IO_GUBN ?? 입출고 구분일텐데 1로 넣어도 괜찮을듯?.
    		V_IN_QTY, -- IO_QTY 수량
    		V_COST, -- A_IO_PRC 단가
    		V_AMT, -- A_IO_AMT
    		null, -- A_TABLE_NAME 모르겠으니 일단 NULL로 처리.
    		null, -- A_TABLE_KEY
    		'Y', -- A_STOCK_YN 재고반영
    		V_CUST_CODE, -- A_CUST_CODE
    		'01', -- A_WARE_POS    		
    		'Y', -- A_SUBUL_YN
    		V_SAVE_DIV, -- A_SAVE_DIV
    		DATE_FORMAT(SYSDATE(), '%Y%m%d'), -- A_IO_DATE -- 수불 발생일자
    		'Y', -- A_STOCK_CHK
    		V_MOLD_CODE, -- A_MOLD_CODE
    		A_SYS_EMP_NO, -- A_SYS_EMP_NO
    		A_SYS_ID, -- A_SYS_ID
    		N_RETURN,
    		V_RETURN
    	);
	end if;

	

	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
--     ELSE
--     
--     	-- 수불처리 실패한 경우
--     	if N_SUBUL_RETURN <> 0 then
--     		SET N_RETURN = -1;
--       		SET V_RETURN = '저장이 실패하였습니다.'; 
--     	end if;
  	END IF;  
  
end