CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_QUAL026$GET_MSUR_EQUI_LIST`(
			IN A_CLASS1 		bigint(20),
			IN A_EQUI_NAME		VARCHAR(50),
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	DECLARE V_CLASS1 VARCHAR(20);

	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	if A_CLASS1 = 0 then
		set V_CLASS1 = '';
	end if;

	select
		  A.EQUI_CODE,
		  A.CLASS1,
		  A.CLASS2,
		  A.TEMP_SEQ,
		  A.EQUI_NAME,
		  A.EQUI_SPEC,
		  A.EQUI_NUM,
		  A.MAKE_COMP,
		  A.MODEL_NAME,
		  A.BUY_AMT,
		  A.BUY_COMP,
		  STR_TO_DATE(A.BUY_DATE, '%Y%m%d') as BUY_DATE,
		  A.USE_DEPT,
		  A.ETC_RMK,
		  A.BUY_POST_NO,
		  A.BUY_ADDRESS,
		  A.BUY_PHONE,
		  A.RES_STATUS,
		  A.USE_EMP_NO,
		  (select kor_name
		   from insa_mst 
		   where emp_no = A.USE_EMP_NO) as USE_EMP_NAME,
		  A.BUY_EMAIL,
		  A.PREV_EQUI_CODE,
		  A.FILE_NAME,
		  A.REAL_FILE_NAME
	from TB_MSUR_EQUI A
	where A.CLASS1 LIKE CONCAT('%', V_CLASS1, '%')
	  and A.EQUI_NAME like CONCAT('%', A_EQUI_NAME, '%')
	;
	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END