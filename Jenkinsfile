try{
	node('master'){
            def docker
            def dockerCMD
            def maven
            def mavenCMD
            def dockerImage
            def tagName
            def gitURL
            def projectName
            stage('prepare'){
                echo "Prepare Tools and Variables to be used in Pipeline Script"
                docker = tool name: 'myDocker', type: 'dockerTool'
                dockerCMD = "${docker}/bin/docker"
                maven = tool name: 'myMaven', type: 'maven'
                mavenCMD = "${maven}/bin/mvn"
                dockerImage = "mdanwarjamal/bootcamp10-case-study"
                tagName = "1.0"
                gitURL = "https://github.com/mdanwarjamal"
                gitSSH = "git@github.com:mdanwarjamal"
                projectName = "bootcamp10-case-study"
            }
            stage('checkout'){
                echo "Checkout Application Code from GitHub Repository"
                git branch: 'main', credentialsId: 'GitHubSSH', url: "${gitSSH}/${projectName}.git"
            }
            stage('build'){
                echo "Build Application Code"
                sh "${mavenCMD} compile"
            }
            stage('package'){
                echo "Generate jar file for Application"
                sh "${mavenCMD} clean package"
            }
            stage('test'){
                echo "Test Application Code"
                sh "${mavenCMD} test -o site"
            }
            stage('publish surefire html report'){
                echo "Publish HTML Surefire Report for Junit"
                publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'target/site', reportFiles: 'surefire-report.html,dependencies.html,dependency-management.html,dependency-info.html', reportName: 'HTML Surefire Report', reportTitles: ''])
            }
      	    stage('publish jacoco coverage test HTML reports'){
            		echo "Publish Jacoco Coverage HTML Reports"
            		publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'target/site/jacoco', reportFiles: 'index.html,jacoco-sessions.html', reportName: 'HTML Jacoco Report', reportTitles: ''])
      	    }
            stage('start Docker'){
               sh "sudo service {dockerCMD} start"
               sh "sudo systemctl enable ${dockerCMD}"
            }
            stage('build docker image'){
                echo "Build Docker image from Dockerfile"
                sh "${dockerCMD} build -t ${dockerImage}:${tagName} ."
            }
            stage('Push to DockerHub'){
                echo "Push Docker Image to DockerHub Online Registry"
                withCredentials([usernamePassword(credentialsId: 'DockerHub', passwordVariable: 'dockerHubPwd', usernameVariable: 'dockerHubUsername')]) {
                    sh "${dockerCMD} login -u ${dockerHubUsername}  -p ${dockerHubPwd}"
                    sh "${dockerCMD} push  ${dockerImage}:${tagName}"
                }
            }
            stage('Deploy Application using Ansible'){
                echo "Install Docker in Ansible host machines"
                echo "deploying spring application"
                ansiblePlaybook credentialsId: 'Ansible', disableHostKeyChecking: true, installation: 'myAnsible', inventory: '/etc/ansible/hosts', playbook: 'deployment.yml'
            }
            stage('Send mail on success'){
        	    	echo "Deployment was successful"
        		    emailext attachLog: true, body: ''' Congratulations Jenkins Build was Successful :) !!!''', subject: 'Case Study CI/CD Pipeline', to: 'cse.mdanwarjamal@gmail.com'
	          }
            currentBuild.result = 'SUCCESS'
        }
}
catch(Exception ex){
        echo "Exception Occured"
        emailext attachlog: false, body: '''Unfortunately, Jenkins Build was Unsucessful :(''', subject: 'Case Study CI/CD Pipeline', to:'cse.mdanwarjamal@gmail.com'
        currentBuild.result = 'FAILURE'
}
finally{
        (currentBuild.result != "ABORTED") && node("master"){
            step([
              $class: 'Mailer',
              notifyEveryUnstableBuild: true,
              recipients: 'cse.mdanwarjamal@gmail.com',
              sendToIndividuals: true
            ])
        }
}
