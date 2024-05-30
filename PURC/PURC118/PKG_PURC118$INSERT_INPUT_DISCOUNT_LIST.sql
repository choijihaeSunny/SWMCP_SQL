CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC118$INSERT_INPUT_DISCOUNT_LIST`(		
	IN A_COMP_ID varchar(10),
    IN A_SET_DATE varchar(8),
    IN A_CUST_CODE varchar(10),
    IN A_INPUT_AMT decimal(16, 4),
    IN A_DS_RATE decimal(16, 4),
    IN A_DS_AMT decimal(16, 4),
    IN A_DS_CAUSE varchar(50),
    IN A_DS_INPUT_FROM varchar(8),
    IN A_DS_INPUT_TO varchar(8),
    IN A_END_AMT decimal(16, 4),
    IN A_RMK varchar(100),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_DISCOUNT_KEY varchar(30);
	declare V_SET_NO varchar(5);

	declare V_DUP_CNT INT;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	set V_SET_NO = (select COUNT(*) + 1
					from TB_INPUT_DISCOUNT
					where SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d'));

	set V_DISCOUNT_KEY = CONCAT('DM', DATE_FORMAT(A_SET_DATE, '%Y%m%d'), LPAD(V_SET_NO, 3, '0'));
   					  
	set V_DUP_CNT = (select COUNT(*)
					 from TB_INPUT_DISCOUNT
					 where DISCOUNT_KEY = V_DISCOUNT_KEY);
					
	if V_DUP_CNT <> 0 then
		set V_SET_NO = V_SET_NO + 1;
		set V_DISCOUNT_KEY = CONCAT('DM', DATE_FORMAT(A_SET_DATE, '%Y%m%d'), LPAD(V_SET_NO, 3, '0'));
	end if;

    INSERT INTO TB_INPUT_DISCOUNT (
    	COMP_ID,
    	SET_DATE,
    	DISCOUNT_KEY,
    	CUST_CODE,
    	INPUT_AMT,
    	DS_RATE,
    	DS_AMT,
    	DS_CAUSE,
    	DS_INPUT_FROM,
    	DS_INPUT_TO,
    	END_AMT,
    	RMK
    	,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
    ) values (
   		A_COMP_ID,
    	DATE_FORMAT(A_SET_DATE, '%Y%m%d'),
    	V_DISCOUNT_KEY,
    	A_CUST_CODE,
    	A_INPUT_AMT,
    	A_DS_RATE,
    	A_DS_AMT,
    	A_DS_CAUSE,
    	DATE_FORMAT(A_DS_INPUT_FROM, '%Y%m%d'),
    	DATE_FORMAT(A_DS_INPUT_TO, '%Y%m%d'),
    	A_END_AMT,
    	A_RMK
    	,A_SYS_EMP_NO
    	,A_SYS_ID
    	,SYSDATE()
    )
    ;
  
   
    
	/*				  
   	call SP_SUBUL_CREATE(
   		A_COMP_ID,-- A_COMP_ID VARCHAR(10),
        CONCAT('TB_MATR_ETC_OUT_DET-', V_MATR_ETC_OUT_KEY),-- A_KEY_VAL VARCHAR(100),
        'INSERT', -- A_SAVE_DIV VARCHAR(10),
        V_SET_DATE, -- A_IO_DATE VARCHAR(8),
        2, -- A_-- IN_OUT VARCHAR(1),
        V_WARE_CODE, -- A_WARE_CODE big--t,        
        V_ITEM_KIND, -- A_ITEM_K--D big--t, input_etc 에 ITEM_KIND 항목이 없음.
        A_ITEM_CODE, -- A_ITEM_CODE VARCHAR(30),
        A_LOT_NO, -- A_LOT_NO VARCHAR(30),
        100, -- A_PROG_CODE big--t,
        V_IO_GUBN, -- A_IO_GUBN	big--t,
        A_QTY, -- A_IO_QTY		DECIMAL,
        A_COST,-- A_IO_PRC		DECIMAL,
        V_AMT,-- A_IO_AMT		DECIMAL,
        'TB_MATR_ETC_OUT_DET', -- V_TABLE_NAME	VARCHAR(50),
        V_MATR_ETC_OUT_KEY, -- V_TABLE_KEY	VARCHAR(100),
        'Y', -- A_STOCK_YN	VARCHAR(1),
        1, -- A_IO_RATE	DECIMAL, -- 환율은 해외와 거래하지 않는 이상 1
        null, -- A_ITEM_CODE_UP	VARCHAR(30),
        V_CUST_CODE, -- A_CUST_CODE		VARCHAR(10),
        'Y', -- A_PRE_STOCK_YN		VARCHAR(1),
        DATE_FORMAT(A_OUT_DATE, '%Y%m%d'), -- A_IO_DATE_AC			VARCHAR(8),
        null, -- A_ORDER_KEY			VARCHAR(30),
        'Y', -- A_SUBUL_ORDER_YN		VARCHAR(1),
        'Y', -- A_SUBUL_YN			VARCHAR(1),
        'Y', -- A_STOCK_CHK			VARCHAR(1),
        A_SYS_ID, -- A_SYS_ID decimal(10,0),
		A_SYS_EMP_NO, -- A_SYS_EMP_NO varchar(10),
		N_SUBUL_RETURN,
    	V_SUBUL_RETURN
   	);
   	*/
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = V_SUBUL_RETURN; -- '저장이 실패하였습니다.'; 
     /*
    ELSE
    
    	-- 수불처리 실패한 경우
    	if N_SUBUL_RETURN <> 0 then
    		SET N_RETURN = -1;
      		SET V_RETURN = V_SUBUL_RETURN; 
    	end if;
    	
    	*/
  	END IF;  
  
end