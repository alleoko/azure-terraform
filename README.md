# Azure Terraform

**Azure Terraform** is a starter project to provision resources on **Microsoft Azure** using **Terraform**. It demonstrates infrastructure as code for deploying Linux VMs, running initialization scripts via `customdata.tpl`, and automatically installing Docker.

---

## Features

- Deploy Azure infrastructure using Terraform  
- Create Linux VMs with automated setup scripts  
- Install and configure Docker on VMs  
- Dynamic VM initialization using `customdata.tpl`  

---

## Tech Stack

- **Terraform** – Infrastructure as Code  
- **Microsoft Azure** – Cloud provider  
- **Linux VM** – Target virtual machines  
- **Bash / Shell scripts** – VM initialization  
- **Docker** – Container runtime installed on VMs  
- **Azure CLI** – Manage Azure resources  
- **Git / GitHub** – Version control  

---

## Repository Structure

- `main.tf` – Terraform configuration  
- `customdata.tpl` – Template for VM initialization  
- `terraform.tfstate` – Terraform state file  

---

## Quick Setup

1. Install Terraform and Azure CLI  
2. Log in to your Azure account  
3. Run Terraform to deploy resources  

> VMs are automatically configured using `customdata.tpl`, which also installs Docker.  

---

## Docker & Custom Data

- `customdata.tpl` runs on VM boot  
- Installs Docker engine and CLI  
- Adds the default VM user to the Docker group  
- Enables immediate use of Docker containers on the VM
