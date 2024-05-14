CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_DIST027$GET_IO_END_LIST`(	
	in A_COMP_ID VARCHAR(10),
	IN A_YYMM TIMESTAMP,
	in A_ITEM_KIND BIGINT(20),
	in A_WARE_CODE bigint(20),
	in A_END_GUBUN INT,
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	
	declare V_CNT INT;
	declare V_YYMM VARCHAR(6);
	
	
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	-- LEETEK 의 PKG_STND_WAREENDMONS 참조
	-- TC_IO_END <=> TB_IO_END
	-- VIEW_ITEM_CODE <=> TB_ITEM_CODE ? VIEW_ITEM ? 
	-- TC_SUBUL_ITEM, TC_SUBUL_MATR <=> TB_SUBUL ?

	--
	
	set V_YYMM = DATE_FORMAT(A_YYMM, '%Y%m');
	
	
	if A_END_GUBUN = 0 then
	
		select COUNT(*)
		into V_CNT
		from TB_IO_END
		where YYMM = V_YYMM
		  and ITEM_KIND = A_ITEM_KIND
		  and WARE_CODE = A_WARE_CODE
		;
	
		if V_CNT > 0 then
			select 
				  A.COMP_ID, A.ITEM_CODE, B.ITEM_NAME, B.ITEM_SPEC, A.ITEM_KIND,
				  A.LOT_NO, A.WARE_CODE, A.PRE_QTY, A.PRE_AMT, A.IN_QTY,
				  A.IN_AMT, A.OUT_QTY, A.OUT_AMT, A.NEXT_QTY, A.NEXT_AMT
			from TB_IO_END A
				inner join VIEW_ITEM B
					on A.ITEM_CODE = B.ITEM_CODE
			where 0 = 1
			;
		else
			select
				  A.COMP_ID, A.ITEM_CODE, A.ITEM_NAME, A.ITEM_SPEC, A.ITEM_GUBUN,
				  A.LOT_NO, A.WARE_CODE, A.YYMM, A.PRE_QTY, A.PRE_AMT,
				  A.IN_QTY, A.IN_AMT, A.OUT_QTY, A.OUT_AMT,
				  (A.PRE_QTY + A.IN_QTY - A.OUT_QTY) AS NEXT_QTY,
				  (CASE WHEN (A.PRE_QTY + A.IN_QTY - A.OUT_QTY) = 0 THEN 0 ELSE (A.PRE_AMT + A.IN_AMT - A.OUT_AMT) end) AS NEXT_AMT,
				  A.ITEM_KIND
			from (
				select
					  Y.COMP_ID, Y.ITEM_CODE, Y.ITEM_NAME, Y.ITEM_SPEC, Y.ITEM_GUBUN,
					  Y.LOT_NO, Y.WARE_CODE, V_YYMM as YYMM, SUM(Y.PRE_QTY) as PRE_QTY, SUM(Y.PRE_AMT) as PRE_AMT,
					  SUM(Y.IN_QTY) as IN_QTY, SUM(Y.IN_AMT) as IN_AMT, SUM(Y.OUT_QTY) as OUT_QTY, SUM(Y.OUT_AMT) as OUT_AMT,
					  Y.ITEM_KIND
				from (
					select 
						  X.COMP_ID, Z.ITEM_CODE, Z.ITEM_NAME, Z.ITEM_SPEC, Z.ITEM_KIND as ITEM_GUBUN,
						  X.LOT_NO, X.WARE_CODE,
						  (CASE WHEN X.IN_OUT = '1' THEN X.IO_QTY WHEN X.IN_OUT = '2' THEN 0 ELSE 0 END) AS IN_QTY,
			              (CASE WHEN X.IN_OUT = '1' THEN X.IO_AMT WHEN X.IN_OUT = '2' THEN 0 ELSE 0 END) AS IN_AMT,
			              (CASE WHEN X.IN_OUT = '1' THEN 0 WHEN X.IN_OUT = '2' THEN X.IO_QTY ELSE 0 END) AS OUT_QTY,
			              (CASE WHEN X.IN_OUT = '1' THEN 0 WHEN X.IN_OUT = '2' THEN X.IO_AMT ELSE 0 END) AS OUT_AMT,
			               0 AS PRE_QTY, 0 AS PRE_AMT,
			              X.ITEM_KIND
					from VIEW_ITEM Z
						inner join TB_SUBUL X
							on X.ITEM_CODE = Z.ITEM_CODE
							and X.ITEM_KIND = A_ITEM_KIND
							and X.WARE_CODE = A_WARE_CODE
							and X.IO_DATE between CONCAT(V_YYMM, '01') and DATE_FORMAT(LAST_DAY(A_YYMM), '%Y%m%d')
					where X.STOCK_YN = 'Y'
					union all 
					select
						  IO.COMP_ID, Z.ITEM_CODE, Z.ITEM_NAME, Z.ITEM_SPEC, Z.ITEM_KIND as ITEM_GUBUN,
						  IO.LOT_NO, IO.WARE_CODE,
						  0 as IN_QTY,
						  0 as IN_AMT,
						  0 as OUT_QTY,
						  0 as OUT_AMT,
						  NVL(IO.NEXT_QTY, 0) as PRE_QTY, NVL(IO.NEXT_AMT, 0) as PRE_AMT,
						  IO.ITEM_KIND
					from VIEW_ITEM Z
						inner join TB_IO_END IO
							on Z.ITEM_CODE = IO.ITEM_CODE
							and IO.ITEM_KIND = A_ITEM_KIND
							and IO.WARE_CODE = A_WARE_CODE
							and IO.YYMM = DATE_FORMAT(DATE_ADD(A_YYMM, interval - 1 month), '%Y%m')
				) Y
				where Y.COMP_ID = A_COMP_ID
				  and Y.ITEM_KIND = A_ITEM_KIND
				  and Y.WARE_CODE = A_WARE_CODE
				group by Y.COMP_ID, Y.ITEM_CODE, Y.ITEM_NAME, Y.ITEM_SPEC, Y.LOT_NO,
					     Y.WARE_CODE
			) A
			-- A_ITEM_GUBUN이 1이 아닐경우 적용되었으나 해당하는 컬럼이 없어 보류.
			WHERE A.PRE_QTY <> 0 OR A.PRE_AMT <> 0 OR A.IN_QTY <> 0 OR A.IN_AMT <> 0 OR A.OUT_QTY <> 0 OR A.OUT_AMT <> 0 
			;
		end if; -- if V_CNT > 0 then end
	else
		select
			  A.COMP_ID, A.ITEM_CODE, B.ITEM_NAME, B.ITEM_SPEC, B.ITEM_KIND as ITEM_GUBUN,
			  A.LOT_NO, A.WARE_CODE, A.PRE_QTY, A.PRE_AMT, A.IN_QTY,
			  A.IN_AMT, A.OUT_QTY, A.OUT_AMT, A.NEXT_QTY, A.NEXT_AMT,
			  A.ITEM_KIND
		from TB_IO_END A
			inner join VIEW_ITEM B
				on A.ITEM_CODE = B.ITEM_CODE
		where A.COMP_ID = A_COMP_ID
		  and A.ITEM_KIND = A_ITEM_KIND
		  and A.WARE_CODE = A_WARE_CODE
		  and A.YYMM = V_YYMM
		;
	end if;

	
	
	
	

	

	--

	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end