variable "project_id" {
  default = "cloud-tpu-inference-test"
}

variable "region" {
    default = "southamerica-west1"
}

variable "zone" {
    default = "southamerica-west1-a"
}

variable "purpose" {
  default = "bm"
}

variable "spanner_instance" {
  default = "vllm-bm-inst"
}

variable "spanner_db" {
  default = "vllm-bm-runs"
}

variable "gcs_bucket" {
  default = "vllm-cb-storage2"
}

variable "v6e_1_count" {
  default     = 8
}

variable "v6e_4_count" {
  default     = 3
}

variable "v6e_8_count" {
  default     = 8
}

variable "branch_hash" {
  default     = "1863e7300422cc775b051193da0a289f3648843f"
  description = "commit hash of bm-infra branch."
}
