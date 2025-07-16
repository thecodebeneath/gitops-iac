variable AWS_ACCESS_KEY_ID {
  type        = string
  nullable    = false
  description = "AWS session credentials"
}

variable AWS_SECRET_ACCESS_KEY {
  type        = string
  nullable    = false
  description = "AWS session credentials"
}

variable AWS_SESSION_TOKEN {
  type        = string
  nullable    = false
  description = "AWS session credentials"
}

variable AWS_REGION {
  type        = string
  default     = "us-east-2"
  description = "AWS session credentials"
}

variable project_name {
  type        = string
  default     = "codebeneath"
  description = "A string used for all resource names"
}
