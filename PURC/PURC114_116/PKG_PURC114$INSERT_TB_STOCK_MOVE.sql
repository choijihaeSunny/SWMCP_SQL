CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_PURC114$INSERT_TB_STOCK_MOVE`(		
	IN A_COMP_ID varchar(10),
	IN A_SET_DATE TIMESTAMP,
	IN A_SET_SEQ varchar(4),
	IN A_MOVE_DATE TIMESTAMP,
    IN A_ITEM_CODE varchar(20),
    IN A_LOT_NO varchar(30),
    IN A_QTY decimal(10, 0),
    IN A_COST decimal(16, 4),
   	IN A_AMT decimal(16, 4),
   	IN A_WARE_CODE bigint(20),
   	IN A_WARE_CODE_PRE bigint(20),
   	IN A_ITEM_KIND varchar(10),
   	IN A_RMK varchar(100),
	IN A_SYS_EMP_NO varchar(10),
	IN A_SYS_ID varchar(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_SET_NO varchar(10);
	declare V_MOVE_KEY varchar(30);

	declare V_DUP_CNT INT;

	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	SET N_RETURN = 0;
  	SET V_RETURN = '저장되었습니다.'; 
  
    if A_WARE_CODE = A_WARE_CODE_PRE then
		SET N_RETURN = -1;
      	SET V_RETURN = '이동전 창고와 이동후 창고가 같습니다.'; 
	end if;
  
  	SET V_SET_NO = (select IFNULL(MAX(SET_NO), 0) + 1
    				from TB_STOCK_MOVE
    				where SET_DATE = DATE_FORMAT(A_SET_DATE, '%Y%m%d')
    				  and SET_SEQ = A_SET_SEQ);
  
    SET V_MOVE_KEY := CONCAT('WM', DATE_FORMAT(A_SET_DATE, '%Y%m%d'), LPAD(A_SET_SEQ, 3, '0'), LPAD(V_SET_NO, 3, '0'));
  	
   	SET V_DUP_CNT = (select COUNT(*)
    				 from TB_STOCK_MOVE
   					 where MOVE_KEY = V_MOVE_KEY
    				);
    if V_DUP_CNT <> 0 then
    	SET V_SET_NO = V_SET_NO + 1;
    	SET V_MOVE_KEY := CONCAT('WM', DATE_FORMAT(A_SET_DATE, '%Y%m%d'), LPAD(A_SET_SEQ, 3, '0'), LPAD(V_SET_NO, 3, '0'));
    end if;
   
    INSERT INTO TB_STOCK_MOVE (
    	COMP_ID,
    	SET_DATE,
    	SET_SEQ,
    	SET_NO,
    	MOVE_KEY,
    	MOVE_DATE,
    	ITEM_CODE,
    	LOT_NO,
    	QTY,
    	COST,
   		AMT,
   		WARE_CODE,
   		WARE_CODE_PRE,
   		ITEM_KIND,
   		RMK
    	,SYS_EMP_NO
    	,SYS_ID
    	,SYS_DATE
    ) values (
   		A_COMP_ID,
    	DATE_FORMAT(A_SET_DATE, '%Y%m%d'),
    	LPAD(A_SET_SEQ, 3, '0'),
    	LPAD(V_SET_NO, 3, '0'),
    	V_MOVE_KEY,
    	DATE_FORMAT(A_MOVE_DATE, '%Y%m%d'),
    	A_ITEM_CODE,
    	A_LOT_NO,
    	A_QTY,
    	A_COST,
   		A_AMT,
   		A_WARE_CODE,
   		A_WARE_CODE_PRE,
   		A_ITEM_KIND,
   		A_RMK
    	,A_SYS_EMP_NO
    	,A_SYS_ID
    	,SYSDATE()
    )
    ;
	
	IF ROW_COUNT() = 0 THEN
  	  SET N_RETURN = -1;
      SET V_RETURN = '저장이 실패하였습니다.'; -- '저장이 실패하였습니다.'; 
  	END IF;  
  
end