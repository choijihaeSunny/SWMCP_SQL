-- swmcp.tb_coating_plan_det definition

CREATE TABLE `tb_coating_plan_det` (
  `COMP_ID` varchar(10) NOT NULL COMMENT '사업장코드',
  `MATR_LOT_NO` varchar(30) NOT NULL COMMENT '원자재 LOT NO',
  `SET_SEQ` varchar(2) NOT NULL COMMENT '순번',
  `PLAN_DATE` varchar(8) NOT NULL COMMENT '계획일자',
  `PLAN_MST_KEY` varchar(50) NOT NULL COMMENT '계획 MST KEY (원자재LOT NO + 생산라인 + 순번(2))',
  `WORK_PLAN_KEY` varchar(50) NOT NULL COMMENT '생산계획 KEY (계획MST KEY + 계획일자)',
  `WORK_LINE` varchar(10) DEFAULT NULL COMMENT '생산라인',
  `MATR_CODE` varchar(30) NOT NULL COMMENT '원자재코드',
  `PROG_CODE` varchar(10) DEFAULT NULL COMMENT '공정',
  `PLAN_QTY` decimal(16,4) DEFAULT 0.0000 COMMENT '계획수량',
  `DEPT_CODE` varchar(10) DEFAULT NULL COMMENT '생산부서코드',
  `CONFIRM_YN` varchar(10) DEFAULT 'N' COMMENT '계획확정구분(Y/N)',
  `WORK_QTY` decimal(16,4) DEFAULT 0.0000 COMMENT '생산수량',
  `END_YN` varchar(10) DEFAULT 'N' COMMENT '계획마감(Y/N)',
  `RMK` varchar(100) DEFAULT NULL COMMENT '비고',
  `SYS_EMP_NO` varchar(10) DEFAULT NULL,
  `SYS_ID` decimal(10,0) DEFAULT NULL,
  `SYS_DATE` timestamp NULL DEFAULT NULL,
  `UPD_EMP_NO` varchar(10) DEFAULT NULL,
  `UPD_ID` decimal(10,0) DEFAULT NULL,
  `UPD_DATE` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`COMP_ID`,`WORK_PLAN_KEY`),
  UNIQUE KEY `tb_coating_plan_det_unique` (`COMP_ID`,`MATR_LOT_NO`,`SET_SEQ`,`PLAN_DATE`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='원자재코팅계획관리Detail';