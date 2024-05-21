CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_MOLD007$INSERT_MOLD_SCRAP_LIST`(		
	IN A_COMP_ID varchar(10),
	IN A_SET_DATE TIMESTAMP,
	IN A_SET_SEQ varchar(4),
    IN A_MOLD_CODE varchar(20),
    IN A_LOT_NO varchar(30),
    IN A_QTY decimal(10, 0),
    IN A_COST decimal(16, 4),
    IN A_DEPT_CODE varchar(10),
    IN A_SCRAP_CAUSE bigint(20),
    IN A_RMK varchar(100),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_LOT_STATE varchar(10);

	declare V_SET_NO varchar(10);
	declare V_MOLD_SCRAP_KEY varchar(30);

	declare V_DUP_CNT INT;

	declare V_AMT decimal(16, 4);

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
  	SET V_SET_NO = (select IFNULL(MAX(SET_NO), 0) + 1
    				from TB_MOLD_SCRAP
    				where SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d')
    				  and SET_SEQ = A_SET_SEQ);
  
    SET V_MOLD_SCRAP_KEY := CONCAT('DD', right(DATE_FORMAT(A_SET_DATE, '%Y%m'), 4), LPAD(A_SET_SEQ, 3, '0'), LPAD(V_SET_NO, 3, '0'));
   
    SET V_DUP_CNT = (select COUNT(*)
    				 from TB_MOLD_SCRAP
   					 where MOLD_SCRAP_KEY = V_MOLD_SCRAP_KEY
    				);
    if V_DUP_CNT <> 0 then
    	set V_SET_NO = V_SET_NO + 1;
    	SET V_MOLD_SCRAP_KEY := CONCAT('DD', right(DATE_FORMAT(A_SET_DATE, '%Y%m'), 4), LPAD(A_SET_SEQ, 3, '0'), LPAD(V_SET_NO, 3, '0'));
    end if;
   
   	set V_AMT = A_QTY * A_COST;
  	
    INSERT INTO TB_MOLD_SCRAP (
    	COMP_ID,
    	SET_DATE,
    	SET_SEQ,
    	SET_NO,
    	MOLD_SCRAP_KEY,
    	MOLD_CODE,
    	LOT_NO,
    	QTY,
    	COST,
    	AMT,
    	DEPT_CODE,
    	SCRAP_CAUSE,
    	RMK
    	,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
    ) values (
    	A_COMP_ID,
    	DATE_FORMAT(A_SET_DATE, '%Y%m%d'),
    	LPAD(A_SET_SEQ, 3, '0'),
    	V_SET_NO,
    	V_MOLD_SCRAP_KEY,
    	A_MOLD_CODE,
    	A_LOT_NO,
    	A_QTY,
    	A_COST,
    	V_AMT,
    	A_DEPT_CODE,
    	A_SCRAP_CAUSE,
    	A_RMK
    	,A_SYS_EMP_NO
    	,A_SYS_ID
    	,SYSDATE()
    )
    ;
   
    -- 폐기상태로 UPDATE
    set V_LOT_STATE = (select DATA_ID
					   from SYS_DATA
					   where path = 'cfg.mold.lotstate'
						 and CODE = 'P');
	
	update TB_MOLD_LOT
	   set LOT_STATE = V_LOT_STATE
	 where LOT_NO = A_LOT_NO
	;
						
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; 
  	END IF;  
  
end