CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_MOLD001$GET_MOLD_LIST`(
			IN A_CLASS1 		bigint(20),
			in A_CLASS2			bigint(20),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	DECLARE V_CLASS1 VARCHAR(20);
	DECLARE V_CLASS2 VARCHAR(20);
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	if A_CLASS1 = 0 then
		set V_CLASS1 = '';
		set V_CLASS2 = '';
	else
		set V_CLASS1 = A_CLASS1;
		if A_CLASS2 = 0 then
			set V_CLASS2 = '';
		else
			set V_CLASS2 = A_CLASS2;
		end if;
	end if;

	select
		  A.MOLD_CODE,
		  A.CLASS1,
		  A.CLASS2,
		  A.CLASS_SEQ,
		  A.MOLD_NAME,
		  A.MOLD_SPEC,
		  A.LOT_YN,
		  A.STOCK_SAFE,
		  A.CUST_CODE,
		  A.ITEM_UNIT,
		  A.USE_YN,
		  A.RMK,
		  A.CODE_PRE,
		  A.WARE_POS
	from TB_MOLD A
	where A.CLASS1 LIKE CONCAT('%', V_CLASS1, '%')
	  and A.CLASS2 like CONCAT('%', V_CLASS2, '%')
	;

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END