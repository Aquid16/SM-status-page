## CI Summary
### Infracost Report
#### vpc Infracost Report
[1mProject:[0m Aquid16/SM-status-page/terraform/production/infrastructure/vpc ([command]/home/runner/work/_temp/389863c7-501f-4597-80d9-70d18dcc61c5/terraform-bin workspace show)

 [4mName[0m                                   [4mMonthly Qty[0m  [4mUnit[0m              [4mMonthly Cost[0m 
                                                                                    
 [1mmodule.vpc.aws_nat_gateway.this[0][0m                                                 
 [2m├─[0m NAT gateway                                 730  hours                   $32.85 
 [2m└─[0m Data processed                   Monthly cost depends on usage: $0.045 per GB   
                                                                                    
[1m OVERALL TOTAL[0m                                                               $32.85 
──────────────────────────────────
16 cloud resources were detected:
∙ 1 was estimated, it includes usage-based costs, see [4mhttps://infracost.io/usage-file[0m
∙ 15 were free, rerun with --show-skipped to see details

#### security_groups Infracost Report
[1mProject:[0m Aquid16/SM-status-page/terraform/production/infrastructure/security_groups ([command]/home/runner/work/_temp/389863c7-501f-4597-80d9-70d18dcc61c5/terraform-bin workspace show)

 [4mName[0m  [4mMonthly Qty[0m  [4mUnit[0m  [4mMonthly Cost[0m 
                                       
[1m OVERALL TOTAL[0m                   $0.00 
──────────────────────────────────
3 cloud resources were detected:
∙ 0 were estimated
∙ 3 were free, rerun with --show-skipped to see details

#### efs Infracost Report
[1mProject:[0m Aquid16/SM-status-page/terraform/production/infrastructure/efs ([command]/home/runner/work/_temp/389863c7-501f-4597-80d9-70d18dcc61c5/terraform-bin workspace show)

 [4mName[0m                       [4mMonthly Qty[0m  [4mUnit[0m            [4mMonthly Cost[0m 
                                                                      
 [1maws_efs_file_system.efs[0m                                              
 [2m└─[0m Storage (standard)    Monthly cost depends on usage: $0.30 per GB 
                                                                      
[1m OVERALL TOTAL[0m                                                  $0.00 
──────────────────────────────────
3 cloud resources were detected:
∙ 1 was estimated, it includes usage-based costs, see [4mhttps://infracost.io/usage-file[0m
∙ 2 were free, rerun with --show-skipped to see details

#### eks Infracost Report
[1mProject:[0m Aquid16/SM-status-page/terraform/production/infrastructure/eks ([command]/home/runner/work/_temp/389863c7-501f-4597-80d9-70d18dcc61c5/terraform-bin workspace show)

 [4mName[0m                                                                                              [4mMonthly Qty[0m  [4mUnit[0m                    [4mMonthly Cost[0m 
                                                                                                                                                     
 [1mmodule.eks.aws_cloudwatch_log_group.this[0][0m                                                                                                         
 [2m├─[0m Data ingested                                                                            Monthly cost depends on usage: $0.50 per GB             
 [2m├─[0m Archival Storage                                                                         Monthly cost depends on usage: $0.03 per GB             
 [2m└─[0m Insights queries data scanned                                                            Monthly cost depends on usage: $0.005 per GB            
                                                                                                                                                     
 [1mmodule.eks.aws_eks_cluster.this[0][0m                                                                                                                  
 [2m└─[0m EKS cluster                                                                                            730  hours                         $73.00 
                                                                                                                                                     
 [1mmodule.eks.module.eks_managed_node_group["sm_worker_nodes"].aws_eks_node_group.this[0][0m                                                              
 [2m└─[0m module.eks.module.eks_managed_node_group["sm_worker_nodes"].aws_launch_template.this[0]                                                          
 [2m   ├─[0m Instance usage (Linux/UNIX, on-demand, t3.medium)                                                 1,460  hours                         $60.74 
 [2m   └─[0m EC2 detailed monitoring                                                                              14  metrics                        $4.20 
                                                                                                                                                     
 [1mmodule.eks.module.kms.aws_kms_key.this[0][0m                                                                                                           
 [2m├─[0m Customer master key                                                                                      1  months                         $1.00 
 [2m├─[0m Requests                                                                                 Monthly cost depends on usage: $0.03 per 10k requests   
 [2m├─[0m ECC GenerateDataKeyPair requests                                                         Monthly cost depends on usage: $0.10 per 10k requests   
 [2m└─[0m RSA GenerateDataKeyPair requests                                                         Monthly cost depends on usage: $0.10 per 10k requests   
                                                                                                                                                     
[1m OVERALL TOTAL[0m                                                                                                                               $138.94 
──────────────────────────────────
30 cloud resources were detected:
∙ 4 were estimated, 2 of which include usage-based costs, see [4mhttps://infracost.io/usage-file[0m
∙ 26 were free, rerun with --show-skipped to see details

#### access_entries Infracost Report
[1mProject:[0m Aquid16/SM-status-page/terraform/production/infrastructure/access_entries ([command]/home/runner/work/_temp/389863c7-501f-4597-80d9-70d18dcc61c5/terraform-bin workspace show)

 [4mName[0m  [4mMonthly Qty[0m  [4mUnit[0m  [4mMonthly Cost[0m 
                                       
[1m OVERALL TOTAL[0m                   $0.00 
──────────────────────────────────
8 cloud resources were detected:
∙ 0 were estimated
∙ 8 are not supported yet, rerun with --show-skipped to see details

#### rds Infracost Report
[1mProject:[0m Aquid16/SM-status-page/terraform/production/infrastructure/rds ([command]/home/runner/work/_temp/389863c7-501f-4597-80d9-70d18dcc61c5/terraform-bin workspace show)

 [4mName[0m                                                      [4mMonthly Qty[0m  [4mUnit[0m   [4mMonthly Cost[0m 
                                                                                            
 [1mmodule.rds.module.db_instance.aws_db_instance.this[0][0m                                      
 [2m├─[0m Database instance (on-demand, Single-AZ, db.t3.micro)          730  hours        $13.14 
 [2m└─[0m Storage (general purpose SSD, gp2)                              20  GB            $2.30 
                                                                                            
[1m OVERALL TOTAL[0m                                                                       $15.44 
──────────────────────────────────
4 cloud resources were detected:
∙ 1 was estimated, it includes usage-based costs, see [4mhttps://infracost.io/usage-file[0m
∙ 3 were free, rerun with --show-skipped to see details

