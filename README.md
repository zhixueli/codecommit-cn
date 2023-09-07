# 使用 Terraform 为 AWS CodeCommit 自动化创建 IAM Users 以及 HTTPS Git credentials
## 预先条件
1. 创建或者配置 s3 存储桶，用于存储 git user 文件，并将存储桶名称配置到 terraform variables 的 bucket_name 
2. 创建 lambda 函数（使用 Lambda 目录下的 python code），用于发送邮件通知
    - 按如下方式配置 lambda 环境变量，设置 smtp 服务相关配置为可用的配置
![alt text](https://github.com/zhixueli/codecommit-cn/blob/main/lambda/lambda_env_vars.jpeg?raw=true)
    - 配置第一步创建 s3 存储桶 event notification，对于 object put/post/copy 事件触发第二步创建的 lambda 函数
    - 对于 lambda 的 execution role 的 policy，添加对 s3 服务只读权限 
3. 预先创建好 iam group，并赋予 group 相应的权限，用于管理 iam git user
## 使用方法
1. 在 terraform.tfvars 文件中的 user_names 中添加所有需要创建的用户的名称，以及 tag 来存储相应的邮箱信息
2. 在 terraform.tfvars 文件中的 group_memberships 配置 user 和 group 之间的对应关系，group 名称必须为在 iam 中已经创建好的 group，user 和 group 可以为一对多的关系
3. 在 main.tf 文件中配置好 aws provider 的区域以及使用的 profile