-- swmcp.tb_io_end definition

CREATE TABLE `tb_io_end` (
  `COMP_ID` varchar(10) NOT NULL COMMENT '사업장코드',
  `YYMM` varchar(6) NOT NULL COMMENT '마감년월',
  `WARE_CODE` bigint(20) NOT NULL COMMENT '창고코드(cfg.com.wh.kind)',
  `ITEM_CODE` varchar(30) NOT NULL COMMENT '품목코드',
  `LOT_NO` varchar(30) NOT NULL COMMENT 'LOT NO',
  `PRE_QTY` decimal(16,4) DEFAULT 0.0000 COMMENT '기초수량',
  `PRE_AMT` decimal(16,4) DEFAULT 0.0000 COMMENT '기초금액',
  `IN_QTY` decimal(16,4) DEFAULT 0.0000 COMMENT '입고수량',
  `IN_AMT` decimal(16,4) DEFAULT 0.0000 COMMENT '입고금액',
  `OUT_QTY` decimal(16,4) DEFAULT 0.0000 COMMENT '출고수량',
  `OUT_AMT` decimal(16,4) DEFAULT 0.0000 COMMENT '출고금액',
  `NEXT_QTY` decimal(16,4) DEFAULT 0.0000 COMMENT '이월수량',
  `NEXT_AMT` decimal(16,4) DEFAULT 0.0000 COMMENT '이월금액',
  `TEMP1` varchar(10) DEFAULT NULL,
  `TEMP2` varchar(10) DEFAULT NULL,
  `TEMP3` varchar(10) DEFAULT NULL,
  `SYS_EMP_NO` varchar(10) DEFAULT NULL COMMENT '등록사번',
  `SYS_ID` decimal(10,0) DEFAULT NULL COMMENT '등록ID',
  `SYS_DT` timestamp NULL DEFAULT NULL COMMENT '등록일자',
  `UPD_EMP_NO` varchar(10) DEFAULT NULL,
  `UPD_ID` decimal(10,0) DEFAULT NULL,
  `UPD_DT` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`COMP_ID`,`YYMM`,`WARE_CODE`,`ITEM_CODE`,`LOT_NO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='수불마감';