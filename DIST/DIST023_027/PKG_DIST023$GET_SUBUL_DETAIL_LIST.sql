CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_DIST023$GET_SUBUL_DETAIL_LIST`(	
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

	-- LEETEK의 PKG_ITEMSTOCKDETAILR, PKG_MATRSTOCKDETAILR 참조
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
			  THEN FIND_IN_SET(A.WARE_CODE, A_WARE_CODE)
			  ELSE A.WARE_CODE LIKE '%'
		  END 
	  
	;

	-- V_END_YYMM null 일 경우 처리 수정 필요
	
	--
	select
		  A.TOP_SORT, A.IN_OUT, A.ITEM_CODE, /*STR_TO_DATE(A.IO_DATE, '%Y%m%d') as IO_DATE*/A.IO_DATE, A.ITEM_NAME,
		  A.ITEM_SPEC, A.IO_GUBUN, A.PRE_QTY, A.IN_QTY, A.OUT_QTY,
		  SUM(A.NEXT_QTY) OVER(PARTITION BY A.ITEM_CODE 
		  					   ORDER BY A.TOP_SORT, A.IO_DATE, A.IN_OUT, A.KEY_VAL) AS STOCK_QTY,
		  A.PRE_AMT, A.IN_AMT, A.OUT_AMT, 
		  SUM(A.NEXT_AMT) OVER(PARTITION BY A.ITEM_CODE 
		  					   ORDER BY A.TOP_SORT, A.IO_DATE, A.IN_OUT, A.KEY_VAL) AS STOCK_AMT,
		  A.LOT_NO
	from (
		select
			  '0' as TOP_SORT, '0' as IN_OUT, AA.ITEM_CODE, AA.ITEM_NAME, AA.ITEM_SPEC,
			  '이월' as IO_DATE, '' as IO_GUBUN,
			  SUM(
				  	(case when AA.IN_OUT = '1' then AA.IO_QTY else 0 END) 
				  - (case when AA.IN_OUT = '2' then AA.IO_QTY else 0 END)
			  ) as PRE_QTY,
			  0 as IN_QTY, 0 as OUT_QTY,
			  SUM(
				  	(case when AA.IN_OUT = '1' then AA.IO_QTY else 0 end)
				  - (case when AA.IN_OUT = '2' then AA.IO_QTY else 0 END)
			  ) as NEXT_QTY,
			  '' as KEY_VAL,
			  SUM(
				    (case when AA.IN_OUT = '1' then AA.IO_AMT else 0 END)
				  - (case when AA.IN_OUT = '2' then AA.IO_AMT else 0 END)
			  ) as PRE_AMT,
			  0 as IN_AMT, 0 as OUT_AMT,
			  SUM(
				    (case when AA.IN_OUT = '1' then AA.IO_AMT else 0 END)
				  - (case when AA.IN_OUT = '2' then AA.IO_AMT else 0 END)
			  ) as NEXT_AMT,
			  AA.LOT_NO
		from (
			select	
				  AAA.ITEM_CODE, BBB.ITEM_NAME, BBB.ITEM_SPEC, '1' as IN_OUT, AAA.NEXT_QTY as IO_QTY,
				  AAA.NEXT_AMT as IO_AMT, AAA.LOT_NO
			from TB_IO_END AAA
				inner join VIEW_ITEM BBB
					on AAA.ITEM_CODE = BBB.ITEM_CODE
			where AAA.COMP_ID = A_COMP_ID
			  and CASE 
					  WHEN A_WARE_CODE != 0
					  THEN FIND_IN_SET(AAA.WARE_CODE, A_WARE_CODE)
					  ELSE AAA.WARE_CODE LIKE '%'
				  END 
			  and AAA.YYMM = V_END_YYMM
			  and AAA.ITEM_CODE like CONCAT('%', A_ITEM_CODE, '%')
			  and CASE 
					  WHEN A_ITEM_KIND != 0
					  THEN FIND_IN_SET(BBB.ITEM_KIND, A_ITEM_KIND)
					  ELSE BBB.ITEM_KIND LIKE '%'
				  END 
			union all 
			select	
				  AAA.ITEM_CODE, BBB.ITEM_NAME, BBB.ITEM_SPEC, AAA.IN_OUT, AAA.IO_QTY,
				  AAA.IO_AMT, AAA.LOT_NO
			from TB_SUBUL AAA
				inner join VIEW_ITEM BBB
					on AAA.ITEM_CODE = BBB.ITEM_CODE
			where AAA.COMP_ID = A_COMP_ID
			  and CASE 
					  WHEN A_WARE_CODE != 0
					  THEN FIND_IN_SET(AAA.WARE_CODE, A_WARE_CODE)
					  ELSE AAA.WARE_CODE LIKE '%'
				  END 
			  and AAA.IO_DATE between V_ST_DATE and V_ED_DATE
			  and AAA.ITEM_CODE like CONCAT('%', A_ITEM_CODE, '%')
			  and CASE 
					  WHEN A_ITEM_KIND != 0
					  THEN FIND_IN_SET(AAA.ITEM_KIND, A_ITEM_KIND)
					  ELSE AAA.ITEM_KIND LIKE '%'
				  END 
		) AA
		group by AA.ITEM_CODE, AA.ITEM_NAME, AA.ITEM_SPEC
		union all
		select 
			  '1' as TOP_SORT, AA.IN_OUT, AA.ITEM_CODE, BB.ITEM_NAME, BB.ITEM_SPEC,
			  AA.IO_DATE, AA.IO_GUBN, 
			  0 as PRE_QTY,
			  (case when IN_OUT = '1' then IO_QTY else 0 END) as IN_QTY,
			  (case when IN_OUT = '2' then IO_QTY else 0 END) as OUT_QTY,
			  (case when IN_OUT = '1' then IO_QTY else IO_QTY * -1 END) as NEXT_QTY,
			  AA.KEY_VAL, 0 as PRE_AMT,
			  (case when IN_OUT = '1' then IO_AMT else 0 END) as IN_AMT,
			  (case when IN_OUT = '2' then IO_AMT else 0 END) as OUT_AMT,
			  (case when IN_OUT = '1' then IO_AMT else IO_AMT * -1 END) as NEXT_AMT,
			  AA.LOT_NO
		from TB_SUBUL AA
			inner join VIEW_ITEM BB
				on AA.ITEM_CODE = BB.ITEM_CODE
		where AA.COMP_ID = A_COMP_ID
		  and CASE 
				  WHEN A_WARE_CODE != 0
				  THEN FIND_IN_SET(AA.WARE_CODE, A_WARE_CODE)
				  ELSE AA.WARE_CODE LIKE '%'
			  END 
		  and AA.IO_DATE between V_ST_DATE and V_ED_DATE
		  and AA.ITEM_CODE like CONCAT('%', A_ITEM_CODE, '%')
		  and CASE 
				  WHEN A_ITEM_KIND != 0
				  THEN FIND_IN_SET(AA.ITEM_KIND, A_ITEM_KIND)
				  ELSE AA.ITEM_KIND LIKE '%'
			  END 
	) A
	;

	--

	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end