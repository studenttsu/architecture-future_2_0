# Обоснование инфраструктуры

## Соответствие диаграмме и Terraform

 В `main.tf` описаны:

| Узел на диаграмме | Ресурс Terraform |
|-------------------|------------------|
| VPC | `yandex_vpc_network` |
| Публичная подсеть 10.10.1.0/24 | `yandex_vpc_subnet.public` |
| Сервисный аккаунт хранилища | `yandex_iam_service_account` |
| Роль SA на каталог (доступ к Object Storage) | `yandex_resourcemanager_folder_iam_member` |
| Уникальный суффикс имени бакета | `random_id` |
| ВМ доменов и платформы | `yandex_compute_instance.workload` (ключи: `med-services`, `fin-services`, `ai-services`, `portal-services`, `airflow-vm`, `kafka-broker`) |

> **Примечание:** NAT Gateway, Security Group, Object Storage bucket и отдельный Compute Disk описаны в целевой архитектуре, но недоступны в учебном каталоге Практикума (PermissionDenied). В production-каталоге с ролью `editor` эти ресурсы восстанавливаются без изменения логики конфигурации.

Узлы **(Manual)** на диаграмме (PostgreSQL как ПО, Kafka/Airflow как процессы на ВМ, Dremio/DataHub/Web, клинические и финтех-приложения, легаси-DWH, интеграция Camel) **не** дублируются в Terraform: их разворачивают команды доменов/платформы поверх выданных ВМ или вне облака, согласно [Task1](../Task1/)–[Task3](../Task3/).

## Выбор ресурсов

| Ресурс | Параметры по умолчанию | Зачем |
|--------|------------------------|--------|
| ВМ (`yandex_compute_instance`) | `standard-v3`, 2 vCPU, 4 ГБ RAM, `core_fraction = 20` | Пилотный каркас под установку стеков доменов и платформы; дробь ядра снижает тариф при низкой утилизации. |
| Прерываемые ВМ | `enable_preemptible = true` | Экономия на лаборатории; для продакшена — `false` в `terraform.tfvars`. |
| Загрузочный диск | 20 ГБ, `network-hdd` | Достаточно для Ubuntu 22.04 и базовых пакетов. |
| Образ | `ubuntu-2204-lts` | Предсказуемая LTS-платформа. |
| Сеть | одна VPC, публичная подсеть | Все ВМ пилота в одной подсети; в production разбивается на публичную (bastion/ALB) и приватную (данные). |
| SA + `storage.editor` на каталог | сервисный аккаунт для приложений к бакету | Ключи SA создаются **вручную** или через отдельный безопасный пайплайн — не хранятся в state. |