
variable "db_username" {
        default ="postgres"
        description = "database master username"
        type        = string 
        sensitive   =true
     }

variable  "db_password" {
        description = "database master password"
        default ="rnGz3FVP3WW3tHkYmV"
        type        = string 
        sensitive   =true
     }


variable "allocated_storage" {
  default     = 32
  type        = number
  description = "Storage allocated to database instance"
}

variable "engine_version" {
  default     = "11.5"
  type        = string
  description = "Database engine version"
}

variable "instance_type" {
  default     = "db.t3.micro"
  type        = string
  description = "Instance type for database instance"
}

variable "storage_type" {
  default     = "gp2"
  type        = string
  description = "Type of underlying storage for database"
}


# variable "database_name" {
#   type        = string
#   description = "Name of database inside storage engine"
# }

variable "database_port" {
  default     = 5432
  type        = number
  description = "Port on which database will accept connections"
}