select * from tb_morder_req_mst
where SET_DATE < '20240808'
;

select * from TB_MORDER_REQ_DET
where MORDER_REQ_MST_KEY IN (
	select MORDER_REQ_MST_KEY from tb_morder_req_mst
	where SET_DATE < '20240808'
);

delete from TB_MORDER_REQ_DET
	where MORDER_REQ_MST_KEY IN (
	select MORDER_REQ_MST_KEY from tb_morder_req_mst
	where SET_DATE < '20240808'
);

delete from TB_MORDER_REQ_MST
where SET_DATE < '20240808'
;


insert into TB_MORDER_REQ_MST (
	COMP_ID
	,SET_DATE
	,SET_SEQ
	,SET_NO
	,MORDER_REQ_MST_KEY
	,MORDER_KIND
	,ORDER_DATE
	,ITEM_CODE
	,REQ_QTY
	,DELI_DATE
	,CUST_CODE
	,EMP_NO
	,DEPT_CODE
	,SHIP_INFO
	,PJ_NO
	,PJ_NAME
	,MORDER_QTY
	,ORDER_KEY
	,DET_SEQ
	,PRE_STOCK_KIND
	,END_YN
	,END_DATE
	,END_EMP_NO
	,RMK
	,SYS_ID
	,SYS_EMP_NO
	,SYS_DT
	,UPD_ID
	,UPD_EMP_NO
	,WARE_CODE
	,MORDER_GUBUN
) select
      '0001' as COMP_ID
      ,A.SET_DATE as SET_DATE
      ,LPAD(FN_GET_SEQ('tb_morder_req_mst', date_format(A.SET_DATE,'%y%m')), 4, '0') as SET_SEQ
      ,(select TRIM(LPAD(IFNULL(MAX(SET_NO),0) + 1, 4, '0'))
        from tb_morder_req_mst
        where COMP_ID = '0001'
          and SET_SEQ = A.MST_SEQ
          and MORDER_REQ_MST_KEY like 'PR%') as SET_NO -- !!
      ,CONCAT('PR', SUBSTR(A.SET_DATE, 3, 4), A.MST_SEQ, '0001',
      (select TRIM(LPAD(IFNULL(MAX(SET_NO),0) + 1, 4, '0'))
        from tb_morder_req_mst
        where COMP_ID = '0001'
          and SET_SEQ = A.MST_SEQ
          and MORDER_REQ_MST_KEY like 'PR%')
      ) as MORDER_REQ_MST_KEY -- !!
      ,151919 as MORDER_KIND
      ,A.SET_DATE as ORDER_DATE
      ,I.ITEM_CODE
      ,0 as REQ_QTY -- !
      ,A.SET_DATE as DELI_DATE
      ,C.CUST_CODE as CUST_CODE
      ,A.EMP_NO as EMP_NO
      ,A.DEPT_CODE as DEPT_CODE
      ,A.SHIP_NO as SHIP_INFO
      ,A.PROJECT_NO as PJ_NO
      ,A.PROJECT_NAME as PJ_NAME
      ,0 as MORDER_QTY --
      ,NULL as ORDER_KEY
      ,NULL as DET_SEQ
      ,NULL as PRE_STOCK_KIND
      ,'N' as END_YN
      ,NULL as END_DATE
      ,NULL as END_EMP_NO
      ,NULL as RMK
      ,105750 as SYS_ID -- !
      ,'202216' as SYS_EMP_NO -- !
      ,SYSDATE() as SYS_DT
      ,105750 as UPD_ID -- !
      ,'202216' as UPD_EMP_NO -- !
      ,NULL as WARE_CODE
      ,'1' as MORDER_GUBUN
from UPLOAD_MORDER_REQ_DET A
	inner join TB_ITEM_CODE I 
		on (A.ITEM_CODE = I.ITEM_CODE_PRE)
	inner join TC_CUST_CODE C
		on (A.CUST_CODE = C.OLD_CUST_CODE
		and C.COMP_ID = '0001')
;

select * from tb_morder_req_mst;
