resource "null_resource" "exec" {
  triggers = {
    always_run = timestamp()
  }
  provisioner "local-exec" {
    command     = var.command
  }
  depends_on  = [var.localexec_depends_on]
}