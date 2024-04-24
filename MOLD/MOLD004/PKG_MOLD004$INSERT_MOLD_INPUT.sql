CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD004$INSERT_MOLD_INPUT`(	
	IN A_COMP_ID varchar(10),
	IN A_SET_DATE TIMESTAMP,
	IN A_SET_SEQ varchar(4),
	INOUT A_MOLD_INPUT_KEY varchar(30),
	IN A_CUST_CODE varchar(10),
	IN A_MOLD_CODE varchar(20),
	IN A_LOT_YN bigint(20),
	IN A_QTY decimal(10, 0),
	IN A_COST decimal(16, 4),
	IN A_AMT decimal(16, 4),
	IN A_DEPT_CODE varchar(10),
	IN A_IN_QTY decimal(10, 0),
#    IN A_CALL_KIND varchar(10),
    IN A_CALL_KEY varchar(30),
#    IN A_END_AMT decimal(16, 4),
	IN A_RMK varchar(100),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_SET_SEQ varchar(4);
	declare V_SET_NO varchar(10);
	declare V_MOLD_INPUT_KEY varchar(30);
	declare V_IN_QTY decimal(10, 0);
	declare V_USE_YN varchar(5);

	declare V_DUP_CNT INT;

	declare I INT;
	declare V_LOT_NO varchar(30);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 

  	SET V_SET_SEQ = LPAD(A_SET_SEQ, 3, '0');
  
	SET V_SET_NO = (select IFNULL(MAX(SET_NO), 0) + 1
    				from TB_MOLD_INPUT
    				where SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d')
    				  and SET_SEQ = V_SET_SEQ
--     				  and substring(MOLD_INPUT_KEY, 3, 4) = right(DATE_FORMAT(A_SET_DATE, '%Y%m'), 4)
    				); 				 
  
    SET V_MOLD_INPUT_KEY = CONCAT('DI', right(DATE_FORMAT(A_SET_DATE, '%Y%m'), 4), V_SET_SEQ, LPAD(V_SET_NO, 3, '0'));
   
    -- 생성된 V_MOLD_INPUT_KEY가 혹시 겹치는 데이터가 있는지 확인.
    SET V_DUP_CNT = (select COUNT(*)
    				 from TB_MOLD_INPUT
   					 where MOLD_INPUT_KEY = V_MOLD_INPUT_KEY
    				);
    if V_DUP_CNT <> 0 then
    	set V_SET_NO = V_SET_NO + 1;
    	SET V_MOLD_INPUT_KEY = CONCAT('DI', right(DATE_FORMAT(A_SET_DATE, '%Y%m'), 4), V_SET_SEQ, LPAD(V_SET_NO, 3, '0'));
    end if;
   
    SET V_IN_QTY = (select IN_QTY
   					from TB_MOLD_FORDER
   					where COMP_ID = A_COMP_ID
	  				  and MOLD_MORDER_KEY = A_CALL_KEY);
	  				 
	  				 
	if A_IN_QTY > V_IN_QTY then
		SET N_RETURN = -1;
      	SET V_RETURN = '입고하려는 수량이 잔여수량보다 큽니다.'; 
	end if;

    INSERT INTO TB_MOLD_INPUT (
    	COMP_ID,
    	SET_DATE,
    	SET_SEQ,
    	SET_NO,
    	MOLD_INPUT_KEY,
    	CUST_CODE,
    	MOLD_CODE,
    	LOT_YN,
    	QTY,
    	COST,
    	AMT,
    	DEPT_CODE,
    	IN_QTY,
#    	CALL_KIND,
    	CALL_KEY,
#    	END_AMT,
    	RMK
    	,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
    ) values (
    	A_COMP_ID,
    	DATE_FORMAT(A_SET_DATE, '%Y%m%d'),
    	V_SET_SEQ,
    	V_SET_NO,
    	V_MOLD_INPUT_KEY,
    	A_CUST_CODE,
    	A_MOLD_CODE,
    	A_LOT_YN,
    	A_QTY,
    	A_COST,
    	A_AMT,
    	A_DEPT_CODE,
    	A_IN_QTY,
#    	A_CALL_KIND,
      	A_CALL_KEY,
#    	A_END_AMT,
    	A_RMK
    	,A_SYS_EMP_NO
    	,A_SYS_ID
    	,SYSDATE()
    )
    ;
	
    update TB_MOLD_FORDER
	   set IN_QTY = IN_QTY - A_IN_QTY
	where COMP_ID = A_COMP_ID
	  and MOLD_MORDER_KEY = A_CALL_KEY
	;
   	
    
	    			 
	SET V_USE_YN = (select CODE
					from sys_data
					where path = 'cfg.mold.lotyn'
					  and DATA_ID = A_LOT_YN);
	 
   	
    if V_USE_YN = 'Y' then
    	set I = 0;
    
    	SET V_SET_NO = (select IFNULL(MAX(SET_NO), 0) + 1
		    		      from TB_MOLD_INPUT_LOT
		    		     where SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d')
		    			   and MOLD_INPUT_KEY = V_MOLD_INPUT_KEY
		    			  );
		    			 
		SET V_LOT_NO = CONCAT('MO', right(DATE_FORMAT(A_SET_DATE, '%Y%m'), 4), LPAD(V_SET_NO, 5, '0'), '00');
	  
		-- LOT_NO 중복방지
		SET V_DUP_CNT = (select COUNT(*)
						 from TB_MOLD_INPUT_LOT
						 where LOT_NO = V_LOT_NO
						);		
		if V_DUP_CNT > 0 then
			
			SET V_SET_NO = (select MAX(substring(LOT_NO, 7, 5)) + 1							
							from tb_mold_input_lot
							where SUBSTRING(LOT_NO, 3, 4) =  right(DATE_FORMAT(A_SET_DATE, '%Y%m'), 4)
							);
		end if;

	
    	WHILE I < A_IN_QTY DO
    	
    		SET V_LOT_NO = CONCAT('MO', right(DATE_FORMAT(A_SET_DATE, '%Y%m'), 4), LPAD(V_SET_NO, 5, '0'), '00');
    	
    		INSERT INTO TB_MOLD_INPUT_LOT (
		    	COMP_ID,
		    	SET_DATE,
		    	SET_SEQ,
		    	SET_NO,
		    	MOLD_INPUT_KEY,
		    	MOLD_CODE,
		    	LOT_NO
		    	,SYS_EMP_NO
		    	,SYS_ID
		    	,SYS_DATE
		    ) VALUES (
		    	A_COMP_ID,
		    	DATE_FORMAT(A_SET_DATE, '%Y%m%d'),
		    	V_SET_SEQ,
		    	V_SET_NO,
		    	V_MOLD_INPUT_KEY,
		    	A_MOLD_CODE,
		    	V_LOT_NO
		    	,A_SYS_EMP_NO
		    	,A_SYS_ID
		    	,SYSDATE()
		    )
		    ;
		   
		    insert into TB_MOLD_LOT (
		    	COMP_ID,
		    	LOT_NO,
		    	MOLD_CODE,
		    	SET_DATE,
		    	IN_CUST,
		    	IN_COST,
		    	LOT_NO_ORI,
		    	LOT_STATE,
		    	QTY
		    	,SYS_EMP_NO
		    	,SYS_ID
		    	,SYS_DATE
		    ) VALUES (
		    	A_COMP_ID,
		    	V_LOT_NO,
		    	A_MOLD_CODE,
		    	DATE_FORMAT(A_SET_DATE, '%Y%m%d'),
		    	A_CUST_CODE,
		    	A_COST,
		    	V_LOT_NO,
		    	'N',
		    	A_QTY
		    	,A_SYS_EMP_NO
		    	,A_SYS_ID
		    	,SYSDATE()
		    )
		    ;
		
			set I = I + 1;
			set V_SET_NO = V_SET_NO + 1;
		   
    	end while;
    end if;
   
    IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
    ELSE
    	call SP_SUBUL_MOLD_CREATE(
    		A_COMP_ID, -- A_COMP_ID
    		V_MOLD_INPUT_KEY, -- A_KEY_VAL
    		1, -- A_IN_OUT 
    		'01', -- A_WARE_CODE -- cfg.com.wh.kind 금형은 무조건 01로 입력.
    		V_LOT_NO, -- A_LOT_NO -- 금형 사용하지 않는 경우 Input테이블 코드라면 사용하는 경우에는?
    		1, -- IO_GUBN ?? 입출고 구분일텐데 1로 넣어도 괜찮을듯?.
    		A_IN_QTY, -- IO_QTY 수량
    		A_COST, -- A_IO_PRC 단가
    		A_AMT, -- A_IO_AMT
    		null, -- A_TABLE_NAME 모르겠으니 일단 NULL로 처리.
    		null, -- A_TABLE_KEY
    		'Y', -- A_STOCK_YN 재고반영
    		A_CUST_CODE, -- A_CUST_CODE
    		'01', -- A_WARE_POS    		
    		'Y', -- A_SUBUL_YN
    		'INSERT', -- A_SAVE_DIV
    		DATE_FORMAT(SYSDATE(), '%Y%m%d'), -- A_IO_DATE -- 수불 발생일자
    		'Y', -- A_STOCK_CHK
    		A_MOLD_CODE, -- A_MOLD_CODE
    		A_SYS_ID, -- A_SYS_ID
    		A_SYS_EMP_NO, -- A_SYS_EMP_NO
    		N_RETURN,
    		V_RETURN
    	);
  	END IF; 
  
end