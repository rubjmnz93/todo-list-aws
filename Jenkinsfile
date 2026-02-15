pipeline {
    agent any // usar cualquier agente disponible para ejecutar la pipeline

    options { skipDefaultCheckout() } // Evitar el checkout automático del código al inicio de la pipeline

    environment { // Definir variables de entorno para toda la pipeline
        ENVIRONMENT = 'production' // Variable de entorno para indicar el entorno de despliegue
        GIT_REPO_URL = 'github.com/rubjmnz93/todo-list-aws.git' // URL del repositorio Git, configurada como variable de entorno en Jenkins para mayor flexibilidad
    }

    stages {

        stage('Get Code') {
            steps {
                echo 'Checkout code from GitHub'
                git url: "https://${GIT_REPO_URL}", branch: 'master' // Realizar el checkout del código desde el repositorio GitHub, utilizando la URL y el tag de release
                echo 'Get SAM configuration file'
                sh 'wget https://raw.githubusercontent.com/rubjmnz93/todo-list-aws-config/refs/heads/${ENVIRONMENT}/samconfig.toml'
            }
        }
        
        stage('SetUp'){
            steps{
                echo 'Setup Virtualenv for testing'
                sh "bash pipelines/PIPELINE-FULL-PRODUCTION/setup.sh" // Ejecutar el script de configuración para preparar el entorno de pruebas, como la creación de un entorno virtual y la instalación de dependencias
            }
        }
        stage('Build') {
            steps{
                echo 'Package sam application:'
                sh "bash pipelines/common-steps/build.sh" // Ejecutar el script de construcción para empaquetar la aplicación utilizando AWS SAM, lo que prepara la aplicación para su despliegue posterior
            }
        }
        stage('Deploy'){
            steps{
                echo 'Initiating Deployment wit SAM'
                sh "bash pipelines/common-steps/deploy.sh" // Ejecutar el script de despliegue para desplegar la aplicación utilizando AWS SAM, lo que implementa la aplicación en el entorno de producción de AWS
            }
        }
        stage('Rest Tests'){
            steps{
                script {
                    def BASE_URL = sh( script: "aws cloudformation describe-stacks --stack-name todo-list-aws-production --query 'Stacks[0].Outputs[?OutputKey==`BaseUrlApi`].OutputValue' --region us-east-1 --output text",
                        returnStdout: true) // Ejecutar un comando de AWS CLI para obtener la URL base de la API desplegada en AWS, utilizando el nombre del stack y la región especificados
                    echo "$BASE_URL" // Imprimir la URL base obtenida
                    echo 'Initiating Rest Tests after deployment' 
                    sh "bash pipelines/common-steps/integration.sh $BASE_URL" // Ejecutar el script de pruebas de integración para realizar pruebas REST contra la API desplegada, pasando la URL base como argumento para que las pruebas puedan interactuar con la API correctamente. Los resultados de las pruebas se guardan en result-integration.xml para su posterior publicación en Jenkins
                }
                   
            }
            post {
                always {
                    junit 'result-integration.xml' // Publicar los resultados de las pruebas de integración utilizando el plugin JUnit
                }
            }
        }
    }
    post { 
        always { 
            echo 'Clean env: delete dir'
            cleanWs() // Limpiar el espacio de trabajo después de la ejecución del pipeline
        }
    }
}
