variable "yc_service_account_key" {
  description = "API-ключ сервисного аккаунта Yandex Cloud"
  sensitive   = true
}

variable "yc_cloud_id" {
  description = "ID облака в Yandex Cloud"
}

variable "yc_folder_id" {
  description = "ID папки (каталога) в Yandex Cloud"
}

variable "yc_zone" {
  description = "Зона доступности"
  default     = "ru-central1-a"
}

variable "docker_image" {
  description = "Docker образ приложения"
  default     = "your_dockerhub_username/devops-hello:latest"
}

variable "db_password" {
  description = "Пароль для базы данных"
  sensitive   = true
  default     = "yc-DevOps-2024!"
}
