-- swmcp.tb_coating_work_det definition

CREATE TABLE `tb_coating_work_det` (
  `COMP_ID` varchar(10) NOT NULL COMMENT '사업장코드',
  `WORK_LINE` varchar(10) DEFAULT NULL COMMENT '생산라인',
  `WORK_KEY` varchar(30) NOT NULL COMMENT '생산KEY (MC + 년월(4) + 순번(3) + NO(3))',
  `WORK_DATE` varchar(8) NOT NULL COMMENT '생산일자',
  `MATR_CODE` varchar(30) NOT NULL COMMENT '품목코드',
  `PROG_CODE` varchar(10) DEFAULT NULL COMMENT '공정코드',
  `LOT_NO` varchar(30) NOT NULL COMMENT '개별 LOT NO',
  `WORK_QTY` decimal(16,4) DEFAULT 0.0000 COMMENT '생산수량(불량수량포함)',
  `WORK_DEPT` varchar(10) DEFAULT NULL COMMENT '생산부서코드',
  `WARE_CODE` bigint(20) DEFAULT NULL COMMENT '재고창고 (cfg.com.wh.kind)',
  `RMK` varchar(100) DEFAULT NULL COMMENT '비고',
  `SYS_EMP_NO` varchar(10) DEFAULT NULL,
  `SYS_ID` decimal(10,0) DEFAULT NULL,
  `SYS_DATE` timestamp NULL DEFAULT NULL,
  `UPD_EMP_NO` varchar(10) DEFAULT NULL,
  `UPD_ID` decimal(10,0) DEFAULT NULL,
  `UPD_DATE` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`COMP_ID`,`WORK_KEY`,`LOT_NO`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='코팅생산실적관리det';