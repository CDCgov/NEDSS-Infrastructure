locals {  
  service_account_name = "${var.resource_prefix}-fluentbit-svc-acc"
}

resource "helm_release" "fluentbit" {  
  name       = "fluentbit"
  repository = "https://fluent.github.io/helm-charts"
  chart      = "fluent-bit"
  version          = var.helm_version
  namespace  = var.namespace
  create_namespace = true
  wait = true

  set {
    name = "serviceAccount.create"
    value = true
  }

  set {
    name = "serviceAccount.name"
    value = local.service_account_name
  }

  values         = [
    <<-EOF
    ## https://docs.fluentbit.io/manual/administration/configuring-fluent-bit/classic-mode/configuration-file
    config:
      service: |
        [SERVICE]
            Daemon Off
            Flush {{ .Values.flush }}
            Log_Level {{ .Values.logLevel }}
            Parsers_File parsers.conf
            Parsers_File custom_parsers.conf
            HTTP_Server On
            HTTP_Listen 0.0.0.0
            HTTP_Port {{ .Values.metricsPort }}
            Health_Check On

      # ## https://docs.fluentbit.io/manual/pipeline/inputs
      inputs: |
        [INPUT]
            Name tail
            Path /var/log/containers/*.log
            multiline.parser docker, cri
            Tag kube.*
            Mem_Buf_Limit 5MB
            Skip_Long_Lines On

        [INPUT]
            Name systemd
            Tag host.*
            Systemd_Filter _SYSTEMD_UNIT=kubelet.service
            Read_From_Tail On


      # ## https://docs.fluentbit.io/manual/pipeline/filters
      filters: |
        [FILTER]
            Name kubernetes
            Match kube.*
            Merge_Log On
            Keep_Log Off
            K8S-Logging.Parser On
            K8S-Logging.Exclude On

      ## https://docs.fluentbit.io/manual/pipeline/outputs
      outputs: |

        [OUTPUT]
            name splunk 
            match *
            host ${var.splunk_hec_url} 
            splunk_send_raw on
            splunk_token ${var.splunk_auth_token} 
            tls on
        # [OUTPUT]        
        #     name                  azure_blob
        #     match                 *
        #     account_name          ${var.blob_account_name}
        #     shared_key            ${var.blob_shared_key}
        #     path                  kubernetes
        #     container_name        ${var.azure_container_name}
        #     auto_create_container on
        #     tls                   on
    EOF
  ]
} 

