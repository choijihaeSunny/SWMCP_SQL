-- swmcp.tb_tax_det definition

CREATE TABLE `tb_tax_det` (
  `COMP_ID` varchar(10) NOT NULL COMMENT '사업장코드',
  `TAX_NUMB` varchar(30) NOT NULL COMMENT '계산서번호 TX + 년월(4) + 순번(4)',
  `TAX_SEQ` varchar(3) NOT NULL COMMENT '계산서순번',
  `ACT_DATE` varchar(8) NOT NULL COMMENT '거래일자',
  `ITEM_CODE` varchar(30) DEFAULT NULL COMMENT '품목코드',
  `QTY` decimal(20,4) DEFAULT 0.0000 COMMENT '수량',
  `COST` decimal(20,4) DEFAULT 0.0000 COMMENT '단가',
  `SUPP_AMT` decimal(20,4) DEFAULT 0.0000 COMMENT '공급가액',
  `VAT` decimal(20,4) DEFAULT 0.0000 COMMENT '부가세',
  `CALL_KIND` varchar(10) DEFAULT NULL COMMENT '호출구분 REQ:출고내역, RTN:출고반품',
  `CALL_KEY` varchar(30) DEFAULT NULL COMMENT '호출 KEY',
  `DIFF_AMT` decimal(20,4) DEFAULT 0.0000 COMMENT '공급가액차이금액',
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
  PRIMARY KEY (`COMP_ID`,`TAX_NUMB`,`TAX_SEQ`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='세금계산서 DET';