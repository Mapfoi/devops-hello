#!/bin/bash

echo "🔍 Проверка настроек проекта..."

# Проверка наличия файлов
echo "📁 Проверка структуры проекта..."
for file in "app/app.py" "app/Dockerfile" "app/requirements.txt" "terraform/main.tf" "terraform/variables.tf" ".github/workflows/deploy.yml"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file not found"
    fi
done

# Проверка Terraform синтаксиса
echo ""
echo "🔧 Проверка Terraform конфигурации..."
cd terraform
terraform fmt -check > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "  ✅ Terraform форматирование корректно"
else
    echo "  ⚠️  Terraform требует форматирования"
    terraform fmt
fi

# Проверка Dockerfile
echo ""
echo "🐳 Проверка Dockerfile..."
cd ../app
docker build -t test-build . > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "  ✅ Dockerfile корректный"
    docker rmi test-build > /dev/null 2>&1
else
    echo "  ❌ Ошибка в Dockerfile"
fi

echo ""
echo "✅ Проверка завершена!"
echo ""
echo "📝 Не забудьте настроить GitHub Secrets:"
echo "  - YC_TOKEN (OAuth токен Yandex Cloud)"
echo "  - YC_CLOUD_ID (ID облака)"
echo "  - YC_FOLDER_ID (ID каталога)"
echo "  - DOCKER_USERNAME (логин Docker Hub)"
echo "  - DOCKER_TOKEN (токен доступа Docker Hub)"
echo "  - DB_PASSWORD (пароль для БД)"
