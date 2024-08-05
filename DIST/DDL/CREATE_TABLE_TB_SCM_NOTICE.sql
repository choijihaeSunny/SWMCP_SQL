-- swmcp.tb_scm_notice definition

CREATE TABLE `tb_scm_notice` (
  `COMP_ID` varchar(10) NOT NULL COMMENT '사업장코드',
  `SET_DATE` varchar(8) NOT NULL COMMENT '등록일자',
  `SET_SEQ` varchar(4) NOT NULL COMMENT '등록순번',
  `NOTICE_MST_KEY` varchar(30) NOT NULL COMMENT '공지KEY NO + 연월일(YYYYMMDD) + 순번(3)',
  `NOTICE_GUBN` varchar(3) NOT NULL COMMENT '공지구분 공지완료 : C  공지중 : P   SP_GET_USE_CODE SCM_NOTICE',
  `NOTICE_TITLE` varchar(50) NOT NULL COMMENT '공지제목',
  `NOTICE_COMMENT` varchar(500) NOT NULL COMMENT '공지내용',
  `NOTICE_EMP_NO` varchar(10) NOT NULL COMMENT '공지담당사원',
  `SYS_ID` decimal(10,0) NOT NULL COMMENT '생성ID',
  `SYS_EMP_NO` varchar(10) NOT NULL COMMENT '생성사원',
  `SYS_DT` timestamp NULL DEFAULT current_timestamp() COMMENT '생성일시',
  `UPD_ID` decimal(10,0) NOT NULL COMMENT '수정ID',
  `UPD_EMP_NO` varchar(10) NOT NULL COMMENT '수정사원',
  `UPD_DT` timestamp NULL DEFAULT current_timestamp() COMMENT '수정일시',
  PRIMARY KEY (`COMP_ID`,`NOTICE_MST_KEY`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='SCM공지등록';