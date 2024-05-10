CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_DIST022$GET_ITEM_STOCK_LIST`(	
	in A_COMP_ID VARCHAR(10),
	in A_ITEM_CODE VARCHAR(30),
	in A_ITEM_NAME VARCHAR(100),
	in A_ITEM_KIND BIGINT(20),
	-- 재고창고값 in 받아야 한다.
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select 
		A.COMP_ID,
		A.ITEM_KIND,
		A.ITEM_CODE,
		C.ITEM_NAME,
		C.ITEM_SPEC,
		str_to_date(B.SET_DATE, '%Y%m%d') as SET_DATE,
		A.STOCK_QTY,
		A.WARE_CODE,
		A.WARE_POS,
		C.USE_YN
	from tb_stock A
		inner join tb_item_lot B on (A.COMP_ID = B.COMP_ID 
								 and A.ITEM_CODE = B.ITEM_CODE 
								 and A.LOT_NO = B.LOT_NO 
								 and B.LOT_STATE = 'NORMAL') 
		inner join tb_item_code C on (A.ITEM_CODE = C.ITEM_CODE)
	where A.COMP_ID = A_COMP_ID 
	 	and A.ITEM_CODE like concat('%', A_ITEM_CODE, '%')
	 	and C.ITEM_NAME like concat('%', A_ITEM_NAME, '%')
	 	and case when A_ITEM_KIND = 0 
	 				then A.ITEM_KIND 
	 				else A_ITEM_KIND 
	 			 end = A_ITEM_KIND
	 	and A.STOCK_QTY > 0
	 order by A.ITEM_CODE, str_to_date(B.SET_DATE, '%Y%m%d'), A.LOT_NO
	;
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end