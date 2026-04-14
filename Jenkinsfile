pipeline {
    agent any

    stages {
        stage('Step 1 - Restore') {
            steps {
                bat 'dotnet restore CGA.MetrologySystem.sln'
            }
        }

        stage('Step 2 - Build') {
            steps {
                bat 'dotnet build CGA.MetrologySystem.sln --no-restore'
            }
        }
    }
}