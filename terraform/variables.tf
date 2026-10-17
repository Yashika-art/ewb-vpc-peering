variable "region" {
  description = "AWS Region for every resource"
  type        = string
  default     = "north-west"
}

variable "student_name" {
  description = "Student name (used for the Student tag)"
  type        = string
}

variable "my_public_ip" {
  description = "Your current public IPv4 address WITHOUT /32 (e.g. 203.0.113.25)"
  type        = string
}

variable "public_key_path" {
  description = "Path to the PUBLIC key (.pub) for your ewb-lab key. Never put the private key in this repo."
  type        = string
  default     = "~/.ssh/ewb-lab.pub"
}

variable "instance_type" {
  description = "Small x86 instance type approved by your instructor"
  type        = string
  default     = "t3.micro"
}

variable "enable_peering" {
  description = "false = baseline (no peering, no peer routes). true = peering + routes. Apply twice to capture the baseline first."
  type        = bool
  default     = false
}
