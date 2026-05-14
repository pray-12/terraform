#!/bin/bash
apt update
apt install -y apache2

# Get the instance ID using the instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Install the AWS CLI
apt install -y awscli

# Download the images from S3 bucket
#aws s3 cp s3://myterraformprojectbucket2023/project.webp /var/www/html/project.png --acl public-read

# Create a simple HTML file with the portfolio content and display the images
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Terraform Project Server</title>

  <style>
    body {
      margin: 0;
      padding: 0;
      height: 100vh;
      display: flex;
      justify-content: center;
      align-items: center;
      background: linear-gradient(135deg, #0f172a, #1e3a8a);
      font-family: Arial, sans-serif;
      color: white;
    }

    .card {
      background: rgba(255, 255, 255, 0.1);
      padding: 40px;
      border-radius: 20px;
      text-align: center;
      width: 80%;
      max-width: 700px;
      box-shadow: 0 8px 30px rgba(0,0,0,0.4);
      backdrop-filter: blur(10px);
    }

    h1 {
      font-size: 3rem;
      margin-bottom: 20px;
      animation: glow 2s infinite alternate;
    }

    h2 {
      margin-bottom: 20px;
      color: #38bdf8;
    }

    .instance {
      color: #22c55e;
      font-weight: bold;
      background: rgba(34,197,94,0.15);
      padding: 5px 10px;
      border-radius: 8px;
    }

    p {
      font-size: 1.2rem;
      color: #e2e8f0;
    }

    @keyframes glow {
      from {
        text-shadow: 0 0 10px #38bdf8;
      }
      to {
        text-shadow: 0 0 25px #22c55e;
      }
    }
  </style>
</head>

<body>

  <div class="card">
    <h1>🚀 Terraform Project Server</h1>

    <h2>
      Instance ID:
      <span class="instance">{{INSTANCE_ID}}</span>
    </h2>

    <p>
      Welcome to your AWS + Terraform infrastructure project.
    </p>

    <p>
      Multi-AZ • Highly Available • DevOps Powered
    </p>
  </div>

</body>
</html>
EOF

# Start Apache and enable it on boot
systemctl start apache2
systemctl enable apache2