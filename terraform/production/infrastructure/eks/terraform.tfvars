cluster_name        = "sm-statuspage-eks"
cluster_version     = "1.31"
desired_size        = 3
max_size            = 3
min_size            = 3
instance_types      = ["t3.medium"]
iam_role_arn        = "arn:aws:iam::992382545251:role/sm-eks-cluster-role"
node_group_role_arn = "arn:aws:iam::992382545251:role/sm-eks-node-group-role"