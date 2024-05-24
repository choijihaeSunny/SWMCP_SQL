CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_COMM_POPUP$GET_MOLD_LOT_STOCK`(	
	in A_COMP_ID VARCHAR(10),
	in A_MOLD_CODE VARCHAR(30),
	in A_MOLD_NAME VARCHAR(100),
	in A_MOLD_SPEC VARCHAR(100),
	in A_MOLD_KIND BIGINT(20),
	in A_WARE_CODE BIGINT(20),
	in A_USE_YN		VARCHAR(1),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select 
		A.COMP_ID,
		A.MOLD_CODE,
		C.MOLD_NAME,
		C.MOLD_SPEC,
		str_to_date(B.SET_DATE, '%Y%m%d') as SET_DATE,
		A.LOT_NO,
		A.STOCK_QTY,
		A.WARE_CODE,
		A.WARE_POS,
		C.USE_YN
	from tb_mold_stock A
		inner join tb_mold_lot B on (A.COMP_ID = B.COMP_ID 
								 and A.MOLD_CODE = B.MOLD_CODE 
								 and A.LOT_NO = B.LOT_NO  
-- 								 and B.LOT_STATE = 'NORMAL'
								 ) 
		inner join tb_mold C on (A.MOLD_CODE = C.MOLD_CODE)
	where A.COMP_ID = A_COMP_ID 
		and case when A_WARE_CODE != 0 
	 				  then A.WARE_CODE = A_WARE_CODE 
	 				  else A.WARE_CODE like '%'
	 			  end
	 	and A.MOLD_CODE like concat('%', A_MOLD_CODE, '%')
	 	and C.MOLD_NAME like concat('%', A_MOLD_NAME, '%')
	 	and C.MOLD_SPEC like concat('%', A_MOLD_SPEC, '%')	 	
	 	and A.STOCK_QTY > 0
	 	and C.USE_YN = A_USE_YN
	 order by A.MOLD_CODE, str_to_date(B.SET_DATE, '%Y%m%d'), A.LOT_NO
	;
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end