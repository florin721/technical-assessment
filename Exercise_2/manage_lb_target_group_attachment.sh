#!/bin/bash

MAIN_TF="main.tf"

if grep -q '#resource "aws_lb_target_group_attachment" "k8s_node_targets"' "$MAIN_TF"; then
  echo "Uncommenting aws_lb_target_group_attachment block in main.tf..."

  sed -i '/#resource "aws_lb_target_group_attachment" "k8s_node_targets"/,/^#}/ s/^#//' "$MAIN_TF"
  
  echo "Block fully uncommented in main.tf."

elif grep -q 'resource "aws_lb_target_group_attachment" "k8s_node_targets"' "$MAIN_TF"; then
  echo "Commenting aws_lb_target_group_attachment block in main.tf..."

  sed -i '/resource "aws_lb_target_group_attachment" "k8s_node_targets"/,/^}/ s/^/#/' "$MAIN_TF"

  echo "Block fully commented out in main.tf."

else
  echo "Adding aws_lb_target_group_attachment block to main.tf..."

  cat <<EOL >> "$MAIN_TF"
resource "aws_lb_target_group_attachment" "k8s_node_targets" {
  for_each = toset(data.aws_instances.eks_nodes.ids)

  target_group_arn = aws_lb_target_group.k8s_target_group.arn
  target_id        = each.key
  port             = 30080
}
EOL

  echo "Block added to main.tf."
fi
