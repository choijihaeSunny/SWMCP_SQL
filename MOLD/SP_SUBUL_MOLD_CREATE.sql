CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`SP_SUBUL_MOLD_CREATE`(
        IN A_COMP_ID VARCHAR(10),
        IN A_KEY_VAL VARCHAR(100), -- 수불 key
        IN A_IN_OUT VARCHAR(1), -- 입고/출고 여부 입:1 출:2
        IN A_WARE_CODE varchar(10),
        IN A_LOT_NO varchar(30),
        
        IN A_IO_GUBN varchar(10),
        IN A_IO_QTY decimal(16,4),
        IN A_IO_PRC decimal(16, 4),
        IN A_IO_AMT decimal(16, 4),
        IN A_TABLE_NAME varchar(50),
        
        IN A_TABLE_KEY varchar(100),
        IN A_STOCK_YN varchar(1),
        IN A_CUST_CODE varchar(10),
        IN A_STOCK_QTY decimal(10, 0),
        IN A_WARE_POS varchar(10),
        
        IN A_SUBUL_YN varchar(1), -- 수불 발생 필요 여부?
        IN A_SAVE_DIV varchar(10), -- insert, update, delete 여부
        IN A_IO_DATE VARCHAR(8), -- 수불 발생 일자?
        IN A_STOCK_CHK	VARCHAR(1),
        IN A_MOLD_CODE varchar(30),
        
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


	-- SP_SUBUL_CREATE 참조하여 작성.
	
	/* 금형수불생성 및 품목, LOT 별 재고 반영*/
	if A_SUBUL_YN = 'Y' then
		if A_SAVE_DIV = 'UPDATE' or A_SAVE_DIV = 'DELETE' then
			-- 수정 또는 삭제할 경우 수불 생성
			select IN_OUT, WARE_CODE, MOLD_CODE, LOT_NO, STOCK_YN, 
				   IO_DATE, IO_QTY
			into   V_IN_OUT, V_WARE_CODE, V_MOLD_CODE, V_LOT_NO, V_STOCK_YN, 
				   V_IO_DATE, V_IO_QTY
			from   TB_MOLD_SUBUL 
			where  COMP_ID = A_COMP_ID and KEY_VAL = A_KEY_VAL;
		end if;
	
		-- INSERT, UPDATE, DELETE else if 구문
		if A_SAVE_DIV = 'INSERT' then 
			-- 기존의 재고값을 구하는듯?
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
			from   TB_MOLD_SUBUL
			where COMP_ID = A_COMP_ID
			  and WARE_CODE = A_WARE_CODE
			  and MOLD_CODE = A_MOLD_CODE
			  and LOT_NO = A_LOT_NO
			  and STOCK_YN = 'Y'
			;
		
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
           
            insert into TB_MOLD_SUBUL (
            	COMP_ID, KEY_VAL, IO_DATE, IN_OUT, WARE_CODE, 
	   			MOLD_CODE, LOT_NO, IO_GUBN, IO_QTY, IO_PRC, 
	   			IO_AMT, TABLE_NAME, TABLE_KEY, STOCK_YN, CUST_CODE, 
	  			SYS_EMP_NO, SYS_ID, SYS_DATE 
            ) values (
            	A_COMP_ID, A_KEY_VAL, A_IO_DATE, A_IN_OUT, A_WARE_CODE,
            	A_MOLD_CODE, A_LOT_NO, A_IO_GUBN, A_IO_QTY, A_IO_PRC,
            	A_IO_AMT, A_TABLE_NAME, A_TABLE_KEY, A_STOCK_YN, A_CUST_CODE,
            	A_SYS_EMP_NO, A_SYS_ID, SYSDATE()
            )
            ;
			
            if A_STOCK_YN = 'Y' then -- 재고반영
            	select COUNT(*)
            	into V_CHK_CNT
            	from TB_MOLD_STOCK
            	where COMP_ID = A_COMP_ID
            	  and WARE_CODE = A_WARE_CODE
            	  and MOLD_CODE = A_MOLD_CODE
            	  and LOT_NO = A_LOT_NO
            	;
            
            	if V_CHK_CNT = 0 then
            		insert into TB_MOLD_STOCK (
            			COMP_ID, WARE_CODE, MOLD_CODE, LOT_NO, STOCK_QTY, 
						CUST_CODE, WARE_POS, SYS_EMP_NO, SYS_DATE
            		) values (
            			A_COMP_ID, A_WARE_CODE, A_MOLD_CODE, A_LOT_NO, A_STOCK_QTY, 
						A_CUST_CODE, A_WARE_POS, SYS_EMP_NO, SYSDATE()
            		)
            		;
            	else
            		update TB_MOLD_STOCK
            		   set STOCK_QTY = V_STOCK_QTY,
            		   	   UPD_EMP_NO = A_SYS_EMP_NO,
            		   	   UPD_DATE = SYSDATE()
            		  where COMP_ID = A_COMP_ID
            		    and WARE_CODE = A_WARE_CODE
            		    and MOLD_CODE = A_MOLD_CODE
            		    and LOT_NO = A_LOT_NO
            		  ;
            	end if; -- if V_CHK_CNT = 0 then end
            	
            	-- 품목코드별 재고 처리
            	-- TB_STOCK_ITEM 에 대응하는 MOLD 테이블을 모르겠어서 일단 보류.
	
            end if; -- if A_STOCK_YN = 'Y' then end
            
        elseif A_SAVE_DIV = 'UPDATE' then 
        	
        	if 
	        	   A_IN_OUT <> V_IN_OUT	
	        	or A_WARE_CODE <> V_WARE_CODE
	        	or A_MOLD_CODE <> V_MOLD_CODE
	        	or A_LOT_NO <> V_LOT_NO
	        	or A_STOCK_YN <> V_STOCK_YN
	        then
        		if V_STOCK_YN = 'Y' then -- 변경 전 정보
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
					 from   TB_MOLD_SUBUL
					 where COMP_ID = V_COMP_ID
					   and WARE_CODE = V_WARE_CODE
					   and MOLD_CODE = V_MOLD_CODE
					   and LOT_NO = V_LOT_NO
					   and STOCK_YN = 'Y'
					;
					
					 if A_IN_OUT = '1' then -- 입고했을 경우
						 set V_IO_QTY_INOUT = V_IO_QTY * -1;
					 else -- 출고했을 경우
						 set V_IO_QTY_INOUT = V_IO_QTY;
					 end if;
					
					 set V_STOCK_QTY = V_STOCK_QTY_PRE + V_IO_QTY_INOUT;
					 set V_STOCK_QTY_DATE = V_STOCK_QTY_PRE_DATE + V_IO_QTY_INOUT;
					
					 if V_STOCK_QTY_DATE < 0 and A_STOCK_CHK = 'Y' then
		            	 SET N_RETURN = -1;
		  				 SET V_RETURN = '[UPDATE] 변경전 재고가 부족합니다.'; 
		            	 leave PROC_BODY;
		            	 /* SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='재고가 부족합니다.'; */  
		             end if;
		            
		             select COUNT(*)
	            	   into V_CHK_CNT
	            	 from TB_MOLD_STOCK
	            	 where COMP_ID = A_COMP_ID
	            	   and WARE_CODE = A_WARE_CODE
	            	   and MOLD_CODE = A_MOLD_CODE
	            	   and LOT_NO = A_LOT_NO
	            	 ;
	            	
	            	 if V_CHK_CNT = 0 then
	            	 	insert into TB_MOLD_STOCK (
	            			COMP_ID, WARE_CODE, MOLD_CODE, LOT_NO, STOCK_QTY, 
							CUST_CODE, WARE_POS, SYS_EMP_NO, SYS_DATE
	            		) values (
	            			A_COMP_ID, A_WARE_CODE, A_MOLD_CODE, A_LOT_NO, A_STOCK_QTY, 
							A_CUST_CODE, A_WARE_POS, SYS_EMP_NO, SYSDATE()
	            		)
	            		;
	            	 else
	            	 	update TB_MOLD_STOCK
	            		   set STOCK_QTY = V_STOCK_QTY,
	            		   	   UPD_EMP_NO = A_SYS_EMP_NO,
	            		   	   UPD_DATE = SYSDATE()
	            		 where COMP_ID = A_COMP_ID
	            		   and WARE_CODE = A_WARE_CODE
	            		   and MOLD_CODE = A_MOLD_CODE
	            		   and LOT_NO = A_LOT_NO
	            		 ;
	            	 end if; -- if V_CHK_CNT = 0 then end
		            
	            	 -- 품목코드별 재고 처리
            		 -- TB_STOCK_ITEM 에 대응하는 MOLD 테이블을 모르겠어서 일단 보류.
					 
        		end if; -- if V_STOCK_YN = 'Y' then end
        		
        		if A_STOCK_YN = 'Y' then
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
					 from   TB_MOLD_SUBUL
					 where COMP_ID = A_COMP_ID
					   and WARE_CODE = A_WARE_CODE
					   and MOLD_CODE = A_MOLD_CODE
					   and LOT_NO = A_LOT_NO
					   and STOCK_YN = 'Y'
					 ;
					
					 if A_IN_OUT = '1' then
					 	set V_IO_QTY_INOUT = A_IO_QTY;
					 else
					 	set V_IO_QTY_INOUT = A_IO_QTY * -1;
					 end if;
					
					 set V_STOCK_QTY = V_STOCK_QTY_PRE + V_IO_QTY_INOUT;
					 set V_STOCK_QTY_DATE = V_STOCK_QTY_PRE_DATE + V_IO_QTY_INOUT;
					
					 if V_STOCK_QTY_DATE < 0 and A_STOCK_CHK = 'Y' then
		            	 SET N_RETURN = -1;
		  				 SET V_RETURN = '[UPDATE] 변경후 재고가 부족합니다.'; 
		            	 leave PROC_BODY;
		            	 /* SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='재고가 부족합니다.'; */  
		             end if;
		            
		             select COUNT(*)
	            	   into V_CHK_CNT
	            	 from TB_MOLD_STOCK
	            	 where COMP_ID = A_COMP_ID
	            	   and WARE_CODE = A_WARE_CODE
	            	   and MOLD_CODE = A_MOLD_CODE
	            	   and LOT_NO = A_LOT_NO
	            	 ;
	            	
	            	 if V_CHK_CNT = 0 then
	            	 	insert into TB_MOLD_STOCK (
	            			COMP_ID, WARE_CODE, MOLD_CODE, LOT_NO, STOCK_QTY, 
							CUST_CODE, WARE_POS, SYS_EMP_NO, SYS_DATE
	            		) values (
	            			A_COMP_ID, A_WARE_CODE, A_MOLD_CODE, A_LOT_NO, A_STOCK_QTY, 
							A_CUST_CODE, A_WARE_POS, SYS_EMP_NO, SYSDATE()
	            		)
	            		;
	            	 else
	            	 	update TB_MOLD_STOCK
	            		   set STOCK_QTY = V_STOCK_QTY,
	            		   	   UPD_EMP_NO = A_SYS_EMP_NO,
	            		   	   UPD_DATE = SYSDATE()
	            		 where COMP_ID = A_COMP_ID
	            		   and WARE_CODE = A_WARE_CODE
	            		   and MOLD_CODE = A_MOLD_CODE
	            		   and LOT_NO = A_LOT_NO
	            		 ;
	            	 end if; -- if V_CHK_CNT = 0 then end
	            	 
	            	 -- 품목코드별 재고 처리
            		 -- TB_STOCK_ITEM 에 대응하는 MOLD 테이블을 모르겠어서 일단 보류.
	            	 
        		end if; -- if A_STOCK_YN = 'Y' then end
        	else
        		if A_STOCK_YN = 'Y' then
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
					 from   TB_MOLD_SUBUL
					 where COMP_ID = A_COMP_ID
					   and WARE_CODE = A_WARE_CODE
					   and MOLD_CODE = A_MOLD_CODE
					   and LOT_NO = A_LOT_NO
					   and STOCK_YN = 'Y'
					 ;
					
					 if A_IN_OUT = '1' then
					 	set V_IO_QTY_INOUT = A_IO_QTY;
					 else
					 	set V_IO_QTY_INOUT = A_IO_QTY * -1;
					 end if;
					
					 set V_STOCK_QTY = V_STOCK_QTY_PRE + V_IO_QTY_INOUT;
					 set V_STOCK_QTY_DATE = V_STOCK_QTY_PRE_DATE + V_IO_QTY_INOUT;
					
					 if V_STOCK_QTY_DATE < 0 and A_STOCK_CHK = 'Y' then
		            	 SET N_RETURN = -1;
		  				 SET V_RETURN = '[UPDATE] 변경후 재고가 부족합니다.'; 
		            	 leave PROC_BODY;
		            	 /* SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='재고가 부족합니다.'; */  
		             end if;
		            
		             select COUNT(*)
	            	   into V_CHK_CNT
	            	 from TB_MOLD_STOCK
	            	 where COMP_ID = A_COMP_ID
	            	   and WARE_CODE = A_WARE_CODE
	            	   and MOLD_CODE = A_MOLD_CODE
	            	   and LOT_NO = A_LOT_NO
	            	 ;
	            	
	            	 if V_CHK_CNT = 0 then
	            	 	insert into TB_MOLD_STOCK (
	            			COMP_ID, WARE_CODE, MOLD_CODE, LOT_NO, STOCK_QTY, 
							CUST_CODE, WARE_POS, SYS_EMP_NO, SYS_DATE
	            		) values (
	            			A_COMP_ID, A_WARE_CODE, A_MOLD_CODE, A_LOT_NO, A_STOCK_QTY, 
							A_CUST_CODE, A_WARE_POS, SYS_EMP_NO, SYSDATE()
	            		)
	            		;
	            	 else
	            	 	update TB_MOLD_STOCK
	            		   set STOCK_QTY = V_STOCK_QTY,
	            		   	   UPD_EMP_NO = A_SYS_EMP_NO,
	            		   	   UPD_DATE = SYSDATE()
	            		 where COMP_ID = A_COMP_ID
	            		   and WARE_CODE = A_WARE_CODE
	            		   and MOLD_CODE = A_MOLD_CODE
	            		   and LOT_NO = A_LOT_NO
	            		 ;
	            	 end if; -- if V_CHK_CNT = 0 then end
	            	 
	            	 -- 품목코드별 재고 처리
            		 -- TB_STOCK_ITEM 에 대응하는 MOLD 테이블을 모르겠어서 일단 보류.
	            	 
        		end if; -- if A_STOCK_YN = 'Y' then end
        	end if;
        
        	update TB_MOLD_SUBUL
        	   set IO_DATE = A_IO_DATE,
        	   	   IN_OUT = A_IN_OUT,
        	   	   WARE_CODE = A_WARE_CODE,
        	   	   MOLD_CODE = A_MOLD_CODE,
        	   	   LOT_NO = A_LOT_NO,
        	   	   STOCK_YN = A_STOCK_YN,
        	   	   IO_QTY = A_IO_QTY,
        	   	   IO_PRC = A_IO_PRC,
        	   	   IO_AMT = A_IO_AMT,
        	   	   CUST_CODE = A_CUST_CODE,
        	   	   UPD_EMP_NO = A_SYS_EMP_NO,
        	   	   UPD_DATE = SYSDATE()
        	 where COMP_ID = A_COMP_ID
        	   and KEY_VAL = A_KEY_VAL
        	;
        
        elseif A_SAVE_DIV = 'DELETE' then
        	
        	if V_STOCK_YN = 'Y' then
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
				from   TB_MOLD_SUBUL
				where COMP_ID = A_COMP_ID
				  and WARE_CODE = A_WARE_CODE
				  and MOLD_CODE = A_MOLD_CODE
				  and LOT_NO = A_LOT_NO
				;
			
				if A_IN_OUT = '1' then 
					set V_IO_QTY_INOUT = V_IO_QTY * -1;
				else
					set V_IO_QTY_INOUT = V_IO_QTY;
				end if;
			
				if V_STOCK_QTY_DATE < 0 and A_STOCK_CHK = 'Y' then
	            	SET N_RETURN = -1;
	  				SET V_RETURN = '[DELETE] 재고가 부족합니다.'; 
	            	leave PROC_BODY;
	            	/* SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT ='재고가 부족합니다.'; */  
	            end if;	
	           
	           	if V_CHK_CNT = 0 then
            		insert into TB_MOLD_STOCK (
            			COMP_ID, WARE_CODE, MOLD_CODE, LOT_NO, STOCK_QTY, 
						CUST_CODE, WARE_POS, SYS_EMP_NO, SYS_DATE
            		) values (
            			A_COMP_ID, A_WARE_CODE, A_MOLD_CODE, A_LOT_NO, A_STOCK_QTY, 
						A_CUST_CODE, A_WARE_POS, SYS_EMP_NO, SYSDATE()
            		)
            		;
            	else
            		update TB_MOLD_STOCK
            		   set STOCK_QTY = V_STOCK_QTY,
            		   	   UPD_EMP_NO = A_SYS_EMP_NO,
            		   	   UPD_DATE = SYSDATE()
            		  where COMP_ID = A_COMP_ID
            		    and WARE_CODE = A_WARE_CODE
            		    and MOLD_CODE = A_MOLD_CODE
            		    and LOT_NO = A_LOT_NO
            		  ;
            	end if; -- if V_CHK_CNT = 0 then end
            	
        	end if; -- if V_STOCK_YN = 'Y' then
        	
        	delete from TB_MOLD_SUBUL
        	where COMP_ID = A_COMP_ID
        	  and KEY_VAL = A_KEY_VAL
        	;
        	
		end if; -- INSERT, UPDATE, DELETE else if 구문 end
	end if; -- if A_SUBUL_YN = 'Y' then endif


	SET N_RETURN = 0;
  	SET V_RETURN = '수불처리 완료되었습니다.'; 
   
   
END