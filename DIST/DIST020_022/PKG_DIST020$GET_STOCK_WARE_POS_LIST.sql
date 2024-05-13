CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_DIST020$GET_STOCK_WARE_POS_LIST`(	
	in A_COMP_ID VARCHAR(10),
	in A_RACK_CODE varchar(20),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_RACK_CODE varchar(20);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	set V_RACK_CODE = REPLACE(A_RACK_CODE, '-', '');

	select 
		A.COMP_ID,
		A.ITEM_KIND,
		A.ITEM_CODE,
		C.ITEM_NAME,
		C.ITEM_SPEC,
		A.LOT_NO,
		str_to_date(B.SET_DATE, '%Y%m%d') as SET_DATE,
		A.STOCK_QTY,
		A.WARE_CODE,
		A.WARE_POS,
		A.WARE_POS_DATE,
		C.USE_YN,
		'DEL_POS' as DEL_POS,
		A.RMK
	from tb_stock A
		inner join tb_item_lot B 
			on (	A.COMP_ID = B.COMP_ID 
				and A.ITEM_CODE = B.ITEM_CODE 
				and A.LOT_NO = B.LOT_NO 
				and B.LOT_STATE = 'NORMAL') 
		inner join tb_item_code C 
			on (A.ITEM_CODE = C.ITEM_CODE)
	where A.COMP_ID = A_COMP_ID 
	  and A.STOCK_QTY > 0
	  and A.WARE_POS = V_RACK_CODE
	order by A.ITEM_CODE, str_to_date(B.SET_DATE, '%Y%m%d'), A.LOT_NO
	;
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end