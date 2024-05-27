-- swmcp.tb_input_discount definition

CREATE TABLE `tb_input_discount` (
  `COMP_ID` varchar(10) NOT NULL COMMENT '사업장코드',
  `SET_DATE` varchar(8) NOT NULL COMMENT '등록일자',
  `CUST_CODE` varchar(10) NOT NULL COMMENT '거래처',
  `INPUT_AMT` decimal(16,4) DEFAULT 0.0000 COMMENT '총입고금액',
  `DS_RATE` decimal(16,4) DEFAULT 0.0000 COMMENT '할인비율(%)',
  `DS_AMT` decimal(16,4) DEFAULT 0.0000 COMMENT '할인금액',
  `DS_CAUSE` varchar(50) DEFAULT NULL COMMENT '할인사유',
  `DS_INPUT_FROM` varchar(8) DEFAULT NULL COMMENT '할인입고기간FROM',
  `DS_INPUT_TO` varchar(8) DEFAULT NULL COMMENT '할인입고기간TO',
  `END_AMT` decimal(16,4) DEFAULT 0.0000 COMMENT '마감금액',
  `RMK` varchar(100) DEFAULT NULL COMMENT '비고',
  `TEMP1` varchar(10) DEFAULT NULL COMMENT '임시01',
  `TEMP2` varchar(10) DEFAULT NULL COMMENT '임시02',
  `TEMP3` varchar(10) DEFAULT NULL COMMENT '임시03',
  `TEMP4` varchar(10) DEFAULT NULL COMMENT '임시04',
  `TEMP5` varchar(10) DEFAULT NULL COMMENT '임시05',
  `SYS_EMP_NO` varchar(10) NOT NULL COMMENT '등록사번',
  `SYS_ID` varchar(30) NOT NULL COMMENT '등록ID',
  `SYS_DATE` timestamp NULL DEFAULT current_timestamp() COMMENT '등록일자',
  `UPD_EMP_NO` varchar(10) DEFAULT NULL COMMENT '수정사번',
  `UPD_ID` varchar(30) DEFAULT NULL COMMENT '수정ID',
  `UPD_DATE` timestamp NULL DEFAULT current_timestamp() COMMENT '수정일자',
  PRIMARY KEY (`COMP_ID`,`SET_DATE`,`CUST_CODE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='금형구매의뢰';