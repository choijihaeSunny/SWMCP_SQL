-- swmcp.vew_sales_coll_det source

create or replace
algorithm = UNDEFINED view `swmcp`.`vew_sales_coll_det` as
select
    `z`.`KIND` as `KIND`,
    `z`.`COMP_ID` as `COMP_ID`,
    `z`.`SET_DATE` as `SET_DATE`,
    `z`.`CUST_CODE` as `CUST_CODE`,
    `z`.`SALES_KIND` as `SALES_KIND`,
    `z`.`ITEM_CODE` as `ITEM_CODE`,
    `z`.`QTY` as `QTY`,
    `z`.`SALE_AMT` as `SALE_AMT`,
    `z`.`COLL_AMT` as `COLL_AMT`
from
    (
    select
        'TAX' as `KIND`,
        `a`.`COMP_ID` as `COMP_ID`,
        `a`.`SET_DATE` as `SET_DATE`,
        `a`.`CUST_CODE` as `CUST_CODE`,
        `a`.`SALES_KIND` as `SALES_KIND`,
        '' as `ITEM_CODE`,
        0 as `QTY`,
        `a`.`VAT` as `SALE_AMT`,
        0 as `COLL_AMT`
    from
        `swmcp`.`tb_tax_mst` `a`
union all
    select
        'COLL' as `KIND`,
        `a`.`COMP_ID` as `COMP_ID`,
        `a`.`SET_DATE` as `SET_DATE`,
        `a`.`CUST_CODE` as `CUST_CODE`,
        `a`.`SALES_KIND` as `SALES_KIND`,
        '' as `ITEM_CODE`,
        0 as `QTY`,
        0 as `SALE_AMT`,
        case
            when (
            select
                `sys`.`CODE`
            from
                `swmcp`.`sys_data` `sys`
            where
                `sys`.`DATA_ID` = `a`.`COLL_KIND`) = 2 then `a`.`COLL_AMT` * -1
            else `a`.`COLL_AMT`
        end as `COLL_AMT`
    from
        `swmcp`.`tb_coll_bill` `a`) `z`;