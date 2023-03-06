// 代码仓库地址
env.GIT_URL = 'http://127.0.0.1:8081/root/hello_java.git'
// 要构建的分支
env.BRANCHES = 'main'
// docker镜像仓库命名空间
env.Aliyun_Repo_Name_Space = 'develop_bigbigliu/'
// docker镜像仓库
env.Aliyun_Repo = 'registry.cn-zhangjiakou.aliyuncs.com/'
// gitlab 凭证id
env.CREDENTIALSID = 'gitlab_hello_java'
// 服务名
env.ServiceName = 'hello_java'
// 镜像仓库凭证
env.Image_CREDENTIALSID = 'alibaba_repo'
// k8s master主机地址
env.K8S_MASTER_HOST = '127.0.0.1'
// k8s master 登录凭证
env.K8s_Master_CREDENTIALSID = 'k8s_master'
// k8s NameSpace
env.NAMESPACE = 'default'

pipeline {
    agent any 
    stages {
        stage('Source') { 
            steps {
                // 打印环境变量
                sh 'printenv'
                git  branch: 'main', credentialsId: 'gitlab_repo_hello_echo', url: 'http://127.0.0.1:8081/root/hello_java.git'
            }
        }
        stage('Test') { 
            steps {
                echo "test start"
                echo "test end" 
            }
        }
        stage('Build') { 
            steps {
                script {
                    // 获取tag
                    def git_tag = sh(script: 'git describe --always --tag', returnStdout: true).trim()

                    container_full_name = env.ServiceName + ':' + git_tag
                    println container_full_name

                    repository = env.Aliyun_Repo + env.Aliyun_Repo_Name_Space + env.ServiceName + ':' + git_tag
                    
                    env.IMAGE_NAME = repository
                    println repository
                    println env.IMAGE_NAME

                    // 使用jenkisn凭证里保存的账号密码
                    withCredentials([usernamePassword(credentialsId: env.Image_CREDENTIALSID, usernameVariable: "username", passwordVariable: "password")]){
                        sh 'pwd && ls -alh'
                        sh 'printenv'
                        sh "docker login --username=$username --password=$password registry.cn-zhangjiakou.aliyuncs.com"
                        sh "docker build -t ${repository} ."
                        sh "docker push ${repository}"

                        // 清理构建现场
                        // sh 'docker rmi ${repository}'
                        // sh 'docker images | grep test | awk \'{print $1":"$2}\' | xargs docker rmi -f || true'
                        // 清理none镜像
                        // sh 'docker rmi -f  `docker images | grep \'<none>\' | awk \'{print $3}\'` || true'
                    }
                }
            }
        }
        stage('Deploy') { 
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: env.K8s_Master_CREDENTIALSID, usernameVariable: "username", passwordVariable: "password")]){
                    // ssh到远程主机替换k8s delpoyment镜像
                    def remote = [:]
                    remote.name = 'root'
                    remote.host = env.K8S_MASTER_HOST
                    remote.user = username
                    remote.password = password
                    remote.allowAnyHosts = true

                    test_commond = 'kubectl set image deployment/hellojava container-0=' + env.IMAGE_NAME
                    sshCommand remote: remote, command: test_commond
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'One way or another, I have finished'
            deleteDir() /* clean up our workspace */
        }
        success {
            echo 'I succeeeded!'
            script {
                // http request 插件
                def requestBody = [
                    
                    "service_name": env.ServiceName,
                    "jenkins_url": env.BUILD_URL,
                    "image": env.IMAGE_NAME,
                    "status": "Success",
                ]
                def response = httpRequest \
                            httpMode: "POST",
                            ignoreSslErrors: true,
                            contentType: 'APPLICATION_JSON',
                            requestBody: groovy.json.JsonOutput.toJson(requestBody),
                            url: "http://127.0.0.1:30003/webhook/jenkins"
                
                println response.content
                echo "Success"
            }
        }
        unstable {
            echo 'I am unstable :/'
        }
        failure {
            echo 'I failed :('
            script {
                // http request 插件
                def requestBody = [
                    
                    "service_name": env.ServiceName,
                    "jenkins_url": env.BUILD_URL,
                    "image": env.IMAGE_NAME,
                    "status": "Failed",
                ]
                def response = httpRequest \
                            httpMode: "POST",
                            ignoreSslErrors: true,
                            contentType: 'APPLICATION_JSON',
                            requestBody: groovy.json.JsonOutput.toJson(requestBody),
                            url: "http://127.0.0.1:30003/webhook/jenkins"
                
                println response.content
                echo "Success"
            }
        }
        changed {
            echo 'Things were different before...'
        }
    }
}