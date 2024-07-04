CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_PROD035$GET_STOCK_DET_POP`(	
	in A_COMP_ID VARCHAR(10),
	in A_WARE_CODE bigint,
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
		  A.STOCK_QTY,
		  (A.STOCK_QTY - SUM(C.PLAN_QTY - C.WORK_QTY)) as PLAN_QTY,  -- 마감이 안 되어 실적이 되지 못한 계획 건 조회
		  A.LOT_NO,
		  A.WARE_CODE
	from TB_STOCK A inner join TB_ITEM_CODE B on A.ITEM_CODE = B.ITEM_CODE
					left outer join tb_coating_plan_det C on A.COMP_ID = C.COMP_ID and A.LOT_NO = C.MATR_LOT_NO and C.END_YN = 'N' and C.PLAN_QTY > C.WORK_QTY 
	where A.COMP_ID = A_COMP_ID
	  and A.ITEM_KIND = (select DATA_ID 
						 from SYS_DATA 
						 where path = 'cfg.item' 
						 and CODE = 'M') -- 원자재'
	  and A.WARE_CODE = A_WARE_CODE
	  and A.STOCK_QTY > 0 
	group by A.ITEM_CODE,
		  B.ITEM_NAME,
		  B.ITEM_SPEC,
		  A.PROG_CODE, 
		  A.STOCK_QTY,
		  A.LOT_NO, A.WARE_CODE;

	
	SET N_RETURN = 0; 
    SET V_RETURN = '조회되었습니다.'; 
END