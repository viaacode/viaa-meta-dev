/*
A collection of Postgres SQL scripts
for checking on and analyzing tables and their indexes.
E.g. sizes, usage and uniqueness

These will give you an idea about table and index bloat
and how usefull your indexing efforts are.

Tested with pg version 11+
*/

-- Never been kissed before
-- Find unused indexes
SELECT
    indexrelid :: regclass AS index,
    relid :: regclass AS table
FROM
    pg_stat_user_indexes
    JOIN pg_index USING (indexrelid)
WHERE
    idx_scan = 0
    AND indisunique is false;

-- Same as above but including size in bytes
-- and n° scans (just to be sure)
SELECT
    indexrelid :: regclass AS index,
    relid :: regclass AS table,
    sum(pg_relation_size(indexrelid :: regclass)) :: bigint AS size,
    idx_scan AS scans
FROM
    pg_stat_user_indexes
    JOIN pg_index USING (indexrelid)
WHERE
    idx_scan = 0
    AND indisunique IS false
GROUP BY
    indexrelid,
    relid,
    idx_scan
ORDER BY
    size desc;

-- Find duplicate indexes
-- Look for true duplicate indexes: same table, same columns, same column order.
SELECT
    a.indrelid::regclass,
    a.indexrelid::regclass,
    b.indexrelid::regclass
FROM
    (SELECT *,array_to_string(indkey,' ') AS cols FROM pg_index) a
    JOIN (SELECT *,array_to_string(indkey,' ') AS cols FROM pg_index) b ON
        ( a.indrelid=b.indrelid AND a.indexrelid > b.indexrelid
        AND
            (
                (a.cols LIKE b.cols||'%' AND coalesce(substr(a.cols,length(b.cols)+1,1),' ')=' ')
                OR
                (b.cols LIKE a.cols||'%' AND coalesce(substr(b.cols,length(a.cols)+1,1),' ')=' ')
            )
        )
ORDER BY
    indrelid;

-- Find the top 20 biggest tables / toasts / indexes
SELECT
    nspname || '.' || relname AS "relation",
    pg_size_pretty(pg_relation_size(C.oid)) AS "size"
FROM
    pg_class C
    LEFT JOIN pg_namespace N ON (N.oid = C.relnamespace)
WHERE
    nspname NOT IN ('pg_catalog', 'information_schema')
ORDER BY
    pg_relation_size(C.oid) DESC
LIMIT
    20;

-- Find table / toast / index sizes for all tables in one or more schema's,
-- ordered by table / index size.
-- Use LIMIT to show only the biggliest.
SELECT
    *,
    Pg_size_pretty(total_bytes) AS total,
    Pg_size_pretty(index_bytes) AS INDEX,
    Pg_size_pretty(toast_bytes) AS toast,
    Pg_size_pretty(table_bytes) AS TABLE
FROM
    (
        SELECT
            *,
            total_bytes - index_bytes - Coalesce(toast_bytes, 0) AS table_bytes
        FROM
            (
                SELECT
                    c.oid,
                    nspname AS table_schema,
                    relname AS TABLE_NAME,
                    c.reltuples AS row_estimate,
                    Pg_total_relation_size(c.oid) AS total_bytes,
                    Pg_indexes_size(c.oid) AS index_bytes,
                    Pg_total_relation_size(reltoastrelid) AS toast_bytes
                FROM
                    pg_class c
                    LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
                WHERE
                    relkind = 'r'
            ) a
        WHERE
            table_schema IN ('shared', 'app')
            /* Choose the schema's you want stats for */
        ORDER BY
            total_bytes DESC
    ) a;

-- When did the cleaner came by?
SELECT
    relname,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM
    pg_stat_all_tables
WHERE
    schemaname IN ('shared', 'app')
    -- Don't forget to select the relevant schema's
ORDER BY
    last_vacuum DESC;

-- Find the fat lazy ones that are hogging your disk space
-- You get a complete list of all tables,
-- alphabetically ordered by schema / tablename
-- including: number of rows, indexes, sizes, uniqueness of the index
-- and usage (scans and tuples)
SELECT
    t.schemaname,
    t.tablename,
    indexname,
    c.reltuples AS num_rows,
    pg_size_pretty(
        pg_relation_size(
            quote_ident(t.schemaname) :: text || '.' || quote_ident(t.tablename) :: text
        )
    ) AS table_size,
    pg_size_pretty(
        pg_relation_size(
            quote_ident(t.schemaname) :: text || '.' || quote_ident(indexrelname) :: text
        )
    ) AS index_size,
    CASE WHEN indisunique THEN 'Y' ELSE 'N' END AS UNIQUE,
    number_of_scans,
    tuples_read,
    tuples_fetched
FROM
    pg_tables t
    LEFT OUTER JOIN pg_class c ON t.tablename = c.relname
    LEFT OUTER JOIN (
        SELECT
            c.relname AS ctablename,
            ipg.relname AS indexname,
            x.indnatts AS number_of_columns,
            idx_scan AS number_of_scans,
            idx_tup_read AS tuples_read,
            idx_tup_fetch AS tuples_fetched,
            indexrelname,
            indisunique,
            schemaname
        FROM
            pg_index x
            JOIN pg_class c ON c.oid = x.indrelid
            JOIN pg_class ipg ON ipg.oid = x.indexrelid
            JOIN pg_stat_all_indexes psai ON x.indexrelid = psai.indexrelid
    ) AS foo ON t.tablename = foo.ctablename
    AND t.schemaname = foo.schemaname
WHERE
    t.schemaname NOT IN ('pg_catalog', 'information_schema')
ORDER BY
    1,
    2;