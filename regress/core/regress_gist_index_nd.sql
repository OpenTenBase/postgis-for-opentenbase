
CREATE OR REPLACE FUNCTION qnodes(q text) RETURNS text
LANGUAGE 'plpgsql' AS
$$
DECLARE
  exp TEXT;
  mat TEXT[];
  ret TEXT;
BEGIN
  FOR exp IN EXECUTE 'EXPLAIN ' || q
  LOOP
    --RAISE NOTICE 'EXP: %', exp;
    mat := regexp_matches(exp, ' *(?:-> *)?(.*Scan)');
    --RAISE NOTICE 'MAT: %', mat;
    IF mat IS NOT NULL THEN
      ret := mat[1];
    END IF;
    --RAISE NOTICE 'RET: %', ret;
  END LOOP;
  RETURN ret;
END;
$$;

-------------------------------------------------------------------------------

create table tbl_geomcollection_nd (
	k serial,
	g geometry
);

\copy tbl_geomcollection_nd from 'regress_gist_index_nd.data';
-- \copy tbl_geomcollection_nd from  '/data/home/kbzhang/OpenTenBase/contrib/postgis-for-opentenbase/regress/core/regress_gist_index_nd.data'

create table test_gist_idx_nd(
	op char(3),
	noidx bigint,
	noidxscan varchar(32),
	gistidx bigint,
	gidxscan varchar(32));

-------------------------------------------------------------------------------
-- No index scan

set enable_indexscan = off;
set enable_bitmapscan = off;
set enable_seqscan = on;

-- alter function qnodes pushdown;
-- insert into test_gist_idx_nd(op, noidx, noidxscan)
-- select '&&&', count(*), qnodes('select count(*) from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g &&& t2.g') from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g &&& t2.g;
-- insert into test_gist_idx_nd(op, noidx, noidxscan)
-- select '~~', count(*), qnodes('select count(*) from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g ~~ t2.g') from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g ~~ t2.g;
-- insert into test_gist_idx_nd(op, noidx, noidxscan)
-- select '@@', count(*), qnodes('select count(*) from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g @@ t2.g') from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g @@ t2.g;
-- insert into test_gist_idx_nd(op, noidx, noidxscan)
-- select '~~=', count(*), qnodes('select count(*) from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g ~~= t2.g') from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g ~~= t2.g;

CREATE TEMPORARY TABLE temp_data(
	op char(3),
	noidx bigint,
	noidxscan varchar(32),
	gistidx bigint,
	gidxscan varchar(32));
-- 下推执行qnodes函数，并将结果存储在临时表中
alter function qnodes pushdown;
insert into temp_data(op, noidx, noidxscan)
select '&&&', count(*), qnodes('select count(*) from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g &&& t2.g') from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g &&& t2.g;
insert into temp_data(op, noidx, noidxscan)
select '~~', count(*), qnodes('select count(*) from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g ~~ t2.g') from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g ~~ t2.g;
insert into temp_data(op, noidx, noidxscan)
select '@@', count(*), qnodes('select count(*) from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g @@ t2.g') from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g @@ t2.g;
insert into temp_data(op, noidx, noidxscan)
select '~~=', count(*), qnodes('select count(*) from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g ~~= t2.g') from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g ~~= t2.g;
alter function qnodes NOT pushdown;
------------------------------------------------------------------------------

create index tbl_geomcollection_nd_gist_nd_idx on tbl_geomcollection_nd using gist(g gist_geometry_ops_nd);

set enable_indexscan = on;
set enable_bitmapscan = off;
set enable_seqscan = off;

-- update test_gist_idx_nd
-- set gistidx = ( select count(*) from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g &&& t2.g ),
-- gidxscan = qnodes(' select count(*) from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g &&& t2.g ')
-- where op = '&&&';
-- update test_gist_idx_nd
-- set gistidx = ( select count(*) from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g ~~ t2.g ),
-- gidxscan = qnodes(' select count(*) from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g ~~ t2.g ')
-- where op = '~~';
-- update test_gist_idx_nd
-- set gistidx = ( select count(*) from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g @@ t2.g ),
-- gidxscan = qnodes(' select count(*) from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g @@ t2.g ')
-- where op = '@@';
-- update test_gist_idx_nd
-- set gistidx = ( select count(*) from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g ~~= t2.g ),
-- gidxscan = qnodes(' select count(*) from tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 where t1.g ~~= t2.g ')
-- where op = '~~=';


-- 更新test_gist_idx_nd表，使用临时表中的结果

alter function qnodes pushdown;


insert into test_gist_idx_nd(op, noidx, noidxscan, gistidx, gidxscan)
SELECT t1.op,t1.noidx, t1.noidxscan, t2.gistidx, t3.gidxscan 
FROM temp_data t1,( SELECT count(*) AS gistidx FROM tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 WHERE t1.g &&& t2.g)t2 , (SELECT qnodes('SELECT count(*) FROM tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 WHERE t1.g &&& t2.g') AS gidxscan)t3 
where t1.op = '&&&';

insert into test_gist_idx_nd(op, noidx, noidxscan, gistidx, gidxscan)
SELECT t1.op,t1.noidx, t1.noidxscan, t2.gistidx, t3.gidxscan 
FROM temp_data t1,( SELECT count(*) AS gistidx FROM tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 WHERE t1.g ~~ t2.g)t2 , (SELECT qnodes('SELECT count(*) FROM tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 WHERE t1.g ~~ t2.g') AS gidxscan)t3 
where t1.op = '~~';

insert into test_gist_idx_nd(op, noidx, noidxscan, gistidx, gidxscan)
SELECT t1.op,t1.noidx, t1.noidxscan, t2.gistidx, t3.gidxscan 
FROM temp_data t1,( SELECT count(*) AS gistidx FROM tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 WHERE t1.g @@ t2.g)t2 , (SELECT qnodes('SELECT count(*) FROM tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 WHERE t1.g @@ t2.g') AS gidxscan)t3 
where t1.op = '@@';

insert into test_gist_idx_nd(op, noidx, noidxscan, gistidx, gidxscan)
SELECT t1.op,t1.noidx, t1.noidxscan, t2.gistidx, t3.gidxscan 
FROM temp_data t1,( SELECT count(*) AS gistidx FROM tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 WHERE t1.g ~~= t2.g)t2 , (SELECT qnodes('SELECT count(*) FROM tbl_geomcollection_nd t1, tbl_geomcollection_nd t2 WHERE t1.g ~~= t2.g') AS gidxscan)t3 
where t1.op = '~~=';


DROP TABLE temp_data;
-------------------------------------------------------------------------------

select * from test_gist_idx_nd ORDER BY op;

-------------------------------------------------------------------------------

DROP TABLE tbl_geomcollection_nd CASCADE;
DROP TABLE test_gist_idx_nd CASCADE;
DROP FUNCTION qnodes (text);
