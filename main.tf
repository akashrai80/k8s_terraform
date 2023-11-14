resource "kubernetes_namespace" "namespace1" {
    metadata {
      name = "terraform-ns"
    }
}
# output "name" {
#   value = kubernetes_namespace.namespace1.id
# }

resource "kubernetes_deployment" "deploy1" {
  metadata {
    name = "terraform-deployment"
    labels = {
      test = "MyExampleApp"
    }
    namespace = kubernetes_namespace.namespace1.id
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        test = "MyExampleApp"
      }
    }

    template {
      metadata {
        labels = {
          test = "MyExampleApp"
        }
      }

      spec {
        container {
          image = "nginx:1.21.6"
          name  = "example"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }
}

# output "labels" {
#   value = kubernetes_deployment.deploy1.spec.0.template.0.metadata.0.labels["test"]
# }

resource "kubernetes_service" "service1" {
  metadata {
    name = "terraform-service"
    namespace = kubernetes_namespace.namespace1.id
  }
  spec {
    selector = {
      test = kubernetes_deployment.deploy1.spec.0.template.0.metadata.0.labels["test"]
    }
    type = "NodePort"
    port {
      port = 80
      target_port = 80
      node_port = 30002
    }
  }
}