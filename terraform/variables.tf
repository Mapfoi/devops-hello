variable "yc_service_account_key_file" {
  description = "Путь к JSON-файлу с ключом сервисного аккаунта Yandex Cloud"
  type        = string
}


variable "yc_cloud_id" {
  description = "ID облака Yandex Cloud"
  type        = string
}


variable "yc_folder_id" {
  description = "ID каталога Yandex Cloud"
  type        = string
}


variable "yc_zone" {
  description = "Зона доступности"
  type        = string
  default     = "ru-central1-a"
}


variable "docker_image" {
  description = "Docker образ приложения"
  type        = string
  default     = ""
}


variable "db_password" {
  description = "Пароль PostgreSQL"
  type        = string
  sensitive   = true
}


variable "ssh_public_key" {
  description = "Публичный SSH ключ пользователя ubuntu"
  type        = string
}