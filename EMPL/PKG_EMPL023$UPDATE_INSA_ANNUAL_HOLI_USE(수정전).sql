CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_EMPL023$UPDATE_INSA_ANNUAL_HOLI_USE`(
	IN A_COMP_ID varchar(10),
	IN A_OID bigint(20),
	IN A_SET_DATE DATETIME,
	IN A_EMP_NO char(8),
	IN A_SET_EMP char(8),
	IN A_ANNUAL_HOLI_KIND varchar(10),
	IN A_USE_ST_DATE DATETIME,
	IN A_USE_END_DATE DATETIME,
	IN A_ANNUAL_HOLI_REASON varchar(500),
	in A_USE_CNT decimal(5,1),
	IN A_RMKS varchar(100),
	in A_OLD_APP_YN char(1),
	IN A_APP_YN char(1),
	IN A_APP_DATE DATETIME,
	IN A_MODI_KEY bigint(20),
	IN A_UPDATE_ID decimal(10,0),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	declare cnt int;
	declare bCnt int;
	declare unuseEa int;
	declare bAppYn varchar(1);
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 
  
  	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
  	select APP_YN
  	  into bAppYn
  	from insa_annual_holi_use
  	where COMP_ID = A_COMP_ID
  	  and OID = A_OID;
  
  	
  	
  	if A_OLD_APP_YN = 'N' and A_APP_YN = 'Y' then
       
  	   update insa_annual_holi
		set UNUSE_EA = UNUSE_EA - A_USE_CNT,
			USE_EA = USE_EA + A_USE_CNT
		where COMP_ID = A_COMP_ID
  		  and EMP_NO = A_EMP_NO
  		  and year = date_format(A_USE_ST_DATE,'%Y')
  		  and DELETE_YN = 'N';
  	
       
		update insa_annual_holi_use
		  	set APP_YN = A_APP_YN,
				APP_DATE = date_format(A_APP_DATE,'%Y%m%d'),
				MODI_KEY = A_MODI_KEY + 1,
				UPDATE_ID = A_UPDATE_ID,
				UPDATE_DT = sysdate()
			where COMP_ID = A_COMP_ID
			  and OID = A_OID
			  and MODI_KEY = A_MODI_KEY;
	 elseif A_OLD_APP_YN = 'Y' and A_APP_YN = 'N' then
	   
	    
  	   update insa_annual_holi
		set UNUSE_EA = UNUSE_EA + A_USE_CNT,
			USE_EA = USE_EA - A_USE_CNT
		where COMP_ID = A_COMP_ID
  		  and EMP_NO = A_EMP_NO
  		  and year = date_format(A_USE_ST_DATE,'%Y')
  		  and DELETE_YN = 'N';
  	
       
		update insa_annual_holi_use
		  	set APP_YN = A_APP_YN,
				APP_DATE = date_format(A_APP_DATE,'%Y%m%d'),
				MODI_KEY = A_MODI_KEY + 1,
				UPDATE_ID = A_UPDATE_ID,
				UPDATE_DT = sysdate()
			where COMP_ID = A_COMP_ID
			  and OID = A_OID
			  and MODI_KEY = A_MODI_KEY;
	 
	 
  	 end if;
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
  
end