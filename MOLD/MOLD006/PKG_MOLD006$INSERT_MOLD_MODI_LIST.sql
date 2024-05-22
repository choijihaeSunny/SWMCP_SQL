CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD006$INSERT_MOLD_MODI_LIST`(		
	IN A_COMP_ID varchar(10),
	IN A_SET_DATE TIMESTAMP,
	IN A_SET_SEQ varchar(4),
 	IN A_MODI_DIV varchar(10),
	IN A_MOLD_CODE varchar(20),
	IN A_LOT_NO varchar(30),
	IN A_QTY decimal(10, 0),
	IN A_COST decimal(16, 4),
#	IN A_MOLD_CODE_AFT varchar(30),
#	IN A_LOT_NO_AFT varchar(30),
	IN A_DEPT_CODE varchar(10),
	IN A_IN_OUT varchar(10),
	IN A_CUST_CODE varchar(10),
	IN A_CONT varchar(100),
	IN A_RMK varchar(100),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_SET_NO varchar(10);
	declare V_MOLD_MODI_KEY varchar(30);
	declare V_LOT_STATE varchar(10);
	declare V_MODI_DIV varchar(10);

	declare V_AMT decimal(16, 4);
	
	declare V_LOT_NO varchar(30);
	declare V_MOLD_CODE varchar(30);

	declare V_DUP_CNT INT;

	declare V_IO_GUBN bigint(20);

	declare N_SUBUL_RETURN INT;
	declare V_SUBUL_RETURN VARCHAR(4000);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  

  	SET V_SET_NO = (select IFNULL(MAX(SET_NO), 0) + 1
    				from TB_MOLD_MODI
    				where SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d')
    				  and SET_SEQ = A_SET_SEQ);
  
    SET V_MOLD_MODI_KEY := CONCAT('DF', right(DATE_FORMAT(A_SET_DATE, '%Y%m'), 4), LPAD(A_SET_SEQ, 3, '0'), LPAD(V_SET_NO, 3, '0'));
   
    SET V_DUP_CNT = (select COUNT(*)
    				 from TB_MOLD_MODI
   					 where MOLD_MODI_KEY = V_MOLD_MODI_KEY
    				);
    if V_DUP_CNT <> 0 then
    	set V_SET_NO = V_SET_NO + 1;
    	SET V_MOLD_MODI_KEY := CONCAT('DF', right(DATE_FORMAT(A_SET_DATE, '%Y%m'), 4), LPAD(A_SET_SEQ, 3, '0'), LPAD(V_SET_NO, 3, '0'));
    end if;
   
    set V_MODI_DIV = (select CODE
   					  from SYS_DATA
   					  where path = 'cfg.mold.modi'
   					    and DATA_ID = A_MODI_DIV);
   	
   	set V_AMT = A_QTY * A_COST;
   
    set V_MOLD_CODE = (select MOLD_CODE
						 from TB_MOLD_LOT
						where LOT_NO = A_LOT_NO);
   					  
   	if V_MODI_DIV = 'M' then -- 수정일 경우
	   	set V_LOT_STATE = (select DATA_ID
						   from SYS_DATA
						   where path = 'cfg.mold.lotstate'
						     and CODE = 'M');
						   
		set V_LOT_NO = (select CONCAT(SUBSTRING(LOT_NO, 1, (length(LOT_NO) - 2)), LPAD(RIGHT(LOT_NO, 2) + 1, 2, '0'))
						from TB_MOLD_LOT
						where LOT_NO = A_LOT_NO);    
						
	    insert into TB_MOLD_LOT (
	    	COMP_ID,
	    	LOT_NO,
	    	MOLD_CODE,
	    	SET_DATE,
	    	IN_CUST,
	    	IN_COST,
	    	LOT_NO_ORI,
	    	LOT_NO_PRE,
	    	LOT_STATE,
	    	QTY,
	    	WET,
	    	CREATE_TABLE,
	    	CREATE_TABLE_KEY,
	    	HIT_CNT,
	    	RMK,
	    	TOT_HIT_CNT,
	    	SYS_EMP_NO,
	    	SYS_ID,
	    	SYS_DATE
	    )
		    select
		    	  COMP_ID,
		    	  V_LOT_NO, 
		    	  V_MOLD_CODE,
		    	  DATE_FORMAT(SYSDATE(), '%Y%m%d'),
		    	  IN_CUST,
		    	  IN_COST,
		      	  LOT_NO_ORI,
		    	  A_LOT_NO,
		    	  V_LOT_STATE,
		    	  QTY,
		    	  WET,
		    	  'TB_MOLD_MODI',
		    	  V_MOLD_MODI_KEY,
		    	  0, -- 수정등록시 신규 LOT 생성으로 금형타수 초기화
		    	  RMK,
		    	  0,
		    	  A_SYS_EMP_NO,
		    	  A_SYS_ID,
		    	  SYSDATE()
		    from TB_MOLD_LOT
		    where LOT_NO = A_LOT_NO    	  
	    ;
	    
	    -- 대상이 된 LOT_NO 폐기상태로 수정
	    set V_LOT_STATE = (select DATA_ID
						   from SYS_DATA
						   where path = 'cfg.mold.lotstate'
						     and CODE = 'P');
	  
	    update TB_MOLD_LOT
	    	set LOT_STATE = V_LOT_STATE
	    where LOT_NO = A_LOT_NO
	    ;
   	else -- if V_MODI_DIV = 'R' -- 수리등록일 경우
   		
   		-- 대상이 된 LOT_NO 수정상태로 수정
   	
	    set V_LOT_STATE = (select DATA_ID
						   from SYS_DATA
						   where path = 'cfg.mold.lotstate'
						     and CODE = 'M');
   		update TB_MOLD_LOT
   			set HIT_CNT = 0 -- 수리등록시 금형타수 초기화
   				,LOT_STATE = V_LOT_STATE
   		where LOT_NO = A_LOT_NO;
   	
   		set V_LOT_NO = A_LOT_NO;
   	end if;
   
   
    -- 수정내역 입력
    INSERT INTO TB_MOLD_MODI (
    	COMP_ID,
    	SET_DATE,
    	SET_SEQ,
    	SET_NO,
    	MOLD_MODI_KEY,
    	MODI_DIV,
    	MOLD_CODE,
    	LOT_NO,
    	QTY,
    	COST,
    	AMT,
    	MOLD_CODE_AFT,
    	LOT_NO_AFT,
    	DEPT_CODE,
    	IN_OUT,
    	CUST_CODE,
    	CONT,
    	RMK
    	,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
    ) values (
    	A_COMP_ID,
    	DATE_FORMAT(A_SET_DATE, '%Y%m%d'),
    	LPAD(A_SET_SEQ, 3, '0'),
    	V_SET_NO,
    	V_MOLD_MODI_KEY,
    	A_MODI_DIV,
    	A_MOLD_CODE,
    	A_LOT_NO,
    	A_QTY,
    	A_COST,
    	V_AMT,
    	V_MOLD_CODE, -- 새로 생성된 LOT_NO와 MOLD_CODE를 입력하였다.
    	V_LOT_NO,
    	A_DEPT_CODE,
    	A_IN_OUT,
    	A_CUST_CODE,
    	A_CONT,
    	A_RMK
    	,A_SYS_EMP_NO
    	,A_SYS_ID
    	,SYSDATE()
    )
    ;
   
   	 
	if V_MODI_DIV = 'M' then -- 수정등록했을 경우 수불처리가 필요하다
	
		SET V_IO_GUBN = (select DATA_ID
						 from SYS_DATA
						 where full_path = 'cfg.com.io.mold.out.out');
						
		-- 기존의 LOT_NO는 폐기됐으므로 출고처리한다.
		call SP_SUBUL_MOLD_CREATE( 
    		A_COMP_ID, -- A_COMP_ID
    		CONCAT('TB_MOLD_MODI-', V_MOLD_MODI_KEY), -- A_KEY_VAL
    		2, -- A_IN_OUT 
    		'01', -- A_WARE_CODE -- cfg.com.wh.kind 금형은 무조건 01로 입력.
    		A_LOT_NO, -- A_LOT_NO -
    		V_IO_GUBN, -- IO_GUBN
    		A_QTY, -- IO_QTY 수량
    		A_COST, -- A_IO_PRC 단가
    		V_AMT, -- A_IO_AMT
    		'TB_MOLD_MODI', -- A_TABLE_NAME
    		V_MOLD_MODI_KEY, -- A_TABLE_KEY
    		'Y', -- A_STOCK_YN 재고반영
    		A_CUST_CODE, -- A_CUST_CODE
    		null, -- A_WARE_POS    		
    		'Y', -- A_SUBUL_YN
    		'INSERT', -- A_SAVE_DIV
    		DATE_FORMAT(SYSDATE(), '%Y%m%d'), -- A_IO_DATE -- 수불 발생일자
    		'Y', -- A_STOCK_CHK
    		A_MOLD_CODE, -- A_MOLD_CODE
    		A_SYS_EMP_NO, -- A_SYS_EMP_NO
    		A_SYS_ID, -- A_SYS_ID
    		N_SUBUL_RETURN,
    		V_SUBUL_RETURN
    	);
	
    	SET V_IO_GUBN = (select DATA_ID
						 from SYS_DATA
						 where full_path = 'cfg.com.io.mold.in.in');
					
    	-- 새로 생성된 LOT_NO를 입고처리한다.
		call SP_SUBUL_MOLD_CREATE( 
    		A_COMP_ID, -- A_COMP_ID
    		CONCAT('TB_MOLD_MODI-', V_MOLD_MODI_KEY), -- A_KEY_VAL
    		1, -- A_IN_OUT 
    		'01', -- A_WARE_CODE -- cfg.com.wh.kind 금형은 무조건 01로 입력.
    		V_LOT_NO, -- A_LOT_NO
    		V_IO_GUBN, -- IO_GUBN 
    		A_QTY, -- IO_QTY 수량
    		A_COST, -- A_IO_PRC 단가
    		V_AMT, -- A_IO_AMT
    		'TB_MOLD_MODI', -- A_TABLE_NAME
    		V_MOLD_MODI_KEY, -- A_TABLE_KEY
    		'Y', -- A_STOCK_YN 재고반영
    		A_CUST_CODE, -- A_CUST_CODE
    		null, -- A_WARE_POS    		
    		'Y', -- A_SUBUL_YN
    		'INSERT', -- A_SAVE_DIV
    		DATE_FORMAT(SYSDATE(), '%Y%m%d'), -- A_IO_DATE -- 수불 발생일자
    		'Y', -- A_STOCK_CHK
    		A_MOLD_CODE, -- A_MOLD_CODE
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