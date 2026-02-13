pipeline {
    agent any

    environment {
        ENVIRONMENT = 'staging'
    }


    stages {
        
        stage('SetUp'){
            steps{
                echo 'Setup Virtualenv for testing'
                sh "bash pipelines/PIPELINE-FULL-STAGING/setup.sh"
            }
        }
        stage('Static Test'){
            steps{
                echo 'Static program analysis:'
                sh "bash pipelines/PIPELINE-FULL-STAGING/static_test.sh"
                echo 'Unit testing:'
                sh "bash pipelines/PIPELINE-FULL-STAGING/unit_test.sh"
            }
            post {
                always {
                    script {
                        def failed = publishCoverage (failUnhealthy: true, 
                            globalThresholds: [[thresholdTarget: 'Line', unhealthyThreshold: 70.0]],
                            adapters: [coberturaAdapter(
                                mergeToOneReport: true, 
                                path: '**/coverage.xml')])
                    }
                    recordIssues tools: [flake8(pattern: 'flake8.out')]
                    recordIssues tools: [pyLint(name: 'Bandit', pattern: 'bandit.out')]
                    junit 'result-unit.xml'
                }
            }
        }
       stage('Build') {
            steps{
                echo 'Package sam application:'
                sh "bash pipelines/common-steps/build.sh"
            }
        }
        stage('Deploy'){
            steps{
                echo 'Initiating Deployment wit SAM'
                sh "bash pipelines/common-steps/deploy.sh"
            }
        }
        stage('Rest Tests'){
            steps{
                script {
                    def BASE_URL = sh( script: "aws cloudformation describe-stacks --stack-name todo-list-aws-staging --query 'Stacks[0].Outputs[?OutputKey==`BaseUrlApi`].OutputValue' --region us-east-1 --output text",
                        returnStdout: true)
                    echo "$BASE_URL"
                    echo 'Initiating Rest Tests after deployment'
                    sh "bash pipelines/common-steps/integration.sh $BASE_URL"
                }
                   
            }
        }
        stage('Promote'){
            steps{
                withCredentials([usernamePassword(
                    credentialsId: 'github-token',
                    usernameVariable: 'GIT_USER',
                    passwordVariable: 'GIT_TOKEN'
                )]) {
                    sh '''
                        set -eux

                        git remote set-url origin https://${GIT_USER}:${GIT_TOKEN}@github.com/rubjmnz93/todo-list-aws.git

                        git fetch origin master:master

                        # Avoid merge conflicts with Jenkins file in master branch
                        git config merge.ours.driver true

                        git checkout master
                        git clean -fd

                        git merge origin/develop --no-ff -m "Auto promote develop -> master [CI]"

                        # create an annotated tag for this release (timestamp based)
                        TAG="release-$(date -u +%Y%m%dT%H%M%SZ)"
                        git tag -a "$TAG" -m "Release $TAG"

                        git push origin master --tags
                    '''
                }

            }
        }
    }
    post { 
        always { 
            echo 'Clean env: delete dir'
            cleanWs()
        }
    }
}