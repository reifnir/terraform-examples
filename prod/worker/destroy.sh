#!/bin/bash

VM_HOSTNAME_BASE="prod-worker"

echo "Destroying 3 worker VMs..."
IDS=(0 1 2)
for ID in ${IDS[*]}; do
  VM_ID="$VM_HOSTNAME_BASE-$ID"
  STATE_KEY="$VM_ID.tfstate"

  echo "Clearing .terraform working directory (or Terraform will not work when more than one VM)..."
  rm -rf ./.terraform

  echo "Initializing terraform for $STATE_KEY"
  terraform init --backend-config="key=$STATE_KEY"

  echo "Executing terraform plan for $VM_ID..."
  terraform destroy -input=false -var "vm_id=$ID" --auto-approve

done
