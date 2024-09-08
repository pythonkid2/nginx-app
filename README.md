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

# CI/CD Pipeline Setup with Jenkins, AWS EC2, and CodeDeploy 

# Step 1: Create Two IAM Roles in AWS IAM

## 1. Create a Role for EC2

1. Open the IAM Management Console and navigate to the "Roles" section.
2. Click on **Create Role**.
3. Under **Select trusted entity**, choose **EC2** as the use case.

![image](https://github.com/user-attachments/assets/78bc025e-e59a-4c5d-a4c1-5d1301fc2e2e)

5. Attach the following managed policies:
   - **AmazonEC2RoleforAWSCodeDeploy** 
   - **AmazonS3FullAccess** 
   - **AWSCodeDeployRole** 

6. Complete the role creation by providing a name and reviewing the configurations.

![image](https://github.com/user-attachments/assets/0251c5c3-8aad-4d0c-8639-5aee5a64e2be)

![image](https://github.com/user-attachments/assets/5050a7bd-6cb0-453b-a899-192ba7c86086)

## 2. Create a Role for CodeDeploy

1. Click on **Create Role**.
2. Under **Select trusted entity**, choose **CodeDeploy** as the use case.
3. 
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
   
5. Under **VPC and subnets**, select the appropriate subnets for the availability zones where the instances will be launched.

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

## **Step 5: Adding Code to the Repository**

### **Step 1: Set Up the Web Application**

1. Create a basic NGINX web server application locally:
   ```
   mkdir nginx-app
   cd nginx-app
   mkdir scripts
   touch index.html
   ```

2. Add a simple HTML page in `index.html`:
   ```
   <!DOCTYPE html>
   <html>
   <head>
       <title>Welcome to NGINX!</title>
   </head>
   <body>
       <h1>Deployed via CodeDeploy!</h1>
   </body>
   </html>
   ```

3. Create deployment scripts:
   - **scripts/install_nginx.sh** (installs NGINX):
     ```
     #!/bin/bash
     sudo apt update -y
     sudo apt install nginx -y
     ```


   - **scripts/start_nginx.sh** (starts NGINX service):
     ```
     #!/bin/bash
     sudo systemctl start nginx
     ```

   - **scripts/deploy.sh** (deploys the web page):
     ```
     #!/bin/bash
     sudo cp /home/ubuntu/nginx-app/index.html /var/www/html/index.html
     sudo systemctl restart nginx
     ```

chmod +x install_nginx.sh deploy.sh start_nginx.sh

add appspec.yml for CodeDeploy

```
version: 0.0
os: linux
files:
  - source: .
    destination: /home/ubuntu/nginx-app

hooks:
  BeforeInstall:
    - location: scripts/install_nginx.sh
      timeout: 300
      runas: root
  AfterInstall:
    - location: scripts/deploy.sh
      timeout: 300
      runas: root
  ApplicationStart:
    - location: scripts/start_nginx.sh
      timeout: 300
      runas: root
```

4. Push this code to the GitHub repository.

### **1. Create a GitHub Repository**

If a repository has not been created yet, do the following:

1. **Log in to GitHub**:
   - Go to [GitHub](https://github.com/) and log in.

2. **Create a New Repository**:
   - Click on the **+** icon in the top-right corner and select **New repository**.
   - Fill in the details:
     - **Repository name**: `nginx-app`
     - **Public/Private**: Public
   - Click **Create repository**.

![image](https://github.com/user-attachments/assets/5fe13336-f32a-4b18-96ad-ef56f38841be)

### **2. Prepare Your Local Project**

1. **Navigate to the Project Directory**:
   ```
   cd /path/to/your/nginx-app
   ```

2. **Initialize Git**:
   ```
   git init
   ```

3. **Add Your Files**:
   ```
   git add .
   ```

4. **Commit Your Changes**:
   ```
   git commit -m "Initial commit of NGINX web application and deployment scripts"
   ```

### **3. Add Your GitHub Repository as a Remote**

1. **Add Remote Origin**:
   ```
   git remote add origin https://github.com/pythonkid2/nginx-app.git
   ```

### **4. Push Your Code to GitHub**

1. **Push to the Remote Repository** using your username and token:
   ```
   git push -u origin main
   ```

2. **Verify Your Push**:
   - Go to your GitHub repository page and refresh to ensure that your files have been uploaded.

![image](https://github.com/user-attachments/assets/6a225fff-7661-4874-9a33-3bdf8c8776b4)

---

## **Step 6: Create and Set Up a Jenkins Server**

1. Launch an Ubuntu EC2 instance with the following specifications:
   - **Instance Type**: `t2.medium`
   - **Storage**: 15 GB
   - **Name**: `jenkins-server`

2. SSH into the EC2 instance:

   ```
   ssh -i /path/to/your-key.pem ubuntu@<EC2_PUBLIC_IP>
   ```

![image](https://github.com/user-attachments/assets/4de2dd57-5b26-404b-841a-22d4c530efa4)

3. Install Jenkins on the instance using the instructions from the following URL:

[Jenkins Installation Guide for Debian/Ubuntu](https://www.jenkins.io/doc/book/installing/linux/#debianubuntu)

Install jave first

```
sudo apt install fontconfig openjdk-17-jre -y
```

4. After Jenkins installation, obtain the initial admin password:

   ```
   sudo cat /var/lib/jenkins/secrets/initialAdminPassword
   ```
5. Access Jenkins by navigating to `http://<EC2_PUBLIC_IP>:8080` in a web browser.

![image](https://github.com/user-attachments/assets/052fbfb7-739e-49bc-ba1e-7de072a652e4)

![image](https://github.com/user-attachments/assets/d2aa3a66-3c8f-4cd3-a82c-5b469110fa6e)

9. Complete the Jenkins setup and ensure it is accessible for further configuration and use.
---

## **Step 7: Jenkins Configuration and Setup**

1. **Create an S3 Bucket for Jenkins**

   - Navigate to the **S3 Console**.
   - Click **Create bucket**.
   - Configure the bucket settings:
     - **Bucket Name**: Enter a unique name  `my-jenkins-codedeploy-bucket'

![image](https://github.com/user-attachments/assets/44dc1444-535e-42f0-b08f-8cbf67055052)

![image](https://github.com/user-attachments/assets/8afc9740-7b4a-4b12-95b6-78276815a517)

 - Click **Create bucket**.

2. **Install Required Plugins in Jenkins**

   - Log in to Jenkins and navigate to **Manage Jenkins** > **Manage Plugins**.
   - Go to the **Available** tab.
   - Search for and install the following plugins:
     - **Pipeline: AWS Steps**
     - **AWS CodeDeploy**
     - **Pipeline: Stage View** (if using pipelines)

![image](https://github.com/user-attachments/assets/85ec7da2-d45f-49d5-b9b1-1391586d0dc2)

3. **Create a Freestyle Project in Jenkins**

   - Go to **New Item** from the Jenkins dashboard.
   - Enter a name for the project.
   - Select **Freestyle project** and click **OK**.

![image](https://github.com/user-attachments/assets/2d9a6952-aaa6-4a3b-8e8f-08c8c93433d7)

    - Configure the project:

 ![image](https://github.com/user-attachments/assets/4f84ce9b-6f5d-4442-812b-1016ef0b1968)

 - **Source Code Management**: Choose **Git** and provide your repository URL (`https://github.com/pythonkid2/nginx-app.git`).

![image](https://github.com/user-attachments/assets/08a3dd8c-2d45-4dae-912c-5be3eb55e340)     

- **Build Triggers**: Configure as needed (e.g., GitHub hook trigger for GITScm polling).
  
![image](https://github.com/user-attachments/assets/df622f7a-00f8-41e0-bee7-cd4e9ef60fc3)

- **Build Environment**: Configure environment settings if required.

Choose post-build-action as deploy an application AWS CodeDeploy 

![image](https://github.com/user-attachments/assets/31d24ce8-fcb1-43e6-9962-fa637dddd156)

![image](https://github.com/user-attachments/assets/1b4755a9-2469-4789-b247-f10373ce34be)

- **Build Steps**: Add build steps for deployment using the AWS CodeDeploy plugin.

![image](https://github.com/user-attachments/assets/96974799-e1b1-45a7-a831-f0ced1ad0a69)

---

## **Step 8: Final Outputs**

### **1. Jenkins Build and Deployment**

- **Build Process:**

![Jenkins Build Process](https://github.com/user-attachments/assets/c73ed129-e5fa-4848-ba13-a05b1d6a0865)
  - Jenkins build process in progress.

### **2. Deployment Started**

- **Deployment Initialization:**

![Deployment Started 1](https://github.com/user-attachments/assets/76bc9aa4-5032-4fc3-8cc9-e00981a89ad2)
  - Deployment has been initiated.
  

  ![Deployment Started 2](https://github.com/user-attachments/assets/a76c6ef1-f871-470b-83f9-951282ad6f3b)
  - Deployment process is underway.

### **3. Deployed with Load Balancer**

- **Load Balancer Configuration:**

![Load Balancer](https://github.com/user-attachments/assets/fbe5802c-97a5-4661-8c13-314036b890d8)
  - Application deployed with a load balancer.

- **Access URL:**

![Load Balancer URL](https://github.com/user-attachments/assets/b38c8661-93f2-44a8-9fd3-f60d35935fd3)
  - Access the application via the load balancer URL: WebApp-AutoScaling-Loadbalancer-1039090491.us-east-2.elb.amazonaws.com.

### **4. Updating HTML Code**

- **Updated HTML Code:**

![Updated HTML Code](https://github.com/user-attachments/assets/6a30df4a-205a-49ff-8ce8-e371dd5acd6e)
  - Updated HTML code for the web application.

- **Code Changes:**

![Code Changes](https://github.com/user-attachments/assets/740d3595-e032-4b08-ba57-882e1350f19e)
  - Screenshot showing the code changes made.

### **5. Jenkins Triggered**

- **Jenkins Triggered Deployment:**

![Jenkins Triggered](https://github.com/user-attachments/assets/ebca1df0-786b-4ab8-9616-d26ee70494eb)
  - Jenkins triggered deployment after code changes.

### **6. Deployment Started**

- **Deployment Process:**

![Deployment Started](https://github.com/user-attachments/assets/212779db-1da1-4225-be25-46fb2e8b6f08)
  - Deployment process has started.

### **7. Deployment Events**

- **Deployment Events:**

![Deployment Events](https://github.com/user-attachments/assets/6ece3926-3cba-46d7-9eed-f1c2b6818e7f)
  - Deployment events showing progress and status.

### **8. New Page Deployed**

- **Deployed Web Page:**

 ![New Page Deployed](https://github.com/user-attachments/assets/9dcdc967-8e1d-4574-8c5c-677419869dfc)
  - The updated web page successfully deployed.

---
---
![image](https://github.com/user-attachments/assets/e61eb3b1-ad69-468d-aba7-7566ba9d8e6a)
