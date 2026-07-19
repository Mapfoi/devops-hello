#!/bin/bash

echo "🔍 Проверка настроек проекта..."

echo "📁 Проверка структуры проекта..."
for file in "app/app.py" "app/Dockerfile" "app/requirements.txt" "terraform/main.tf" "terraform/variables.tf" ".github/workflows/deploy.yml"; do
    if [ -f "$file" ]; then
        echo "  ✅ $file"
    else
        echo "  ❌ $file not found"
    fi
done

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
