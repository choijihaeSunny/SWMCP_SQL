CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROD035$SET_COATING_PLAN_CONFIRM`(	
	in A_COMP_ID 			VARCHAR(10),
	in A_DEPT_CODE			VARCHAR(10),
	in A_SET_DATE 			DATETIME,
	in A_CONFIRM_YN_OLD		VARCHAR(1),
	in A_CONFIRM_YN			VARCHAR(1),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_SET_DATE	VARCHAR(8);
	declare V_CNT		INT;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET V_SET_DATE = date_format(A_SET_DATE,'%Y%m%d');

	select COUNT(*) 
	into V_CNT 
	from TB_COATING_PLAN_DET A
	where COMP_ID = A_COMP_ID 
	  and DEPT_CODE = A_DEPT_CODE 
	  and CONFIRM_YN = A_CONFIRM_YN_OLD 
	  and PLAN_DATE = V_SET_DATE;
	
	 
	if A_CONFIRM_YN = 'Y' and V_CNT > 0 then 
   
		SET N_RETURN = 0;
    	SET V_RETURN = '코팅계획 확정 완료했습니다.';
	elseif A_CONFIRM_YN = 'Y' and V_CNT = 0 then
		
		SET N_RETURN = -1;
    	SET V_RETURN = '코팅계획 확정 할 내역이 없습니다.';
    elseif A_CONFIRM_YN = 'N' and V_CNT > 0 then
		    
		SET N_RETURN = 0;
    	SET V_RETURN = '코팅계획 확정 취소 완료했습니다.';
    elseif A_CONFIRM_YN = 'N' and V_CNT = 0 then
		SET N_RETURN = -1;
    	SET V_RETURN = '코팅계획 확정 취소 할 내역이 없습니다.';
    else 
    	SET N_RETURN = 0;
	    SET V_RETURN = '조회되었습니다.';
	end if;


	update TB_COATING_PLAN_DET 
	set    CONFIRM_YN = A_CONFIRM_YN
	where COMP_ID = A_COMP_ID 
	  and DEPT_CODE = A_DEPT_CODE 
	  and CONFIRM_YN = A_CONFIRM_YN_OLD 
	  and PLAN_DATE = V_SET_DATE;

	 
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF; 	  
		
END