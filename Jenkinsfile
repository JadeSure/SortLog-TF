pipeline {
    agent any 

    //  parameters {
    //     booleanParam defaultValue: true,  description: 'True: generate TF AWS resources', name: 'applyTF'

    // }   
    parameters {
        choice choices: ['apply', 'destroy'], description: '''apply for creating resources
        destroy for releasing all the resources''', name: 'TFOperation'
        choice choices: ['dev-uat', 'prod'], description: '''apply for creating resources
        destroy for releasing all the resources''', name: 'APP_ENV'
    }

    environment {
        AWS_CRED = "AWS_sortlog"
        AWS_REGION = "ap-southeast-2"

        // tf
        APP_ENV = "$APP_ENV"
    }   


    stages {

        stage ('tf-dev'){
            steps {
                withAWS(credentials: AWS_CRED, region: AWS_REGION){
                    script {
                        if (env.BRANCH_NAME == 'dev'){
                             sh  '''
                            terraform init -input=false
                            terraform workspace select $APP_ENV || terraform workspace new $APP_ENV
                            terraform $TFOperation \
                               -var="env_prefix=$APP_ENV"\
                               --auto-approve
                            '''
                            script {
                                front_domain_name = sh(returnStdout: true, script: "terraform output front_domain_name")
                                back_domain_name = sh(returnStdout: true, script: "terraform output back_domain_name")
                                cdn = sh(returnStdout: true, script: "terraform output cdn")
                                alb_dns_name = sh(returnStdout: true, script: "terraform output alb_dns_name")
                            }
                            sh  "echo ${front_domain_name}"
                            sh  "echo ${back_domain_name}"
                        }
                    }
                }
            }
        }
    }

    post {
        always {
            script {
                try{
                    // docker images -qa | xargs docker rmi -f
                    sh'''
                        docker rmi $(docker images -q)
                        docker system prune
                        cleanWs()
                    '''
                } catch (Exception e) {
                    echo "docker clean failed"
                }
            }
        
        }

        failure {
            // send message it was failsure
            echo "uhm... 我觉得不太行！"
        }

        success {
            // send message it was success
            echo "老铁！恭喜你，成功了呀!"
        }
    }
 
}
