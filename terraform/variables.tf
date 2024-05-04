variable "venmo_auth_token" {
  description = "Venmo auth token"
  type        = string
  # Default will be taken from the environment variable 'TF_VAR_venmo_auth_token' 
  # or you will be prompted to provide the value when running "terrafor apply"
}
