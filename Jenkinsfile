pipeline {
    agent any

    environment {
        AWS_REGION = 'eu-north-1'
    }

    stages {
        stage('Checkout') {
            steps {
                echo "📦 Checking out Terraform code..."
                git branch: 'main', url: 'https://github.com/ramsrikanthpabbineedi/11-19-2025.git'
            }
        }

        stage('Terraform Format Check') {
            steps {
                echo "🧩 Checking Terraform formatting..."
                sh 'terraform fmt -check -recursive'
            }
        }

        stage('Terraform Init') {
            steps {
                echo "🚀 Initializing Terraform..."
                withAWS(credentials: 'aws_id', region: "${AWS_REGION}") {
                    sh 'terraform init -input=false'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                echo "🧠 Validating Terraform configuration..."
                withAWS(credentials: 'aws_id', region: "${AWS_REGION}") {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                echo "📝 Creating Terraform plan..."
                withAWS(credentials: 'aws_id', region: "${AWS_REGION}") {
                    sh 'terraform plan -out=tfplan -input=false'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                echo "⚙️ Applying Terraform changes automatically..."
                withAWS(credentials: 'aws_id', region: "${AWS_REGION}") {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
    }

    post {
        success {
            echo "✅ Terraform resources deployed successfully!"
        }
        failure {
            echo "❌ Terraform pipeline failed!"
        }
        always {
            cleanWs()
        }
    }
}


