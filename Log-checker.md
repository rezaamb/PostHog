1) حجم لاگ‌های مهم در system
```bash
docker exec -it root-clickhouse-1 clickhouse-client --query "
SELECT table, formatReadableSize(sum(bytes)) AS size
FROM system.parts
WHERE database = 'system'
  AND table IN ('text_log','query_log','query_views_log','metric_log','asynchronous_metric_log','session_log')
GROUP BY table
ORDER BY sum(bytes) DESC;"
```

2) حجم + مسیر پارت‌ها (برای ربط‌دادن به فایل‌سیستم)
```bash
docker exec -it root-clickhouse-1 clickhouse-client --query "
SELECT table,
       formatReadableSize(sum(bytes)) AS size,
       any(path) AS any_part_path
FROM system.parts
WHERE database = 'system'
  AND table IN ('text_log','query_log','query_views_log','metric_log','asynchronous_metric_log')
GROUP BY table
ORDER BY sum(bytes) DESC;"
```
3) شمارش ردیف‌های هر جدول لاگ
```bash
docker exec -it root-clickhouse-1 clickhouse-client --query "
SELECT table, formatReadableQuantity(sum(rows)) AS rows
FROM system.parts
WHERE database = 'system'
  AND table IN ('text_log','query_log','query_views_log','metric_log','asynchronous_metric_log','session_log')
GROUP BY table
ORDER BY sum(rows) DESC;"
```
نکته: اگر خواستید همهٔ جدول‌های دیتابیس system را ببینید (نه فقط لاگ‌ها):
```bash
docker exec -it root-clickhouse-1 clickhouse-client --query "
SELECT table, formatReadableSize(sum(bytes)) AS size
FROM system.parts
WHERE database = 'system'
GROUP BY table
ORDER BY sum(bytes) DESC;"
```
