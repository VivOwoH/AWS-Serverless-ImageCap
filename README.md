# AWS Image Caption App with Serverless Architecture

A cloud-native web application that automatically generates captions and thumbnails for uploaded images using AWS serverless computing and Google's Gemini AI. See [deployment report](deployment%20report.pdf) for full details.

## Deployment

### Packaged Artifects

- **caption-package.zip**: Contains Google AI dependencies and caption generation code
- **thumbnail-package.zip**: Contains PIL library and image processing code
- **Image-caption-app.zip**: Flask web application code

### Environment Variables

- Caption Lambda
```
DB_HOST=image-app-db.cqi7uwt3hkvj.us-east-1.rds.amazonaws.com
DB_NAME=image_caption_db
DB_USER=admin
DB_PASSWORD=imagePassword!
GOOGLE_API_KEY=AIzaSyBlEbQP4zbYOqcYL_-Sv_KhlBsfo2ZWbUE
```

- Thumbnail Lambda
```
DB_HOST=image-app-db.cqi7uwt3hkvj.us-east-1.rds.amazonaws.com
DB_NAME=image_caption_db
DB_USER=admin
DB_PASSWORD=imagePassword!
```

- Database Schema
```sql
CREATE TABLE captions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    image_key VARCHAR(255) NOT NULL,
    caption TEXT,
    thumbnail_key VARCHAR(255),
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    caption_generated_at TIMESTAMP NULL,
    thumbnail_generated_at TIMESTAMP NULL
);
```


## Architecture Overview

### Web Application Architecture
![Web Application Architecture](app.drawio.png)

The three-tier architecture:
- **Presentation Layer**: Application Load Balancer (ALB) in public subnets across two Availability Zone (AZs)
- **Application Layer**: Auto-scaling Flask web servers in private subnets
- **Data Layer**: RDS MySQL in isolated private subnets

### Serverless Architecture
![Serverless Architecture](serverless.drawio.png)

Event-driven serverless components handle caption/thumbnail processing:
- **S3 Upload Trigger**: ObjectCreated events initiate processing
- **SNS Fan-out**: Distributes events to multiple Lambda functions
- **Caption Lambda**: Generates descriptions using Google Gemini AI
- **Thumbnail Lambda**: Creates 200x200px image thumbnails

## Features

- **Auto-scaling**: EC2 instances scale based on 70% CPU utilization
- **Event-driven Processing**: Automatic caption and thumbnail generation on upload
- **Three-tier Security**: Network isolation with security groups and private subnets
- **High Availability**: Multi-AZ deployment with load balancing
- **External AI Integration**: Google Gemini API for intelligent image captioning

### AWS Services
- **Compute**: EC2 with Auto Scaling Groups (ASGs), Lambda Functions
- **Storage**: S3 for images and deployment packages
- **Database**: RDS MySQL for metadata and captions
- **Networking**: VPC, ALB, NAT Gateway
- **Messaging**: SNS for event distribution
- **Monitoring**: CloudWatch for logs and metrics

#### Event Flow

1. User uploads image through web interface
2. Image stored in S3 with metadata recorded in RDS
3. S3 ObjectCreated event triggers SNS topic
4. SNS fans out to two Lambda functions:
   - **Caption Lambda**: Downloads image, calls Gemini API, updates database
   - **Thumbnail Lambda**: Generates resized image, uploads to S3, updates database
5. Results displayed in web gallery with captions and thumbnails

### Dev Stack
- **Backend**: Python Flask web framework
- **AI**: Google Generative AI (Gemini 2.5 Flash)
- **Image Processing**: PIL (Python Imaging Library)
- **Database**: MySQL with mysql-connector-python


## Infrastructure Config

### ASG
- **Instance Type**: t3.micro (1 vCPU, 1 GB RAM)
- **Scaling Policy**: Target tracking at 70% CPU utilization
- **Capacity**: Min 1, Max 3 instances
- **Health Checks**: ELB health checks with 300s grace period

### Lambda Functions
- **Memory**: 512 MB allocated for both functions
- **Timeout**: 5 minutes for external API calls
- **VPC**: Deployed in private subnets with NAT Gateway access
- **Permissions**: LabRole with S3, RDS, and VPC permissions

### Security Groups
- **ALB-SG**: HTTP (80) from internet
- **EC2-SG**: HTTP (5000) from ALB, SSH (22) from Bastion
- **Lambda-SG**: MySQL (3306) to RDS
- **RDS-SG**: MySQL (3306) from EC2 and Lambda only

## Load Testing

Validated auto-scaling behavior with sustained traffic:

![Load Test](loadtest.png)


