CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_DIST024$GET_SUBUL_TOTAL_LIST`(	
	in A_COMP_ID VARCHAR(10),
	IN A_ST_DATE TIMESTAMP,
	IN A_ED_DATE TIMESTAMP,
	in A_ITEM_CODE VARCHAR(30),
	in A_ITEM_NAME VARCHAR(100),
	in A_ITEM_KIND BIGINT(20),
	in A_WARE_CODE bigint(20),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_ST_DATE VARCHAR(8);
	declare V_ED_DATE VARCHAR(8);
	
	declare V_PRE_DATE VARCHAR(8);
	declare V_END_YYMM VARCHAR(8);
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	set V_ST_DATE = DATE_FORMAT(A_ST_DATE, '%Y%m%d');
	set V_ED_DATE = DATE_FORMAT(A_ED_DATE, '%Y%m%d');
	set V_PRE_DATE = DATE_FORMAT(DATE_ADD(A_ST_DATE, interval - 1 month), '%Y%m%d');

	-- LEETEK의 PKG_ITEMSTOCKTOTALR, PKG_MATRSTOCKTOTALR 참조
	-- TC_IO_END <=> TB_IO_END
	-- VIEW_ITEM_CODE <=> TB_ITEM_CODE ? VIEW_ITEM ? 
	-- TC_SUBUL_ITEM, TC_SUBUL_MATR <=> TB_SUBUL ?

	select
		  MAX(YYMM)
	into V_END_YYMM
	from TB_IO_END A
		inner join VIEW_ITEM B
		on A.ITEM_CODE = B.ITEM_CODE
	where A.COMP_ID = A_COMP_ID
	  and A.YYMM < SUBSTRING(V_ST_DATE, 1, 6)
	  and CASE 
			  WHEN A_WARE_CODE != 0
			  THEN A.WARE_CODE = A_WARE_CODE
			  ELSE A.WARE_CODE LIKE '%'
		  END 
	;

	if V_END_YYMM is null then
		set V_END_YYMM = '202001';
	end if;

	--
	
	select 
		  A.ITEM_CODE, A.ITEM_NAME, A.ITEM_SPEC, A.WARE_CODE, 
		  SUM(A.PRE_QTY) as PRE_QTY, SUM(A.IN_QTY) as IN_QTY, SUM(A.OUT_QTY) as OUT_QTY,
		  (SUM(A.PRE_QTY) + SUM(A.IN_QTY) - SUM(A.OUT_QTY)) as STOCK_QTY,
		  SUM(A.PRE_AMT) as PRE_AMT, SUM(A.IN_AMT) as IN_AMT, SUM(A.OUT_AMT) as OUT_AMT,
		  (SUM(A.PRE_AMT) + SUM(A.IN_AMT) - SUM(A.OUT_AMT)) as STOCK_AMT,
		  A.ITEM_KIND, A.LOT_NO, A.CUST_CODE
	from (
		select
			  AA.COMP_ID, AA.ITEM_CODE, BB.ITEM_NAME, BB.ITEM_SPEC, AA.NEXT_QTY as PRE_QTY,
			  AA.NEXT_AMT as PRE_AMT, 0 as IN_QTY, 0 as IN_AMT, 0 as OUT_QTY, 0 as OUT_AMT,
			  AA.WARE_CODE, BB.ITEM_KIND, AA.LOT_NO, '' as CUST_CODE
		from TB_IO_END AA
			inner join VIEW_ITEM BB
				on AA.ITEM_CODE = BB.ITEM_CODE
		where AA.COMP_ID = A_COMP_ID
		  and CASE 
				  WHEN A_WARE_CODE != 0
				  THEN AA.WARE_CODE = A_WARE_CODE
				  ELSE AA.WARE_CODE LIKE '%'
			  end
		  and AA.YYMM = V_END_YYMM
		union all 
		select 
			  AA.COMP_ID, AA.ITEM_CODE, BB.ITEM_NAME, BB.ITEM_SPEC,
			  (case when AA.IN_OUT = '1' then AA.IO_QTY else AA.IO_QTY * -1 END) as PRE_QTY,
			  (case when AA.IN_OUT = '1' then AA.IO_AMT else AA.IO_AMT * -1 END) as PRE_AMT,
			  0 as IN_QTY, 0 as IN_AMT, 0 as OUT_QTY, 0 as OUT_AMT, AA.WARE_CODE,
			  AA.ITEM_KIND, AA.LOT_NO, AA.CUST_CODE
		from TB_SUBUL AA
			inner join VIEW_ITEM BB
				on AA.ITEM_CODE = BB.ITEM_CODE
		where AA.COMP_ID = A_COMP_ID
		  and CASE 
				  WHEN A_WARE_CODE != 0
				  THEN AA.WARE_CODE = A_WARE_CODE
				  ELSE AA.WARE_CODE LIKE '%'
			  end
		  and AA.IO_DATE between CONCAT(V_END_YYMM, '32') and V_PRE_DATE
		union all 
		select
		      AA.COMP_ID, AA.ITEM_CODE, BB.ITEM_NAME, BB.ITEM_SPEC,
		      (case when AA.IN_OUT = '1' then AA.IO_QTY else AA.IO_QTY * -1 END) as PRE_QTY,
		      (case when AA.IN_OUT = '1' then AA.IO_AMT else AA.IO_AMT * -1 END) as PRE_AMT,
		      0 as IN_QTY, 0 as IN_AMT, 0 as OUT_QTY, 0 as OUT_AMT, AA.WARE_CODE,
			  AA.ITEM_KIND, AA.LOT_NO, AA.CUST_CODE
		from TB_SUBUL AA
			inner join VIEW_ITEM BB
				on AA.ITEM_CODE = BB.ITEM_CODE
		where AA.COMP_ID = A_COMP_ID
		  and CASE 
				  WHEN A_WARE_CODE != 0
				  THEN AA.WARE_CODE = A_WARE_CODE
				  ELSE AA.WARE_CODE LIKE '%'
			  end
		and AA.IO_DATE between V_ST_DATE and V_ED_DATE
	) A
	where A.COMP_ID = A_COMP_ID
	  and A.ITEM_CODE like CONCAT('%', A_ITEM_CODE, '%')
	  and CASE 
			  WHEN A_ITEM_KIND != 0
			  THEN A.ITEM_KIND = A_ITEM_KIND
			  ELSE A.ITEM_KIND LIKE '%'
		  END 
	group by A.ITEM_CODE, A.ITEM_NAME, A.ITEM_SPEC, A.COMP_ID, A.WARE_CODE,
			 A.ITEM_KIND, A.LOT_NO, A.CUST_CODE
	;
	
	
	--

	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end