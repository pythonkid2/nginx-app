# Problem Statement

### Objective
Setup a CI/CD pipeline using tools of your choice (or preferably the mentioned tools) to achieve the following goals:
1. **Deploy on Code Push**: The pipeline should deploy a simple web application to a server whenever code is pushed to a repository.
2. **Accessibility**: The deployed web application should be accessible via any web browser.
3. **Scalability**: The deployment should be scalable. When the load increases, the number of servers should automatically scale up and down while ensuring that newly launched servers have the updated code.

### Additional Requirements
1. The setup should be done using **AWS**, **Jenkins**, and **CodeDeploy**.
2. **Jenkins** should not be installed on the same server as the one hosting the deployed application.

### Tools
- **Jenkins**
- **Git/Bitbucket**
- **AWS EC2**
- **AWS CodeDeploy**

---

# Step 1: Create Two IAM Roles in AWS IAM

## 1. Create a Role for EC2
1. Open the IAM Management Console and navigate to the "Roles" section.
2. Click on **Create Role**.
3. Under **Select trusted entity**, choose **EC2** as the use case.
![image](https://github.com/user-attachments/assets/78bc025e-e59a-4c5d-a4c1-5d1301fc2e2e)
4. Attach the following managed policies:
   - **AmazonEC2RoleforAWSCodeDeploy** 
   - **AmazonS3FullAccess** 
   - **AWSCodeDeployRole** 
5. Complete the role creation by providing a name and reviewing the configurations.
![image](https://github.com/user-attachments/assets/0251c5c3-8aad-4d0c-8639-5aee5a64e2be)
![image](https://github.com/user-attachments/assets/5050a7bd-6cb0-453b-a899-192ba7c86086)

## 2. Create a Role for CodeDeploy

1. Click on **Create Role**.
2. Under **Select trusted entity**, choose **CodeDeploy** as the use case.
![image](https://github.com/user-attachments/assets/fde72782-cc4c-4324-9f11-3f7fb9b52773)
4. Attach the following managed policies:
   - **AmazonEC2FullAccess** 
   - **AWSCodeDeployRole** 
5. Finalize the role creation by providing a name and reviewing the configurations.
![image](https://github.com/user-attachments/assets/b4e9acc7-bc29-49a4-8d3b-1d992027016d)

# Step 2: Create a Launch Template with the EC2-Role

1. Open the EC2 Management Console and navigate to the **Launch Templates** section.
2. Click on **Create Launch Template**.

### Configure the Launch Template:
- **Launch Template Name**: Enter `WebApp-server`.
- **AMI (Amazon Machine Image)**: Select the latest Ubuntu image.
![image](https://github.com/user-attachments/assets/e39b22be-9336-448d-a418-09006d8f4ae4)
- **Instance Type**: Choose `t2.micro`.
- **Key Pair**:select the key pair.
- **Security groups**: select default (open ssh, http, https ports)
- **IAM Instance Profile**: Choose the IAM role `EC2-Role` created earlier.
![image](https://github.com/user-attachments/assets/ac6c6d5c-e604-4bc3-9f8c-879ee9fc9f42)
- **Storage**: Use default storage settings.

### User Data:

Add the following script in the **Advanced Details** under the **User Data** section:
```
#!/bin/bash

# Optional: Wait for instance initialization
sleep 30

# Update package list
sudo apt update -y

# Install necessary packages
sudo apt install -y ruby-full 

# Download the CodeDeploy agent installation script
wget https://aws-codedeploy-us-east-2.s3.us-east-2.amazonaws.com/latest/install

# Make the installation script executable
chmod +x ./install

# Run the installation script
sudo ./install auto
```
![image](https://github.com/user-attachments/assets/09b36a9e-fdb4-454f-afc2-4be0e847d49f)
![image](https://github.com/user-attachments/assets/274b6558-2b0b-4c99-b6ce-875cc0a3dfe7)
![image](https://github.com/user-attachments/assets/155b2fca-fe3d-491c-950a-ebcf8ea0d201)

---

# Step 3: Create an Auto Scaling Group and Attach a Load Balancer

## 1. Create an Auto Scaling Group

1. Navigate to the **Auto Scaling Groups** section in the **EC2 Management Console** and click **Create Auto Scaling Group**.
2. In the **Auto Scaling Group Name** field, enter `WebApp-AutoScalingGroup`.
3. Under **Launch Template**, select the previously created launch template `WebApp-server`.
   ![Launch Template Image](https://github.com/user-attachments/assets/b5e01927-0d8c-4ea3-9000-b1b44ca1a7c8)
4. Under **VPC and subnets**, select the appropriate subnets for the availability zones where the instances will be launched.
   ![VPC and Subnets Image](https://github.com/user-attachments/assets/3bb6a2db-7c3f-4ee4-a68c-5cf12705c73c)

## 2. Configure Advanced Options and Load Balancing

1. Under **Load Balancing**, choose to attach to a new load balancer.
2. Set the following configuration for the load balancer:
   - **Load Balancer Name**: `WebApp-AutoScaling-Loadbalancer`
   - **Scheme**: Choose **Internet-facing**
   ![Load Balancer Configuration Image](https://github.com/user-attachments/assets/43d29188-a9d5-4f7b-9c3b-113bbe66c0d2)
3. In the **Target Groups** section, a new instance target group will be created with default settings:
   - **Target Group Name**: `WebApp-AutoScaling`
   ![Target Group Configuration Image](https://github.com/user-attachments/assets/58ffe1a4-0077-4100-846e-84ec6699545b)

## 3. Configure Auto Scaling Policies

1. Set the desired scaling parameters:
   - **Desired Capacity**: `1`
   - **Minimum Capacity**: `1`
   - **Maximum Capacity**: `2`
2. Enable a **Target Tracking Scaling Policy**. Configure it as follows:
   - **Policy Name**: `Target Tracking Policy`
   - **Metric Type**: **Average CPU utilization**
   - **Target Value**: `60`
   ![Scaling Policy Configuration Image](https://github.com/user-attachments/assets/0476a314-bfdc-47c2-9ebf-d3ce5b45143e)

3. Review the configuration, finalize, and click **Create Auto Scaling Group**.

![image](https://github.com/user-attachments/assets/0476a314-bfdc-47c2-9ebf-d3ce5b45143e)

![image](https://github.com/user-attachments/assets/74585bee-cfae-4def-b3f2-c55ec37ea222)

The created instances have code deploy agent installed and its working fine 
![image](https://github.com/user-attachments/assets/bdc773e0-2110-443f-9c1e-b2223085bc1f)

---

# Step 4: Create a CodeDeploy Application and Deployment Group

## 1. Create a CodeDeploy Application

1. Open the **AWS CodeDeploy Console**.
2. Click on **Create Application**.
3. Set the following configurations:
   - **Application Name**: Enter `WebApp-CodeDeploy`.
   - **Compute Platform**: Select **EC2/On-premises**.
![image](https://github.com/user-attachments/assets/c23a51b0-e48b-40ed-8296-8efcab350899)

4. Click **Create Application**.

## 2. Create a Deployment Group

1. In the **AWS CodeDeploy Console**, select the newly created application `WebApp-CodeDeploy`.
2. Click on **Create Deployment Group**.

### Configure Deployment Group:
1. Set the following:
   - **Deployment Group Name**: Enter `WebApp-DeploymentGroup`.
   - **Service Role**: Select the previously created IAM role with CodeDeploy permissions

2. Under **Deployment type**, choose **In-place**.
![image](https://github.com/user-attachments/assets/66ab59a1-b045-41c9-93b8-9407712d5998)

### Configure Environment:
1. In the **Environment Configuration** section:
   - **Environment type**: Select **Amazon EC2 instances**.
   - **Auto Scaling Group**: Choose `WebApp-AutoScalingGroup` (the Auto Scaling Group created earlier).
![image](https://github.com/user-attachments/assets/4d7e3ac7-e2fc-416b-9a83-d74f952c6daa)

2. Under **Deployment Settings**:
   - **Deployment Configuration**: Choose **CodeDeployDefault.OneAtATime** (or select another option as needed).

### Configure Load Balancer (Optional):
1. If load balancing is used, check the box for **Enable load balancing**.

![image](https://github.com/user-attachments/assets/ba1b67c5-edc1-458b-96ee-ce05c815b8a6)


3. Review the configuration and click **Create Deployment Group**.

---







