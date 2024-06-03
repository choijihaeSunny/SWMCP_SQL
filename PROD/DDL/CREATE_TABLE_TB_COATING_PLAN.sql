-- swmcp.tb_coating_plan definition

CREATE TABLE `tb_coating_plan` (
  `COMP_ID` varchar(10) NOT NULL COMMENT '사업장코드',
  `MATR_LOT_NO` varchar(30) NOT NULL COMMENT '원자재 LOT NO',
  `SET_SEQ` varchar(2) NOT NULL COMMENT '순번',
  `PLAN_MST_KEY` varchar(50) NOT NULL COMMENT '계획 MST KEY (원자재 LOT NO + 순번)',
  `WORK_LINE` varchar(10) DEFAULT NULL COMMENT '생산라인',
  `ORDER_KEY` varchar(30) DEFAULT NULL COMMENT '주문번호',
  `MATR_CODE` varchar(30) NOT NULL COMMENT '원자재코드',
  `PROG_CODE` varchar(10) DEFAULT NULL COMMENT '공정',
  `PLAN_TOT_QTY` decimal(16,4) DEFAULT 0.0000 COMMENT '계획수량',
  `STOCK_QTY` decimal(16,4) DEFAULT 0.0000 COMMENT '재고수량',
  `DEPT_CODE` varchar(10) DEFAULT NULL COMMENT '생산부서코드',
  `WARE_CODE` bigint(20) DEFAULT NULL COMMENT '재고창고 (cfg.com.wh.kind)',
  `RMK` varchar(100) DEFAULT NULL COMMENT '비고',
  `SYS_EMP_NO` varchar(10) DEFAULT NULL,
  `SYS_ID` decimal(10,0) DEFAULT NULL,
  `SYS_DATE` timestamp NULL DEFAULT NULL,
  `UPD_EMP_NO` varchar(10) DEFAULT NULL,
  `UPD_ID` decimal(10,0) DEFAULT NULL,
  `UPD_DATE` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`COMP_ID`,`PLAN_MST_KEY`),
  UNIQUE KEY `tb_coating_plan_unique` (`COMP_ID`,`MATR_LOT_NO`,`SET_SEQ`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='원자재코팅계획관리';