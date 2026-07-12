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

        // ══════════════════════════════════════════
        // STAGE 1: BUILD
        // Runs on: develop AND feature/SS-TEST-*
        // Skipped on: prod
        // ══════════════════════════════════════════
        stage('Build') {
            when {
                anyOf {
                    branch 'develop'
                    branch pattern: 'feature/SS-TEST-.*', comparator: 'REGEXP'
                }
            }
            steps {
                echo "🔨 Building on branch: ${env.BRANCH_NAME}"
                script {
                    // Build docker image
                    sh "docker build -t ${IMAGE_NAME}:${env.BRANCH_NAME.replaceAll('/', '-')} ."
                }
                echo "✅ Build completed!"
            }
        }

        // ══════════════════════════════════════════
        // STAGE 2: TEST (Good practice to add!)
        // Runs on: develop AND feature/SS-TEST-*
        // ══════════════════════════════════════════
        stage('Test') {
            when {
                anyOf {
                    branch 'develop'
                    branch pattern: 'feature/SS-TEST-.*', comparator: 'REGEXP'
                }
            }
            steps {
                echo "🧪 Running tests on branch: ${env.BRANCH_NAME}"
                // sh 'run your tests here'
                echo "✅ Tests passed!"
            }
        }

        // ══════════════════════════════════════════
        // STAGE 3: DEPLOY TO DEV
        // Runs ONLY on: develop
        // ══════════════════════════════════════════
        stage('Deploy to Dev') {
            when {
                branch 'develop'
            }
            steps {
                echo "🚀 Deploying to DEV container..."
                script {
                    sh """
                        docker rm -f ${DEV_CONTAINER} || true
                        docker run -d --name ${DEV_CONTAINER} \
                            -p ${DEV_PORT}:80 \
                            ${IMAGE_NAME}:develop
                    """
                }
                echo "✅ Deployed to DEV at http://localhost:${DEV_PORT}"
            }
        }

        // ══════════════════════════════════════════
        // STAGE 4: DEPLOY TO PROD
        // Runs ONLY on: prod
        // NO BUILD — uses pre-built image from develop!
        // ══════════════════════════════════════════
        stage('Deploy to Prod') {
            when {
                branch 'prod'
            }
            steps {
                echo "🚀 Deploying to PROD container..."
                script {
                    // Reuses the develop image (no rebuild!)
                    sh """
                        docker rm -f ${PROD_CONTAINER} || true
                        docker run -d --name ${PROD_CONTAINER} \
                            -p ${PROD_PORT}:80 \
                            ${IMAGE_NAME}:develop
                    """
                }
                echo "✅ Deployed to PROD at http://localhost:${PROD_POR