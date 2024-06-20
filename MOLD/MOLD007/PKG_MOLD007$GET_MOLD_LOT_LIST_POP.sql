CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_MOLD007$GET_MOLD_LOT_LIST_POP`(
			IN A_COMP_ID VARCHAR(10),
			IN A_MOLD_CODE		VARCHAR(20),
			IN A_MOLD_NAME		VARCHAR(50),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	select
		  A.MOLD_CODE,
		  C.MOLD_NAME,
		  C.MOLD_SPEC,
		  C.LOT_YN,
		  A.LOT_NO,
		  B.QTY,
		  B.IN_COST,
		  C.STOCK_SAFE,
		  C.CUST_CODE,
		  (select CUST_NAME
		   from tc_cust_code
		   where cust_code = C.CUST_CODE) as CUST_NAME,
		  C.ITEM_UNIT,
		  C.RMK,
		  C.CODE_PRE,
		  C.WARE_POS
	from TB_MOLD_STOCK A
		inner join TB_MOLD_LOT B on (A.COMP_ID = B.COMP_ID
								 and A.MOLD_CODE = B.MOLD_CODE
								 and A.LOT_NO = B.LOT_NO)
		inner join TB_MOLD C on (B.MOLD_CODE = C.MOLD_CODE)
	where A.COMP_ID = A_COMP_ID
	  and C.MOLD_CODE LIKE CONCAT('%', A_MOLD_CODE, '%')
	  and C.MOLD_NAME like CONCAT('%', A_MOLD_NAME, '%')
	  and C.USE_YN = 'Y'
	  and B.LOT_STATE in (select DATA_ID
	  					  from SYS_DATA 
	  					  where path = 'cfg.mold.lotstate'
						    and CODE = 'M') -- 수리상태인 내역 호출
	  and A.STOCK_QTY > 0
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END