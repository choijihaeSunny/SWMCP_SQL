CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROD035$GET_STOCK_DET_POP`(	
	in A_COMP_ID VARCHAR(10),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select  
	      'N' as IS_CHECK,
		  A.ITEM_CODE,
		  B.ITEM_NAME,
		  B.ITEM_SPEC,
		  A.PROG_CODE,
		  NVL(C.PLAN_TOT_QTY, 0)  as PLAN_QTY, -- 마감이 안 되어 실적이 되지 못한 계획 건 조회
		  A.LOT_NO,
		  A.STOCK_QTY - NVL(C.PLAN_TOT_QTY, 0) as STOCK_QTY,
		  A.WARE_CODE,
		  D.ORDER_KEY
	from TB_STOCK A
		inner join TB_ITEM_CODE B
			on A.ITEM_CODE = B.ITEM_CODE
		LEFT join TB_COATING_PLAN C
			on A.ITEM_CODE = C.MATR_CODE 
		LEFT join TB_ORDER_DET D
			on C.COMP_ID = D.COMP_ID
		   and C.ORDER_KEY = D.ORDER_KEY
	where A.COMP_ID = A_COMP_ID
	  and A.ITEM_KIND = (select DATA_ID 
						 from SYS_DATA 
						 where path = 'cfg.item' 
						 and CODE = 'M') -- 원자재'
	  and A.LOT_NO like 'LM%' -- 원자재
	;

	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
END