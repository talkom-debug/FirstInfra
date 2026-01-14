
env                                   = "#{env_prefix}#"
project                               = "meitarim"
workload_number                       = "944804414148"
shared_network_account_number         = "962999615719"
application_services_account_number   = "231634754053"
shared_db_account_number              = "767828748445"
vpce_sg_ingress_addtional_cidr_blocks = ["172.16.0.0/24"]
alb_sg_ingress_allow_cidrs = ["10.23.100.0/24","10.23.101.0/24","10.23.102.0/24","10.23.103.0/24","10.23.230.18/32"]

api_prefix = "#{api_prefix}#"
cognito_callback_urls = ["https://permissionregistration.#{env_prefix}#.molsa.gov.il/"]
workloads = {
  "meitarim" = {
    domain        = "meitarim.#{env_prefix}#.molsa.gov.il"
    create_bucket = true
    create_apigw = true
    ecs = {
      container_port                 = 8080
      container_name                 = "meitarim"
      image                          = "#{molsa_ecr_repository}#/#{env_prefix}#-repo:meitarim-server"
      cpu                            = 256
      memory                         = 512
      health_check_path              = "/#{api_prefix}#/Utilities/health-check"
      container_essential            = true
      desired_count                  = 1
      cw_log_group_retention_in_days = 30
      enable_execute_command         = false
      container_environment = [
        {
          name  = "ASPNETCORE_ENVIRONMENT"
          value = "Development"
        },
        {
          name  = "BucketName"
          value = "meitarim-object-store-#{env_prefix}#"
        }
      ]
      container_secrets = [
        {
          name       = "ConnectionStrings_MeitarimConnection"
          secret_key = "db-connection-string"
        }
      ]
    },

    cloudfront = {
      default_root_object = "index.html"
      default_cache_behavior = {
        cache_policy_name            = "Caching-1year"
        response_headers_policy_name = "molsa-#{env_prefix}#-response-headers-policy" #"molsa-#{env_prefix}#-response-headers-policy"
        origin_request_policy_name   =  "molsa-#{env_prefix}#-content-origin-request-policy" #"molsa-#{env_prefix}#-content-origin-request-policy"
      }
      ordered_cache_behavior = [
        {
          path_pattern           = "/#{api_prefix}#*"
          target_origin_id       = "ingress_alb"
          viewer_protocol_policy = "redirect-to-https"

          allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
          cached_methods  = ["GET", "HEAD"]

          use_forwarded_values         = false
          compress                     = true
          cache_policy_name            = "Managed-CachingDisabled"
          origin_request_policy_name   = "Managed-AllViewer"
          response_headers_policy_name = "molsa-#{env_prefix}#-response-headers-policy" #"molsa-#{env_prefix}#-response-headers-policy"
        }
      ]
      geo_restriction = {
        restriction_type = "whitelist"
        locations        = ["IL"]
      }
      custom_error_response = [{
        error_code         = 403
        response_code      = 403
        response_page_path = "/index.html"
        }, {
        error_code         = 404
        response_code      = 200
        response_page_path = "/index.html"
      }]
    }
  },
  "meitarim-object-store-#{env_prefix}#" = {
    domain        = "meitarim-object-store-#{env_prefix}#"
    bucket_storge = true
    create_bucket = true
    attach_policy_bucket = false
    create_apigw = false
  }
}

#RDS
db_name                                    = "SA_PSS_MEITARIM_AID_CENTERS"

postgres_app_username = "meitarimuser"
postgres_app_password = "#{postgres_app_password}#"
roles_assgined_app_user = {
  table_privileges    = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "TRIGGER"]
  sequence_privileges = ["SELECT", "USAGE", "UPDATE"]
  function_privileges = ["EXECUTE"]
  schema_privileges   = ["CREATE", "USAGE"]
}

postgres_dev_username = "meitarim_#{env_prefix}#_user"
postgres_dev_password = "#{postgres_dev_team_user_password}#"
roles_assgined_dev_user = {
  table_privileges    = ["SELECT", "INSERT", "UPDATE", "DELETE", "TRUNCATE", "REFERENCES", "TRIGGER"]
  sequence_privileges = ["SELECT", "USAGE", "UPDATE"]
  function_privileges = ["EXECUTE"]
  schema_privileges   = ["CREATE", "USAGE"]
}


tags = {
  created_by  = "terraform"
  environment = "#{env_prefix}#"
  project     = "meitarim"
}

generic_shutdown_startup_operations_tags = {
  "NoShutdown" = "#{no_shutdown_tag_value}#"
  "NoStartup" = "#{no_startup_tag_value}#"
  "BypassAutoShutdownStartup" = "#{bypass_auto_shutdown_startup_tag_value}#"
}


#Postgres Provider
use_dev_nlb  = false
dev_nlb_host = "10.184.65.38"
dev_nlb_port = 5434
