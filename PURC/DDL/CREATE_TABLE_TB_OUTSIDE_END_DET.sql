-- swmcp.tb_outside_end_det definition

CREATE TABLE `tb_outside_end_det` (
  `COMP_ID` varchar(10) NOT NULL COMMENT '사업장코드',
  `OUTSIDE_END_KEY` varchar(30) NOT NULL COMMENT '외주가공비마감 MST KEY',
  `DET_SEQ` varchar(4) NOT NULL COMMENT '순번',
  `ACT_DATE` varchar(8) NOT NULL COMMENT '거래일자',
  `ITEM_CODE` varchar(30) DEFAULT NULL COMMENT '품목코드',
  `QTY` decimal(20,4) DEFAULT 0.0000 COMMENT '수량',
  `COST` decimal(20,4) DEFAULT 0.0000 COMMENT '단가',
  `SUPP_AMT` decimal(20,4) DEFAULT 0.0000 COMMENT '공급가액',
  `VAT` decimal(20,4) DEFAULT 0.0000 COMMENT '부가세',
  `CALL_KIND` varchar(10) DEFAULT NULL COMMENT '호출구분 (외주가공입고, 외주가공재고반품, 외주가공재고반품입고)',
  `CALL_KEY` varchar(30) DEFAULT NULL COMMENT '호출KEY',
  `RMKS` varchar(100) DEFAULT NULL COMMENT '특이사항',
  `TEMP1` varchar(10) DEFAULT NULL COMMENT '임시01',
  `TEMP2` varchar(10) DEFAULT NULL COMMENT '임시02',
  `TEMP3` varchar(10) DEFAULT NULL COMMENT '임시03',
  `TEMP4` varchar(10) DEFAULT NULL COMMENT '임시04',
  `TEMP5` varchar(10) DEFAULT NULL COMMENT '임시05',
  `SYS_ID` decimal(10,0) NOT NULL COMMENT '생성ID',
  `SYS_EMP_NO` varchar(10) NOT NULL COMMENT '생성사원',
  `SYS_DATE` timestamp NULL DEFAULT current_timestamp() COMMENT '생성일시',
  `UPD_ID` decimal(10,0) NOT NULL COMMENT '수정ID',
  `UPD_EMP_NO` varchar(10) NOT NULL COMMENT '수정사원',
  `UPD_DATE` timestamp NULL DEFAULT current_timestamp() COMMENT '수정일시',
  PRIMARY KEY (`COMP_ID`,`OUTSIDE_END_KEY`,`DET_SEQ`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='구매외주가공비마감DET';