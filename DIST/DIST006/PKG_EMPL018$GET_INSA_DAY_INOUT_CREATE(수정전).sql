CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_EMPL018$GET_INSA_DAY_INOUT_CREATE`(
	IN A_COMP_ID VARCHAR(10),
	IN A_SET_DATE  DATETIME,
	IN A_SYS_USER DECIMAL(10),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
PROC:BEGIN
	
	DECLARE A_OID_ID BIGINT(20);
    DECLARE A_YYMM VARCHAR(6);
    DECLARE A_CNT  DECIMAL;
    
    DECLARE A_EMP_NO  VARCHAR(8);
    DECLARE A_WORK_DIV  VARCHAR(10);
    DECLARE A_WORK_KIND  VARCHAR(10);
    DECLARE A_RMKS  VARCHAR(100);
  
    DECLARE endRow  INT DEFAULT FALSE;
	DECLARE v_count INT DEFAULT -1;
	DECLARE v_emp_no varchar(8);
	DECLARE v_dept_code varchar(20);
	DECLARE v_cnt  INT;
    DECLARE A_RST_TIME VARCHAR(20);
    DECLARE A_REND_TIME VARCHAR(20);
   
	  
	DECLARE cursor1 CURSOR FOR SELECT EMP_NO, DEPT_CODE FROM INSA_MST where ( RETIRE_DATE is null or EMP_STATE <> 'T' );
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET endRow = TRUE;
 
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	BEGIN 
		SET N_RETURN = -1;
		CALL USP_SYS_GET_ERRORINFO(V_RETURN); 
	END; 
	SET N_RETURN = 0;
	SET V_RETURN = '생성완료';
   
 
   select DISTINCT HOLY_KND  into A_WORK_KIND
    from tc_fact_cal
   where concat(YYYY,MM,DD)  = date_format(A_SET_DATE,'%Y%m%d');
      
  OPEN cursor1;
  emp_loop: LOOP
 
  SET v_count = v_count +1 ; 
  SET endRow = false; 
 
  
  FETCH cursor1 INTO v_emp_no, v_dept_code;
    
    
    IF endRow THEN
      LEAVE emp_loop;
    END IF;
     
    
    
       select COUNT(*)  into v_cnt
        from insa_day_inout_excel
       where SET_DATE = date_format(A_SET_DATE,'%Y%m%d')
         and EMP_NO = v_emp_no
         and DELETE_YN  = 'N';
        
       
    if v_cnt = 0 then 
          
	       select EMP_NO, WORK_DIV, RMKS into A_EMP_NO, A_WORK_DIV, A_RMKS
	        from insa_longtime_worker
	       where ST_DATE <= date_format(A_SET_DATE,'%Y%m%d') and END_DATE >= date_format(A_SET_DATE,'%Y%m%d')
	         and EMP_NO = v_emp_no
	         and DELETE_YN  = 'N';
	     
	      if ( IFNULL(A_EMP_NO, 'N' ) <> 'N' ) then 
	            
		  	INSERT INTO insa_day_inout
				  	   	(COMP_ID,
							OID,
							SET_DATE,
							EMP_NO,
							WORK_TYPE,
							WORK_KIND,
							ST_TIME,
							END_TIME,
							WORK_TIME,
							OVER_TIME,
							SPE_TIME,
							RMKS,
							ADJ_EMP,
							ADJ_DATE,
							OUTING_TIME,
							COMBACK_TIME,
							INPUT_DATE,
							INPUT_ST_TIME,
							MODI_KEY,
							INSERT_ID,
							INSERT_DT,
							UPDATE_ID,
							UPDATE_DT,
							DELETE_YN)
				   select  	A_COMP_ID,
							NEXTVAL(sq_com),
						    date_format(A_SET_DATE,'%Y%m%d'),
						    v_emp_no,
						    A_WORK_KIND,
						    A_WORK_DIV,
						    null,
						    null,
						    8,
						    0,
						    0,
						    A_RMKS,
						    null,
							null,
							0,
							0,
							null,
							null,
							0,
							A_SYS_USER,
							sysdate(),
							A_SYS_USER,
							sysdate(),
							'N';
		  Else
		      
		       select EMP_NO, ANNUAL_HOLI_KIND, ANNUAL_HOLI_REASON into A_EMP_NO, A_WORK_DIV,  A_RMKS
		        from insa_annual_holi_use
		       where USE_ST_DATE <= date_format(A_SET_DATE,'%Y%m%d') and USE_END_DATE >= date_format(A_SET_DATE,'%Y%m%d')
		         and EMP_NO = v_emp_no
		         and APP_YN = 'Y'
		         and DELETE_YN  = 'N';
		     
		      if ( IFNULL(A_EMP_NO, 'N' ) <> 'N' ) then 
		            
			  	INSERT INTO insa_day_inout
					  	   	(COMP_ID,
								OID,
								SET_DATE,
								EMP_NO,
								WORK_TYPE,
								WORK_KIND,
								ST_TIME,
								END_TIME,
								WORK_TIME,
								OVER_TIME,
								SPE_TIME,
								RMKS,
								ADJ_EMP,
								ADJ_DATE,
								OUTING_TIME,
								COMBACK_TIME,
								INPUT_DATE,
								INPUT_ST_TIME,
								MODI_KEY,
								INSERT_ID,
								INSERT_DT,
								UPDATE_ID,
								UPDATE_DT,
								DELETE_YN)
					   select  	A_COMP_ID,
								NEXTVAL(sq_com),
							    date_format(A_SET_DATE,'%Y%m%d'),
							    v_emp_no,
							    A_WORK_KIND,
							    A_WORK_DIV,
							    null,
							    null,
							    8,
							    0,
							    0,
							    A_RMKS,
							    null,
								null,
								0,
								0,
								null,
								null,
								0,
								A_SYS_USER,
								sysdate(),
								A_SYS_USER,
								sysdate(),
								'N';
				 else
				          
				          
	
				  	INSERT INTO insa_day_inout
						  	   	(COMP_ID,
									OID,
									SET_DATE,
									EMP_NO,
									WORK_TYPE,
									WORK_KIND,
									ST_TIME,
									END_TIME,
									WORK_TIME,
									OVER_TIME,
									SPE_TIME,
									RMKS,
									ADJ_EMP,
									ADJ_DATE,
									OUTING_TIME,
									COMBACK_TIME,
									INPUT_DATE,
									INPUT_ST_TIME,
									MODI_KEY,
									INSERT_ID,
									INSERT_DT,
									UPDATE_ID,
									UPDATE_DT,
									DELETE_YN)
						   select  	A_COMP_ID,
									NEXTVAL(sq_com),
								    date_format(A_SET_DATE,'%Y%m%d'),
								    v_emp_no,
								    A_WORK_KIND,
								    null,
								    null,
								    null,
								    8,
								    0,
								    0,
								    null,
								    null,
									null,
									0,
									0,
									null,
									null,
									0,
									A_SYS_USER,
									sysdate(),
									A_SYS_USER,
									sysdate(),
									'N';
		         End if;
	            
	        End if;
    else
          
	       select EMP_NO, WORK_TYPE, ST_TIME, END_TIME into A_EMP_NO, A_WORK_DIV, A_RST_TIME, A_REND_TIME
	        from insa_day_inout_excel
	       where SET_DATE = date_format(A_SET_DATE,'%Y%m%d')
	         and EMP_NO = v_emp_no
	         and DELETE_YN  = 'N';
    
	       if A_RST_TIME = '' or  A_REND_TIME = '' THEN
	      	  	INSERT INTO insa_day_inout
					  	   	(COMP_ID,
								OID,
								SET_DATE,
								EMP_NO,
								WORK_TYPE,
								WORK_KIND,
								ST_TIME,
								END_TIME,
								WORK_TIME,
								OVER_TIME,
								SPE_TIME,
								RMKS,
								ADJ_EMP,
								ADJ_DATE,
								OUTING_TIME,
								COMBACK_TIME,
								INPUT_DATE,
								INPUT_ST_TIME,
								MODI_KEY,
								INSERT_ID,
								INSERT_DT,
								UPDATE_ID,
								UPDATE_DT,
								DELETE_YN)
					   select  	A_COMP_ID,
								NEXTVAL(sq_com),
							    date_format(A_SET_DATE,'%Y%m%d'),
							    v_emp_no,
							    A_WORK_KIND,
							    null,
							    null,
							    null,
							    8,
							    0,
							    0,
							    null,
							    null,
								null,
								0,
								0,
								null,
								null,
								0,
								A_SYS_USER,
								sysdate(),
								A_SYS_USER,
								sysdate(),
								'N';
			 else
			    INSERT INTO insa_day_inout
			  	   	(COMP_ID,
						OID,
						SET_DATE,
						EMP_NO,
						WORK_TYPE,
						WORK_KIND,
						ST_TIME,
						END_TIME,
						WORK_TIME,
						OVER_TIME,
						SPE_TIME,
						RMKS,
						ADJ_EMP,
						ADJ_DATE,
						OUTING_TIME,
						COMBACK_TIME,
						INPUT_DATE,
						INPUT_ST_TIME,
						MODI_KEY,
						INSERT_ID,
						INSERT_DT,
						UPDATE_ID,
						UPDATE_DT,
						DELETE_YN)
			  SELECT  	A_COMP_ID,
						NEXTVAL(sq_com),
						T_A.SET_DATE,
						T_A.EMP_NO,
						A_WORK_KIND as HOLY_CHK,
						T_A.WORK_KIND,
						T_A.ST_TIME,
						T_A.END_TIME,
						case when  SUBSTRING(T_A.R_ST_TIME,12,8) = '00:00:00' or   SUBSTRING(T_A.R_END_TIME,12,8) = '00:00:00' then 8 else  FN_EMP_WORK_TIME_CAL(T_A.COMP_ID, 'A', T_A.S_ST_TIME,  T_A.S_END_TIME, T_A.R_ST_TIME, T_A.R_END_TIME) end  as WORK_TIME,
						case when  SUBSTRING(T_A.R_ST_TIME,12,8) = '00:00:00' or   SUBSTRING(T_A.R_END_TIME,12,8) = '00:00:00' then 0 else  FN_EMP_WORK_TIME_CAL(T_A.COMP_ID, 'B', T_A.S_ST_TIME,  T_A.S_END_TIME, T_A.R_ST_TIME, T_A.R_END_TIME) end  as EX_TIME,
						case when  SUBSTRING(T_A.R_ST_TIME,12,8) = '00:00:00' or   SUBSTRING(T_A.R_END_TIME,12,8) = '00:00:00' then 0 else  FN_EMP_WORK_TIME_CAL(T_A.COMP_ID, 'C', T_A.N_ST_TIME,  T_A.N_END_TIME, T_A.R_ST_TIME, T_A.R_END_TIME) end as SP_TIME,
						  null,
						T_A.ADJ_EMP,
						T_A.ADJ_DATE,
						0,
						0,
						T_A.INPUT_DATE,
						T_A.INPUT_ST_TIME,
						0,
						A_SYS_USER,
						sysdate(),
						A_SYS_USER,
						sysdate(),
						'N'
				  FROM ( select A.COMP_ID,
				                 A.SET_DATE,
								 A.EMP_NO, 
								 A.WORK_KIND,
								 B.WORK_TYPE,
								 B.ST_TIME,
								 B.END_TIME,
								 B.ADJ_EMP,
								 B.ADJ_DATE,
								 B.INPUT_DATE,
								 B.INPUT_ST_TIME,
							     date_format(concat( A.SET_DATE,concat(REPLACE(A.ST_TIME , ':',''),'00' )), '%Y-%m-%d %H:%i:%s') as S_ST_TIME,
								 date_format(case when convert(SUBSTRING(A.ST_TIME,1,2),INT) < convert(SUBSTRING(A.END_TIME,1,2),INT) then date_format(concat( A.SET_DATE,concat(REPLACE(A.END_TIME , ':',''),'00' )), '%Y-%m-%d %H:%i:%s')  
								                                  else  DATE_ADD( date_format(concat( A.SET_DATE,concat(REPLACE(A.END_TIME , ':',''),'00' )), '%Y-%m-%d %H:%i:%s'), interval 1 day) end, '%Y-%m-%d %H:%i:%s')   as S_END_TIME,
								 date_format(concat( A.SET_DATE,REPLACE(B.ST_TIME , ':','')), '%Y-%m-%d %H:%i:%s')  as R_ST_TIME,
								 date_format(case when convert(SUBSTRING(B.ST_TIME,1,2),INT) < convert(SUBSTRING(B.END_TIME,1,2),INT) then date_format(concat( A.SET_DATE,REPLACE(B.END_TIME , ':','')), '%Y-%m-%d %H:%i:%s')  
								                                  else  DATE_ADD( date_format(concat( A.SET_DATE,REPLACE(B.END_TIME , ':','')), '%Y-%m-%d %H:%i:%s'), interval 1 day) end, '%Y-%m-%d %H:%i:%s')   as R_END_TIME,
								 date_format(concat( A.SET_DATE,concat(REPLACE('2200' , ':',''),'00' )), '%Y-%m-%d %H:%i:%s') as N_ST_TIME,
											date_format(case when convert(SUBSTRING(A.ST_TIME,1,2),INT) < convert(SUBSTRING('0600',1,2),INT) then date_format(concat( A.SET_DATE,concat(REPLACE('0600', ':',''),'00' )), '%Y-%m-%d %H:%i:%s')  
											                                  else  DATE_ADD( date_format(concat( A.SET_DATE,concat(REPLACE('0600', ':',''),'00' )), '%Y-%m-%d %H:%i:%s'), interval 1 day) end, '%Y-%m-%d %H:%i:%s')   as N_END_TIME                                	
						  from insa_day_work_kind   A inner join  insa_day_inout_excel  B on A.COMP_ID = B.COMP_ID and A.SET_DATE = B.SET_DATE  and A.EMP_NO = B.EMP_NO 
						where A.SET_DATE = date_format(A_SET_DATE,'%Y%m%d')
						  and A.EMP_NO = v_emp_no
						 ) T_A ;
			 
			 end if;
     End if;
    
      iterate emp_loop;
   
  END loop emp_loop;
 
  SELECT v_count; 
 
  
  CLOSE cursor1;
 
    
END