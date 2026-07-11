###############################################################################
# locals.tf (raiz) - Etiquetas de gobierno FinOps
###############################################################################
locals {
  name_prefix = "tecnohome"
  account_id  = data.aws_caller_identity.current.account_id

  common_tags = {
    Project       = "TecnoHome"
    Proyecto      = "TecnoHome-Infraestructura"
    Entorno       = var.entorno
    Responsable   = var.responsable
    CentroDeCosto = var.centro_de_costo
  }
}
