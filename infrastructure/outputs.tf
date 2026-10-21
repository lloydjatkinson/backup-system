output "repositories" {
  description = "Per-machine restic repositories and credentials."
  sensitive   = true
  value       = local.repositories
}