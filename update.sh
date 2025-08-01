#!/bin/bash
cd /opt/supabase-project

echo "Создается резервная копия перед обновлением"
docker exec supabase-db pg_dump -U postgres -d postgres > backup_$(date +%F_%H-%M).sql

echo "Останавливается работа Supabase"
docker compose down

echo "Обновление образов"
docker compose pull

echo "Выполняем запуск Supabase"
docker compose up -d

echo "Поздравляю. Supabase обновлена!"
