CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_SALE026$GET_OUT_DET_LOT`(	
	in A_COMP_ID VARCHAR(10),
	in A_OUT_KEY VARCHAR(30),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select 
		A.COMP_ID,
		str_to_date(A.SET_DATE,'%Y%m%d') as SET_DATE,
		A.SET_SEQ,
		A.SET_NO,
		A.OUT_MST_KEY,
		A.OUT_KEY,
		A.LOT_NO,
		str_to_date(A.OUT_DATE,'%Y%m%d') as OUT_DATE,
		B.CUST_CODE,
		B.EX_RATE,
		A.ITEM_CODE,
		A.QTY,
		C.COST,
		A.RETURN_QTY,
		A.RMK,
		C.ORDER_KEY,
		B.DEPT_CODE,
		D.WARE_CODE
	from tb_out_det_lot A
		inner join tb_out_mst B on (A.COMP_ID = B.COMP_ID and A.OUT_MST_KEY = B.OUT_MST_KEY)
		inner join tb_out_det C on (A.COMP_ID = C.COMP_ID and A.OUT_KEY = C.OUT_KEY)
		left join dept_code D on (B.DEPT_CODE = D.DEPT_CODE)
	where A.COMP_ID = A_COMP_ID 
	 	and A.OUT_KEY = A_OUT_KEY;
	
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end