pipeline {
    agent any

    environment {
        DEV_CONTAINER  = 'ss-test-dev'
        PROD_CONTAINER = 'ss-test-prod'
        DEV_PORT       = '8081'
        PROD_PORT      = '8082'
        IMAGE_NAME     = 'ss-test-app'
    }

    stages {

        // ══════════════════════════════════════════════════
        // STAGE 1: CHECKOUT INFO (runs on all branches)
        // Just prints which branch is being processed
        // ══════════════════════════════════════════════════
        stage('Info') {
            steps {
                echo "════════════════════════════════════════"
                echo "🔍 Branch being processed: ${env.BRANCH_NAME}"
                echo "🔢 Build number: ${env.BUILD_NUMBER}"
                echo "════════════════════════════════════════"
            }
        }

        // ══════════════════════════════════════════════════
        // STAGE 2: BUILD
        // Runs on: develop AND feature/SS-TEST-*
        // Skipped on: prod (prod reuses develop image!)
        // ══════════════════════════════════════════════════
        stage('Build') {
            when {
                anyOf {
                    branch 'develop'
                    branch pattern: 'feature/SS-TEST-.*', comparator: 'REGEXP'
                }
            }
            steps {
                echo "🔨 Building Docker image on branch: ${env.BRANCH_NAME}"
                script {
                    // Sanitize branch name for docker tag (replace / with -)
                    def imageTag = env.BRANCH_NAME.replaceAll('/', '-')
                    sh "docker build -t ${IMAGE_NAME}:${imageTag} ."
                    echo "✅ Built image: ${IMAGE_NAME}:${imageTag}"
                }
            }
        }

        // ══════════════════════════════════════════════════
        // STAGE 3: TEST
        // Runs on: develop AND feature/SS-TEST-*
        // Good practice — always test before deploy!
        // ══════════════════════════════════════════════════
        stage('Test') {
            when {
                anyOf {
                    branch 'develop'
                    branch pattern: 'feature/SS-TEST-.*', comparator: 'REGEXP'
                }
            }
            steps {
                echo "🧪 Running tests on branch: ${env.BRANCH_NAME}"
                script {
                    // Replace with your actual test commands
                    // e.g., sh 'npm test' or sh 'mvn test'
                    sh 'echo "Running sample tests..."'
                    sh 'echo "All tests passed!"'
                }
                echo "✅ Tests completed successfully!"
            }
        }

        // ══════════════════════════════════════════════════
        // STAGE 4: DEPLOY TO DEV
        // Runs ONLY on: develop
        // Deploys develop image to dev container
        // ══════════════════════════════════════════════════
        stage('Deploy to Dev') {
            when {
                branch 'develop'
            }
            steps {
                echo "🚀 Deploying to DEV container..."
                script {
                    sh """
                        docker rm -f ${DEV_CONTAINER} || true
                        docker run -d \
                            --name ${DEV_CONTAINER} \
                            -p ${DEV_PORT}:80 \
                            ${IMAGE_NAME}:develop
                    """
                }
                echo "✅ Deployed to DEV → http://localhost:${DEV_PORT}"
            }
        }

        // ══════════════════════════════════════════════════
        // STAGE 5: DEPLOY TO PROD
        // Runs ONLY on: prod
        // NO BUILD — reuses the develop image!
        // ══════════════════════════════════════════════════
        stage('Deploy to Prod') {
            when {
                branch 'prod'
            }
            steps {
                echo "🚀 Deploying to PROD container..."
                script {
                    // Verify develop image exists before deploying
                    def imageExists = sh(
                        script: "docker images -q ${IMAGE_NAME}:develop",
                        returnStdout: true
                    ).trim()

                    if (imageExists == '') {
                        error("❌ No develop image found! Build develop first before deploying to prod!")
                    }

                    sh """
                        docker rm -f ${PROD_CONTAINER} || true
                        docker run -d \
                            --name ${PROD_CONTAINER} \
                            -p ${PROD_PORT}:80 \
                            ${IMAGE_NAME}:develop
                    """
                }
                echo "✅ Deployed to PROD → http://localhost:${PROD_PORT}"
            }
        }
    }

    // ══════════════════════════════════════════════════
    // POST ACTIONS — runs after all stages complete
    // ══════════════════════════════════════════════════
    post {
        success {
            echo "════════════════════════════════════════"
            echo "✅ Pipeline SUCCEEDED for branch: ${env.BRANCH_NAME}"
            echo "════════════════════════════════════════"
        }
        failure {
            echo "════════════════════════════════════════"
            echo "❌ Pipeline FAILED for branch: ${env.BRANCH_NAME}"
            echo "════════════════════════════════════════"
        }
        always {
            echo "🧹 Cleaning up dangling images..."
            sh 'docker image prune -f || true'
        }
    }
}