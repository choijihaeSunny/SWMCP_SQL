CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROD035$GET_STOCK_DET_POP`(	
	in A_COMP_ID VARCHAR(10),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select  
	      'N' as IS_CHK,
		  A.ITEM_CODE,
		  B.ITEM_NAME,
		  B.ITEM_SPEC,
		  A.PROG_CODE,
		  A.STOCK_QTY - NVL(C.STOCK_QTY, 0) as PLAN_QTY, -- 마감이 안 되어 실적이 되지 못한 계획 건 조회
		  A.LOT_NO,
		  A.STOCK_QTY,
		  A.WARE_CODE 
	from tb_stock A
		inner join tb_item_code B
			on A.ITEM_CODE = B.ITEM_CODE
		LEFT join tb_coating_plan C
			on A.ITEM_CODE = C.MATR_CODE 
	where A.ITEM_KIND = (select DATA_ID 
						 from SYS_DATA 
						 where path = 'cfg.item' 
						 and CODE = 'M') -- 원자재'
	;

	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
END