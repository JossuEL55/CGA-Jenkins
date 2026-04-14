pipeline {
    agent any

    stages {
        stage('Step 1 - Restore') {
            steps {
                bat 'dotnet restore CGA.MetrologySystem.slnx'
            }
        }

        stage('Step 2 - Build') {
            steps {
                bat 'dotnet build CGA.MetrologySystem.slnx --configuration Release --no-restore'
            }
        }
    }
}