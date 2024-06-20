CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_QUAL031$GET_CORRECT_REQ_RESULT_LIST`(
			IN A_ST_DATE 		TIMESTAMP,
			IN A_ED_DATE		TIMESTAMP,
			IN A_ACT_RESULT 	bigint(20), 
            OUT N_RETURN      	INT,
            OUT V_RETURN      	VARCHAR(4000)
)
PROC:begin
	
	declare V_ACT_RESULT varchar(3);
	
	declare exit HANDLER for sqlexception
	call USP_SYS_GET_ERRORINFO_ALL(V_RETURN, N_RETURN); 

	set V_ACT_RESULT = (select CODE
						from SYS_DATA
						where DATA_ID = A_ACT_RESULT);
	
	if V_ACT_RESULT = 0 then -- 요청
		select
			  STR_TO_DATE(A.REQ_DATE, '%Y%m%d') as REQ_DATE,
			  A.REQ_SEQ,
			  A.REQ_KEY,
			  A.STATUS_DIV,
			  A.REQ_EMP_NO,
			  (select KOR_NAME
			   from INSA_MST
			   where EMP_NO = A.REQ_EMP_NO) as REQ_EMP_NAME,
			  A.REQ_DEPT,
			  A.REC_DEPT,
			  STR_TO_DATE(A.REPLY_DATE, '%Y%m%d') as REPLY_DATE,
			  STR_TO_DATE(A.TEST_DATE, '%Y%m%d') as TEST_DATE,
			  A.REQ_RMK,
			  A.STATUS_NOW,
			  A.CORRECT_PLAN,
			  A.REQ_CAUSE,
			  A.REQ_PLAN,
			  STR_TO_DATE(A.IMP_DATE, '%Y%m%d') as IMP_DATE,
			  A.ACT_RESULT,
			  A.CONTINUE_PLAN,
			  A.ACT_EFFECT,
			  A.ACT_EFFECT_DETAIL,
			  A.ACT_EFFECT_MANAGE,
			  A.REPLY_EMP_NO,
			  (select KOR_NAME
			   from INSA_MST
			   where EMP_NO = A.REPLY_EMP_NO) as REPLY_EMP_NAME,
			  A.CONF_EMP_NO,
			  (select KOR_NAME
			   from INSA_MST
			   where EMP_NO = A.CONF_EMP_NO) as CONF_EMP_NAME,
			  A.SYS_DATE
		from TB_CORRECT_REQ_RESULT A -- 20240618 요청상태 내역일 경우 날짜 불문하고 조회하도록 수정.
		where A.ACT_RESULT = A_ACT_RESULT
		;
	else -- V_ACT_RESULT = 1 -- 조치완료
		select
			  STR_TO_DATE(A.REQ_DATE, '%Y%m%d') as REQ_DATE,
			  A.REQ_SEQ,
			  A.REQ_KEY,
			  A.STATUS_DIV,
			  A.REQ_EMP_NO,
			  (select KOR_NAME
			   from INSA_MST
			   where EMP_NO = A.REQ_EMP_NO) as REQ_EMP_NAME,
			  A.REQ_DEPT,
			  A.REC_DEPT,
			  STR_TO_DATE(A.REPLY_DATE, '%Y%m%d') as REPLY_DATE,
			  STR_TO_DATE(A.TEST_DATE, '%Y%m%d') as TEST_DATE,
			  A.REQ_RMK,
			  A.STATUS_NOW,
			  A.CORRECT_PLAN,
			  A.REQ_CAUSE,
			  A.REQ_PLAN,
			  STR_TO_DATE(A.IMP_DATE, '%Y%m%d') as IMP_DATE,
			  A.ACT_RESULT,
			  A.CONTINUE_PLAN,
			  A.ACT_EFFECT,
			  A.ACT_EFFECT_DETAIL,
			  A.ACT_EFFECT_MANAGE,
			  A.REPLY_EMP_NO,
			  (select KOR_NAME
			   from INSA_MST
			   where EMP_NO = A.REPLY_EMP_NO) as REPLY_EMP_NAME,
			  A.CONF_EMP_NO,
			  (select KOR_NAME
			   from INSA_MST
			   where EMP_NO = A.CONF_EMP_NO) as CONF_EMP_NAME,
			  A.SYS_DATE
		from TB_CORRECT_REQ_RESULT A
		where A.REQ_DATE between DATE_FORMAT(A_ST_DATE, '%Y%m%d') and DATE_FORMAT(A_ED_DATE, '%Y%m%d')
		  and A.ACT_RESULT = A_ACT_RESULT
		;
	end if;
				
	

	set N_RETURN := 0;
    set V_RETURN := '조회 되었습니다';
END