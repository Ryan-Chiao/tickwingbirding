-- Tickwing 本地开发数据库初始化脚本
-- 由 docker-entrypoint-initdb.d 在容器首次启动时自动执行

-- 设置时区
SET timezone = 'UTC';

-- 创建数据库（若不存在）
-- 注意：POSTGRES_DB 环境变量已在 docker-compose.yml 中设置为 tickwing_dev
-- 此脚本主要用于补充初始化操作

-- 创建 pg_uuid 扩展（UUID 生成）
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- 创建 pg_trgm 扩展（模糊搜索）
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- 输出确认信息
DO $$
BEGIN
  RAISE NOTICE 'Tickwing database initialized: tickwing_dev';
END $$;
