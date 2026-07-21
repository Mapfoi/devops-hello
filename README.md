# DevOps-проект: автоматизированное развертывание Flask-приложения в Yandex Cloud

## 📌 Описание проекта
Разработал и внедрил полноценный CI/CD-пайплайн для веб-приложения на Python (Flask) с PostgreSQL в облаке Yandex Cloud. Инфраструктура описана как код (Terraform), развертывание автоматизировано через GitHub Actions, мониторинг — Prometheus + Grafana. 

## 🛠 Использованные технологии

| Категория | Технологии |
|-----------|------------|
| **Инфраструктура как код** | Terraform, Yandex Cloud Provider, Managed PostgreSQL, Compute Cloud, VPC, Cloud-Init |
| **CI/CD** | GitHub Actions, Docker Hub, SSH Deployment |
| **Контейнеризация** | Docker, Docker Compose |
| **Backend** | Python, Flask, Gunicorn, psycopg2 |
| **База данных** | PostgreSQL (Managed Service) |
| **Мониторинг** | Prometheus, Grafana, prometheus-flask-exporter |

## 🧩 Что реализовано

### Автоматическое создание инфраструктуры (IaC)
Terraform автоматически создаёт (или использует существующие):
- VPC и подсети
- Managed PostgreSQL Cluster (с пользователем и базой данных)
- Две виртуальные машины: для приложения и для мониторинга

### CI/CD пайплайн (GitHub Actions)
При каждом push в ветку `main`:
1. Сборка Docker-образа приложения.
2. Публикация образа в Docker Hub.
3. Применение изменений инфраструктуры через Terraform (создание/обновление ресурсов).
4. Ожидание готовности VM и установка Docker (если отсутствует).
5. Деплой контейнера приложения и обновление стека мониторинга.

### Самоинициализация базы данных
При запуске Flask-приложение автоматически:
- Подключается к PostgreSQL.
- Создаёт таблицу
