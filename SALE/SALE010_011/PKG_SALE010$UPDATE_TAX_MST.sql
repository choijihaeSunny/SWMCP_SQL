CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_SALE010$UPDATE_TAX_MST`(	
	IN A_IS_CHK varchar(3),
	IN A_CUD_KEY varchar(10),
	IN A_COMP_ID varchar(10),
	INOUT A_OID bigint(20),
	IN A_SET_DATE DATE,
	IN A_SET_SEQ varchar(4),
	INOUT A_VBILL_NUM varchar(20),
	IN A_VBILL_DATE DATE,
	IN A_CUST_CODE varchar(10),
	IN A_TAX_AMT decimal(20,4),
	IN A_TAX_VAT decimal(20,4),
	IN A_SEND_DIV varchar(10),
	IN A_VBILL_DIV varchar(10),
	IN A_T_ENG_AMT decimal(20,4),
	IN A_CURN_UNIT varchar(10),
	IN A_CURN_RATE decimal(20,4),
	IN A_RMK varchar(50),
	IN A_SLIP_NUMB varchar(20),
	IN A_EMP_NO varchar(10),
	IN A_INSERT_ID decimal(10,0),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	declare V_SEQ VARCHAR(4);
    declare IS_SLIP_CHK varchar(2);
	declare IS_SLIP_CHK2 varchar(2);
    declare OLD_SLIP_NO varchar(5);
	declare NEW_SLIP_NO varchar(5);
    declare IS_SLIP_NUMB varchar(100);
    declare A_AC_CODE varchar(10);
	declare A_AC_CODE2 varchar(10);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	if A_IS_CHK = 'Y' then
		
		if A_CUD_KEY = 'DELETE' then
		
			SET N_RETURN = 0;
		  	SET V_RETURN = '삭제되었습니다.'; 
		  
		     /*전표생성여부 및 승인여부 확인*/
		    SELECT SLIP_YN, END_YN
	          INTO IS_SLIP_CHK, IS_SLIP_CHK2
		      from tbl_slip_mst
			 where SLIP_NUMB = A_SLIP_NUMB
			   and COMP_ID = A_COMP_ID;
		  
			 if IS_SLIP_CHK = '2' then
	        	signal sqlstate '20001' set message_text = '이미 승인한(전표승인) 건 입니다.#';
	        elseif IS_SLIP_CHK2 = 'Y' then
	        	signal sqlstate '20001' set message_text = '이미 마감된(회계마감) 건 입니다.#';
	        else
	        
				SET N_RETURN = 0;
			  	SET V_RETURN = '발행이 취소되었습니다.'; 
		        
		        DELETE FROM TBL_SLIP_DETA 
	 	        WHERE COMP_ID = A_COMP_ID 
	 	      	AND SLIP_NUMB = A_SLIP_NUMB;
	 	      
		        DELETE FROM TBL_SLIP_MST 
		        WHERE COMP_ID = A_COMP_ID 
		        AND SLIP_NUMB = A_SLIP_NUMB;
		       
	 	       	/*세금계산서 생성내역 삭제*/
		  	    DELETE FROM tax_mst
			     where OID = A_OID
				 and COMP_ID = A_COMP_ID;
				
	        end if;
		  
			IF ROW_COUNT() = 0 THEN
		  	  SET N_RETURN = -1;
		      SET V_RETURN = '삭제가 실패하였습니다.'; 
		  	END IF;  
		  
		else
		
			SET N_RETURN = 0;
		  	SET V_RETURN = '저장되었습니다.'; 
		  
		  	SET A_OID = NEXTVAL(sq_com);
		  
			select LPAD(FN_GET_SEQ('tax_mst', date_format(A_SET_DATE, '%Y%m%d')), 4, '0') INTO V_SEQ;
		
			SET A_VBILL_NUM = concat(date_format(A_SET_DATE, '%Y%m%d'), V_SEQ);
		  
		  	INSERT INTO tax_mst
			  		(COMP_ID,
					OID,
					SET_DATE,
					SET_SEQ,
					VBILL_NUM,
					VBILL_DATE,
					CUST_CODE,
					TAX_AMT,
					TAX_VAT,
					SEND_DIV,
					VBILL_DIV,
					T_ENG_AMT,
					CURN_UNIT,
					CURN_RATE,
					RMK,
					SLIP_NUMB,
					INSERT_ID,
					INSERT_DT,
					UPDATE_ID,
					UPDATE_DT,
					MODI_KEY)
				values
					(A_COMP_ID,
					A_OID,
					date_format(A_SET_DATE, '%Y%m%d'),
					V_SEQ,
					A_VBILL_NUM,
					date_format(A_VBILL_DATE, '%Y%m%d'),
					A_CUST_CODE,
					A_TAX_AMT,
					A_TAX_VAT,
					A_SEND_DIV,
					A_VBILL_DIV,
					A_T_ENG_AMT,
					A_CURN_UNIT,
					A_CURN_RATE,
					A_RMK,
					A_SLIP_NUMB,
					A_INSERT_ID,
					NOW(),
					A_INSERT_ID,
					NOW(),
					0);
			
				
				/*회계전표 생성*/
				SELECT MAX(SLIP_NO) 
			    INTO OLD_SLIP_NO 
			    FROM TBL_SLIP_MST 
			    WHERE COMP_ID = A_COMP_ID
				  AND SLIP_DATE = DATE_FORMAT(A_SET_DATE,'%Y%m%d')
				  AND SLIP_EMP_NO = A_EMP_NO;
			     
			    IF OLD_SLIP_NO IS NULL OR OLD_SLIP_NO = '' THEN
			        set NEW_SLIP_NO = '0001';
			    ELSE 
			        set NEW_SLIP_NO = LPAD(OLD_SLIP_NO + 1, 4, '0');
			    END IF;   
			   
			    set IS_SLIP_NUMB = concat(DATE_FORMAT(A_SET_DATE,'%Y%m%d'), A_EMP_NO, NEW_SLIP_NO);
		
				UPDATE tax_mst 
		        SET SLIP_NUMB = IS_SLIP_NUMB, 
		            UPDATE_ID = A_INSERT_ID, 
		            UPDATE_DT = now() 
		        WHERE COMP_ID = A_COMP_ID 
		          AND OID = A_OID;
		         
		        INSERT INTO TBL_SLIP_MST(
		            COMP_ID, 
		            SLIP_NUMB, 
		            SLIP_DATE, 
		            SLIP_EMP_NO, 
		            SLIP_NO, 
		            SLIP_POST, 
		            SLIP_KIND, 
		            SLIP_YN, 
		            END_YN, 
		            SYS_EMP_NO, 
		            SYS_DATE
		        )VALUES(
		           A_COMP_ID, 
		           IS_SLIP_NUMB, 
		           DATE_FORMAT(A_SET_DATE,'%Y%m%d'), 
		           A_EMP_NO, 
		           NEW_SLIP_NO, 
		           A_DEPT, 
		           '2' , 
		           '1' , 
		           'N' , 
		           A_INSERT_ID, 
		           now()
		        );    
		       
	  			select AC_CODE into A_AC_CODE from tbl_auto_account_info where COMP_ID = A_COMP_ID and INFO_CODE = '01'; 
		       
		        INSERT INTO TBL_SLIP_DETA 
		        (
		                   COMP_ID, 
		                   SLIP_NUMB, 
		                   SLIP_SEQ, 
		                   AC_CODE, 
		                   POST_APPL, 
		                   DR_AMT, 
		                   CR_AMT, 
		                   CUST_CODE, 
		                   CUST_NAME, 
		                   AC_NO, 
		                   SLIP_CONT, 
		                   ST_DATE, 
		                   END_DATE, 
		                   SYS_EMP_NO, 
		                   SYS_DATE, 
		                   ETAX_CREATE_YN
		        ) 
		            SELECT A.COMP_ID, 
		            	   IS_SLIP_NUMB, 
		            	   '1', 
		            	   '1110501', 
		            	   A_DEPT, 
		            	   0, 
		            	   A.TAX_AMT,   
		            	   A.CUST_CODE, 
		             	   FN_CUST_NAME(A.COMP_ID, A.CUST_CODE) as CUST_NAME, 
		            	   
		            	   A.VBILL_NUM, 
		            	   '', 
		            	   A.VBILL_DATE, 
		            	   null, 
		            	   A_INSERT_ID, 
		            	   now(), 
		            	   'Y'
		            FROM tax_mst A 
		            WHERE A.COMP_ID = A_COMP_ID
		              AND A.OID = A_OID
		              
		            UNION ALL
		             
		            SELECT A.COMP_ID, 
		            	   IS_SLIP_NUMB, 
		            	   dense_rank() over(order by B.OID asc) + 1 ,  
		            	   '1110103', 
		            	   A_DEPT, 
		            	   B.SUPP_AMT,   
		            	   0, 
		            	   B.CUST_CODE, 
		             	   FN_CUST_NAME(A.COMP_ID, B.CUST_CODE) as CUST_NAME, 
		            	   
		            	   B.VBILL_NUM, 
		            	   '', 
		            	   NULL, 
		            	   NULL,
		            	   A_INSERT_ID, 
		            	   now(), 
		            	   'Y'
		            FROM tax_mst A 
		            	inner join tax_det B on (A.OID = B.TAX_OID)
		            WHERE A.COMP_ID = A_COMP_ID
		              AND A.OID = A_OID;
				
				
			IF ROW_COUNT() = 0 THEN
		  	  SET N_RETURN = -1;
		      SET V_RETURN = '저장이 실패하였습니다.'; 
		  	END IF;  
		
		end if;
		
	end if;
  
end