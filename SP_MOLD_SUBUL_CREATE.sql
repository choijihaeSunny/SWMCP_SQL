CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`SP_MOLD_SUBUL_CREATE`(
        IN A_COMP_ID VARCHAR(10),
        IN A_KEY_VAL VARCHAR(100), -- 수불 KEY
        IN A_IN_OUT VARCHAR(1), -- 입고/출고 여부 입:1 출:2
        
        IN A_SUBUL_YN varchar(1), -- 수불 발생 필요 여부?
        IN A_SAVE_DIV varchar(10), -- insert, update, delete 여부
        IN A_IO_DATE VARCHAR(8), -- 수불 발생 일자?
        IN A_STOCK_CHK	VARCHAR(1),
        
        IN A_SYS_ID decimal(10,0),
		IN A_SYS_EMP_NO varchar(10),
	
        OUT N_RETURN INT,
        OUT V_RETURN VARCHAR(4000)
	)
PROC_BODY : begin
	declare V_IN_OUT VARCHAR(1);
	declare V_WARE_CODE VARCHAR(10);
	declare V_MOLD_CODE varchar(30);
	declare V_LOT_NO VARCHAR(30);
	declare V_STOCK_YN VARCHAR(1);
	declare V_IO_DATE VARCHAR(8);
	declare V_IO_QTY DECIMAL;
	declare V_ORDER_KEY VARCHAR(30);
	declare V_ERROR_MSG VARCHAR(100);
	declare V_STOCK_QTY_PRE	DECIMAL;
	declare V_STOCK_QTY_PRE_DATE	DECIMAL;
	declare V_STOCK_QTY	DECIMAL;
	declare V_STOCK_QTY_DATE	DECIMAL;
	declare V_CHK_CNT INT;
	declare V_IO_QTY_INOUT	DECIMAL;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	
	/* 금형수불생성 및 품목, LOT 별 재고 반영*/
	if A_SUBUL_YN = 'Y' then
		if A_SAVE_DIV = 'UPDATE' or A_SAVE_DIV = 'DELETE' then
			-- 수정 또는 삭제할 경우 수불 생성
			select N_OUT, WARE_CODE, MOLD_CODE, LOT_NO, STOCK_YN, IO_DATE, IO_QTY
			into   V_IN_OUT, V_WARE_CODE, V_MOLD_CODE, V_LOT_NO, V_STOCK_YN, V_IO_DATE, V_IO_QTY
			from   TB_MOLD_SUBUL 
			where  COMP_ID = A_COMP_ID and KEY_VAL = A_KEY_VAL;
		end if;
	
		-- INSERT, UPDATE, DELETE else if 구문
		if A_SAVE_DIV = 'INSERT' then
			-- 기존의 재고 최종 값을 구하는듯?
			select ifnull(SUM(CASE 
								  WHEN IN_OUT = '1' THEN IO_QTY 
								  ELSE IO_QTY * -1 
							  END), 0),
				   ifnull(SUM(CASE 
					   			  WHEN IO_DATE <= A_IO_DATE THEN 
					   			  								CASE 
						   			  								WHEN IN_OUT = '1' THEN IO_QTY 
						   			  												  ELSE IO_QTY * -1 
						   			  							END 
						   		  ELSE 0 
						   	   END), 0)
			into   V_STOCK_QTY_PRE, -- 재고수량
				   V_STOCK_QTY_PRE_DATE -- 스블일자
			from   TB_MOLD_SUBUL;
		
			if A_IN_OUT = '1' then -- 입고했을 경우
				set V_IO_QTY_INOUT = A_IO_QTY;
			else -- 출고했을 경우
				set V_IO_QTY_INOUT = A_IO_QTY * -1;
			end if;
		
			set V_STOCK_QTY = V_STOCK_QTY_PRE + V_IO_QTY_INOUT;
			set V_STOCK_QTY_DATE = V_STOCK_QTY_PRE_DATE + V_IO_QTY_INOUT;
		
			if V_STOCK_QTY_DATE < 0 and A_STOCK_CHK = 'Y' then
            	SET N_RETURN = -1;
  				SET V_RETURN = '[INSERT] 재고가 부족합니다.'; 
            	leave PROC_BODY;
            	/* SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='재고가 부족합니다.'; */  
            end if;	
			
		end if; -- INSERT, UPDATE, DELETE else if 구문 end
	end if; -- if A_SUBUL_YN = 'Y' then endif


	SET N_RETURN = 0;
  	SET V_RETURN = '수불처리 완료되었습니다.'; 
   
   
END