CREATE DEFINER=`ubidom`@`%` PROCEDURE `swmcp`.`PKG_SALE020$GET_OUT_MST_POP`(	
	in A_COMP_ID VARCHAR(10),
	in A_ST_DATE DATETIME,
	in A_ED_DATE DATETIME,
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
		A.OUT_MST_KEY,
		str_to_date(A.OUT_DATE,'%Y%m%d') as OUT_DATE,
		A.CUST_CODE,
		B.CUST_NAME,
		A.EMP_NO,
		A.DEPT_CODE,
		A.CURR_UNIT,
		A.EX_RATE,
		A.PJ_NO,
		D.PJ_NAME,
		D.SHIP_INFO,
		A.SALES_TYPE,
		A.DELI_PLACE,
		A.SALES_KIND,
		A.CUST_LOCATION,
		A.PACK_SPEC,
		A.RMK
	from tb_out_mst A
		inner join tc_cust_code B on (A.COMP_ID = B.COMP_ID and A.CUST_CODE = B.CUST_CODE)
		left join insa_mst C on (A.COMP_ID = C.COMP_ID and A.EMP_NO = C.EMP_NO)
		left join tb_project D on (A.COMP_ID = D.COMP_ID and A.PJ_NO = D.PJ_CODE)
		left join dept_code E on (A.DEPT_CODE = E.DEPT_CODE)
	where A.COMP_ID = A_COMP_ID 
	 	and A.OUT_DATE between date_format(A_ST_DATE, '%Y%m%d') and date_format(A_ED_DATE, '%Y%m%d');
	
	
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.'; 
end