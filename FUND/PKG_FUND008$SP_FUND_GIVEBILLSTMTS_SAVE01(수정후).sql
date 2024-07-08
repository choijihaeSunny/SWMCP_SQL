CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_FUND008$SP_FUND_GIVEBILLSTMTS_SAVE01`(
	in A_COMP_ID varchar(10),
	in A_SLIP_EMP_NO varchar(10),
	in A_SLIP_POST varchar(5),
	in A_SYS_EMP_NO varchar(10),
	in A_SLIP_DATE date, 
	in A_BAL_KIND varchar(1),
	in A_BILL_KIND varchar(10),
	in A_BILL_NO varchar(20),
	in A_BAL_SLIP_NUMB varchar(19),
	in A_END_SLIP_NUMB varchar(19),
	in A_BAL_NO varchar(100),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
)
begin
	
	declare OLD_SLIP_NO varchar(100);
	declare NEW_SLIP_NO varchar(100);
	declare IS_SLIP_NUMB varchar(100);
	declare IS_SLIP_CHK varchar(2);
	declare IS_SLIP_CHK2 varchar(2);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
	
	select max(slip_no)
	into OLD_SLIP_NO
	from tbl_slip_mst 
	where COMP_ID = A_COMP_ID
		and slip_date = DATE_FORMAT(A_SLIP_DATE,'%Y%m%d')
		and slip_emp_no = A_SLIP_EMP_NO;
	
	if OLD_SLIP_NO is null or OLD_SLIP_NO = '' then 
		set NEW_SLIP_NO = '0001';
	else 
		set NEW_SLIP_NO = lpad(OLD_SLIP_NO + 1, 4, '0'); 
	end if;
	set IS_SLIP_NUMB = CONCAT(DATE_FORMAT(A_SLIP_DATE,'%Y%m%d'), A_SLIP_EMP_NO, NEW_SLIP_NO);
	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
	
  	if A_BAL_KIND = '1' then
  		if A_BAL_SLIP_NUMB is null or A_BAL_SLIP_NUMB = '' then 
  		
  		
  		update tbl_out_bill_deta
  			set BAL_SLIP_NUMB = IS_SLIP_NUMB,
  				BAL_SLIP_DATE = DATE_FORMAT(A_SLIP_DATE,'%Y%m%d'),
  				BAL_SLIP_NO = NEW_SLIP_NO,
  				UPD_EMP_NO = A_SYS_EMP_NO,
  				UPD_DATE = now()
  			where COMP_ID = A_COMP_ID
  				and BILL_KIND = A_BILL_KIND
  				and BILL_NO = A_BILL_NO;
  			
  			insert into tbl_slip_mst
  			(
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
  			) values (
  				A_COMP_ID,
  				IS_SLIP_NUMB,
  				DATE_FORMAT(A_SLIP_DATE,'%Y%m%d'),
  				A_SLIP_EMP_NO,
  				NEW_SLIP_NO,
  				A_SLIP_POST,
  				'2',
  				'1',
  				'N',
  				A_SYS_EMP_NO,
  				now()
  			);
  		
  			
  			insert into tbl_slip_deta
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
  				SYS_DATE
  				
  			) 
  				select 
  						COMP_ID,
  						IS_SLIP_NUMB,
  						'1',
  						(select AC_CODE
	            	     from TBL_AC_CODE
	            	     where BEFORE_AC_CODE = '2110103') as AC_CODE, 
  						A_SLIP_POST,
  						0,
  						BILL_AMT,
  						BANK_CODE,
  						(select CUST_NAME
  						 from tc_cust_code
  						 where cust_code = tbl_out_bill_deta.BANK_CODE) as BANK_NAME,
  						BILL_NO,
  						CONT,
  						BAL_DATE,
  						END_DATE,
  						A_SYS_EMP_NO,
  						now()
  				from tbl_out_bill_deta
  				where COMP_ID = A_COMP_ID
  					and BILL_KIND = A_BILL_KIND
  					and BILL_NO = A_BILL_NO
  					and BAL_SLIP_NUMB = IS_SLIP_NUMB
  				union all
  				select
  						COMP_ID,
  						IS_SLIP_NUMB,
  						'2',
  						AC_CODE,
  						A_SLIP_POST,
  						BILL_AMT,
  						0,
  						CUST_CODE,
  						(select CUST_NAME
  						 from tc_cust_code
  						 where cust_code = tbl_out_bill_deta.CUST_CODE) as CUST_NAME,
  						 null,
  						 null,
  						 null,
  						 null,
  						 A_SYS_EMP_NO,
  						 now()
  				from tbl_out_bill_deta
  				where COMP_ID = A_COMP_ID
  					and BILL_KIND = A_BILL_KIND
  					and BILL_NO = A_BILL_NO
  					and BAL_SLIP_NUMB = IS_SLIP_NUMB
  				;
  		
  		
  		else 
  		
  		
  			select SLIP_YN, END_YN
			  into IS_SLIP_CHK, IS_SLIP_CHK2
			  from tbl_slip_mst
			  where COMP_ID = A_COMP_ID
			  	and slip_numb = A_BAL_SLIP_NUMB;
			  			
			  if IS_SLIP_CHK = '2' then
			  	signal sqlstate '20001' set message_text = '이미 승인한 건 입니다.#';
			  elseif IS_SLIP_CHK2 = 'Y' then
			  	signal sqlstate '20001' set message_text = '이미 마감된 건 입니다.#';
			  else
			  	update tbl_out_bill_deta 
			  	set BAL_SLIP_NUMB = null,
			  		BAL_SLIP_DATE = null,
			  		BAL_SLIP_NO = null,
			  		UPD_EMP_NO  = A_SYS_EMP_NO,
			  		UPD_DATE = now()
			  	where COMP_ID = A_COMP_ID
			  	and BAL_SLIP_NUMB = A_BAL_SLIP_NUMB;
			  
			    delete from tbl_slip_mst 
			    where COMP_ID = A_COMP_ID
			    	and SLIP_NUMB = A_BAL_SLIP_NUMB;
			    
			    
			    
			  end if;
			 
			 
  		end if;
  	elseif A_BAL_KIND = '2' then
  		if A_END_SLIP_NUMB is null or A_END_SLIP_NUMB = '' then 
  		
  		
  		update tbl_out_bill_deta 
  			set END_SLIP_NUMB = IS_SLIP_NUMB,
  				END_SLIP_DATE = DATE_FORMAT(A_SLIP_DATE,'%Y%m%d'),
  				END_SLIP_NO = NEW_SLIP_NO,
  				UPD_EMP_NO = A_SYS_EMP_NO,
  				UPD_DATE = now()
  			where COMP_ID = A_COMP_ID
  				and BILL_KIND = A_BILL_KIND
  				and BILL_NO = A_BILL_NO;
  
  			insert into tbl_slip_mst 
  			(
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
  			) values (
  				A_COMP_ID,
  				IS_SLIP_NUMB,
  				DATE_FORMAT(A_SLIP_DATE,'%Y%m%d'),
  				A_SLIP_EMP_NO,
  				NEW_SLIP_NO,
  				A_SLIP_POST,
  				'2',
  				'1',
  				'N',
  				A_SYS_EMP_NO,
  				now()
  			);
  		
  			insert into tbl_slip_deta
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
  				 select
  				 		COMP_ID,
  				 		END_SLIP_NUMB,
  				 		'1',
  				 		(select AC_CODE
	            	     from TBL_AC_CODE
	            	     where BEFORE_AC_CODE = '2110103') as AC_CODE, 
  				 		A_SLIP_POST,
  				 		BILL_AMT,
  				 		0,
  				 		CUST_CODE,
  				 		(select CUST_NAME
  						 from tc_cust_code
  						 where cust_code = tbl_out_bill_deta.CUST_CODE) as CUST_NAME,
  						A_BAL_NO,
  						null,
  						null,
  						null,
  						A_SYS_EMP_NO,
  						now(),
  						(select ETAX_CREATE_YN
  				  		 from tc_cust_code
  						where cust_code = tbl_out_bill_deta.CUST_CODE) as ETAX_CREATE_YN
  				 from tbl_out_bill_deta 
  				 where COMP_ID = A_COMP_ID
  				 	and BILL_KIND = A_BILL_KIND
  				 	and BILL_NO = A_BILL_NO
  				 	and END_SLIP_NUMB = IS_SLIP_NUMB
  				 union all 
  				 select 
  				 		COMP_ID,
  				 		END_SLIP_NUMB,
  				 		'2',
  				 		(select AC_CODE
	            	     from TBL_AC_CODE
	            	     where BEFORE_AC_CODE = '1110103') as AC_CODE, 
  				 		A_SLIP_POST,
  				 		0,
  				 		BILL_AMT,
  				 		BANK_CODE,
  				 		(select CUST_NAME
  						 from tc_cust_code
  						 where cust_code = tbl_out_bill_deta.BANK_CODE) as BANK_NAME,
  						A_BAL_NO,
  						null,
  						null,
  						null,
  						A_SYS_EMP_NO,
  						now(),
  						(select ETAX_CREATE_YN
  				  		 from tc_cust_code
  						where cust_code = tbl_out_bill_deta.CUST_CODE) as ETAX_CREATE_YN
  				 from tbl_out_bill_deta 
  				 where COMP_ID = A_COMP_ID
  				 	and BILL_KIND = A_BILL_KIND
  				 	and BILL_NO = A_BILL_NO
  				 	and END_SLIP_NUMB = IS_SLIP_NUMB;
  		
  		
  		
  		else 
  		
  		
  			select SLIP_YN, END_YN
			  into IS_SLIP_CHK, IS_SLIP_CHK2
			  from tbl_slip_mst
			  where COMP_ID = A_COMP_ID
			  	and slip_numb = A_BAL_SLIP_NUMB;
			  			
			  if IS_SLIP_CHK = '2' then
			  	signal sqlstate '20001' set message_text = '이미 승인한 건 입니다.#';
			  elseif IS_SLIP_CHK2 = 'Y' then
			  	signal sqlstate '20001' set message_text = '이미 마감된 건 입니다.#';
			  else
			  	update tbl_out_bill_deta 
			  	set BAL_SLIP_NUMB = null,
			  		BAL_SLIP_DATE = null,
			  		BAL_SLIP_NO = null,
			  		UPD_EMP_NO  = A_SYS_EMP_NO,
			  		UPD_DATE = now()
			  	where COMP_ID = A_COMP_ID
			  	and BAL_SLIP_NUMB = A_BAL_SLIP_NUMB;
			  
			    delete from tbl_slip_mst 
			    where COMP_ID = A_COMP_ID
			    	and SLIP_NUMB = A_BAL_SLIP_NUMB;
			    
			  
			    
			   end if; 
  		
  		
  		
  		end if;
  	end if;
 			  
  			
  	  	
    
  IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  END IF; 
END