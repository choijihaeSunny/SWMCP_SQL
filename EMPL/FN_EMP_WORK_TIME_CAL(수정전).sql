CREATE DEFINER=`ubidom`@`%` FUNCTION `swmcp`.`FN_EMP_WORK_TIME_CAL`(	

	 V_COMP_ID   VARCHAR(20),

	 V_GUBN      CHAR(1),

   	 V_ST_TIME    DATETIME,

     V_END_TIME   DATETIME,

     V_RST_TIME   DATETIME,

     V_REND_TIME  DATETIME

) RETURNS decimal(10,2)
begin

	DECLARE V_CAL_ITME DECIMAL(10,2);

    DECLARE V_CAL_YEAR1 DECIMAL(10,2);

    DECLARE V_CAL_YEAR2 DECIMAL(10,2);

    DECLARE V_M_ST_TIME   DATETIME;

    DECLARE V_CAL_DATE  VARCHAR(8);

    DECLARE V_BASE_DATE  VARCHAR(8);

  

    set V_CAL_ITME = 0;

    set V_M_ST_TIME = ADDTIME(V_ST_TIME,'08:00:00');

    

    

    

    

    if V_GUBN = 'A' then 

       

       if V_RST_TIME <= V_ST_TIME  and V_REND_TIME >= V_END_TIME then 

       	   set V_CAL_ITME = 8;

       END if;

       

       if V_RST_TIME <= V_ST_TIME  and V_REND_TIME < V_END_TIME then 

       	   set V_CAL_ITME = ifnull(hour(timediff(time_format('080000', '%H:%i:%s'), timediff(V_END_TIME, V_REND_TIME ))),0);

       END if;

       

       if V_RST_TIME > V_ST_TIME  and V_REND_TIME >= V_END_TIME then 

           set V_CAL_ITME =  ifnull(hour(timediff(time_format('080000', '%H:%i:%s'), timediff(V_RST_TIME, V_ST_TIME ))),0);

           

       END if;

       

       if V_RST_TIME > V_ST_TIME  and V_REND_TIME < V_END_TIME then 

       	   set V_CAL_ITME =  ifnull(hour(timediff(time_format('080000', '%H:%i:%s'), timediff(V_RST_TIME, V_ST_TIME ))),0) + ifnull(hour(timediff(time_format('080000', '%H:%i:%s'), timediff(V_END_TIME, V_REND_TIME ))),0);

       END if;

    end if;

   

    if V_GUBN = 'B' then 

       

       if V_REND_TIME >= V_END_TIME then 

       	   set V_CAL_ITME =  hour(IFNULL(timediff(V_M_ST_TIME, V_REND_TIME ),0));

       END if;

    end if;

   

    if V_GUBN = 'C' and  V_REND_TIME > V_ST_TIME then 

       

       if V_RST_TIME <= V_ST_TIME  and V_REND_TIME >= V_END_TIME then 

           

       	   set V_CAL_ITME = 8;

       END if;

       

       if V_RST_TIME <= V_ST_TIME  and V_REND_TIME < V_END_TIME then 

           

       	   set V_CAL_ITME = ifnull(hour(timediff(time_format('080000', '%H:%i:%s'), timediff(V_END_TIME, V_REND_TIME ))),0);

       END if;

       

       if V_RST_TIME > V_ST_TIME  and V_REND_TIME >= V_END_TIME then 

           

       	   set V_CAL_ITME = ifnull(hour(timediff(time_format('080000', '%H:%i:%s'), timediff(V_RST_TIME, V_ST_TIME ))),0);

           

       END if;

       

       if V_RST_TIME > V_ST_TIME  and V_REND_TIME < V_END_TIME then 

           

       	   set V_CAL_ITME =  ifnull(hour(timediff(time_format('080000', '%H:%i:%s'), timediff(V_RST_TIME, V_ST_TIME ))),0) + ifnull(hour(timediff(time_format('080000', '%H:%i:%s'), timediff(V_END_TIME, V_REND_TIME ))),0);

       END if;

    end if;

   

    RETURN V_CAL_ITME;

END