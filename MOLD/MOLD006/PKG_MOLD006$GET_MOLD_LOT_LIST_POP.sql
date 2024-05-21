CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_MOLD006$GET_MOLD_LOT_LIST_POP`(
			IN A_MOLD_CODE		VARCHAR(20),
			IN A_MOLD_NAME		VARCHAR(50),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare V_LOT_STATE varchar(10);

	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	set V_LOT_STATE = (select DATA_ID
					   from SYS_DATA
					   where path = 'cfg.mold.lotstate'
						 and CODE = 'N');

	select
		  B.MOLD_CODE,
		  B.MOLD_NAME,
		  B.MOLD_SPEC,
		  B.LOT_YN,
		  A.LOT_NO,
		  A.QTY,
		  A.IN_COST,
		  B.STOCK_SAFE,
		  B.CUST_CODE,
		  (select CUST_NAME
		   from tc_cust_code
		   where cust_code = B.CUST_CODE) as CUST_NAME,
		  B.ITEM_UNIT,
		  B.RMK,
		  B.CODE_PRE,
		  B.WARE_POS
	from TB_MOLD_LOT A
		inner join TB_MOLD B on (A.MOLD_CODE = B.MOLD_CODE)
	where B.MOLD_CODE LIKE CONCAT('%', A_MOLD_CODE, '%')
	  and B.MOLD_NAME like CONCAT('%', A_MOLD_NAME, '%')
	  and B.USE_YN = 'Y'
	  and A.LOT_STATE = V_LOT_STATE
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END