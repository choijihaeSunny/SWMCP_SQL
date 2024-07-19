CREATE DEFINER=`root`@`%` PROCEDURE `swmcp`.`PKG_EMPL008$PRINT_CERTIFICATION_DATA`(
	IN A_COMP_ID varchar(10),
	IN A_PASSPOST_DATE DATETIME,
	IN A_PASSPOST_NO varchar(20),
	OUT N_RETURN INT,
	OUT V_RETURN VARCHAR(4000)
	)
begin
	DECLARE EXIT HANDLER FOR SQLEXCEPTION 
	CALL USP_SYS_GET_ERRORINFO(V_RETURN); 
  	SELECT a.comp_id as COMP_ID,
             a.EMP_NO        AS EMP_NO,   
             if(a.CERT_KIND='1' , '재  직  증  명  서','경  력  증  명  서')     AS CERT_KIND,   
             str_to_date(A.REQ_DATE,'%Y%m%d') AS APPLY_DATE,   
             str_to_date(A.BAL_DATE,'%Y%m%d')  AS PASSPOST_DATE,   
             a.BAL_NO   AS PASSPOST_NO,   
             CONCAT(b.kor_name,if(B.CHN_NAME != '' or B.CHN_NAME != null,concat('(',B.CHN_NAME,')'),''))      AS  KOR_NAME,
             case when length(B.REGI_NUMB) > 6 then CONCAT(SUBSTR(B.REGI_NUMB,1,6),'-*******') else B.REGI_NUMB end REGI_NUMB,
             b.address        AS EMP_ADDRES,
             B.DEPT_CODE     AS POST_CODE,
             FN_POST_NAME(A.COMP_ID,B.DEPT_CODE)  AS POST_NAME,
             FN_USE_CODE_NAME2( a.comp_id, 'cfg.insa.IS02' , B.JIKWEE)   AS JIKWEE, 
             str_to_date(B.ENTER_DATE,'%Y%m%d') AS ENTER_DATE,  
             if(B.RETIRE_DATE = '' or B.RETIRE_DATE = null,str_to_date(A.BAL_DATE,'%Y%m%d'),str_to_date(B.RETIRE_DATE,'%Y%m%d')) AS RETIRE_DATE,
             year(if(B.RETIRE_DATE = '' or B.RETIRE_DATE = null,str_to_date(A.BAL_DATE,'%Y%m%d'),str_to_date(B.RETIRE_DATE,'%Y%m%d'))) - year(str_to_date(B.ENTER_DATE,'%Y%m%d')) as TERM_YEAR,
             mod(timestampdiff(month,str_to_date(B.ENTER_DATE,'%Y%m%d'),if(B.RETIRE_DATE = '' or B.RETIRE_DATE = null,str_to_date(A.BAL_DATE,'%Y%m%d'),str_to_date(B.RETIRE_DATE,'%Y%m%d'))),12) as TERM_MONTH,
             a.USE_REASON      AS USE_TYPE,
             a.work_nm     AS WORK_NAME, 
             a.cust_subject  AS CUST_SUBJECT,
             a.BAL_EMP       AS BALGBJA,
             a.BAL_EA       AS MAESU,
             e.address        AS ADDRESS,
             e.comp_name   AS COMP_NAME,
             e.president_name  AS PRESIDENT_NAME,
             case when  a.CERT_KIND='1' then '위 사람은 상기와 같이 재직하고 있음을 증명합니다.' 
                                        else '위 사람은 상기의 경력이 틀림없음을 증명합니다.' end TEX_CONTS
    FROM insa_cert a inner join insa_mst  b on (a.COMP_ID = b.COMP_ID and a.emp_no    = b.emp_no)
                     inner join TC_COMP   e  on (a.COMP_ID = e.COMP_ID)
   where a.comp_id =  A_COMP_ID
     and a.BAL_DATE =   date_format(A_PASSPOST_DATE,'%Y%m%d')
     and a.BAL_NO   =  A_PASSPOST_NO ;
    
    
	SET N_RETURN = 0;
    SET V_RETURN = '조회되었습니다.';
end